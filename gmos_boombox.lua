gmosBoomboxSongs = { };

--// Spawns some food
function gmosSpawnBoombox(userId, song)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local boombox;

	local boomboxMdl;

	boomboxMdl = "models/props_lab/citizenradio.mdl";

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// precache model
	_EntPrecacheModel(boomboxMdl);

	--// create the boombox
	boombox = gmosCreateAndRegister("prop_physics", userId, 15);
	_EntSetModel(boombox, boomboxMdl);
	_EntSetPos(boombox, spawnPt);
	_EntSpawn(boombox);

	--// set the boombox song
	gmosBoomboxSongs[boombox] = song;

	--// success
	return true;
end

--// handles 'eating' food
function gmosActivateBoombox(userId, entityId)
	_EntEmitSound(entityId, gmosBoomboxSongs[entityId]);

	--// success
	return true;
end