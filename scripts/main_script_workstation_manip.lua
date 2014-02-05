require "AddAppDirectory"
AddAppDirectory()

--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
runfile[[main_base.lua]]

modelLoader{
	factory = false,
	metal = false,
	manipulate = true,
	parent = nil,
	scale = 1/100,
	position = nil,
	hasColor = false,
	outToIVE = false,
	outPath = nil -- must be defined if outToIVE is true
}

