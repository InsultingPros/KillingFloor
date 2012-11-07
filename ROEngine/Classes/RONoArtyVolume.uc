//=============================================================================
// RONoArtyVolume
//=============================================================================
// A volume class that won't allow artillery to be called within it
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//============================================================================

class RONoArtyVolume extends Volume;

var() 	name 	SpawnAreaTag;     // SpawnArea tag for ROSpawnArea associated with this actor
var	 ROSpawnArea	AssociatedSpawn;  // Associated ROSpawn area for this arty volume

function PostBeginPlay()
{
	local ROSpawnArea Spawn;

	if (SpawnAreaTag != '')
	{
		foreach AllActors(class'ROSpawnArea', Spawn, SpawnAreaTag)
		{
			AssociatedSpawn = Spawn;
			break;
		}
	}
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
}
