
local pm=require("primitives")
local serpent=require("serpent")
local os = require("os")
local demo=require("demo")
local string=require("string")

local time = 0
local manager = nil
local managerchn = nil
local mainchn = nil
local errorCh = nil
local wndwidth = 0
local wndheight = 0
local scalex=1.5
local scaley=1.5
local renderImage = nil
local job={}

local tm=0

local GUI = {}

function love.conf(t)
 -- as before
 t.identity = 'LuaRPT'
-- as before
end

function dumpObj(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function CreateJob()

	job.scene = demo.load()
	job.scene.id=tostring(job.scene):sub(-7)
	job.resolution = {}
	job.resolution.width = GUI.GetImageWidth()
	job.resolution.height = GUI.GetImageHeight()

	job.use_path_tracing = GUI.GetUsePathTracing()
	
	job.path_tracing_samples = GUI.GetPathTracingSamples()

	job.numworkers=GUI.GetWorkersNumber()
	local ss=GUI.GetSectorSize()
	job.sectionwidth=ss --math.ceil(job.resolution.height/(job.numworkers*ss))
	job.sectionheight=ss--math.ceil(job.resolution.height/(job.numworkers*ss))

	renderImage = love.image.newImageData( job.resolution.width, job.resolution.height )

	scalex=wndwidth/job.resolution.width
	scaley=wndheight/job.resolution.height
end

function StartJob()

	manager = love.thread.newThread("manager.lua","manager")
	manager:start()

	managerchn:push(serpent.dump({job=job}))
	managerchn:push(serpent.dump({start=true}))
	tm = os.clock()
end

function StopJob()
	managerchn:push(serpent.dump({stop=true}))
end

function SavePicture()
	if renderImage then
		renderImage:encode("img_" .. love.timer.getTime() .. ".png")
	end
end

function SaveScreenShot()
	local screenshot= love.graphics.newScreenshot()
	if screenshot then
		screenshot:encode("scr_" .. love.timer.getTime() .. ".png")
	end
end

function CreateNumberTextInput(label,default,parent)
	local font = loveframes.basicfontsmall
	local lbl = loveframes.Create("text")
	lbl:SetText(label)
	lbl:SetFont(font)
	parent:AddItem(lbl)
	local txt = loveframes.Create("textinput")
	txt:SetText(default)
	txt:SetFont(font)
	txt.OnTextChanged = function(object, text)
	    if tonumber(text) == nil then
	    	object:SetText(object:GetText():gsub("[^0-9]*",""))
	    end
	end
	parent:AddItem(txt)
	return txt
end

function CreateButton(label,parent,fn)
	local button = loveframes.Create("button")
	button:SetText(label)
	button.OnClick = fn
	parent:AddItem(button)
	return button
end

function createGUI()
	local font = loveframes.basicfontsmall

	--Main menu
	local mainframe = loveframes.Create("frame")
	mainframe:SetName("Render Options")
	mainframe:SetSize(200, 400)
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

	mainframe.workersnumtxt=CreateNumberTextInput("Workers Number:","8",optionslist)
	GUI.GetWorkersNumber = function () return tonumber(GUI.mainframe.workersnumtxt:GetText()) or 8 end

	mainframe.sectorsizetxt=CreateNumberTextInput("Sector size (pixels):","10",optionslist)
	GUI.GetSectorSize = function () return tonumber(GUI.mainframe.sectorsizetxt:GetText()) or 10 end

	local useptlbl = loveframes.Create("text")
	useptlbl:SetText("Use path tracing:")
	useptlbl:SetFont(font)
	optionslist:AddItem(useptlbl)
	local pathtracingchk = loveframes.Create("checkbox")
	pathtracingchk:SetSize(20,20)
	optionslist:AddItem(pathtracingchk)
	mainframe.pathtracingchk=pathtracingchk
	GUI.GetUsePathTracing = function () return GUI.mainframe.pathtracingchk:GetChecked() and 1 or 0 end

	mainframe.ptsamplestxt=CreateNumberTextInput("Path tracing samples:","10",optionslist)
	GUI.GetPathTracingSamples = function () return tonumber(GUI.mainframe.ptsamplestxt:GetText()) or 10 end


	mainframe.imagewidthtxt=CreateNumberTextInput("Width:","800",optionslist)
	GUI.GetImageWidth = function () return tonumber(GUI.mainframe.imagewidthtxt:GetText()) or 800 end

	mainframe.imageheighttxt=CreateNumberTextInput("Height:","600",optionslist)
	GUI.GetImageHeight = function () return tonumber(GUI.mainframe.imageheighttxt:GetText()) or 600 end

	CreateButton("Start",optionslist,function(object)
	    CreateJob()
	    StartJob()
	    GUI.infoframe:SetPos(GUI.mainframe:GetPos())
	    loveframes.SetState("running")
	end)

	--Image Buttons
	CreateButton("Save Screenshot",optionslist,SaveScreenShot)
	CreateButton("Save Image",optionslist,SavePicture)


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


	CreateButton("Stop",infolist,function(object)
		StopJob()
	    GUI.mainframe:SetPos(infoframe:GetPos())
	    loveframes.SetState("idle")
	end)

	--Image Buttons
	CreateButton("Save Screenshot",infolist,SaveScreenShot)
	CreateButton("Save Image",infolist,SavePicture)


	loveframes.SetState("idle")
end

function love.load()
	require("libraries.loveframes")

	wndwidth = love.window.getWidth()
	wndheight = love.window.getHeight()

	
	managerchn = love.thread.getChannel("managerchn")
	mainchn = love.thread.getChannel("mainchn")

	--sendjob()

	createGUI()
end

function love.update(dt)
	time=dt
	local s = mainchn:pop()
	if s then
		local m = loadstring(s)()
		if m.result then
			for y,v in pairs(m.data) do
				for x,w in pairs(v) do
					local c = pm.ColorF.to255(w)
					if x<job.resolution.width and y<job.resolution.height then
						renderImage:setPixel(x,y,c.r,c.g,c.b,255)
					end
				end
			end
		elseif m.done then
			print("Done in: " .. (os.clock() - tm) )
		end
	end
	
	if manager then
		local err=manager:getError();
		if err then
			print(err)
			debug.debug()
			love.event.push("quit")
		end
	end

	-- update love frames
	loveframes.update(dt)
end

function love.draw()
	if renderImage then
		local image = love.graphics.newImage( renderImage )
		love.graphics.draw(image,0,0,0,scalex,scaley)
	end

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