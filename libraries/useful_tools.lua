-- Useful tools and various functions - partial version for VRJuggLua_model_loader
require("osgFX")
require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

getRandomColor = coroutine.wrap(function()
	while true do
		coroutine.yield({98/255,192/255,220/255})
		coroutine.yield({188/255,166/255,142/255})
		coroutine.yield({54/255,99/255,120/255})
		coroutine.yield({0/255,120/255,173/255})
		coroutine.yield({237/255,160/255,167/255})
		coroutine.yield({30/255,213/255,89/255})
		coroutine.yield({228/255,161/255,70/255})
		coroutine.yield({125/255,125/255,0})
		coroutine.yield({199/255,74/255,108/255})
		coroutine.yield({255/255,105/255,51/255})
		coroutine.yield({110/255,166/255,191/255})
		coroutine.yield({128/255,63/255,67/255})
		coroutine.yield({218/255,202/255,143/255})
		coroutine.yield({239/255,107/255,69/255})
		coroutine.yield({125/255,0,0})
		coroutine.yield({92/255,129/255,88/255})
		coroutine.yield({102/255,153/255,254/255})
		coroutine.yield({255/255,103/255,204/255})
		coroutine.yield({0,125/255,0})
		coroutine.yield({0,0,125/255})
		coroutine.yield({102/255,51/255,1})
		coroutine.yield({255/255,251/255,102/255})
		coroutine.yield({0/255,51/255,102/255})
		coroutine.yield({239/255,107/255,69/255})
		coroutine.yield({223/255,69/255,101/255})
		coroutine.yield({255/255,128/255,192/255})
		coroutine.yield({51/255,51/255,51/255})
		coroutine.yield({204/255,153/255,104/255})
	end
end)

function addToWorld(xform)
	RelativeTo.World:addChild(xform)
end

function wrapTransformInBlueScribeSwitch(xform)
	local switch = osg.Switch()
	local scribe = osgFX.Scribe()
	scribe:setWireframeColor(osg.Vec4f(0, 0, 1, 1))
	switch:addChild(xform)
	switch:addChild(scribe)
	scribe:addChild(xform)
	switch:setSingleChildOn(0)
	return switch
end

function wrapTransformInMatrixTransform(xform)
	local MT = osg.MatrixTransform()
	MT:addChild(xform)
	return MT
end

local getRoomToWorld = function()
	return RelativeTo.World:getInverseMatrix()
end

--- This is a HIDEOUS HACK @todo
local matrixMult = function(a, b)
	local copyOfA = osg.Matrixd(a)
	copyOfA:preMult(b)
	return copyOfA
end

local transformMatrixRoomToWorld = function(m)
	return matrixMult(getRoomToWorld(), m)
end

function changeTransformColor(xform, color)
	local mat = osg.Material()
	mat:setColorMode(0x1201);
	mat:setAmbient (0x0408, osg.Vec4(color[1], color[2], color[3], 1.0))
	mat:setDiffuse (0x0408, osg.Vec4(0.2, 0.2, 0.2, 1.0))
	mat:setSpecular(0x0408, osg.Vec4(0.2, 0.2, 0.2, 1.0))
	mat:setShininess(0x0408, 1)
	local ss = xform:getOrCreateStateSet()
	ss:setAttributeAndModes(mat, osg.StateAttribute.Values.ON+osg.StateAttribute.Values.OVERRIDE);
end

function scaleTransform(node,scale)
	node:setScale(osg.Vec3d(scale,scale,scale))
end