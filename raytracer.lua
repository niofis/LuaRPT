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

local bvh = require("bvh")
local primitives = require("primitives")
local os = require("os")
local math = require('math')
local string = require("string")
local table = require("table")
local tostring = tostring

local base = _G

module("raytracer")

Ray={}
function Ray:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.origin=o.origin or primitives.Vector3:new{}
	o.direction=o.direction or primitives.Vector3:new{}

	return o
end

function Ray:normalize()
	self.direction:normalize()
end

Result={}
function Result:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.color=primitives.ColorF:new{}
	o.samples=0

	return o
end


Raytracer={}
function Raytracer:new(o)
	o=o or {}
	base.setmetatable(o,self)
	self.__index=self

	o.resolution = o.resolution or {}
	o.image = o.image or {}
	o.scene = o.scene or Scene:new{}
	o.bvh=bvh.BVH:new{}
	o.bvh_init=0

	return o
end


function Raytracer:render(section,use_pathtracing,samples)
	local camera=self.scene.camera
	local hdv=(camera.rt-camera.lt)/self.resolution.width	--horizontal delta vector
	local vdv=(camera.lb-camera.lt)/self.resolution.height  --vertical delta vector

	if self.bvh_init==0 then
		base.print("Building BVH...")
		local st=os.clock()
		self.bvh:build(self.scene)
		base.print("Done in " .. os.clock()-st .. "s")
		self.bvh_init=1
	end
	self.use_pathtracing=use_pathtracing
	self.results={}
	for y=section.y,section.y+section.height-1 do
		self.image[y]=self.image[y] or {}
		for x=section.x,section.x+section.width-1 do
			local pt=(camera.lt + (hdv*x) + (vdv*y))
			local ray=Ray:new{origin=pt,direction=pt-camera.eye}
			ray:normalize()

			if(use_pathtracing==0) then
				--Not path tracing
				local r=self:traceray(ray,1,use_pathtracing)
				self.image[y][x]=r.color

			else
				--Path Tracing
				samples=samples or 10
				local colorpath=primitives.ColorF:new{}
				for s=1,samples do
					--The random helps with antialias
					pt=(camera.lt + (hdv*(x + math.random())) + (vdv*(y+ math.random())))
					ray=Ray:new{origin=pt,direction=pt-camera.eye}
					ray:normalize()
					local r=self:traceray(ray,1,use_pathtracing)
					colorpath=colorpath+r.color
				end
				self.image[y][x]=colorpath/samples
			end

		end
	end
end

function Raytracer:lighting(res,ray)
	local scene=self.scene
	local light=primitives.ColorF:new{}
	local spec=primitives.ColorF:new{}
	local pt=res.point
	local on=res.normal
	local intensity=0

	--for x=1,100 do
	for i,l in base.pairs(scene.lights) do
		local lp=nil
		if(self.use_pathtracing==1) then lp=l:getrandomlightpoint() else lp=l:getlightpoint() end
		local nray=Ray:new{origin=pt,direction=(lp-pt)};
		local len=nray.direction:normalize()
		local nres=self:traceray(nray,-1,0) --determine shadows

		if (nres.obj==nil or nres.dist>len or nres.obj.islight==1) then
			local int=(nray.direction*on)
			local dp=int*(l.intensity-len)/l.intensity
			light=light+math.max(dp,0)
--					base.print(math.max(dp,0),light.r,light.g,light.b)
			--specular lighting
			local vr=nray.direction - (on*(int*2))
			int=vr*ray.direction
			if(int>0) then
				int=int^20
				spec=spec+(l.color*int)
			end
		end
	end
	--end
	--light=light/100
	--spec=spec/100
	return {lighting=light,specular=spec}  --[1]Lighting, [2]Specular coloring
end

function Raytracer:traceray(ray,level,use_pathtracing)
	local cl_i=0
	local cl_t=0
	local t=0
	local obj=nil
	local scene=self.scene
	local result={}
	local nray=nil

	local objs=self.bvh:traverse(ray)

	for i,o in base.pairs(objs) do
		t=o:intersect(ray)
		if t and (t<cl_t or cl_i==0) then
			cl_t=t
			cl_i=i
			obj=o
		end
	end

	result.obj=obj
	result.color=primitives.ColorF:new{}
	result.dist=cl_t
	result.point=ray.origin + (ray.direction*cl_t)
	result.refraction=1

	if(level>0 and obj~=nil) then
		result.normal=obj:normal(result.point)

		local li=self:lighting(result,ray)
		result.lighting=li.lighting
		result.specular=li.specular

		if obj.islight==1 then
			result.color=obj.color
		else
			result.color=(obj.color*result.lighting) + result.specular
		end

		self.results[level]=result
		if(level<10) then
			if(obj.reflection>0) then
				nray=self:reflection(ray,level)
				result.color=(result.color*(1-obj.reflection)) + (self:traceray(nray,level+1,use_pathtracing).color*obj.reflection)
			end
			if(obj.refraction>0 and obj.color.a<1) then
				result.refraction=obj.refraction
				nray=self:refraction(ray,level)
				if(nray) then
					local refracted=self:traceray(nray,level+1,use_pathtracing)
					local rcol=refracted.color
					if refracted.refraction~=1 then
						--beer's law, apply only on internal reflection
						local absorbance=obj.color*0.15*(-refracted.dist)
						absorbance.a=math.exp(absorbance.a)
						absorbance.r=math.exp(absorbance.r)
						absorbance.g=math.exp(absorbance.g)
						absorbance.b=math.exp(absorbance.b)
						rcol=rcol*absorbance
						--result.color=(result.color*(obj.color.a)) + refracted.color*(1-obj.color.a)
						--result.color=(result.color*(obj.color.a)) +(refracted.color * absorbance)*(1-obj.color.a)
					end
					result.color=(result.color*(obj.color.a)) + rcol*(1-obj.color.a)
				end
			end
		end
		--[[
		if use_pathtracing==1 then
		if(obj.islight==0 and level==1) then
				local samples=10
				local colorpath=ColorF:new{}
				local sc=1
				for s=1,samples do
					local rand_ray=Ray:new{}
					--Get only rays directed to the upper half hemisphere of the collision point, the normal indicates the north
					repeat
						rand_ray.direction.x=math.random(-100000,100000)
						rand_ray.direction.y=math.random(-100000,100000)
						rand_ray.direction.z=math.random(-100000,100000)
						rand_ray:normalize()
					until (result.normal * rand_ray.direction)>0

					rand_ray.origin=result.point  + (result.normal*0.01)
					local rc=self:traceray(rand_ray,level+1,0)
					if(rc.obj~=nil and rc.obj~=result.obj) then
						colorpath=colorpath + rc.color
						sc=sc+1
					end
				end
				result.color=result.color + (colorpath/sc)
			end
		end
		]]
		if use_pathtracing==1  and level<10 then
			local rand_ray=Ray:new{}
			local dotp=0
			--Get only rays directed to the upper half hemisphere of the collision point, the normal indicates the north
			repeat
				rand_ray.direction.x=math.random(-100000,100000)
				rand_ray.direction.y=math.random(-100000,100000)
				rand_ray.direction.z=math.random(-100000,100000)
				rand_ray:normalize()
				dotp=result.normal * rand_ray.direction
			until (dotp>=0)
			rand_ray.origin=result.point  + (result.normal*0.0001)
			level=level+1
			local rc=self:traceray(rand_ray,level,use_pathtracing)
			if(rc.obj~=nil and rc.obj~=result.obj) then
				if dotp<0 then dotp=0 end
				result.color=result.color+(result.obj.color*(rc.color*dotp)) + (rc.color*dotp*0.2)
			end
		end
	end



	return result
end

function Raytracer:reflection(ray,level) --returns a Ray
	local t=(ray.direction*self.results[level].normal)*2
	local dir=ray.direction-(self.results[level].normal*t)
	local res=Ray:new{}
	dir:normalize()
	res.direction=dir
	res.origin=self.results[level].point + (res.direction*0.0001)
	return res
end

function Raytracer:refraction(ray,level)--returns a Vector3

	local current_index=1 --in case this is the first ray level, refraction index is set to 1.0 (vacuum) as default

	local new_index=self.results[level].refraction

	local n=current_index/new_index
	local t=self.results[level].normal*ray.direction
	local ta=n*n*(1-(t*t))
	local res=nil
	local normal=self.results[level].normal

	if(level>1) then
		current_index=self.results[level-1].refraction
	end


	if(ta<=1) then
		res=Ray:new{}
		if(level>1 and self.results[level-1].obj==self.results[level].obj) then
			normal=normal*-1
			self.results[level].refraction=1.0
		end

		if new_index~= 1 then
			res.direction=(ray.direction*n) - normal*(n+math.sqrt(1-ta))
		else
			res.direction=ray.direction
		end

		res.direction:normalize()
		res.origin=self.results[level].point + (res.direction*0.0001)
	end

	return res
end
