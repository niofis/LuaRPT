
package.path = package.path .. ';./LuaRPT/?.lua'

require('love.filesystem')
require('love.event')

local serpent = require("serpent")

local os = require("os")
local mngch = love.thread.getChannel("manager");
local regch = love.thread.getChannel("register")

local threads={}
local workers = {}
local workersdone=0
local alldone=true
local job=nil

local sections = {}

local tm  = os.clock()

function generateSections(sw,sh)
	sections = {}
	local xstep=sw
	local ystep=sh
	local x=0
	local y=0

	while y<job.resolution.height do
		while x<job.resolution.width do
			local s = {}
			s.x=x
			s.y=y
			s.width=xstep
			s.height=ystep
			s.resolution=job.resolution
			s.use_path_tracing = job.use_path_tracing
			s.path_tracing_samples = job.path_tracing_samples
			table.insert(sections,s)
			x=x+xstep
		end
		x=0
		y = y + ystep
	end
end

function getRegistrations(num)
	for _=1,num do
		local r = regch:demand()
		--Registration starts when the worker send a new channel
		if r and tostring(r)=="Channel" then
			local w={}
			w.id=tostring(w):sub(-7)
			w.channel=r
			workers[w.id]=w
		end
	end
end

function closeallworkers()
	for _,t in pairs(threads) do
		t:kill()
	end
end

function launchWorkers(num)
	for i=1,num do
		local w = love.thread.newThread("worker.lua","worker")
		w:start()
		table.insert(threads,w)
	end

	getRegistrations(num)
end

function renderdone()
	local m = {done = true}
	mngch:supply(serpent.dump(m))
	alldone=true
end

function getWorkerMessages()
	for _,w in pairs(workers) do
		local m = w.channel:pop()
		if m then
			m=loadstring(m)()

			if m.getwork then
				local s=table.remove(sections,1)
				if s then
					s.section=true
					s.sceneid=job.scene.id
					w.channel:supply(serpent.dump(s))
				else
					workersdone=workersdone + 1
					if workersdone == job.numworkers then
						renderdone()
					end
				end
			elseif m.result then
				mngch:supply(serpent.dump(m))
			elseif m.getscene then
				local s = serpent.dump(job.scene)
				w.channel:supply(s)
			end
		end
	end
end

function getManagerMessages()
	while true do
		local m = mngch:pop()
		if m then 
			m=loadstring(m)()
			if m.start then
				alldone=false
			if m.stop then
				alldone=true
			end
			elseif m.job then
				job=m.job
				closeallworkers()
				launchWorkers(job.numworkers)
				generateSections(job.sectionwidth,job.sectionheight)
			end
		end

		if alldone == false then
			getWorkerMessages()
		end
	end
end



--Init


--Main loop
getManagerMessages()

