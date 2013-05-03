require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

local filename = string.match(getScriptFilename(), "(.-)([^\\]-([^%.]+))$") .. "models_sparta.lua"
local outfile = assert(io.open(filename, "w"))
local filestr = ""

--recursive function to strip of the beginning and extension of paths
local function stripPathAndExtension(str)
	slash_location = string.find(str, '\\')
	if slash_location == nil then
		str = string.gsub(str, " ", "")
		str = string.gsub(str, "-", "_")
		str = string.gsub(str, "__", "_")
		str = string.gsub(str, ".osg", "")
		str = string.gsub(str, ".ive", "")
		str = string.gsub(str, ".STL", "")
		str = string.gsub(str, ".stl", "")
		return str
	else
		return stripPathAndExtension(string.sub(str, slash_location + 1))
	end
end


local introStr = [[
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
params = defineSimulationParameters{
	maxStiffness = 300.0
}

]]

local posStr = [[
local global_position = {0, 0, 0}
local global_orientation = AngleAxis(Degrees(0), Axis{0.0, 0.0, 0.0})
local global_voxelsize = .003
local global_scale = 1.0
local global_density = 5

]]

filestr = filestr .. introStr .. posStr

outfile:write(filestr)

local function transformString(path)
	local transform_name = stripPathAndExtension(path)
	local s = transform_name..[[ = Transform{
	scale = global_scale,
	orientation = global_orientation,
	Model(]].."[[".. path .."]]".."),".."\n"..[[
}

]]..transform_name.."_sparta"..[[ = addObject{
	position = global_position,
	voxelsize = global_voxelsize,
	density = global_density,
	]]..transform_name..[[,
}

-----------------------------------------------------------
	]]
	return s
end

local loadModelPathsFromFile = function(filename)
	local file = assert(io.open(filename, "r"))
	for v in file:lines() do
		outfile:write(transformString(v))
	end
end

local loadOSGsAndIves = function()
	for i, v in pairs(arg) do
		if string.find(v, ".osg") or string.find(v, ".ive") then
			outfile:write(transformString(v))
			outfile:write("\n")
		elseif string.find(v, ".txt") then
			loadModelPathsFromFile(v)
		end
	end
	
end

local function writeSimCall() 
	outfile:write("\n".."simulation:startInSchedulerThread()")
end

loadOSGsAndIves()
writeSimCall()
outfile:close()
print("Sparta Script created!...closing")
vrjKernel.stop()


