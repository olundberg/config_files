#!/usr/bin/env bash
set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/olundberg/config_files/master"
YAZI_CONFIG_DIR="$HOME/.config/yazi"
NVIM_INIT="$HOME/.config/nvim/init.vim"

# Determine if running from a local clone or piped via `curl | bash`
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

echo "==> [1/4] Checking / Installing Yazi..."
if ! command -v yazi >/dev/null 2>&1; then
    if command -v snap >/dev/null 2>&1; then
        echo "Installing yazi via snap..."
        sudo snap install yazi --classic
    else
        echo "Error: 'snap' not found and 'yazi' is not installed."
        echo "Please install yazi from https://github.com/sxyazi/yazi/releases and re-run."
        exit 1
    fi
else
    echo "Yazi is already installed: $(command -v yazi)"
fi

echo "==> [2/4] Installing Yazi configuration files to $YAZI_CONFIG_DIR..."
mkdir -p "$YAZI_CONFIG_DIR/plugins/subrepo-git.yazi"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/init.lua" ]; then
    echo "Copying config files from local directory ($SCRIPT_DIR)..."
    cp -f "$SCRIPT_DIR/init.lua" "$YAZI_CONFIG_DIR/init.lua"
    cp -f "$SCRIPT_DIR/yazi.toml" "$YAZI_CONFIG_DIR/yazi.toml"
    cp -f "$SCRIPT_DIR/keymap.toml" "$YAZI_CONFIG_DIR/keymap.toml"
    cp -f "$SCRIPT_DIR/package.toml" "$YAZI_CONFIG_DIR/package.toml"
    cp -f "$SCRIPT_DIR/plugins/subrepo-git.yazi/main.lua" "$YAZI_CONFIG_DIR/plugins/subrepo-git.yazi/main.lua"
else
    echo "Downloading config files from GitHub ($RAW_BASE/yazi)..."
    curl -fsSL "$RAW_BASE/yazi/init.lua" -o "$YAZI_CONFIG_DIR/init.lua"
    curl -fsSL "$RAW_BASE/yazi/yazi.toml" -o "$YAZI_CONFIG_DIR/yazi.toml"
    curl -fsSL "$RAW_BASE/yazi/keymap.toml" -o "$YAZI_CONFIG_DIR/keymap.toml"
    curl -fsSL "$RAW_BASE/yazi/package.toml" -o "$YAZI_CONFIG_DIR/package.toml"
    curl -fsSL "$RAW_BASE/yazi/plugins/subrepo-git.yazi/main.lua" -o "$YAZI_CONFIG_DIR/plugins/subrepo-git.yazi/main.lua"
fi

echo "==> [3/4] Installing Yazi external plugins (git.yazi)..."
YA_BIN="$(command -v ya || echo /snap/bin/ya)"
if [ -x "$YA_BIN" ]; then
    "$YA_BIN" pkg install || "$YA_BIN" pkg add yazi-rs/plugins:git || true
else
    echo "Warning: 'ya' binary not found in PATH; skipping plugin install."
fi

echo "==> [4/4] Configuring Neovim ($NVIM_INIT) to use Yazi..."
mkdir -p "$(dirname "$NVIM_INIT")"

# Ensure vim-plug is installed so plug#begin() and :PlugInstall work on a new machine
PLUG_VIM="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
if [ ! -f "$PLUG_VIM" ]; then
    echo "Installing vim-plug to $PLUG_VIM..."
    mkdir -p "$(dirname "$PLUG_VIM")"
    curl -fsSL "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -o "$PLUG_VIM"
fi

if [ ! -f "$NVIM_INIT" ]; then
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../neovim/init.vim" ]; then
        cp "$SCRIPT_DIR/../neovim/init.vim" "$NVIM_INIT"
    else
        curl -fsSL "$RAW_BASE/neovim/init.vim" -o "$NVIM_INIT" || touch "$NVIM_INIT"
    fi
fi

if [ -f "$NVIM_INIT" ]; then
    # Fix invalid '# Ranger in Vim' comment if present from older neovim/init.vim
    if grep -q "Plug 'kevinhwang91/rnvimr'.*#" "$NVIM_INIT"; then
        sed -i "s/\(Plug 'kevinhwang91\/rnvimr'.*\)#/\1\"/" "$NVIM_INIT"
    fi

    # 1. Add plenary.nvim and yazi.nvim inside plug#begin() .. plug#end() if not already present
    if ! grep -q "mikavilpas/yazi.nvim" "$NVIM_INIT"; then
        if grep -q "call plug#end()" "$NVIM_INIT"; then
            if ! grep -q "nvim-lua/plenary.nvim" "$NVIM_INIT"; then
                sed -i "/call plug#end()/i Plug 'nvim-lua/plenary.nvim'" "$NVIM_INIT"
            fi
            sed -i "/call plug#end()/i Plug 'mikavilpas/yazi.nvim'" "$NVIM_INIT"
            echo "Added plenary.nvim and yazi.nvim to plug#begin() in $NVIM_INIT"
        else
            echo "Warning: 'call plug#end()' not found in $NVIM_INIT. Please add Plug 'mikavilpas/yazi.nvim' manually."
        fi
    elif ! grep -q "nvim-lua/plenary.nvim" "$NVIM_INIT"; then
        sed -i "/mikavilpas\/yazi.nvim/i Plug 'nvim-lua/plenary.nvim'" "$NVIM_INIT"
        echo "Added missing dependency plenary.nvim to $NVIM_INIT"
    fi

    # 2. Append Yazi configuration block if not already present
    if ! grep -q "Yazi integration (yazi.nvim)" "$NVIM_INIT"; then
        cat >> "$NVIM_INIT" << 'EOF'

" Yazi integration (yazi.nvim)
let g:NERDTreeHijackNetrw = 0
let g:loaded_netrwPlugin = 1
command! -nargs=? -complete=dir Explore Yazi
command! -nargs=? -complete=dir Ex Yazi
cnoreabbrev <expr> explore (getcmdtype() == ':' && getcmdline() ==# 'explore') ? 'Yazi' : 'explore'
cnoreabbrev <expr> ex (getcmdtype() == ':' && getcmdline() ==# 'ex') ? 'Yazi' : 'ex'
nnoremap <silent> <Leader>- :Yazi<CR>
nnoremap <silent> <Leader>n :Yazi<CR>
nnoremap <silent> <Leader>cw :Yazi cwd<CR>
nnoremap <silent> <M-f> :Yazi toggle<CR>

lua << LUA_EOF
local ok, yazi = pcall(require, "yazi")
if ok then
  yazi.setup({
    open_for_directories = true,
  })
end
LUA_EOF
EOF
        echo "Added Yazi keybindings and Lua setup to $NVIM_INIT"
    fi

    # 3. Install Neovim plugins headlessly via vim-plug
    if command -v nvim >/dev/null 2>&1; then
        echo "Running :PlugInstall --sync in Neovim..."
        if ! nvim --headless +'PlugInstall --sync' +qa; then
            echo "Warning: Headless :PlugInstall encountered an issue. You can run :PlugInstall inside nvim manually."
        fi
    else
        echo "Warning: 'nvim' is not installed or not in PATH; skipping :PlugInstall."
        echo "Once Neovim is installed, open 'nvim' and run :PlugInstall."
    fi
fi

echo "==> Done! Yazi and Neovim integration are installed and ready."
