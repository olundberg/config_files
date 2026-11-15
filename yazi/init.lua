-- ~/.config/yazi/init.lua
-- 1. Enable official git.yazi plugin (shows status of files/folders inside a repo)
require("git"):setup {
	order = 1500,
}

-- 2. Enable subrepo-git plugin (shows status + branch of child Git repositories when in a parent folder)
require("subrepo-git"):setup {
	order = 1400,
}

-- 3. Display active Conda environment and current repo's Git branch in the top-right header
local git_cache = {
	cwd = nil,
	branch = "",
	last_check = 0,
}

Header:children_add(function(self)
	-- Conda environment (reads $CONDA_DEFAULT_ENV)
	local conda = os.getenv("CONDA_DEFAULT_ENV")
	local conda_str = (conda and conda ~= "") and ("(" .. conda .. ") ") or ""

	-- Git branch for the current directory in Yazi (cached per directory / 3s TTL)
	local cwd = tostring(self._current.cwd)
	local now = os.time()
	if cwd ~= git_cache.cwd or (now - git_cache.last_check) >= 3 then
		git_cache.cwd = cwd
		git_cache.last_check = now
		git_cache.branch = ""

		local quoted_cwd = "'" .. cwd:gsub("'", "'\\''") .. "'"
		local cmd = "git -C " .. quoted_cwd .. " rev-parse --abbrev-ref HEAD 2>/dev/null"
		local handle = io.popen(cmd)
		if handle then
			local branch = handle:read("*l")
			handle:close()
			if branch and branch ~= "" then
				git_cache.branch = " " .. branch .. " "
			end
		end
	end

	return ui.Line {
		ui.Span(conda_str):fg("yellow"),
		ui.Span(git_cache.branch):fg("magenta"),
	}
end, 500, Header.RIGHT)
