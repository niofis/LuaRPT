package.path = package.path .. ';./LuaRPT/?.lua'

local wrkch = love.thread.getChannel("worker")
local serpent=require("serpent")
local scn=wrkch:demand()
local pm=require("primitives")

print(scn)
local scene=loadstring(scn)()
scene=pm.Scene:new(scene)


render={}
resolution={width=res_width,height=res_height}

rtracer=rt.Raytracer:new{resolution=resolution,scene=scene,image=render}

section={x=sx,y=sy,width=delta,height=delta}
			rtracer:render(section,use_path_tracing,path_tracing_samples)