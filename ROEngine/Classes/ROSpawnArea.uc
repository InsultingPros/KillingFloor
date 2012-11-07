//=============================================================================
// ROSpawnArea
//=============================================================================
// Defines an area where players can spawn
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROSpawnArea extends Actor
	placeable;

//=============================================================================
// Variables
//=============================================================================

var()	bool		bInitiallyActive;          // True if the spawn is enabled when play starts
var()	bool		bAxisSpawn;			       // Axiss can use this spawn
var()	bool		bAlliesSpawn;			   // Soviets can use this spawn
var()	int		AxisPrecedence;			       // Used to decide which spawn area gets priority over the others (Larger numbers increase precendence, 0 = starting spawn area)
var()	int		AlliesPrecedence;
var()	array<int>	AxisRequiredObjectives;    // A list of the objective numbers for each objective that must be complete to use this spawn area
var()	array<int>	AlliesRequiredObjectives;
var()	array<int>	NeutralRequiredObjectives;

var()	name		VolumeTag;			       // Volume that defines the shape of this spawn area
var()	int		SpawnProtectionTime;		   // Time in seconds that players inside here are invincible after spawning
var()   bool	bTankCrewSpawnArea;            // This spawn area is used exclusively for tank crewmen
var()   bool	bIncludeNeutralObjectives;     // Used in conjunction with TeamMustLoseAllRequired. Will check to see if there are any neutral objectives in the NeutralRequiredObjectives array for spawning not just owned objectives

var	Volume		AttachedVolume;
var	bool		bEnabled;

enum ETeamMustLoseAllRequired
{
	SPN_Neutral,
	SPN_Axis,
	SPN_Allies,
};

var()	ETeamMustLoseAllRequired	TeamMustLoseAllRequired;  // This team must lose all required obj to be moved back

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay - Tell the game info about this spawn area and find the volume
//-----------------------------------------------------------------------------

function PostBeginPlay()
{
	if (ROTeamGame(Level.Game) != None)
	{
		if (bTankCrewSpawnArea)
			ROTeamGame(Level.Game).TankCrewSpawnAreas[ROTeamGame(Level.Game).TankCrewSpawnAreas.Length] = self;
		else
			ROTeamGame(Level.Game).SpawnAreas[ROTeamGame(Level.Game).SpawnAreas.Length] = self;
	}

	if (VolumeTag != '')
	{
		foreach AllActors(class'Volume', AttachedVolume, VolumeTag)
		{
			AttachedVolume.AssociatedActor = self;
			break;
		}
	}

	Disable('Trigger');
}

//-----------------------------------------------------------------------------
// PreventDamage - Returns true if this player should not be damaged at all
//-----------------------------------------------------------------------------

function bool PreventDamage(Pawn Other)
{
	if( ((Level.TimeSeconds - Other.SpawnTime) < SpawnProtectionTime) && AttachedVolume != none && AttachedVolume.Encompasses(Other) )
	{
		return true;
	}

	return false;
}

//-----------------------------------------------------------------------------
// Trigger - Allows a disabled spawn area to become enabled
//-----------------------------------------------------------------------------

function Trigger(Actor Other, Pawn EventInstigator)
{
    bEnabled = true;
	Disable('Trigger');

	if (ROTeamGame(Level.Game) != None)
	{
		if (bTankCrewSpawnArea)
			ROTeamGame(Level.Game).CheckTankCrewSpawnAreas();
		else
			ROTeamGame(Level.Game).CheckSpawnAreas();

		ROTeamGame(Level.Game).CheckVehicleFactories();
	}
}

//-----------------------------------------------------------------------------
// Reset - Set enabled state to default
//-----------------------------------------------------------------------------

function Reset()
{
	bEnabled = bInitiallyActive;

	if (!bEnabled)
		Enable('Trigger');
}

//=============================================================================
// defaultpropeties
//=============================================================================

defaultproperties
{
     bInitiallyActive=True
     bHidden=True
     RemoteRole=ROLE_None
}
