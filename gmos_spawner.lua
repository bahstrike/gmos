spawnerSpawners = { };
spawnerEnabled = { };

--// gmosSpawnSpawner
--// Spawns a spawner
function gmosSpawnSpawner(userId)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local keypad;
	local exploder;
	local spawner;

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// create the keypad
	keypad = gmosCreateAndRegister("prop_physics", userId, 9);
	_EntPrecacheModel("models/props_lab/keypad.mdl");
	_EntSetModel(keypad, "models/props_lab/keypad.mdl");
	_EntSetPos(keypad, spawnPt);
	_EntSpawn(keypad);


	--// Create the spawner
	spawner = gmosCreateAndRegister("prop_physics", userId, 10);
	_EntPrecacheModel("models/props_c17/streetsign004e.mdl");
	_EntSetModel(spawner, "models/props_c17/streetsign004e.mdl");
	_EntSetPos(spawner, vecAdd(spawnPt, vector3(20.5, 0, 0)));
	_EntSpawn(spawner);

	--// store links
	spawnerSpawners[keypad] = spawner;

	--// Start the spawner keypad as disabled initially
	--gmosDisableSpawner(keypad);
	gmosEnableSpawner(keypad);

	--// success
	return true;
end

--// gmosGetSpawnerSpawner
--// Gets the associated spawner object for the keypad
function gmosGetSpawnerSpawner(keypadId)
	local spawnerId = spawnerSpawners[keypadId];

	if((spawnerId == nil) or (not _EntExists(spawnerId) or (gmosGetEntityType(spawnerId) ~= 10))) then
		return 0;
	else
		return spawnerId;
	end
end

--// gmosIsSpawnerEnabled
--// Determines if a spawner is enabled
function gmosIsSpawnerEnabled(keypadId)
	if(spawnerEnabled[keypadId] == nil) then
		return 0;
	else
		return spawnerEnabled[keypadId];
	end
end

--// gmosEnableSpawner
--// Enables a spawner keypad
function gmosEnableSpawner(keypadId)
	spawnerEnabled[keypadId] = 1;
end

--// gmosDisableSpawner
--// Disables a spawner keypad
function gmosDisableSpawner(keypadId)
	spawnerEnabled[keypadId] = 0;
end

--// gmosActivateSpawner
--// Activates/fires spawner
function gmosActivateSpawner(userId, keypadId)
	local spawnerId = gmosGetSpawnerSpawner(keypadId);

	if(spawnerEnabled[keypadId] ~= 1) then return; end

	if(spawnerId == 0) then
		_EntEmitSound(keypadId, "buttons/button6.wav");

		gmosDisplayResult(userId, "Missing spawner", 3);
	else
		_EntEmitSound(keypadId, "buttons/button3.wav");

		gmosDisplayResult(userId, "Triggering spawner", 0);

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
		--local explosion = _EntCreate("env_explosion");
		--_EntSetKeyValue(explosion, "iMagnitude", "150");
		--_EntSetPos(explosion, _EntGetPos(exploderId));
		--_EntSpawn(explosion);
		--_EntFire(explosion, "Explode", "", 0.3);
	end
end