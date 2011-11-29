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


local math=require("math")
local rt=require("raytracer")
local pm=require("primitives")

local base = _G
local io = require("io")

module("demo")

function spiral(count,start,scn)
	local si=2*math.pi/count
	local dx,dy,dz
	dy=0.125
	for i=start,count+start do
		dy=dy+0.25
		dx=math.sin(si*i)+2.5
		dz=-math.cos(si*i)
		scn.objects[i]=pm.Sphere:new{name="spiral"..i,center=pm.Vector3:new{x=dx,y=dy,z=dz},radius=0.35,color=pm.ColorF:new{r=1,g=0.5}}
	end
end

function load()

local scn=pm.Scene:new{}
scn.camera.lt.x=-3.2
scn.camera.lt.y=4.8
scn.camera.lt.z=-5
scn.camera.lb.x=-3.2
scn.camera.lb.y=0
scn.camera.lb.z=-5
scn.camera.rt.x=3.2
scn.camera.rt.y=4.8
scn.camera.rt.z=-5
scn.camera.eye.x=0
scn.camera.eye.y=2.4
scn.camera.eye.z=-15


scn.objects[3]=pm.Sphere:new{name="blue",center=pm.Vector3:new{x=0,y=1,z=0},radius=1,color=pm.ColorF:new{b=1}}
scn.objects[4]=pm.Sphere:new{name="yellow",center=pm.Vector3:new{x=-2,y=1,z=1},radius=1,color=pm.ColorF:new{r=1,g=1},reflection=0.40}
scn.objects[5]=pm.Sphere:new{name="red-glass",center=pm.Vector3:new{x=-0.5,y=0.5,z=-3},radius=0.5,color=pm.ColorF:new{a=0.5,r=1,g=0,b=0},refraction=1.491}

scn.objects[1]=pm.Triangle:new{name="floor",p1=pm.Vector3:new{x=-200,y=0,z=200},p2=pm.Vector3:new{x=200,y=0,z=200},p3=pm.Vector3:new{x=0,y=0,z=-20},color=pm.ColorF:new{g=0.5,r=0.5,b=0.5}}
scn.objects[2]=pm.Triangle:new{name="back",p1=pm.Vector3:new{x=-200,y=-200,z=50},p3=pm.Vector3:new{x=200,y=-200,z=50},p2=pm.Vector3:new{x=0,y=2000,z=50},color=pm.ColorF:new{b=1, r=0.7372, g=0.9098}}

spiral(10,6,scn)

--scn.lights[1]=Light:new{color=ColorF:new{r=1,g=1,b=1},position=Vector3:new{x=5,y=5,z=-5},intensity=40}
--scn.lights[2]=Light:new{color=ColorF:new{r=1,g=1,b=1},position=Vector3:new{x=-5,y=5,z=5},intensity=40}
--scn.lights[1]=Sphere:new{name="light",center=Vector3:new{x=5,y=5,z=-5},radius=1,color=ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=100}
scn.lights[1]=pm.Sphere:new{name="light",center=pm.Vector3:new{x=15,y=50,z=-10},radius=5,color=pm.ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=1000};
--scn.lights[2]=pm.Sphere:new{name="light2",center=pm.Vector3:new{x=0,y=3,z=-1},radius=0.33,color=pm.ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=1}


--scn:loadfromms3d("smart.ms3d",{x=0,y=0,z=0})

return scn
end
