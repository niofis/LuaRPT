local time = 0
local manager = nil
local mngch = nil
local errorCh = nil

function dumpObj(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function love.load()
	manager = love.thread.newThread("manager.lua","manager")
	mngch = love.thread.getChannel("manager")
	--errorCh = love.thread.getChannel("error")
	manager:start()
end

function love.update(dt)
	time=dt

	if mngch:peek() then
		print("Manager:",mngch:pop())
	end
	
	local err=manager:getError();
	if err then
		print(err)
		debug.debug()
		love.event.push("quit")
	end
end

function love.draw()
	love.graphics.print("time: " .. time , 10,10)
end

function love.keypressed(key, unicode)
	if key=="escape" then
		love.event.push("quit")
	end
end

