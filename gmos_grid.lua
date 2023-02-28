--// construct progress members
--// 0 - grid width
--// 1 - grid height
--// 2 - grid depth
--// 3 - spawn pt
--// 4 - cur x
--// 5 - cur y
--// 6 - cur z
--// 7 - timer ID


gmosGrid = { };
gmosConstructProgress = { };

--// Spawns a grid
function gmosSpawnGrid(userId, width, height, depth)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);


	gmosDestroyGrid(userId);

	if(spawnPt == vector3(0,0,0)) then return false; end

	gmosGrid[userId] = { };
	gmosGrid[userId][0] = 1;
	

	gmosConstructProgress[userId] = { };
	gmosConstructProgress[userId][0] = width;
	gmosConstructProgress[userId][1] = height;
	gmosConstructProgress[userId][2] = depth;
	gmosConstructProgress[userId][3] = spawnPt;
	gmosConstructProgress[userId][4] = 0;
	gmosConstructProgress[userId][5] = 0;
	gmosConstructProgress[userId][6] = 0;
	gmosConstructProgress[userId][7] = AddTimer(0.1, 0, gmosConstructGrid, userId);

	--// success
	return true;
end

--// Constructs parts of the grid
function gmosConstructGrid(userId)
	local x;
	local y;
	local z;
	local box;
	local boxMdl;
	local width;
	local height;
	local depth;

	x = gmosConstructProgress[userId][4];
	y = gmosConstructProgress[userId][5];
	z = gmosConstructProgress[userId][6];
	width = gmosConstructProgress[userId][0];
	height = gmosConstructProgress[userId][1];
	depth = gmosConstructProgress[userId][2];

	local boxwidth = 64;
	local boxheight = 64;
	local boxdepth = 64;

	boxMdl = "models/props/de_dust/du_crate_64x64.mdl";
	_EntPrecacheModel(boxMdl);

	--// build piece
	box = gmosCreateAndRegister("prop_physics", userId, 14);
	_EntSetModel(box, boxMdl);
	_EntSetPos(box, vecAdd(gmosConstructProgress[userId][3], vector3(x*boxwidth, y*boxdepth, z*boxheight+boxheight/2)) );
	_EntSpawn(box);
	_phys.EnableMotion(box, false);
	gmosGrid[userId][gmosGrid[userId][0]] = box;
	gmosGrid[userId][0] = gmosGrid[userId][0] + 1;


	--// increment
	x = x+1;
	if(x == width) then
		x = 0;
		y = y+1;
	end
	if(y == height) then
		y = 0;
		z = z+1;
	end
	if(z == depth) then
		--// done
		HaltTimer(gmosConstructProgress[userId][7]);
		gmosConstructProgress[userId] = nil;

		gmosDisplayResult(userId, "Grid Completed", 1);
	else
		gmosConstructProgress[userId][4] = x;
		gmosConstructProgress[userId][5] = y;
		gmosConstructProgress[userId][6] = z;

		gmosDisplayResult(userId, string.format("Grid Progress: %d%%", (gmosGrid[userId][0]-1) / (width*height*depth) * 100), 0);
	end
end

--// Destroys a grid
function gmosDestroyGrid(userId)
	local i;

	if(gmosConstructProgress[userId] == nil) then
		if(gmosGrid[userId] ~= nil) then
			for i=1,gmosGrid[userId][0] do
				gmosDestroyEntity(gmosGrid[userId][i]);
			end

			gmosGrid[userId] = nil;

			gmosDisplayResult(userId, "Grid Destroyed", 1);
		end
	end
end

--// Unregisters a single grid object
function gmosUnregisterGridObject(userId, entityId)
	local i;

	if(gmosGrid[userId] ~= nil) then
		for i=0,gmosGrid[userId][0] do
			if( gmosGrid[userId][i] == entityId ) then
				gmosGrid[userId][i] = nil;
				break;
			end
		end
	end
end