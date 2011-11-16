--[[
Copyright (c) 2011 Enrique CR

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
]]


local math = require('math')
local string = require("string")
local table = require("table")
local tostring = tostring

local base = _G
local io = require("io")

module("image")

function serialize(data)
	local s=""
	local c=nil
	local str=""

	for y=0,data.height-1 do
		for x=0, data.width-1 do
			c=data[y][x];
			s=string.format("%02X%02X%02X",
			math.min(c.r*255,255),
			math.min(c.g*255,255),
			math.min(c.b*255,255))
			str=str .. s
		end
		str=str .. "\n"
	end

	return str
end

function save(filename,data)

	local file=io.open(filename,"w")
	local s=""
	local str=""

	for y=data.x,data.x+data.height-1 do
		str=""
		for x=data.y,data.y+data.width-1 do
			c=data[y][x];
			s=string.format("%02X%02X%02X",
			math.min(c.r*255,255),
			math.min(c.g*255,255),
			math.min(c.b*255,255))
			str=str .. s
		end
		file:write(str,"\n")
	end

	file:close()
end

function saveforpost(message,local_filename,remote_filename, data)
	local file=io.open(local_filename,"w")
	local s=""
	local str=""

	file:write("message=",message,"&filename=",remote_filename,"&imagedata=")

	for y=0,data.height-1 do
		str=""
		for x=0, data.width-1 do
			c=data[y][x];
			s=string.format("%02X%02X%02X",
			math.min(c.r*255,255),
			math.min(c.g*255,255),
			math.min(c.b*255,255))
			str=str .. s
		end
		file:write(str,"\n")
	end
	file:close()
end

function savebinary(filename,data)
	local file=io.open(filename,"wb")
	for y=0,data.height-1 do
		for x=0, data.width-1 do
			c=data[y][x];
			file:write(
			string.char(math.min(c.r*255,255)),
			string.char(math.min(c.g*255,255)),
			string.char(math.min(c.b*255,255)))
		end
	end
	file:close()
end

function load(filename)
	local data={}
	local file=io.open(filename)
	local y=0
	local x=0
	local nums
	if file==nil then return nil end
	for line in file:lines() do
		x=0
		data[y]=data[y] or {}
		for d in line:gmatch("(%x%x%x%x%x%x)") do
			data[y][x]=data[y][x] or {}
			data[y][x].r=image.hextonum(d:match("%x%x",1))
			data[y][x].g=image.hextonum(d:match("%x%x",3))
			data[y][x].b=image.hextonum(d:match("%x%x",5))
			x=x+1
		end
		y=y+1
	end

	data.width=x
	data.height=y

	return data
end

local function hextonum(value)
	local pos=1
	local ex
	local number=0
	ex=value:len()-1
	value=value:lower()
	for d in value:gmatch("%x") do
		local v=0
		v=string.byte(d) - string.byte("0")
		if v>=string.byte("1") then v=v-string.byte("1")+10 end
		number=number+math.pow(16,ex)*v
		ex=ex-1
	end
	return number
end

