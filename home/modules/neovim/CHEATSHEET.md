# Neovim Keybinding Cheatsheet

Leader key: `Space`

Tip: Press `Space` and wait — Which-key shows all available commands.

## Navigation & Files

| Key | Action |
|-----|--------|
| `Space ff` | Find files (fuzzy) |
| `Space fg` | Find by grep (search in files) |
| `Space fb` | Find open buffers |
| `Space fr` | Find recent files |
| `Space fh` | Find help tags |
| `Space fd` | Find diagnostics |
| `Space fc` | Find colorscheme |
| `Space fk` | Find keymaps |

## File Explorer (Neo-tree)

| Key | Action |
|-----|--------|
| `Space e` | Toggle file explorer |
| `Space o` | Focus file explorer |

## Buffers

| Key | Action |
|-----|--------|
| `Space bn` | Next buffer |
| `Space bp` | Previous buffer |
| `Space bd` | Close buffer |
| `Space w` | Save file |

## Splits & Windows

| Key | Action |
|-----|--------|
| `Space sv` | Split vertical |
| `Space sh` | Split horizontal |
| `Ctrl+h` | Move to left window/tmux pane |
| `Ctrl+j` | Move to bottom window/tmux pane |
| `Ctrl+k` | Move to top window/tmux pane |
| `Ctrl+l` | Move to right window/tmux pane |

## LSP (Code Intelligence)

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Peek definition |
| `gD` | Go to definition |
| `ga` | Code action (quick fix) |
| `gr` | Rename symbol |
| `gf` | Find references |
| `gt` | Code outline (sidebar) |
| `ge` | Toggle diagnostics panel |
| `[e` | Previous diagnostic |
| `]e` | Next diagnostic |
| `Space li` | LSP info |
| `Space lf` | Format buffer |
| `Space lr` | Rename |
| `Space la` | Code action |

## Git

| Key | Action |
|-----|--------|
| `Space gg` | Open Neogit (git interface) |
| `Space gd` | Open diff view |
| `Space gh` | File history |
| `Space gq` | Close diff view |
| `]h` | Next git hunk |
| `[h` | Previous git hunk |
| `Space hs` | Stage hunk |
| `Space hr` | Reset hunk |
| `Space hp` | Preview hunk |
| `Space tb` | Toggle line blame |

## Terminal

| Key | Action |
|-----|--------|
| `Ctrl+\` | Toggle terminal (quick) |
| `Space tt` | Toggle terminal (bottom) |
| `Space tv` | Toggle terminal (right) |
| `Space tf` | Toggle terminal (float) |
| `Esc` | Exit terminal mode |
| `Ctrl+h/j/k/l` | Navigate out of terminal |

## Claude Code (AI)

| Key | Action |
|-----|--------|
| `Space cc` | Toggle Claude Code |
| `Space cC` | Continue conversation |
| `Space cr` | Resume conversation |

## Treesitter Text Objects

| Key | Action |
|-----|--------|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside argument |
| `]f` | Next function start |
| `[f` | Previous function start |
| `]c` | Next class start |
| `[c` | Previous class start |
| `Ctrl+Space` | Start/expand selection |
| `Backspace` | Shrink selection |

## Completion (in Insert mode)

| Key | Action |
|-----|--------|
| `Tab` | Next suggestion |
| `Shift+Tab` | Previous suggestion |
| `Enter` | Accept suggestion |
| `Ctrl+Space` | Trigger completion |
| `Ctrl+e` | Close completion |
| `Ctrl+f` | Scroll docs down |
| `Ctrl+b` | Scroll docs up |

## General

| Key | Action |
|-----|--------|
| `Space nh` | Clear search highlight |
| `Space` + wait | Show all keybindings (Which-key) |

## VS Code Equivalents

| VS Code | Neovim |
|---------|--------|
| `Cmd+P` | `Space ff` |
| `Cmd+Shift+F` | `Space fg` |
| `Cmd+B` | `Space e` |
| `Cmd+S` | `Space w` |
| `F12` | `gD` |
| `Alt+F12` | `gd` |
| `F2` | `gr` |
| `Cmd+.` | `ga` |
| `Cmd+Shift+M` | `ge` |
| `Ctrl+`` ` | `Ctrl+\` or `Space tt` |
| `Cmd+Shift+G` | `Space gg` |
| Copilot | `Space cc` (Claude Code) |

## LSP Servers Configured

| Language | Server |
|----------|--------|
| TypeScript/JavaScript | typescript-tools + biome |
| Python | pyright |
| Nix | nixd |
| JSON | jsonls (with schemas) |
| YAML | yamlls |
| Bash/Shell | bashls |
| Dockerfile | dockerls |
| Lua | lua_ls |

Format on save is enabled via Biome (TS/JS/JSON), ruff (Python), nixfmt (Nix).
