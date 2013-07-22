package.path = package.path .. ';./LuaRPT/?.lua'

local serpent=require("serpent")
local pm=require("primitives")
local rt=require("raytracer")
local os = require("os")

local chn = love.thread.newChannel()
local scene = {}
local section = {}
local result={}
local use_path_tracing=0
local path_tracing_samples=10
local rtracer={}
--[[

local wrkch = love.thread.getChannel("worker")
local scn=wrkch:demand()

local scene=loadstring(scn)()
scene=pm.Scene:new(scene)



]]

function sendresult()
	chn:supply(serpent.dump({result=true,section=section,data=result}))
end

function dowork()
	result={}
	rtracer.image=result
	rtracer.resolution=section.resolution
	--local tm=os.clock()
	rtracer:render(section,section.use_path_tracing,section.path_tracing_samples)
	--print("done section in "..os.clock() - tm.."s")
	sendresult()
end

function register()
	local regch = love.thread.getChannel("register")
	regch:push(chn)
end

function getscene()
	chn:supply(serpent.dump({getscene=true}))
	local m = chn:demand()
	if m then
		scene = pm.Scene:new(loadstring(m)())
		rtracer = rt.Raytracer:new{scene=scene}
	end
end

function getwork()
	chn:supply(serpent.dump({getwork=true}))
	local m=chn:demand()
	if m then
		section = loadstring(m)()
		if section.sceneid ~= scene.id then
			getscene()
		end
		dowork()
	end
end

register()

while true do
	getwork()
end