package.path = package.path .. ';./LuaRPT/?.lua'

local wrkch = love.thread.getChannel("worker")

local scn=worker:demand()

print(scn)
for i,v in pairs(scn) do
	print(i,v)
end