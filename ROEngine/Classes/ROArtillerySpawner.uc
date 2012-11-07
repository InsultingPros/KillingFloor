//=============================================================================
// ROArtillerySpawner
//=============================================================================
// A helper class for the ROArtilleryShell. Handles spawning the individual
// Artillery rounds and the logic associated with that.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================

class ROArtillerySpawner extends Actor;

//=============================================================================
// Variables
//=============================================================================

var int SpawnCounter;
var int SalvoCounter;
var int OwningTeam;
var int SalvoAmount;
var int BatterySize;
var int StrikeDelay;
var int SpreadAmount;

var Controller	InstigatorController; // The controller that spawned this
var ROArtilleryShell LastSpawnedShell;// The last shell spawned by this arty spawner
var vector OriginalArtyLocation;      // Stores the location of the place the arty was originally called on

//=============================================================================
// Functions
//=============================================================================

function PostBeginPlay()
{
	local int StrikeTemp;
	local ROLevelInfo LI;

	Super.PostBeginPlay();

	InstigatorController = Controller(Owner);

    OwningTeam = InstigatorController.GetTeamNum();

	LI = ROTeamGame(Level.Game).LevelInfo;

     BatterySize=LI.GetBatterySize(OwningTeam);
     SalvoAmount=LI.GetSalvoAmount(OwningTeam);
     SpreadAmount=LI.GetSpreadAmount(OwningTeam);
     StrikeTemp=LI.GetStrikeDelay(OwningTeam); // Delay

    // Save artillery strike position to GRI
    ROGameReplicationInfo(Level.Game.GameReplicationInfo).ArtyStrikeLocation[OwningTeam] = location;

	if (FRand() < 0.5)
	{
	 	StrikeDelay =  StrikeTemp +  (StrikeTemp * (Frand() * 0.15));
	}
	else
	{
	 	StrikeDelay =  StrikeTemp -  (StrikeTemp * (Frand() * 0.15));
	}

	SetTimer(StrikeDelay, false);
}

function Destroyed()
{
    // Remove arty location from GRI
    ROGameReplicationInfo(Level.Game.GameReplicationInfo).ArtyStrikeLocation[OwningTeam] = vect(0,0,0);
    LastSpawnedShell = none;
    super.Destroyed();
}

// Cancel the strike. Are we using this? Ramm
function CallOffStrike()
{
   Destroy();
}

function timer()
{
	local vector AimVec;
	local ROVolumeTest RVT;
	local ROPlayer ROP;
	//local int OwningTeam, SalvoSize;

    // Hack: Lets find a better way to prevent arty from spilling to the next round.
    // Also kill the arty strike if the commander switches teams or leaves the server
    if ( (!ROTeamGame(Level.Game).IsInState('RoundInPlay'))
        || InstigatorController == none || InstigatorController.GetTeamNum() != OwningTeam )
    {
        if( LastSpawnedShell != none && !LastSpawnedShell.bDeleteMe )
        {
            LastSpawnedShell.Destroy();
        }

        Destroy();
        return;
    }

    RVT = Spawn(class'ROVolumeTest',self,,OriginalArtyLocation);

    // If the place this arty is falling has become a NoArtyVolume after the
    // strike was called, cancel the strike.
    if ((RVT != none && RVT.IsInNoArtyVolume()))
    {
        ROP = ROPlayer(InstigatorController);

        if ( ROP != none )
        {
            ROP.ReceiveLocalizedMessage(class'ROArtilleryMsg', 5);
        }

        RVT.Destroy();

        if( LastSpawnedShell != none && !LastSpawnedShell.bDeleteMe )
        {
            LastSpawnedShell.Destroy();
        }

        Destroy();
        return;
    }

    RVT.Destroy();



	if( SpawnCounter <= BatterySize)
	{
	    AimVec = vect(0,0,0);
	    AimVec.X += Rand(SpreadAmount);// was 500
	    if (Frand() > 0.5)
	    {
           AimVec.X *= -1;
	    }

	    AimVec.Y += Rand(SpreadAmount);
	    if (Frand() > 0.5)
	    {
           AimVec.Y *= -1;
	    }


        LastSpawnedShell = Spawn(class 'ROArtilleryShell',InstigatorController,, Location + AimVec, rotator(PhysicsVolume.Gravity));

        SpawnCounter++;
        SetTimer(FRand() * 1.5, false);
        return;
    }

    if( SalvoCounter < SalvoAmount )
    {
        SalvoCounter++;
        SpawnCounter = 0;
        SetTimer(Max(Rand(20),10), false);// Time between salvos
    }
    else
    {
    		Destroy();   // Hope this doesn't F anything up
    }
}

defaultproperties
{
     DrawType=DT_None
}
