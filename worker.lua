package.path = package.path .. ';./LuaRPT/?.lua'

local wrkch = love.thread.getChannel("worker")
local serpent=require("serpent")
local scn=wrkch:demand()

print(scn)
local scene=loadstring(scn)()
for i,v in pairs(scene) do
	print(i,v)
end