require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

local factory = Transform{
	orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}),
	scale = ScaleFrom.inches,
	Model(vrjLua.findInModelSearchPath([[../models/basicfactory.ive]]))
}

RelativeTo.World:addChild(factory)