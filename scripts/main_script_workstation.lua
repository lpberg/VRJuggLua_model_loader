require "AddAppDirectory"
AddAppDirectory()

-- local useMETaLSettings = true

if useMETaLSettings then
	print("VRJuggLua_Model_Loader: Loading METaL Settings")
	dragBtn = gadget.DigitalInterface("WMButtonB")
	nextBtn = gadget.DigitalInterface("WMButtonRight")
	prevBtn = gadget.DigitalInterface("WMButtonLeft")
	resetBtn = gadget.DigitalInterface("WMButton1")
	--for scaling action frame at bottom
	increaseBtn = gadget.DigitalInterface("WMButtonPlus")
	decreaseBtn = gadget.DigitalInterface("WMButtonMinus")
	global_pos = {2, 1.5, 1.5}
else
	print("VRJuggLua_Model_Loader: Loading Workstation Settings")
	nextBtn = gadget.DigitalInterface("VJButton0")
	dragBtn = gadget.DigitalInterface("VJButton2")
	prevBtn = gadget.DigitalInterface("VJButton1")
	-- for scaling action frame at bottom - no more buttons!
	increaseBtn = nil
	decreaseBtn = nil
	global_pos = {1, 1.5, .25}
end

local function startSimSparta()
	SimSparta(dragBtn, nextBtn, prevBtn, resetBtn)
end
--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
dofile([[libraries\useful_tools.lua]])
--load SimSparta for createManipulatableObject() and SimSparta() - frame action call
dofile([[libraries\SimSparta.lua]])
--add factory model
dofile([[libraries\loadBasicFactory.lua]])
--add lighting to scene
dofile([[libraries\simpleLights.lua]])

local models = {}

local loadModelPathsFromFileAndCreateManipulatables = function(a)
	local file = assert(io.open(a.filename, "r"))
	local parent = a.parent or RelativeTo.World
	local my_position = a.position = global_pos
	local my_scale = a.scale or 1
	for v in file:lines() do
		if  string.find(v, ".txt") then
			loadModelPathsFromFileAndCreateManipulatables(v)
		else
			model = Transform{Model(v)}
			model_xform = Transform{position = my_position, model}
			table.insert(models, model)
			changeTransformColor(model_xform, getRandomColor())
			parent:addChild(createManipulatableObject(model_xform))
		end
	end
end


local loadModelsAndCreateManipulatables = function(a)
	for i, v in pairs(arg) do
		if  string.find(v, ".txt") then
			loadModelPathsFromFileAndCreateManipulatables(v)
		else
			local parent = a.parent or RelativeTo.World
			local my_position = a.position = global_pos
			local my_scale = a.scale or 1
			model = Transform{Model(v)}
			model_xform = Transform{position = my_position, model}
			table.insert(models, model)
			changeTransformColor(model_xform, getRandomColor())
			parent:addChild(createManipulatableObject(model_xform))
		end
	end
	startSimSparta()
end

local loadModelPathsFromFile = function(a)
	local parent = a.parent or RelativeTo.World
	local my_scale = a.scale or 1
	local my_position = a.position = global_pos
	local file = assert(io.open(a.filename, "r"))
	for v in file:lines() do
		model = Transform{position = my_position, scale = my_scale, Model(v)}
		changeTransformColor(model, getRandomColor())
		parent:addChild(model)
	end
end

local loadModels = function(a)
	for i, v in pairs(arg) do
		if  string.find(v, ".txt") then
			loadModelPathsFromFile(v)
		else
			local parent = a.parent or RelativeTo.World
			local my_scale = a.scale or 1
			local my_position = a.position = global_pos
			model = Transform{position = my_position, scale = my_scale, Model(v)}
			changeTransformColor(model, getRandomColor())
			parent:addChild(model)
		end
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

--TODO: pass in with launcher?
function main()
	loadModels({parent = nil, scale = 1, position = nil})
	-- OR
	-- loadModelsAndCreateManipulatables({parent = nil, position = nil, scale = 1})
end
main()
