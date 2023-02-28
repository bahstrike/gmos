--// Cannon kit object links
cannonkitExploders = { };
cannonkitSpawners = { };
cannonkitEnabled = { };

--// gmosSpawnCannonKit
--// Spawns a cannon kit
function gmosSpawnCannonKit(userId)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local keypad;
	local exploder;
	local spawner;

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// create the keypad
	keypad = gmosCreateAndRegister("prop_physics", userId, 3); --_EntCreate("prop_physics");
	_EntPrecacheModel("models/props_lab/keypad.mdl");
	_EntSetModel(keypad, "models/props_lab/keypad.mdl");
	_EntSetPos(keypad, spawnPt);
	--gmosRegisterEntity(keypad, 3);
	_EntSpawn(keypad);

	--// Create the exploder
	exploder = gmosCreateAndRegister("prop_physics", userId, 4); --_EntCreate("prop_physics");
	_EntPrecacheModel("models/weapons/w_grenade.mdl");
	_EntSetModel(exploder, "models/weapons/w_grenade.mdl");
	_EntSetPos(exploder, vecAdd(spawnPt, vector3(-10.5, 0, 0)));
	--gmosRegisterEntity(exploder, 4);
	_EntSpawn(exploder);

	--// Create the spawner
	spawner = gmosCreateAndRegister("prop_physics", userId, 5); --_EntCreate("prop_physics");
	_EntPrecacheModel("models/props_c17/streetsign004e.mdl");
	_EntSetModel(spawner, "models/props_c17/streetsign004e.mdl");
	_EntSetPos(spawner, vecAdd(spawnPt, vector3(20.5, 0, 0)));
	--gmosRegisterEntity(spawner, 5);
	_EntSpawn(spawner);

	--// store links
	cannonkitExploders[keypad] = exploder;
	cannonkitSpawners[keypad] = spawner;

	--// Start the cannon keypad as disabled initially
	gmosDisableCannon(keypad);

	--// success
	return true;
end

--// gmosGetCannonExploder
--// Gets the associated exploder object for the keypad
function gmosGetCannonExploder(keypadId)
	local exploderId = cannonkitExploders[keypadId];

	if((exploderId == nil) or (not _EntExists(exploderId) or (gmosGetEntityType(exploderId) ~= 4))) then
		return 0;
	else
		return exploderId;
	end
end

--// gmosGetCannonSpawner
--// Gets the associated spawner object for the keypad
function gmosGetCannonSpawner(keypadId)
	local spawnerId = cannonkitSpawners[keypadId];

	if((spawnerId == nil) or (not _EntExists(spawnerId) or (gmosGetEntityType(spawnerId) ~= 5))) then
		return 0;
	else
		return spawnerId;
	end
end

--// gmosIsCannonEnabled
--// Determines if a cannon is enabled
function gmosIsCannonEnabled(keypadId)
	if(cannonkitEnabled[keypadId] == nil) then
		return 0;
	else
		return cannonkitEnabled[keypadId];
	end
end

--// gmosEnableCannon
--// Enables a cannon keypad
function gmosEnableCannon(keypadId)
	cannonkitEnabled[keypadId] = 1;
end

--// gmosDisableCannon
--// Disables a cannon keypad
function gmosDisableCannon(keypadId)
	cannonkitEnabled[keypadId] = 0;
end

--// gmosActivateCannon
--// Activates/fires cannon
function gmosActivateCannon(userId, keypadId)
	local exploderId = gmosGetCannonExploder(keypadId);
	local spawnerId = gmosGetCannonSpawner(keypadId);

	if(cannonkitEnabled[keypadId] ~= 1) then return; end

	if((exploderId == 0) or (spawnerId == 0)) then
		_EntEmitSound(keypadId, "buttons/button6.wav");

		gmosDisplayResult(userId, "Missing exploder and/or spawner", 3);
	else
		_EntEmitSound(keypadId, "buttons/button3.wav");

		gmosDisplayResult(userId, "Firing Cannon", 0);

		--// Create the ammo
		local ammo = _EntCreate("prop_physics");
		_EntPrecacheModel("models/props_c17/oildrum001_explosive.mdl");
		_EntSetModel(ammo, "models/props_c17/oildrum001_explosive.mdl");
		_EntSetAng(ammo, _EntGetAng(spawnerId));
		_EntSetPos(ammo, _EntGetPos(spawnerId));
--		_EntSetKeyValue(ammo, "damage", 100);
		_EntSpawn(ammo);
		_EntFire(ammo, "Sethealth", "100", " ");
		_EntFire(ammo, "addoutput", "exploderadius 150", 0);
		_EntFire(ammo, "addoutput", "explodedamage 150", 0);

		--// Create the explosion
		local explosion = _EntCreate("env_explosion");
		_EntSetKeyValue(explosion, "iMagnitude", "150");
		_EntSetPos(explosion, _EntGetPos(exploderId));
		_EntSpawn(explosion);
		_EntFire(explosion, "Explode", "", 0.3);
	end
end