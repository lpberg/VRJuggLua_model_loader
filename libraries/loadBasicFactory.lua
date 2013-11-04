require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

factory = Transform{
	position = {0,0,5},
	orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}),
	scale = ScaleFrom.inches,
	Model(vrjLua.findInModelSearchPath([[../models/basicfactory.ive]]))
}