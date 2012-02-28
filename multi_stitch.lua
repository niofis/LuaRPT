local image=require("image")
local png=require("png")

local file="image"
local count=1
local imgout="image"

for i,v in pairs(arg) do
	if(v=="-file") then file=arg[i+1] end
	if(v=="-count") then count=0 + arg[i+1] end
	if(v=="-png") then imgout=arg[i+1] end
end

local datas={}


for i=1,count do
	local fn=file .. "." .. i
	print("Loading file " .. fn)
	datas[i]=image.load(fn)
end

print("Creating png file")

png.createnew(datas[1].width*count,datas[1].height)

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
