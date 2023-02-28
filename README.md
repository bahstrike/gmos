## WARNING
The current commit is legit just an archive of some crap i wrote a long time ago, and wont even work in the current version of garrys mod. So take everything with a grain of salt, or a shot of whiskey. Either or




# GMOS v1.5      2006 Strike



## About
GMOS (Garry's Mod Operating System) is a
collection of scripts that make up a fake OS.





## Installation
All GMOS scripts should be in:
C:\Program Files\Steam\steamapps\SourceMods\gmod9\lua\strike





## Getting Started
1)  Host a game of Garry's Mod

2)  Open console and type:
    lua_openscript strike/main.lua

3)  Type in chat (not console):
    gmos system init





## Using GMOS
All of GMOS' commands are typed in chat (not console). Most GMOS commands
require you to be aiming at an object or a spot on the ground.

The GENERAL COMMANDS do not require you to be aiming at anything in particular.
The OBJECT TWEAKING COMMANDS require you to be aiming at the object you wish to manipulate.
The OBJECT SPAWNING COMMANDS require you to be aiming at a spot on the ground where you wish to spawn the object.


### GENERAL COMMANDS
 [ To initialize or shutdown GMOS on your client ]
gmos system init
gmos system shutdown

 [ To hide or show the GMOS window ]
gmos status on
gmos status off

 [ To broadcast a popup message window to all players ]
gmos broadcastinfo Hello this is a message.

 [ To play a HL1 song on all players (type any number from about 0 to 30, some song numbers do not exist) ]
gmos music $0
gmos music $1
etc..

 [ To play a HL2 song on all players (type any number from about 0 to 30, some song numbers do not exist) ]
gmos music #0
gmos music #1
etc..


### OBJECT TWEAKING COMMANDS
| Command | Description |
| ------- | ----------- |
| gmos tweak lock | To prevent an object from being deleted with Remove tool or moved by Physics/Gravity gun |
| gmos tweak unlock | To unlock an object, allowing it to be deleted with Remove tool or moved by Physics/Gravity gun |
| gmos tweak fly | To set the mass of an object to an extremely small value. This is deprecated, use   gmos setmass |
| gmos tweak big | To set the mass of an object to a large value. This is deprecated, use   gmos setmass |
| gmos tweak huge | To set the mass of an object to an extremely large value. This is deprecated, use   gmos setmass |
| gmos setmass XXX | To change the mass of an object to any value, where XXX is the new mass |
| gmos info target | To get a popup message displaying information about an object you are aiming at; most notably including the entity type registered with GMOS, the object's mass, and the object's model filename |



### OBJECT SPAWNING COMMANDS
 [ To spawn a melon that gives health when you break it ]
gmos spawn melon

 [ To spawn a RedBull that makes you run very fast when you break it ]
gmos spawn redbull

 [ To spawn a bottle of poison that damages you when you break it ]
gmos spawn poison

 [ To spawn a laser that can be toggled on/off by pressing USE on it ]
gmos spawn laser

 [ To spawn a fieldgate that can be toggled on/off by pressing USE on the console ]
gmos spawn fieldgate

 [ To spawn a cannon-kit that can be fired by pressing USE on the keypad (note that all 3 items must be frozen w/ gravity gun to enable keypad) ]
gmos spawn cannonkit

 [ To spawn a 9x8x6 grid used for fort wars. Use remove tool to carve out hallways and rooms. Only one grid per player. Type   gmos destroy grid   to remove the whole grid at once ]
gmos spawn grid

 [ To spawn a boombox with the specified song. Uses same $ or # scheme as  gmos music ]
gmos boombox $22
gmos boombox #14

 [ To spawn a crate that will switch between two masses when keypad is activated. Use  gmos masschangeon XXX   and  gmos masschangeoff XXX   while aiming at keypad to change on/off masses, where XXX is the new mass ]
gmos spawn masschange


# Known Bugs
Destroying breakable objects (such as wood or explosive barrels) can cause object IDs
to be reused without GMOS unregistering the original object. The result means that
sometimes an object may become locked when nobody locked it. Usually the host is able to
unlock the object  (gmos tweak unlock).
