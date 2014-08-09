local os=require("os")

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
img_file="image"
hex_file="image"
procs=1
--Process commandline args
scene="demo"

for i,v in pairs(arg) do
	if(v=="-sdl") then use_sdl=1 end
	if(v=="-v") then print_prog=1 end
	if(v=="-res") then
		res_width=0 + arg[i+1]
		res_height=0 + arg[i+2]
		section_w=res_width
		section_h=res_height
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
		scene=arg[i+1]
	end
	if(v=="-procs") then -- Usage -scene package_name
		procs=0+arg[i+1]
	end
end

--this will prevent the renderer to halt on non even number of processes (except 1)
if procs>1 and procs%2 ~=0 then procs=procs+1 end

if section_w==0 then section_w=res_width end
if section_h==0 then section_h=res_height end

local cmd="start lua render.lua -scene %s -res %u %u"

cmd=string.format(cmd,scene,res_width,res_height)

if(use_sdl==1) then cmd=cmd .. " -sdl" end
if(print_prog==1) then cmd=cmd .. " -v" end

if(use_path_tracing==1) then cmd=cmd .. " -path " .. path_tracing_samples end

local sec_str=" -s %d %d %d %d"

local sh=section_h/procs

for i=0,procs-1 do
	local ns=string.format(sec_str,section_x,section_y + sh*i,section_w,sh)
	ns=ns .. " -hex " .. img_file .. "." .. (i+1)
	ns=cmd .. ns
	os.execute(ns)
	--print(ns)
end

print("\nWhen done run the following command:")
print(string.format("lua multi_stitch.lua  -count %d -file %s -png %s",procs,img_file,img_file))




