-----------------------------------------------------------------------------------------
--	Get a sleep function...
-----------------------------------------------------------------------------------------
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
		loaded, lib = pcall(require, "ffi")
		if loaded then
			lib.cdef "unsigned int sleep(unsigned int seconds);"
			sleep = lib.C.sleep
		else
			loaded, lib = pcall(require, "apr")
			if loaded then
				sleep = lib.sleep
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

-----------------------------------------------------------------------------------------
--	Begin program
-----------------------------------------------------------------------------------------

io.write "Made by HawkBlade\n"

sleep(3)

io.write "Would you like to open a game?\n"
