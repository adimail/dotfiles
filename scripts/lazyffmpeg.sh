#!/usr/bin/env bash

# Image & Video FFmpeg FZF Interface Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
	echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
	echo -e "${GREEN}✔ ${1}${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
	echo -e "${RED}✖ ${1}${NC}"
}

print_media() {
	echo -e "${MAGENTA}🎞 ${1}${NC}"
}

# Global arrays for plugins
declare -a LOADED_PLUGIN_NAMES
declare -a LOADED_PLUGIN_COMMANDS
declare -a LOADED_PLUGIN_DATATYPES

# Function to load plugins from JSON file
load_plugins() {
	local PLUGIN_DIR="${HOME}/.lazyffmpeg"
	local PLUGIN_FILE_PATH="${PLUGIN_DIR}/plugins.json"
	if ! command -v jq &>/dev/null; then
		print_warning "jq is not installed. Plugin support will be disabled."
		print_warning "Please install jq to use custom plugins (e.g., 'sudo apt install jq' or 'brew install jq')."
		return 1 # Indicates jq is missing
	fi
	if [ ! -d "$PLUGIN_DIR" ]; then
		print_info "Plugin directory $PLUGIN_DIR does not exist. Creating it."
		mkdir -p "$PLUGIN_DIR"
	fi
	if [ ! -f "$PLUGIN_FILE_PATH" ]; then
		# Plugin file doesn't exist - skip silently and return
		return 0
	fi
	local plugin_data
	# Fix 1: Check jq command directly instead of using $?
	if ! plugin_data=$(jq -c '.[]' "$PLUGIN_FILE_PATH" 2>/dev/null); then
		print_error "Failed to parse plugin file: $PLUGIN_FILE_PATH."
		print_error "Ensure it is valid JSON. You can validate it with 'jq . \"$PLUGIN_FILE_PATH\"'."
		return 1 # Indicates parsing error
	fi

	# Additional check for empty but valid JSON (empty array case)
	if [ -z "$plugin_data" ] && [ -s "$PLUGIN_FILE_PATH" ]; then
		# This is likely an empty array [], which is valid JSON but produces no output
		return 0
	fi

	# Clear previous plugin data in case of re-load (not current use case but good practice)
	LOADED_PLUGIN_NAMES=()
	LOADED_PLUGIN_COMMANDS=()
	LOADED_PLUGIN_DATATYPES=()
	local temp_names=()
	local temp_commands=()
	local temp_datatypes=()
	local lines_processed=0
	# Read line by line from the jq output (each object is on its own line)
	while IFS= read -r plugin_json_object; do
		lines_processed=$((lines_processed + 1))
		if [ -z "$plugin_json_object" ]; then # Should not happen with jq -c '.[]' unless input is empty array
			continue
		fi
		local name command datatype
		# Extract fields using jq from the individual JSON object string
		name=$(jq -r '.name' <<<"$plugin_json_object")
		command=$(jq -r '.command' <<<"$plugin_json_object")
		datatype=$(jq -r '.dataType' <<<"$plugin_json_object")
		# jq returns string "null" if key is missing or value is JSON null.
		if [ -z "$name" ] || [ "$name" == "null" ] ||
			[ -z "$command" ] || [ "$command" == "null" ] ||
			[ -z "$datatype" ] || [ "$datatype" == "null" ]; then
			print_warning "Skipping plugin with missing/invalid fields in $PLUGIN_FILE_PATH: $plugin_json_object"
			continue
		fi
		temp_names+=("$name")
		temp_commands+=("$command")
		temp_datatypes+=("$datatype")
	done <<<"$plugin_data"
	# Assign to global arrays
	LOADED_PLUGIN_NAMES=("${temp_names[@]}")
	LOADED_PLUGIN_COMMANDS=("${temp_commands[@]}")
	LOADED_PLUGIN_DATATYPES=("${temp_datatypes[@]}")
	if [ ${#LOADED_PLUGIN_NAMES[@]} -gt 0 ]; then
		print_info "Successfully loaded ${#LOADED_PLUGIN_NAMES[@]} custom plugins."
	elif [ "$lines_processed" -gt 0 ]; then
		print_warning "Found plugin entries in $PLUGIN_FILE_PATH, but none were valid."
	fi
	return 0
}

# Check if required tools are installed
check_dependencies() {
	local missing=()

	if ! command -v fzf &>/dev/null; then
		missing+=("fzf")
	fi

	if ! command -v ffmpeg &>/dev/null; then
		missing+=("ffmpeg")
	fi

	if [ "${#missing[@]}" -ne 0 ]; then
		print_error "Missing critical dependencies: ${missing[*]}"
		print_error "Please install the missing tools first."
		exit 1
	fi
}

# Detect file type based on extension
detect_file_type() {
	local file="$1"
	local ext="${file##*.}"
	local ext_lower

	ext_lower=$(printf "%s" "$ext" | tr '[:upper:]' '[:lower:]')
	case "$ext_lower" in
	# Video formats
	mp4 | avi | mkv | mov | wmv | flv | webm | m4v | mpg | mpeg | m2v | 3gp | 3g2 | f4v | asf | rm | rmvb | vob | ts | mts | m2ts)
		echo "video"
		;;
	# Image formats
	jpg | jpeg | png | gif | bmp | tiff | tif | webp | svg | ico | psd | raw | cr2 | nef | arw | dng | heic | heif | avif | jxl)
		echo "image"
		;;
	# Audio formats (for video operations like extract audio)
	mp3 | wav | flac | aac | ogg | m4a | wma | opus | ac3 | dts)
		echo "audio"
		;;
	*)
		echo "unknown"
		;;
	esac
}

# Get file info using ffprobe
get_file_info() {
	local file="$1"
	if command -v ffprobe &>/dev/null; then
		ffprobe -v quiet -print_format json -show_format -show_streams "$file" 2>/dev/null
	fi
}

# Helper: build a sorted list of all matching files, newest-first
get_sorted_file_list() {
	local predicates=("$@")
	if find . -maxdepth 1 -type f "${predicates[@]}" -printf '' &>/dev/null; then
		find . -maxdepth 1 -type f "${predicates[@]}" -printf '%T@ %p\n' |
			sort -nr |
			cut -d' ' -f2- |
			sed 's|^\./||'
	else
		find . -maxdepth 1 -type f "${predicates[@]}" -print0 |
			xargs -0 stat -f "%m %N" |
			sort -nr |
			awk '{ $1=""; sub(/^ /, ""); print }' |
			sed 's|^\./||'
	fi
}

# Main script
main() {
	check_dependencies

	# Load plugins early. load_plugins will print warnings if jq is missing or file is bad.
	# It returns 1 on critical failure (jq missing, parse error), 0 otherwise.
	load_plugins # We don't exit if it fails, just plugins won't be available.

	# Set working directory
	WORK_DIR="${1:-.}"
	if [ ! -d "$WORK_DIR" ]; then
		print_error "Directory '$WORK_DIR' does not exist."
		exit 1
	fi

	cd "$WORK_DIR" || exit 1

	INPUT_FILE=$(
		get_sorted_file_list \
			\( \
			-iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o \
			-iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.m4v" -o \
			-iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.m2v" -o -iname "*.3gp" -o \
			-iname "*.3g2" -o -iname "*.f4v" -o -iname "*.asf" -o -iname "*.rm" -o \
			-iname "*.rmvb" -o -iname "*.vob" -o -iname "*.ts" -o -iname "*.mts" -o \
			-iname "*.m2ts" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
			-iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.tif" -o \
			-iname "*.webp" -o -iname "*.svg" -o -iname "*.ico" -o -iname "*.psd" -o \
			-iname "*.raw" -o -iname "*.cr2" -o -iname "*.nef" -o -iname "*.arw" -o \
			-iname "*.dng" -o -iname "*.heic" -o -iname "*.heif" -o -iname "*.avif" -o \
			-iname "*.jxl" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o \
			-iname "*.aac" -o -iname "*.ogg" -o -iname "*.m4a" -o -iname "*.wma" -o \
			-iname "*.opus" -o -iname "*.ac3" -o -iname "*.dts" \
			\) |
			fzf \
				--prompt="Select input file: " \
				--height=70% \
				--border \
				--preview 'file {} 2>/dev/null; echo; ffprobe -v quiet -show_format -show_streams {} 2>/dev/null | head -20 || echo "No media info available"'
	)

	if [ -z "$INPUT_FILE" ]; then
		print_error "No input file selected. Exiting."
		exit 1
	fi

	# Detect file type
	FILE_TYPE=$(detect_file_type "$INPUT_FILE")

	print_success "Selected input file: $INPUT_FILE (Type: $FILE_TYPE)"

	echo -en "${BLUE}Enter output filename with extension: ${NC}" # Use print_info style for prompt
	read -r OUTPUT_FILE

	if [ -z "$OUTPUT_FILE" ]; then
		print_error "No output filename provided. Exiting."
		exit 1
	fi

	print_success "Output file will be: $OUTPUT_FILE"

	local -a OPERATIONS
	case "$FILE_TYPE" in
	video)
		OPERATIONS=(
			"convert_only:Convert format only"
			"compress_video:Compress video (reduce file size)"
			"change_resolution:Change video resolution"
			"change_fps:Change frame rate"
			"trim_video:Trim video (specify start/duration)"
			"extract_audio:Extract audio from video"
			"remove_audio:Remove audio track"
			"rotate_video:Rotate video"
			"flip_video:Flip video"
			"crop_video:Crop video"
			"brightness_contrast:Adjust brightness/contrast"
			"speed_change:Change video speed"
			"create_gif:Convert to GIF"
			"extract_frames:Extract frames as images"
			"stabilize:Stabilize shaky video"
			"blur_video:Apply blur effect"
			"sharpen_video:Sharpen video"
			"grayscale_video:Convert to grayscale"
			"sepia_video:Apply sepia effect"
			"reverse_video:Reverse video"
			"loop_video:Loop video multiple times"
			"merge_audio:Add/replace audio track"
			"add_subtitle:Burn subtitles into video"
		)
		;;
	image)
		OPERATIONS=(
			"convert_only:Convert format only"
			"resize:Resize image"
			"resize_percentage:Resize by percentage"
			"compress_quality:Compress with quality setting"
			"rotate:Rotate image"
			"flip:Flip image"
			"crop:Crop image"
			"blur:Apply blur effect"
			"sharpen:Sharpen image"
			"grayscale:Convert to grayscale"
			"sepia:Apply sepia effect"
			"brightness:Adjust brightness"
			"contrast:Adjust contrast"
			"gamma:Adjust gamma"
			"thumbnail:Create thumbnail"
			"border:Add border"
			"noise_reduction:Reduce noise"
			"color_balance:Adjust color balance"
			"saturation:Adjust saturation"
			"hue_shift:Shift hue"
		)
		;;
	audio)
		OPERATIONS=(
			"convert_only:Convert format only"
			"compress_audio:Compress audio (reduce bitrate)"
			"change_volume:Change audio volume"
			"trim_audio:Trim audio"
			"fade_in_out:Add fade in/out"
			"normalize:Normalize audio levels"
			"speed_change:Change audio speed"
			"reverse_audio:Reverse audio"
			"extract_segment:Extract audio segment"
		)
		;;
	*) # Includes "unknown"
		OPERATIONS=(
			"convert_only:Convert format only"
			"get_info:Get file information"
		)
		;;
	esac

	# Add custom plugins to OPERATIONS
	local num_loaded_plugins=${#LOADED_PLUGIN_NAMES[@]}
	if [ "$num_loaded_plugins" -gt 0 ]; then
		local added_plugins_count=0
		for ((i = 0; i < num_loaded_plugins; i++)); do
			local p_dtype="${LOADED_PLUGIN_DATATYPES[i]}"
			local p_name="${LOADED_PLUGIN_NAMES[i]}"
			# Allow plugin if its dataType matches current FILE_TYPE, or if plugin dataType is "any"
			if [[ "$p_dtype" == "$FILE_TYPE" || "$p_dtype" == "any" || ("$FILE_TYPE" == "unknown" && "$p_dtype" == "any") ]]; then
				OPERATIONS+=("plugin_$i:${p_name}") # Prefix with "plugin_" to identify them
				added_plugins_count=$((added_plugins_count + 1))
			fi
		done
		if [ "$added_plugins_count" -gt 0 ]; then
			print_info "Added $added_plugins_count custom plugins to the operations list."
		fi
	fi

	SELECTED_OP_DESC=$( # Get the description part
		printf '%s\n' "${OPERATIONS[@]}" |
			sed 's/^[^:]*://' | # Show only description
			fzf --prompt="Select operation: " --height=70% --border
	)

	if [ -z "$SELECTED_OP_DESC" ]; then
		print_error "No operation selected. Exiting."
		exit 1
	fi

	# Find the operation key based on the selected description
	OP_KEY=""
	for op_with_key in "${OPERATIONS[@]}"; do
		if [[ "$op_with_key" == *":$SELECTED_OP_DESC" ]]; then
			OP_KEY="${op_with_key%%:*}"
			break
		fi
	done

	if [ -z "$OP_KEY" ]; then
		print_error "Could not determine operation key for: $SELECTED_OP_DESC. Exiting."
		exit 1
	fi

	print_success "Selected operation: $SELECTED_OP_DESC (Key: $OP_KEY)"

	local -a COMMAND # Use an array for the command and its arguments

	case "$OP_KEY" in
	"convert_only")
		COMMAND=(ffmpeg -i "$INPUT_FILE" "$OUTPUT_FILE")
		;;

	# VIDEO OPERATIONS
	"compress_video")
		echo "Select compression level:"
		COMPRESSION=$(
			printf "High quality (CRF 18)\nGood quality (CRF 23)\nMedium quality (CRF 28)\nLow quality (CRF 32)\nCustom CRF" |
				fzf --prompt="Compression level: "
		)
		case "$COMPRESSION" in
		"High quality (CRF 18)") CRF=18 ;;
		"Good quality (CRF 23)") CRF=23 ;;
		"Medium quality (CRF 28)") CRF=28 ;;
		"Low quality (CRF 32)") CRF=32 ;;
		"Custom CRF")
			echo -n "Enter CRF value (0-51, lower is better quality): "
			read -r CRF
			;;
		*)
			print_error "Invalid compression choice."
			exit 1
			;;
		esac
		COMMAND=(ffmpeg -i "$INPUT_FILE" -c:v libx264 -crf "$CRF" -preset medium -c:a aac -b:a 128k "$OUTPUT_FILE")
		;;

	"change_resolution")
		echo "Select target resolution:"
		RESOLUTION=$(
			printf "4K (3840x2160)\n1080p (1920x1080)\n720p (1280x720)\n480p (854x480)\n360p (640x360)\nCustom" |
				fzf --prompt="Resolution: "
		)
		case "$RESOLUTION" in
		"4K (3840x2160)") RES="3840:-2" ;;
		"1080p (1920x1080)") RES="1920:-2" ;;
		"720p (1280x720)") RES="1280:-2" ;;
		"480p (854x480)") RES="854:-2" ;;
		"360p (640x360)") RES="640:-2" ;;
		"Custom")
			echo -n "Enter custom resolution (e.g., 1280x720, or 1280:-2 to maintain aspect ratio): "
			read -r RES
			;;
		*)
			print_error "Invalid resolution choice."
			exit 1
			;;
		esac
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=$RES" "$OUTPUT_FILE")
		;;

	"change_fps")
		echo -n "Enter target frame rate (e.g., 24, 30, 60): "
		read -r FPS
		COMMAND=(ffmpeg -i "$INPUT_FILE" -r "$FPS" "$OUTPUT_FILE")
		;;

	"trim_video")
		echo -n "Enter start time (e.g., 00:01:30 or 90): "
		read -r START_TIME
		echo -n "Enter duration (e.g., 00:02:00 or 120, or leave empty to go to end): "
		read -r DURATION
		if [ -z "$DURATION" ]; then
			COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -c copy "$OUTPUT_FILE")
		else
			COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -t "$DURATION" -c copy "$OUTPUT_FILE")
		fi
		;;

	"extract_audio")
		echo "Select audio format to extract:"
		FORMAT=$(
			printf "m4a (copy AAC if possible)\nmp3 (re-encode to MP3)\nwav (re-encode to WAV)\nflac (re-encode to FLAC)\naac (copy AAC into .aac if possible)\nogg (re-encode to OGG Vorbis)" |
				fzf --prompt="Audio format: "
		)
		# Update OUTPUT_FILE to reflect the new extension
		BASE_OUTPUT_FILE="${OUTPUT_FILE%.*}" # Output filename without extension

		case "$FORMAT" in
		"m4a (copy AAC if possible)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.m4a"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec copy -y "$OUTPUT_FILE")
			;;
		"aac (copy AAC into .aac if possible)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.aac"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec copy -y "$OUTPUT_FILE")
			;;
		"mp3 (re-encode to MP3)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.mp3"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec libmp3lame -b:a 192k -y "$OUTPUT_FILE")
			;;
		"wav (re-encode to WAV)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.wav"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec pcm_s16le -y "$OUTPUT_FILE")
			;;
		"flac (re-encode to FLAC)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.flac"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec flac -y "$OUTPUT_FILE")
			;;
		"ogg (re-encode to OGG Vorbis)")
			OUTPUT_FILE="${BASE_OUTPUT_FILE}.ogg"
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec libvorbis -qscale:a 5 -y "$OUTPUT_FILE")
			;;
		*)
			print_error "No valid format selected for audio extraction. Exiting."
			exit 1
			;;
		esac
		print_warning "Output file for extracted audio will be: $OUTPUT_FILE"
		;;

	"remove_audio")
		COMMAND=(ffmpeg -i "$INPUT_FILE" -c:v copy -an "$OUTPUT_FILE")
		;;

	"rotate_video")
		ROTATION=$(
			printf "90° clockwise\n180°\n270° clockwise (90° counter-clockwise)\nCustom angle" |
				fzf --prompt="Rotation: "
		)
		case "$ROTATION" in
		"90° clockwise")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=1 "$OUTPUT_FILE")
			;;
		"180°")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "transpose=2,transpose=2" "$OUTPUT_FILE") # Or rotate=PI
			;;
		"270° clockwise (90° counter-clockwise)")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=2 "$OUTPUT_FILE")
			;;
		"Custom angle")
			echo -n "Enter rotation angle in degrees (clockwise): "
			read -r ANGLE
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "rotate=${ANGLE}*PI/180" "$OUTPUT_FILE")
			;;
		*)
			print_error "Invalid rotation choice."
			exit 1
			;;
		esac
		;;

	"flip_video")
		FLIP_TYPE=$(
			printf "Horizontal\nVertical\nBoth" |
				fzf --prompt="Flip type: "
		)
		case "$FLIP_TYPE" in
		"Horizontal") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf hflip "$OUTPUT_FILE") ;;
		"Vertical") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf vflip "$OUTPUT_FILE") ;;
		"Both") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "hflip,vflip" "$OUTPUT_FILE") ;;
		*)
			print_error "Invalid flip choice."
			exit 1
			;;
		esac
		;;

	"crop_video")
		echo -n "Enter crop parameters (width:height:x:y, e.g., 1280:720:100:50): "
		read -r CROP_PARAMS
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "crop=$CROP_PARAMS" "$OUTPUT_FILE")
		;;

	"speed_change") # Video speed change
		SPEED=$(
			printf "0.5x (Half speed)\n2x (Double speed)\n4x (Quad speed)\nCustom" |
				fzf --prompt="Speed: "
		)
		case "$SPEED" in
		"0.5x (Half speed)") SPEED_VAL="0.5" ;;
		"2x (Double speed)") SPEED_VAL="2.0" ;;
		"4x (Quad speed)") SPEED_VAL="4.0" ;;
		"Custom")
			echo -n "Enter speed multiplier (e.g., 1.5 for faster, 0.75 for slower): "
			read -r SPEED_VAL
			;;
		*)
			print_error "Invalid speed choice."
			exit 1
			;;
		esac
		# For video, adjust both video PTS and audio tempo
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "setpts=PTS/${SPEED_VAL}" -af "atempo=${SPEED_VAL}" "$OUTPUT_FILE")
		;;

	"create_gif")
		echo -n "Enter start time (e.g., 00:01:30, or press Enter for beginning): "
		read -r START_TIME_GIF
		echo -n "Enter duration in seconds (e.g., 5): "
		read -r DURATION_GIF
		if ! [[ "$DURATION_GIF" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (($(echo "$DURATION_GIF <= 0" | bc -l))); then
			print_error "Invalid duration. Must be a positive number."
			exit 1
		fi
		echo -n "Enter GIF width (e.g., 480, or -1 to auto-scale height): "
		read -r GIF_WIDTH
		GIF_WIDTH=${GIF_WIDTH:-480} # Default to 480 if empty
		echo -n "Enter GIF FPS (e.g., 10, 15): "
		read -r GIF_FPS
		GIF_FPS=${GIF_FPS:-10} # Default to 10 if empty

		# Ensure output file has .gif extension
		if [[ "${OUTPUT_FILE##*.}" != "gif" ]]; then
			OUTPUT_FILE="${OUTPUT_FILE%.*}.gif"
			print_warning "Output filename changed to $OUTPUT_FILE for GIF format."
		fi

		local gif_ffmpeg_cmd_palette
		local gif_ffmpeg_cmd_usepalette

		if [ -n "$START_TIME_GIF" ]; then
			gif_ffmpeg_cmd_palette="ffmpeg -y -ss \"$START_TIME_GIF\" -t \"$DURATION_GIF\" -i \"$INPUT_FILE\" -vf \"fps=$GIF_FPS,scale=$GIF_WIDTH:-1:flags=lanczos,palettegen\" palette.png"
			gif_ffmpeg_cmd_usepalette="ffmpeg -ss \"$START_TIME_GIF\" -t \"$DURATION_GIF\" -i \"$INPUT_FILE\" -i palette.png -lavfi \"fps=$GIF_FPS,scale=$GIF_WIDTH:-1:flags=lanczos[x];[x][1:v]paletteuse\" \"$OUTPUT_FILE\""
		else
			gif_ffmpeg_cmd_palette="ffmpeg -y -t \"$DURATION_GIF\" -i \"$INPUT_FILE\" -vf \"fps=$GIF_FPS,scale=$GIF_WIDTH:-1:flags=lanczos,palettegen\" palette.png"
			gif_ffmpeg_cmd_usepalette="ffmpeg -t \"$DURATION_GIF\" -i \"$INPUT_FILE\" -i palette.png -lavfi \"fps=$GIF_FPS,scale=$GIF_WIDTH:-1:flags=lanczos[x];[x][1:v]paletteuse\" \"$OUTPUT_FILE\""
		fi
		COMMAND=(bash -c "$gif_ffmpeg_cmd_palette && $gif_ffmpeg_cmd_usepalette && rm palette.png")
		;;

	# IMAGE OPERATIONS
	"resize")
		echo -n "Enter target size (e.g., 800x600, 1920x-2 to maintain aspect ratio): "
		read -r SIZE
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=$SIZE" "$OUTPUT_FILE")
		;;

	"resize_percentage")
		echo -n "Enter percentage (e.g., 50 for 50%, 200 for 200%): "
		read -r PERCENTAGE
		SCALE=$(awk "BEGIN { printf \"%.2f\", $PERCENTAGE/100 }")
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=iw*$SCALE:ih*$SCALE" "$OUTPUT_FILE")
		;;

	"compress_quality") # For images
		OUTPUT_EXT_LOWER=$(printf "%s" "${OUTPUT_FILE##*.}" | tr '[:upper:]' '[:lower:]')
		if [[ "$OUTPUT_EXT_LOWER" == "jpg" || "$OUTPUT_EXT_LOWER" == "jpeg" ]]; then
			echo "Select JPEG quality:"
			QUALITY=$(
				printf "High (q:v 2)\nGood (q:v 5)\nMedium (q:v 10)\nLow (q:v 15)\nCustom" |
					fzf --prompt="Quality: "
			)
			case "$QUALITY" in
			"High (q:v 2)") Q_VAL=2 ;;
			"Good (q:v 5)") Q_VAL=5 ;;
			"Medium (q:v 10)") Q_VAL=10 ;;
			"Low (q:v 15)") Q_VAL=15 ;;
			"Custom")
				echo -n "Enter quality value for JPEG (1-31, lower is better): "
				read -r Q_VAL
				;;
			*)
				print_error "Invalid quality choice."
				exit 1
				;;
			esac
			COMMAND=(ffmpeg -i "$INPUT_FILE" -q:v "$Q_VAL" "$OUTPUT_FILE")
		elif [[ "$OUTPUT_EXT_LOWER" == "webp" ]]; then
			echo "Select WebP quality (0-100, higher is better, 75 is good default):"
			echo -n "Enter quality value for WebP (0-100): "
			read -r Q_VAL_WEBP
			COMMAND=(ffmpeg -i "$INPUT_FILE" -quality "$Q_VAL_WEBP" "$OUTPUT_FILE") # For libwebp via ffmpeg
		else
			print_warning "Quality compression primarily for JPEG/WebP. For other formats, this will be a direct conversion."
			COMMAND=(ffmpeg -i "$INPUT_FILE" "$OUTPUT_FILE")
		fi
		;;

	"rotate") # Image rotate
		ROTATION=$(
			printf "90° clockwise\n180°\n270° clockwise (90° counter-clockwise)\nCustom angle" |
				fzf --prompt="Rotation: "
		)
		case "$ROTATION" in
		"90° clockwise")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=1 "$OUTPUT_FILE")
			;;
		"180°")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "transpose=2,transpose=2" "$OUTPUT_FILE")
			;;
		"270° clockwise (90° counter-clockwise)")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=2 "$OUTPUT_FILE")
			;;
		"Custom angle")
			echo -n "Enter rotation angle in degrees (clockwise): "
			read -r ANGLE
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "rotate=${ANGLE}*PI/180" "$OUTPUT_FILE")
			;;
		*)
			print_error "Invalid rotation choice."
			exit 1
			;;
		esac
		;;

	"flip") # Image flip
		FLIP_TYPE=$(
			printf "Horizontal\nVertical\nBoth" |
				fzf --prompt="Flip type: "
		)
		case "$FLIP_TYPE" in
		"Horizontal") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf hflip "$OUTPUT_FILE") ;;
		"Vertical") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf vflip "$OUTPUT_FILE") ;;
		"Both") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "hflip,vflip" "$OUTPUT_FILE") ;;
		*)
			print_error "Invalid flip choice."
			exit 1
			;;
		esac
		;;

	"border")
		print_info "Configure Border:"
		echo -n "Enter border thickness in pixels (e.g., 10): "
		read -r BORDER_THICKNESS
		if ! [[ "$BORDER_THICKNESS" =~ ^[1-9][0-9]*$ ]]; then
			print_error "Invalid border thickness. Must be a positive integer."
			exit 1
		fi

		echo -n "Enter border color (e.g., black, white, red, #FF0000, 0x00FF00): "
		read -r BORDER_COLOR
		BORDER_COLOR=${BORDER_COLOR:-black} # Default to black if empty

		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "pad=width=iw+2*${BORDER_THICKNESS}:height=ih+2*${BORDER_THICKNESS}:x=${BORDER_THICKNESS}:y=${BORDER_THICKNESS}:color=${BORDER_COLOR}" "$OUTPUT_FILE")
		;;

	"crop") # Image crop
		echo -n "Enter crop dimensions (width:height:x:y, e.g., 800:600:100:50): "
		read -r CROP_PARAMS
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "crop=$CROP_PARAMS" "$OUTPUT_FILE")
		;;

	"blur") # Image blur
		echo -n "Enter blur radius (e.g., 5, 10 for boxblur strength): "
		read -r BLUR_RADIUS
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "boxblur=$BLUR_RADIUS" "$OUTPUT_FILE")
		;;

	"sharpen" | "sharpen_video")
		SHARPEN_LEVEL=$(
			printf "Light\nMedium\nStrong\nCustom" |
				fzf --prompt="Sharpen level: "
		)
		case "$SHARPEN_LEVEL" in
		"Light")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "unsharp=5:5:0.8:3:3:0.4" "$OUTPUT_FILE")
			;;
		"Medium")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "unsharp=5:5:1.0:3:3:0.5" "$OUTPUT_FILE")
			;;
		"Strong")
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "unsharp=5:5:1.5:3:3:0.8" "$OUTPUT_FILE")
			;;
		"Custom")
			echo -n "Enter sharpening luma strength (e.g., 0.0-2.0): "
			read -r LUMA_STRENGTH
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "unsharp=5:5:${LUMA_STRENGTH}:3:3:0.5" "$OUTPUT_FILE") # Default chroma params
			;;
		*)
			print_error "Invalid sharpen choice."
			exit 1
			;;
		esac
		;;

	"grayscale" | "grayscale_video")
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "format=gray" "$OUTPUT_FILE")
		;;

	"sepia" | "sepia_video")
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" "$OUTPUT_FILE")
		;;

	"brightness" | "brightness_contrast") # brightness_contrast for video, brightness for image
		echo -n "Enter brightness adjustment (-1.0 to 1.0, 0 is no change): "
		read -r BRIGHTNESS
		if [ "$FILE_TYPE" = "video" ] || [ "$OP_KEY" = "brightness_contrast" ]; then # Also handle if image op explicitly calls for contrast
			echo -n "Enter contrast adjustment (-2.0 to 2.0 for video, -1000 to 1000 for image eq, 1 or 0 is no change): "
			read -r CONTRAST
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=brightness=${BRIGHTNESS}:contrast=${CONTRAST}" "$OUTPUT_FILE")
		else # Image only brightness
			COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=brightness=${BRIGHTNESS}" "$OUTPUT_FILE")
		fi
		;;

	"contrast") # Image only contrast
		echo -n "Enter contrast adjustment (-1000.0 to 1000.0, 0 is no change for eq filter): "
		read -r CONTRAST
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=contrast=${CONTRAST}" "$OUTPUT_FILE")
		;;

	"gamma")
		echo -n "Enter gamma adjustment (0.1 to 10.0, 1 is no change): "
		read -r GAMMA
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=gamma=${GAMMA}" "$OUTPUT_FILE")
		;;

	"thumbnail")
		SIZE_OPT=$(
			printf "150x150\n200x200\n300x300\nCustom" |
				fzf --prompt="Thumbnail size (WxH): "
		)
		local THUMB_SIZE
		if [ "$SIZE_OPT" = "Custom" ]; then
			echo -n "Enter thumbnail size (e.g., 250x250, or 250x-1 to maintain aspect): "
			read -r THUMB_SIZE
		else
			THUMB_SIZE="$SIZE_OPT"
		fi
		COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=$THUMB_SIZE" "$OUTPUT_FILE")
		;;

	# AUDIO OPERATIONS
	"compress_audio")
		echo "Select audio quality/bitrate:"
		QUALITY=$(
			printf "128k\n192k\n256k\n320k\nCustom" |
				fzf --prompt="Bitrate: "
		)
		local BITRATE
		if [ "$QUALITY" = "Custom" ]; then
			echo -n "Enter bitrate (e.g., 160k): "
			read -r BITRATE
		else
			BITRATE="$QUALITY"
		fi
		COMMAND=(ffmpeg -i "$INPUT_FILE" -b:a "$BITRATE" "$OUTPUT_FILE")
		;;

	"change_volume")
		echo -n "Enter volume multiplier (e.g., 0.5 for half, 2.0 for double) or dB value (e.g., -6dB, 3dB): "
		read -r VOLUME
		COMMAND=(ffmpeg -i "$INPUT_FILE" -af "volume=${VOLUME}" "$OUTPUT_FILE")
		;;

	"trim_audio")
		echo -n "Enter start time (e.g., 00:01:30 or 90): "
		read -r START_TIME
		echo -n "Enter duration (e.g., 00:02:00 or 120, or leave empty to go to end): "
		read -r DURATION
		if [ -z "$DURATION" ]; then
			COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -c copy "$OUTPUT_FILE") # Or re-encode if format changes
		else
			COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -t "$DURATION" -c copy "$OUTPUT_FILE")
		fi
		;;

	"get_info")
		print_info "Getting file information for $INPUT_FILE..."
		get_file_info "$INPUT_FILE" | jq '.' # Pipe to jq for pretty printing if available
		exit 0                               # Exit after showing info, no output file generated
		;;

	plugin_*)
		local plugin_index="${OP_KEY#plugin_}" # Extract the index from "plugin_X"
		local raw_plugin_command="${LOADED_PLUGIN_COMMANDS[plugin_index]}"

		if [ -z "$raw_plugin_command" ]; then
			print_error "Could not find command for plugin key $OP_KEY (index $plugin_index)."
			exit 1
		fi
		# The raw_plugin_command string should already have "$INPUT_FILE" and "$OUTPUT_FILE"
		# These will be expanded by the current shell when bash -c executes the command string.
		# Make sure INPUT_FILE and OUTPUT_FILE are exported so subshells from bash -c can see them if needed,
		# though direct expansion by the parent shell invoking bash -c is usually sufficient.
		export INPUT_FILE OUTPUT_FILE
		COMMAND=(bash -c "$raw_plugin_command")
		;;

	*)
		print_error "Unknown operation key: $OP_KEY"
		exit 1
		;;
	esac

	echo
	print_warning "Command to execute:"
	# Properly quote each part of the command for display
	local cmd_display=""
	for part in "${COMMAND[@]}"; do
		cmd_display+=$(printf "%q " "$part")
	done
	echo -e "  ${YELLOW}$cmd_display${NC}"
	echo
	print_warning "Input file:  $INPUT_FILE"
	print_warning "Output file: $OUTPUT_FILE" # This might have been updated by 'extract_audio' or 'create_gif'
	print_warning "File type:   $FILE_TYPE"

	echo
	echo -n -e "${BLUE}Execute this command? (Y/n): ${NC}"
	read -r CONFIRM
	if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
		print_info "Operation cancelled by user."
		exit 0
	fi

	print_info "Executing FFmpeg operation..."
	echo
	# Execute the command array directly
	if "${COMMAND[@]}"; then
		print_success "Operation completed successfully!"
		if [ -f "$OUTPUT_FILE" ]; then # Check if output file was actually created
			print_success "Output file: $OUTPUT_FILE"
			# Show basic file info
			print_info "Output file details:"
			ls -lh "$OUTPUT_FILE"
			if command -v file &>/dev/null; then
				file "$OUTPUT_FILE"
			fi
		else
			print_warning "Output file $OUTPUT_FILE was not found. The plugin or command might not have created it as expected."
		fi
	else
		print_error "Operation failed! Check FFmpeg output above for details."
		exit 1
	fi
}

# Ensure script exits if any command fails when not explicitly handled
trap 'print_error "An unexpected error occurred. Exiting."; exit 1' ERR

main "$@"
