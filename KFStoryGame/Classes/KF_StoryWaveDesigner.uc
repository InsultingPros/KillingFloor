/*
	--------------------------------------------------------------
	KF_StoryWaveDesigner
	--------------------------------------------------------------

	This actor provides level designers with a method of settings up
	waves in story missions. It is used in conjunction with either
	KFZombieVolumes or KFStoryZombieVolumes.

	note : This class just serves as a front end for level designers
	and a place to declare structs.

    All of the heavy lifting is done in KF_Wave_Controller

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryWaveDesigner extends Info
dependson(KFStoryGameInfo)
hidecategories(sound)
placeable;


enum ESpawnProgressionType
{
	Proceed_On_AllZEDSDead,
	Proceed_On_AllZEDsSpawned,
};



struct SWaveSpawn
{
    var()       array<string>                               SquadList;
    var         array<int>                                  SpawnedSquads;
    var         KFStoryGameInfo.SZEDSquadType               NextSpawnSquad;
    var   array<KFStoryGameInfo.SZEDSquadType>              AllSquads;
    var()       name                                        ZombieDeathEvent;
    var()       name                                        ZombieSpawnTag;
    var()       name                                        ZombieSpawnEvent;
    var()       float                                       SpawnInterval;
    var()       int                                         MaxZEDs;
    var()       bool                                        bNoDifficultyScaling;
    var()       bool                                        bRandomSquadsWithoutRepeats; // Squads will be used in a random order, but will use every squad in the list before starting to go through the list again
};

enum ESineWavePatternUsage
{
	SWP_StartAtMinRate,
	SWP_StartAtMaxRate,
	SWP_AlwaysFullSpeed,
};

struct SZEDWave
{
    var         bool                                        bKillStragglers;
    var()       array<name>                                 Wave_VolumeTags;
    var()       name                                        Wave_ActivationTag;
    var()       array<SWaveSpawn>                           Wave_Spawns;
    var         KF_Wave_Controller                          WaveController;
    var()       ESineWavePatternUsage                       SineWavePatternUsage;
};

/*==============================================================================*/

var  ()         array<SZEDWave>                             Waves;

var             int                                         CurrentWaveIdx;

enum EWaveProgressType
{
    Procceed_On_AllZEDsSpawned,
    Proceed_On_AllZEDsKilled,
};


var(Debug)        bool                                      bPrintDebugLogs;

/*==============================================================================*/




function Reset()
{
    local int i;

    for(i = 0 ; i < Waves.length ; i ++)
    {
        Waves[i].WaveController.Reset();
    }
}

function PostBeginPlay()
{
    if(KFStoryGameInfo(Level.Game) != none)
    {
        InitWaveControllers();
    }
}

function InitWaveControllers()
{
    local int i;

    for(i = 0 ; i < Waves.length ; i ++)
    {
       SpawnControllerForWave(i);
    }
}

function SpawnControllerForWave(int Index)
{
    Waves[Index].WaveController = Spawn(class 'KF_Wave_Controller',self);
    if(Waves[Index].WaveController != none)
    {
        Waves[Index].WaveController.SetOwningmanager() ;
        Waves[Index].WaveController.WaveIndex = Index ;
        Waves[Index].WaveController.Initialize();
    }
    else
    {
        log(" === WARNING === could not spawn a WaveController for : "@self@" at Wave Index : "@Index@"!",'Story_Debug');
    }
}


/*
==================================================================================
Handy functions ... mostly gonna query the Wave Controller here */

function  KF_Wave_Controller GetCurrentWaveController()
{
    return Waves[CurrentWaveIdx].WaveController ;
}

/* Returns the amount of time between ZED Spawns */
function float    GetAdjustedSpawninterval()
{
    return GetCurrentWaveController().GetSpawnInterval();
}

/* Grab the total number of ZEDs in the current wave */
function int     GetWaveMaxMonsters()
{
    return GetCurrentWaveController().GetMaxMonsters();
}

/* Grab the number of ZEDs left alive in the current wave */
function int     GetWaveRemainingMonsters()
{
    return GetCurrentWaveController().GetRemainingMonsters();
}

function bool    IsDirectingSpawnsFor( ZombieVolume TestVol)
{
    return GetCurrentWaveController().IsDirectingSpawnsFor(TestVol);
}

/*
function array<class <KFMonster> > GetCurrentZEDList()
{
    return GetCurrentWaveController().GetCurrentZEDList();
} */

function array<class <KFMonster> > GetNextSpawnSquad()
{
    return GetCurrentWaveController().NextSpawnSquad;
}

function int GetWaveByName(name WaveTag)
{
   local int i;

   for(i = 0 ; i < Waves.length ; i ++)
   {
      if(Waves[i].Wave_ActivationTag == WaveTag)
      {
         return i;
      }
   }

   return -1;
}



/*=====================================================================================
======================================================================================*/
// Events ==============================================================================


function Trigger( actor Other, pawn EventInstigator )
{
    GoToNextWave();
}

function GoToNextWave()
{
    if(CurrentWaveidx < Waves.length - 1)
    {
        GoToWave(Waves[CurrentWaveIdx + 1].Wave_ActivationTag);
    }
}

function GoToWave(name WaveTag)
{
    local int i;

    CurrentWaveIdx = GetWaveByName(WaveTag) ;

    /* Abort any other currently active waves in this designer*/
    for(i = 0 ; i < Waves.length ; i ++)
    {
        if(i != CurrentWaveIdx &&
        Waves[i].WaveController.bActive)
        {
            Waves[i].WaveController.AbortWave();
        }
    }
}

/*====================================================================================
======================================================================================*/


function GetEvents(out array<name> TriggeredEvents,  out array<name>  ReceivedEvents)
{
    local int i,idx;

    Super.GetEvents(TriggeredEvents,ReceivedEvents);

    for(i = 0 ; i < Waves.length ; i ++)
    {
        if(Waves[i].Wave_ActivationTag != '')
        {
            ReceivedEvents[ReceivedEvents.length] = Waves[i].Wave_ActivationTag ;
        }

        for(idx = 0 ; idx < Waves[i].Wave_Spawns.length ; idx ++)
        {
            if(Waves[i].Wave_Spawns[idx].ZombieSpawnEvent != '')
            {
                TriggeredEvents[TriggeredEvents.length] = Waves[i].Wave_Spawns[idx].ZombieSpawnEvent;
            }
            if(Waves[i].Wave_Spawns[idx].ZombieDeathEvent != '')
            {
                TriggeredEvents[TriggeredEvents.length] = Waves[i].Wave_Spawns[idx].ZombieDeathEvent;
            }
        }
    }
}

defaultproperties
{
     Texture=Texture'KFStoryGame_Tex.Editor.KF_StoryWaves_Ico'
     DrawScale=0.500000
}
