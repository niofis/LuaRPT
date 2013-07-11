package.path = package.path .. ';../?.lua'

local pm=require("primitives")
local dm=require("demo")



function dump(obj,lvl)
	local l=lvl or 0
	for i,v in pairs(obj) do
		--print(string.rep("\t",l),i,v)
		if type(v)=="table" then
			dump(v,l+1)
		end
	end
end

function TestVector3()
	local v1=pm.Vector3:new{x=123456,y=2.2,z=0.12345678901234567}
	local srl=v1:serialize()
	print(srl)
	local v2=pm.Vector3.parse(srl)
	dump(v2)
end

function TestCamera()
	local c1=pm.Camera:new{}

	c1.lt.x=-3.2
	c1.lt.y=4.8
	c1.lt.z=-5
	c1.lb.x=-3.2
	c1.lb.y=0
	c1.lb.z=-5
	c1.rt.x=3.2
	c1.rt.y=4.8
	c1.rt.z=-5
	c1.eye.x=0
	c1.eye.y=2.4
	c1.eye.z=-15

	local srl=c1:serialize()
	print(srl)

	local c2=pm.Camera.parse(srl)
	dump(c2)
end

function TestColorF()
	local v1=pm.ColorF:new{r=1,g=0.9,b=0.8,a=0.7}
	local srl=v1:serialize()
	print(srl)
	local v2=pm.ColorF.parse(srl)
	dump(v2)
end

function TestLight()
	local l1=pm.Light:new{color=pm.ColorF:new{r=1,g=1,b=1},position=pm.Vector3:new{x=5,y=5,z=-5},intensity=40}
	local srl=l1:serialize()
	print(srl)
	local l2=pm.Light.parse(srl)
	dump(l2)
end

function TestSphere()
	local l1=pm.Sphere:new{name="blue",center=pm.Vector3:new{x=0,y=1,z=0},radius=1,color=pm.ColorF:new{b=1}, specular=1}
	local srl=l1:serialize()
	print(srl)
	local l2=pm.Sphere.parse(srl)
	dump(l2)
end

function TestTriangle()
	local l1=pm.Triangle:new{name="back",p1=pm.Vector3:new{x=-200,y=-200,z=50},p3=pm.Vector3:new{x=200,y=-200,z=50},p2=pm.Vector3:new{x=0,y=2000,z=50},color=pm.ColorF:new{b=1, r=0.7372, g=0.9098}}
	local srl=l1:serialize()
	print(srl)
	local l2=pm.Triangle.parse(srl)
	dump(l2)
end

function TestScene()
	local l1=dm.load()
	local srl=l1:serialize()
	print(srl)
end



--[[
TestVector3()
TestCamera()
TestColorF()
TestLight()
TestSphere()
TestTriangle()
]]
TestScene()