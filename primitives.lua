
local math = require('math')
local string = require("string")
local table = require("table")
local serpent = require("serpent")
local ms3d = {} --require("ms3d")
local tostring = tostring

local base = _G
module("primitives")

Vector3={}

function Vector3:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.x=o.x or 0
	o.y=o.y or 0
	o.z=o.z or 0
	return o
end

Vector3.__add = function(a,b)
	local res = Vector3:new{}
	res.x=a.x+b.x
	res.y=a.y+b.y
	res.z=a.z+b.z
	return res
end

Vector3.__sub = function(a,b)
	local res = Vector3:new{}
	res.x=a.x-b.x
	res.y=a.y-b.y
	res.z=a.z-b.z
	return res
end

Vector3.__mul = function(a,b) --Dot Prodct or scale depending on parameter b
	local res = 0
	if(base.type(b)=="table") then
		res=a.x*b.x + a.y*b.y + a.z*b.z
	elseif(base.type(b)=="number") then
		res=Vector3:new{x=a.x*b, y=a.y*b, z=a.z*b}
	end
	return res
end

Vector3.__div = function(a,b)
	local res=Vector3:new{x=a.x/b, y=a.y/b, z=a.z/b}
	return res
end

Vector3.__pow = function(a,b) --^ Cross Product
	local res = Vector3:new{}
	res.x=a.y*b.z-a.z*b.y
	res.y=a.z*b.x-a.x*b.z
	res.z=a.x*b.y-a.y*b.x
	return res
end

function Vector3:add(a)
	if(base.type(a)=="table") then
		self.x=self.x+a.x
		self.y=self.y+a.y
		self.z=self.z+a.z
	elseif(base.type(a)=="number") then
		self.x=self.x+a
		self.y=self.y+a
		self.z=self.z+a
	end
end

function Vector3:multiply(a)
	if(base.type(a)=="table") then
		self.x=self.x*a.x
		self.y=self.y*a.y
		self.z=self.z*a.z
	elseif(base.type(a)=="number") then
		self.x=self.x*a
		self.y=self.y*a
		self.z=self.z*a
	end
end

function Vector3:length()--Length/Norm
	local res=0
	local a= self
	res=math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z)
	return res
end

function Vector3:normal()
	local res=Vector3:new{}
	local l=self:length()
	res.x=self.x/l
	res.y=self.y/l
	res.z=self.z/l
	return res
end

function Vector3:normalize()
	local l=self:length()
	self.x=self.x/l
	self.y=self.y/l
	self.z=self.z/l
	return l
end

function Vector3:reciprocal()
	local res=Vector3:new{}
	res.x=1/self.x
	res.y=1/self.y
	res.z=1/self.z
	return res
end

Camera={}

function Camera:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.lt= Vector3:new(o.lt)
	o.lb= Vector3:new(o.lb)
	o.rt= Vector3:new(o.rt)
	o.eye= Vector3:new(o.eye)
	return o
end

Scene={}
function Scene:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	if base.type(o.objects) == "table" then
		for _,b in base.pairs(o.objects) do
			if b.type == "sphere" then Sphere:new(b) end
			if b.type == "triangle" then Triangle:new(b) end
		end
	else
		o.objects=o.objects or {}
	end

	if base.type(o.lights) == "table" then
		for _,l in base.pairs(o.lights) do
			if l.type == "point_light" then Light:new(l) end
		end
	else
		o.lights=o.lights or {}
	end

	if base.type(o.materials) == "table" then
		for _,m in base.pairs(o.materials) do
			Material:new(m)
		end
	else
		o.materials=o.materials or {}
	end

	if base.type(o.groups) == "table" then
		for _,g in base.pairs(o.groups) do
			Group:new(g)
		end
	else
		o.groups=o.groups or {}
	end

	o.camera=Camera:new(o.camera)

	return o
end

function Scene:addobject(o)
	table.insert(self.objects,o)
end

function Scene:addlight(l)
	table.insert(self.lights,l)
end

function Scene:addmaterial(m)
	table.insert(self.materials,m)
end

function Scene:addgroup(g)
	table.insert(self.groups,g)
end

function Scene:serialize()
	return serpent.dump(self)
end

function Scene:loadfromms3d(filename, offset, scale,specular)
	ms3d.loadfile(filename)
	local num_triangles=ms3d.getnumtriangles()
	for i=1,num_triangles do
		local tr=ms3d.gettriangle(i)
		local obj=Triangle:new{name="",p1=Vector3:new{x=tr.v1.x,y=tr.v1.y,z=tr.v1.z},
											p3=Vector3:new{x=tr.v2.x,y=tr.v2.y,z=tr.v2.z},
											p2=Vector3:new{x=tr.v3.x,y=tr.v3.y,z=tr.v3.z},
											color=ColorF:new{a=tr.color.a,r=tr.color.r,g=tr.color.g,b=tr.color.b},specular=specular}

		if tr.color.a<1.0 then
			obj.refraction=1
			--i'll have to add another triangle for the refraction to work with the vertices swaped so it gets an inverted normal
			--[[
			local obj2=Triangle:new{name="",p1=Vector3:new{x=tr.v1.x,y=tr.v1.y,z=tr.v1.z},
											p3=Vector3:new{x=tr.v2.x,y=tr.v2.y,z=tr.v2.z},
											p2=Vector3:new{x=tr.v3.x,y=tr.v3.y,z=tr.v3.z},
											color=ColorF:new{a=tr.color.a,r=tr.color.r,g=tr.color.g,b=tr.color.b}}
			local dissp=obj:normal()*(-0.001)
			obj2.p1:add(dissp)
			obj2.p2:add(dissp)
			obj2.p3:add(dissp)
			obj2.refraction=1.491
			table.insert(self.objects,obj2)
			]]
		end

		if base.type(offset)=="table" then
			obj.p1:add(offset)
			obj.p2:add(offset)
			obj.p3:add(offset)
		end
		table.insert(self.objects,obj)
	end
	ms3d.closefile()
end


ColorF={}

function ColorF:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.a=o.a or 0
	o.r=o.r or 0
	o.g=o.g or 0
	o.b=o.b or 0

	return o
end

ColorF.__add = function(a,b)
	local res = ColorF:new{}
	if(base.type(b)=="number") then
		res.a=a.a+b
		res.r=a.r+b
		res.g=a.g+b
		res.b=a.b+b
	elseif (base.type(b)=="table") then
		res.a=a.a+b.a
		res.r=a.r+b.r
		res.g=a.g+b.g
		res.b=a.b+b.b
	end
	return res
end

ColorF.__sub = function(a,b)
	local res = ColorF:new{}
	res.a=a.a-b.a
	res.r=a.r-b.r
	res.g=a.g-b.g
	res.b=a.b-b.b
	return res
end

ColorF.__mul = function(a,b)
	local res = ColorF:new{}
	if(base.type(b)=="table") then
		res.a=a.a*b.a
		res.r=a.r*b.r
		res.g=a.g*b.g
		res.b=a.b*b.b
	elseif(base.type(b)=="number")then
		res.a=a.a*b
		res.r=a.r*b
		res.g=a.g*b
		res.b=a.b*b
	end
	return res
end

ColorF.__div = function(a,b)
	local res = ColorF:new{}
	if(base.type(b)=="table") then
		res.a=a.a/b.a
		res.r=a.r/b.r
		res.g=a.g/b.g
		res.b=a.b/b.b
	elseif(base.type(b)=="number")then
		res.a=a.a/b
		res.r=a.r/b
		res.g=a.g/b
		res.b=a.b/b
	end
	return res
end

function ColorF:to255()
	local res = ColorF:new{}
	res.a=math.min(math.floor(self.a*255),255)
	res.r=math.min(math.floor(self.r*255),255)
	res.g=math.min(math.floor(self.g*255),255)
	res.b=math.min(math.floor(self.b*255),255)
	return res
end

function ColorF:normalize()
	local m = math.max(self.r,self.g,self.b)
	if(m>1) then
		self.r=self.r/m
		self.g=self.g/m
		self.b=self.b/m
	end
end

Material = {}

function Material:new(o)
	o = o or {}
	base.setmetatable(o,self)
	self.__index = self

	o.name = o.name or "material"
	o.diffuse = ColorF:new(o.diffuse)
	o.reflection = o.reflection or 0
	o.refraction = o.refraction or 0
	o.specular = o.specular or 0
	return o
end

function Material:getdiffuse(x,y)
	return self.diffuse
end

Group = {}

function Group:new(o)
	o = o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.name = o.name or "group"
	o.material = Material:new(o.material)
	return o
end

Box={}

function Box:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.min=o.min or Vector3:new{}
	o.max=o.max or Vector3:new{}
	o.objects=nil
	o.left=nil
	o.right=nil
	return o
end

function Box:add(box,is_left)
	if is_left==1 then
		self.left=box
	else
		self.right=box
	end

	if box~=nil then
		self.max.x=math.max(self.max.x,box.max.x)
		self.max.y=math.max(self.max.y,box.max.y)
		self.max.z=math.max(self.max.z,box.max.z)

		self.min.x=math.min(self.min.x,box.min.x)
		self.min.y=math.min(self.min.y,box.min.y)
		self.min.z=math.min(self.min.z,box.min.z)
	end
end

function Box.createparent(a,b)
	local res=Box:new{}
	res.max.x=math.max(a.max.x,b.max.x)
	res.max.y=math.max(a.max.y,b.max.y)
	res.max.z=math.max(a.max.z,b.max.z)

	res.min.x=math.min(a.min.x,b.min.x)
	res.min.y=math.min(a.min.y,b.min.y)
	res.min.z=math.min(a.min.z,b.min.z)

	if(a.min.x<b.min.x) then
		res.left=a
		res.right=b
	else
		res.left=b
		res.right=a
	end
	return res
end

function Box.merge(a,b)
	local res=Box:new{}
	local idx=1

	if b==nil then return a end

	res.objects={}

	res.max.x=math.max(a.max.x,b.max.x)
	res.max.y=math.max(a.max.y,b.max.y)
	res.max.z=math.max(a.max.z,b.max.z)

	res.min.x=math.min(a.min.x,b.min.x)
	res.min.y=math.min(a.min.y,b.min.y)
	res.min.z=math.min(a.min.z,b.min.z)

	if(a.objects) then
		for i,v in base.pairs(a.objects) do
			res.objects[idx]=v
			idx=idx+1
		end
	end

	if(b.objects) then
		for i,v in base.pairs(b.objects) do
			res.objects[idx]=v
			idx=idx+1
		end
	end

	return res
end

function Box:center()
	local res=Vector3:new{}
	res.x=(self.max.x+self.min.x)/2
	res.y=(self.max.y+self.min.y)/2
	res.z=(self.max.z+self.min.z)/2
	return res
end

function Box:distance(other)
	return (self:center()-other:center()):length()
end

function Box:intersect(ray)

	local inv_direction=ray.direction:reciprocal()
	local sign={(inv_direction.x<0) and 2 or 1,
				(inv_direction.y<0) and 2 or 1,
				(inv_direction.z<0) and 2 or 1}
	local parameters={self.min,self.max}

	local tmin=(parameters[sign[1]].x - ray.origin.x) * inv_direction.x
	local tmax=(parameters[3-sign[1]].x - ray.origin.x) * inv_direction.x
	local tymin=(parameters[sign[2]].y - ray.origin.y) * inv_direction.y
	local tymax=(parameters[3-sign[2]].y - ray.origin.y) * inv_direction.y
	if (tmin>tymax) or (tymin>tmax) then
		return false
	end
	if tymin>tmin then
		tmin=tymin
	end
	if tymax<tmax then
		tmax=tymax
	end
	local tzmin=(parameters[sign[3]].z - ray.origin.z) * inv_direction.z
	local tzmax=(parameters[3-sign[3]].z - ray.origin.z) * inv_direction.z
	if (tmin>tzmax) or (tzmin>tmax) then
		return false
	end

	return true
end


Light={}

function Light:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.position= Vector3:new(o.position)
	o.color= ColorF:new(o.color)
	o.intensity=o.intensity or 100

	o.type="point_light"
	return o
end

Sphere={}
function Sphere:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.center= Vector3:new(o.center)
	
	o.group= Group:new(o.group)

	o.radius=o.radius or 0
	o.name=o.name or "sphere"
	o.reflection=o.reflection or 0
	o.refraction=o.refraction or 0
	o.specular=o.specular or 0

	o.islight=o.islight or 0
	o.intensity= o.intensity or 0

	o.type="sphere"

	return o
end


function Sphere:normal(pt)
	local res=pt-self.center
	res:normalize()
	return res
end

function Sphere:intersect(ray)
	local sphere=self
	local edge=ray.origin-sphere.center
	local B=-2.0*(edge*ray.direction)
	local B2=B*B
	local C=(edge*edge)-(sphere.radius*sphere.radius)
	local I=B2-4.0*C

	if(I<0) then
		return nil
	end


	local t0=math.sqrt(I)
	local t=(B-t0)/2.0

	if(t<0.01) then
		t=(B+t0)/2.0
	end


	if(t<0.01) then
		return nil
	end

	return t
end

function Sphere:getbox()
	local res=Box:new()
	res.min.x=self.center.x-self.radius
	res.min.y=self.center.y-self.radius
	res.min.z=self.center.z-self.radius

	res.max.x=self.center.x+self.radius
	res.max.y=self.center.y+self.radius
	res.max.z=self.center.z+self.radius

	res.objects={self}

	return res

end

function Sphere:getlightpoint()
	return self.center;
end

function Sphere:getrandomlightpoint()
	local pt=Vector3:new{}
	pt.x=math.random(-100000,100000)
	pt.y=math.random(-100000,100000)
	pt.z=math.random(-100000,100000)
	pt:normalize()
	pt=self.center + (pt*self.radius)
	return pt;
end

Triangle={}
function Triangle:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.p1=Vector3:new(o.p1)
	o.p2=Vector3:new(o.p2)
	o.p3=Vector3:new(o.p3)
	o.color=ColorF:new(o.color)
	o.name=o.name or "triangle"
	o.reflection=o.reflection or 0
	o.refraction=o.refraction or 0
	o.specular=o.specular or 0

	o.islight=o.islight or 0
	o.intensity= o.intensity or 0

	o.type="triangle"
	--Initialize
	o:init()
	return o
end


function Triangle:init()
	self.v1=self.p1
	self.v2=self.p2-self.p1
	self.v3=self.p3-self.p1
	self.n=self.v2^self.v3
	self.n:normalize()
end

function Triangle:normal(pt)
	return self.n
end

function Triangle:intersect(ray)
	local temp=ray.origin-self.v1
	local B=temp*self.n
	local B2=ray.direction*self.n
	local t=-B/B2
	local k=0
	local u=0

	if t<0.0001 then
		return nil
	end

	if math.abs(self.n.x)>math.abs(self.n.y) then
		if math.abs(self.n.x)>math.abs(self.n.z) then
			k='x'
			u='y'
			v='z'
		else
			k='z'
			u='x'
			v='y'
		end
	else
		if math.abs(self.n.y)>math.abs(self.n.z) then
			k='y'
			u='z'
			v='x'
		else
			k='z'
			u='x'
			v='y'
		end
	end
	temp={}
	temp[u]=ray.origin[u] + t*ray.direction[u] - self.v1[u]
	temp[v]=ray.origin[v] + t*ray.direction[v] - self.v1[v]

	local I=self.v3[u]*self.v2[v] - self.v3[v]*self.v2[u]

	B=(self.v3[u]*temp[v] - self.v3[v]*temp[u])/I
	if B < 0 then
		return nil
	end

	local C = (self.v2[v]*temp[u] - self.v2[u]*temp[v])/I
	if C < 0 then
		return nil
	end

	if (B+C) > 1 then
		return nil
	end

	return t
end

function Triangle:getbox()
	local res=Box:new()
	res.min.x=math.min(self.p1.x,self.p2.x,self.p3.x)
	res.min.y=math.min(self.p1.y,self.p2.y,self.p3.y)
	res.min.z=math.min(self.p1.z,self.p2.z,self.p3.z)

	res.max.x=math.max(self.p1.x,self.p2.x,self.p3.x)
	res.max.y=math.max(self.p1.y,self.p2.y,self.p3.y)
	res.max.z=math.max(self.p1.z,self.p2.z,self.p3.z)

	res.objects={self}

	return res

end

function Triangle:getlightpoint()
	return self.p1;
end

function Triangle:getrandomlightpoint()
	return self.p1;
end
