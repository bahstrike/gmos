--// Fieldgate info
--//  0 - Deactivated
--//  1 - Activated

gmosFieldGateInfo = { };
gmosFieldGatePost = { };
gmosFieldGateLogic = { };
gmosFieldGateBeam = { };

--// gmosSpawnFieldGate
--// Spawns a field gate and control
function gmosSpawnFieldGate(userId)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local control;
	local postPos;
	local post = { };
	local logic = { };
	local beam = { };

	local postMdl = "models/props_c17/signpole001.mdl";
	local controlMdl = "models/props_lab/citizenradio.mdl";
	local postPosMdl = "models/props_junk/Rock001a.mdl";

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// precache models
	_EntPrecacheModel(postMdl);
	_EntPrecacheModel(controlMdl);
	_EntPrecacheModel(postPosMdl);

	--// create the control
	control = gmosCreateAndRegister("prop_physics", userId, 7); --_EntCreate("prop_physics");
	_EntSetModel(control, controlMdl);
	_EntSetPos(control, spawnPt);
	--gmosRegisterEntity(control, 7);
	_EntSpawn(control);

	--// create the post positioner
	postPos = gmosCreateAndRegister("prop_physics", userId, 0); --_EntCreate("prop_physics");
	_EntSetModel(postPos, postPosMdl);
	_EntSetPos(postPos, vecAdd(spawnPt, vector3(0, 0, 90)));

	--// create the post A
	post[0] = gmosCreateAndRegister("prop_physics", userId, 6); --_EntCreate("prop_physics");
	_EntSetModel(post[0], postMdl);
	_EntSetPos(post[0], vecAdd(spawnPt, vector3(-30, 0, -10)));
	--gmosRegisterEntity(post[0], 6);

	--// create the post B
	post[1] = gmosCreateAndRegister("prop_physics", userId, 6); --_EntCreate("prop_physics");
	_EntSetModel(post[1], postMdl);
	_EntSetPos(post[1], vecAdd(spawnPt, vector3(30, 0, -10)));
	--gmosRegisterEntity(post[1], 6);

	--// Spawn the posts
	_EntSpawn(post[0]);
	_EntSpawn(post[1]);
	_EntSpawn(postPos);

	--// Weld the posts
	WeldEntities(post[0], post[1]);
	WeldEntities(post[0], postPos);
	WeldEntities(post[1], postPos);

	--// Store the posts
	gmosFieldGatePost[control] = { };
	gmosFieldGatePost[control][0] = post[0];
	gmosFieldGatePost[control][1] = post[1];

	--// Set laser info to off
	gmosFieldGateInfo[control] = 0;

	--// success
	return true;
end

--// gmosFieldGateGetPost
--// Gets a fieldgate post
function gmosFieldGateGetPost(controlId, postId)
	if(gmosFieldGatePost[controlId] == nil) then
		return 0;
	elseif(gmosFieldGatePost[controlId][postId] == nil) then
		return 0;
	else
		return gmosFieldGatePost[controlId][postId];
	end
end

--// gmosActivateLaser
--// Turns on a laser
function gmosActivateFieldGate(userId, controlId)
	if(gmosFieldGateInfo[controlId] == 1) then return; end

	--// get posts and make sure they are valid
	local postA = gmosFieldGateGetPost(controlId, 0);
	local postB = gmosFieldGateGetPost(controlId, 1);
	if((postA == 0) or (postB == 0)) then return; end

	gmosFieldGateInfo[controlId] = 1;

	_EntEmitSound(controlId, "buttons/button9.wav");

	gmosDisplayResult(userId, "FieldGate activated", 0);

	--// find target position
	local targetPos = _EntGetPos(postB); --gmosEntityPickPosition(postA, 1024, vecSub());
	local sourcePos = _EntGetPos(postA);

	--// offset target/source positions a little closer to each other so they dont hit the damn posts
	local vec = vecNormalize(vecSub(targetPos, sourcePos));
	local offsetAmt = vector3(2, 2, 2);
	targetPos = vecSub(targetPos, vecMul(vec, offsetAmt));
	sourcePos = vecAdd(sourcePos, vecMul(vec, offsetAmt));

	--// Create the 3 laser beams
	gmosFieldGateLogic[controlId] = { };
	gmosFieldGateBeam[controlId] = { };
	local i;
	local logic;
	local beam;
	local heightStep = 30;
	local height = heightStep - 5;
	for i=0,2 do
		--// Create laser logic
		logic = _EntCreate("info_target");
		_EntSetKeyValue(logic, "targetname", "NULL" .. logic);
		_EntSetPos(logic, vecAdd(sourcePos, vector3(0, 0, height)));
		_EntSpawn(logic);

		--// Create laser beam
		beam = _EntCreate("env_laser");
		_EntSetPos(beam, vecAdd(targetPos, vector3(0, 0, height)));
		_EntSetKeyValue(beam, "renderamt", "150");
		_EntSetKeyValue(beam, "rendercolor", "150 30 30");
		_EntSetKeyValue(beam, "texture", "sprites/laserbeam.spr");
		_EntSetKeyValue(beam, "TextureScroll", "15");
		_EntSetKeyValue(beam, "targetname", "gmp_laser" .. beam);
		_EntSetKeyValue(beam, "parentname", "");
		_EntSetKeyValue(beam, "damage", "350");
		_EntSetKeyValue(beam, "spawnflags", "1");
		_EntSetKeyValue(beam, "width", "2");
		_EntSetKeyValue(beam, "dissolvetype", "None");
		_EntSetKeyValue(beam, "EndSprite", "");
		_EntSetKeyValue(beam, "LaserTarget", "NULL" .. logic);
		_EntSetKeyValue(beam, "TouchType", "0");
		_EntSpawn(beam);

		--// store the entities
		gmosFieldGateLogic[controlId][i] = logic;
		gmosFieldGateBeam[controlId][i] = beam;

		--// increment height
		height = height + heightStep;
	end
end

--// gmosDeactivateLaser
--// Turns off a laser
function gmosDeactivateFieldGate(userId, controlId)
	if(gmosFieldGateInfo[controlId] == 0) then return; end

	gmosFieldGateInfo[controlId] = 0;

	_EntEmitSound(controlId, "buttons/button19.wav");

	gmosDisplayResult(userId, "FieldGate deactivated", 0);

	--// Go through and remove the laser beam entities
	local i;
	for i=0,2 do
		if(gmosFieldGateLogic[controlId] ~= nil) then
			if(gmosFieldGateLogic[controlId][i] ~= nil) then
				_EntRemove(gmosFieldGateLogic[controlId][i]);
			end
		end

		if(gmosFieldGateBeam[controlId] ~= nil) then
			if(gmosFieldGateBeam[controlId][i] ~= nil) then
				_EntRemove(gmosFieldGateBeam[controlId][i]);
			end
		end
	end

	--// clear our references
	gmosFieldGateLogic[controlId] = nil;
	gmosFieldGateBeam[controlId] = nil;
end

--// gmosToggleLaser
--// Toggle the laser
function gmosToggleFieldGate(userId, controlId)
	if(gmosGetEntityType(controlId) ~= 7) then return; end

	if(gmosFieldGateInfo[controlId] == 0) then
		gmosActivateFieldGate(userId, controlId);
	else
		gmosDeactivateFieldGate(userId, controlId);
	end
end