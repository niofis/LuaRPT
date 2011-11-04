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
local image=require("image")

require("demo")

res_width=320
res_height=240
use_sdl=1
use_png=1
print_prog=1
use_path_tracing=1
path_tracing_samples=10

--Process commandline args

for _,v in pairs(arg) do
	if(v=="-sdl") then use_sdl=1 end
	if(v=="-nsdl") then use_sdl=0 end
	if(v=="-v") then print_prog=1 end
	if(v=="-nv") then print_prog=0 end
	if(v=="-i") then use_png=1 end
	if(v=="-ni") then use_png=0 end
end

if(use_sdl==1) then
	sdl=require("luasdl")
	sdl.setresolution(res_width,res_height)
	sdl.showsurface()
end

if(use_png==1) then
	png=require("png")
	png.createnew(res_width,res_height)
end

print("Resolution: " .. res_width .."x"..res_height)
print("Total objects: " .. table.maxn(scn.objects))

render={}
resolution={width=res_width,height=res_height}

rtracer=rt.Raytracer:new{resolution=resolution,scene=scn,image=render}

function copyimage(section,render,isfloat)
	for y=section.y,section.y + section.height-1 do
		for x=section.x,section.x + section.width-1 do
			if(render and render[y] and render[y][x]) then
				local rgb={}
				if isfloat~=1 then
					rgb=render[y][x]
				else
					rgb=render[y][x]:to255()
				end

				if(use_sdl==1) then
					sdl.setpixel(x,y,rgb.r,rgb.g,rgb.b)
				end
				if(use_png==1) then
					png.setpixel(x,y,rgb.r,rgb.g,rgb.b)
				end
			end
		end
	end
end

function renderwithupdate()
	local delta=10
	local dy=res_height/delta
	local dx=res_width/delta
	local tm;
	local i=0
	local section={}

	for sy=0,res_height-1,delta do
		for sx=0,res_width-1,delta do
			tm=os.clock()
			section={x=sx,y=sy,width=delta,height=delta}
			rtracer:render(section,use_path_tracing,path_tracing_samples)
			i=i+1
			if(print_prog==1) then
				print("Section " ..i.."/" .. (dx*dy) .. " ("..sx..","..sy..") "..delta.."w, "..delta.."h done in "..os.clock() - tm.."s")
			end
			if(use_sdl==1) or (use_png==1) then
				copyimage(section,render,1)
			end
		end
	end

end

st=os.clock()
renderwithupdate()
st= os.clock() - st
print(st .. "s Total")

render.width=res_width
render.height=res_height

--print("saving...")
--image.save("finalimagedata.txt",render)
--print("done saving!")

if(use_png==1) then
	print("saving png...")
	png.save("image.png")
	png.release()
	print("done!")
end

print("all done!")
if(use_sdl==1) then
	sdl.waitclose()
end
