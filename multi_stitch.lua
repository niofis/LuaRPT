local image=require("image")
local io = require("io")

local file="image"
local count=1
local imgout="image"
local use_png = 0 
local use_ppm = 0

for i,v in pairs(arg) do
	if(v=="-file") then file=arg[i+1] end
	if(v=="-count") then count=0 + arg[i+1] end
	if(v=="-png") then 
		use_png = 1
		imgout=arg[i+1] 
	end
	if(v=="-ppm") then 
		use_ppm = 1
		imgout=arg[i+1] 
	end
end

local datas={}


for i=1,count do
	local fn=file .. "." .. i
	print("Loading file " .. fn)
	datas[i]=image.load(fn)
end

print("Creating image file")

if use_png == 1 then
	local png=require("png")
	png.createnew(datas[1].width,datas[1].height*count)

	for i,d in pairs(datas) do
		for x=0,d.width-1 do
			for y=0,d.height-1 do
				local rgb=d[y][x]
				png.setpixel(x+((i-1)*d.width),y,
					rgb.r,
					rgb.g,
					rgb.b)
			end
		end
	end
	print("Saving...")
	png.save(imgout .. ".png")
	png.release()
	print("Done!")
end

if use_ppm == 1 then
	
	local ppm_magic = "P6"
	local file = io.open(imgout, "wb")
	
	file:write(
		string.format("%s %i %i %i\n",
		ppm_magic,
		datas[1].width,
		datas[1].height*count,
		"255"))

	for i,d in pairs(datas) do
		for y=0,d.height-1 do
			for x=0,d.width-1 do
				local rgb=d[y][x]
				file:write(
				string.char(rgb.r),
				string.char(rgb.g),
				string.char(rgb.b))
			end
		end
	end

	file:close()
--[[
	local data={}
	data.width = datas[1].width*count
	data.heigth = datas[1].height

	for i,d in pairs(datas) do
		for y=0,d.height-1 do
			data[y] = {}
			for x=0,d.width-1 do
				local rgb=d[y][x]
				local c = {}
				c.r = rgb.r / 255
				c.g = rgb.g / 255
				c.b = rgb.b / 255
				data[y][x+((i-1)*d.width)] = c
			end
		end
	end
	image.ppm(imgout, data)
	]]
end

