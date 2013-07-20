
package.path = package.path .. ';./LuaRPT/?.lua'

require('love.filesystem')

local demo=require("demo")
local scene = demo.load()
local mngch = love.thread.getChannel("manager");


mngch:push("viveeee!!")

local worker = love.thread.newThread("worker.lua","worker")
local wrkch = love.thread.getChannel("worker")

worker:start()

local s=scene:serialize()
wrkch:push(s)

