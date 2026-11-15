--- @since 26.8.15
-- Async fetcher plugin for Yazi that displays Git branch and dirty/clean/ahead/behind status
-- next to subdirectories that are Git repositories (when viewing a parent directory of multiple repos).

local function is_git_repo(dir_url)
	local git_url = dir_url:join(".git")
	local stat = fs.cha(git_url)
	if not stat then
		return false
	end
	if stat.is_dir then
		return true
	end
	local file = io.open(tostring(git_url))
	if file then
		local head = file:read(8)
		file:close()
		return head == "gitdir: "
	end
	return false
end

local update_state = ya.sync(function(st, results)
	st.repos = st.repos or {}
	for path, info in pairs(results) do
		st.repos[path] = info == false and nil or info
	end
	ui.render()
end)

local function setup(st, opts)
	st.repos = {}
	opts = opts or {}
	opts.order = opts.order or 1400

	Linemode:children_add(function(self)
		if not self._file.in_current or not self._file.cha.is_dir then
			return ""
		end

		local info = st.repos[tostring(self._file.url)]
		if not info then
			return ""
		end

		if self._file.is_hovered then
			local parts = { " " }
			if info.sign ~= "" then
				parts[#parts + 1] = info.sign .. " "
			end
			if info.sync ~= "" then
				parts[#parts + 1] = info.sync .. " "
			end
			if info.branch ~= "" then
				parts[#parts + 1] = info.branch
			end
			return ui.Line(parts)
		end

		local spans = { ui.Span(" ") }
		if info.sign ~= "" then
			spans[#spans + 1] = ui.Span(info.sign .. " "):fg(info.color)
		end
		if info.sync ~= "" then
			spans[#spans + 1] = ui.Span(info.sync .. " "):fg("cyan")
		end
		if info.branch ~= "" then
			spans[#spans + 1] = ui.Span(info.branch):fg("magenta")
		end
		return ui.Line(spans)
	end, opts.order)
end

local function parse_porcelain_v2(stdout)
	local branch = ""
	local sync = ""
	local staged, unstaged, untracked, conflict = false, false, false, false

	for line in stdout:gmatch("[^\r\n]+") do
		if line:sub(1, 14) == "# branch.head " then
			branch = line:sub(15)
			if branch == "(detached)" then
				branch = "detached"
			end
		elseif line:sub(1, 12) == "# branch.ab " then
			local ahead, behind = line:match("^# branch%.ab %+(%d+) %-(%d+)")
			local s = ""
			if ahead and tonumber(ahead) > 0 then
				s = s .. "↑" .. ahead
			end
			if behind and tonumber(behind) > 0 then
				s = s .. "↓" .. behind
			end
			sync = s
		elseif line:sub(1, 2) == "? " then
			untracked = true
		elseif line:sub(1, 2) == "u " then
			conflict = true
		elseif line:sub(1, 2) == "1 " or line:sub(1, 2) == "2 " then
			local xy = line:sub(3, 4)
			local x, y = xy:sub(1, 1), xy:sub(2, 2)
			if x ~= "." then
				staged = true
			end
			if y ~= "." then
				unstaged = true
			end
		end
	end

	local sign = "✓"
	local color = "green"
	if conflict then
		sign = "!"
		color = "red"
	elseif staged or unstaged or untracked then
		local flags = ""
		if staged then
			flags = flags .. "+"
		end
		if unstaged then
			flags = flags .. "*"
		end
		if untracked then
			flags = flags .. "?"
		end
		sign = flags
		color = ( unstaged or untracked ) and "yellow" or "green"
	end

	return {
		branch = branch,
		sync = sync,
		sign = sign,
		color = color,
	}
end

local function fetch(_, job)
	local results = {}
	local has_any = false

	for _, file in ipairs(job.files) do
		if file.cha.is_dir and is_git_repo(file.url) then
			local path = tostring(file.url)
			local output = Command("git")
				:cwd(path)
				:arg({ "--no-optional-locks", "status", "--porcelain=v2", "--branch", "-unormal" })
				:output()
			if output and output.status.success then
				results[path] = parse_porcelain_v2(output.stdout)
				has_any = true
			end
		elseif file.cha.is_dir then
			results[tostring(file.url)] = false
		end
	end

	if has_any or next(results) ~= nil then
		update_state(results)
	end

	return ya.co(function()
		for _, file in ipairs(job.files) do
			coroutine.yield(file, { retry = true })
		end
	end)
end

return { setup = setup, fetch = fetch }
