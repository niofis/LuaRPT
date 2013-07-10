package.path = package.path .. ';../?.lua'

local pm=require("primitives")

function dump(obj)
	for i,v in pairs(obj) do
		print(i,v)
	end
end

function TestVector3()
	local v1=pm.Vector3:new{x=123456,y=2.2,z=0.12345678901234567}
	local srl=v1:serialize()
	print(srl)
	local v2=pm.Vector3.parse(srl)
	dump(v2)
end


TestVector3()