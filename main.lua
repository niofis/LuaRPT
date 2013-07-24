
local pm=require("primitives")
local serpent=require("serpent")
local os = require("os")
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
local framesstate="none"

local tm=0

local GUI = {}

function love.conf(t)
 t.identity = 'LuaRPT'
 t.title = 'LuaRPT'
end

function dumpbbj(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function createjob()

	package.loaded.scene=nil

	job = {}
	job.done=false
	job.scene = require("scene").load()
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

	job.sectionstotal=(job.resolution.width*job.resolution.height) / (job.sectionwidth*job.sectionheight)
	job.sectionsdone=0

	renderImage = love.image.newImageData( job.resolution.width, job.resolution.height )

	scalex=wndwidth/job.resolution.width
	scaley=wndheight/job.resolution.height

end

function startjob()

	manager = love.thread.newThread("manager.lua","manager")

	managerchn:clear()
	managerchn:push(serpent.dump({job=job}))

	manager:start()
	tm = os.clock()
end

function stopjob()
	if job.done==false then
		job.done=true
		managerchn:push(serpent.dump({stop=true}))
		mainchn:clear()
	end
end

function savepicture()
	if renderImage then
		renderImage:encode("img_" .. love.timer.getTime() .. ".png")
	end
end

function savescreenshot()
	local screenshot= love.graphics.newScreenshot()
	if screenshot then
		screenshot:encode("scr_" .. love.timer.getTime() .. ".png")
	end
end

function updateinfo()
	GUI.infoframe.progresslbl:SetText("Sections: " .. job.sectionsdone .. "/" .. job.sectionstotal .. " (" .. math.ceil(100*job.sectionsdone/job.sectionstotal) .. "%)")
	GUI.infoframe.timelbl:SetText("Render time: " .. os.clock() - tm .. "s")
end

function createnumbertextinput(label,default,parent)
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

function createbutton(label,parent,fn)
	local button = loveframes.Create("button")
	button:SetText(label)
	button.OnClick = fn
	parent:AddItem(button)
	return button
end

function createlabel(text,parent,font)
	local lbl = loveframes.Create("text")
	lbl:SetText(text)
	lbl:SetFont(font)
	parent:AddItem(lbl)
	return lbl
end

function creategui()
	local font = loveframes.basicfontsmall

	--Main menu
	local mainframe = loveframes.Create("frame")
	mainframe:SetName("Render Options (toggle: m)")
	mainframe:SetSize(200, 410)
	mainframe:SetPos(wndwidth-200,0)
	mainframe:SetState("idle")
	mainframe:ShowCloseButton(false)

	GUI.mainframe=mainframe

	local optionslist = loveframes.Create("list", mainframe)
	optionslist:SetSize(200, optionslist:GetParent():GetHeight() - 25)
	optionslist:SetPos(0, 25)
	optionslist:SetPadding(5)
	optionslist:SetSpacing(5)
	optionslist:SetDisplayType("vertical")

	mainframe.workersnumtxt=createnumbertextinput("Workers Number:","8",optionslist)
	GUI.GetWorkersNumber = function () return tonumber(GUI.mainframe.workersnumtxt:GetText()) or 8 end

	mainframe.sectorsizetxt=createnumbertextinput("Sector size (pixels):","10",optionslist)
	GUI.GetSectorSize = function () return tonumber(GUI.mainframe.sectorsizetxt:GetText()) or 10 end

	local useptlbl = loveframes.Create("text")
	useptlbl:SetText("Use path tracing:")
	useptlbl:SetFont(font)
	optionslist:AddItem(useptlbl)

	local usepathtracing = loveframes.Create("multichoice")
	usepathtracing:AddChoice("Yes")
	usepathtracing:AddChoice("No")
	usepathtracing:SetChoice("No")
	optionslist:AddItem(usepathtracing)
	mainframe.usepathtracing=usepathtracing
	GUI.GetUsePathTracing = function () return GUI.mainframe.usepathtracing:GetChoice()=="Yes" and 1 or 0 end

	mainframe.ptsamplestxt=createnumbertextinput("Path tracing samples:","10",optionslist)
	GUI.GetPathTracingSamples = function () return tonumber(GUI.mainframe.ptsamplestxt:GetText()) or 10 end


	mainframe.imagewidthtxt=createnumbertextinput("Render Image Width:","800",optionslist)
	GUI.GetImageWidth = function () return tonumber(GUI.mainframe.imagewidthtxt:GetText()) or 800 end

	mainframe.imageheighttxt=createnumbertextinput("Render Image Height:","600",optionslist)
	GUI.GetImageHeight = function () return tonumber(GUI.mainframe.imageheighttxt:GetText()) or 600 end

	createbutton("Start",optionslist,function(object)
	    createjob()
	    startjob()
	    GUI.infoframe:SetPos(GUI.mainframe:GetPos())
	    GUI.infoframe.stopbutton:SetText("Stop")
	    loveframes.SetState("running")
	end)

	--Image Buttons
	createbutton("Save Screenshot",optionslist,savescreenshot)
	createbutton("Save Image",optionslist,savepicture)


	--Information frame
	local infoframe = loveframes.Create("frame")
	infoframe:SetName("Render Info (toggle: m)")
	infoframe:SetSize(200, 160)
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

	GUI.infoframe.progresslbl=createlabel("Progress:",infolist,font)
	GUI.infoframe.timelbl=createlabel("Time:",infolist,font)

	infoframe.stopbutton=createbutton("Stop",infolist,function(object)
		stopjob()
	    GUI.mainframe:SetPos(GUI.infoframe:GetPos())
	    loveframes.SetState("idle")
	end)


	--Image Buttons
	createbutton("Save Screenshot",infolist,savescreenshot)
	createbutton("Save Image",infolist,savepicture)


	loveframes.SetState("idle")
end

function love.load()
	love.window.setMode(800,600)

	require("libraries.loveframes")

	wndwidth = love.window.getWidth()
	wndheight = love.window.getHeight()

	
	managerchn = love.thread.getChannel("managerchn")
	mainchn = love.thread.getChannel("mainchn")

	creategui()
end

function love.update(dt)
	time=dt
	local m = mainchn:pop()
	if m then
		local msg = loadstring(m)()
		if msg.result then
			for y,v in pairs(msg.data) do
				for x,w in pairs(v) do
					local c = pm.ColorF.to255(w)
					if x<job.resolution.width and y<job.resolution.height then
						renderImage:setPixel(x,y,c.r,c.g,c.b,255)
					end
				end
			end
			job.sectionsdone=job.sectionsdone + 1
		elseif msg.done then
			job.done=true
			GUI.infoframe.stopbutton:SetText("Back")
			--last info update
			updateinfo()
		end
	end
	
	if manager then
		local err=manager:getError();
		if err then
			print("Manager Error: ", err)
			debug.debug()
			love.event.push("quit")
		end
	end

	-- update love frames
	if job.done==false then
		updateinfo()
	end

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
	elseif key == "m" then
		local tmp=loveframes.GetState()
		loveframes.SetState(framesstate)
		framesstate=tmp
	end

	loveframes.keypressed(key, string.byte(unicode or "\0",1))
end

function love.keyreleased(key)

	-- pass the key released event to love frames
	loveframes.keyreleased(key)
	
end