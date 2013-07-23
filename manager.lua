
package.path = package.path .. ';./LuaRPT/?.lua'

require('love.filesystem')
require('love.event')
require('love.timer')

local serpent = require("serpent")

local os = require("os")
local managerchn = love.thread.getChannel("managerchn");
local mainchn = love.thread.getChannel("mainchn")
local regch = love.thread.getChannel("register")

local threads={}
local workers = {}
local workersdone=0
local working=true
local job=nil

local sections = {}

local tm  = os.clock()

function generatesections(sw,sh)
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

function getregistrations(num)
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
	for _,w in pairs(workers) do
		w.sendchn:supply(serpent.dump({close=true}))
		w.receivechn:clear()
	end
	threads={}
end

function launchworkers(num)
	threads={}
	for i=1,num do
		local w = love.thread.newThread("worker.lua","worker")
		w:start()
		table.insert(threads,w)
	end
	--getregistrations(num)
end

function renderdone()
	mainchn:supply(serpent.dump({done = true}))
	working=false
	managerchn:clear()
end

function getworkermessages()
	for _,w in pairs(workers) do
		local m = w.receivechn:pop()
		if m then
			if type(m) == "string" then
				local msg=loadstring(m)()

				if msg.getwork then
					local s=table.remove(sections,1)
					if s then
						s.section=true
						s.sceneid=job.scene.id
						w.sendchn:push(serpent.dump(s))
					else
						w.sendchn:push(serpent.dump({close = true }))
						workersdone=workersdone + 1
						if workersdone == job.numworkers then
							renderdone()
						end
					end
				elseif msg.result then
					mainchn:push(m)
				elseif msg.getscene then
					w.sendchn:push(serpent.dump({scene = job.scene}))
				end
			end
		end
	end
	for _,t in pairs(threads) do

		local err=t:getError()
		if err then
			print("Worker Error: ", err)
			debug.debug()
			love.event.push("quit")
		end
	end
end

function getmanagermessages()
	while working==true do
		local m = managerchn:pop()
		if m then
			if type(m) == "string" then
				local msg=loadstring(m)()
				if msg.stop then
					working=false
					closeallworkers()
					break
				elseif msg.job then
					working=true
					job=msg.job
					generatesections(job.sectionwidth,job.sectionheight)
					launchworkers(job.numworkers)
				end
			elseif tostring(m)=="Channel" then
				--This is a registration from a worker
				local w={}
				w.id=tostring(w):sub(-7)
				w.sendchn=m
				w.receivechn= love.thread.newChannel()
				workers[w.id]=w
				w.sendchn:push(w.receivechn)
			end
		end
		getworkermessages()
	end
end



--Init


--Main loop
getmanagermessages()

