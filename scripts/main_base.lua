require "AddAppDirectory"
AddAppDirectory()

--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
runfile[[../libraries/useful_tools.lua]]
--add lighting to scene
runfile([[../libraries/simpleLights.lua]])

local function CenterTransformAtPosition(xform, pos)
	local bound = xform:getBound()
	return Transform{
		position = -bound:center() + Vec(unpack(pos)),
		xform,
	}
end

local function isAcceptableFileType(file)
	if string.find(file, ".txt") then
		return true
	elseif string.find(file, ".osg") then
		return true
	elseif string.find(file, ".ive") then
		return true
	elseif string.find(file, ".obj") then
		return true
	elseif string.find(file, ".3ds") then
		return true
	else
		return false
	end
end

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function loadModel(file_name, a)
	print("Adding: ", file_name)
	local model = Transform{position = a.position, scale = a.scale, Model(file_name)}
	if not a.hasColor then
		changeTransformColor(model, getRandomColor())
	end
	if not a.manipulate then
		a.parent:addChild(model)
	end
	table.insert(a.models, model)
end

local function loadModelFilesFromTxtFile(a)
	local file = assert(io.open(a.filename, "r"))
	for v in file:lines() do
		v = trim(v)
		loadModel(v, a)
	end
end

local function loadIndividualModelFiles(a)
	for i, v in pairs(arg) do
		if isAcceptableFileType(v) then
			loadModel(v, a)
		end
	end
end

local function assignButtons(a)
	if a.metal then
		print("VRJuggLua_Model_Loader: Loading METaL Buttons")
		a.dragBtn = gadget.DigitalInterface("WMButtonB")
		a.nextBtn = gadget.DigitalInterface("WMButtonRight")
		a.prevBtn = gadget.DigitalInterface("WMButtonLeft")
		a.resetBtn = gadget.DigitalInterface("WMButton1")
		--for scaling action frame at bottom
		a.increaseBtn = gadget.DigitalInterface("WMButtonPlus")
		a.decreaseBtn = gadget.DigitalInterface("WMButtonMinus")
		a.global_pos = {2, 1.5, 1.5}
	else
		print("VRJuggLua_Model_Loader: Loading Workstation Buttons")
		a.nextBtn = gadget.DigitalInterface("VJButton0")
		a.dragBtn = gadget.DigitalInterface("VJButton2")
		a.prevBtn = gadget.DigitalInterface("VJButton1")
		-- for scaling action frame at bottom - no more buttons!
		a.increaseBtn = nil
		a.decreaseBtn = nil
		a.global_pos = {1, 1.5, .25}
	end
end

local function addScalingFrameAction(a)
-- only gets added if buttons are defined
	if a.increaseBtn and a.decreaseBtn then
		Actions.addFrameAction(
			function()
				while true do
					if a.increaseBtn.justPressed then
						for _, v in ipairs(a.models) do
							scaleTransform(v, v:getScale():x() * 1.05)
						end
					end
					if a.decreaseBtn.justPressed then
						for _, v in ipairs(a.models) do
							scaleTransform(v, v:getScale():x() * 0.95)
						end
					end
					Actions.waitForRedraw()
				end
			end
		)
	end
end

function modelLoader(a)
	if a.manipulate then
		--load SimSparta for createManipulatableObject() and SimSparta()
		runfile([[../libraries/SimSparta.lua]])
	end
	assignButtons(a)
	a.models = {}
	a.parent = a.parent or Transform{}
	a.scale = a.scale or 1
	a.position = a.position or {0, 0, 0}
	local firstArg = arg[1]
	if string.find(firstArg, ".txt") then
		a.filename = firstArg
		loadModelFilesFromTxtFile(a)
	else
		loadIndividualModelFiles(a)
	end
	if a.factory then
		local factory = runfile([[../libraries/loadBasicFactory.lua]])
		a.parent:addChild(factory)
	end
	if a.manipulate then
		SimSparta{
			parent = a.parent,
			models = a.models,
			cycleThroughParts = true,
			dragBtn = a.dragBtn,
			nextBtn = a.nextBtn,
			prevBtn = a.prevBtn,
			resetBtn = a.resetBtn,
		}
	end
	if a.centerPosition then
		a.parent = CenterTransformAtPosition(a.parent, a.centerPosition)
	end
	
	if a.parent:getNumChildren() > 0 then
		RelativeTo.World:addChild(a.parent)
	end
	
	if a.outToIVE and a.outPath then
		osgLua.saveObjectFile(a.parent, a.outPath)
	end
	addScalingFrameAction(a)
end