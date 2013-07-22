
local pm=require("primitives")
local serpent=require("serpent")
local os = require("os")
local demo=require("demo")
local string=require("string")

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

local GUI = {}

function dumpObj(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function sendJob()

	local job = {}

	job.scene = demo.load()
	job.scene.id=tostring(job.scene):sub(-7)
	job.resolution = renderres
	job.use_path_tracing = GUI.GetUsePathTracing()
	
	job.path_tracing_samples = GUI.GetPathTracingSamples()
	
	job.numworkers=GUI.GetWorkersNumber()
	local ss=GUI.GetSectorSize()
	job.sectionwidth=ss --math.ceil(job.resolution.height/(job.numworkers*ss))
	job.sectionheight=ss--math.ceil(job.resolution.height/(job.numworkers*ss))

	mngch:supply(serpent.dump({job=job}))

	mngch:supply(serpent.dump({start=true}))
	tm = os.clock()
end

function createGUI()
	local font = loveframes.basicfontsmall

	--Main menu
	local mainframe = loveframes.Create("frame")
	mainframe:SetName("Render Options")
	mainframe:SetSize(200, love.graphics.getHeight() - 325)
	mainframe:SetPos(0, 0)
	mainframe:SetState("idle")
	mainframe:ShowCloseButton(false)
	mainframe:Center()

	GUI.mainframe=mainframe

	local optionslist = loveframes.Create("list", mainframe)
	optionslist:SetSize(200, optionslist:GetParent():GetHeight() - 25)
	optionslist:SetPos(0, 25)
	optionslist:SetPadding(5)
	optionslist:SetSpacing(5)
	optionslist:SetDisplayType("vertical")

	local workerlbl = loveframes.Create("text")
	workerlbl:SetText("Workers Number:")
	workerlbl:SetFont(font)
	optionslist:AddItem(workerlbl)


	local workersnumtxt = loveframes.Create("textinput")
	workersnumtxt:SetText("8")
	workersnumtxt:SetFont(font)
	workersnumtxt.OnTextChanged = function(object, text)
	    if tonumber(text) == nil then
	    	object:SetText(object:GetText():gsub("[^0-9]*",""))
	    end
	end
	optionslist:AddItem(workersnumtxt)
	mainframe.workersnumtxt=workersnumtxt

	GUI.GetWorkersNumber = function () return tonumber(GUI.mainframe.workersnumtxt:GetText()) or 1 end

	local sectorlbl = loveframes.Create("text")
	sectorlbl:SetText("Sector size (pixels):")
	sectorlbl:SetFont(font)
	optionslist:AddItem(sectorlbl)

	local sectorsizetxt = loveframes.Create("textinput")
	sectorsizetxt:SetText("10")
	sectorsizetxt:SetFont(font)
	sectorsizetxt.OnTextChanged = function(object, text)
	    if tonumber(text) == nil then
	    	object:SetText(object:GetText():gsub("[^0-9]*",""))
	    end
	end
	optionslist:AddItem(sectorsizetxt)
	mainframe.sectorsizetxt=sectorsizetxt

	GUI.GetSectorSize = function () return tonumber(GUI.mainframe.sectorsizetxt:GetText()) or 10 end

	local useptlbl = loveframes.Create("text")
	useptlbl:SetText("Use path tracing:")
	useptlbl:SetFont(font)
	optionslist:AddItem(useptlbl)
	local pathtracingchk = loveframes.Create("checkbox")
	optionslist:AddItem(pathtracingchk)
	mainframe.pathtracingchk=pathtracingchk
	GUI.GetUsePathTracing = function () return GUI.mainframe.pathtracingchk:GetChecked() and 1 or 0 end

	local ptsampleslbl = loveframes.Create("text")
	ptsampleslbl:SetText("Path tracing samples:")
	ptsampleslbl:SetFont(font)
	optionslist:AddItem(ptsampleslbl)
	local ptsamplestxt = loveframes.Create("textinput")
	ptsamplestxt:SetText("10")
	ptsamplestxt:SetFont(font)
	ptsamplestxt.OnTextChanged = function(object, text)
	    if tonumber(text) == nil then
	    	object:SetText(object:GetText():gsub("[^0-9]*",""))
	    end
	end
	optionslist:AddItem(ptsamplestxt)
	mainframe.ptsamplestxt=ptsamplestxt
	GUI.GetPathTracingSamples = function () return tonumber(GUI.mainframe.ptsamplestxt:GetText()) or 10 end

	local startbutton = loveframes.Create("button")
	startbutton:SetText("Start")
	startbutton.OnClick = function(object)
	    sendJob()
	    GUI.infoframe:SetPos(GUI.mainframe:GetPos())
	    loveframes.SetState("running")
	end
	optionslist:AddItem(startbutton)




	--Information frame
	local infoframe = loveframes.Create("frame")
	infoframe:SetName("Render Info")
	infoframe:SetSize(200, love.graphics.getHeight() - 325)
	infoframe:SetPos(0, 0)
	infoframe:SetState("running")
	infoframe:ShowCloseButton(false)

	GUI.infoframe=infoframe

	local infolist = loveframes.Create("list", infoframe)
	infolist:SetSize(200, infolist:GetParent():GetHeight() - 25)
	infolist:SetPos(0, 25)
	infolist:SetPadding(5)
	infolist:SetSpacing(5)
	infolist:SetDisplayType("vertical")

	local stopbutton = loveframes.Create("button")
	stopbutton:SetText("Stop")
	stopbutton.OnClick = function(object)
		GUI.mainframe:SetPos(infoframe:GetPos())
	    loveframes.SetState("idle")
	end
	infolist:AddItem(stopbutton)


	loveframes.SetState("idle")
end

function love.load()
	require("libraries.loveframes")

	wndwidth = love.window.getWidth()
	wndheight = love.window.getHeight()

	manager = love.thread.newThread("manager.lua","manager")
	mngch = love.thread.getChannel("manager")
	--errorCh = love.thread.getChannel("error")
	manager:start()

	--sendjob()

	createGUI()
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

	-- update love frames
	loveframes.update(dt)
end

function love.draw()

	local image = love.graphics.newImage( imageData )
	love.graphics.draw(image,0,0,0,scalex,scaley)

	loveframes.draw()
end

function love.mousepressed(x, y, button)
	
	-- pass the mouse pressed event to love frames
	loveframes.mousepressed(x, y, button)
	
end

function love.mousereleased(x, y, button)

	-- pass the mouse released event to love frames
	loveframes.mousereleased(x, y, button)

end

function love.keypressed(key, unicode)

	if key=="escape" then
		love.event.push("quit")
	end

	loveframes.keypressed(key, string.byte(unicode,1))
end

function love.keyreleased(key)

	-- pass the key released event to love frames
	loveframes.keyreleased(key)
	
end