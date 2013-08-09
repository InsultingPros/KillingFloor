/*
	--------------------------------------------------------------
	KF_Wave_Controller
	--------------------------------------------------------------

    This actor does all the dirty work for the Wave Designer. It
    handles Timing for wave spawns, tracks the number of monsters
    in each wave and the wave spawn cycle.

    The Progression of a Wave goes something like :

    New Wave -->   New Cycle --->  Pick a Squad ---> Spawn Squad

    this repeats until the total number of ZEDs is equal to the
    Max monsters value set in the cycle.  Then we move on to the
    next cycle and repeat.

    It's worth noting that 'standard' KF  Waves would only have a
    single Spawn cycle per wave. Multiple cycles are only really
    needed for setting up complex waves where you want lots of
    variation in the frequency or type of monsters being spawned.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_Wave_Controller extends Actor
dependsOn(KFStoryGameInfo);

/*  we've spawned everything we can possibly spawn.  Tell the next controller to start doing its thing .. */
var         bool                                        bSpawningComplete;

var         KFStoryGameInfo                             StoryGI;

var array < class<KFMonster> >                          NextSpawnSquad;

/*===========================================================================================================
Wave Vars
============================================================================================================*/

/* array of all Zombie Volumes which will spawn ZEDs for this wave */
var         array<ZombieVolume>                         WaveVols;

/* Set by the Designer - reference to tag of volumes used in this wave */
var         array<name>                                 Wave_VolumeTags;

/* Total number of ZEDs which will be spawned for this wave */
var         int                                         Wave_ZEDTotal;

/* Total number of ZEDs remaining in this wave (sum of the total spawn count from all cycles)   */
var         int                                         Wave_RemainingZEDs;

/* Reference to the index of this Controller in it's owning Designer's Wave array */
var         int                                         WaveIndex;

/* number of ZEDs which were spawned by this Controller in the current wave */
var         int                                         RunningSpawnTotal;

/* Number of ZEDs left in the map after this wave ended */
var         int                                         NumStragglers;

/*==========================================================================================================
Spawn Cycle Vars
============================================================================================================*/

/*  index of the current SpawnGroup in this wave */
var         int                                         CurrentCycleIdx;

var         KFStoryGameInfo.SZEDSquadType               CurrentSquad;

var         array<KF_StoryWaveDesigner.SWaveSpawn>      AllSpawnCycles;

var         KF_StoryWaveDesigner.SWaveSpawn             CurrentSpawnCycle;

/* Wave Designer actor which this Controller belongs to */
var         private KF_StoryWaveDesigner                OwningManager;

/* Should we be spitting out ZEDs ? */
var         bool                                        bActive;

/* number of Spawn Cycles left to spawn for this wave */
var         int                                         RemainingSpawnCycles;

/* Number of ZEDs left in the current spawn cycle */
var         int                                         CycleRemainingZEDs;

var         int                                         Cycle_ZEDTotal;

var         ZombieVolume                                LastSpawningVolume;

var         int                                         NumFailedFindVolumeAttempts,MaxFailedFindVolumeAttempts;
var         int                                         NumFailedSquadSpawnAttempts,MaxFailedSquadSpawnAttempts;

var         float                                       WaveTimeElapsed, LastWaveSpawnTime;

var         KF_StoryWaveDesigner.ESineWavePatternUsage  CurrentSineWavePatternUsage;

/* We have finished spawning all the zeds in the current Squad we're trying to spawn */
var         bool                                        bFinishedLastSquadSpawn;

/* The name of the last squad we tried to spawn */
var         string                                      LastSpawnSquadName;


/*============================================================================================================= */

function Initialize()
{
	StoryGI = KFStoryGameInfo(level.Game);
    Tag = GetOwningManager().Waves[WaveIndex].Wave_ActivationTag ;

    /* Figure out which volumes will be used for s pawning in this wave */
    Wave_VolumeTags = GetOwningManager().Waves[WaveIndex].Wave_VolumeTags ;
    FindControlledVolumes();
}


/* Figure out which volumes will be used to spawn ZEDs for this wave */
function FindControlledVolumes()
{
    local ZombieVolume V;
    local int i;

    foreach AllActors(class 'ZombieVolume' , V)
    {
        for(i=0; i < Wave_VolumeTags.length ; i ++)
        {
            if(V.Tag == Wave_VolumeTags[i])
            {
                V.SetOwner(OwningManager);
                WaveVols[WaveVols.length] = V;
            }
        }
    }
}

function Reset()
{
    bSpawningComplete = false;
    bActive = false;
    Wave_ZEDTotal = 0;
    Cycle_ZEDTotal = 0;
    CycleRemainingZEDS = 0;
    Wave_RemainingZEDs = 0;
    CurrentCycleIdx = default.CurrentCycleIdx;
    RemainingSpawnCycles = 0;
    RunningSpawnTotal = 0;
    NumStragglers=0;
}


function SetOwningManager()
{
    OwningManager     =  KF_StoryWaveDesigner(Owner);
}

function KF_StoryWaveDesigner   GetOwningManager()
{
    return OwningManager;
}

function InitSpawns()
{
    local int i,idx;
    local int NewTotalZEDs;

    AllSpawnCycles          = GetOwningManager().Waves[WaveIndex].Wave_Spawns;
    RemainingSpawnCycles    = AllSpawnCycles.length;
    LastWaveSpawnTime = 0;
    CurrentSineWavePatternUsage = GetOwningManager().Waves[WaveIndex].SineWavePatternUsage;
    bFinishedLastSquadSpawn=true;

    // Scale the WaveTimeElapsed to modify where we start in the sine wave pattern
    if( CurrentSineWavePatternUsage == SWP_StartAtMinRate || CurrentSineWavePatternUsage == SWP_AlwaysFullSpeed )
    {
        WaveTimeElapsed = 0;
    }
    else if( CurrentSineWavePatternUsage == SWP_StartAtMaxRate )
    {
        WaveTimeElapsed = 40;
    }

    for(i = 0 ; i < RemainingSpawnCycles ; i ++)
    {
        for(idx = 0 ; idx < AllSpawnCycles[i].SquadList.length ; idx ++)
        {
            AllSpawnCycles[i].AllSquads[idx] = StoryGI.FindSquadByName(AllSpawnCycles[i].SquadList[idx]);
        }

        NewTotalZEDs += GetCycleMaxZEDs(i);
    }

    Wave_ZEDTotal      = NewTotalZEDs;
    Wave_RemainingZEDs = Wave_ZEDTotal;

    if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
    {
        log("Init spawns for wave : "@WaveIndex@" - Total Enemies for this wave will be : "@Wave_ZEDTotal,'Story_Debug');
    }
}


/* Updates Zombie Volume Events & Tags to match the settings for the current spawn cycle */
function UpdateVolumeTags(ZombieVolume V)
{
    V.ZombieDeathEvent = CurrentSpawnCycle.ZombieDeathEvent;
    V.ZombieSpawnTag   = CurrentSpawnCycle.ZombieSpawnTag;
    V.ZombieSpawnEvent = CurrentSpawnCycle.ZombieSpawnEvent;
}

/* Returns true if this wave spawns endless enemies */
function bool InfiniteSpawns()
{
    return GetMaxMonsters() == 0 || GetCycleMaxZEDs(CurrentCycleIdx) == 0 ;
}


function AllSpawningFinished()
{
    bSpawningComplete = true;

    if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
    {
        log("=========================================================",'Story_Debug');
        log(self@"  - Wave : "@WaveIndex@" has spawned all ("@RunningSpawnTotal@") its ZEDs. ",'Story_Debug');
    }

    NumStragglers = StoryGi.NumMonsters;
    log("Number of stragglers at the time this Wave ended was : "@NumStragglers,'Story_Debug');
}


function bool IsDirectingSpawnsFor( ZombieVolume TestVol)
{
    local int i;

    for(i = 0 ; i < WaveVols.length ; i ++)
    {
       if(WaveVols[i] == TestVol)
       {
           return true;
       }
    }

    return false;
}


/* Triggering an active wave aborts it.  Triggering an inactive wave starts it up */
function Trigger( actor Other, pawn EventInstigator )
{
   if(!bActive)
   {
      StartWave(Other);
   }
   else
   {
      AbortWave(Other);
   }
}


function StartWave(optional Actor TriggeringActor)
{
    if(bSpawningComplete)
    {
        Reset();
    }

    if(!bSpawningComplete)
    {
        bActive = true;

        if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
        {
            log("======================================================================",'Story_Debug');
            log("Starting  :"@Tag@" for Wave Designer : "@GetOwningManager()@" - Instigator : "@TriggeringActor,'Story_Debug');
        }

        /* Set up the Spawn Cycles & Calculate the ZED totals */
        InitSpawns();
        StartNextSpawnCycle();
        GetOwningManager().GoToWave(tag);

        SetTimer(GetSpawninterval(),false);
        DoSquadSpawn();
    }
}
function AbortWave(optional Actor TriggeringActor)
{
    bActive = false;

    if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
    {
        log("======================================================================",'Story_Debug');
        log("Stopping :"@Tag@" for Wave Designer : "@GetOwningManager()@" - Instigator : "@TriggeringActor,'Story_Debug');
    }

   /* We're trying to end this wave but the spawning hasn't yet finished. Cut it off */
    AllSpawningFinished();

/*    if(GetOwningManager().Waves[WaveIndex].bKillStragglers)
    {
        KillStragglers();
    }
*/
}

/* Timed ZED spawning*/
function Timer()
{
    if(!bSpawningComplete && bActive)
    {
        // Increment the wave time counter
        if( LastWaveSpawnTime > 0 )
        {
            WaveTimeElapsed += (Level.TimeSeconds - LastWaveSpawnTime);
        }

        DoSquadSpawn();
        SetTimer(GetSpawninterval(),false);
    }
}

/* We're moving to another wave - Kill off the remaining zeds as elegantly as possible ... */
function KillStragglers()
{
    local int i;
    local int idx;
    local KFMonster Straggler;
    local array<KFMonster>  MarkedForDeath;

    // - need to set this before we start killing zeds off or the array size will change while we're iterating it ...
    for(i = 0 ; i < WaveVols.length ; i ++)
    {
        for(idx = 0 ; idx < WaveVols[i].ZEDList.length ; idx ++)
        {
            Straggler = WaveVols[i].ZEDList[idx] ;
            if(Straggler != none && Straggler.Event == CurrentSpawnCycle.ZombieDeathEvent &&
             !IsVisibleToAnyone(Straggler) )
            {
                Straggler.Event = '';
                MarkedForDeath[MarkedForDeath.length] = Straggler;
            }
        }
    }

    i= 0;
    for(i = 0 ; i < MarkedForDeath.length ; i ++)
    {
        Straggler = MarkedForDeath[i];
        if(Straggler != none)
        {
            Straggler.Died(Straggler.Controller, class'Gibbed', Straggler.Location );
        }
    }
}

/* Returns true if the supplied actor is visible to any player on the server */
function   bool IsVisibleToAnyone(Pawn A)
{
    local Controller C;
    local KFPlayerController_Story PC;
    local float MinKillDistSq;

    MinKillDistSq = 1000 * 1000;

	for( C=Level.ControllerList; C!=None; C=C.NextController )
	{
        PC = KFPlayerController_Story(C);
        if(PC != none)
        {
            if(PC.HasLineOfSightTo(A.Location + (vect(0,0,1) * (A.CollisionHeight/2))) &&
            VSizeSquared(A.Location - PC.CalcViewLocation) < MinKillDistSq)
            {
                return true;
            }
        }
	}

    return false;
}

/* Returns true if the number of monsters currently in play exceeds the total limit as defined in the Level Rules.
This is primarily for performance reasons ... */

function bool  MaxMonstersAtOnce(int NewMonsters, optional out Int ClampedNewMonsters)
{
    local bool bReachedMax;

    if(StoryGI != none)
    {
        bReachedMax = Max(StoryGI.NumMonsters,0) + NewMonsters > StoryGI.StoryRules.MaxEnemiesAtOnce ;

        if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
        {
            log("Current Monsters : "@Max(StoryGI.NumMonsters,0)@"Wave Max : "@GetMaxMonsters()@" Level Max : "@StoryGI.StoryRules.MaxEnemiesAtOnce,'Story_Debug');
        }

        if(bReachedMax)
        {
            ClampedNewMonsters = Min(NewMonsters,StoryGI.StoryRules.MaxEnemiesAtOnce - Max(StoryGI.NumMonsters,0));
            return true ;
        }
    }

    return false;
}

/* Builds a squad and passes it to SpawnASquad() */
function DoSquadSpawn()
{
    local int NumToSpawn,ClampedMonsters;
    local int IgnoreZEDLimit;
    local string SquadName;
    local int I;

    if(bSpawningComplete)
    {
        return;
    }

    LastWaveSpawnTime = Level.TimeSeconds;

    if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
    {
        log("**** DO SQUAD SPAWN *******************************************************",'Story_Debug');
    }

    if( NextSpawnSquad.length > 0 && !bFinishedLastSquadSpawn )
    {
        // NextSpawnSquad needs to finish spawning the last spawn squad we tried!
        SquadName = LastSpawnSquadName;
    }
    else
    {
        NextSpawnSquad = BuildNextSpawnSquad(IgnoreZedLimit,SquadName);
        LastSpawnSquadName = SquadName;
        bFinishedLastSquadSpawn=false;
    }
    NumToSpawn = NextSpawnSquad.length;

    /* Make sure the squad size never exceeds the number of guys remaining to spawn */
    if(!InfiniteSpawns())
    {
        NumToSpawn = Min(NumToSpawn, GetRemainingMonstersInCycle());
    }

    /* Make sure the squad size never exceeds the total max enemies value in the level rules */
    if(IgnoreZEDLimit == 0 && MaxMonstersAtOnce(NumToSpawn,ClampedMonsters))
    {
        log("DoSquadSpawn want to spawn "$NumToSpawn$" can only spawn "$ClampedMonsters,'Story_Debug');
        for(i=0; i < NextSpawnSquad.length ; i ++)
        {
            if( i < ClampedMonsters )
            {
                log("DoSquadSpawn wants to spawn "$NextSpawnSquad[i],'Story_Debug');
            }
            else
            {
                log("DoSquadSpawn wants to spawn "$NextSpawnSquad[i]$" but can't because there are too many monsters already",'Story_Debug');
            }
        }
        NumToSpawn = ClampedMonsters;
    }
    else
    {
        for(i=0; i < NextSpawnSquad.length ; i ++)
        {
            log("DoSquadSpawn wants to spawn "$NextSpawnSquad[i],'Story_Debug');
        }
    }

    if(NumToSpawn > 0)
    {
       SpawnASquad(NumToSpawn,SquadName);
    }
}

function bool SpawnASquad(int NumDesired, optional string SquadName)
{
    local ZombieVolume   SpawnVol;
    local int NumSpawned;
    local int Diff;
    local int i;


    // Log what the squad is going to be when we spawn it

    for(i=0; i < NextSpawnSquad.length ; i ++)
    {
        log("SpawnASquad wants to spawn "$NextSpawnSquad[i],'Story_Debug');
    }

    StoryGI.NextSpawnSquad = NextSpawnSquad;         // needs to be set *before* we look for a Zombie Volume, as RateZombieVolume() checks this array

    SpawnVol = GetASpawnVolume();
    if(SpawnVol != none )
    {
        NumFailedFindVolumeAttempts = 0;
        LastSpawningVolume = SpawnVol ;
        UpdateVolumeTags(SpawnVol);

        /* Perform the actual spawn */
        StoryGI.SpawnZEDsInVolume(SpawnVol,NumDesired,NumSpawned,true);

        if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
        {
            log("*** Spawned : "@NumSpawned@" ZEDs for Squad : "@SquadName,'Story_Debug');
        }

        RunningSpawnTotal += NumSpawned ;
        UpdateRemainingZEDs(NumSpawned);

        Diff = Max(NumDesired - NumSpawned,0);

        if(Diff == 0 )
        {
            // Only say the squad spawn is complete if all zeds from the squad have spawned
            if( StoryGI.NextSpawnSquad.length == 0 )
            {
                OnSquadSpawnComplete(SquadName);
            }
            else
            {
                // Make sure you use the squad from the Story GI before you recurse
                // as it has had the zeds you already spawned removed
                NextSpawnSquad  = StoryGI.NextSpawnSquad;
            }
            NumFailedFindVolumeAttempts = 0;
            return true;
        }
        else
        {
            if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
            {
                log("Wanted to spawn"@NumDesired@" zeds, but could only spawn : "@NumSpawned,'Story_Debug');
                log(" Trying again with : "@Diff@" Zeds ... ", 'Story_Debug');
            }

            // Make sure you use the squad from the Story GI before you recurse
            // as it has had the zeds you already spawned removed
            NextSpawnSquad  = StoryGI.NextSpawnSquad;

            // Don't let this infinitely recurse and crash the game, give up
            // if it can't spawn.
            if(NumFailedSquadSpawnAttempts < MaxFailedSquadSpawnAttempts)
            {
                SpawnASquad(Diff,SquadName);  // recurse.
            }
            else
            {
                if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
                {
                    Log(" *** CRITICAL SPAWNING FAILURE.   could not spawn : "@SquadName@"in,  after : "@NumFailedSquadSpawnAttempts@" attempts!",'Story_Debug');
                }
            }
        }
    }
    else
    {
        NumFailedFindVolumeAttempts ++;
        if(NumFailedFindVolumeAttempts < MaxFailedFindVolumeAttempts)
        {
            SpawnASquad(NumDesired,SquadName);  // recurse.
        }
        else
        {
            if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
            {
                Log(" *** CRITICAL SPAWNING FAILURE.   could not find a volume to spawn : "@SquadName@"in,  after : "@NumFailedFindVolumeAttempts@" attempts!",'Story_Debug');
            }
        }
    }

    return false;
}

function UpdateRemainingZEDs(int NumSpawned)
{
    CycleRemainingZEDs = Max(CycleRemainingZEDs - NumSpawned,0);
    Wave_RemainingZEDs = Max(Wave_RemainingZEDs - NumSpawned,0);
}

/* A ZED Squad was just spawned successfully . Increment the appropriate values
to keep the spawn cycle moving */

function OnSquadSpawnComplete(optional string SquadName)
{
    local int SquadIdx;

    log(SquadName@" just spawned successfully!", 'Story_Debug');

    bFinishedLastSquadSpawn=true;

    if(SquadName != "")
    {
        FindSquadByName(SquadName,SquadIdx);
        CurrentSpawnCycle.AllSquads[SquadIdx].LastSquadSpawnTime = Level.TimeSeconds;
    }

    if(GetRemainingMonstersInCycle() == 0 )
    {
        StartNextSpawnCycle();
    }
}

function StartNextSpawnCycle()
{
    local int NumSpawnCycles;

    NumSpawnCycles = AllSpawnCycles.length ;
    if(RemainingSpawnCycles > 0 )
    {
        CurrentCycleIdx                 = Min(CurrentCycleIdx + 1 , NumSpawnCycles-1);
        CurrentSpawnCycle               = AllSpawnCycles[CurrentCycleIdx] ;
        RemainingSpawnCycles            = Max(RemainingSpawnCycles - 1,0) ;
        Cycle_ZEDTotal                  = GetCycleMaxZEDs(CurrentCycleIdx);
        CycleRemainingZEDs              = Cycle_ZEDTotal;
        CurrentSpawnCycle.SpawnedSquads.Length = 0;
    }
    else
    {
        if(GetRemainingMonsters() == 0 &&
        !InfiniteSpawns() )
        {
            AllSpawningFinished();
        }
    }
}

/* Find a volume to spawn the next squad of ZEDs in */
function ZombieVolume   GetASpawnVolume()
{
    local ZombieVolume  SpawnVol;
    local bool bSpawningPatriarch;

    bSpawningPatriarch     = SquadContainsZED(NextSpawnSquad,class 'ZombieBoss');
    SpawnVol               = RateVolumes(,bSpawningPatriarch);

    if(SpawnVol == none)
    {
        if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
        {
            log("== WARNING : "@self@" could not find a suitable spawn volume for : "@CurrentSquad.Squad_Name,'Story_Debug');
        }
    }

    return SpawnVol ;
}


function ZombieVolume RateVolumes(optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{
	local ZombieVolume BestZ;
	local float BestScore,tScore;
	local int i,l;
	local Controller C;
	local array<Controller> CL;
	local int NumInvalidvols;

	// First pass, pick a random player.
	for( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health>0 )
			CL[CL.Length] = C;
	}
	if( CL.Length>0 )
		C = CL[Rand(CL.Length)];
	else if( C==None )
		return None; // Shouldnt get to this case, but just to be sure...

	// Second pass, figure out best spawning point.
	l = WaveVols.length ;
//	log(self@" RateVolumes :: Number of volumes to choose from : "@l);
	if(l == 0)
	{
        if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
        {
	       log(" WARNING -  NO ZOMBIE VOLUMES ASSOCIATED WITH WAVE : "@WaveIndex@" OF :"@GetOwningManager(),'Story_Debug');
        }

        return none;
	}
	for( i=0; i<l; i++ )
	{
        tScore = WaveVols[i].RateZombieVolume(StoryGI,LastSpawningVolume,C,bIgnoreFailedSpawnTime, bBossSpawning);

		if( tScore<0 )
		{
            NumInvalidVols ++;
			continue;
		}

        if( BestZ==None || (tScore>BestScore) )
		{
			BestScore = tScore;
			BestZ = WaveVols[i];
		}
	}

//	log(self@" RateVolumes :: Number of invalid volumes : "@NumInvalidVols);


	return BestZ;
}

/* Returns true if the supplied monster squad has a monster of the specified type in it */
function bool SquadContainsZED(array < class<KFMonster> > CheckSquad, class <KFMonster> ClassType)
{
    local int i;

    for(i = 0 ; i < CheckSquad.length ; i ++)
    {
       if(ClassisChildOf(CheckSquad[i],ClassType))
       {
           return true;
       }
    }

    return false;
}

/* looks up a squad of the supplied name in the Current Spawn Cycle's cached Squads list */

function KFStoryGameInfo.SZEDSquadType     FindSquadByName(string SquadName, optional out int Index)
{
    local int i;
    local KFStoryGameInfo.SZEDSquadType ExportSquad;

    for(i = 0 ; i < CurrentSpawnCycle.AllSquads.length ; i ++)
    {
        if(CurrentSpawnCycle.AllSquads[i].Squad_Name == SquadName)
        {
            Index = i;
            ExportSquad = CurrentSpawnCycle.AllSquads[i] ;
            break;
        }
    }

    if(ExportSquad.Squad_Name == "")
    {
       log("Warning - could not find a suitable struct for Squad of Name : "@SquadName);
    }

    return ExportSquad;
}


function float GetSpawnInterval()
{
    local float AdjustedInterval;
    local bool bFullSpeedSpawning;

    // Set full speed spawning if we want that
    if( CurrentSineWavePatternUsage == SWP_AlwaysFullSpeed )
    {
        bFullSpeedSpawning = true;
    }

    if(StoryGI != none)
    {
        AdjustedInterval = StoryGI.GetAdjustedSpawnInterval(CurrentSpawnCycle.SpawnInterval, WaveTimeElapsed, bFullSpeedSpawning) ;
    }

    if(GetOwningManager() != none &&
    GetOwningManager().bPrintDebugLogs)
    {
    	log(tag@"--> Next ZED Spawn will occur in : "@AdjustedInterval@" Seconds ... ",'Story_Debug');
    }

    return AdjustedInterval;
}

/* Returns the total number of ZEDs that will spawn in this wave*/
function   int GetMaxMonsters()
{
    return Wave_ZEDTotal;
}


/* Returns the total number of ZEDs to spawn in a given cycle,  taking into account player & game difficulty scaling */
function int GetCycleMaxZEDs(int CycleIndex)
{
    local int AdjustedMaxZEDs;

    AdjustedMaxZEDs = AllSpawnCycles[CycleIndex].MaxZEDs;

    /* Infinite spawns, dont bother applying difficulty scaling */
    if(AdjustedMaxZEDs == 0)
    {
        return 0;
    }

    if(!AllSpawnCycles[CycleIndex].bNoDifficultyScaling)
    {
        AdjustedMaxZEDs *= StoryGI.GetZEDCountModifier() ;
    }

    AdjustedMaxZEDs = Max(AdjustedMaxZEDs,1);

    return AdjustedMaxZEDs;
}

function   int GetRemainingMonsters()
{
    return Wave_RemainingZEDs;
}

function   int GetRemainingMonstersInCycle()
{
    return CycleRemainingZEDs;
}

/* Since the priority enums aren't ordered from low to high ... */
function    int GetOrderedPriority(int PriorityVal)
{
    switch(PriorityVal)
    {
        case 0 :  return 2;     // Normal
        case 1 :  return 1;     // Low
        case 2 :  return 0;     // VeryLow
        case 3 :  return 3;     // High
        case 4 :  return 4;     // VeryHigh
    }

    return -1;
}

function array<class <KFMonster> > BuildNextSpawnSquad(optional out int bIgnoreZEDLimit, optional out string ChosenSquadName)
{
    local array<class <KFMonster> >  ExportSquad;
    local int i,idx,RandIdx,BestIdx;
    local int NumZEDs;
    local float BestRating;
    local array<Float> SquadRatings;
    local int PriorityVal;
    local float RandMin,RandMax;
    local array<string> VeryLowSquads,LowSquads,NormalSquads,HighSquads,VeryHighSquads,SquadsToRate;
    local KFStoryGameInfo.SZEDSquadType ZSquad;
    local int j;
    local bool bSkipThisSquad;
    local array<int> SquadIndexes;

    if(GetOwningManager() != none && GetOwningManager().bPrintDebugLogs)
    {
        log("**** BUILD NEXT SQUAD *******************************************************",'Story_Debug');
    }

    if( CurrentSpawnCycle.bRandomSquadsWithoutRepeats )
    {
        if( CurrentSpawnCycle.SquadList.length == CurrentSpawnCycle.SpawnedSquads.Length )
        {
            CurrentSpawnCycle.SpawnedSquads.Length = 0;
            log("Resetting SpawnedSquad list as we've already been through every squad",'Story_Debug');
        }

        for(i = 0 ; i < CurrentSpawnCycle.SquadList.length ; i ++)
        {
            bSkipThisSquad = false;

            // see if we should skip this squad because its already been used
            for(j = 0 ; j < CurrentSpawnCycle.SpawnedSquads.length ; j ++)
            {
                if( CurrentSpawnCycle.SpawnedSquads[j] == i )
                {
                    bSkipThisSquad = true;
                }
            }

            if( !bSkipThisSquad )
            {
                SquadsToRate[SquadsToRate.length] = CurrentSpawnCycle.SquadList[i];
                SquadIndexes[SquadsToRate.length - 1] = i;
                log(">> Adding Squad to Randomly Cycle Through :: "@CurrentSpawnCycle.SquadList[i],'Story_Debug');
            }
            else
            {
                log("<< Skipping already used Squad :: "@CurrentSpawnCycle.SquadList[i],'Story_Debug');
            }
        }

        BestIdx = Rand(SquadsToRate.length);
        // Add this squad to the list of squads that already have been used
        CurrentSpawnCycle.SpawnedSquads[CurrentSpawnCycle.SpawnedSquads.length] = SquadIndexes[BestIdx];
        log("** Used Squad :: "@SquadsToRate[BestIdx],'Story_Debug');
    }
    else
    {
        /* We only want to rate one squad from each Priority pool, if we allow multiple squads from the same
        pool to be rated, it'll throw off the rating system */

        /* First of all, let's break the squadlist up by priority group */

        for(i = 0 ; i < CurrentSpawnCycle.SquadList.length ; i ++)
        {
            ZSquad = FindSquadByName(CurrentSpawnCycle.SquadList[i]);
            log(CurrentSpawnCycle.SquadList[i]@" Last Spawned time : "@ZSquad.LastSquadSpawnTime@" :: MinSpawnInterval : "@ZSquad.MinTimeBetweenSpawns);

            /* Has enough time passed between spawns of this squad? */
            if(ZSquad.LastSquadSpawnTime > 0 && Level.TimeSeconds - ZSquad.LastSquadSpawnTime < ZSquad.MinTimeBetweenSpawns)
            {
                log("Rejected Spawn of : "@CurrentSpawnCycle.SquadList[i]@" because it spawned : "@Level.TimeSeconds-ZSquad.LastSquadSpawnTime@" seconds ago.  Next Allowed Spawn in : "@ZSquad.MinTimeBetweenSpawns - (Level.TimeSeconds - ZSquad.LastSquadSpawnTime));
                continue;   // not long enough, skip this one.
            }

            PriorityVal = FindSquadByName(CurrentSpawnCycle.SquadList[i]).Squad_Priority;
            switch(PriorityVal)
            {
                case 0  :   NormalSquads[NormalSquads.length] = CurrentSpawnCycle.SquadList[i];               // Normal
                            break;

                case 1  :   LowSquads[LowSquads.length] = CurrentSpawnCycle.SquadList[i];                     // Low
                            break;

                case 2  :   VeryLowSquads[VeryLowSquads.length] = CurrentSpawnCycle.SquadList[i];             // VeryLow
                            break;

                case 3  :   HighSquads[HighSquads.length] = CurrentSpawnCycle.SquadList[i];                   // High
                            break;

                case 4  :   VeryHighSquads[VeryHighSquads.length] = CurrentSpawnCycle.SquadList[i];           // VeryHigh
                            break;
            }
        }

        /* Add one squad from each priority group to the Squads to rate array. */

        if(VeryLowSquads.length > 0)
        {
            SquadsToRate[SquadsToRate.length]= VeryLowSquads[Rand(VeryLowSquads.length)] ;
        }
        if(LowSquads.length > 0)
        {
            SquadsToRate[SquadsToRate.length] = LowSquads[Rand(LowSquads.length)] ;
        }
        if(NormalSquads.length > 0)
        {
            SquadsToRate[SquadsToRate.length] = NormalSquads[Rand(NormalSquads.length)] ;
        }
        if(HighSquads.length > 0)
        {
            SquadsToRate[SquadsToRate.length] = HighSquads[Rand(HighSquads.length)] ;
        }
        if(VeryHighSquads.length > 0)
        {
            SquadsToRate[SquadsToRate.length] = VeryHighSquads[Rand(VeryHighSquads.length)] ;
        }

        /* Now we're gonna calculate the rating values for each Squad */
        for(i = 0 ; i < SquadsToRate.length ; i ++)
        {
            PriorityVal = FindSquadByName(SquadsToRate[i]).Squad_Priority;

            switch(PriorityVal)
            {
                case 0  :   RandMin = 0.5;                  // Normal
                            RandMax = 1;
                            break;

                case 1  :   RandMin = 0.25;                 // Low
                            RandMax = 1;
                            break;

                case 2  :   RandMin = 0.1;                 // VeryLow
                            RandMax = 1;
                            break;

                case 3  :   RandMin = 0.75;                 // High
                            RandMax = 1;
                            break;

                case 4  :   RandMin = 0.9;                 // VeryHigh
                            RandMax = 1;
                            break;
            }

            SquadRatings[i] = RandRange(RandMin,RandMax);
        }

        /* Iterate the squad ratings and pick the highest one.  We'll be spawning that */
        for(i = 0 ; i < SquadRatings.length ; i ++)
        {
            log("GetNextSquad ::: "@SquadsToRate[i]@" rolled a : "@SquadRatings[i],'Story_Debug');

            if(i == 0 ||
            SquadRatings[i] > BestRating)
            {
                BestRating = SquadRatings[i];
                BestIdx = i;
            }
        }

        log("GetNextSquad ::: "@"Selected -> "@SquadsToRate[BestIdx]@" to spawn.  It's priority is : "@string(GetEnum(Enum 'KFStoryGameInfo.EZEDSpawnPriority',FindSquadByName(SquadsToRate[BestIdx]).Squad_Priority)),'Story_Debug');
    }

    RandIdx = BestIdx;
    ZSquad = FindSquadByName(SquadsToRate[RandIdx]);
    CurrentSquad = ZSquad;
    ChosenSquadName = CurrentSquad.Squad_Name;
    bIgnoreZEDLimit = int(CurrentSquad.bIgnoreLevelMaxZEDs) ;

    for(i = 0 ; i < CurrentSquad.Squad_ZEDs.Length ; i ++)
    {
        NumZEDs = CurrentSquad.Squad_ZEDS[i].NumToSpawn;
        for(idx = 0 ; idx < NumZEDs ; idx ++)
        {
            ExportSquad[ExportSquad.length] = CurrentSquad.Squad_ZEDs[i].ZEDClass ;
        }
    }

    return ExportSquad ;
}

defaultproperties
{
     CurrentCycleIdx=-1
     MaxFailedFindVolumeAttempts=10
     MaxFailedSquadSpawnAttempts=25
     bFinishedLastSquadSpawn=True
     bHidden=True
     RemoteRole=ROLE_None
}
