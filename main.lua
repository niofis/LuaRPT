
local pm=require("primitives")
local serpent=require("serpent")
local os = require("os")
local demo=require("demo")

local time = 0
local manager = nil
local mngch = nil
local errorCh = nil
local wndwidth = 0
local wndheight = 0
local scalex=1.5
local scaley=1.5
local renderres={width=800,height=600}
local imageData = love.image.newImageData( renderres.width, renderres.height )
local job={}

local tm=0

function dumpObj(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function sendjob()

	local job = {}

	job.scene = demo.load()
	job.scene.id=tostring(job.scene):sub(-7)
	job.resolution = renderres
	job.use_path_tracing = 0
	path_tracing_samples = 1000
	job.numworkers=4
	local mul=10
	job.sectionwidth=mul --math.ceil(job.resolution.height/(job.numworkers*mul))
	job.sectionheight=mul--math.ceil(job.resolution.height/(job.numworkers*mul))

	mngch:supply(serpent.dump({job=job}))

	mngch:supply(serpent.dump({start=true}))
	tm = os.clock()
end

function love.load()
	wndwidth = love.window.getWidth()
	wndheight = love.window.getHeight()

	manager = love.thread.newThread("manager.lua","manager")
	mngch = love.thread.getChannel("manager")
	--errorCh = love.thread.getChannel("error")
	manager:start()

	sendjob()
end

function love.update(dt)
	time=dt
	scalex=wndwidth/renderres.width
	scaley=wndheight/renderres.height
	local s = mngch:pop()
	if s then
		local m = loadstring(s)()
		if m.result then
			for y,v in pairs(m.data) do
				for x,w in pairs(v) do
					local c = pm.ColorF.to255(w)
					if x<renderres.width and y<renderres.height then
						imageData:setPixel(x,y,c.r,c.g,c.b,255)
					end
					--[[
					if w.b ~= 0 then 
						print(s)
						debug.debug() 
					end
					]]
				end
			end
		elseif m.done then
			print("Done in: " .. (os.clock() - tm) )
		end
	end
	
	local err=manager:getError();
	if err then
		print(err)
		debug.debug()
		love.event.push("quit")
	end
end

function love.draw()
	local image = love.graphics.newImage( imageData )
	love.graphics.draw(image,0,0,0,scalex,scaley)
	love.graphics.setColor(255,255,255)
	love.graphics.print("time: " .. time , 10,10)
	--love.graphics.point(400,300)
end

function love.keypressed(key, unicode)
	if key=="escape" then
		love.event.push("quit")
	end
end

