package.path = package.path .. ';../?.lua'

local pm=require("primitives")



function dump(obj,lvl)
	local l=lvl or 0
	for i,v in pairs(obj) do
		print(string.rep("\t",l),i,v)
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


TestVector3()
TestCamera()
TestColorF()