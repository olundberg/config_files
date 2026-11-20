# Repository Guidelines (`config_files`)

This repository contains personal dotfiles, tool configurations (`yazi`, `neovim`, `tmux`, etc.), and bootstrap/installation scripts intended to work reliably on fresh Linux machines (both from a local clone and via `curl | bash`).

## Portable Install Scripts (`install.sh`)
- **Do not assume dependencies are pre-installed** on a target machine:
  - When configuring Neovim plugins with `vim-plug`, always ensure `${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim` exists (downloading it via `curl` if missing) before running `:PlugInstall`.
  - Check each required plugin and dependency (e.g., `nvim-lua/plenary.nvim` alongside `mikavilpas/yazi.nvim`) independently when patching `init.vim`.
- **Headless Neovim plugin installation**:
  - Always use `nvim --headless +'PlugInstall --sync' +qa` so async plugin downloads finish before Neovim exits.
  - Never swallow errors with `>/dev/null 2>&1 || true` on plugin or package installation commands; surface warnings clearly if a step fails.

## Neovim / Vimscript Configurations (`neovim/init.vim`, `vimrc`)
- Use `"` for comments in Vimscript (never `#`, which causes syntax errors on commands like `Plug '...'`).
- After editing `init.vim` or `install.sh`, verify syntax with `bash -n <script>` and `nvim -u <init.vim> --headless +qa`.
