# Yazi Configuration

Custom configuration, plugins, and Neovim integration for [Yazi](https://github.com/sxyazi/yazi) (terminal file manager written in Rust).

## Quick Install (One-Liner, No Clone Needed)

On any new computer, run this single command to install Yazi, download all custom configs/plugins from GitHub, and configure Neovim to use Yazi as its file explorer:

```bash
curl -fsSL https://raw.githubusercontent.com/olundberg/config_files/master/yazi/install.sh | bash
```

*(Or if you already cloned the repo locally: `bash ~/orepos/config_files/yazi/install.sh`)*

### What [`install.sh`](./install.sh) does automatically:
1. Installs `yazi` via `snap` if not already installed.
2. Downloads (or copies locally) `init.lua`, `yazi.toml`, `keymap.toml`, `package.toml`, and `plugins/subrepo-git.yazi/main.lua` into `~/.config/yazi/`.
3. Installs external Yazi plugins (`yazi-rs/plugins:git`) via `ya pkg install`.
4. Updates `~/.config/nvim/init.vim` with `plenary.nvim` + `mikavilpas/yazi.nvim`, configures `:Explore`, `:explore`, `:Ex`, `:ex`, `<Leader>n`, `<Leader>-`, `<Leader>cw`, and `<M-f>` to open Yazi, and runs `:PlugInstall` headlessly.

---

## Features Included

1. **Top-Right Header (`init.lua`):**
   - Displays the active **Conda environment** (`$CONDA_DEFAULT_ENV`) in yellow.
   - Displays the current directory's **Git branch** (` <branch>`) in magenta (cached with a 3s TTL to avoid CPU overhead).
2. **In-Repo Git Status (`git.yazi` plugin):**
   - Shows modified (`M`), added (`A`), untracked (`?`), and deleted (`D`) indicators next to files and directories inside a Git repository.
3. **Multi-Repo Parent Directory Overview (`plugins/subrepo-git.yazi/main.lua`):**
   - When viewing a parent folder containing multiple Git repositories (e.g. `~/orepos`), asynchronously inspects each child repository and displays its status and active branch right next to the folder name:
     - `✓` (Green): Clean working tree
     - `+` / `*` / `?` (Yellow/Green): Staged (`+`), modified unstaged (`*`), or untracked (`?`) changes
     - `!` (Red): Merge conflicts
     - `↑N` / `↓N` (Cyan): Commits ahead/behind remote
     - `<branch>` (Magenta): Current branch name of the child repository
4. **Custom Keymaps & Layout (`keymap.toml` & `yazi.toml`):**
   - Miller column ratios set to `[ 2, 3, 6 ]`.
   - Directory bookmarks: `gr` (`~/repos`) and `go` (`~/orepos`).
5. **Neovim Integration (`yazi.nvim`):**
   - Replaces `netrw` when opening directories (`nvim .`) and maps `:Explore` / `:explore` / `:Ex` / `:ex`, `<Leader>n`, `<Leader>-`, `<Leader>cw`, and `<M-f>` to Yazi.

---

## Manual Installation Steps

If you prefer to run the steps manually instead of using `install.sh`:

### 1. Install Yazi
```bash
sudo snap install yazi --classic
```

### 2. Copy Configuration Files
```bash
mkdir -p ~/.config/yazi/plugins
cp -r init.lua yazi.toml keymap.toml package.toml ~/.config/yazi/
cp -r plugins/subrepo-git.yazi ~/.config/yazi/plugins/
```

### 3. Install External Yazi Plugins (`git.yazi`)
```bash
ya pkg install
```

### 4. Set Neovim as Default Editor (Optional)
Ensure this is in your `~/.bashrc`:
```bash
export EDITOR=nvim
export VISUAL=nvim
```
