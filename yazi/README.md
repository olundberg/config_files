# Yazi Configuration

Custom configuration and plugins for [Yazi](https://github.com/sxyazi/yazi) (terminal file manager written in Rust).

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

---

## Installation on a New Machine

### 1. Install Yazi

On Ubuntu / Linux (via Snap):
```bash
sudo snap install yazi --classic
```
*(Alternatively, download the `x86_64-unknown-linux-gnu` binary (`yazi` and `ya`) from [Yazi Releases](https://github.com/sxyazi/yazi/releases) into `~/.local/bin`.)*

### 2. Copy Configuration Files

Copy the files from this folder to `~/.config/yazi/`:

```bash
mkdir -p ~/.config/yazi/plugins
cp -r init.lua yazi.toml keymap.toml package.toml ~/.config/yazi/
cp -r plugins/subrepo-git.yazi ~/.config/yazi/plugins/
```

### 3. Install External Yazi Plugins (`git.yazi`)

Install the official `git.yazi` plugin defined in `package.toml` using Yazi's package manager (`ya`):

```bash
ya pkg install
# Or explicitly:
# ya pkg add yazi-rs/plugins:git
```

### 4. Set Neovim as Default Editor (Optional)

Yazi uses `$EDITOR` when opening text and JSON files. Ensure this is in your `~/.bashrc`:

```bash
export EDITOR=nvim
export VISUAL=nvim
```
