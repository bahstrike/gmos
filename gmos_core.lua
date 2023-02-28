--//  UI CHANNELS USED
--// -------------------
--//  0 - gmos status RECT  background
--//  1 - gmos status TEXT  title/version
--//  2 - gmos status TEXT  result
--//  3 - gmos status TEXT  target info
--//  4 - gmos status TEXT  global result
--//  5 - gmos status TEXT  help

--// 10 - gmos infopop RECT titlebackground
--// 11 - gmos infopop RECT clientbackground
--// 12 - gmos infopop TEXT title
--// 13 - gmos infopop TEXT contents
--// 14 - gmos infopop TEXT close

--// 25 - gmos keypad RECT background
--// 26 - gmos keypad TEXT title and description
--// 27 - gmos keypad RECT curEntry background
--// 28 - gmos keypad TEXT curEntry
--// 29 - gmos keypad RECT 0
--// 30 - gmos keypad RECT 1
--// 31 - gmos keypad RECT 2
--// 32 - gmos keypad RECT 3
--// 33 - gmos keypad RECT 4
--// 34 - gmos keypad RECT 5
--// 35 - gmos keypad RECT 6
--// 36 - gmos keypad RECT 7
--// 37 - gmos keypad RECT 8
--// 38 - gmos keypad RECT 9
--// 39 - gmos keypad TEXT 0
--// 40 - gmos keypad TEXT 1
--// 41 - gmos keypad TEXT 2
--// 42 - gmos keypad TEXT 3
--// 43 - gmos keypad TEXT 4
--// 44 - gmos keypad TEXT 5
--// 45 - gmos keypad TEXT 6
--// 46 - gmos keypad TEXT 7
--// 47 - gmos keypad TEXT 8
--// 48 - gmos keypad TEXT 9

--// Entity types
--// -------------
--//   0 - Not registered
--//   1 - Laser
--//   2 - Locked Geometry
--//   3 - Cannon Kit keypad
--//   4 - Cannon Kit exploder
--//   5 - Cannon Kit spawner
--//   6 - Fieldgate
--//   7 - Fieldgate control
--//   8 - Food
--//   9 - Spawner keypad
--//  10 - Spawner spawner
--//  11 - Owner-Restricted Geometry
--//  12 - MassChange keypad
--//  13 - MassChange object
--//  14 - Grid object
--//  15 - Boombox

--// Include any other GMOS related stuff here
_OpenScript("strike/gmos_laser.lua");
_OpenScript("strike/gmos_cannon.lua");
_OpenScript("strike/gmos_fieldgate.lua");
_OpenScript("strike/gmos_food.lua");
_OpenScript("strike/gmos_spawner.lua");
_OpenScript("strike/gmos_masschange.lua");
_OpenScript("strike/gmos_grid.lua");
_OpenScript("strike/gmos_boombox.lua");

--// GMOS globals
function gmosGetTag()
	return "GMOS v1.5";
end

--//  Player Options
gmosEnabled = { };
gmosOptionStatus = { };
gmosViolations = {  };
gmosLastSpawnTime = {  };

--// Entities
gmosEntityTypes = { };
gmosEntities = { };
gmosEntityOwners = { };

gmosEntityTypes[0] = "Normal";
gmosEntityTypes[1] = "Laser";
gmosEntityTypes[2] = "Locked";
gmosEntityTypes[3] = "Cannon Keypad";
gmosEntityTypes[4] = "Cannon Exploder";
gmosEntityTypes[5] = "Cannon Spawner";
gmosEntityTypes[6] = "FieldGate";
gmosEntityTypes[7] = "FieldGate Control";
gmosEntityTypes[8] = "Food";
gmosEntityTypes[9] = "Spawner Keypad";
gmosEntityTypes[10] = "Spawner Spawner";
gmosEntityTypes[11] = "Owner-Restricted";
gmosEntityTypes[12] = "MassChange keypad";
gmosEntityTypes[13] = "MassChange object";
gmosEntityTypes[14] = "Grid object";
gmosEntityTypes[15] = "Boombox";

--//  gmosInit
--//  Initializes the GMOS system
function gmosInit(userId)
	--// make sure we are shut down
	gmosShutdown(userId);

	--// we are init'd
	gmosEnabled[userId] = true;

	gmosViolations[userId] = 0;
	gmosLastSpawnTime[userId] = 0;

	--// Open the status view
	gmosOpenStatusView(userId);

	--// Set initial display result
	gmosDisplayResult(userId, "GMOS Init Success", 1);

	--// Display warning info
	--//gmosDisplayInfo(userId, "Warning", "This game is regulated by a custom set of\nanti-griefer scripts. You are not allowed to\nremove or manipulate objects you have not\ncreated, unless explicitly unlocked by its\ncreator. Enjoy your stay.", false);

	gmosUpdateViolationDisplay(userId);
end

--//  gmosSetCreator
--//  Registers a player as the creator of an entity
function gmosSetCreator(entityId, userId)
	gmosEntityOwners[entityId] = userId;
end

--//  gmosGetCreator
--//  Gets the userId for whoever created the specified entity, or 0 if unknown
function gmosGetCreator(entityId)
	if(gmosEntityOwners[entityId] == nil) then
		return 0;
	else
		return gmosEntityOwners[entityId];
	end
end

--//  gmosRegisterViolation
--//  Increments a user's violation count, displaying a message, killing, or kicking the player for repeat offenders.
function gmosRegisterViolation(userId)
	local v = gmosViolations[userId] + 0;

	if(v ~= 0) then
		gmosViolations[userId] = v;

		--// let them know just how many times they have violated
		gmosUpdateViolationDisplay(userId);


		--// first time violators, give a warning message
		if(v < 3) then
			if(v == 1) then
				gmosDisplayInfo(userId, "Violation", "Anti-Griefer system has detected a first-time\nviolation. Let it be the last.", true);
			else
				_PlayerSetHealth(userId, _PlayerInfo(userId, "health") / 2);
			end
		elseif(v < 6) then
			if(v == 3) then
				gmosDisplayInfo(userId, "Violation", "Anti-Griefer system has detected three\nviolations. You will be penalized for further\nviolations.", false);
				_PlayerSetHealth(userId, _PlayerInfo(userId, "health") / 2);
			else
				_PlayerSetHealth(userId, 1);
			end
		elseif(v <= 9) then
			gmosDisplayInfo(userId, "Violation", "Anti-Griefer system has detected six or more\nviolations. You are on your last leg...", false);
			_PlayerKill(userId);
		else
			--// bastard has violated 10 times..
			gmosDisplayInfo(userId, "Violation", "Tough shit, you were warned far more than\nneeded.", false);
			_PlayerKill(userId);			
		end
	end		
end

--//  gmosPreDestroyEntity
--//  Safely unregisters an entity from gmos
function gmosPreDestroyEntity(entityId)
	gmosUnregisterEntity(entityId);
	gmosSetCreator(entityId, nil);
end

--//  gmosDestroyEntity
--//  Safely unregisters an entity from gmos and deletes the entity. It is of course
--//  still possible to delete entities without unregistering properties first, but
--//  this should be done wherever possible to prevent possible 'property creeps' in
--//  which a newly created entity 'inherits' whatever gmos features may have been enabled in
--//  that particular entityId's info vector.
function gmosDestroyEntity(entityId)
	if(entityId ~= nil) then
		gmosPreDestroyEntity(entityId);
		_EntRemove(entityId);
	end
end

--//  gmosCreateAndRegister
--//  Creates and registers an entity with gmos
function gmosCreateAndRegister(entityClass, userId, entType)
	local entity = _EntCreate(entityClass);

	gmosRegisterEntity(entity, entType);
	gmosSetCreator(entity, userId);

	return entity;
end

--//  gmosVerifyCreator
--//  Verifies that the specified entity was created by the specified player
function gmosVerifyCreator(entityId, userId)
	return (gmosGetCreator(entityId) == userId);
end

--//  gmosOpenStatusView
--//  Creates a status view for the specified player
function gmosOpenStatusView(userId)
	--// make sure the player does not already have the status window visible
	if(gmosOptionStatus[userId] or (not gmosEnabled[userId])) then return; end

	--// toggle the option on
	gmosOptionStatus[userId] = true;

	--// Create the GUI rect
	_GModRect_Start("gmod/white")
	_GModRect_SetPos(0.8, 0.3, 0.19, 0.25);
	_GModRect_SetColor(60, 150, 60, 100);
	_GModRect_SetTime(99999, 1.0, 0.3);
	_GModRect_Send(userId, 0);


	--// Create the title text
	_GModText_Start("Default");
	_GModText_SetPos(0.82, 0.32);
	_GModText_SetDelay(1.0);
	_GModText_SetTime(99999, 0.3, 0.3);
	_GModText_SetColor(232, 232, 198, 220);
	_GModText_SetText(string.format("%s\n_____________", gmosGetTag()));
	_GModText_Send(userId, 1);

	gmosSetHelp(userId, "gmos info gmos");
	gmosSetTargetInfo(userId, "%targetinfo%");
end

--//  gmosSetHelp
--//  Sets the help tag in the GMOS status window
function gmosSetHelp(userId, helpText)
	if((userId ~= 0) and ((not gmosOptionStatus[userId]) or (not gmosEnabled[userId]))) then return; end

	local prefix;

	--// Decide the prefix
	if(string.sub(helpText, 1, 4) == "gmos") then
		--// Its a gmos command being suggested. Is it for info or to try out?
		if((string.sub(helpText, 6, 9) == "help") or (string.sub(helpText, 6, 9) == "info")) then
			prefix = "For more information, say:";
		else
			prefix = "Try the following command:";
		end
	else
		--// Not a gmos command, must just be text info
		prefix = "Info Tip:";
	end

	--// Create the help text
	_GModText_Start("Default");
	_GModText_SetPos(0.805, 0.50);
	_GModText_SetDelay(1.0);
	_GModText_SetTime(99999, 0.3, 0.3);
	_GModText_SetColor(232, 232, 198, 220);
	_GModText_SetText(string.format("%s\n%s", prefix, helpText));
	_GModText_Send(userId, 5);
end

--//  gmosSetTargetInfo
--//  Sets the target info tag in GMOS status
function gmosSetTargetInfo(userId, targetInfo)
	if((userId ~= 0) and ((not gmosOptionStatus[userId]) or (not gmosEnabled[userId]))) then return; end

	--// Create the target info text
	_GModText_Start("Default");
	_GModText_SetPos(0.82, 0.38);
	_GModText_SetDelay(1.0);
	_GModText_SetTime(99999, 0.3, 0.3);
	_GModText_SetColor(232, 232, 198, 220);
	_GModText_SetText(targetInfo);
	_GModText_Send(userId, 3);
end

--//  gmosChoose_DisplayInfo
--//  Choose callback for display info
function gmosChoose_DisplayInfo(userId, selectionId, seconds)
	--// Doesnt matter what they picked, just close the info window
	gmosCloseInfo(userId);
end

--//  gmosPlaySound
--//  Plays specified sound for player, or for everybody if userId is 0
function gmosPlaySound(userId, sound)
	if(userId == 0) then
		_PlaySound(sound);
	else
		_PlaySoundPlayer(userId, sound);
	end
end

--//  gmosDisplayInfo
--//  Pops up an infobox with specified info
function gmosDisplayInfo(userId, title, info, autoClose)
	if((userId ~= 0) and (not gmosEnabled[userId])) then return; end

	--// play 'popup' sound
	gmosPlaySound(userId, "common/bugreporter_succeeded.wav");

	local freeze;
      local posX = 0.35;
	local posY = 0.35;
	local width = 0.35;
	local titleHeight = 0.05;
	local clientHeight = 0.3;
	local textWidth = 0.01;
	local charsPerLine = string.len("-----------------------------------------------");
	local curPos = 0;
	local newInfo;

	--// decide freeze time. if this was sent to a particular user, he can close himself
	--// otherwise set a short delay
	if(autoClose or (userId == 0)) then
		freeze = 4;
	else
		freeze = 99999;
	end

	--if(string.len(info) > charsPerLine) then
		--// Format the info line so it will auto-wrap
	--	newInfo = string.sub(info, 0, charsPerLine);
	--	for curPos = charsPerLine, string.len(info), charsPerLine do
	--		if((string.len(info) - curPos) < charsPerLine) then
	--			newInfo = string.format("%s\n%s", newInfo, string.sub(info, curPos));
	--		else
	--			newInfo = string.format("%s\n%s", newInfo, string.sub(info, curPos, curPos + charsPerLine));
	--		end
	--	end
	--else
		newInfo = info;
	--end

	--// Create the GUI title rect
	_GModRect_Start("gmod/white")
	_GModRect_SetPos(posX, posY, width, titleHeight);
	_GModRect_SetColor(60, 90, 60, 150);
	_GModRect_SetTime(freeze, 0.5, 0.1);
	_GModRect_Send(userId, 10);

	--// Create the GUI client rect
	_GModRect_Start("gmod/white")
	_GModRect_SetPos(posX, posY + titleHeight, width, clientHeight);
	_GModRect_SetColor(60, 150, 60, 100);
	_GModRect_SetTime(freeze, 0.5, 0.1);
	_GModRect_Send(userId, 11);

	--// Create the GUI title text
	_GModText_Start("Default");
	_GModText_SetPos(posX + textWidth, posY + textWidth);
	_GModText_SetDelay(0.5);
	_GModText_SetTime(freeze, 0.1, 0.1);
	_GModText_SetColor(232, 232, 198, 220);
	_GModText_SetText(title);
	_GModText_Send(userId, 12);

	--// Create the GUI client text
	_GModText_Start("Default");
	_GModText_SetPos(posX + textWidth, posY + titleHeight + textWidth);
	_GModText_SetDelay(0.5);
	_GModText_SetTime(freeze, 0.1, 0.1);
	_GModText_SetColor(198, 232, 198, 220);
	_GModText_SetText(newInfo);
	_GModText_Send(userId, 13);

	--// Create the GUI close text
	_GModText_Start("Default");
	_GModText_SetPos(posX + textWidth, posY + titleHeight + (clientHeight - textWidth*3));
	_GModText_SetDelay(0.5);
	_GModText_SetTime(freeze, 0.1, 0.1);
	_GModText_SetColor(232, 232, 198, 220);
	if(autoClose) then
		_GModText_SetText("Auto-Close");
	else
		_GModText_SetText("0. Close");
	end
	_GModText_Send(userId, 14);

	--// Hook up option callback
	if( (not autoClose) and (userId ~= 0) ) then
		_PlayerOption(userId, "gmosChoose_DisplayInfo", 99999);
	end
end

--//  gmosCloseInfo
--//  Closes the info display box
function gmosCloseInfo(userId)
	--// close backgrounds
	_GModRect_Hide(userId, 10, 0.1, 0.4);
	_GModRect_Hide(userId, 11, 0.1, 0.4);

	--// close texts
	_GModText_Hide(userId, 12, 0.1, 0);
	_GModText_Hide(userId, 13, 0.1, 0);
	_GModText_Hide(userId, 14, 0.1, 0);
end

--//  gmosRegisterEntity
--//  Registers a created entity with the gmos system
function gmosRegisterEntity(entityId, type)
	if(entityId ~= nil) then
		gmosEntities[entityId] = type;
	end
end

--//  gmosUnregisterEntity
--//  Unregisters an entity with the gmos system
function gmosUnregisterEntity(entityId)
	gmosRegisterEntity(entityId, nil);
end

--//  gmosGetEntityType
--//  Gets an entity's type
function gmosGetEntityType(entityId)
	local entType = gmosEntities[entityId];

	if(entType == nil) then
		return 0;
	else
		return entType;
	end
end

--//  gmosGetEntityTypeString
--//  Gets the name of an entity's type
function gmosGetEntityTypeString(entityId)
	return gmosEntityTypes[gmosGetEntityType(entityId)];
end

--//  gmosDisplayResult
--//  Displays the result of a command to the GMOS status window, if it is enabled
--//  severity values:
--//    0 - Simple notification
--//    1 - Success notification (green)
--//    2 - Warning notification (orange)
--//    3 - Error notification (red)
function gmosDisplayResult(userId, result, severity)
	if((userId ~= 0) and ((not gmosEnabled[userId]) or (not gmosOptionStatus[userId]))) then return; end

	--// Create the title text
	_GModText_Start("Default");
	_GModText_SetPos(0.82, 0.36);
	_GModText_SetTime(7.5, 0.1, 0.3);

	if(severity == 0) then
		_GModText_SetColor(232, 232, 198, 220);
	elseif(severity == 1) then
		_GModText_SetColor(30, 200, 30, 220);
	elseif(severity == 2) then
		_GModText_SetColor(255, 100, 20, 220);
	elseif(severity == 3) then
		_GModText_SetColor(255, 30, 30, 220);
	end

	_GModText_SetText(result);
	_GModText_Send(userId, 2);
end

--//  gmosUpdateViolationDisplay
--//  Informs a player of their violation count.
function gmosUpdateViolationDisplay(userId)
	if((userId ~= 0) and ((not gmosEnabled[userId]) or (not gmosOptionStatus[userId]))) then return; end
	local v = gmosViolations[userId];

	--// Create the title text
	_GModText_Start("Default");
	_GModText_SetPos(0.82, 0.42);
	_GModText_SetTime(99999, 0.1, 0.3);

	if(v == 0) then
		_GModText_SetColor(232, 232, 198, 220);
	elseif(v < 3) then
		_GModText_SetColor(255, 200, 30, 220);
	elseif(v < 6) then
		_GModText_SetColor(255, 100, 20, 220);
	else
		_GModText_SetColor(255, 30, 30, 220);
	end

	if(v == 0) then
		_GModText_SetText( "No violations." );
	else
		_GModText_SetText( string.format("Violations: %s", tostring(v)) );
	end
	_GModText_Send(userId, 4);
end

--//  gmosCloseStatusView
--//  Closes the gmos status view for specified player
function gmosCloseStatusView(userId)
	--// make sure the option is enabled
	if(gmosOptionStatus[userId]) then
		--// turn the option off
		gmosOptionStatus[userId] = false;

		--// Close GUI rect and contents
		_GModRect_Hide(userId, 0, 0.3, 1);
		_GModText_Hide(userId, 1, 0.3, 0);
		_GModText_Hide(userId, 2, 0.3, 0);
		_GModText_Hide(userId, 3, 0.3, 0);
		_GModText_Hide(userId, 4, 0.3, 0);
		_GModText_Hide(userId, 5, 0.3, 0);
	end
end

--// gmosShutdown
--// Shuts down the gmos system
function gmosShutdown(userId)
	--// Reset options
	gmosOptionStatus[userId] = false;
	gmosEnabled[userId] = false;

	--// Hide all GUI crap
	_GModRect_HideAll(userId);
	_GModText_HideAll(userId);
end

--// gmosPlayerPickEntity
--// Gets the entity the player is looking at
function gmosPlayerPickEntity(userId, maxDistance)
	local vPos = _PlayerGetShootPos(userId);
	local vAng = _PlayerGetShootAng(userId);

	_TraceLine(vPos, vAng, maxDistance, userId);

	if((not _TraceHit()) or (_TraceHitWorld())) then
		return 0;
	else
		return _TraceGetEnt();
	end
end

--// gmosPlayerPickPosition
--// Gets the position the player is looking at
function gmosPlayerPickPosition(userId, maxDistance)
	local vPos = _PlayerGetShootPos(userId);
	local vAng = _PlayerGetShootAng(userId);

	_TraceLine(vPos, vAng, maxDistance, userId);

	if(_TraceHit()) then
		return _TraceEndPos();
	else
		return vector3(0,0,0);
	end
end

--// gmosEntityPickPosition
--// Gets the position the entity is looking at
function gmosEntityPickPosition(entityId, maxDistance, angleAdd)
	_TraceLine(_EntGetPos(entityId), vecAdd(_EntGetAng(entityId), angleAdd), maxDistance, entityId);

	--if(_TraceHit()) then
		return _TraceEndPos();
	--else
	--	return vector3(0,0,0);
	--end
end

--// gmosActivateEntity
--// Activates an entity that (should) have been spawned by gmos
function gmosActivateEntity(userId, entityId)
	local entType = gmosGetEntityType(entityId);

	if(entType == 0) then
		--// Not a registered entity
		return;
	elseif(entType == 1) then
		--// Laser
		gmosToggleLaser(userId, entityId);
	elseif(entType == 3) then
		--// Cannon Kit keypad
		gmosActivateCannon(userId, entityId);
	elseif(entType == 7) then
		--// FieldGate keyboard
		gmosToggleFieldGate(userId, entityId);
	elseif(entType == 9) then
		--// Spawner keypad
		gmosActivateSpawner(userId, entityId);
	elseif(entType == 12) then
		--// MassChange keypad
		gmosToggleMassChange(userId, entityId);
	elseif(entType == 15) then
		--// Boombox
		gmosActivateBoombox(userId, entityId);
	end
end

--// gmosDoCommand
--// Does a scripted command from a player target
function gmosDoCommand(userId, command, message)
	--// Manipulating status window?
	if(command == "status") then
		if((message == "on") or (message == "1") or (message == "enable")) then
			gmosOpenStatusView(userId);
		elseif((message == "off") or (message == "0") or (message == "")) then
			gmosCloseStatusView(userId);
		end
	end

	--// Manipulating gmod?
	if(command == "system") then
		if((message == "init") or (message == "on") or (message == "enable") or (message == "1")) then
			--// play 'startup' sound
			_PlaySoundPlayer(userId, "items/suitchargeok1.wav");
			gmosInit(userId);
		elseif((message == "shutdown") or (message == "off") or (message == "disable") or (message == "0")) then
			--// play 'shutdown' sound
			_PlaySoundPlayer(userId, "items/flashlight1.wav");
			gmosShutdown(userId);
		end
	end

	--// Help/info system?
	if((command == "info") or (command == "help")) then
		if(message == "about") then
			--// display about info
			gmosDisplayInfo(userId, "About GMOS", "BAH GMOS 2005", true);
		elseif((message == "help") or (message == "info")) then
			--// display help info
			gmosDisplayInfo(userId, "Info: Help/Info", "The info or help command (both are equivelant) is used to retrieve more information about a particular command.\nFor example, to retrieve information related to GMOS system commands, say 'gmos info system'", false);
		elseif(message == "gmos") then
			gmosDisplayInfo(userId, "Info: GMOS", "GMOS is an API written in Lua to help manage GMOD-related tasks", false);
		elseif(message == "system") then
			gmosDisplayInfo(userId, "Info: System", "The system commands control GMOS. The following commands are supported:\n\ngmos system init - Initializes GMOS\ngmos system shutdown - Shuts down GMOS", false);
		elseif((message == "commands") or (message == "command")) then
			gmosDisplayInfo(userId, "Info: Commands", "GMOS is controlled by commands that you say (type as you would speak to other people; NOT console commands). The basic structure of GMOS commands is\n'gmos' + 'catagory' + 'command'\n\nSo for example, you could say 'gmos status enable' to display the GMOS status window", false);
		elseif(message == "target") then
			local tmpEnt = gmosPlayerPickEntity(userId, 1024);
			if(tmpEnt ~= 0) then
				gmosDisplayInfo(userId, "Info: Target", string.format("Target Properties\nName: %s\nClassname: %s\nModel: %s\nMass: %s\n Type: %s", _EntGetName(tmpEnt), _EntGetType(tmpEnt), _EntGetModel(tmpEnt), tostring(_phys.GetMass(tmpEnt)), gmosGetEntityTypeString(tmpEnt)), false);
				gmosDisplayResult(userId, "Displaying target info", 1);
			else
				gmosDisplayResult(userId, "Could not pick target entity", 3);
			end
		elseif((message == "cannon") or (message == "cannonkit") or (message == "cannons")) then
			gmosDisplayInfo(userId, "Cannon Kit", "The cannon kit comes with three parts.\n\n1. Keypad\n2. Detonator\n3. Ammo Spawner\n\nHow to use these three components is\nleft up to you ;)\n\nType 'gmos info cannonkit' to see this message\nagain.", false);
		elseif((message == "laser") or (message == "lasers")) then
			gmosDisplayInfo(userId, "Laser", "The laser comes with just one part, the laser emitter.\nSimply activate the laser to toggle it on\nand off.\n\nType 'gmos info laser' to see this message again.", false);
		elseif((message == "gate") or (message == "fieldgate") or (message == "forcefield")) then
			gmosDisplayInfo(userId, "FieldGate", "The field gate comes with two parts.\n\n1. FieldGate\n2. FieldGate Control\n\nPlace the FieldGate whereever you wish.\nToggle the field with the FieldGate Control\n\nType 'gmos info fieldgate' to see this message\nagain.", false);
		elseif(message == "melon") then
			gmosDisplayInfo(userId, "Melon", "The melon restores health when broken", false);
		elseif(message == "poison") then
			gmosDisplayInfo(userId, "Poison", "This bottle of poison is rather nasty when consumed", false);
		elseif(message == "redbull") then
			gmosDisplayInfo(userId, "RedBull", "RedBull gives you wiiiiiings!", false);
		elseif(message == "spawner") then
			gmosDisplayInfo(userId, "Spawner", "The spawner.. spawns stuff", false);
		elseif(message == "masschange") then
			gmosDisplayInfo(userId, "MassChange", "The MassChange has two parts.\n\n1. Keypad\n2. MassChange object\n\nUse the keypad to toggle masses.\nAim at keypad and type\ngmos masschangeon xxx\ngmos masschangeoff xxx", false);
		elseif(message == "grid") then
			gmosDisplayInfo(userId, "Grid", "The Grid can be hollowed out to make a fort!", false);
		elseif(message == "boombox") then
			gmosDisplayInfo(userId, "Boombox", "The boombox plays specified music\nwhen you activate it.", false);
		end
	end

	--// List system?
	if((command == "list") or (command == "display") or (command == "show")) then
		if((message == "info") or (message == "help")) then
			gmosDisplayInfo(userId, "Command List: Help/Info", "gmos info 'command'\nRetrieves information about specified 'command'\n'command' can be one of the following:\n about\n gmos\n info\n system\n commands", false);
		elseif((message == "commands") or (message == "command")) then
			gmosDisplayInfo(userId, "Command List: Command Catagories", "gmos 'catagory' [command]\nPerforms a command related to a specific 'catagory'\n'catagory' can be one of the following:\n system - Controls GMOS system\n status - Controls GMOS status window\n list - Lists all possible commands", false);
		end
	end

	--// Mass change
	if(command == "masschangeon") then
		local tmpEnt = gmosPlayerPickEntity(userId, 1024);
		if(tmpEnt ~= 0) then
			if(gmosGetEntityType(tmpEnt) == 12) then
				gmosMassChangeOn(tmpEnt, tonumber(message));
				gmosDisplayResult(userId, "On mass set", 1);
			else
				gmosDisplayResult(userId, "Must target keypad", 3);
			end
		else
			gmosDisplayResult(userId, "Could not pick target entity", 3);
		end
	end
	if(command == "masschangeoff") then
		local tmpEnt = gmosPlayerPickEntity(userId, 1024);
		if(tmpEnt ~= 0) then
			if(gmosGetEntityType(tmpEnt) == 12) then
				gmosMassChangeOff(tmpEnt, tonumber(message));
				gmosDisplayResult(userId, "Off mass set", 3);
			else
				gmosDisplayResult(userId, "Must target keypad", 1);
			end
		else
			gmosDisplayResult(userId, "Could not pick target entity", 3);
		end
	end

	--// Music system
	if(command == "music") then
		if((message == "off") or (message == "disable") or (message == "0")) then
			--// can we disable whatever was played here?
			gmosDisplayResult(userId, "Music stopping not implemented", 2);
		else
			if(string.sub(message, 0, 1) == "$") then
				--// preset music ID
				_PlaySound(string.format("music/hl1_song%s.mp3", string.sub(message, 2)));
				gmosDisplayResult(userId, "Music playing", 1);
			elseif(string.sub(message, 0, 1) == "#") then
				--// preset music ID
				_PlaySound(string.format("music/hl2_song%s.mp3", string.sub(message, 2)));
				gmosDisplayResult(0, "Music playing", 1);
			else
				--// just play the music
				_PlaySound(message);
			end
		end
	end

	--// boombox spawner
	if(command == "boombox") then
		local song;

		if(string.sub(message, 0, 1) == "$") then
			--// preset music ID
			song = string.format("music/hl1_song%s.mp3", string.sub(message, 2));
		elseif(string.sub(message, 0, 1) == "#") then
			--// preset music ID
			song = string.format("music/hl2_song%s.mp3", string.sub(message, 2));
		else
			song = message;
		end

		gmosSpawnBoombox(userId, song);
		gmosDoCommand(userId, "info", "boombox");
	end

	--// Spawn system
	if((command == "spawn") or (command == "create")) then
		local success = false;

		if(message == "laser") then
			success = gmosSpawnLaser(userId);

			--// Display help screen on laser
			gmosDoCommand(userId, "info", "laser");
		elseif(message == "cannonkit") then
			success = gmosSpawnCannonKit(userId);

			--// Display help screen on cannon kit
			gmosDoCommand(userId, "info", "cannonkit");
		elseif(message == "fieldgate") then
			success = gmosSpawnFieldGate(userId);

			--// Display help screen on field gate
			gmosDoCommand(userId, "info", "fieldgate");
		elseif(message == "melon") then
			success = gmosSpawnFood(userId, 0);

			--// Display help screen on melon
			gmosDoCommand(userId, "info", "melon");
		elseif(message == "poison") then
			success = gmosSpawnFood(userId, 1);

			--// Display help screen on poison
			gmosDoCommand(userId, "info", "poison");
		elseif(message == "redbull") then
			success = gmosSpawnFood(userId, 2);
			gmosDoCommand(userId, "info", "redbull");
		elseif(message == "spawner") then
			success = gmosSpawnSpawner(userId, 2);
			gmosDoCommand(userId, "info", "spawner");
		elseif(message == "masschange") then
			success = gmosSpawnMassChange(userId);
			gmosDoCommand(userId, "info", "masschange");
		elseif(message == "grid") then
			success = gmosSpawnGrid(userId, 9, 8, 6);
			gmosDoCommand(userId, "info", "grid");
		end

		if(success) then
			gmosDisplayResult(userId, string.format("%s created", message), 1);
		else
			gmosDisplayResult(userId, "Could not create object", 3);
		end
	end

	--// extra testing stuff
	if(command == "broadcastinfo") then
		gmosDisplayInfo(0, "Broadcast", message, false);
	end

	if(command == "broadcastresult") then
		gmosDisplayResult(0, message, 0);
	end

	if(command == "sethelp") then
		gmosSetHelp(0, message);
	end

	if(command == "setmass") then
		local tmp = gmosPlayerPickEntity(userId, 1024);
		local m = tonumber(message);
		if(m ~= nil) then
			_phys.SetMass(tmp, m);
			gmosDisplayResult(userId, "Mass changed", 1);
		else
			gmosDisplayResult(userId, "Not aiming at anything", 2);
		end
	end

	if(command == "destroy") then
		if(message == "grid") then
			gmosDestroyGrid(userId);
		end
	end

	--// more stuff
	if(command == "tweak") then
		local tmp = gmosPlayerPickEntity(userId, 1024);
		if(message == "fly") then
			if(tmp ~= 0) then
				_phys.SetMass(tmp, 1.0);
				gmosDisplayResult(userId, "Fly enabled for target", 1);
			else
				gmosDisplayResult(userId, "Not aiming at anything", 2);
			end
		elseif(message == "huge") then
			if(tmp ~= 0) then
				_phys.SetMass(tmp, 100000.0);
			else
				gmosDisplayResult(userId, "Not aiming at anything", 2);
			end
		elseif(message == "big") then
			if(tmp ~= 0) then
				_phys.SetMass(tmp, 5000.0);
			else
				gmosDisplayResult(userId, "Not aiming at anything", 2);
			end
		elseif(message == "lock") then
			if(tmp ~= 0) then
				if(gmosGetEntityType(tmp) == 0) then
					gmosRegisterEntity(tmp, 2);
					gmosDisplayResult(userId, "Object locked", 0);
				else
					gmosDisplayResult(userId, "Unable to lock/already locked", 2);
				end
			else
				gmosDisplayResult(userId, "Not aiming at anything", 2);
			end
		elseif(message == "unlock") then
			if(tmp ~= 0) then
				if(gmosGetEntityType(tmp) == 2) then
					gmosRegisterEntity(tmp, 0);
					gmosDisplayResult(userId, "Object unlocked", 0);
				else
					gmosDisplayResult(userId, "Unable to unlock/already unlocked", 2);
				end
			else
				gmosDisplayResult(userId, "Not aiming at anything", 2);
			end
		end
	end
end