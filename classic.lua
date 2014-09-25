local catchStack = {
	n = 0,
	push = function(self, item)
		self.n = self.n + 1
		self[self.n] = item
	end,
	pop = funciton(self)
		local n = self.n
		local item = self[n]
		self[n] = nil
		self.n = n - 1
		return item
	end
}

local function try(func, ...)
	local returns = {pcall(func, ...)}
	if returns[1] then
		return select(2, table.unpack(returns))
	else
		catchStack:push({func = func, msg = returns[2], ...})
	end
end

local function catch(func)
	pcall(func, catchStack:pop())
end

local function safecall(func, ...)
	return select(2, pcall(func, ...))
end

-------------------------------------------------------------------------------
--	Get a sleep function...
-------------------------------------------------------------------------------
local sleep
local loaded, lib = pcall(require, "posix")
if loaded then
	sleep = lib.sleep
else
	loaded, lib = pcall(require, "socket")
	if loaded then
		sleep = function (sec)
			lib.select(nil, nil, sec)
		end
	else
		loaded, lib = pcall(require, "apr")
		if loaded then
			sleep = lib.sleep
		else
			loaded, lib = pcall(require, "ffi")
			if loaded then
				lib.cdef "unsigned int sleep(unsigned int seconds);"
				sleep = lib.C.sleep
			elseif string.sub(package.config, 1, 1) == "\\" or os.getenv("WINDIR") then
				if tonumber(io.popen("ver", "r"):read("*a"):match("%d%.%d")) > 5.0 then
					sleep = function (sec)
						os.execute("timeout " .. sec .. " /nobreak > NUL")
					end
				else
					local f = assert(io.open("sleep.vbs","w"))
					f:write("WScript.Sleep(WScript.Arguments(0))\n")
					f:close()
					sleep = function (sec)
						os.execute("sleep.vbs " .. sec * 1000)
					end
				end
			else
				sleep = function (sec)
					os.execute("sleep " .. sec)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
--	Begin program
-------------------------------------------------------------------------------

io.write "Made by HawkBlade\n"

sleep(3)

io.write "Would you like to open a game?\n"

if string.lower(io.read "*a") == "yes" then
	local f = io.open("a.txt", "r")
	money, fields, soldiers, catapults, grass, wheat, barley, season, seasonchance = safecall(load("return " .. f:read "*a"))
end
