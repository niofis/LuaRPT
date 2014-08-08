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

Version 1.0.1
]]


local math=require("math")
local rt=require("raytracer")
local image=require("image")

local scene=require("demo")

res_width=1280
res_height=720
use_sdl=0
use_png=0
use_hex=0
print_prog=0
use_path_tracing=0
path_tracing_samples=10
section_x=0
section_y=0
section_w=0
section_h=0
img_file="image.png"
hex_file="image.hex"
--Process commandline args

for i,v in pairs(arg) do
	if(v=="-sdl") then use_sdl=1 end
	if(v=="-v") then print_prog=1 end
	if(v=="-res") then
		res_width=0 + arg[i+1]
		res_height=0 + arg[i+2]
	end
	if(v=="-s") then
		section_x=0 + arg[i+1]
		section_y=0 + arg[i+2]
		section_w=0 + arg[i+3]
		section_h=0 + arg[i+4]
	end
	if(v=="-png") then
		use_png=1
		img_file=arg[i+1]
	end
	if(v=="-hex") then
		use_hex=1
		hex_file=arg[i+1]
	end
	if(v=="-path") then
		use_path_tracing=1
		path_tracing_samples=0 + arg[i+1]
	end
	if(v=="-scene") then -- Usage -scene package_name
		scene=require(arg[i+1])
	end
	if(v=="-ppm") then
		use_ppm=1
		img_file=arg[i+1]
	end
end

if section_w==0 then section_w=res_width end
if section_h==0 then section_h=res_height end

if(use_sdl==1) then
	sdl=require("luasdl")
	sdl.setresolution(res_width,res_height)
	sdl.showsurface()
end

if(use_png==1) then
	png=require("png")
	png.createnew(section_w,section_h)
end

scn=scene.load()

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
					png.setpixel(x-section_x,y-section_y,rgb.r,rgb.g,rgb.b)
				end
			end
		end
	end
end

function renderwithupdate()
	local delta=10
	local dy=section_h/delta
	local dx=section_w/delta
	local tm;
	local i=0
	local section={}
	local outs=""

	for sy=section_y,section_y+section_h-1,delta do
		for sx=section_x,section_x+section_w-1,delta do
			tm=os.clock()
			section={x=sx,y=sy,width=delta,height=delta}
			rtracer:render(section,use_path_tracing,path_tracing_samples)
			i=i+1
			if(print_prog==1) then
				outs="\rSection " ..i.."/" .. (dx*dy) .. " ("..sx..","..sy..") "..delta.."w, "..delta.."h done in "..os.clock() - tm.."s"
				io.stdout:write(outs .. string.rep(" ", 80-#outs))
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
print("\n" .. st .. "s Total")

render.x=section_x
render.y=section_y
render.width=section_w
render.height=section_h

--print("saving...")
--image.save("finalimagedata.txt",render)
--print("done saving!")

if(use_hex==1) then
	io.stdout:write("saving hex...")
	image.save(hex_file,render)
	print("done!")
end

if(use_png==1) then
	io.stdout:write("saving png...")
	png.save(img_file)
	png.release()
	print("done!")
end

if(use_ppm==1) then
	io.stdout:write("saving ppm...")
	image.ppm(img_file, render)
	print("done!")
end

print("all done!")
if(use_sdl==1) then
	sdl.waitclose()
end
