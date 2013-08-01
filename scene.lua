local math=require("math")
local rt=require("raytracer")
local pm=require("primitives")

local scene = {}

local function spiral(count,scn)
	local si=2*math.pi/count
	local dx,dy,dz
	dy=0.125

	local morange=pm.Material:new{diffuse=pm.ColorF:new{r=1,g=0.5},specular=1}
	local gspiral=pm.Group:new{material=morange}

	scn:addmaterial(morange)
	scn:addgroup(gspiral)

	for i=1,count do
		dy=dy+0.25
		dx=math.sin(si*i)+2.5
		dz=-math.cos(si*i)
		scn:addobject(pm.Sphere:new{name="spiral"..i,center=pm.Vector3:new{x=dx,y=dy,z=dz},radius=0.35,group=gspiral})
	end
end

function scene.load()
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

	local mblue=pm.Material:new{diffuse=pm.ColorF:new{b=1},specular=1}
	local gblue=pm.Group:new{material=mblue}
	local myellow=pm.Material:new{diffuse=pm.ColorF:new{r=1,g=1},specular=1, reflection = 0.4}
	local gyellow=pm.Group:new{material=myellow}
	local mredglass=pm.Material:new{diffuse=pm.ColorF:new{a=0.5,r=1}, reflection=0.5,refraction=1.491, specular=1}
	local gredglass=pm.Group:new{material=mredglass}
	local mfloor=pm.Material:new{diffuse=pm.ColorF:new{g=0.5,r=0.5,b=0.5}}
	local gfloor=pm.Group:new{material=mfloor}
	local mback=pm.Material:new{diffuse=pm.ColorF:new{b=1, r=0.7372, g=0.9098}}
	local gback=pm.Group:new{material=mback}
	local mlight=pm.Material:new{diffuse=pm.ColorF:new{r=1,g=1,b=1}}
	local glight=pm.Group:new{material=mlight}

	scn:addmaterial(mblue)
	scn:addmaterial(myellow)
	scn:addmaterial(mredglass)
	scn:addmaterial(mfloor)
	scn:addmaterial(mback)
	scn:addmaterial(mlight)

	scn:addgroup(gblue)
	scn:addgroup(gyellow)
	scn:addgroup(gredglass)
	scn:addgroup(gfloor)
	scn:addgroup(gback)
	scn:addgroup(glight)

	scn:addobject(pm.Sphere:new{name="blue",center=pm.Vector3:new{x=0,y=1,z=0},radius=1,group=gblue})
	scn:addobject(pm.Sphere:new{name="yellow",center=pm.Vector3:new{x=-2,y=1,z=1},radius=1,group=gyellow})
	scn:addobject(pm.Sphere:new{name="red-glass",center=pm.Vector3:new{x=-0.5,y=0.5,z=-3},radius=0.5,group=gredglass})

	scn:addobject(pm.Triangle:new{name="floor",p1=pm.Vector3:new{x=-200,y=0,z=200},p2=pm.Vector3:new{x=200,y=0,z=200},p3=pm.Vector3:new{x=0,y=0,z=-20},group=gfloor})
	scn:addobject(pm.Triangle:new{name="back",p1=pm.Vector3:new{x=-200,y=-200,z=50},p3=pm.Vector3:new{x=200,y=-200,z=50},p2=pm.Vector3:new{x=0,y=2000,z=50},group=gback})

	spiral(10,scn)

	--scn.lights[1]=Light:new{color=ColorF:new{r=1,g=1,b=1},position=Vector3:new{x=5,y=5,z=-5},intensity=40}
	--scn.lights[2]=Light:new{color=ColorF:new{r=1,g=1,b=1},position=Vector3:new{x=-5,y=5,z=5},intensity=40}
	--scn.lights[1]=Sphere:new{name="light",center=Vector3:new{x=5,y=5,z=-5},radius=1,color=ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=100}
	--scn.lights[1]=pm.Sphere:new{name="light",center=pm.Vector3:new{x=15,y=50,z=-10},radius=5,color=pm.ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=1000};
	--scn.lights[2]=pm.Sphere:new{name="light2",center=pm.Vector3:new{x=0,y=3,z=-1},radius=0.33,color=pm.ColorF:new{r=1,g=1,b=1,a=1},islight=1,intensity=1}
	local l=pm.Sphere:new{name="light",center=pm.Vector3:new{x=3,y=3,z=-10},radius=0.2,group=glight,islight=1,intensity=1000}
	scn:addobject(l)
	scn:addlight(l)
	--scn:addlight(pm.Triangle:new{name="light2",p1=pm.Vector3:new{x=-4,y=2,z=0},p3=pm.Vector3:new{x=-4,y=3,z=0},p2=pm.Vector3:new{x=-3,y=2,z=0},color=pm.ColorF:new{b=1, r=1, g=1},islight=1,intensity=1000})
	--scn:loadfromms3d("smart.ms3d",{x=0,y=0,z=0})
	return scn
end

return scene
