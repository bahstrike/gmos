--// Food type
--//  0 - Watermelon, give health
--//  1 - Poison, reduce health
--//  2 - Redbull, increase max speed

gmosFoodType = { };

--// Spawns some food
function gmosSpawnFood(userId, foodType)
	local spawnPt = gmosPlayerPickPosition(userId, 1024);
	local food;

	local foodMdl;

	--// decide what type of food
	if(foodType == 0) then
		foodMdl = "models/props_junk/watermelon01.mdl";
	elseif(foodType == 1) then
		foodMdl = "models/props_junk/garbage_glassbottle001a.mdl";
	elseif(foodType == 2) then
		foodMdl = "models/props_junk/glassjug01.mdl";
	else
		return false;
	end

	if(spawnPt == vector3(0,0,0)) then return false; end

	--// precache models
	_EntPrecacheModel(foodMdl);

	--// create the food
	food = gmosCreateAndRegister("prop_physics", userId, 8);
	_EntSetModel(food, foodMdl);
	_EntSetPos(food, spawnPt);
	_EntSpawn(food);

	--// set the food type
	gmosFoodType[food] = foodType;

	--// success
	return true;
end

--// handles 'eating' food
function gmosHandleFood(userId, entityId)
	local foodType = gmosFoodType[entityId];

	if(foodType == 0) then
		--// watermelon, heal
		_PlayerSetHealth(userId, _PlayerInfo(userId, "health") + 45);
		gmosDisplayResult(userId, "Mmm, tasty!", 0);
	elseif(foodType == 1) then
		--// poison, hurt
		local hlth = _PlayerInfo(userId, "health") - 99;
		if(hlth > 0) then
			_PlayerSetHealth(userId, hlth);
			gmosDisplayResult(userId, "Yuck, poison!", 1);
		else
			_PlayerKill(userId);
			gmosDisplayResult(userId, "Aghhh, poison!", 2);
		end
	elseif(foodType == 2) then
		--// red bull, increase speed
		_PlayerSetMaxSpeed(userId, 3000.0);
		gmosDisplayResult(userId, "Wings!", 0);
	end

	--// success
	return true;
end