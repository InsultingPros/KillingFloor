//==============================================================================
// ROVehicleFactory
// Copyright (C) 2004 Jeffrey Nakai
//
// This class is currently a work-in-progress.  It is based off the
//	ONSVehicleFactory class with certain undesireable features removed.  This
//	class will be expanded as we get a better sense of how the RO vehicles are
//	going to work.  We need to start twisting some arms soon to get vehicle
//	designs from Alan
//==============================================================================

class ROVehicleFactory extends SVehicleFactory
	abstract
	placeable;

//===================================================================
// **Warning** This class, like many of the new vehicle classes
// is pretty hacked together right now. Clean up right after alpha!!!
// Ramm
//===================================================================

// Carry overs from ONS incase we decide on some sort of spawn effect(not likely)
var     float           PreSpawnEffectTime;
var     Emitter         BuildEffect;
var		bool			SpawningBuildEffects;

var()   float           RespawnTime;
var()	bool			bAllowVehicleRespawn;
var()	bool			bUseBuildEffects;
var     bool            bFactoryActive;

// allows the other side to capture the factory and use the vehicles
var()	bool			bAllowOpposingForceCapture;
var		Vehicle			LastSpawnedVehicle;
var		float			LastSpawnedTime;
var     int             TotalSpawnedVehicles;
var()   int             VehicleRespawnLimit;

var()   bool            bDestroyVehicleWhenInactive;    // Caues the vehicle at this factory to be destroyed when the factory becomes inactive

// need to figure out if we really need this
enum ROSideIndex
{
	AXIS,
	ALLIES,
	NEUTRAL  	// either side can use this vehicle
};

var() ROSideIndex	TeamNum;

var()	bool			bUsesSpawnAreas;		// Actived by the spawn area

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
		VehicleClass.static.StaticPrecache(Level);

}

simulated function UpdatePrecacheMaterials()
{
    VehicleClass.static.StaticPrecache(Level);

	// precache the BuildEffect if there is one
}

function PostNetBeginPlay()
{
//	local GameObjective O, Best;
//	local float BestDist, NewDist;

    Super.PostNetBeginPlay();

	//Legacy ONS code, kept here incase we want to tie factories to objectives

    /*if ( !bDeleteMe && !Level.Game.IsA('ROTeamGame') )
    {
		foreach AllActors(class'GameObjective',O)
		{
			NewDist = VSize(Location - O.Location);
			if ( (Best == None) || (NewDist < BestDist) )
			{
				Best = O;
				BestDist = NewDist;
			}
		}

		if ( Best != None )
			Activate(Best.DefenderTeamIndex);
	} */
}

function ActivatedBySpawn(int Team)
{
	if( Team == AXIS_TEAM_INDEX )
	{
		Activate(AXIS);
	}
	else if ( Team == ALLIES_TEAM_INDEX )
	{
	    Activate(ALLIES);
	}
	else
	{
		Activate(NEUTRAL);
	}
}

function Activate(ROSideIndex T)
{
    if (!bFactoryActive || TeamNum != T)
    {
        TeamNum = T;
        bFactoryActive = True;
        SpawningBuildEffects = True;
        //SetTimer(0.1, false);
        Timer();
    }
}

function Deactivate()
{
    bFactoryActive = False;

	if (bDestroyVehicleWhenInactive && ROVehicle(LastSpawnedVehicle) != None )
	{
	   ROVehicle(LastSpawnedVehicle).ResetTime = Level.TimeSeconds + 1;
	}
}

event VehicleDestroyed(Vehicle V)
{
	Super.VehicleDestroyed(V);

    ROTeamGame(Level.Game).LevelInfo.HandleDestroyedVehicle( class<ROVehicle>(VehicleClass) );

	// Factory can't respawn the vehicle, return out
	if( !bAllowVehicleRespawn )
		return;

	if( bUseBuildEffects )
	{
		SpawningBuildEffects = true;
		if( TotalSpawnedVehicles < 1)
		{
			Timer();
		}
		else
		{
			SetTimer(RespawnTime - PreSpawnEffectTime, False);
		}
    }
    else
    {
		if( TotalSpawnedVehicles < 1)
		{
			Timer();
		}
		else
		{
			SetTimer(RespawnTime, false);
		}
    }
}

function Timer()
{
    if (bFactoryActive && Level.Game.bAllowVehicles && VehicleCount < MaxVehicleCount && TotalSpawnedVehicles < VehicleRespawnLimit)
	{
        if( bUseBuildEffects && SpawningBuildEffects )
        {
        	SpawningBuildEffects = false;
            SpawnBuildEffect();
            SetTimer(PreSpawnEffectTime, False);
        }
        else
    	   SpawnVehicle();
    }
}

function SpawnVehicle()
{
	local Pawn P;
	local bool bBlocked;
	local ROLevelInfo ROL;

    foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.25)
	{
		bBlocked = true;
		// MergeTODO:Replace this with a proper vehicle can't spawn message
		/*
		if (PlayerController(P.Controller) != None)
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 11);
		*/
	}

	ROL = ROTeamGame(Level.Game).LevelInfo;

    // Don't spawn this vehicle if there are too many already
    if(!bBlocked && ROL != none && ROL.bUseVehicleTotalLimits &&
        ROL.OverVehicleLimit( class<ROVehicle>(VehicleClass)))
    {
         bBlocked = true;
    }

    if (bBlocked)
    	SetTimer(1, false); //try again later
    else
    {
        if( bAllowOpposingForceCapture && TeamNum == AXIS )
            LastSpawnedVehicle = spawn(VehicleClass,,, Location, Rotation + rot(0,32768,0));
        else
            LastSpawnedVehicle = spawn(VehicleClass,,, Location, Rotation);

		if (LastSpawnedVehicle != None )
		{
			VehicleCount++;
			TotalSpawnedVehicles++;
			if( ROL != none )
			     ROL.HandleSpawnedVehicle( class<ROVehicle>(VehicleClass) );
			LastSpawnedTime = Level.TimeSeconds;
			LastSpawnedVehicle.SetTeamNum(TeamNum);
			// Removed this since it was causing extra vehicle respawning, if we find a use for it revisit
			//LastSpawnedVehicle.Event = Tag;
			LastSpawnedVehicle.ParentFactory = Self;
		}
		else
		{
		    log("Spawned vehicle failed for "$Self);
		}
    }
}

// Not used right now
function SpawnBuildEffect()
{
}

// Is RO gonna use Triggers
event Trigger( Actor Other, Pawn EventInstigator )
{
}

simulated function Reset()
{

     //log("Reset got called for "$self);
     if( !bUsesSpawnAreas )
     {
         //log(self$" spawning vehicle because of reset");
         SpawnVehicle();
         TotalSpawnedVehicles=0;
         Activate(TeamNum);
     }
     else
     {
         TotalSpawnedVehicles=0;
         bFactoryActive=false;
     }
}

defaultproperties
{
     PreSpawnEffectTime=2.000000
     RespawnTime=15.000000
     bAllowVehicleRespawn=True
     VehicleRespawnLimit=255
     TeamNum=NEUTRAL
     DrawType=DT_Mesh
}
