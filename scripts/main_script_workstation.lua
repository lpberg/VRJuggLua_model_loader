require "AddAppDirectory"
AddAppDirectory()

--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
runfile[[../libraries/useful_tools.lua]]
--load SimSparta for createManipulatableObject() and SimSparta() - frame action call
runfile([[../libraries/SimSparta.lua]])
--add factory model
runfile([[../libraries/loadBasicFactory.lua]])
-- RelativeTo.World:addChild(factory)
--add lighting to scene
runfile([[../libraries/simpleLights.lua]])

local models = {}

manipulate = false
useMETaLButtons = false

if useMETaLButtons then
	print("VRJuggLua_Model_Loader: Loading METaL Buttons")
	dragBtn = gadget.DigitalInterface("WMButtonB")
	nextBtn = gadget.DigitalInterface("WMButtonRight")
	prevBtn = gadget.DigitalInterface("WMButtonLeft")
	resetBtn = gadget.DigitalInterface("WMButton1")
	--for scaling action frame at bottom
	increaseBtn = gadget.DigitalInterface("WMButtonPlus")
	decreaseBtn = gadget.DigitalInterface("WMButtonMinus")
	global_pos = {2, 1.5, 1.5}
else
	print("VRJuggLua_Model_Loader: Loading Workstation Buttons")
	nextBtn = gadget.DigitalInterface("VJButton0")
	dragBtn = gadget.DigitalInterface("VJButton2")
	prevBtn = gadget.DigitalInterface("VJButton1")
	-- for scaling action frame at bottom - no more buttons!
	increaseBtn = nil
	decreaseBtn = nil
	global_pos = {1, 1.5, .25}
end

local function CenterTransformAtPosition(name,pos)
    local bound = name:getBound()
    return Transform{
        position = -bound:center()+Vec(unpack(pos));
        name
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

local loadModelPathsFromFile = function(a)
	local parent = Transform{}
	local my_scale = a.scale or 1
	local my_position = a.position or global_pos
	local file = assert(io.open(a.filename, "r"))
	for v in file:lines() do
		v = trim(v)
		if isAcceptableFileType(v) then
			if manipulate then
				model = Transform{scale = my_scale, Model(v)}
				model_xform = Transform{position = my_position, model}
				table.insert(models, model)
				changeTransformColor(model_xform, getRandomColor())
				parent:addChild(createManipulatableObject(model_xform))
			else
				print(v)
				model = Transform{position = my_position, scale = my_scale, Model(v)}
				changeTransformColor(model, getRandomColor())
				parent:addChild(model)
			end
		end
	end
	if parent:getNumChildren() > 0 then
		RelativeTo.World:addChild(CenterTransformAtPosition(parent,my_position))
	end
end

local loadModels = function(a)
	local parent = Transform{}
	local my_scale = a.scale or 1
	local my_position = a.position or global_pos
	for i, v in pairs(arg) do
		if string.find(v, ".txt") then
			loadModelPathsFromFile({filename = v})
		else
			if isAcceptableFileType(v) then
				if manipulate then
					model = Transform{scale = my_scale, Model(v)}
					model_xform = Transform{position = my_position, model}
					table.insert(models, model)
					changeTransformColor(model_xform, getRandomColor())
					parent:addChild(createManipulatableObject(model_xform))
				else
					model = Transform{position = my_position, scale = my_scale, Model(v)}
					changeTransformColor(model, getRandomColor())
					parent:addChild(model)
				end
			end
		end
	end
	if parent:getNumChildren() > 0 then
		RelativeTo.World:addChild(CenterTransformAtPosition(parent,my_position))
	end
	if manipulate then
		SimSparta(dragBtn, nextBtn, prevBtn, resetBtn)
	end
end

local function addScalingFrameAction()
	-- only gets added if buttons are defined
	if increaseBtn ~= nil and decreaseBtn ~= nil then
		Actions.addFrameAction(
			function()
				while true do
					if increaseBtn.justPressed then
						for _, v in ipairs(models) do
							scaleTransform(v, v:getScale():x() * 1.05)
						end
					end
					if decreaseBtn.justPressed then
						for _, v in ipairs(models) do
							scaleTransform(v, v:getScale():x() * 0.95)
						end
					end
					Actions.waitForRedraw()
				end
			end
		)
	end
end
addScalingFrameAction()

loadModels({parent = nil, scale = 1, position = nil})

