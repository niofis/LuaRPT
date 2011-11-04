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
local primitives = require("primitives")

local base = _G

module("bvh")


BVH={}

function BVH:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.head=o.head or primitives.Box:new{}
	o.num_boxed=1
	o.heigth=1

	return o
end


--ordering by quicksort using x coordinate
function BVH:qsort(list,p,r)
	if p<r then
		local q=self:partition(list,p,r)
		self:qsort(list,p,q-1)
		self:qsort(list,q+1,r)
	end
end

function BVH:partition(list,p,r)
	local x=list[r].max.z
	local i=p-1
	local t
	for j=p,r-1 do
		if list[j].max.z<=x then
			i=i+1
			t=list[i]
			list[i]=list[j]
			list[j]=t
		end
	end
	i=i+1
	t=list[i]
	list[i]=list[r]
	list[r]=t
	return i
end


function BVH:build(scene)
	--traverse the scene.objects list, create boxes for each object
	--merge near boxes and later create the hierarchy

	--I'll start by grouping four by four in no order whatsoever
	local box
	local list={}
	local leaves={}
	local leaves_count=0
	local count=0
	local leave_size=4

	self.leaves={}

	--get list of boxes for every object in scene
	for i,v in base.pairs(scene.objects) do
		count=count+1
		list[count]=v:getbox()
	end

	--order said list using min.x coordinate

	--self:qsort(list,1,count)


	--merge near (leave_size) boxes
	leaves_count=0
	for i=1,count,leave_size do
		box=primitives.Box:new()
		for x=0,leave_size-1 do
			box=primitives.Box.merge(box,list[i+x])
		end
		leaves_count=leaves_count+1
		leaves[leaves_count]=box
	end


	while leaves_count>1 do
		count=0
		--2 by 2. odd goes left, even goes right
		for i=1,leaves_count,2 do
			box=primitives.Box:new{}
			box:add(leaves[i],1)	--goes left
			box:add(leaves[i+1],0)  --goes right
			count=count+1
			leaves[count]=box
		end
		leaves_count=count
	end
	self.head=leaves[1]
end

function BVH:traverse(ray)
	local objs={}
	self:rtraceray(self.head,ray,objs)
	return objs
end

function BVH:rtraceray(box,ray,objs)
	if box:intersect(ray) then
		if box.left~=nil then
			self:rtraceray(box.left,ray,objs)
		end
		if box.right~=nil then
			self:rtraceray(box.right,ray,objs)
		end
		if box.objects~=nil then
			local i=#objs
			for _,v in base.pairs(box.objects) do
				i=i+1
				objs[i]=v
			end
		end
	end
end
