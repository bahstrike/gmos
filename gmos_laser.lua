--// Laser info
--//  0 - Deactivated laser
--//  1 - Activated laser

gmosLaserInfo = { };
gmosLaserLogic = { };
gmosLaserBeam = { };

--// gmosSpawnLaser
--// Spawns a laser
function gmosSpawnLaser(userId)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local obj;

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// create the object
	obj = gmosCreateAndRegister("prop_physics", userId, 1); --_EntCreate("prop_physics");
	_EntPrecacheModel("models/props_combine/breenclock.mdl");
	_EntSetModel(obj, "models/props_combine/breenclock.mdl");
	_EntSetPos(obj, spawnPt);

	--// register the object with gmos
	--gmosRegisterEntity(obj, 1);

	--// spawn the object
	_EntSpawn(obj);

	--// Set laser info to off
	gmosLaserInfo[obj] = 0;

	--// success
	return true;
end

--// gmosActivateLaser
--// Turns on a laser
function gmosActivateLaser(userId, laser)
	if(gmosLaserInfo[laser] == 1) then return; end

	gmosLaserInfo[laser] = 1;

	_EntEmitSound(laser, "buttons/button17.wav");

	gmosDisplayResult(userId, "Laser activated", 0);

	--// find target position
	local targetPos = gmosEntityPickPosition(laser, 1024, vector3(0, 0, 0));

	--// Create laser logic
	local logic = _EntCreate("info_target");
	_EntSetKeyValue(logic, "targetname", "NULL" .. logic);
	_EntSetPos(logic, _EntGetPos(laser));
	_EntSpawn(logic);

	--// Create laser beam
	local beam = _EntCreate("env_laser");
	_EntSetPos(beam, targetPos);
	_EntSetKeyValue(beam, "renderamt", "100");
	_EntSetKeyValue(beam, "rendercolor", "100 100 255");
	_EntSetKeyValue(beam, "texture", "sprites/laserbeam.spr");
	_EntSetKeyValue(beam, "TextureScroll", "15");
	_EntSetKeyValue(beam, "targetname", "gmp_laser" .. beam);
	_EntSetKeyValue(beam, "parentname", "");
	_EntSetKeyValue(beam, "damage", "35");
	_EntSetKeyValue(beam, "spawnflags", "1");
	_EntSetKeyValue(beam, "width", "3");
	_EntSetKeyValue(beam, "dissolvetype", "None");
	_EntSetKeyValue(beam, "EndSprite", "");
	_EntSetKeyValue(beam, "LaserTarget", "NULL" .. logic);
	_EntSetKeyValue(beam, "TouchType", "0");
	_EntSpawn(beam);

	--// Store laser entities
	gmosLaserLogic[laser] = logic;
	gmosLaserBeam[laser] = beam;
end

--// gmosDeactivateLaser
--// Turns off a laser
function gmosDeactivateLaser(userId, laser)
	if(gmosLaserInfo[laser] == 0) then return; end

	gmosLaserInfo[laser] = 0;

	_EntEmitSound(laser, "buttons/button10.wav");

	gmosDisplayResult(userId, "Laser deactivated", 0);

	--// Destroy linked entities, if they exist
	if(gmosLaserLogic[laser] ~= nil) then
		_EntRemove(gmosLaserLogic[laser]);
		--gmosDestroyEntity(gmosLaserLogic[laser]);
		gmosLaserLogic[laser] = nil;
	end

	if(gmosLaserBeam[laser] ~= nil) then
		_EntRemove(gmosLaserBeam[laser]);
		--gmosDestroyEntity(gmosLaserBeam[laser]);
		gmosLaserBeam[laser] = nil;
	end
end

--// gmosIsLaserActive
--// Is the specified entity an active laser?
function gmosIsLaserActive(entity)
	if((gmosGetEntityType(entity) == 1) and (gmosLaserInfo[entity] == 1)) then
		return true;
	else
		return false;
	end
end

--// gmosToggleLaser
--// Toggle the laser
function gmosToggleLaser(userId, laser)
	if(gmosGetEntityType(laser) ~= 1) then return; end

	if(gmosLaserInfo[laser] == 0) then
		gmosActivateLaser(userId, laser);
	else
		gmosDeactivateLaser(userId, laser);
	end
end