<p align="center">
  <a href="https://adimail.github.io/">
    <picture>
      <img src="assets\favicon.ico" height="100">
    </picture>
    <h1 align="center">adimail config files</h1>
  </a>
</p>

## Keybindings

### LSP

| **Keybinding** | **Description**                                                             |
| -------------- | --------------------------------------------------------------------------- |
| `gD`           | Jump to the declaration of the symbol under the cursor.                     |
| `gd`           | Go to the definition of the symbol under the cursor.                        |
| `gi`           | Show all implementations of the symbol under the cursor.                    |
| `<leader>D`    | Go to the type definition of the symbol under the cursor.                   |
| `<leader>wa`   | Add a workspace folder to the LSP client.                                   |
| `<leader>wr`   | Remove a workspace folder from the LSP client.                              |
| `<leader>wl`   | List all workspace folders currently known to the LSP client.               |
| `<leader>e`    | Show diagnostic information in a floating window.                           |
| `[d`           | Jump to the previous diagnostic message.                                    |
| `]d`           | Jump to the next diagnostic message.                                        |
| `<leader>q`    | Set the list of diagnostics to the location list.                           |
| `<leader>ld`   | Same as `<leader>q`, set diagnostics to the location list.                  |
| `<leader>qd`   | Set diagnostics to the quickfix list.                                       |
| `<leader>so`   | Open Telescope for LSP document symbols search.                             |
| `<leader>sd`   | Open Telescope to search and view diagnostics.                              |
| `K`            | Show hover documentation for the symbol under the cursor.                   |
| `gf`           | Open LSP symbol finder for the current document.                            |
| `<leader>gf`   | Open LSP symbol finder with implementation details.                         |
| `gx`           | Trigger a code action for the symbol under the cursor.                      |
| `<leader>ca`   | Trigger a code action for the symbol under the cursor (with a description). |

### Telescope

| **Keybinding** | **Description**                                         |
| -------------- | ------------------------------------------------------- |
| `<leader>ff`   | Find Files                                              |
| `<leader>fg`   | Live grep file content                                  |
| `<leader>ob`   | Search opened buffers                                   |
| `<leader>O`    | Search opened buffers                                   |
| `<leader>fh`   | Search help manual page                                 |
| `<leader>td`   | Toggle Todo Telescope                                   |
| `<leader>jl`   | Toggle Telescope jumplist                               |
| `<leader>fw`   | Grep strings below the cursor                           |
| `<leader>so`   | Search document symbols with LSP                        |
| `<leader>sd`   | Search diagnostics with Telescope                       |
| `<leader>ht`   | Search harpoon marks                                    |
| `<leader>cf`   | Fuzzy search in the current buffer without line numbers |
