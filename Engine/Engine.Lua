local GE = {
	GameObjects = require("Engine/GameObjects"),
	MathFuncs = require("Engine/MathFuncs"),
	Physics = require("Engine/Physics"),
	Rendering = require ("Engine/Rendering"),
	KeyInput = require ("Engine/KeyInput");
	LevelLoader = require ("Engine/LevelLoader");
	Logger = require ("Engine/Logger")
}
GE.DrawRectCenter = GE.Rendering.DrawRectCenter;

GE.GetKeyDown = GE.KeyInput.GetKeyDown;

return GE;
