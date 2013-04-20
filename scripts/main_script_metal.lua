require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

--set buttons required for SimSparta
nextBtn = gadget.DigitalInterface("WMButtonRight")
prevBtn = gadget.DigitalInterface("WMButtonLeft")
dragBtn = gadget.DigitalInterface("WMButtonB")
--for scaling action frame at bottom
increaseBtn = gadget.DigitalInterface("WMButtonPlus")
decreaseBtn = gadget.DigitalInterface("WMButtonMinus")

--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
dofile([[libraries\useful_tools.lua]])
--load SimSparta for createManipulatableObject() and SimSparta() - frame action call
dofile([[libraries\SimSparta.lua]])
--add factory model
dofile([[libraries\loadBasicFactory.lua]])
--add lighting to scene
dofile([[libraries\simpleLights.lua]])

local models = {}
local global_position = {2, 1.5, 1.5}

local loadModelPathsFromFile = function(filename)
	local file = assert(io.open(filename, "r"))
	for v in file:lines() do
		model = Transform{Model(v)}
		model_xform = Transform{position = global_position, model}
		table.insert(models, model)
		changeTransformColor(model_xform, getRandomColor())
		RelativeTo.World:addChild(createManipulatableObject(model_xform))
	end
end


local loadOSGsAndIves = function()
	for i, v in pairs(arg) do
		if string.find(v, ".osg") or string.find(v, ".ive") then
			model = Transform{Model(v)}
			model_xform = Transform{position = global_position, model}
			table.insert(models, model)
			changeTransformColor(model_xform, getRandomColor())
			RelativeTo.World:addChild(createManipulatableObject(model_xform))
		elseif  string.find(v, ".txt") then
			loadModelPathsFromFile(v)
		end
	end
end

loadOSGsAndIves()

--adding SimSparted frame action
SimSparta(dragBtn, nextBtn, prevBtn)

-- add frame action for scaling objects 
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
