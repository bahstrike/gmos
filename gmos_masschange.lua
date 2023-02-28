--// MassChange info
--//  0 - Deactivated
--//  1 - Activated

gmosMassChangeInfo = { };
gmosMassChangeObj = { };
gmosMassChangeMassOn = { };
gmosMassChangeMassOff = { };

--// gmosSpawnMassChange
--// Spawns a mass change object and control
function gmosSpawnMassChange(userId)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local keypad;
	local obj;

	local keypadMdl = "models/props_lab/keypad.mdl";
	local objMdl = "models/props/de_dust/du_crate_64x64.mdl";

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// precache models
	_EntPrecacheModel(keypadMdl);
	_EntPrecacheModel(objectMdl);

	--// create the keypad
	keypad = gmosCreateAndRegister("prop_physics", userId, 12);
	_EntSetModel(keypad, keypadMdl);
	_EntSetPos(keypad, spawnPt);
	_EntSpawn(keypad);

	--// create the masschange object
	obj = gmosCreateAndRegister("prop_physics", userId, 13);
	_EntSetModel(obj, objMdl);
	_EntSetPos(obj, vecAdd(spawnPt, vector3(0, 0, 90)));
	_EntSpawn(obj);

	--// Set mass change info to off
	gmosMassChangeInfo[keypad] = 0;
	gmosMassChangeObj[keypad] = obj;

	--// set default masses
	gmosMassChangeMassOn[keypad] = 300;
	gmosMassChangeMassOff[keypad] = 40;

	--// success
	return true;
end

--// gmosMassChangeOn
--// Changes the mass object's on mass
function gmosMassChangeOn(keypadId, mass)
	gmosMassChangeMassOn[keypadId] = mass;
end

--// gmosMassChangeOn
--// Changes the mass object's off mass
function gmosMassChangeOff(keypadId, mass)
	gmosMassChangeMassOff[keypadId] = mass;
end


--// gmosActivateMassChange
--// Turns on mass object mass
function gmosActivateMassChange(userId, keypadId)
	_EntEmitSound(keypadId, "buttons/button17.wav");
	gmosMassChangeInfo[keypadId] = 1;
	_phys.SetMass(gmosMassChangeObj[keypadId], gmosMassChangeMassOn[keypadId]);

	gmosDisplayResult(userId, "Activated", 0);
end

--// gmosDeactivateMassChange
--// Turns off mass object mass
function gmosDeactivateMassChange(userId, keypadId)
	_EntEmitSound(keypadId, "buttons/button10.wav");
	gmosMassChangeInfo[keypadId] = 0;
	_phys.SetMass(gmosMassChangeObj[keypadId], gmosMassChangeMassOff[keypadId]);

	gmosDisplayResult(userId, "Deactivated", 0);
end


--// gmosToggleMassChange
--// Toggles mass change
function gmosToggleMassChange(userId, keypadId)
	if(gmosMassChangeInfo[keypadId] == 1) then
		gmosDeactivateMassChange(userId, keypadId);
	else
		gmosActivateMassChange(userId, keypadId);
	end
end