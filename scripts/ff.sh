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
    echo -e "${GREEN}${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}${1}${NC}"
}

print_error() {
    echo -e "${RED}${1}${NC}"
}

print_media() {
    echo -e "${MAGENTA}🎬 ${1}${NC}"
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
        print_error "Missing dependencies: ${missing[*]}"
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
        mp4|avi|mkv|mov|wmv|flv|webm|m4v|mpg|mpeg|m2v|3gp|3g2|f4v|asf|rm|rmvb|vob|ts|mts|m2ts)
            echo "video"
            ;;
        # Image formats
        jpg|jpeg|png|gif|bmp|tiff|tif|webp|svg|ico|psd|raw|cr2|nef|arw|dng|heic|heif|avif|jxl)
            echo "image"
            ;;
        # Audio formats (for video operations like extract audio)
        mp3|wav|flac|aac|ogg|m4a|wma|opus|ac3|dts)
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
# If GNU find supports -printf, use it. Otherwise, use BSD find + stat.
get_sorted_file_list() {
    # Arguments: any "find . -type f \( … \)" predicates should be appended after "-type f".
    # Example usage: get_sorted_file_list -iname "*.mp4" -o -iname "*.jpg"
    local predicates=( "$@" )
    if find . -type f "${predicates[@]}" -printf '' &>/dev/null; then
        # GNU find available: use -printf '%T@ %p\n'
        find . -type f "${predicates[@]}" -printf '%T@ %p\n' \
            | sort -nr \
            | cut -d' ' -f2- \
            | sed 's|^\./||'
    else
        # BSD/Mac find: fallback to using stat
        # Note: stat -f '%m %N' prints "mtime filepath"
        find . -type f "${predicates[@]}" -print0 \
            | xargs -0 stat -f "%m %N" \
            | sort -nr \
            | awk '{ $1=""; sub(/^ /, ""); print }' \
            | sed 's|^\./||'
    fi
}

# Main script
main() {
    check_dependencies

    # Set working directory
    WORK_DIR="${1:-.}"
    if [ ! -d "$WORK_DIR" ]; then
        print_error "Directory '$WORK_DIR' does not exist."
        exit 1
    fi

    cd "$WORK_DIR" || exit 1

    # 1: Select input file (newest files first)
    print_info "1: Select input media file"
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
            \) \
        | fzf \
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

    print_success "Selected input file: $INPUT_FILE"
    print_media "Detected file type: $FILE_TYPE"

    # 2: Get output filename with extension
    print_info "2: Enter output filename with extension"
    echo -n "Enter output filename with extension: "
    read -r OUTPUT_FILE

    if [ -z "$OUTPUT_FILE" ]; then
        print_error "No output filename provided. Exiting."
        exit 1
    fi

    print_success "Output file: $OUTPUT_FILE"

    # 3: Select operation based on file type
    print_info "3: Select operation"

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
                "add_watermark:Add text watermark"
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
                "watermark:Add text watermark"
                "border:Add border"
                "noise_reduction:Reduce noise"
                "color_balance:Adjust color balance"
                "saturation:Adjust saturation"
                "hue_shift:Shift hue"
                "vignette:Add vignette effect"
                "emboss:Apply emboss effect"
                "oil_painting:Oil painting effect"
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
        *)
            OPERATIONS=(
                "convert_only:Convert format only"
                "get_info:Get file information"
            )
            ;;
    esac

    SELECTED_OP=$(
        printf '%s\n' "${OPERATIONS[@]}" \
        | sed 's/^[^:]*://' \
        | fzf --prompt="Select operation: " --height=70% --border
    )

    if [ -z "$SELECTED_OP" ]; then
        print_error "No operation selected. Exiting."
        exit 1
    fi

    # Find the operation key
    OP_KEY=""
    for op in "${OPERATIONS[@]}"; do
        if [[ "$op" == *":$SELECTED_OP" ]]; then
            OP_KEY="${op%%:*}"
            break
        fi
    done

    print_success "Selected operation: $SELECTED_OP"

    # 4: Configure operation parameters
    print_info "4: Configuring operation parameters"
    local COMMAND

    case "$OP_KEY" in
        "convert_only")
            COMMAND=(ffmpeg -i "$INPUT_FILE" "$OUTPUT_FILE")
            ;;

        # VIDEO OPERATIONS
        "compress_video")
            echo "Select compression level:"
            COMPRESSION=$(
                printf "High quality (CRF 18)\nGood quality (CRF 23)\nMedium quality (CRF 28)\nLow quality (CRF 32)\nCustom CRF" \
                | fzf --prompt="Compression level: "
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
            esac
            COMMAND=(ffmpeg -i "$INPUT_FILE" -c:v libx264 -crf "$CRF" -c:a aac -b:a 128k "$OUTPUT_FILE")
            ;;

        "change_resolution")
            echo "Select target resolution:"
            RESOLUTION=$(
                printf "4K (3840x2160)\n1080p (1920x1080)\n720p (1280x720)\n480p (854x480)\n360p (640x360)\nCustom" \
                | fzf --prompt="Resolution: "
            )
            case "$RESOLUTION" in
                "4K (3840x2160)") RES="3840x2160" ;;
                "1080p (1920x1080)") RES="1920x1080" ;;
                "720p (1280x720)") RES="1280x720" ;;
                "480p (854x480)") RES="854x480" ;;
                "360p (640x360)") RES="640x360" ;;
                "Custom")
                    echo -n "Enter custom resolution (e.g., 1280x720): "
                    read -r RES
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
            echo -n "Enter duration (e.g., 00:02:00 or 120): "
            read -r DURATION
            COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -t "$DURATION" -c copy "$OUTPUT_FILE")
            ;;

        "extract_audio")
            FORMAT=$(
                printf "mp3\nwav\nflac\naac\nogg" \
                | fzf --prompt="Audio format: "
            )
            OUTPUT_FILE_EXT="${OUTPUT_FILE%.*}.$FORMAT"
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vn -acodec copy "$OUTPUT_FILE_EXT")
            ;;

        "remove_audio")
            COMMAND=(ffmpeg -i "$INPUT_FILE" -c:v copy -an "$OUTPUT_FILE")
            ;;

        "rotate_video")
            ROTATION=$(
                printf "90° clockwise\n180°\n270° clockwise\nCustom angle" \
                | fzf --prompt="Rotation: "
            )
            case "$ROTATION" in
                "90° clockwise")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=1 "$OUTPUT_FILE")
                    ;;
                "180°")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "transpose=2,transpose=2" "$OUTPUT_FILE")
                    ;;
                "270° clockwise")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=2 "$OUTPUT_FILE")
                    ;;
                "Custom angle")
                    echo -n "Enter rotation angle in degrees: "
                    read -r ANGLE
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "rotate=${ANGLE}*PI/180" "$OUTPUT_FILE")
                    ;;
            esac
            ;;

        "flip_video")
            FLIP_TYPE=$(
                printf "Horizontal\nVertical\nBoth" \
                | fzf --prompt="Flip type: "
            )
            case "$FLIP_TYPE" in
                "Horizontal") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf hflip "$OUTPUT_FILE") ;;
                "Vertical")   COMMAND=(ffmpeg -i "$INPUT_FILE" -vf vflip "$OUTPUT_FILE") ;;
                "Both")       COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "hflip,vflip" "$OUTPUT_FILE") ;;
            esac
            ;;

        "crop_video")
            echo -n "Enter crop parameters (width:height:x:y, e.g., 1280:720:100:50): "
            read -r CROP_PARAMS
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "crop=$CROP_PARAMS" "$OUTPUT_FILE")
            ;;

        "speed_change")
            SPEED=$(
                printf "0.5x (Half speed)\n2x (Double speed)\n4x (Quad speed)\nCustom" \
                | fzf --prompt="Speed: "
            )
            case "$SPEED" in
                "0.5x (Half speed)") SPEED_VAL="0.5" ;;
                "2x (Double speed)") SPEED_VAL="2.0" ;;
                "4x (Quad speed)")   SPEED_VAL="4.0" ;;
                "Custom")
                    echo -n "Enter speed multiplier (e.g., 1.5, 0.75): "
                    read -r SPEED_VAL
                    ;;
            esac
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "setpts=PTS/${SPEED_VAL}" -af "atempo=${SPEED_VAL}" "$OUTPUT_FILE")
            ;;

        "create_gif")
            echo -n "Enter start time (e.g., 00:01:30, or press Enter for beginning): "
            read -r START_TIME
            echo -n "Enter duration in seconds (e.g., 5): "
            read -r DURATION
            GIF_OUTPUT="${OUTPUT_FILE%.*}.gif"
            if [ -n "$START_TIME" ]; then
                COMMAND=(bash -c "ffmpeg -ss \"$START_TIME\" -t \"$DURATION\" -i \"$INPUT_FILE\" -vf \"fps=10,scale=320:-1:flags=lanczos,palettegen\" -y palette.png && \
                                 ffmpeg -ss \"$START_TIME\" -t \"$DURATION\" -i \"$INPUT_FILE\" -i palette.png -lavfi \"fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse\" \"$GIF_OUTPUT\" && \
                                 rm palette.png")
            else
                COMMAND=(bash -c "ffmpeg -t \"$DURATION\" -i \"$INPUT_FILE\" -vf \"fps=10,scale=320:-1:flags=lanczos,palettegen\" -y palette.png && \
                                 ffmpeg -t \"$DURATION\" -i \"$INPUT_FILE\" -i palette.png -lavfi \"fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse\" \"$GIF_OUTPUT\" && \
                                 rm palette.png")
            fi
            ;;

        "add_watermark"|"watermark")
            echo -n "Enter watermark text: "
            read -r WATERMARK_TEXT
            echo -n "Enter font size (default: 24): "
            read -r FONT_SIZE
            FONT_SIZE=${FONT_SIZE:-24}

            POSITION=$(
                printf "Top-left\nTop-right\nBottom-left\nBottom-right\nCenter" \
                | fzf --prompt="Position: "
            )

            case "$POSITION" in
                "Top-left")     POS="10:10" ;;
                "Top-right")    POS="W-tw-10:10" ;;
                "Bottom-left")  POS="10:H-th-10" ;;
                "Bottom-right") POS="W-tw-10:H-th-10" ;;
                "Center")       POS="(W-tw)/2:(H-th)/2" ;;
            esac

            # Escape single quotes in watermark text
            WATERMARK_ESCAPED=${WATERMARK_TEXT//\'/\\\'}
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "drawtext=text='$WATERMARK_ESCAPED':fontsize=${FONT_SIZE}:fontcolor=white:x=$POS:shadowcolor=black:shadowx=2:shadowy=2" "$OUTPUT_FILE")
            ;;

        # IMAGE OPERATIONS
        "resize")
            echo -n "Enter target size (e.g., 800x600, 1920x1080): "
            read -r SIZE
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=$SIZE" "$OUTPUT_FILE")
            ;;

        "resize_percentage")
            echo -n "Enter percentage (e.g., 50 for 50%, 200 for 200%): "
            read -r PERCENTAGE
            SCALE=$(awk "BEGIN { printf \"%.2f\", $PERCENTAGE/100 }")
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=iw*$SCALE:ih*$SCALE" "$OUTPUT_FILE")
            ;;

        "compress_quality")
            OUTPUT_EXT="${OUTPUT_FILE##*.}"
            OUTPUT_EXT_LOWER=$(printf "%s" "$OUTPUT_EXT" | tr '[:upper:]' '[:lower:]')
            if [[ "$OUTPUT_EXT_LOWER" == "jpg" || "$OUTPUT_EXT_LOWER" == "jpeg" ]]; then
                echo "Select JPEG quality:"
                QUALITY=$(
                    printf "High (q:v 2)\nGood (q:v 5)\nMedium (q:v 10)\nLow (q:v 15)\nCustom" \
                    | fzf --prompt="Quality: "
                )
                case "$QUALITY" in
                    "High (q:v 2)") Q_VAL=2 ;;
                    "Good (q:v 5)") Q_VAL=5 ;;
                    "Medium (q:v 10)") Q_VAL=10 ;;
                    "Low (q:v 15)") Q_VAL=15 ;;
                    "Custom")
                        echo -n "Enter quality value (1-31, lower is better): "
                        read -r Q_VAL
                        ;;
                esac
                COMMAND=(ffmpeg -i "$INPUT_FILE" -q:v "$Q_VAL" "$OUTPUT_FILE")
            else
                COMMAND=(ffmpeg -i "$INPUT_FILE" "$OUTPUT_FILE")
            fi
            ;;

        "rotate")
            ROTATION=$(
                printf "90° clockwise\n180°\n270° clockwise\nCustom angle" \
                | fzf --prompt="Rotation: "
            )
            case "$ROTATION" in
                "90° clockwise")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=1 "$OUTPUT_FILE")
                    ;;
                "180°")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "transpose=2,transpose=2" "$OUTPUT_FILE")
                    ;;
                "270° clockwise")
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf transpose=2 "$OUTPUT_FILE")
                    ;;
                "Custom angle")
                    echo -n "Enter rotation angle in degrees: "
                    read -r ANGLE
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "rotate=${ANGLE}*PI/180" "$OUTPUT_FILE")
                    ;;
            esac
            ;;

        "flip")
            FLIP_TYPE=$(
                printf "Horizontal\nVertical\nBoth" \
                | fzf --prompt="Flip type: "
            )
            case "$FLIP_TYPE" in
                "Horizontal") COMMAND=(ffmpeg -i "$INPUT_FILE" -vf hflip "$OUTPUT_FILE") ;;
                "Vertical")   COMMAND=(ffmpeg -i "$INPUT_FILE" -vf vflip "$OUTPUT_FILE") ;;
                "Both")       COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "hflip,vflip" "$OUTPUT_FILE") ;;
            esac
            ;;

        "crop")
            echo -n "Enter crop dimensions (width:height:x:y, e.g., 800:600:100:50): "
            read -r CROP_PARAMS
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "crop=$CROP_PARAMS" "$OUTPUT_FILE")
            ;;

        "blur")
            echo -n "Enter blur radius (e.g., 5, 10): "
            read -r BLUR_RADIUS
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "boxblur=$BLUR_RADIUS" "$OUTPUT_FILE")
            ;;

        "sharpen"|"sharpen_video")
            SHARPEN_LEVEL=$(
                printf "Light\nMedium\nStrong\nCustom" \
                | fzf --prompt="Sharpen level: "
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
                    echo -n "Enter sharpening strength (0.0-2.0): "
                    read -r STRENGTH
                    COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "unsharp=5:5:${STRENGTH}:3:3:0.5" "$OUTPUT_FILE")
                    ;;
            esac
            ;;

        "grayscale"|"grayscale_video")
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "format=gray" "$OUTPUT_FILE")
            ;;

        "sepia"|"sepia_video")
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" "$OUTPUT_FILE")
            ;;

        "brightness"|"brightness_contrast")
            echo -n "Enter brightness adjustment (-1.0 to 1.0, 0 is no change): "
            read -r BRIGHTNESS
            if [ "$FILE_TYPE" = "video" ]; then
                echo -n "Enter contrast adjustment (-2.0 to 2.0, 1 is no change): "
                read -r CONTRAST
                COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=brightness=${BRIGHTNESS}:contrast=${CONTRAST}" "$OUTPUT_FILE")
            else
                COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=brightness=${BRIGHTNESS}" "$OUTPUT_FILE")
            fi
            ;;

        "contrast")
            echo -n "Enter contrast adjustment (-2.0 to 2.0, 1 is no change): "
            read -r CONTRAST
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=contrast=${CONTRAST}" "$OUTPUT_FILE")
            ;;

        "gamma")
            echo -n "Enter gamma adjustment (0.1 to 10.0, 1 is no change): "
            read -r GAMMA
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "eq=gamma=${GAMMA}" "$OUTPUT_FILE")
            ;;

        "thumbnail")
            SIZE=$(
                printf "150x150\n200x200\n300x300\nCustom" \
                | fzf --prompt="Thumbnail size: "
            )
            if [ "$SIZE" = "Custom" ]; then
                echo -n "Enter thumbnail size (e.g., 250x250): "
                read -r SIZE
            fi
            COMMAND=(ffmpeg -i "$INPUT_FILE" -vf "scale=$SIZE" "$OUTPUT_FILE")
            ;;

        # AUDIO OPERATIONS
        "compress_audio")
            echo "Select audio quality:"
            QUALITY=$(
                printf "128k\n192k\n256k\n320k\nCustom" \
                | fzf --prompt="Bitrate: "
            )
            if [ "$QUALITY" = "Custom" ]; then
                echo -n "Enter bitrate (e.g., 160k): "
                read -r QUALITY
            fi
            COMMAND=(ffmpeg -i "$INPUT_FILE" -b:a "$QUALITY" "$OUTPUT_FILE")
            ;;

        "change_volume")
            echo -n "Enter volume multiplier (e.g., 0.5 for half, 2.0 for double): "
            read -r VOLUME
            COMMAND=(ffmpeg -i "$INPUT_FILE" -af "volume=${VOLUME}" "$OUTPUT_FILE")
            ;;

        "trim_audio")
            echo -n "Enter start time (e.g., 00:01:30): "
            read -r START_TIME
            echo -n "Enter duration (e.g., 00:02:00): "
            read -r DURATION
            COMMAND=(ffmpeg -i "$INPUT_FILE" -ss "$START_TIME" -t "$DURATION" -c copy "$OUTPUT_FILE")
            ;;

        "get_info")
            print_info "Getting file information..."
            get_file_info "$INPUT_FILE"
            exit 0
            ;;

        *)
            print_error "Unknown operation: $OP_KEY"
            exit 1
            ;;
    esac

    # 5: Confirm and execute
    print_info "5: Confirm execution"
    echo
    print_warning "Command to execute:"
    printf "  %q" "${COMMAND[@]}"
    echo
    print_warning "Input file:  $INPUT_FILE"
    print_warning "Output file: $OUTPUT_FILE"
    print_warning "File type:   $FILE_TYPE"

    # If output file exists, ask whether to overwrite
    if [ -f "$OUTPUT_FILE" ]; then
        print_warning "Output file already exists!"
        echo -n "Overwrite? (y/N): "
        read -r OVERWRITE
        if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled."
            exit 0
        fi
        # Insert -y immediately after 'ffmpeg'
        COMMAND=( "${COMMAND[@]/ffmpeg/ffmpeg -y}" )
    fi

    echo
    echo -n "Execute this command? (Y/n): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
        print_info "Operation cancelled."
        exit 0
    fi

    # Execute the command directly in an if statement to capture success/failure
    print_info "Executing FFmpeg operation..."
    echo
    if "${COMMAND[@]}"; then
        print_success "Operation completed successfully!"
        print_success "Output file: $OUTPUT_FILE"

        # Show basic file info
        if [ -f "$OUTPUT_FILE" ]; then
            print_info "Output file details:"
            ls -lh "$OUTPUT_FILE"
            if command -v file &>/dev/null; then
                file "$OUTPUT_FILE"
            fi
        fi
    else
        print_error "Operation failed!"
        exit 1
    fi
}

main "$@"
