--// Set up our includes
_OpenScript("strike/gmos_core.lua");

--// Hook into player talk events
function eventPlayerSay (userId, sayText, bTeam)
     --//First we have to split up sayText
     --//sayText would be "<Player>: <text>", but we only want "<text>"
     local text = string.sub(sayText, string.find(sayText, ":") + 2);

     --// Take the first word and set it to the variable 'command'
     local command = string.sub(text, 0, string.find(text, " ")) ;

     --// If text is only one word, then text is equal to command
     if ( text == command ) then --//if there is only 1 word
           return(sayText);
     end

     --// If the command is 'hudmsg ', then proceed
     local message = string.sub(text, string.find(text, " ") + 1) ;

     if (command == "gmos ") then 
	     --// Split the rest of the text up into a sub-command, and a message that encapsulates the rest of the string
     	     local subcommand = string.sub(message, 0, string.find(message, " ") - 1);
	     local submessage = string.sub(message, string.len(subcommand) + 2, string.len(message));

	     --// have gmos handle the command
           gmosDoCommand(userId, subcommand, submessage);

           --//To block the actual chat message, we return ""
           return(" ");
     end

     --//If there is no "hudmsg" then return the normal chat message
     return(sayText);
end

--// Hook in to when players spawn objects
function onPhysFreeze(userId, entityId)
	--// If its the cannon keypad then enable it
	if(gmosGetEntityType(entityId) == 3) then
		gmosEnableCannon(entityId);
		gmosDisplayResult(userId, "Enabling keypad", 0);
	else
		gmosDisplayResult(userId, string.format("%s frozen", gmosEntityTypes[gmosGetEntityType(entityId)]), 0);
	end

	return true;
end

--// Hook in to when props are broken
function eventPropBreak(userId, entityId)
	--// if its food, handle it
	if(gmosGetEntityType(entityId) == 8) then
		gmosHandleFood(userId, entityId);
	end

	gmosPreDestroyEntity(entityId);

	return true;
end

--// Hook in to when players attempt to spawn props
function eventPlayerSpawnProp(userId, propName)
	if( ((_CurTime() - gmosLastSpawnTime[userId]) <= 1) or (gmosViolations[userId] >= 10) ) then
		gmosRegisterViolation(userId);
		return false;
	end

	gmosLastSpawnTime[userId] = _CurTime();

	return true;
end

--// Hook in to when players spawn props
function eventPlayerPropSpawned(userId, entityId)
	--// Register the owner with the prop
	gmosSetCreator(entityId, userId);
	--gmosRegisterEntity(entityId, 11);

	gmosDisplayResult(userId, "Registered prop", 0);
end

--// Hook in to when players spawn ragdolls
function eventPlayerRagdollSpawned(userId, entityId)
	--// Register the owner with the ragdoll
	gmosSetCreator(entityId, userId);

	gmosDisplayResult(userId, "Registered ragdoll", 0);
end

--// Hook in to when players remove objects
function onPlayerRemove(userId, entityId)
	local entType = gmosGetEntityType(entityId);

	if(entType == 2) then
		gmosDisplayResult(userId, "Can't remove locked objects", 3);

		--// if a player that is not the owner tried to remove the object, issue a violation
		if(not gmosVerifyCreator(entityId, userId)) then
			gmosRegisterViolation(userId);
		end

		return false;
	else
		--// if the type is not regular-ass prop then do an owner check
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			gmosDisplayResult(userId, string.format("Removed %s", gmosGetEntityTypeString(entityId)), 0);

			--// if we were registered then set our type to 0
			--if(entType ~= 0) then
			--	gmosRegisterEntity(entityId, 0);
			--end

			--// if its a grid object, unregister from grid
			if(gmosGetEntityType(entityId) == 14) then
				gmosUnregisterGridObject(userId, entityId);
			end

			gmosPreDestroyEntity(entityId);

			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook in to when player becomes active
function eventPlayerActive (name, userId, steamId)
	gmosDoCommand(userId, "system", "init");
end

--// Hook in to when a player respawns
function eventPlayerSpawn(userId)
	--// If the player violated too many times, make that dumb shit pay
	if(gmosViolations[userId] >= 10) then
		_PlayerFreeze(userId, true);
		_PlayerSetHealth(userId, 1);
		_PlayerRemoveAllWeapons(userId);
		_PlayerDisableAttack(userId, true);
		_PlayerLockInPlace(userId, true);
	end
end

--// Hook in to when player activates an entity
function eventPlayerUseEntity(userId, entity)
	gmosActivateEntity(userId, entity);
end

--// Hook into physics gun pickups
function onPhysPickup(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		--// if the type is not regular-ass prop then do an owner check
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			--// If we are moving the cannon keypad, then disable it
			if(gmosGetEntityType(entityId) == 3) then
				gmosDisableCannon(entityId);
				gmosDisplayResult(userId, "Disabling keypad", 0);
			end

			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook into gravity gun punts
function onGravGunPunt(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook into gravity gun pickups
function onGravGunPickup(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook into gravity gun drops
function onGravGunDrop(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook into gravity gun launches
function onGravGunLaunch(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		if((gmosGetEntityType(entityId) == 0) or gmosVerifyCreator(entityId, userId)) then
			return true;
		else
			--// we dont have access to mess with it! take that, damn mingebags!
			gmosDisplayResult(userId, "Can't disturb", 3);
			gmosRegisterViolation(userId);

			return false;
		end
	end
end

--// Hook into physics gun drops
function onPhysDrop(userId, entityId)
	if(gmosGetEntityType(entityId) == 2) then
		return false;
	else
		return true;
	end
end

--///// CODE ENTRY

--// present the users with a startup message
_ScreenText(0, string.format("BAH %s Startup\n2005 Bad Ass Hackers", gmosGetTag()), -1, 0.3, 200, 128, 0, 255, 1.0, 0.3, 1.7, 0, 0);
_PrintMessageAll(3, "GMOS>> Say 'gmos system init' to begin");