
package.path = package.path .. ';./LuaRPT/?.lua'

require('love.filesystem')

local serpent = require("serpent")
local demo=require("demo")
local scene = demo.load()
local mngch = love.thread.getChannel("manager");


mngch:push("viveeee!!")

local worker = love.thread.newThread("worker.lua","worker")
local wrkch = love.thread.getChannel("worker")

worker:start()

local s=serpent.dump(scene)
wrkch:push(s)

