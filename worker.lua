package.path = package.path .. ';./LuaRPT/?.lua'

local serpent=require("serpent")
local pm=require("primitives")
local rt=require("raytracer")
local os = require("os")

require("love.thread")

local receivechn = love.thread.newChannel()
local sendchn = nil
local scene = {}
local section = {}
local result={}
local use_path_tracing=0
local path_tracing_samples=10
local rtracer={}

function sendresult()
	sendchn:supply(serpent.dump({result=true,section=section,data=result}))
end

function dowork()
	result={}
	rtracer.image=result
	rtracer.resolution=section.resolution
	--local tm=os.clock()
	rtracer:render(section,section.use_path_tracing,section.path_tracing_samples)
	--print("done section in "..os.clock() - tm.."s")
	section.done=true
	sendresult()
	--get next
	sendchn:push(serpent.dump({getwork=true}))
end

function register()
	local managerchn = love.thread.getChannel("managerchn")
	managerchn:push(receivechn)
end

function getscene()
	sendchn:supply(serpent.dump({getscene=true}))
	local m = receivechn:demand()
	if m then
		scene = pm.Scene:new(loadstring(m)())
	end
end

function getwork()
	while true do
		local m=receivechn:pop()
		if m then
			if type(m) == "string" then
				local msg = loadstring(m)()
				if msg.section then

					section = msg
					section.done=false

					if msg.sceneid ~= scene.id then
						sendchn:push(serpent.dump({getscene=true}))
					else
						dowork()
					end
				elseif msg.close then
					sendchn:clear()
					return
				elseif msg.scene then
					scene = pm.Scene:new(msg.scene)
					rtracer = rt.Raytracer:new{scene=scene}
					if section.done==false then
						dowork()
					end
				end
			elseif tostring(m)=="Channel" then
				sendchn = m
				--ask for first job
				sendchn:push(serpent.dump({getwork=true}))
			end
		end
	end
end

register()

getwork()
