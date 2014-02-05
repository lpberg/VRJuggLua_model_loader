require "AddAppDirectory"
AddAppDirectory()

--load useful_tools for getRandomColor(), changeTransformColor(), and scaleTransform()
runfile[[main_base.lua]]

modelLoader{
	factory = false,
	metal = false,
	manipulate = false,
	parent = nil,
	scale = 1/100,
	position = nil,
	outToIVE = false,
	hasColor = false,
	outPath = [[C:\Users\lpberg\Desktop\parentTEST.ive]]
}

