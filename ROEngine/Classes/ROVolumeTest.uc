//=============================================================================
// ROVolumeTest
//=============================================================================
// A temporary actor that is spawned to test if it is in a particular volume
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//============================================================================

class ROVolumeTest extends Actor;

//=============================================================================
// Functions
//=============================================================================

// Returns true if this test actor is in an area where artillery should not be allowed
function bool IsInNoArtyVolume()
{
	local Volume V;

	foreach TouchingActors(class'Volume', V)
	{
		if ((V.AssociatedActor != none && V.AssociatedActor.IsA('ROSpawnArea') && IsCurrentSpawnArea(ROSpawnArea(V.AssociatedActor)))
			|| V.IsA('RONoArtyVolume') && (IsCurrentSpawnArea(RONoArtyVolume(V).AssociatedSpawn) || RONoArtyVolume(V).SpawnAreaTag == ''))
			return true;
	}

	return false;
}

// Returns true if this ROSpawnArea is the current spawn for either team
function bool IsCurrentSpawnArea(ROSpawnArea spawn)
{
	if ( spawn == ROTeamGame(Level.Game).CurrentSpawnArea[0] ||
		 spawn == ROTeamGame(Level.Game).CurrentSpawnArea[1] ||
		 spawn == ROTeamGame(Level.Game).CurrentTankCrewSpawnArea[0] ||
		 spawn == ROTeamGame(Level.Game).CurrentTankCrewSpawnArea[1])
		return true;
	else
		return false;

}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_None
     RemoteRole=ROLE_None
     LifeSpan=0.500000
     bCollideActors=True
}
