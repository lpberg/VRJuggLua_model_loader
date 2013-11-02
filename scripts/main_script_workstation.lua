require "AddAppDirectory"
AddAppDirectory()

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
	local my_position = a.position = {1, 1.5, .25}
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
			local my_position = a.position = {1, 1.5, .25}
			local my_scale = a.scale or 1
			model = Transform{Model(v)}
			model_xform = Transform{position = my_position, model}
			table.insert(models, model)
			changeTransformColor(model_xform, getRandomColor())
			parent:addChild(createManipulatableObject(model_xform))
		end
	end
end

local loadModelPathsFromFile = function(a)
	local parent = a.parent or RelativeTo.World
	local my_scale = a.scale or 1
	local file = assert(io.open(a.filename, "r"))
	for v in file:lines() do
		model = Transform{scale = my_scale, Model(v)}
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
			model = Transform{scale = my_scale, Model(v)}
			changeTransformColor(model, getRandomColor())
			parent:addChild(model)
		end
	end
end

function main()
	loadModels()
end
main()

local function startSimSparta()
	nextBtn = gadget.DigitalInterface("VJButton0")
	dragBtn = gadget.DigitalInterface("VJButton2")
	-- prevBtn = gadget.DigitalInterface("VJButton1")
	SimSparta(dragBtn, nextBtn, prevBtn)
end
-- startSimSparta()

local function addScalingFrameAction()
	-- for scaling action frame at bottom - no more buttons!
	-- increaseBtn = 
	-- decreaseBtn = 
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
-- addScalingFrameAction()