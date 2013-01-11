class KFGameType extends Invasion
	config;

#exec OBJ LOAD FILE=KillingFloorTextures.utx
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
//#exec OBJ LOAD FILE=KillingFloorManorTextures.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=KFX.utx
#exec OBJ LOAD FILE=KFMaterials.utx
#exec OBJ LOAD FILE=KillingFloorLabTextures.utx
#exec OBJ LOAD FILE=KillingFloorStatics.usx
//#exec OBJ LOAD FILE=KillingFloorManorStatics.usx
//#exec OBJ LOAD FILE=KillingFloorLabStatics.usx
#exec OBJ LOAD FILE=EffectsSM.usx
#exec OBJ LOAD FILE=PatchStatics.usx
#exec OBJ LOAD FILE=KF_pickups2_Trip.usx
#exec OBJ LOAD FILE=KF_generic_sm.usx
#exec OBJ LOAD FILE=KF_Weapons_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons2_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons3rd_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons3rd2_Trip_T.utx
#exec OBJ LOAD FILE=KFPortraits.utx
#exec OBJ LOAD FILE=KF_Soldier_Trip_T.utx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T_Two.utx
#exec OBJ LOAD FILE=kf_generic_t.utx
#exec OBJ LOAD FILE=kf_gore_trip_sm.usx
#exec OBJ LOAD FILE=kf_fx_gore_T_Two.utx
#exec OBJ LOAD FILE=KF_PlayerGlobalSnd.uax
#exec OBJ LOAD FILE=KF_MAC10MPTex.utx
#exec OBJ LOAD FILE=KF_MAC10MPAnims.ukx
#exec OBJ LOAD FILE=KF_MAC10MPSnd.ukx

var const localized string SandboxGroup;

var() WaveInfo ShortWaves[16];	// Wave config for a short game
var() WaveInfo NormalWaves[16];	// Wave config for a normal game
var() WaveInfo LongWaves[16];	// Wave config for a long game

const GL_Short	= 0;
const GL_Normal	= 1;
const GL_Long	= 2;
const GL_Custom	= 3;

var()	globalconfig int	KFGameLength;  		// The length for this game, adds/removes waves
var()	globalconfig bool	bDisableZedSpawning;// Disable zed spawning for debugging



struct IMClassList
{
	var class<KFMonster> MClass;
	var string ID;
};
struct MSquadsList
{
	var array< class<KFMonster> > MSquad;
};
var array<MSquadsList> InitSquads;

var class<KFMonstersCollection> MonsterCollection;

var     int                     FinalSquadNum;          // The final squad num we are on

var     bool    bUsedSpecialSquad;  // Tracks if the special squad has been used already this time through the list
var     int     SpecialListCounter; // Keep track of how many time's we've been through the list

var transient int EventNum;

var string HumanName[4];
var string ZombieName[4];
var int Time,LobbyTimeCounter;
var int ZombiesKilled;
var int TotalMaxMonsters;
var int SquadsToSpawn;
var bool rewardFlag;
var bool bUpdateViewTargs,bNotifiedLastManStanding;
var KFMusicTrigger MapSongHandler;

var PlayerReplicationInfo KFPRIArray[16];

const MAX_BUYITEMS=200;

const KFPROPNUM = 16;
var localized string KFSurvivalPropText[KFPROPNUM];
var localized string KFSurvivalDescText[KFPROPNUM];

var	localized string NoLateJoiners;

var() globalconfig float WaveStartSpawnPeriod;
var() globalconfig int StartingCash,MinRespawnCash;  // Cash amount Players start with to buy equipment
var bool bNoBots; // If true, no friendly bot AI
var() globalconfig bool bUseEndGameBoss,bRespawnOnBoss;
var() globalconfig bool bNoLateJoiners;
var() localized string BossBattleSong;
var globalconfig string TmpWavesInf,TmpSquadsInf,TmpMClassInf;

// Versions of the config vars that we'll hard code for non-custom
// game settings, modifying some for each difficulty level;

var()   int     StartingCashBeginner, StartingCashNormal, StartingCashHard, StartingCashSuicidal, StartingCashHell; // The starting cash for the different difficulty levels
var()   int     MinRespawnCashBeginner, MinRespawnCashNormal, MinRespawnCashHard, MinRespawnCashSuicidal, MinRespawnCashHell; // The starting cash for the different difficulty levels
var()   int     TimeBetweenWavesBeginner, TimeBetweenWavesNormal, TimeBetweenWavesHard, TimeBetweenWavesSuicidal, TimeBetweenWavesHell;

var()   array<string>       StandardMonsterSquads;  // The standard monster squads
var()   int                 StandardMaxZombiesOnce; // Standard max zombies that can be in play at once

var(LoadingHints) localized array<string> KFHints;

var() globalconfig array<string> MonsterSquad;

var array<int> SquadsToUse; // Pointers
var int InitialSquadsToUseSize;
var array < class<KFMonster> > NextSpawnSquad;
var array<ShopVolume> ShopList;

var ZombieVolume LastSpawningVolume;
var array<ZombieVolume> ZedSpawnList;

var byte TraderProblemLevel;
var bool bTradingDoorsOpen;

var class<AIController>ControllerClass;
var string ControllerClassName;

var float LastWaveStartTime;

var() globalconfig int LobbyTimeOut; // Number of Seconds after someone has gone to a Ready state that the game auto-begins.
var() globalconfig int TimeBetweenWaves;    // Value (in seconds) for how long there is between waves.

var float StoredRadius, StoredHeight;

var bool MusicPlaying,CalmMusicPlaying;

var KFLevelRules KFLRules;

var bool bBotsAdded;

var config bool bEnemyHealthBars;

var ZombieVolume LastZVol;

var array<PlayerDeathMark> DeathMarkers; // for zombie eating.

var() array<string> AvailableChars;
var() array< Class<KFVeterancyTypes> > LoadedSkills;
var() globalconfig int MaxZombiesOnce;

var bool bWaveBossInProgress,bHasSetViewYet,bBossHasSaidWord;
var KFMonster ViewingBoss;

// ZEDTime - slomo system
var     bool    bZEDTimeActive;			// We're currently in a ZedTime slomo event
var     float   CurrentZEDTimeDuration;	// Remaining time of current ZedTime event
var()   float   ZEDTimeDuration;		// How long a ZedTime slomo event will last
var()   float   ZedTimeSlomoScale;		// What percentage of normal game speed to slow down the game during ZedTime
var     float   LastZedTimeEvent;		// The last time we had a Zed Time event
var		int		ZedTimeExtensionsUsed;	// Number of Zed Time extensions used(Chaining effect for killing other Zeds while Zed Time is active)
var     bool    bSpeedingBackUp;        // We're coming out of zed time

// Pickup Management
var	array<KFRandomItemSpawn>	WeaponPickups;
var	array<KFAmmoPickup>			AmmoPickups;

// Voice Messages
var	bool	bDidTraderMovingMessage;
var	bool	bDidMoveTowardTraderMessage;
var	bool	bDidSpottedCrawlerMessage;
var	bool	bDidStalkerInvisibleMessage;
var	bool	bDidSpottedGorefastMessage;
var	bool	bDidSpottedSirenMessage;
var	bool	bDidSirenScreamMessage;
var	bool	bDidSpottedScrakeMessage;
var	bool	bDidSpottedFleshpoundMessage;
var	bool	bDidKillStalkerMeleeMessage;
var	float	LastBurnedEnemyMessageTime;
var	float	BurnedEnemyMessageDelay;

//Hints
var		float	HintTime_1;
var		float	HintTime_2;
var 	bool 	bShowHint_2;
var 	bool	bShowHint_3;

// Wave Money Debugging
var     bool    bDebugMoney;            // Whether or not to track the money
var()   int     TotalPossibleWaveMoney; // How much money could be earned in this wave
var()   int     TotalPossibleMatchMoney;// How much money could be earned in this match

var()   float   SineWaveFreq;           // Controls the frequency of the zombie spawning sine wave. This is used to increase/decrease speed and intensity of zombie spawning to give the gameplay peaks and valleys
var()   float   WaveTimeElapsed;        // How long this wave has been going on

var	array<class<Weapon> >	InstancedWeaponClasses;

/* AI -- Should ZED controllers query the pawns they are attacking to assess threat priority?   -  NOTE:   currently only enabled in story mode gametype*/
var bool                    bUseZEDThreatAssessment;

/* Mod support for steam based events */

struct MClassTypes
{
	var() config string MClassName,MID;
};
var() globalconfig array<MClassTypes> MonsterClasses;
var() string EndGameBossClass;


// Store info for a special squad we want to spawn outside of the normal wave system
struct SpecialSquad
{
	var array<string> ZedClass;
	var array<int> NumZeds;
};

// Special squads are used to spawn a squad outside of the normal wave system so
// we have a bit more control. Basically. these will only spawn towards the
// end of the normal squad list. This way you don't end up with a bunch of really
// beast Zeds spawning one right after the other> It also guarantees that this
// squad will always get used - Ramm
var     array<SpecialSquad>     SpecialSquads;          // The currently used SpecialSquad array
var     array<SpecialSquad>     ShortSpecialSquads;     // The special squad array for a short game
var     array<SpecialSquad>     NormalSpecialSquads;    // The special squad array for a normal game
var     array<SpecialSquad>     LongSpecialSquads;      // The special squad array for a long game

var     array<SpecialSquad>     FinalSquads;            // Squads that spawn with the Patriarch

var()   array<MClassTypes>  StandardMonsterClasses; // The standard monster classed



// Stub
static function Texture GetRandomTeamSymbol(int base) { return None; }

event PreBeginPlay()
{
    Super.PreBeginPlay();

	KFGameReplicationInfo(GameReplicationInfo).bNoBots = bNoBots;
	KFGameReplicationInfo(GameReplicationInfo).PendingBots = 0;
	KFGameReplicationInfo(GameReplicationInfo).GameDiff = GameDifficulty;
	KFGameReplicationInfo(GameReplicationInfo).bEnemyHealthBars = bEnemyHealthBars;

	HintTime_1 = 99999999.00;
	HintTime_2 = 99999999.00;

	bShowHint_2 = true;
	bShowHint_3 = true;
}

// Overriden to handle ZEDTime zombie death slomo system
event Tick(float DeltaTime)
{
    local float TrueTimeFactor;
    local Controller C;

    if( bZEDTimeActive )
    {
        TrueTimeFactor = 1.1/Level.TimeDilation;
        CurrentZEDTimeDuration -= DeltaTime * TrueTimeFactor;

        if( CurrentZEDTimeDuration < (ZEDTimeDuration*0.166) && CurrentZEDTimeDuration > 0 )
        {
            if( !bSpeedingBackUp )
            {
                bSpeedingBackUp = true;

            	for( C=Level.ControllerList;C!=None;C=C.NextController )
            	{
            		if (KFPlayerController(C)!= none)
            		{
                        KFPlayerController(C).ClientExitZedTime();
            		}
            	}
            }

            SetGameSpeed(Lerp( (CurrentZEDTimeDuration/(ZEDTimeDuration*0.166)), 1.0, 0.2 ));
        }


        if( CurrentZEDTimeDuration <= 0 )
        {
            bZEDTimeActive = false;
            bSpeedingBackUp = false;
            SetGameSpeed(1.0);
			ZedTimeExtensionsUsed = 0;
        }
    }
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	for ( i = 0; i < default.KFHints.Length; i++ )
		Hints[Hints.Length] = default.KFHints[i];

	return Hints;
}

static function string ParseLoadingHintNoColor(string Hint, PlayerController Ref)
{
	local string CurrentHint, Cmd, Result, original;
	local int pos;

	original = hint;

	pos = InStr(Hint, "%");
	if ( pos == -1 )
		return Hint;

	do
	{
		Cmd = "";
		Result = "";

		CurrentHint $= Left(Hint,pos);
		Hint = Mid(Hint, pos+1);

		pos = InStr(Hint, "%");
		if ( pos == -1 )
			break;

		Cmd = Left(Hint,pos);
		Hint = Mid(Hint,pos+1);
		Result = GetKeyBindName(Cmd,Ref);
		if ( Result == Cmd || Result == "" )
		    Result = "(?)";
			//break;

		CurrentHint $= Result;
		pos = InStr(Hint, "%");
	} until ( Hint == "" || pos == -1 );

	if ( Result != "" && Result != Cmd )
		return CurrentHint $ Hint;

	return CurrentHint $ "(?)" $ Hint;
}

// Called when a dramatic event happens that might cause slomo
// BaseZedTimePossibility - the attempted probability of doing a slomo event
function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
    local float RandChance;
    local float TimeSinceLastEvent;
    local Controller C;

    TimeSinceLastEvent = Level.TimeSeconds - LastZedTimeEvent;

    // Don't go in slomo if we were just IN slomo
    if( TimeSinceLastEvent < 10.0 && BaseZedTimePossibility != 1.0 )
    {
        return;
    }

    if( TimeSinceLastEvent > 60 )
    {
        BaseZedTimePossibility *= 4.0;
    }
    else if( TimeSinceLastEvent > 30 )
    {
        BaseZedTimePossibility *= 2.0;
    }

    RandChance = FRand();

    //log("TimeSinceLastEvent = "$TimeSinceLastEvent$" RandChance = "$RandChance$" BaseZedTimePossibility = "$BaseZedTimePossibility);

    if( RandChance <= BaseZedTimePossibility )
    {
        bZEDTimeActive =  true;
        bSpeedingBackUp = false;
        LastZedTimeEvent = Level.TimeSeconds;

		if ( DesiredZedTimeDuration != 0.0 )
		{
			CurrentZEDTimeDuration = DesiredZedTimeDuration;
		}
		else
		{
			CurrentZEDTimeDuration = ZEDTimeDuration;
		}

        SetGameSpeed(ZedTimeSlomoScale);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
    		if (KFPlayerController(C)!= none)
    		{
                KFPlayerController(C).ClientEnterZedTime();
    		}

			if ( C.PlayerReplicationInfo != none && KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements).AddZedTime(ZEDTimeDuration);
			}
		}
    }
}

// Overridden to support KF functionality
function ShowPathTo(PlayerController P, int TeamNum)
{
    if( KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
    {
        return;
    }

    KFGameReplicationInfo(GameReplicationInfo).CurrentShop.InitTeleports();

    if ( (KFGameReplicationInfo(GameReplicationInfo).CurrentShop.TelList[0] != None) &&
       (P.FindPathToward(KFGameReplicationInfo(GameReplicationInfo).CurrentShop.TelList[0], false) != None) )
    {
        Spawn(class'RedWhisp', P,, P.Pawn.Location);
    }
}

// Kill all the enemy AI. Used for debugging
exec function KillZeds()
{
    local Controller c, nextC;
    local int num;
	local Controller PC;

	for ( PC = Level.ControllerList; PC != none; PC = PC.NextController )
	{
		if ( PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.SteamStatsAndAchievements != none )
		{
			PC.PlayerReplicationInfo.SteamStatsAndAchievements.bUsedCheats = true;
		}
	}

    num = NumMonsters;

    c = Level.ControllerList;

    while (c != none && num > 0)
    {
        nextC = c.NextController;
        if (KillZed(c))
            --num;
        c = nextC;
    }
}

function bool KillZed(Controller c)
{
    local MonsterController b;

    b = MonsterController(c);
    if (b != None)
    {
		if ( (Vehicle(b.Pawn) != None) && (Vehicle(b.Pawn).Driver != None) )
			Vehicle(b.Pawn).Driver.KilledBy(Vehicle(b.Pawn).Driver);
		else if (b.Pawn != None)
            b.Pawn.KilledBy( b.Pawn );
		if (b != None)
			b.Destroy();
        return true;
    }
    return false;
}

// Force slomo for a longer period of time when the boss dies
function DoBossDeath()
{
    local Controller C;
    local Controller nextC;
    local int num;

    bZEDTimeActive =  true;
    bSpeedingBackUp = false;
    LastZedTimeEvent = Level.TimeSeconds;
    CurrentZEDTimeDuration = ZEDTimeDuration*2;
    SetGameSpeed(ZedTimeSlomoScale);

    num = NumMonsters;

    c = Level.ControllerList;

    // turn off all the other zeds so they don't attack the player
    while (c != none && num > 0)
    {
        nextC = c.NextController;
        if (KFMonsterController(C)!=None)
        {
            C.GotoState('GameEnded');
            --num;
        }
        c = nextC;
    }

}

function bool BecomeSpectator(PlayerController P)
{
	if( P.PlayerReplicationInfo==None || P.PlayerReplicationInfo.bOnlySpectator )
		Return False; // Already are spectator.
	return Super.BecomeSpectator(P);
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
	if( P.PlayerReplicationInfo==None || !P.PlayerReplicationInfo.bOnlySpectator )
		Return False; // Already are active player.
	if ( !GameReplicationInfo.bMatchHasBegun || (NumPlayers >= MaxPlayers) || P.IsInState('GameEnded') || P.IsInState('RoundEnded') )
	{
		P.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}
	if ( (Level.NetMode==NM_Standalone) && (NumBots>InitialBots) )
	{
		RemainingBots--;
		bPlayerBecameActive = true;
	}
	P.PlayerReplicationInfo.Score = StartingCash;
	return true;
}

function array<IMClassList> LoadUpMonsterListFromGameType()
{
	local array<IMClassList> InitMList;
	local int i,j;
	local Class<KFMonster> MC;

	for( i=0; i<MonsterClasses.Length; i++ )
	{
		if( MonsterClasses[i].MClassName=="" || MonsterClasses[i].MID=="" )
		{
			Continue;
		}

   		MC = Class<KFMonster>(DynamicLoadObject(MonsterClasses[i].MClassName,Class'Class'));


        //override the monster with its event version, assuming it's one of our own Zombies
        if(MC.default.EventClasses.Length > eventNum && InStr(MonsterClasses[i].MClassName, "KFChar.Zombie")  != -1 )
        {
            MC = Class<KFMonster>(DynamicLoadObject(MC.default.EventClasses[eventNum],Class'Class'));
        }


		if( MC==None )
		{
			Continue;
		}

        MC.static.PreCacheAssets(Level);

		InitMList.Length = j+1;
		InitMList[j].MClass = MC;
		InitMList[j].ID = MonsterClasses[i].MID;
		j++;
	}
	//precache the boss
	/*MC = Class<KFMonster>(DynamicLoadObject(EndGameBossClass,Class'Class'));
	if(MC.default.EventClasses.Length > eventNum)
    {
        MC = Class<KFMonster>(DynamicLoadObject(MC.default.EventClasses[eventNum],Class'Class'));
    }
    MC.static.PreCacheAssets(Level);
    InitMList.Length = j+1;
	InitMList[j].MClass = MC;*/

	return InitMList;
}

function array<IMClassList> LoadUpMonsterListFromCollection()
{
	local array<IMClassList> InitMList;
	local int i,j;
	local Class<KFMonster> MC;

	for( i=0; i<MonsterCollection.default.MonsterClasses.Length; i++ )
	{
		if( MonsterCollection.default.MonsterClasses[i].MClassName=="" || MonsterCollection.default.MonsterClasses[i].MID=="" )
			Continue;

   		MC = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.MonsterClasses[i].MClassName,Class'Class'));

		if( MC==None )
			Continue;

        MC.static.PreCacheAssets(Level);

		InitMList.Length = j+1;
		InitMList[j].MClass = MC;
		InitMList[j].ID = MonsterCollection.default.MonsterClasses[i].MID;
		j++;
	}
	return InitMList;
}

function LoadUpMonsterList()
{
	local int i,j,q,c,n;
	local Class<KFMonster> MC;
	local string S,ID;
	local bool bInitSq;
	local array<IMClassList> InitMList;

    if( KFGameLength != GL_Custom )
    {
        InitMList = LoadUpMonsterListFromCollection();
    }
    else
    {
        InitMList = LoadUpMonsterListFromGameType();
    }

	//Log("Got"@j@"monsters. Loading up monster squads...",'Init');
	for( i=0; i<MonsterSquad.Length; i++ )
	{
		S = MonsterSquad[i];
		if( S=="" )
			Continue;
		bInitSq = False;
		n = 0;
		While( S!="" )
		{
			q = int(Left(S,1));
			ID = Mid(S,1,1);
			S = Mid(S,2);
			MC = None;
			for( j=0; j<InitMList.Length; j++ )
			{
				if( InitMList[j].ID~=ID )
				{
					MC = InitMList[j].MClass;
					Break;
				}
			}
			if( MC==None )
				Continue;
			if( !bInitSq )
			{
				InitSquads.Length = c+1;
				bInitSq = True;
			}
			while( (q--)>0 )
			{
				InitSquads[c].MSquad.Length = n+1;
				InitSquads[c].MSquad[n] = MC;
				n++;
			}
		}
		if( bInitSq )
			c++;
	}
	//Log("Got"@c@"monster squads.",'Init');
	if( FallbackMonster==class'EliteKrall' && InitMList.Length>0 )
		FallbackMonster = InitMList[0].MClass;
}

event InitGame( string Options, out string Error )
{
//	local int i,j;
	local KFLevelRules KFLRit;
	local ShopVolume SH;
	local ZombieVolume ZZ;
	local string InOpt;

	Super.InitGame(Options, Error);

	MaxPlayers = Clamp(GetIntOption( Options, "MaxPlayers", MaxPlayers ),0,6);
	default.MaxPlayers = Clamp( default.MaxPlayers, 0, 6 );

	foreach DynamicActors(class'KFLevelRules',KFLRit)
	{
		if(KFLRules==none)
			KFLRules = KFLRit;
		else Warn("MULTIPLE KFLEVELRULES FOUND!!!!!");
	}
	foreach AllActors(class'ShopVolume',SH)
		ShopList[ShopList.Length] = SH;
	foreach AllActors(class'ZombieVolume',ZZ)
		ZedSpawnList[ZedSpawnList.Length] = ZZ;

	//provide default rules if mapper did not need custom one
	if(KFLRules==none)
		KFLRules = spawn(class'KFLevelRules');

	log("KFLRules = "$KFLRules);

	InOpt = ParseOption(Options, "UseBots");
	if ( InOpt != "" )
	{
		bNoBots = bool(InOpt);
	}

    log("Game length = "$KFGameLength);

    if( KFGameLength != GL_Custom )
    {
        // Set up the default game type settings
        bUseEndGameBoss = true;
        bRespawnOnBoss = true;
        if( StandardMonsterClasses.Length > 0 )
        {
            MonsterClasses = StandardMonsterClasses;
        }
        MonsterSquad = StandardMonsterSquads;
        MaxZombiesOnce = StandardMaxZombiesOnce;
        bCustomGameLength = false;
        UpdateGameLength();

        // Set difficulty based values
        if ( GameDifficulty >= 7.0 ) // Hell on Earth
        {
        	TimeBetweenWaves = TimeBetweenWavesHell;
        	StartingCash = StartingCashHell;
        	MinRespawnCash = MinRespawnCashHell;
        }
        else if ( GameDifficulty >= 5.0 ) // Suicidal
        {
        	TimeBetweenWaves = TimeBetweenWavesSuicidal;
        	StartingCash = StartingCashSuicidal;
        	MinRespawnCash = MinRespawnCashSuicidal;
        }
        else if ( GameDifficulty >= 4.0 ) // Hard
        {
        	TimeBetweenWaves = TimeBetweenWavesHard;
        	StartingCash = StartingCashHard;
        	MinRespawnCash = MinRespawnCashHard;
        }
        else if ( GameDifficulty >= 2.0 ) // Normal
        {
        	TimeBetweenWaves = TimeBetweenWavesNormal;
        	StartingCash = StartingCashNormal;
        	MinRespawnCash = MinRespawnCashNormal;
        }
        else //if ( GameDifficulty == 1.0 ) // Beginner
        {
        	TimeBetweenWaves = TimeBetweenWavesBeginner;
        	StartingCash = StartingCashBeginner;
        	MinRespawnCash = MinRespawnCashBeginner;
        }

        InitialWave = 0;

        PrepareSpecialSquads();
    }
    else
    {
        bCustomGameLength = true;
        UpdateGameLength();
    }

	LoadUpMonsterList();
}

function NotifyGameEvent(int EventNumIn)
{
    if( KFGameLength != GL_Custom )
    {
        if(MonsterCollection != class'KFMonstersCollection' )
        {//we already have an event

            if(EventNumIn == 3 && MonsterCollection != class'KFMonstersXmas')
            {
                log("Was we should be in halloween mode but we aren't!");
            }
            if(EventNumIn == 2 && MonsterCollection != class'KFMonstersHalloween')
            {
                log("Was we should be in halloween mode but we aren't!");
            }
            if(EventNumIn == 0 && MonsterCollection != class'KFMonstersCollection')
            {
                log("Was we shouldn't have an event but we do!");
            }
            return;
        }
    }
    else
    {
        //if we've already decided on doing an event, return
        if(EventNum != EventNumIn && EventNum != 0)
        {
            return;
        }
    }

    if(EventNumIn == 2 )
    {
        MonsterCollection = class'KFMonstersHalloween';
    }
    else if(EventNumIn == 3 )
    {
        MonsterCollection = class'KFMonstersXmas';
    }
    //EventNum = EventNumIn;
    PrepareSpecialSquads();
    LoadUpMonsterList();
}

simulated function PrepareSpecialSquadsFromGameType()
{
    local int i;

    if( KFGameLength == GL_Short )
    {
        FinalWave = 4;

       	for( i=0; i<FinalWave; i++ )
       	{
       		Waves[i] = ShortWaves[i];
       		SpecialSquads[i] = ShortSpecialSquads[i];
      	}
    }
    else if( KFGameLength == GL_Normal )
    {
        FinalWave = 7;
       	for( i=0; i<FinalWave; i++ )
       	{
       		Waves[i] = NormalWaves[i];
       		SpecialSquads[i] = NormalSpecialSquads[i];
       	}
    }
    else if( KFGameLength == GL_Long )
    {
        FinalWave = 10;
       	for( i=0; i<FinalWave; i++ )
       	{
       		Waves[i] = LongWaves[i];
       		SpecialSquads[i] = LongSpecialSquads[i];
     	}
    }
}

simulated function PrepareSpecialSquadsFromCollection()
{
    local int i;
    if( KFGameLength == GL_Short )
    {
        FinalWave = 4;
       	for( i=0; i<FinalWave; i++ )
     	{
       		Waves[i] = ShortWaves[i];
  		    MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.ShortSpecialSquads[i];
       	}
    }
    else if( KFGameLength == GL_Normal )
    {
        FinalWave = 7;
     	for( i=0; i<FinalWave; i++ )
       	{
       		Waves[i] = NormalWaves[i];
            MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.NormalSpecialSquads[i];
      	}
    }
    else if( KFGameLength == GL_Long )
    {
        FinalWave = 10;
      	for( i=0; i<FinalWave; i++ )
      	{
     		Waves[i] = LongWaves[i];
    	    MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.LongSpecialSquads[i];
      	}
    }
}

simulated function PrepareSpecialSquads()
{
    if( SpecialSquads.Length == 0 )
    {
        PrepareSpecialSquadsFromCollection();
    }
    else
    {
        PrepareSpecialSquadsFromGameType();
    }
}

// For the GUI buy menu
simulated function float GetDifficulty()
{
	return GameDifficulty;
}

function UpdateGameLength()
{
	local Controller C;

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if ( PlayerController(C) != none && PlayerController(C).SteamStatsAndAchievements != none )
		{
			PlayerController(C).SteamStatsAndAchievements.bUsedCheats = PlayerController(C).SteamStatsAndAchievements.bUsedCheats || bCustomGameLength;
		}
	}
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.blood.bloodsplash_1');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.blood.bloodsplash_2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.blood.bloodsplash_3');

	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.bloat_explode');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.Brain_Chunk_1');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.Brain_Chunk_2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.Brain_Chunk_3');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.Brain_Full');

	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.eyeball');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.intestines');

	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.britsoldier1head');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.britsoldier3head');

	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.mikehead');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.riotcop1head');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.riotcop2head');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.heads.chrishead');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.limbs.british_riot_police_arm_resource');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.limbs.british_riot_police_leg_resource');
	myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.puke.puke_chunk');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KF_pickups2_Trip.Supers.MP7_Dart');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KF_generic_sm.Bullet_Shells.Handcannon_Shell');

	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.FragProjectile');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib1');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');

	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'KillingFloorStatics.Gib2');
	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tracer');
 }

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);

	// new weapons 1st person
	//hands
//    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.hands.hands_d');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.hands.hands_1stP_riot_D');
    myLevel.AddPrecacheMaterial(Material'KF_Weapons_Trip_T.hands.hands_1stP_military_diff');

	//equipment
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.equipment.MedInjector_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.equipment.MedInjector_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.equipment.MedInjector_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.equipment.Welder_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.equipment.Welder_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.equipment.Welder_D');

    //melee
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Axe_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Axe_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.Axe_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Axe_bloody_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Axe_bloody_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.Axe_bloody');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Chainsaw_cmb');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Chainsaw_env_cmb');
    //myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.Chainsaw_D');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Chainsaw_bloody_cmb');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.Chainsaw_bloody_env_cmb');
    //myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.Chainsaw_bloody');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.knife_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.knife_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.knife_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.knife_bloody_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.knife_bloody_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.knife_bloody');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.machete_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.machete_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.machete_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.machete_bloody_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Melee.machete_bloody_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Melee.machete_bloody');
    myLevel.AddPrecacheMaterial(Texture'KillingFloorWeapons.Frag_Grenade.FragSkin');
    myLevel.AddPrecacheMaterial(Texture'KillingFloorWeapons.Frag_Grenade.GrenadeSPEC');
    //myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Melee.Katana_D');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Melee.Katana_cmb');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Melee.Katana_env_cmb');
    //myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Melee.Katana_Bloody');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Melee.Katana_bloody_cmb');
    //myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Melee.Katana_bloody_env_cmb');

    //Specials
   	/*myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.AA12_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.AA12_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.AA12_D');
   	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.M32_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.M32_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.M32_D');
   	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.M79_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.M79_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.M79_Diff');
   	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.Mp_7_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.Mp_7_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.Mp_7_D');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.Mp_7_dot');
	myLevel.AddPrecacheMaterial(Material'KF_Weapons2_Trip_T.Special.MP_7_SHDR');
   	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.pipebomb_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Special.pipebomb_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Special.pipebomb_D');*/

	//pistols
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Pistols.Ninemm_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Pistols.Deagle_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Pistols.Deagle_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Pistols.Deagle_D');

	//rifles
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.winchester_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.winchester_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Rifles.winchester_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.Bullpup_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.Bullpup_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Rifles.Bullpup_D');
	myLevel.AddPrecacheMaterial(Material'KF_Weapons_Trip_T.Rifles.reflex_sight_A_unlit');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Rifles.Reflexsight_A');
	/*myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.Crossbow_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Rifles.Crossbow_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Rifles.Crossbow_D');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Rifles.CBLens');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.M14_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.M14_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Rifle.M14_D');
   	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.Scar_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.Scar_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Rifle.Scar_D');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Rifle.Scar_Dot_Alpha');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Rifle.Scar_Lens_D');
    myLevel.AddPrecacheMaterial(Material'KF_Weapons2_Trip_T.Rifle.Scar_lens_Shader');
    myLevel.AddPrecacheMaterial(Material'KF_Weapons2_Trip_T.Rifle.Scar_SHDR');
	MyLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.AK47_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons2_Trip_T.Rifle.AK47_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons2_Trip_T.Rifle.AK47_D');*/

    //Shotties
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Shotguns.Shotgun_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Shotguns.Shotgun_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Shotguns.Shotgun_D');
    /*myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Shotguns.Boomstick_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Shotguns.Boomstick_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Shotguns.Boomstick_D');*/

	//Supers
	/*myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.LAW_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.LAW_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Supers.LAW_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.Rocket_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.Rocket_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Supers.Rocket_D');
    myLevel.AddPrecacheMaterial(Shader'KF_Weapons_Trip_T.Supers.law_reddot_shdr');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Supers.Law_Sight_Dot_A');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.Flamethrower_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.Supers.Flamethrower_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Weapons_Trip_T.Supers.Flamethrower_D');*/


	// new weapons 3rd person
	// Eqipment

	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.equipment.Syringe_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.equipment.Welder_3rd');

	// Melee
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.melee.Axe_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.melee.Chainsaw_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.melee.Knife_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.melee.Machete_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.melee.SawChain_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.melee.Katana_3rd');

	// Pistols
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Pistols.Ninemm_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Pistols.Handcannon_3rd');

	// Rifles
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Rifles.bullup_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Rifles.Crossbow_3rd');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Rifles.Winchester_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KillingFloorWeapons.Xbow.CommandoCross');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Rifles.AK47_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Rifles.M14_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Rifles.scar_3rd');

	// Shotgun
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Shotguns.CombatShotgun_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Shotguns.HuntingShot_3rd');

	// Specials
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Super.Flamethrower_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd_Trip_T.Super.LAW_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KillingFloorWeapons.LAW.RocketSkin');
	myLevel.AddPrecacheMaterial(Texture'KillingFloorWeapons.Frag_Grenade.FragSkin3P');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.AA12_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.m32_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.M79_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.MP7_3rd');
	//myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.pipebomb_3rd');
	//myLevel.AddPrecacheMaterial(Combiner'KF_Weapons3rd2_Trip_T.Super.pipebomb3rd_cmb');
	//myLevel.AddPrecacheMaterial(material'KF_Weapons3rd2_Trip_T.Super.pipebomb_3rd_shdr');

	// Characters
	myLevel.AddPrecacheMaterial(Combiner'KF_Soldier_Trip_T.Uniforms.brit_soldier_I_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Soldier_Trip_T.Uniforms.brit_soldier_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.Uniforms.brit_soldier_I_diff');
	myLevel.AddPrecacheMaterial(Combiner'KF_Soldier_Trip_T.Uniforms.british_riot_police_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Soldier_Trip_T.Uniforms.british_riot_police_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.Uniforms.british_riot_police_diff');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.Uniforms.british_riot_police_mask');
	myLevel.AddPrecacheMaterial(Material'KF_Soldier_Trip_T.Uniforms.british_riot_police_fb');
	myLevel.AddPrecacheMaterial(Shader'KF_Soldier_Trip_T.Uniforms.british_riot_police_I_shd');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.heads.chris_head_diff');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.heads.mike_head_diff');
	myLevel.AddPrecacheMaterial(Texture'KF_Soldier_Trip_T.Uniforms.shopkeeper_diff');




	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.reflection_cube');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.reflection_env');


	myLevel.AddPrecacheMaterial(Material'KFX.CloakGradient');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.FPDeviceBloomAmber');
	myLevel.AddPrecacheMaterial(Material'PatchTex.Common.ZedBurnSkin');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.FPDeviceBloomRed');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.DavinSkin');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T_Two.burns_diff');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T_Two.burns_emissive_mask');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_energy_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_env_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_fire_cmb');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T_Two.burns_shdr');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_cmb');

	// Explosives/Fire
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel1');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowchunksfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.radialexplosion_1frame');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.grenademark_snow');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.concrete_chunks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel3');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.waterring_2frame');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.impact_2frame');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplashcloud');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplatter2');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersmoke');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodchunksfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.rock_chunks');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Misc.smoke_animated');
	myLevel.AddPrecacheMaterial(Texture'KillingFloorTextures.LondonCommon.fire3');
	myLevel.AddPrecacheMaterial(Texture'Effects_Tex.explosions.impact_2frame');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Misc.healingFXflare');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Misc.healingFX');
	myLevel.AddPrecacheMaterial(Texture'Effects_Tex.explosions.radialexplosion_1frame');

	// Bullet hits
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_cloth');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_concrete');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_dirt');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_flesh');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_ice');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_metal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_metalarmor');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_snow');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_wood');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.Sparks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.papersmoke');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonesmokefinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtclouddark');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtcloud');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundthick');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.grasschunks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonefinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonechunksfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.icechunks');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.sparkfinal2');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundchunksfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.rubbersmokefinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodsmokefinal2');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.rocketmark_dirt');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.rocketmark_snow');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.LightSmoke_8Frame');
	myLevel.AddPrecacheMaterial(Material'ROEffects.Skins.Rexpt');
	myLevel.AddPrecacheMaterial(Material'ROEffects.SmokeAlphab_t');
	myLevel.AddPrecacheMaterial(Material'KillingFloorTextures.LondonCommon.fire3');
	myLevel.AddPrecacheMaterial(Material'kf_fx_trip_t.Misc.KFTracerShot');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.MPmuzzleflash_4frame');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.MuzzleCorona1stP');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Karmuzzle_2frame');
	myLevel.AddPrecacheMaterial(Material'kf_fx_trip_t.Misc.kfnoise');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.muzzle_4frame3rd');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.metalsmokefinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.Melee_Slash');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.grenademark_dirt');
	myLevel.AddPrecacheMaterial(Material'KFX.MetalHitKF');
	myLevel.AddPrecacheMaterial(Material'KFX.KFFlames');
	myLevel.AddPrecacheMaterial(Material'KillingFloorWeapons.FlameThrower.FlameThrowerFire');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_2');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.MP3rdPmuzzle_smoke1frame');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.glowfinal');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.PTRDmuzzle_2frame');
	myLevel.AddPrecacheMaterial(Material'PatchTex.Common.CreteWall');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.STGmuzzleflash_4frame');
	myLevel.AddPrecacheMaterial(Material'KillingFloorWeapons.FlameThrower.PilotBloom');
	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.paperchunks');

 	//Gore
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.bloat_explode_blood');
//	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.bloat_vomit_spray');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.bloat_vomit_spray_anim');
//	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.blood_cube');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.blood_drips');
//	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.blood_hit_a');
//	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.blood_hit_b');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.blood_hit_c');
//  myLevel.AddPrecacheMaterial(combiner'kf_fx_trip_t.Gore.blood_hit_c_env_cmb');
    myLevel.AddPrecacheMaterial(texture'kf_fx_trip_t.Gore.blood_lifemap');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.brain');
    myLevel.AddPrecacheMaterial(Shader'kf_fx_trip_t.Gore.brain_SHDR');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.eyeball_diff');
    myLevel.AddPrecacheMaterial(combiner'kf_fx_trip_t.Gore.eyeball_env_cmb');
    myLevel.AddPrecacheMaterial(combiner'kf_fx_trip_t.Gore.eyebayll_cmb');
    myLevel.AddPrecacheMaterial(combiner'kf_fx_trip_t.Gore.intestines_cmb');
	myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.intestines_diff');
    myLevel.AddPrecacheMaterial(combiner'kf_fx_trip_t.Gore.intestines_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.KF_Gore_Limbs_diff');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.limbremoval_blood');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.limbremoval_blood_b');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.pukechunk_diffuse');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.kf_bloodspray_b_diff');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.kf_bloodspray_diff');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff');

    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.pukechunk_diffuse');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.vomit_16f');
	myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_001');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_002');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_003');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_004');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_005');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Splatter_006');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreEmitters.BloodPuff');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreEmitters.BloodCircle');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Drip_003');
	myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Drip_002');
    myLevel.AddPrecacheMaterial(Texture'Effects_Tex.GoreDecals.Drip_001');
    myLevel.AddPrecacheMaterial(Material'KFX.BloodStreak');
    myLevel.AddPrecacheMaterial(Material'KFX.BloodSplat1');
    myLevel.AddPrecacheMaterial(Material'KFX.BloodSplat2');
    myLevel.AddPrecacheMaterial(Material'KFX.BloodSplat3');
    myLevel.AddPrecacheMaterial(Material'KFX.VomSplat');
    myLevel.AddPrecacheMaterial(Material'KFX.VomitSplash');
    myLevel.AddPrecacheMaterial(Material'KFX.KFSparkHead');
    myLevel.AddPrecacheMaterial(Material'kf_fx_trip_t.Misc.speedtrail_T');
/*    myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.Blood_Smear_Long');
    myLevel.AddPrecacheMaterial(Material'kf_gore_trip_T_Two.Blood_Smear_Long_SHDR');
    myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.deadbodies_blood_a');
    myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.deadbodies_blood_b');
	myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.deadbodies_blood_c');
	myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.deadbodies_gore_diff');
	myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.factory_worker_uniform_diff');
	myLevel.AddPrecacheMaterial(Texture'kf_gore_trip_T_Two.rave_sec_guard_body');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.ravesec_blood_A_CMB');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.ravesec_blood_B_CMB');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.ravesec_blood_C_CMB');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.uniform_blood_A_CMB');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.uniform_blood_B_CMB');
	myLevel.AddPrecacheMaterial(combiner'kf_gore_trip_T_Two.uniform_blood_C_CMB');*/


	// Tracer Textures
	myLevel.AddPrecacheMaterial(Material'Effects_tex.Weapons.TrailBlur');
	myLevel.AddPrecacheMaterial(Material'kf_generic_t.Shotgun_Pellet');
	myLevel.AddPrecacheMaterial(Texture'KF_Weapons3rd2_Trip_T.Super.MP7_Dart_DIFF');

	//Other for better loads.....
	myLevel.AddPrecacheMaterial(Material'KFX.BrainSplash');
	myLevel.AddPrecacheMaterial(Material'KFX.BloodSplash');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHud.Generic.HUD');
	myLevel.AddPrecacheMaterial(Material'KFMaterials.GlassChips');
	myLevel.AddPrecacheMaterial(Material'KFMaterials.PlantBits');
	myLevel.AddPrecacheMaterial(Material'KFMaterials.WoodChips');
	myLevel.AddPrecacheMaterial(Material'KFX.TransTrailT');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Perks.Perk_Medic');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Perks.Perk_SharpShooter');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Perks.Perk_Commando');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Perks.Perk_Berserker');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Perks.Perk_Firebug');
	myLevel.AddPrecacheMaterial(Material'KFPatch2.BossBits');
	myLevel.AddPrecacheMaterial(Material'PatchTex.ShottyCasing');
	myLevel.AddPrecacheMaterial(Material'KFX.Grain2');

	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Box_128x64');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.knife_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.single_9mm_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.combat_shotgun_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.winchester_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.syring_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Rectangel_selected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Welder');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Syringe');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.welder_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Winchester');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.combat_shotgun');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.single_9mm');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.knife');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.chainsaw_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.axe_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.machette_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.dual_handcannon_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.handcannon_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Bullpup');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.law_unselected');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.boomstic_unselected');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.crossbow_unselected');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.flamethrower_unselected');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.bullpup_unselected');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.LAW');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.BoomStick');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Crossbow');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.FlameThrower');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.handcannon');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.dual_handcannon');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.machette');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Axe');
	//myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.WeaponSelect.Chainsaw');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Bio_Clock_Circle');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Single_Bullet');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Bullets');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Flashlight_Off');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.Generic.debuggarrow1');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.BluntSplashNormal');
	myLevel.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
	myLevel.AddPrecacheMaterial(Material'KFPortraits.Trader_portrait');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Medical_Cross');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Shield');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Weight');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Grenade');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Pound_Symbol');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Perk_Star');
	myLevel.AddPrecacheMaterial(Material'KillingFloorHUD.HUD.Hud_Bio_Circle');

	myLevel.AddPrecacheMaterial(Material'KillingFloorWeapons.Dualies.LightCircle');
	myLevel.AddPrecacheMaterial(Material'KillingFloorWeapons.Dualies.BeretaTacLightStream');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	//TODO - sortage of this lot
	Super.PrecacheGameAnnouncements(V,bRewardSounds);

	if(!bRewardSounds)
	{
		V.PrecacheSound('HereTheyCome1');
		V.PrecacheSound('HereTheyCome2');
		V.PrecacheSound('HereTheyCome3');
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super(Info).FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.GameGroup,"GameDifficulty", GetDisplayText("GameDifficulty"),	0, 0, "Select", default.GIPropsExtras[0], "Xb");
	PlayInfo.AddSetting(default.GameGroup,"KFGameLength", 	GetDisplayText("KFGameLength"),		0, 1, "Select", default.GIPropsExtras[1], "Xb", , true);

    PlayInfo.AddSetting(default.SandboxGroup,"FinalWave", GetDisplayText("Waves"),		50, 4, "Text", "10;0:15");
	PlayInfo.AddSetting(default.SandboxGroup,"WaveStartSpawnPeriod", GetDisplayText("WaveStartSpawnPeriod"),50,5,"Text","3;0.0:6.0");
	PlayInfo.AddSetting(default.SandboxGroup,"StartingCash", GetDisplayText("StartingCash"),0,0,"Text","200;0:500");
	PlayInfo.AddSetting(default.SandboxGroup,"MinRespawnCash", GetDisplayText("MinRespawnCash"),0,1,"Text","200;0:500");

    if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        PlayInfo.AddSetting(default.SandboxGroup,"TimeBetweenWaves", GetDisplayText("TimeBetweenWaves"),0,3,"Text","60;1:999");
    }
    else
    {
        PlayInfo.AddSetting(default.SandboxGroup,"TimeBetweenWaves", GetDisplayText("TimeBetweenWaves"),0,3,"Text","60;1:100");
    }

    if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
	   PlayInfo.AddSetting(default.SandboxGroup, "MaxZombiesOnce", GetDisplayText("MaxZombiesOnce"),70,2,"Text","4;1:600");
    }
    else
    {
	   PlayInfo.AddSetting(default.SandboxGroup, "MaxZombiesOnce", GetDisplayText("MaxZombiesOnce"),70,2,"Text","4;6:600");
    }

	PlayInfo.AddSetting(default.SandboxGroup,"bUseEndGameBoss", GetDisplayText("bUseEndGameBoss"),0,9,"Check");

	PlayInfo.AddSetting(default.ServerGroup, "LobbyTimeOut",	GetDisplayText("LobbyTimeOut"),		0, 1, "Text",	"3;0:120",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "bAdminCanPause",	GetDisplayText("bAdminCanPause"),	1, 1, "Check",			 ,	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",	GetDisplayText("MaxSpectators"),	1, 1, "Text",	 "6;0:32",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",		GetDisplayText("MaxPlayers"),		0, 1, "Text",	  "6;1:6",	,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",		GetDisplayText("MaxIdleTime"),		0, 1, "Text",	"3;0:300",	,True,True);

	PlayInfo.AddSetting(default.SandboxGroup,"TmpWavesInf", GetDisplayText("TmpWavesInf"),80,8,"Custom",";;KFGui.KFInvWaveConfig",,,);
	PlayInfo.AddSetting(default.SandboxGroup,"TmpSquadsInf",GetDisplayText("TmpSquadsInf"),80,7,"Custom",";;KFGui.KFInvSquadConfig",,,);
	PlayInfo.AddSetting(default.SandboxGroup,"TmpMClassInf",GetDisplayText("TmpMClassInf"),80,6,"Custom",";;KFGui.KFInvClassConfig",,,);

	// Add GRI's PIData
	if (default.GameReplicationInfoClass != None)
	{
		default.GameReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.VoiceReplicationInfoClass != None)
	{
		default.VoiceReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.BroadcastClass != None)
		default.BroadcastClass.static.FillPlayInfo(PlayInfo);
	else class'BroadcastHandler'.static.FillPlayInfo(PlayInfo);

	PlayInfo.PopClass();

	if (class'Engine.GameInfo'.default.VotingHandlerClass != None)
	{
		class'Engine.GameInfo'.default.VotingHandlerClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}
	else
		log("GameInfo::FillPlayInfo class'Engine.GameInfo'.default.VotingHandlerClass = None");
}

static event string GetDisplayText( string PropName )
{
	switch (PropName)
	{
		case "WaveStartSpawnPeriod":		return default.KFSurvivalPropText[0];
		case "StartingCash":				return default.KFSurvivalPropText[2];
		case "bNoBots":					    return default.KFSurvivalPropText[3];
		case "bNoLateJoiners":				return default.KFSurvivalPropText[4];
		case "LobbyTimeOut":				return default.KFSurvivalPropText[5];
	//	case "bEnemyHealthBars":			return default.KFSurvivalPropText[6];
	    case "TimeBetweenWaves":            return default.KFSurvivalPropText[7];
	    case "Waves":                       return default.KFSurvivalPropText[8];
	    case "KFGameLength":				return default.KFSurvivalPropText[9];
	    case "MaxZombiesOnce":				return default.KFSurvivalPropText[10];
	    case "bUseEndGameBoss":				return default.KFSurvivalPropText[11];
	}
	return Super.GetDisplayText( PropName );
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "WaveStartSpawnPeriod":		return default.KFSurvivalDescText[0];
		case "StartingCash":				return default.KFSurvivalDescText[2];
		case "bNoBots":					    return default.KFSurvivalDescText[3];
		case "bNoLateJoiners":				return default.KFSurvivalDescText[4];
		case "LobbyTimeOut":				return default.KFSurvivalDescText[5];
		case "MaxZombiesOnce":				return default.KFSurvivalDescText[10];
		case "TimeBetweenWaves":		    return default.KFSurvivalDescText[7];
		case "bUseEndGameBoss":				return default.KFSurvivalDescText[11];
		case "TmpWavesInf":					return default.KFSurvivalDescText[12];
		case "TmpSquadsInf":				return default.KFSurvivalDescText[13];
		case "TmpMClassInf":				return default.KFSurvivalDescText[14];
		case "EndGameBossClass":			return "The boss battle monster class.";
		case "MinRespawnCash":				return default.KFSurvivalDescText[15];
		case "Waves":                       return default.KFSurvivalDescText[8];
	    case "KFGameLength":				return default.KFSurvivalDescText[9];
	}
	return Super.GetDescriptionText(PropName);
}

event PostNetBeginPlay()
{
	KFGameReplicationInfo(GameReplicationInfo).bNoBots = bNoBots;
	KFGameReplicationInfo(GameReplicationInfo).PendingBots = 0;
	KFGameReplicationInfo(GameReplicationInfo).GameDiff = GameDifficulty;
	KFGameReplicationInfo(GameReplicationInfo).bEnemyHealthBars = bEnemyHealthBars;
}

function AddMonster()
{
	local NavigationPoint StartSpot;
	local Pawn NewMonster;
	local class<Monster> NewMonsterClass;
	local int MonstersAdded;

	StartSpot = FindPlayerStart(None,1);
	if ( StartSpot == None )
		return;

	NewMonsterClass = WaveMonsterClass[Rand(WaveNumClasses)];
	MonstersAdded ++;
	NewMonster = Spawn(NewMonsterClass,,,StartSpot.Location+(NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	if ( NewMonster ==  None )
		NewMonster = Spawn(FallBackMonster,,,StartSpot.Location+(FallBackMonster.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	MonstersAdded ++;
	if ( NewMonster != None )
	{
		WaveMonsters++;
		NumMonsters++;
	}

	if (NewMonster != none && MonstersAdded < 3)
		Super.AddMonster();

	if (MonstersAdded >= 3)
		MonstersAdded = 0;
}

function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
	local Controller C;
	local PlayerController Living;
	local byte AliveCount;

	if ( MaxLives > 0 )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator )
			{
				AliveCount++;
				if( Living==None )
					Living = PlayerController(C);
			}
		}
		if ( AliveCount==0 )
		{
			EndGame(Scorer,"LastMan");
			return true;
		}
		else if( !bNotifiedLastManStanding && AliveCount==1 && Living!=None )
		{
			bNotifiedLastManStanding = true;
			Living.ReceiveLocalizedMessage(Class'KFLastManStandingMsg');
		}
	}
	return false;
}

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local float KillScore;
	local Controller C;

	OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None )
	{
		OtherPRI.NumLives++;
		OtherPRI.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));	// you Lose 35% of your current cash on Hell on Earth, 15% on normal.
		OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));

		if (OtherPRI.Score < 0 )
			OtherPRI.Score = 0;
		if (OtherPRI.Team.Score < 0 )
			OtherPRI.Team.Score = 0;

		OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
		OtherPRI.bOutOfLives = true;
		if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,Killer.PlayerReplicationInfo);
		else if( Killer==None || Monster(Killer.Pawn)==None )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI);
		else BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,,Killer.Pawn.Class);
		CheckScore(None);
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

	if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}

	if ( Killer==None || !Killer.bIsPlayer || (Killer==Other) )
		return;

	if ( Other.bIsPlayer )
	{
		Killer.PlayerReplicationInfo.Score -= 5;
		Killer.PlayerReplicationInfo.Team.Score -= 2;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -5, "team_frag");
		return;
	}
	if ( LastKilledMonsterClass == None )
		KillScore = 1;
	else if(Killer.PlayerReplicationInfo !=none)
	{
		KillScore = LastKilledMonsterClass.Default.ScoringValue;

		// Scale killscore by difficulty
        if ( GameDifficulty >= 5.0 ) // Suicidal and Hell on Earth
        {
        	KillScore *= 0.65;
        }
        else if ( GameDifficulty >= 4.0 ) // Hard
        {
        	KillScore *= 0.85;
        }
        else if ( GameDifficulty >= 2.0 ) // Normal
        {
        	KillScore *= 1.0;
        }
        else //if ( GameDifficulty == 1.0 ) // Beginner
        {
        	KillScore *= 2.0;
        }

        // Increase score in a short game, so the player can afford to buy cool stuff by the end
        if( KFGameLength == GL_Short )
        {
            KillScore *= 1.75;
        }

		KillScore = Max(1,int(KillScore));
		Killer.PlayerReplicationInfo.Kills++;

		ScoreKillAssists(KillScore, Other, Killer);

		Killer.PlayerReplicationInfo.Team.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
	}

	if (Killer.PlayerReplicationInfo !=none && Killer.PlayerReplicationInfo.Score < 0)
		Killer.PlayerReplicationInfo.Score = 0;


    /* Begin Marco's Kill Messages */

        if( Class'HUDKillingFloor'.Default.MessageHealthLimit<=Other.Pawn.Default.Health ||
        Class'HUDKillingFloor'.Default.MessageMassLimit<=Other.Pawn.Default.Mass )
		{
			for( C=Level.ControllerList; C!=None; C=C.nextController )
			{
                if( C.bIsPlayer && xPlayer(C)!=None )
				{
                    xPlayer(C).ReceiveLocalizedMessage(Class'KillsMessage',1,Killer.PlayerReplicationInfo,,Other.Pawn.Class);
                }
            }
        }
		else
        {
            if( xPlayer(Killer)!=None )
			{
                xPlayer(Killer).ReceiveLocalizedMessage(Class'KillsMessage',,,,Other.Pawn.Class);
            }
        }

    /* End Marco's Kill Messages */

}

function ScoreKillAssists(float Score, Controller Victim, Controller Killer)
{
	local int i;
	local float GrossDamage, ScoreMultiplier, KillScore;
	local KFMonsterController MyVictim;
	local KFPlayerReplicationInfo KFPRI;

	MyVictim = KFMonsterController(Victim);

	if ( MyVictim.KillAssistants.Length < 1 )
	{
		return;
	}
	else
	{
		for ( i = 0; i < MyVictim.KillAssistants.Length; i++ )
		{
			GrossDamage += MyVictim.KillAssistants[i].Damage;
		}

		ScoreMultiplier = Score / GrossDamage;

		for ( i = 0; i < MyVictim.KillAssistants.Length; i++  )
		{
			if ( MyVictim.KillAssistants[i].PC != none &&
            MyVictim.KillAssistants[i].PC.PlayerReplicationInfo != none)
			{
				KillScore = ScoreMultiplier * MyVictim.KillAssistants[i].Damage;
                MyVictim.KillAssistants[i].PC.PlayerReplicationInfo.Score += KillScore;

                KFPRI = KFPlayerReplicationInfo(MyVictim.KillAssistants[i].PC.PlayerReplicationInfo) ;
                if(KFPRI != none)
				{
                    if(MyVictim.KillAssistants[i].PC != Killer)
                    {
                        KFPRI.KillAssists ++ ;
                    }

                    KFPRI.ThreeSecondScore += KillScore;
                }
			}
		}
	}
}

function SetupWaveBot(Inventory BotsInv);

/* Spawn and initialize a bot
*/
function Bot SpawnBot(optional string botName)
{
	local KFInvasionBot NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
	Chosen = BotTeam.ChooseBotClass(botName);

	if (Chosen.PawnClass == None)
		Chosen.Init(); //amb
	NewBot = Spawn(class 'KFInvasionBot');

	if ( NewBot != None )
		InitializeBot(NewBot,BotTeam,Chosen);

	// Decide if bot should be a veteran.
	if ( LoadedSkills.Length > 0 && FRand() < 0.35 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None )
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];

	NewBot.PlayerReplicationInfo.Score = StartingCash;

	return NewBot;
}


function InitializeBot(Bot NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
	local string S;

	NewBot.InitializeSkill(AdjustedDifficulty);
	Chosen.InitBot(NewBot);
	BotTeam.AddToTeam(NewBot);
	if ( Chosen.ModifiedPlayerName != "" )
		ChangeName(NewBot, Chosen.ModifiedPlayerName, false);
	else ChangeName(NewBot, Chosen.PlayerName, false);
	BotTeam.SetBotOrders(NewBot,Chosen);

	S = Class'KFGameType'.Static.GetValidCharacter("");
	NewBot.PlayerReplicationInfo.SetCharacterName(S);
	xBot(NewBot).PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(S);
}

function OverrideInitialBots();

function ReplenishWeapons(Pawn P);

// Play The Warning Sound at the Beginning of the Match
function WarningTimer()
{
	if( Level.TimeSeconds >= Time &&  bWaveInProgress )
		Time += 90;
}

function bool RewardSurvivingPlayers()
{
	local Controller C;
	local int moneyPerPlayer,div;
	local TeamInfo T;

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if ( C.Pawn != none && C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.Team != none )
		{
			T = C.PlayerReplicationInfo.Team;
			div++;
		}
	}

	if ( T == none || T.Score <= 0 )
	{
		return false;
	}

	moneyPerPlayer = int(T.Score / float(div));

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if ( C.Pawn != none && C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.Team != none )
		{
			if ( div == 1 )
			{
				C.PlayerReplicationInfo.Score += T.Score;
				T.Score = 0;
			}
			else
			{
				C.PlayerReplicationInfo.Score += moneyPerPlayer;
				T.Score-=moneyPerPlayer;
				div--;
			}

			C.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;

			if( T.Score <= 0 )
			{
				T.Score = 0;
				Break;
			}
		}
	}

	T.NetUpdateTime = Level.TimeSeconds - 1;

	return true;
}

function Timer()
{
	Super.Timer();

	if (ElapsedTime % 10 == 0)
	{
	    UpdateSteamUserData();
	}

	WarningTimer();
}

function StartGameMusic( bool bCombat )
{
	local Controller C;
	local string S;

	if( MapSongHandler==None )
		Return;
	if( bCombat )
	{
		if( MapSongHandler.WaveBasedSongs.Length<=WaveNum || MapSongHandler.WaveBasedSongs[WaveNum].CombatSong=="" )
			S = MapSongHandler.CombatSong;
		else S = MapSongHandler.WaveBasedSongs[WaveNum].CombatSong;
		MusicPlaying = True;
		CalmMusicPlaying = False;
	}
	else
	{
		if( MapSongHandler.WaveBasedSongs.Length<=WaveNum || MapSongHandler.WaveBasedSongs[WaveNum].CalmSong=="" )
			S = MapSongHandler.Song;
		else S = MapSongHandler.WaveBasedSongs[WaveNum].CalmSong;
		CalmMusicPlaying = True;
		MusicPlaying = False;
	}

	for( C=Level.ControllerList;C!=None;C=C.NextController )
	{
		if (KFPlayerController(C)!= none)
			KFPlayerController(C).NetPlayMusic(S, MapSongHandler.FadeInTime,MapSongHandler.FadeOutTime);
	}
}
function StartInitGameMusic( KFPlayerController Other )
{
	local string S;

	if( MapSongHandler==None )
		Return;
	if( MusicPlaying )
	{
		if( MapSongHandler.WaveBasedSongs.Length<=WaveNum || MapSongHandler.WaveBasedSongs[WaveNum].CombatSong=="" )
			S = MapSongHandler.CombatSong;
		else S = MapSongHandler.WaveBasedSongs[WaveNum].CombatSong;
	}
	else if( CalmMusicPlaying )
	{
		if( MapSongHandler.WaveBasedSongs.Length<=WaveNum || MapSongHandler.WaveBasedSongs[WaveNum].CalmSong=="" )
			S = MapSongHandler.Song;
		else S = MapSongHandler.WaveBasedSongs[WaveNum].CalmSong;
	}
	if( S!="" )
		Other.NetPlayMusic(S,0.5,0);
}

function StopGameMusic()
{
	local Controller C;
	local float FdT;

	if( MapSongHandler!=None )
		FdT = MapSongHandler.FadeOutTime;
	else FdT = 1;

	for( C=Level.ControllerList;C!=None;C=C.NextController )
	{
		if (KFPlayerController(C)!= none)
			KFPlayerController(C).NetStopMusic(FdT);
	}
	MusicPlaying = False;
	CalmMusicPlaying = False;
}

exec function AddNamedBot(string botname)
{
	local Controller C;

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if ( C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.SteamStatsAndAchievements != none )
		{
			C.PlayerReplicationInfo.SteamStatsAndAchievements.bUsedCheats = true;
		}
	}

	super.AddNamedBot(botname);
}

exec function AddBots(int num)
{
	local Controller C;

	num = Clamp(num, 0, MaxPlayers - (NumPlayers + NumBots));

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if ( C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.SteamStatsAndAchievements != none )
		{
			C.PlayerReplicationInfo.SteamStatsAndAchievements.bUsedCheats = true;
		}
	}

	while (--num >= 0)
	{
		if ( Level.NetMode != NM_Standalone )
			MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
		AddBot();
	}
}

// Force add a "human" bot without a weapon for debuggin/testing
exec function MyForceAddBot()
{
	local Bot NewBot;

    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        return;
    }

	NewBot = MySpawnBot();

	if ( NewBot == None )
	{
		warn("Failed to spawn bot.");
		return;
	}

	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
	NumBots++;
	if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead','MPStart');
	return;
}

// Force add a "human" bot without a weapon on the enemy team for debuggin/testing
function Bot MySpawnBot(optional string botName)
{
	local KFInvasionBot NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = Teams[1];
	Chosen = BotTeam.ChooseBotClass(botName);

	if (Chosen.PawnClass == None)
		Chosen.Init(); //amb
	NewBot = Spawn(class 'KFInvasionBot');

	if ( NewBot != None )
		InitializeBot(NewBot,BotTeam,Chosen);

	// Decide if bot should be a veteran.
	if ( LoadedSkills.Length > 0 && FRand() < 0.35 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None )
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];

	NewBot.PlayerReplicationInfo.Score = StartingCash;

	return NewBot;
}

// lazy Cut n' paste to allow maximum tweakage without worrying
// about the effects of underlying classes
function bool AddBot(optional string botName)
{
	local Bot NewBot;

	if (bNoBots)
		return false;

	NewBot = SpawnBot(botName);

	if ( NewBot == None )
	{
		warn("Failed to spawn bot.");
		return false;
	}

	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
	NumBots++;
	if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead','MPStart');
	return true;
}

auto State PendingMatch
{
	function RestartPlayer( Controller aPlayer )
	{
		if ( CountDown <= 0 )
			RestartPlayer(aPlayer);
	}

	function Timer()
	{
		local Controller P;
		local bool bReady;
		local int PlayerCount, ReadyCount;

		Global.Timer();

		if ( Level.NetMode == NM_StandAlone && NumSpectators > 0 ) // Spectating only.
		{
			StartMatch();
			PlayStartupMessage();
			return;
		}

		// first check if there are enough net players, and enough time has elapsed to give people
		// a chance to join
		if ( NumPlayers == 0 )
			bWaitForNetPlayers = true;

		if ( bWaitForNetPlayers && Level.NetMode != NM_Standalone )
		{
			if ( NumPlayers >= MinNetPlayers )
				ElapsedTime++;
			else
				ElapsedTime = 0;

			if ( NumPlayers == MaxPlayers || ElapsedTime > NetWait )
				bWaitForNetPlayers = false;
		}

		if ( Level.NetMode != NM_Standalone && (bWaitForNetPlayers || (bTournament && NumPlayers < MaxPlayers)) )
		{
			PlayStartupMessage();
			return;
		}

		// check if players are ready
		bReady = true;
		StartupStage = 1;

		for ( P = Level.ControllerList; P != None; P = P.NextController )
		{

            //NotifyGameEvent( KFSteamStatsAndAchievements(KFPlayerController(P).SteamStatsAndAchievements).Stat46.Value );

            //KFPlayerController(P).ClientZedsSpawn(EventNum);

			if ( P.IsA('PlayerController') && P.PlayerReplicationInfo != none && P.bIsPlayer && P.PlayerReplicationInfo.Team != none &&
				P.PlayerReplicationInfo.bWaitingPlayer && !P.PlayerReplicationInfo.bOnlySpectator)
			{
				PlayerCount++;

				if ( !P.PlayerReplicationInfo.bReadyToPlay )
					bReady = false;
				else
					ReadyCount++;
			}
		}

		if ( PlayerCount > 0 && bReady && !bReviewingJumpspots )
			StartMatch();

		PlayStartupMessage();

		if ( NumPlayers>2 )
			ElapsedTime++;

		if ( (ReadyCount >= PlayerCount * 0.65 || ElapsedTime > 300) && PlayerCount > 2 && LobbyTimeout > 0 )
		{
			if ( LobbyTimeout <= 1 )
			{
				for ( P = Level.ControllerList; P != None; P = P.NextController )
				{
					if ( P.IsA('PlayerController') && P.PlayerReplicationInfo != none )
						P.PlayerReplicationInfo.bReadyToPlay = True;
				}

				LobbyTimeout = 0;
			}
			else
			{
				LobbyTimeout--;
			}

			KFGameReplicationInfo(GameReplicationInfo).LobbyTimeout = LobbyTimeout;
		}
		else
		{
			KFGameReplicationInfo(GameReplicationInfo).LobbyTimeout = -1;
		}
	}

	function BeginState()
	{
		bWaitingToStartMatch = true;
		StartupStage = 0;

		if ( LobbyTimeout <= 0 )
			LobbyTimeCounter = 10;
		else
			LobbyTimeCounter = LobbyTimeout;

		NetWait = Max(NetWait,0);
	}

	function EndState()
	{
		KFGameReplicationInfo(GameReplicationInfo).LobbyTimeout = -1;
	}

Begin:
	if ( bQuickStart )
	{
	    //this is a hack because we can't declare variables in the Begin label
		DetermineEvent();
		StartMatch();
	}
}

//this is a hack because we can't declare variables in the Begin label
function DetermineEvent()
{
    local Controller P;
	for ( P = Level.ControllerList; P != None; P = P.NextController )
	{
        NotifyGameEvent( KFSteamStatsAndAchievements(KFPlayerController(P).SteamStatsAndAchievements).Stat46.Value );
    }
}

// Added stub function here so the game won't crash when it can't find this  - TODO, maybe just move the function here! - Ramm
function UpdateViews(){}

State MatchInProgress
{
	function bool UpdateMonsterCount() // To avoid invasion errors.
	{
		local Controller C;
		local int i,j;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				if( Monster(C.Pawn)!=None )
					i++;
				else j++;
			}
		}
		NumMonsters = i;
		Return (j>0);
	}

	function bool BootShopPlayers()
	{
		local int i,j;
		local bool bRes;

		j = ShopList.Length;
		for( i=0; i<j; i++ )
		{
			if( ShopList[i].BootPlayers() )
				bRes = True;
		}
		Return bRes;
	}

	function SelectShop()
	{
		local array<ShopVolume> TempShopList;
		local int i;
		local int SelectedShop;

		// Can't select a shop if there aren't any
		if ( ShopList.Length < 1 )
		{
			return;
		}

		for ( i = 0; i < ShopList.Length; i++ )
		{
			if ( ShopList[i].bAlwaysClosed )
				continue;

			TempShopList[TempShopList.Length] = ShopList[i];
		}

		SelectedShop = Rand(TempShopList.Length);

        if ( TempShopList[SelectedShop] != KFGameReplicationInfo(GameReplicationInfo).CurrentShop )
        {
        	KFGameReplicationInfo(GameReplicationInfo).CurrentShop = TempShopList[SelectedShop];
        }
        else if ( SelectedShop + 1 < TempShopList.Length )
        {
        	KFGameReplicationInfo(GameReplicationInfo).CurrentShop = TempShopList[SelectedShop + 1];
        }
        else
        {
        	KFGameReplicationInfo(GameReplicationInfo).CurrentShop = TempShopList[0];
        }
	}

	function OpenShops()
	{
		local int i;
		local Controller C;

		bTradingDoorsOpen = True;

		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bAlwaysClosed )
				continue;
			if( ShopList[i].bAlwaysEnabled )
			{
				ShopList[i].OpenShop();
			}
		}

        if ( KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
        {
            SelectShop();
        }

		KFGameReplicationInfo(GameReplicationInfo).CurrentShop.OpenShop();

		// Tell all players to start showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(true);

					// Have Trader tell players that the Shop's Open
					if ( WaveNum < FinalWave )
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 2);
					}
					else
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 3);
					}

					//Hints
					KFPlayerController(C).CheckForHint(31);
					HintTime_1 = Level.TimeSeconds + 11;
				}
			}
		}
	}

	function CloseShops()
	{
		local int i;
		local Controller C;
		local Pickup Pickup;

		bTradingDoorsOpen = False;
		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bCurrentlyOpen )
				ShopList[i].CloseShop();
		}

		SelectShop();

		foreach AllActors(class'Pickup', Pickup)
		{
			if ( Pickup.bDropped )
			{
				Pickup.Destroy();
			}
		}

		// Tell all players to stop showing the path to the trader
		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( C.Pawn != none && C.Pawn.Health > 0 )
			{
				if ( KFPlayerController(C) != none )
				{
					KFPlayerController(C).SetShowPathToTrader(false);
					KFPlayerController(C).ClientForceCollectGarbage();

					if ( WaveNum < FinalWave - 1 )
					{
						// Have Trader tell players that the Shop's Closed
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 6);
					}
				}
			}
		}
	}

	function Timer()
	{
		local Controller C;
		local bool bOneMessage;
		local Bot B;

		Global.Timer();

		if ( Level.TimeSeconds > HintTime_1 && bTradingDoorsOpen && bShowHint_2 )
		{
			for ( C = Level.ControllerList; C != None; C = C.NextController )
			{
				if( C.Pawn != none && C.Pawn.Health > 0 )
				{
					KFPlayerController(C).CheckForHint(32);
					HintTime_2 = Level.TimeSeconds + 11;
				}
			}

			bShowHint_2 = false;
		}

		if ( Level.TimeSeconds > HintTime_2 && bTradingDoorsOpen && bShowHint_3 )
		{
			for ( C = Level.ControllerList; C != None; C = C.NextController )
			{
				if( C.Pawn != None && C.Pawn.Health > 0 )
				{
					KFPlayerController(C).CheckForHint(33);
				}
			}

			bShowHint_3 = false;
		}

		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
		if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;
		ElapsedTime++;
		GameReplicationInfo.ElapsedTime = ElapsedTime;
		if( !UpdateMonsterCount() )
		{
			EndGame(None,"TimeLimit");
			Return;
		}

		if( bUpdateViewTargs )
			UpdateViews();

		if (!bNoBots && !bBotsAdded)
		{
			if(KFGameReplicationInfo(GameReplicationInfo) != none)

			if((NumPlayers + NumBots) < MaxPlayers && KFGameReplicationInfo(GameReplicationInfo).PendingBots > 0 )
			{
				AddBots(1);
				KFGameReplicationInfo(GameReplicationInfo).PendingBots --;
			}

			if (KFGameReplicationInfo(GameReplicationInfo).PendingBots == 0)
			{
				bBotsAdded = true;
				return;
			}
		}

		if( bWaveBossInProgress )
		{
			// Close Trader doors
			if( bTradingDoorsOpen )
			{
				CloseShops();
				TraderProblemLevel = 0;
			}
			if( TraderProblemLevel<4 )
			{
				if( BootShopPlayers() )
					TraderProblemLevel = 0;
				else TraderProblemLevel++;
			}
			if( !bHasSetViewYet && TotalMaxMonsters<=0 && NumMonsters>0 )
			{
				bHasSetViewYet = True;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( C.Pawn!=None && KFMonster(C.Pawn)!=None && KFMonster(C.Pawn).MakeGrandEntry() )
					{
						ViewingBoss = KFMonster(C.Pawn);
						Break;
					}
				if( ViewingBoss!=None )
				{
					ViewingBoss.bAlwaysRelevant = True;
					for ( C = Level.ControllerList; C != None; C = C.NextController )
					{
						if( PlayerController(C)!=None )
						{
							PlayerController(C).SetViewTarget(ViewingBoss);
							PlayerController(C).ClientSetViewTarget(ViewingBoss);
							PlayerController(C).bBehindView = True;
							PlayerController(C).ClientSetBehindView(True);
							PlayerController(C).ClientSetMusic(BossBattleSong,MTRAN_FastFade);
						}
						if ( C.PlayerReplicationInfo!=None && bRespawnOnBoss )
						{
							C.PlayerReplicationInfo.bOutOfLives = false;
							C.PlayerReplicationInfo.NumLives = 0;
							if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator && PlayerController(C)!=None )
								C.GotoState('PlayerWaiting');
						}
					}
				}
			}
			else if( ViewingBoss!=None && !ViewingBoss.bShotAnim )
			{
				ViewingBoss = None;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if( PlayerController(C)!=None )
					{
						if( C.Pawn==None && !C.PlayerReplicationInfo.bOnlySpectator && bRespawnOnBoss )
							C.ServerReStartPlayer();
						if( C.Pawn!=None )
						{
							PlayerController(C).SetViewTarget(C.Pawn);
							PlayerController(C).ClientSetViewTarget(C.Pawn);
						}
						else
						{
							PlayerController(C).SetViewTarget(C);
							PlayerController(C).ClientSetViewTarget(C);
						}
						PlayerController(C).bBehindView = False;
						PlayerController(C).ClientSetBehindView(False);
					}
			}
			if( TotalMaxMonsters<=0 || (Level.TimeSeconds>WaveEndTime) )
			{
				// if everyone's spawned and they're all dead
				if ( NumMonsters <= 0 )
					DoWaveEnd();
			}
			else AddBoss();
		}
		else if(bWaveInProgress)
		{
			WaveTimeElapsed += 1.0;

			// Close Trader doors
			if (bTradingDoorsOpen)
			{
				CloseShops();
				TraderProblemLevel = 0;
			}
			if( TraderProblemLevel<4 )
			{
				if( BootShopPlayers() )
					TraderProblemLevel = 0;
				else TraderProblemLevel++;
			}
			if(!MusicPlaying)
				StartGameMusic(True);

			if( TotalMaxMonsters<=0 )
			{
				if ( NumMonsters <= 5 /*|| Level.TimeSeconds>WaveEndTime*/ )
				{
					for ( C = Level.ControllerList; C != None; C = C.NextController )
						if ( KFMonsterController(C)!=None && KFMonsterController(C).CanKillMeYet() )
						{
							C.Pawn.KilledBy( C.Pawn );
							Break;
						}
				}
				// if everyone's spawned and they're all dead
				if ( NumMonsters <= 0 )
				{
                    DoWaveEnd();
				}
			} // all monsters spawned
			else if ( (Level.TimeSeconds > NextMonsterTime) && (NumMonsters+NextSpawnSquad.Length <= MaxMonsters) )
			{
				WaveEndTime = Level.TimeSeconds+160;
				if( !bDisableZedSpawning )
				{
                    AddSquad(); // Comment this out to prevent zed spawning
                }

				if(nextSpawnSquad.length>0)
				{
                	NextMonsterTime = Level.TimeSeconds + 0.2;
				}
				else
                {
                    NextMonsterTime = Level.TimeSeconds + CalcNextSquadSpawnTime();
                }
  			}
		}
		else if ( NumMonsters <= 0 )
		{
			if ( WaveNum == FinalWave && !bUseEndGameBoss )
			{
				if( bDebugMoney )
				{
					log("$$$$$$$$$$$$$$$$ Final TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
				}

				EndGame(None,"TimeLimit");
				return;
			}
			else if( WaveNum == (FinalWave + 1) && bUseEndGameBoss )
			{
				if( bDebugMoney )
				{
					log("$$$$$$$$$$$$$$$$ Final TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
				}

				EndGame(None,"TimeLimit");
				return;
			}

			WaveCountDown--;
			if ( !CalmMusicPlaying )
			{
				InitMapWaveCfg();
				StartGameMusic(False);
			}

			// Open Trader doors
			if ( WaveNum != InitialWave && !bTradingDoorsOpen )
			{
            	OpenShops();
			}

			// Select a shop if one isn't open
            if (	KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
            {
                SelectShop();
            }

			KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
			if ( WaveCountDown == 30 )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
					if ( KFPlayerController(C) != None )
					{
						// Have Trader tell players that they've got 30 seconds
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 4);
					}
				}
			}
			else if ( WaveCountDown == 10 )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
					if ( KFPlayerController(C) != None )
					{
						// Have Trader tell players that they've got 10 seconds
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 5);
					}
				}
			}
			else if ( WaveCountDown == 5 )
			{
				KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn=false;
				InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
			}
			else if ( (WaveCountDown > 0) && (WaveCountDown < 5) )
			{
				if( WaveNum == FinalWave && bUseEndGameBoss )
				{
				    BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 3);
				}
				else
				{
                    BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 1);
                }
			}
			else if ( WaveCountDown <= 1 )
			{
				bWaveInProgress = true;
				KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = true;

				// Randomize the ammo pickups again
				if( WaveNum > 0 )
				{
					SetupPickups();
				}

				if( WaveNum == FinalWave && bUseEndGameBoss )
				{
				    StartWaveBoss();
				}
				else
				{
					SetupWave();

					for ( C = Level.ControllerList; C != none; C = C.NextController )
					{
						if ( PlayerController(C) != none )
						{
							PlayerController(C).LastPlaySpeech = 0;

							if ( KFPlayerController(C) != none )
							{
								KFPlayerController(C).bHasHeardTraderWelcomeMessage = false;
							}
						}

						if ( Bot(C) != none )
						{
							B = Bot(C);
							InvasionBot(B).bDamagedMessage = false;
							B.bInitLifeMessage = false;

							if ( !bOneMessage && (FRand() < 0.65) )
							{
								bOneMessage = true;

								if ( (B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn) )
								{
									B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
									B.bInitLifeMessage = false;
								}
							}
						}
					}
			    }
		    }
		}
	}

	// Use a sine wave to somewhat randomly increase/decrease the frequency (and
	// also the intensity) of zombie squad spawning. This will give "peaks and valleys"
	// the the intensity of the zombie attacks
	function float CalcNextSquadSpawnTime()
	{
		local float NextSpawnTime;
		local float SineMod;

		SineMod = 1.0 - Abs(sin(WaveTimeElapsed * SineWaveFreq));

		NextSpawnTime = KFLRules.WaveSpawnPeriod;

        if( KFGameLength != GL_Custom )
        {
            if( KFGameLength == GL_Short )
            {
                // Make the zeds come faster in the earlier waves
                if( WaveNum < 2 )
                {
                    if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.3;
                    }
                }
                // Give a slightly bigger breather in the later waves
                else if( WaveNum >= 2 )
                {
                    if( NumPlayers <= 3 )
                    {
                        NextSpawnTime *= 1.1;
                    }
                    else if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 1.0;//0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.75;//0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.60;//0.3;
                    }
                }
            }
            else if( KFGameLength == GL_Normal )
            {
                // Make the zeds come faster in the earlier waves
                if( WaveNum < 4 )
                {
                    if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.3;
                    }
                }
                // Give a slightly bigger breather in the later waves
                else if( WaveNum >= 4 )
                {
                    if( NumPlayers <= 3 )
                    {
                        NextSpawnTime *= 1.1;
                    }
                    else if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 1.0;//0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.75;//0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.6;//0.3;
                    }
                }
            }
            else if( KFGameLength == GL_Long )
            {
                // Make the zeds come faster in the earlier waves
                if( WaveNum < 7 )
                {
                    if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.3;
                    }
                }
                // Give a slightly bigger breather in the later waves
                else if( WaveNum >= 7 )
                {
                    if( NumPlayers <= 3 )
                    {
                        NextSpawnTime *= 1.1;
                    }
                    else if( NumPlayers == 4 )
                    {
                        NextSpawnTime *= 1.0;//0.85;
                    }
                    else if( NumPlayers == 5 )
                    {
                        NextSpawnTime *= 0.75;//0.65;
                    }
                    else if( NumPlayers >= 6 )
                    {
                        NextSpawnTime *= 0.60;//0.3;
                    }
                }
            }
        }
        else
        {
            if( NumPlayers == 4 )
            {
                NextSpawnTime *= 0.85;
            }
            else if( NumPlayers == 5 )
            {
                NextSpawnTime *= 0.65;
            }
            else if( NumPlayers >= 6 )
            {
                NextSpawnTime *= 0.3;
            }
        }

        // Make the zeds come a little faster at all times on harder and above
        if ( GameDifficulty >= 4.0 ) // Hard
        {
            NextSpawnTime *= 0.85;
        }

		NextSpawnTime += SineMod * (NextSpawnTime * 2);

		return NextSpawnTime;
	}

	function DoWaveEnd()
	{
		local Controller C;
		local KFDoorMover KFDM;
		local PlayerController Survivor;
		local int SurvivorCount;

        // Only reset this at the end of wave 0. That way the sine wave that scales
        // the intensity up/down will be somewhat random per wave
        if( WaveNum < 1 )
        {
            WaveTimeElapsed = 0;
        }

		if ( !rewardFlag )
			RewardSurvivingPlayers();

		if( bDebugMoney )
		{
			log("$$$$$$$$$$$$$$$$ Wave "$WaveNum$" TotalPossibleWaveMoney = "$TotalPossibleWaveMoney,'Debug');
			log("$$$$$$$$$$$$$$$$ TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
			TotalPossibleWaveMoney=0;
		}

		// Clear Trader Message status
		bDidTraderMovingMessage = false;
		bDidMoveTowardTraderMessage = false;

		bWaveInProgress = false;
		bWaveBossInProgress = false;
		bNotifiedLastManStanding = false;
		KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = false;

		WaveCountDown = Max(TimeBetweenWaves,1);
		KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
		WaveNum++;

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( C.PlayerReplicationInfo != none )
			{
				C.PlayerReplicationInfo.bOutOfLives = false;
				C.PlayerReplicationInfo.NumLives = 0;

				if ( KFPlayerController(C) != none )
				{
					if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo) != none )
					{
						KFPlayerController(C).bChangedVeterancyThisWave = false;

						if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill != KFPlayerController(C).SelectedVeterancy )
						{
							KFPlayerController(C).SendSelectedVeterancyToServer();
						}
					}
				}

				if ( C.Pawn != none )
				{
					if ( PlayerController(C) != none )
					{
						Survivor = PlayerController(C);
						SurvivorCount++;
					}
				}
				else if ( !C.PlayerReplicationInfo.bOnlySpectator )
				{
					C.PlayerReplicationInfo.Score = Max(MinRespawnCash,int(C.PlayerReplicationInfo.Score));

					if( PlayerController(C) != none )
					{
						PlayerController(C).GotoState('PlayerWaiting');
						PlayerController(C).SetViewTarget(C);
						PlayerController(C).ClientSetBehindView(false);
						PlayerController(C).bBehindView = False;
						PlayerController(C).ClientSetViewTarget(C.Pawn);
					}

					C.ServerReStartPlayer();
				}

				if ( KFPlayerController(C) != none )
				{
					if ( KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements) != none )
					{
						KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements).WaveEnded();
					}

                    // Don't broadcast this message AFTER the final wave!
                    if( WaveNum < FinalWave )
                    {
						KFPlayerController(C).bSpawnedThisWave = false;
						BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 2);
					}
					else if ( WaveNum == FinalWave )
					{
						KFPlayerController(C).bSpawnedThisWave = false;
					}
					else
					{
						KFPlayerController(C).bSpawnedThisWave = true;
					}
				}
			}
		}

		if ( Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 &&
			 SurvivorCount == 1 && Survivor != none && KFSteamStatsAndAchievements(Survivor.SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(Survivor.SteamStatsAndAchievements).AddOnlySurvivorOfWave();
		}

		bUpdateViewTargs = True;

		//respawn doors
		foreach DynamicActors(class'KFDoorMover', KFDM)
			KFDM.RespawnDoor();
	}
	function InitMapWaveCfg()
	{
		local int i,l;
		local KFRandomSpawn RS;

		l = ZedSpawnList.Length;
		for( i=0; i<l; i++ )
			ZedSpawnList[i].NotifyNewWave(WaveNum);
		foreach DynamicActors(Class'KFRandomSpawn',RS)
			RS.NotifyNewWave(WaveNum,FinalWave-1);
	}
	function StartWaveBoss()
	{
		local int i,l;

		l = ZedSpawnList.Length;
		for( i=0; i<l; i++ )
			ZedSpawnList[i].Reset();
		bHasSetViewYet = False;
		WaveEndTime = Level.TimeSeconds+60;
		NextSpawnSquad.Length = 1;

		if( KFGameLength != GL_Custom )
		{

  		    NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.EndGameBossClass,Class'Class'));
  		    NextspawnSquad[0].static.PreCacheAssets(Level);
        }
        else
        {
            NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(EndGameBossClass,Class'Class'));
            if(NextSpawnSquad[0].default.EventClasses.Length > eventNum)
            {
                NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(NextSpawnSquad[0].default.EventClasses[eventNum],Class'Class'));
            }
  		    NextspawnSquad[0].static.PreCacheAssets(Level);
        }

		if( NextSpawnSquad[0]==None )
			NextSpawnSquad[0] = Class<KFMonster>(FallbackMonster);
		KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = 1;
		TotalMaxMonsters = 1;
		bWaveBossInProgress = True;
	}
	function UpdateViews() // To fix camera stuck on ur spec target
	{
		local Controller C;

		bUpdateViewTargs = False;
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( PlayerController(C) != None && C.Pawn!=None )
				PlayerController(C).ClientSetViewTarget(C.Pawn);
		}
	}

	// Setup the random ammo pickups
	function SetupPickups()
	{
		local int NumWeaponPickups, NumAmmoPickups, Random, i, j;
		local int m;

		// Randomize Available Ammo Pickups
		if ( GameDifficulty >= 5.0 ) // Suicidal and Hell on Earth
		{
			NumWeaponPickups = WeaponPickups.Length * 0.1;
			NumAmmoPickups = AmmoPickups.Length * 0.1;
		}
		else if ( GameDifficulty >= 4.0 ) // Hard
		{
			NumWeaponPickups = WeaponPickups.Length * 0.2;
			NumAmmoPickups = AmmoPickups.Length * 0.35;
		}
		else if ( GameDifficulty >= 2.0 ) // Normal
		{
			NumWeaponPickups = WeaponPickups.Length * 0.3;
			NumAmmoPickups = AmmoPickups.Length * 0.5;
		}
		else // Beginner
		{
			NumWeaponPickups = WeaponPickups.Length * 0.5;
			NumAmmoPickups = AmmoPickups.Length * 0.65;
		}

        // reset all the of the pickups
        for ( m = 0; m < WeaponPickups.Length ; m++ )
        {
       		WeaponPickups[m].DisableMe();
        }

        for ( m = 0; m < AmmoPickups.Length ; m++ )
        {
       		AmmoPickups[m].GotoState('Sleeping', 'Begin');
        }

        // Ramdomly select which pickups to spawn
        for ( i = 0; i < NumWeaponPickups && j < 10000; i++ )
        {
        	Random = Rand(WeaponPickups.Length);

        	if ( !WeaponPickups[Random].bIsEnabledNow )
        	{
        		WeaponPickups[Random].EnableMe();
        	}
        	else
        	{
        		i--;
        	}

        	j++;
        }

        for ( i = 0; i < NumAmmoPickups && j < 10000; i++ )
        {
        	Random = Rand(AmmoPickups.Length);

        	if ( AmmoPickups[Random].bSleeping )
        	{
        		AmmoPickups[Random].GotoState('Pickup');
        	}
        	else
        	{
        		i--;
        	}

        	j++;
        }
    }

	function BeginState()
	{
		Super.BeginState();

		WaveNum = InitialWave;
		InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;

		// Ten second initial countdown
		WaveCountDown = 10;// Modify this if we want to make it take long for zeds to spawn initially

		SetupPickups();
	}

	function EndState()
	{
		local Controller C;

		Super.EndState();

		// Tell all players to stop showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(false);
				}
			}
		}
	}
}

state MatchOver
{
	function Timer()
	{
		Super.Timer();

		if (ElapsedTime % 10 == 0)
		{
			UpdateSteamUserData();
		}

		if( !bBossHasSaidWord )
		{
			bBossHasSaidWord = True;
			BossLaughtIt();
		}
	}

	function BossLaughtIt()
	{
		local Controller C;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( KFMonster(C.Pawn)!=None && C.Pawn.Health>0 && KFMonster(C.Pawn).SetBossLaught() )
				Return;
		}
	}
}

function PlayStartupMessage()
{
}

//This is kinda messy, but we need to get rid of those damned blue
//messages.
event PostLogin( PlayerController NewPlayer )
{
	local int i;

	NewPlayer.SetGRI(GameReplicationInfo);
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	Super.PostLogin(NewPlayer);

	if (UnrealPlayer(NewPlayer) != None)
		UnrealPlayer(NewPlayer).ClientReceiveLoginMenu(LoginMenuClass, bAlwaysShowLoginMenu);
	if ( NewPlayer.PlayerReplicationInfo.Team != None )
		GameEvent("TeamChange",""$NewPlayer.PlayerReplicationInfo.Team.TeamIndex,NewPlayer.PlayerReplicationInfo);

    // Initialize the listen server hosts's VOIP. Had to add this here since the
    // Epic code to do this was calling GetLocalPlayerController() in event Login()
    // which of course will always fail, because the PC's "Player" variable
    // hasn't been set yet. - Ramm
	if ( NewPlayer != None )
	{
		if ( Level.NetMode == NM_ListenServer )
		{
			if ( Level.GetLocalPlayerController() == NewPlayer )
				NewPlayer.InitializeVoiceChat();
		}
	}

	if ( KFPlayerController(NewPlayer) != none )
	{
		for ( i = 0; i < InstancedWeaponClasses.Length; i++ )
		{
			KFPlayerController(NewPlayer).ClientWeaponSpawned(InstancedWeaponClasses[i], none);
		}
	}

	if ( NewPlayer.PlayerReplicationInfo.bOnlySpectator ) // must not be a spectator
	{
		KFPlayerController(NewPlayer).JoinedAsSpectatorOnly();
	}
	else
	{
		NewPlayer.GotoState('PlayerWaiting');
	}

	if( KFPlayerController(NewPlayer)!=None )
		StartInitGameMusic(KFPlayerController(NewPlayer));

	if ( bCustomGameLength && NewPlayer.SteamStatsAndAchievements != none )
	{
		NewPlayer.SteamStatsAndAchievements.bUsedCheats = true;
	}
}

function Logout(Controller Exiting)
{
	local Inventory Inv;

	if ( Exiting.Pawn != none )
	{
		for ( Inv = Exiting.Pawn.Inventory; Inv != none; Inv = Inv.Inventory )
		{
			if ( class<Weapon>(Inv.class) != none )
			{
				WeaponDestroyed(class<Weapon>(Inv.class));
			}
		}
	}

	super.Logout(Exiting);
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	local Controller C;
	local string MapName;
	local KFSteamStatsAndAchievements StatsAndAchievements;

	if ( PlayerController(Killer) != none )
	{
		if ( KFMonster(KilledPawn) != None && Killed != Killer )
		{
			if ( bZEDTimeActive && KFPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none &&
				 KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill != none &&
				 KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill.static.ZedTimeExtensions(KFPlayerReplicationInfo(Killer.PlayerReplicationInfo)) > ZedTimeExtensionsUsed )
			{
				// Force Zed Time extension for every kill as long as the Player's Perk has Extensions left
				DramaticEvent(1.0);

				ZedTimeExtensionsUsed++;
			}
			else if ( Level.TimeSeconds - LastZedTimeEvent > 0.1 )
			{
		        // Possibly do a slomo event when a zombie dies, with a higher chance if the zombie is closer to a player
		        if( Killer.Pawn != none && VSizeSquared(Killer.Pawn.Location - KilledPawn.Location) < 22500 ) // 3 meters
		        {
		            DramaticEvent(0.05);
		        }
		        else
		        {
		            DramaticEvent(0.025);
		        }
		    }

            StatsAndAchievements = KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements);
			if ( StatsAndAchievements != none )
			{
                if( Killer.Pawn.Physics == PHYS_FALLING && damageType == class'DamTypeKrissM')
		        {
		            StatsAndAchievements.AddAirborneZedKill();
		        }

				MapName = GetCurrentMapName(Level);

				StatsAndAchievements.AddKill(KFMonster(KilledPawn).bLaserSightedEBRM14Headshotted, class<DamTypeMelee>(damageType) != none, bZEDTimeActive, class<DamTypeM4AssaultRifle>(damageType) != none || class<DamTypeM4203AssaultRifle>(damageType) != none, class<DamTypeBenelli>(damageType) != none, class<DamTypeMagnum44Pistol>(damageType) != none, class<DamTypeMK23Pistol>(damageType) != none, class<DamTypeFNFALAssaultRifle>(damageType) != none, class<DamTypeBullpup>(damageType) != none, MapName);

				if ( Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 && KilledPawn.AnimAction == 'ZombieFeed' )
				{
					StatsAndAchievements.AddFeedingKill();
				}

				if (MapName ~= "KF-HillbillyHorror")
				{
					if ( class<DamTypeTrenchgun>(damageType) != none )
					{
                 		StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Set200ZedOnFireOnHillbilly);
					}
				}

				if ( KilledPawn.IsA('KFMonster') )
				{
				    if( KFMonster(KilledPawn).bZapped )
				    {
				        KFSteamStatsAndAchievements(KFPlayerController(KFMonster(KilledPawn).ZappedBy.Controller).SteamStatsAndAchievements).AddZedKilledWhileZapped();
                    }

                    if ( Killer.Pawn != none && KFWeapon(Killer.Pawn.Weapon) != none && KFWeapon(Killer.Pawn.Weapon).Tier3WeaponGiver != none &&
					     KFSteamStatsAndAchievements(KFWeapon(Killer.Pawn.Weapon).Tier3WeaponGiver.SteamStatsAndAchievements) != none )
				    {
					    KFSteamStatsAndAchievements(KFWeapon(Killer.Pawn.Weapon).Tier3WeaponGiver.SteamStatsAndAchievements).AddDroppedTier3Weapon();
					    KFWeapon(Killer.Pawn.Weapon).Tier3WeaponGiver = none;
				    }
				}

				if ( KilledPawn.IsA('ZombieCrawler') )
				{
                    if ( class<DamTypeCrossbow>(damageType) != none )
                    {
                        StatsAndAchievements.KilledCrawlerWithCrossbow();
                    }
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddCrawlerKillWithKSG();
					}

					if (class<DamTypeThompson>(damageType) != none)
					{
                    	StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB);
					}

					if (class<DamTypeMKb42AssaultRifle>(damageType) != none)
					{
                    	StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB);
					}

					if ( KilledPawn.Physics == PHYS_Falling && class<DamTypeM79Grenade>(damageType) != none )
					{
						StatsAndAchievements.AddCrawlerKilledInMidair();
					}

					StatsAndAchievements.AddXMasCrawlerKill();
				}
				else if ( KilledPawn.IsA('ZombieBloat') )
				{
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddBloatKillWithKSG();
					}

					StatsAndAchievements.AddBloatKill(class<DamTypeBullpup>(damageType) != none);
				}
				else if ( KilledPawn.IsA('ZombieSiren') )
				{
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddSirenKillWithKSG();
					}

					StatsAndAchievements.AddSirenKill(class<DamTypeLawRocketImpact>(damageType) != none);
				}
				else if ( KilledPawn.IsA('ZombieStalker') )
				{
				    if( class<DamTypeWinchester>(damageType) != none )
                    {
                        StatsAndAchievements.AddStalkerKillWithLAR();
                    }
					if ( class<DamTypeFrag>(damageType) != none )
					{
						StatsAndAchievements.AddStalkerKillWithExplosives();
					}
					else if ( class<DamTypeMelee>(damageType) != none )
					{
						// 25% chance saying something about killing Stalker("Kissy, kissy, darlin!" or "Give us a kiss!")
						if ( !bDidKillStalkerMeleeMessage && FRand() < 0.25 )
						{
							PlayerController(Killer).Speech('AUTO', 19, "");
							bDidKillStalkerMeleeMessage = true;
						}
					}
					else if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddStalkerKillWithKSG();
					}
					else if ( class<DamTypeNailGun>(damageType) != none)
					{
						StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill4StalkersNailgun);
					}

					StatsAndAchievements.AddXMasStalkerKill();
				}
				else if ( KilledPawn.IsA('ZombieHusk') )
				{
					if ( class<DamTypeBurned>(damageType) != none || class<DamTypeFlamethrower>(damageType) != none )
					{
						StatsAndAchievements.KilledHusk(KFMonster(KilledPawn).bDamagedAPlayer);
					}

					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddHuskKillWithKSG();
					}

					if ( class<DamTypeDeagle>(damageType) != none ||
                         class<DamTypeMagnum44Pistol>(damageType) != none ||
                         class<DamTypeDualies>(damageType) != none ||
                         class<DamTypeFlareProjectileImpact>(damageType) != none ||
                         class<DamTypeMK23Pistol>(damageType) != none ||
                         class<DamTypeMagnum44Pistol>(damageType) != none )
					{
						StatsAndAchievements.KilledHuskWithPistol();
					}

                    if( class<DamTypeHuskGun>(damageType) != none ||
                        class<DamTypeHuskGunProjectileImpact>(damageType) != none )
                    {
                        StatsAndAchievements.KilledXMasHuskWithHuskCannon();
                    }
				}
				else if ( KilledPawn.IsA('ZombieScrake') )
				{
					KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements).AddScrakeKill(MapName);

                    if ( class<DamTypeM203Grenade>(damageType) != none)
                    {
                        StatsAndAchievements.AddM203NadeScrakeKill();
                    }

					if ( class<DamTypeChainsaw>(damageType) != none )
					{
						StatsAndAchievements.AddChainsawScrakeKill();
					}

					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddScrakeKillWithKSG();
					}

					if( class<DamTypeFlareRevolver>(damageType )!= none ||
					    class<DamTypeHuskGun>(damageType) != none ||
					    class<DamTypeHuskGunProjectileImpact>(damageType) != none ||
					    class<DamTypeBurned>(damageType) != none ||
					    class<DamTypeHuskGunProjectileImpact>(damageType) != none ||
					    class<DamTypeFlameNade>(damageType) != none ||
					    class<DamTypeFlamethrower>(damageType) != none ||
					    class<DamTypeFlameNade>(damageType) != none ||
					    class<DamTypeFlareProjectileImpact>(damageType) != none ||
					    class<DamTypeTrenchgun>(damageType) != none )
	                 {
                        StatsAndAchievements.ScrakeKilledByFire();
	                 }

	                 if(class<DamTypeClaymoreSword>(damageType) != none)
	                 {
	                     StatsAndAchievements.AddXMasClaymoreScrakeKill();
                     }

				}
				else if ( KilledPawn.IsA('ZombieFleshPound') )
				{
					StatsAndAchievements.KilledFleshpound(class<DamTypeMelee>(damageType) != none, class<DamTypeAA12Shotgun>(damageType) != none, class<DamTypeKnife>(damageType) != none, class<DamTypeClaymoreSword>(damageType) != none);

					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddFleshPoundKillWithKSG();
					}

					else if ( class<DamTypeDwarfAxe>(damageType) != none )
					{
					    if ( KFMonster(KilledPawn).bBackstabbed )
					    {
						    StatsAndAchievements.AddFleshpoundAxeKill();
					    }
					}

				}
				else if ( KilledPawn.IsA('ZombieBoss') )
				{
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddBossKillWithKSG();
					}

					for ( C = Level.ControllerList; C != none; C = C.NextController )
					{
						if ( PlayerController(C) != none && KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements) != none )
						{
							KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements).KilledPatriarch(KFMonster(KilledPawn).bHealed, class<DamTypeLAW>(damageType) != none, GameDifficulty >= 5.0, KFMonster(KilledPawn).bOnlyDamagedByCrossbow, class<DamTypeClaymoreSword>(damageType) != none, MapName);
						}
					}
				}
				else if ( KilledPawn.IsA('ZombieClot') )
				{
				    StatsAndAchievements.AddClotKill();
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddClotKillWithKSG();
					}
				}
				else if ( KilledPawn.IsA('ZombieGoreFast') )
				{
					if ( class<DamTypeKSGShotgun>(damageType) != none )
					{
						StatsAndAchievements.AddGoreFastKillWithKSG();
					}
					else if ( class<DamTypeTrenchgun>(damageType) != none ||
							  class<DamTypeFlareRevolver>(damageType) != none ||
							  class<DamTypeFlareProjectileImpact>(damageType) != none)
					{
						StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Set3HillbillyGorefastsOnFire);
					}

					if( KFMonster(KilledPawn).bBackstabbed )
					{
					    StatsAndAchievements.AddGorefastBackstab();
					}
				}

				if ( class<KFWeaponDamageType>(damageType) != none )
				{
					class<KFWeaponDamageType>(damageType).Static.AwardKill(StatsAndAchievements,KFPlayerController(Killer),KFMonster(KilledPawn));

					if ( class<DamTypePipeBomb>(damageType) != none )
					{
						if ( KFPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill == class'KFVetDemolitions' )
						{
							StatsAndAchievements.AddDemolitionsPipebombKill();
						}
					}
					else if ( class<DamTypeBurned>(damageType) != none )
					{
						// 1% chance of the Killer saying something about burning the enemy to death
						if ( FRand() < 0.01 && Level.TimeSeconds - LastBurnedEnemyMessageTime > BurnedEnemyMessageDelay )
						{
							PlayerController(Killer).Speech('AUTO', 20, "");
							LastBurnedEnemyMessageTime = Level.TimeSeconds;
						}
					}
					else if ( class<DamTypeSCARMK17AssaultRifle>(damageType) != none )
					{
						StatsAndAchievements.AddSCARKill();
					}
					else if ( class<DamTypeM7A3M>(damageType) != none && KFMonster(KilledPawn).bDamagedAPlayer )
					{
						StatsAndAchievements.OnKilledZedInjuredPlayerWithM7A3();
					}
					else if ( class<DamTypeMKb42AssaultRifle>(damageType) != none)
					{
						StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill6ZedWithoutReloadingMKB42);
					}
					else if ( class<DamTypeAxe>(damageType) != none)
					{
						StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill5HillbillyZedsIn10SecsSythOrAxe);
					}
					else if ( class<DamTypeScythe>(damageType) != none)
					{
						StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill5HillbillyZedsIn10SecsSythOrAxe);
					}
				}
				StatsAndAchievements.AddKillPoints(StatsAndAchievements.KFACHIEVEMENT_Kill1000HillbillyZeds);
			}
		}
    }

	if ( (MonsterController(Killed) != None) || (Monster(KilledPawn) != None) )
	{
		ZombiesKilled++;
		KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = Max(TotalMaxMonsters + NumMonsters - 1,0);
   		if ( !bDidTraderMovingMessage )
   		{
   			if ( PlayerController(Killer) != none && float(ZombiesKilled) / float(ZombiesKilled + TotalMaxMonsters + NumMonsters - 1) >= 0.20 )
   			{
   				if ( WaveNum < FinalWave - 1 || (WaveNum < FinalWave && bUseEndGameBoss) )
   				{
					// Have Trader tell players that the Shop's Moving
					PlayerController(Killer).ServerSpeech('TRADER', 0, "");
		   		}

	   			bDidTraderMovingMessage = true;
	   		}
   		}
   		else if ( !bDidMoveTowardTraderMessage )
   		{
   			if ( PlayerController(Killer) != none && float(ZombiesKilled) / float(ZombiesKilled + TotalMaxMonsters + NumMonsters - 1) >= 0.80 )
   			{
   				if ( WaveNum < FinalWave - 1 || (WaveNum < FinalWave && bUseEndGameBoss) )
   				{
	   				if ( Level.NetMode != NM_Standalone || Killer.Pawn == none || KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none ||
					   	 VSizeSquared(Killer.Pawn.Location - KFGameReplicationInfo(GameReplicationInfo).CurrentShop.Location) > 2250000 ) // 30 meters
					{
						// Have Trader tell players that the Shop's Almost Open
						PlayerController(Killer).Speech('TRADER', 1, "");
					}
				}

   				bDidMoveTowardTraderMessage = true;
   			}
   		}
	}

	if ( KFMonster(KilledPawn) != none && class<DamTypeVomit>(damageType) != none )
	{
		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( PlayerController(C) != none && KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements).KilledEnemyWithBloatAcid();
			}
		}
	}

	Super.Killed(Killer,Killed,KilledPawn,DamageType);
}

function SetupWave()
{
	local int i,j;
	local float NewMaxMonsters;
	//local int m;
	local float DifficultyMod, NumPlayersMod;
	local int UsedNumPlayers;

	if ( WaveNum > 15 )
	{
		SetupRandomWave();
		return;
	}

	TraderProblemLevel = 0;
	rewardFlag=false;
	ZombiesKilled=0;
	WaveMonsters = 0;
	WaveNumClasses = 0;
	NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;

    // scale number of zombies by difficulty
    if ( GameDifficulty >= 7.0 ) // Hell on Earth
    {
    	DifficultyMod=1.7;
    }
    else if ( GameDifficulty >= 5.0 ) // Suicidal
    {
    	DifficultyMod=1.5;
    }
    else if ( GameDifficulty >= 4.0 ) // Hard
    {
    	DifficultyMod=1.3;
    }
    else if ( GameDifficulty >= 2.0 ) // Normal
    {
    	DifficultyMod=1.0;
    }
    else //if ( GameDifficulty == 1.0 ) // Beginner
    {
    	DifficultyMod=0.7;
    }

    UsedNumPlayers = NumPlayers + NumBots;

    // Scale the number of zombies by the number of players. Don't want to
    // do this exactly linear, or it just gets to be too many zombies and too
    // long of waves at higher levels - Ramm
	switch ( UsedNumPlayers )
	{
		case 1:
			NumPlayersMod=1;
			break;
		case 2:
			NumPlayersMod=2;
			break;
		case 3:
			NumPlayersMod=2.75;
			break;
		case 4:
			NumPlayersMod=3.5;
			break;
		case 5:
			NumPlayersMod=4;
			break;
		case 6:
			NumPlayersMod=4.5;
			break;
        default:
            NumPlayersMod=UsedNumPlayers*0.8; // in case someone makes a mutator with > 6 players
	}

    NewMaxMonsters = NewMaxMonsters * DifficultyMod * NumPlayersMod;

    TotalMaxMonsters = Clamp(NewMaxMonsters,5,800);  //11, MAX 800, MIN 5

	MaxMonsters = Clamp(TotalMaxMonsters,5,MaxZombiesOnce);
	//log("****** "$MaxMonsters$" Max at once!");

	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters=TotalMaxMonsters;
	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn=true;
	WaveEndTime = Level.TimeSeconds + Waves[WaveNum].WaveDuration;
	AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;

	j = ZedSpawnList.Length;
	for( i=0; i<j; i++ )
		ZedSpawnList[i].Reset();
	j = 1;
	SquadsToUse.Length = 0;

	for ( i=0; i<InitSquads.Length; i++ )
	{
		if ( (j & Waves[WaveNum].WaveMask) != 0 )
		{
            SquadsToUse.Insert(0,1);
            SquadsToUse[0] = i;

            // Ramm ZombieSpawn debugging
            /*for ( m=0; m<InitSquads[i].MSquad.Length; m++ )
            {
               log("Wave "$WaveNum$" Squad "$SquadsToUse.Length$" Monster "$m$" "$InitSquads[i].MSquad[m]);
            }
            log("****** "$TotalMaxMonsters);*/
		}
		j *= 2;
	}

    // Save this for use elsewhere
    InitialSquadsToUseSize = SquadsToUse.Length;
    bUsedSpecialSquad=false;
    SpecialListCounter=1;

	//Now build the first squad to use
	BuildNextSquad();
}

function BuildNextSquad()
{
	local int i, j, RandNum;
	//local int m;

    // Reinitialize the SquadsToUse after all the squads have been used up
	if( SquadsToUse.Length == 0 )
	{
        j = 1;

        for ( i=0; i<InitSquads.Length; i++ )
    	{
    		if ( (j & Waves[WaveNum].WaveMask) != 0 )
    		{
    			SquadsToUse.Insert(0,1);
    			SquadsToUse[0] = i;

                // Ramm ZombieSpawn debugging
                /*
                for ( m=0; m<InitSquads[i].MSquad.Length; m++ )
                {
                   log("ReInit!!! Wave "$WaveNum$" Squad "$SquadsToUse.Length$" Monster "$m$" "$InitSquads[i].MSquad[m]);
                }
                log("****** "$TotalMaxMonsters);*/
    		}

    		j *= 2;
    	}

    	if( SquadsToUse.Length==0 )
    	{
    		Warn("No squads to initilize with.");
    		Return;
    	}

	    // Save this for use elsewhere
        InitialSquadsToUseSize = SquadsToUse.Length;
        SpecialListCounter++;
        bUsedSpecialSquad=false;
	}

	RandNum = Rand(SquadsToUse.Length);
	NextSpawnSquad = InitSquads[SquadsToUse[RandNum]].MSquad;

	// Take this squad out of the list so we don't get repeats
	SquadsToUse.Remove(RandNum,1);

}

// If spawning in the previous zombie volume failed, try another
function TryToSpawnInAnotherVolume(optional bool bBossSpawning)
{
    //log("Spawning failed, trying another volume");
	LastZVol = FindSpawningVolume(false, bBossSpawning);
	if( LastZVol!=None )
		LastSpawningVolume = LastZVol;
}

function AddSpecialSquadFromGameType()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up Special monster classes...");
	for( i=0; i<SpecialSquads[WaveNum].ZedClass.Length; i++ )
	{
		if( SpecialSquads[WaveNum].ZedClass[i]=="" )
		{
			//log("Missing a special squad!!!");
            Continue;
		}
		MC = Class<KFMonster>(DynamicLoadObject(SpecialSquads[WaveNum].ZedClass[i],Class'Class'));
		if( MC==None )
		{
			//log("Couldn't DLO a special squad!!!");
            Continue;
		}

        for( j=0; j<SpecialSquads[WaveNum].NumZeds[i]; j++ )
        {
            //log("SpecialSquad!!! Wave "$WaveNum$" Monster "$j$" = "$MC);

            TempSquads[TempSquads.Length] = MC;
        }
        //log("****** SpecialSquad");
	}

    bUsedSpecialSquad = true;

	NextSpawnSquad = TempSquads;
}

function AddSpecialSquadFromCollection()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up Special monster classes...");
	for( i=0; i<MonsterCollection.default.SpecialSquads[WaveNum].ZedClass.Length; i++ )
	{
		if( MonsterCollection.default.SpecialSquads[WaveNum].ZedClass[i]=="" )
		{
			//log("Missing a special squad!!!");
            Continue;
		}
		MC = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.SpecialSquads[WaveNum].ZedClass[i],Class'Class'));
		if( MC==None )
		{
			//log("Couldn't DLO a special squad!!!");
            Continue;
		}

        for( j=0; j<MonsterCollection.default.SpecialSquads[WaveNum].NumZeds[i]; j++ )
        {
            //log("SpecialSquad!!! Wave "$WaveNum$" Monster "$j$" = "$MC);

            TempSquads[TempSquads.Length] = MC;
        }
        //log("****** SpecialSquad");
	}

    bUsedSpecialSquad = true;

	NextSpawnSquad = TempSquads;
}
// Load up a special monster squad. Used outside of the normal system to spawn
// a group of particularly nasty squad of zeds only once per time through the
// squad list
function AddSpecialSquad()
{
    if( SpecialSquads.Length == 0 )
    {
        AddSpecialSquadFromCollection();
    }
    else
    {
        AddSpecialSquadFromGameType();
    }
}

function bool AddSquad()
{
	local int numspawned;
	local int ZombiesAtOnceLeft;
	local int TotalZombiesValue;

	if(LastZVol==none || NextSpawnSquad.length==0)
	{
        // Throw in the special squad if the time is right
        if( KFGameLength != GL_Custom && !bUsedSpecialSquad &&
            (MonsterCollection.default.SpecialSquads.Length >= WaveNum || SpecialSquads.Length >= WaveNum)
            && MonsterCollection.default.SpecialSquads[WaveNum].ZedClass.Length > 0
            && (SpecialListCounter%2 == 1))
		{
            AddSpecialSquad();
		}
		else
		{
            BuildNextSquad();
        }
		LastZVol = FindSpawningVolume();
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;
	}

	if(LastZVol == None)
	{
		NextSpawnSquad.length = 0;
		return false;
	}

    // How many zombies can we have left to spawn at once
    ZombiesAtOnceLeft = MaxMonsters - NumMonsters;

	//Log("Spawn on"@LastZVol.Name);
	if( LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,ZombiesAtOnceLeft,TotalZombiesValue) )
	{
    	NumMonsters += numspawned; //NextSpawnSquad.Length;
    	WaveMonsters+= numspawned; //NextSpawnSquad.Length;

        if( bDebugMoney )
        {
            if ( GameDifficulty >= 7.0 ) // Hell on Earth
            {
            	TotalZombiesValue *= 0.5;
            }
            else if ( GameDifficulty >= 5.0 ) // Suicidal
            {
            	TotalZombiesValue *= 0.6;
            }
            else if ( GameDifficulty >= 4.0 ) // Hard
            {
            	TotalZombiesValue *= 0.75;
            }
            else if ( GameDifficulty >= 2.0 ) // Normal
            {
            	TotalZombiesValue *= 1.0;
            }
            else //if ( GameDifficulty == 1.0 ) // Beginner
            {
            	TotalZombiesValue *= 2.0;
            }

            TotalPossibleWaveMoney += TotalZombiesValue;
            TotalPossibleMatchMoney += TotalZombiesValue;
        }

    	NextSpawnSquad.Remove(0, numspawned);

    	return true;
    }
    else
    {
        TryToSpawnInAnotherVolume();
        return false;
    }
}

function bool AddBoss()
{
	local int ZombiesAtOnceLeft;
	local int numspawned;

	FinalSquadNum = 0;

    // Force this to the final boss class
	NextSpawnSquad.Length = 1;
	if( KFGameLength != GL_Custom)
	{
 	    NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.EndGameBossClass,Class'Class'));
    }
    else
    {
        NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(EndGameBossClass,Class'Class'));
        //override the monster with its event version
        if(NextSpawnSquad[0].default.EventClasses.Length > eventNum)
        {
            NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(NextSpawnSquad[0].default.EventClasses[eventNum],Class'Class'));
        }
    }

	if( LastZVol==none )
	{
		LastZVol = FindSpawningVolume(false, true);
		if(LastZVol!=None)
			LastSpawningVolume = LastZVol;
	}

	if(LastZVol == None)
	{
		LastZVol = FindSpawningVolume(true, true);
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;

		if( LastZVol == none )
		{
            //log("Error!!! Couldn't find a place for the Patriarch after 2 tries, trying again later!!!");
            TryToSpawnInAnotherVolume(true);
            return false;
		}
	}

    // How many zombies can we have left to spawn at once
    ZombiesAtOnceLeft = MaxMonsters - NumMonsters;

    //log("Patrarich spawn, MaxMonsters = "$MaxMonsters$" NumMonsters = "$NumMonsters$" ZombiesAtOnceLeft = "$ZombiesAtOnceLeft$" TotalMaxMonsters = "$TotalMaxMonsters);

	if(LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,32/*ZombiesAtOnceLeft*/,,true))
	{
        //log("Spawned Patriarch - numspawned = "$numspawned);

        NumMonsters+=numspawned;
        WaveMonsters+=numspawned;

        return true;
	}
    else
    {
        //log("Failed Spawned Patriarch - numspawned = "$numspawned);

        TryToSpawnInAnotherVolume(true);
        return false;
    }

}

// Spawn a helper squad for the patriarch when he runs off to heal
function AddBossBuddySquad()
{
	local int numspawned;
	local int TotalZombiesValue;
	local int i;
	local int TempMaxMonsters;
	local int TotalSpawned;
	local int TotalZeds;
	local int SpawnDiff;

    // Scale the number of helpers by the number of players
    if( NumPlayers == 1 )
    {
        TotalZeds = 8;
    }
    else if( NumPlayers <= 3 )
    {
        TotalZeds = 12;
    }
    else if( NumPlayers <= 5 )
    {
        TotalZeds = 14;
    }
    else if( NumPlayers >= 6 )
    {
        TotalZeds = 16;
    }

	for ( i = 0; i < 10; i++ )
    {
        if( TotalSpawned >= TotalZeds )
        {
            FinalSquadNum++;
            //log("Too many monsters, returning");
            return;
        }

        numspawned = 0;

        // Set up the squad for spawning
        NextSpawnSquad.length = 0;
        AddSpecialPatriarchSquad();

		LastZVol = FindSpawningVolume();
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;

    	if(LastZVol == None)
    	{
    		LastZVol = FindSpawningVolume();
    		if( LastZVol!=None )
    			LastSpawningVolume = LastZVol;

    		if( LastZVol == none )
    		{
                log("Error!!! Couldn't find a place for the Patriarch squad after 2 tries!!!");
    		}
    	}

        // See if we've reached the limit
        if( (NextSpawnSquad.Length + TotalSpawned) > TotalZeds )
        {
            SpawnDiff = (NextSpawnSquad.Length + TotalSpawned) - TotalZeds;

            if( NextSpawnSquad.Length > SpawnDiff )
            {
                NextSpawnSquad.Remove(0, SpawnDiff);
            }
            else
            {
                FinalSquadNum++;
                return;
            }

            if( NextSpawnSquad.Length == 0 )
            {
                FinalSquadNum++;
                return;
            }
        }

        // Spawn the squad
        TempMaxMonsters =999;
    	if( LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TempMaxMonsters,999,TotalZombiesValue) )
    	{
        	NumMonsters += numspawned;
        	WaveMonsters+= numspawned;
        	TotalSpawned += numspawned;

        	NextSpawnSquad.Remove(0, numspawned);
        }
    }

    FinalSquadNum++;
}

function AddSpecialPatriarchSquadFromGameType()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up FinalSquads monster classes...");
	for( i=0; i<FinalSquads[FinalSquadNum].ZedClass.Length; i++ )
	{
		if( FinalSquads[FinalSquadNum].ZedClass[i]=="" )
		{
			//log("Missing a FinalSquads squad!!!");
            Continue;
		}

	    MC = Class<KFMonster>(DynamicLoadObject(FinalSquads[FinalSquadNum].ZedClass[i],Class'Class'));

		if( MC==None )
		{
			//log("Couldn't DLO a FinalSquads squad!!!");
            Continue;
		}

        for( j=0; j<FinalSquads[FinalSquadNum].NumZeds[i]; j++ )
        {
            //log("FinalSquads!!! FinalSquadNum "$FinalSquadNum$" Monster "$j$" = "$MC);

            TempSquads[TempSquads.Length] = MC;
        }
        //log("****** FinalSquads");
	}

	NextSpawnSquad = TempSquads;

}


function AddSpecialPatriarchSquadFromCollection()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up FinalSquads monster classes...");
	for( i=0; i<MonsterCollection.default.FinalSquads[FinalSquadNum].ZedClass.Length; i++ )
	{
		if( MonsterCollection.default.FinalSquads[FinalSquadNum].ZedClass[i]=="" )
		{
			//log("Missing a FinalSquads squad!!!");
            Continue;
		}

	    MC = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.FinalSquads[FinalSquadNum].ZedClass[i],Class'Class'));

		if( MC==None )
		{
			//log("Couldn't DLO a FinalSquads squad!!!");
            Continue;
		}

        for( j=0; j<MonsterCollection.default.FinalSquads[FinalSquadNum].NumZeds[i]; j++ )
        {
            //log("FinalSquads!!! FinalSquadNum "$FinalSquadNum$" Monster "$j$" = "$MC);

            TempSquads[TempSquads.Length] = MC;
        }
        //log("****** FinalSquads");
	}

	NextSpawnSquad = TempSquads;

}

// Fill up the special patriarch squad
function AddSpecialPatriarchSquad()
{
    if( FinalSquads.Length == 0 )
    {
        AddSpecialPatriarchSquadFromCollection();
    }
    else
    {
        AddSpecialPatriarchSquadFromGameType();
    }
}

// Ramm debugging code
/*
exec function CheckVol()
{
	local ZombieVolume BestZ;
	local float BestScore,tScore;
	local int i,l;
	local Controller C;
	local array<Controller> CL;

	ClearStayingDebugLines();

	BuildNextSquad();

	// First pass, pick a random player.
	for( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health>0 )
			CL[CL.Length] = C;
	}
	if( CL.Length>0 )
		C = CL[Rand(CL.Length)];
	else if( C==None )
		return; // Shouldnt get to this case, but just to be sure...

	// Second pass, figure out best spawning point.
	l = ZedSpawnList.Length;
	for( i=0; i<l; i++ )
	{
		ZedSpawnList[i].bDebugZoneSelection = true;
        tScore = ZedSpawnList[i].RateZombieVolume(Self,LastSpawningVolume,C);
		if( tScore<0 )
			continue;
		if( BestZ==None || (tScore>BestScore) )
		{
			BestScore = tScore;
			BestZ = ZedSpawnList[i];
		}
	}

    BestZ.DrawDebugCylinder(BestZ.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),C.Pawn.CollisionRadius * 5,C.Pawn.CollisionHeight * 5,8,128, 255, 255);

	LastSpawningVolume = BestZ;
	BestZ.LastSpawnTime = Level.TimeSeconds;
}

exec function TestSpawn()
{
	local ZombieVolume BestZ;
	local float BestScore,tScore;
	local int i,l;
	local Controller C;
	local array<Controller> CL;

	ClearStayingDebugLines();

	// Second pass, figure out best spawning point.
	l = ZedSpawnList.Length;
	for( i=0; i<l; i++ )
	{
		ZedSpawnList[i].bDebugSpawnSelection = !ZedSpawnList[i].bDebugSpawnSelection;
	}
}
*/
// End Ramm Spawning debugging


function ZombieVolume FindSpawningVolume(optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{
	local ZombieVolume BestZ;
	local float BestScore,tScore;
	local int i,l;
	local Controller C;
	local array<Controller> CL;

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
	l = ZedSpawnList.Length;
	for( i=0; i<l; i++ )
	{
        tScore = ZedSpawnList[i].RateZombieVolume(Self,LastSpawningVolume,C,bIgnoreFailedSpawnTime, bBossSpawning);
		if( tScore<0 )
			continue;
		if( BestZ==None || (tScore>BestScore) )
		{
			BestScore = tScore;
			BestZ = ZedSpawnList[i];
		}
	}
	return BestZ;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local float InstigatorSkill;
	local KFPlayerController PC;
	local float DamageBeforeSkillAdjust;

    if ( KFPawn(Injured) != none )
	{
		if ( KFPlayerReplicationInfo(Injured.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			Damage = KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill.Static.ReduceDamage(KFPlayerReplicationInfo(Injured.PlayerReplicationInfo), KFPawn(Injured), KFMonster(instigatedBy), Damage, DamageType);
		}
	}

	// This stuff cuts thru all the B.S
	if ( DamageType == class'DamTypeVomit' || DamageType == class'DamTypeWelder' || DamageType == class'SirenScreamDamage' )
	{
		return damage;
	}

	if ( instigatedBy == None )
	{
		return Super(xTeamGame).ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	}

	if ( Monster(Injured) != None )
	{
		if ( instigatedBy != None )
		{
			PC = KFPlayerController(instigatedBy.Controller);
			if ( Class<KFWeaponDamageType>(damageType) != none && PC != none )
			{
				Class<KFWeaponDamageType>(damageType).Static.AwardDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), Clamp(Damage, 1, Injured.Health));
			}
		}

		return super(UnrealMPGameInfo).ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );
	}

	if ( MonsterController(InstigatedBy.Controller) != None )
	{
		InstigatorSkill = MonsterController(instigatedBy.Controller).Skill;
		if ( NumPlayers > 4 )
			InstigatorSkill += 1.0;
		if ( (InstigatorSkill < 7) && (Monster(Injured) == None) )
		{
			if ( InstigatorSkill <= 3 )
				Damage = Damage;
			else Damage = Damage;
		}
	}
	else if ( KFFriendlyAI(InstigatedBy.Controller) != None && KFHumanPawn(Injured) != none  )
		Damage *= 0.25;
	else if ( injured == instigatedBy )
		Damage = Damage * 0.5;


	if ( InvasionBot(injured.Controller) != None )
	{
		if ( !InvasionBot(injured.controller).bDamagedMessage && (injured.Health - Damage < 50) )
		{
			InvasionBot(injured.controller).bDamagedMessage = true;
			if ( FRand() < 0.5 )
				injured.Controller.SendMessage(None, 'OTHER', 4, 12, 'TEAM');
			else injured.Controller.SendMessage(None, 'OTHER', 13, 12, 'TEAM');
		}
		if ( GameDifficulty <= 3 )
		{
			if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
				Damage *= 0.5;

			//skill level modification
			if ( MonsterController(InstigatedBy.Controller) != None )
				Damage = Damage;
		}
	}

	if( injured.InGodMode() )
		return 0;
	if( instigatedBy!=injured && MonsterController(InstigatedBy.Controller)==None && (instigatedBy.Controller==None || instigatedBy.GetTeamNum()==injured.GetTeamNum()) )
	{
		if ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
			Momentum *= TeammateBoost;
		if ( Bot(injured.Controller) != None )
			Bot(Injured.Controller).YellAt(instigatedBy);

		if ( FriendlyFireScale==0.0 || (Vehicle(injured) != None && Vehicle(injured).bNoFriendlyFire) )
		{
			if ( GameRulesModifiers != None )
				return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
			else return 0;
		}
		Damage *= FriendlyFireScale;
	}

	// Start code from DeathMatch.uc - Had to override this here because it was reducing
	// bite damage (which is 1) down to zero when the skill settings were low

	if ( (instigatedBy != None) && (InstigatedBy != Injured) && (Level.TimeSeconds - injured.SpawnTime < SpawnProtectionTime)
		&& (class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None) )
		return 0;

    Damage = super(UnrealMPGameInfo).ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( instigatedBy == None)
        return Damage;

    DamageBeforeSkillAdjust = Damage;

    if ( Level.Game.GameDifficulty <= 3 )
    {
        if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
            Damage *= 0.5;
    }
    return (Damage * instigatedBy.DamageScaling);
	// End code from DeathMatch.uc
}

static function bool NeverAllowTransloc()
{
	return true;
}

function bool AllowTransloc()
{
	return bAllowTrans || bOverrideTranslocator;
}

function AddGameSpecificInventory(Pawn p);

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local PlayerController NewPlayer;
	local Controller C;

	NewPlayer = Super.Login(Portal,Options,Error);

	if ( NewPlayer.PlayerReplicationInfo.bOnlySpectator && NumSpectators > MaxSpectators )
	{
		Error = GameMessageClass.Default.MaxedOutMessage;
		NewPlayer.Destroy();
		return None;
	}
	else if ( !NewPlayer.PlayerReplicationInfo.bOnlySpectator && NumPlayers > MaxPlayers && !NewPlayer.PlayerReplicationInfo.bAdmin )
	{
		Error = GameMessageClass.Default.MaxedOutMessage;
		NewPlayer.Destroy();
		return None;
	}

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (C.PlayerReplicationInfo != None) && C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator && !GameReplicationInfo.bMatchHasBegun )
		{
			NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
			NewPlayer.PlayerReplicationInfo.NumLives = 1;
			Break;
		}
	}

	NewPlayer.SetGRI(GameReplicationInfo);

	//let's route to our custom KFPlayerController state for class Selection.

	// give the new player the server starting cash
	if ( !NewPlayer.PlayerReplicationInfo.bOnlySpectator ) // must not be a spectator
	{
		NewPlayer.PlayerReplicationInfo.Score = StartingCash;
	}

	if ( bDelayedStart ) //!
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;
	}

	return NewPlayer;
}

event PreLogin( string Options, string Address, string PlayerID, out string Error, out string FailCode )
{
	Super.PreLogin(Options,Address,PlayerID,Error,FailCode);
	if( FailCode=="" && GameReplicationInfo.bMatchHasBegun && bNoLateJoiners )
	{
		FailCode = "FC_NoLateJoiners";
		Error = NoLateJoiners;
	}
}
function bool AtCapacity(bool bSpectator)
{
	if ( Level.NetMode == NM_Standalone )
		return false;

	if ( bSpectator )
		return ( (NumSpectators >= MaxSpectators)
				&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
	else
		return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

// Mod this to include the choices made in the GUIClassMenu
function RestartPlayer( Controller aPlayer )
{
	if ( aPlayer.PlayerReplicationInfo.bOutOfLives || aPlayer.Pawn!=None )
		return;
	if( bWaveInProgress && PlayerController(aPlayer)!=None )
	{
		aPlayer.PlayerReplicationInfo.bOutOfLives = True;
		aPlayer.PlayerReplicationInfo.NumLives = 1;
		aPlayer.GoToState('Spectating');
		Return;
	}

	Super.RestartPlayer(aPlayer);

	if ( KFHumanPawn(aPlayer.Pawn) != none )
	{
		KFHumanPawn(aPlayer.Pawn).VeterancyChanged();
	}
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	local string S;

	if( damageType==None )
		damageType = Class'DamageType';
	if( Killer!=None && Other!=None && Killer!=Other )
		Broadcast(Self,ParseKillMessage(GetNameOf(Killer.Pawn),GetNameOf(Other.Pawn),damageType.Default.DeathString),'DeathMessage');
	else if( Other!=None )
	{
		if( Other.Pawn!=None && Other.Pawn.bIsFemale )
			S = damageType.Default.FemaleSuicide;
		else S = damageType.Default.MaleSuicide;
		Broadcast(Self,ParseKillMessage("Someone",GetNameOf(Other.Pawn),S),'DeathMessage');
	}
}
function string GetNameOf( Pawn Other )
{
	local string S;

	if( Other==None )
		Return "Someone";
	if( Other.PlayerReplicationInfo!=None )
		Return Other.PlayerReplicationInfo.PlayerName;
	S = Other.MenuName;
	if( S=="" )
	{
		Other.MenuName = string(Other.Class.Name);
		S = Other.MenuName;
	}
	if( Monster(Other)!=None && Monster(Other).bBoss )
		Return "the"@S;
	else if( Class'KFInvasionMessage'.Static.ShouldUseAn(S) )
		Return "an"@S;
	else Return "a"@S;
}

function GetServerInfo( out ServerResponseLine ServerState )
{
	super.GetServerInfo(ServerState);

	if ( GameDifficulty == 1.0 )
	{
		ServerState.Flags = ServerState.Flags | 32;
	}
	else if ( GameDifficulty == 2.0 )
	{
		ServerState.Flags = ServerState.Flags | 64;
	}
	else if ( GameDifficulty == 4.0 )
	{
		ServerState.Flags = ServerState.Flags | 128;
	}
	else if ( GameDifficulty == 5.0 )
	{
		ServerState.Flags = ServerState.Flags | 256;
	}
	else if ( GameDifficulty == 7.0 )
	{
		ServerState.Flags = ServerState.Flags | 512;
	}
}

function GetServerDetails( out ServerResponseLine ServerState )
{
	local int l;

	Super.GetServerDetails( ServerState );
	l = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "Max runtime zombies";
	ServerState.ServerInfo[l].Value = string(MaxZombiesOnce);
	l++;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "Starting cash";
	ServerState.ServerInfo[l].Value = string(StartingCash);
	l++;
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == Teams[0] )
		return false;

	Other.StartSpot = None;

	if ( Teams[0].AddToTeam(Other) )
	{
		if ( bNewTeam && PlayerController(Other)!=None )
			GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
	}
	return true;
}

static function string GetCurrentMapName(LevelInfo TheLevel)
{
	local string Ret;
	local int i, j;

	// Get the MapName out of the URL
	Ret = TheLevel.GetLocalURL();

	i = InStr(Ret, "/") + 1;
	if ( i < 0 || i > 16 )
	{
		i = 0;
	}

	j = InStr(Ret, "?");
	if ( j < 0 )
	{
		j = Len(Ret);
	}

	if ( Mid(Ret, j - 3, 3) ~= "rom" )
	{
		j -= 4;
	}

	Ret = Mid(Ret, i, j - i);

	return Ret;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController Player;
	local bool bSetAchievement;
	local string MapName;

	EndTime = Level.TimeSeconds + EndTimeDelay;

	if ( WaveNum > FinalWave )
	{
		GameReplicationInfo.Winner = Teams[0];
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 2;

		if ( GameDifficulty >= 2.0 )
		{
			bSetAchievement = true;

			// Get the MapName out of the URL
			MapName = GetCurrentMapName(Level);
		}
	}
	else
	{
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 1;
	}

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) ) {
        KFGameReplicationInfo(GameReplicationInfo).EndGameType = 0;
        return false;
    }

	for ( P = Level.ControllerList; P != none; P = P.nextController )
	{
		Player = PlayerController(P);
		if ( Player != none )
		{
			Player.ClientSetBehindView(true);
			Player.ClientGameEnded();

			if ( bSetAchievement && KFSteamStatsAndAchievements(Player.SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(Player.SteamStatsAndAchievements).WonGame(MapName, GameDifficulty, KFGameLength == GL_Long);
			}
		}

		P.GameHasEnded();
	}

	if ( CurrentGameProfile != none )
	{
		CurrentGameProfile.bWonMatch = false;
	}

	return true;
}

function SendPlayer( PlayerController aPlayer, string URL )
{
	if( bGameEnded || aPlayer==None || aPlayer.PlayerReplicationInfo==None )
		Return;
	Broadcast(Self,aPlayer.PlayerReplicationInfo.PlayerName@"has ended the level.");
	if( Left(URL,4)~="NULL" )
	{
		WaveNum = FinalWave;
		EndGame(None,"TimeLimit");
		Return;
	}
	Level.ServerTravel(URL,False);
	bGameEnded = True;
}

static function string GetValidCharacter( string S )
{
	local int i,l;

	l = Default.AvailableChars.Length;
	if( S!="" )
	{
		for( i=0; i<l; i++ )
		{
			if( Default.AvailableChars[i]~=S )
				Return Default.AvailableChars[i];
		}
	}
	Return Default.AvailableChars[Rand(l)];
}

static function string GetLoadingHint( PlayerController PC, string MapName, Color ColorHint )
{
	local Material Shot;
	local UT2K4ServerLoading LO;
	local LevelSummary LS;
	local array<Material> TexToUse;
	local int i,j;
	local LoadingInfoImage CI;

	// Look for map screenshot.
	LS = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", Class'LevelSummary', True));
	if( LS!=None && LS.ScreenShot!=None )
		Shot = LS.ScreenShot;
	if( Shot==None ) // Try looking for mapname <screenshot>
		Shot = Material(DynamicLoadObject(MapName$".ScreenShot", Class'Material', True));
	if( Shot!=None )
	{
		if( MaterialSequence(Shot)!=None )
		{
			For( i=0; i<MaterialSequence(Shot).SequenceItems.Length; i++ )
			{
				TexToUse.Length = j+1;
				TexToUse[j] = MaterialSequence(Shot).SequenceItems[i].Material;
				j++;
			}
			Shot = TexToUse[Rand(j)];
		}
		if( Texture(Shot) != none )
			Texture(Shot).LODSet = LODSET_Interface;
		foreach PC.AllObjects(Class'UT2K4ServerLoading', LO)
		{
			CI = New(None)Class'LoadingInfoImage';
			LO.Operations[LO.Operations.Length] = CI;
			CI.Image = Shot;
			if( LS!=None )
			{
				CI.MapTitle = LS.Title;
				CI.MapAuthor = LS.Author;
			}
		}
	}
	Return Default.KFHints[Rand(Default.KFHints.Length)];
}

function WeaponPickedUp(KFRandomItemSpawn PickedUp)
{
	local int Random, i;

	if ( PickedUp == none )
	{
		return;
	}

    PickedUp.DisableMe();

    for ( i = 0; i < 10000; i++ )
    {
    	Random = Rand(WeaponPickups.Length);

    	if ( WeaponPickups[Random] != PickedUp && !WeaponPickups[Random].bIsEnabledNow )
    	{
    		WeaponPickups[Random].EnableMeDelayed(30.0 / float(GetNumPlayers()));
    		return;
    	}
    }

    PickedUp.EnableMeDelayed(30.0 / float(GetNumPlayers()));
}

function AmmoPickedUp(KFAmmoPickup PickedUp)
{
	local int Random, i;

    for ( i = 0; i < 10000; i++ )
    {
    	Random = Rand(AmmoPickups.Length);

    	if ( AmmoPickups[Random] != PickedUp && AmmoPickups[Random].bSleeping )
    	{
    		AmmoPickups[Random].GotoState('Sleeping', 'DelayedSpawn');
    		return;
    	}
    }

    PickedUp.GotoState('Sleeping', 'DelayedSpawn');
}

function WeaponSpawned(Inventory Weapon)
{
	local Controller C;

	if ( Weapon == none || class<Weapon>(Weapon.Class) == none )
	{
		return;
	}

	InstancedWeaponClasses[InstancedWeaponClasses.Length] = class<Weapon>(Weapon.Class);

    for ( C = Level.ControllerList; C != none; C = C.nextController )
    {
    	if ( KFPlayerController(C) != none )
    	{
    		KFPlayerController(C).ClientWeaponSpawned(class<Weapon>(Weapon.Class), Weapon);
    	}
    }
}

function WeaponDestroyed(class<Weapon> WeaponClass)
{
	local Controller C;
	local int i;

	for ( i = 0; i < InstancedWeaponClasses.Length; i++ )
	{
		if ( InstancedWeaponClasses[i] == WeaponClass )
		{
			InstancedWeaponClasses.Remove(i, 1);
			break;
		}
	}

    for ( C = Level.ControllerList; C != none; C = C.nextController )
    {
    	if ( KFPlayerController(C) != none )
    	{
			KFPlayerController(C).ClientWeaponDestroyed(WeaponClass);
		}
	}
}

defaultproperties
{
     SandboxGroup="Sandbox"
     ShortWaves(0)=(WaveMask=196611,WaveMaxMonsters=20,WaveDuration=255)
     ShortWaves(1)=(WaveMask=19662621,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.100000)
     ShortWaves(2)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     ShortWaves(3)=(WaveMask=73378265,WaveMaxMonsters=42,WaveDuration=255,WaveDifficulty=0.300000)
     NormalWaves(0)=(WaveMask=196611,WaveMaxMonsters=20,WaveDuration=255)
     NormalWaves(1)=(WaveMask=16974063,WaveMaxMonsters=28,WaveDuration=255,WaveDifficulty=0.100000)
     NormalWaves(2)=(WaveMask=19662621,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.100000)
     NormalWaves(3)=(WaveMask=37490365,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.200000)
     NormalWaves(4)=(WaveMask=39399101,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     NormalWaves(5)=(WaveMask=58665455,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
     NormalWaves(6)=(WaveMask=73386457,WaveMaxMonsters=42,WaveDuration=255,WaveDifficulty=0.300000)
     LongWaves(0)=(WaveMask=196611,WaveMaxMonsters=20,WaveDuration=255)
     LongWaves(1)=(WaveMask=16974063,WaveMaxMonsters=28,WaveDuration=255,WaveDifficulty=0.100000)
     LongWaves(2)=(WaveMask=19662621,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.100000)
     LongWaves(3)=(WaveMask=20713145,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.200000)
     LongWaves(4)=(WaveMask=37490365,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     LongWaves(5)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     LongWaves(6)=(WaveMask=56114877,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     LongWaves(7)=(WaveMask=58616303,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
     LongWaves(8)=(WaveMask=75393519,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
     LongWaves(9)=(WaveMask=90171865,WaveMaxMonsters=45,WaveDuration=255,WaveDifficulty=0.300000)
     MonsterCollection=Class'KFMod.KFMonstersCollection'
     HumanName(0)="Cpl.McinTyre"
     HumanName(1)="Sgt.Michaels"
     HumanName(2)="Pvt.Davin"
     HumanName(3)="Cpl.Powers"
     KFSurvivalPropText(0)="Wave Start Spawn Period"
     KFSurvivalPropText(1)="Wave Spawn Period"
     KFSurvivalPropText(2)="Starting Cash"
     KFSurvivalPropText(3)="No Bots"
     KFSurvivalPropText(4)="No Late Joiners"
     KFSurvivalPropText(5)="Lobby TimeOut"
     KFSurvivalPropText(6)="Specimen HealthBars"
     KFSurvivalPropText(7)="Wave Downtime"
     KFSurvivalPropText(8)="Number of Waves"
     KFSurvivalPropText(9)="Game Length"
     KFSurvivalPropText(10)="Max Specimens"
     KFSurvivalPropText(11)="Use EndGame Boss"
     KFSurvivalPropText(12)="Waves Config"
     KFSurvivalPropText(13)="Squads Config"
     KFSurvivalPropText(14)="Monsters Config"
     KFSurvivalPropText(15)="Min Respawn Cash Amount"
     KFSurvivalDescText(0)="Specify time between successive spawns at start of waves(recommended:6.0), lower values may hurt performance!"
     KFSurvivalDescText(1)="Specify time between successive spawns during a wave(recommended:3.0), lower values may hurt performance!"
     KFSurvivalDescText(2)="Specify how much money players should begin the game with. (Max 300)"
     KFSurvivalDescText(3)="Check this box to remove bots from the game."
     KFSurvivalDescText(4)="Check this box to stop people from joining after the game has started."
     KFSurvivalDescText(5)="Set the maximum time on the lobby screen which can elapse after one player has clicked ready before the game automatically starts. "
     KFSurvivalDescText(6)="If true, specimens will have visible health indicators above their heads"
     KFSurvivalDescText(7)="The based amount of time (in seconds) to count between waves."
     KFSurvivalDescText(8)="The number of waves per level."
     KFSurvivalDescText(9)="Sets number of waves: Short is 4 waves, Normal is 7, and long is 10.  Custom enables Sandbox mode, but turns off Perk progression."
     KFSurvivalDescText(10)="Maximum zombies at once on playtime, note that high values will LAG when theres a lot of them."
     KFSurvivalDescText(11)="Spawn the final boss on end of final wave."
     KFSurvivalDescText(12)="Configure the Killing Floor waves."
     KFSurvivalDescText(13)="Configure the monster squads to use on waves."
     KFSurvivalDescText(14)="Configure the monster classes to be used in the squads."
     KFSurvivalDescText(15)="Minimum amount of Cash when respawning on new wave."
     NoLateJoiners="This server does not allow late joiners."
     WaveStartSpawnPeriod=6.000000
     StartingCash=300
     MinRespawnCash=250
     bNoBots=True
     bUseEndGameBoss=True
     bRespawnOnBoss=True
     BossBattleSong="KF_Abandon"
     StartingCashBeginner=300
     StartingCashNormal=250
     StartingCashHard=250
     StartingCashSuicidal=200
     StartingCashHell=100
     MinRespawnCashBeginner=250
     MinRespawnCashNormal=200
     MinRespawnCashHard=200
     MinRespawnCashSuicidal=150
     MinRespawnCashHell=100
     TimeBetweenWavesBeginner=90
     TimeBetweenWavesNormal=60
     TimeBetweenWavesHard=60
     TimeBetweenWavesSuicidal=60
     TimeBetweenWavesHell=60
     StandardMonsterSquads(0)="4A"
     StandardMonsterSquads(1)="4A1G"
     StandardMonsterSquads(2)="2B"
     StandardMonsterSquads(3)="4B"
     StandardMonsterSquads(4)="3A1G"
     StandardMonsterSquads(5)="2D"
     StandardMonsterSquads(6)="3A1C"
     StandardMonsterSquads(7)="2A2C"
     StandardMonsterSquads(8)="2A3B1C"
     StandardMonsterSquads(9)="1A3C"
     StandardMonsterSquads(10)="3A1C1H"
     StandardMonsterSquads(11)="3A1B2D1G1H"
     StandardMonsterSquads(12)="3A1E"
     StandardMonsterSquads(13)="2A1E"
     StandardMonsterSquads(14)="2A3C1E"
     StandardMonsterSquads(15)="2B3D1G2H"
     StandardMonsterSquads(16)="4A1C"
     StandardMonsterSquads(17)="4A"
     StandardMonsterSquads(18)="4D"
     StandardMonsterSquads(19)="4C"
     StandardMonsterSquads(20)="6B"
     StandardMonsterSquads(21)="2B2C2D1H"
     StandardMonsterSquads(22)="2A2B2C2H"
     StandardMonsterSquads(23)="1F"
     StandardMonsterSquads(24)="1I"
     StandardMonsterSquads(25)="2A1C1I"
     StandardMonsterSquads(26)="2I"
     StandardMaxZombiesOnce=32
     KFHints(0)="Aiming for the head is a good idea. If you score a critical headshot, you can remove a Specimen's head, rendering them unable to use special abilities, and increasing any further damage they take."
     KFHints(1)="While you can use your medical syringe to heal your own wounds, it is far more effective when used on a team mate."
     KFHints(2)="The Fleshpound. Shooting him with small weapons just makes him mad. Think big, powerful weapons for this one!"
     KFHints(3)="Patriarch addendum: Did we forget to brief you? Yes, it seems he can cloak when he needs to heal. Luckily, only a couple of times in his short, angry life."
     KFHints(4)="The Patriarch. This is the Big One. Chain-gun. Rockets. And vicious up close, too!"
     KFHints(5)="The Scrake. Yes, that IS a chainsaw he's carrying...  nothing subtle about him!"
     KFHints(6)="The Crawler. Interesting attempt to merge human and arachnid genes. Sort-of worked, too - these little nasties have a habit of appearing in all sorts of strange places!"
     KFHints(7)="The Bloat. Not too hard to kill, but its bile is poisonous, so make sure you keep out of range!"
     KFHints(8)="Your movement speed is affected by your weight total. You can also run faster carrying a melee weapon than a gun."
     KFHints(9)="Bloats will explode in a shower of acidic goop when they die. Keep your distance when taking them down."
     KFHints(10)="The Stalker will be largely cloaked and very hard to see, until she is close enough to gut you. Listen carefully for her."
     KFHints(11)="The Trader will only open her shop for a brief time when the coast is clear. You'll have to find where she is situated in each map, and plan your shopping beforehand."
     KFHints(12)="The Gorefast - tends to live up to its name, so watch out for it speeding in towards you."
     KFHints(13)="The Clot is not that dangerous - but does have a nasty habit of grappling you and not letting you get away, so keep him at a distance."
     KFHints(14)="The Siren is a real screamer. Very nasty. Her screams actually hurt - and they'll destroy grenades and rockets in mid-air!"
     MonsterSquad(0)="4A"
     MonsterSquad(1)="4A1G"
     MonsterSquad(2)="2B"
     MonsterSquad(3)="4B"
     MonsterSquad(4)="3A1G"
     MonsterSquad(5)="2D"
     MonsterSquad(6)="3A1C"
     MonsterSquad(7)="2A2C"
     MonsterSquad(8)="2A3B1C"
     MonsterSquad(9)="1A3C"
     MonsterSquad(10)="3A1C1H"
     MonsterSquad(11)="3A1B2D1G1H"
     MonsterSquad(12)="3A1E"
     MonsterSquad(13)="2A1E"
     MonsterSquad(14)="2A3C1E"
     MonsterSquad(15)="2B3D1G2H"
     MonsterSquad(16)="4A1C"
     MonsterSquad(17)="4A"
     MonsterSquad(18)="4D"
     MonsterSquad(19)="4C"
     MonsterSquad(20)="6B"
     MonsterSquad(21)="2B2C2D1H"
     MonsterSquad(22)="2A2B2C2H"
     MonsterSquad(23)="1F"
     MonsterSquad(24)="1I"
     MonsterSquad(25)="2A1C1I"
     MonsterSquad(26)="2I"
     ControllerClassName="KFmod.KFDoorController"
     LobbyTimeout=20
     TimeBetweenWaves=60
     AvailableChars(0)="Corporal_Lewis"
     AvailableChars(1)="Lieutenant_Masterson"
     AvailableChars(2)="Police_Constable_Briar"
     AvailableChars(3)="Private_Schnieder"
     AvailableChars(4)="Sergeant_Powers"
     AvailableChars(5)="Police_Sergeant_Davin"
     AvailableChars(6)="Dr_Gary_Glover"
     AvailableChars(7)="DJ_Scully"
     AvailableChars(8)="FoundryWorker_Aldridge"
     AvailableChars(9)="Agent_Wilkes"
     AvailableChars(10)="Mr_Foster"
     AvailableChars(11)="LanceCorporal_Lee_Baron"
     AvailableChars(12)="Mike_Noble"
     AvailableChars(13)="Security_Officer_Thorne"
     AvailableChars(14)="Harold_Hunt"
     AvailableChars(15)="Kerry_Fitzpatrick"
     AvailableChars(16)="Paramedic_Alfred_Anderson"
     AvailableChars(17)="Trooper_Clive_Jenkins"
     AvailableChars(18)="Harchier_Spebbington"
     AvailableChars(19)="Captian_Wiggins"
     AvailableChars(20)="Chopper_Harris"
     AvailableChars(21)="Kevo_Chav"
     AvailableChars(22)="Reverend_Alberts"
     AvailableChars(23)="Baddest_Santa"
     AvailableChars(24)="Pyro_Blue"
     AvailableChars(25)="Pyro_Red"
     AvailableChars(26)="Steampunk_Berserker"
     AvailableChars(27)="Steampunk_Firebug"
     AvailableChars(28)="Steampunk_Medic"
     AvailableChars(29)="Steampunk_Sharpshooter"
     AvailableChars(30)="Steampunk_MrFoster"
     AvailableChars(31)="KF_Soviet"
     AvailableChars(32)="KF_German"
     AvailableChars(33)="Commando_Chicken"
     AvailableChars(34)="Steampunk_Commando"
     AvailableChars(35)="Steampunk_Demolition"
     AvailableChars(36)="Steampunk_DJ_Scully"
     AvailableChars(37)="Steampunk_Support_Specialist"
     AvailableChars(38)="Ash_Harding"
     AvailableChars(39)="Dave_The_Butcher_Roberts"
     AvailableChars(40)="Dr_Jeffrey_Tamm"
     AvailableChars(41)="Samuel_Avalon"
     AvailableChars(42)="Shadow_Ferret"
     AvailableChars(43)="Harold_Lott"
     AvailableChars(44)="ChickenNator"
     AvailableChars(45)="Reaper"
     AvailableChars(46)="DAR"
     LoadedSkills(0)=Class'KFMod.KFVetFieldMedic'
     LoadedSkills(1)=Class'KFMod.KFVetSupportSpec'
     LoadedSkills(2)=Class'KFMod.KFVetSharpshooter'
     LoadedSkills(3)=Class'KFMod.KFVetCommando'
     LoadedSkills(4)=Class'KFMod.KFVetBerserker'
     LoadedSkills(5)=Class'KFMod.KFVetFirebug'
     LoadedSkills(6)=Class'KFMod.KFVetDemolitions'
     MaxZombiesOnce=32
     ZEDTimeDuration=3.000000
     ZedTimeSlomoScale=0.200000
     LastBurnedEnemyMessageTime=-120.000000
     BurnedEnemyMessageDelay=120.000000
     SineWaveFreq=0.040000
     MonsterClasses(0)=(MClassName="KFChar.ZombieClot",Mid="A")
     MonsterClasses(1)=(MClassName="KFChar.ZombieCrawler",Mid="B")
     MonsterClasses(2)=(MClassName="KFChar.ZombieGoreFast",Mid="C")
     MonsterClasses(3)=(MClassName="KFChar.ZombieStalker",Mid="D")
     MonsterClasses(4)=(MClassName="KFChar.ZombieScrake",Mid="E")
     MonsterClasses(5)=(MClassName="KFChar.ZombieFleshpound",Mid="F")
     MonsterClasses(6)=(MClassName="KFChar.ZombieBloat",Mid="G")
     MonsterClasses(7)=(MClassName="KFChar.ZombieSiren",Mid="H")
     MonsterClasses(8)=(MClassName="KFChar.ZombieHusk",Mid="I")
     EndGameBossClass="KFChar.ZombieBoss"
     WaveConfigMenu="KFGUI.KFWaveConfigMenu"
     FallbackMonsterClass="KFChar.ZombieStalker"
     FinalWave=10
     InvasionBotNames(1)="Zombie"
     InvasionBotNames(2)="Zombie"
     InvasionBotNames(3)="Zombie"
     InvasionBotNames(4)="Zombie"
     InvasionBotNames(5)="Zombie"
     InvasionBotNames(6)="Zombie"
     InvasionBotNames(7)="Zombie"
     InvasionBotNames(8)="Zombie"
     InvasionEnd(0)="Sound"
     InvasionEnd(1)="Sound"
     InvasionEnd(2)="Sound"
     InvasionEnd(3)="Sound"
     InvasionEnd(4)="Sound"
     InvasionEnd(5)="Sound"
     Waves(0)=(WaveMask=196611,WaveMaxMonsters=20,WaveDuration=255)
     Waves(1)=(WaveMask=16974063,WaveMaxMonsters=28,WaveDuration=255,WaveDifficulty=0.100000)
     Waves(2)=(WaveMask=19662621,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.100000)
     Waves(3)=(WaveMask=20713145,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.200000)
     Waves(4)=(WaveMask=20713149,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     Waves(5)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     Waves(6)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
     Waves(7)=(WaveMask=41839087,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
     Waves(8)=(WaveMask=41839087,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
     Waves(9)=(WaveMask=39840217,WaveMaxMonsters=45,WaveDuration=255,WaveDifficulty=0.300000)
     Waves(10)=(WaveMask=65026687,WaveMaxMonsters=50)
     Waves(11)=(WaveMask=63750079,WaveMaxMonsters=50)
     Waves(12)=(WaveMask=64810679,WaveMaxMonsters=50)
     Waves(13)=(WaveMask=62578607,WaveMaxMonsters=60)
     Waves(14)=(WaveMask=100663295,WaveMaxMonsters=50)
     Waves(15)=(WaveMask=125892608,WaveMaxMonsters=15)
     bAllowNonTeamChat=True
     MaxTeamSize=6
     TeamAIType(0)=Class'KFMod.KFTeamAI'
     TeamAIType(1)=Class'KFMod.KFTeamAI'
     bForceRespawn=True
     NumRounds=10
     SpawnProtectionTime=0.000000
     EndGameSoundName(0)="Sound"
     EndGameSoundName(1)="Sound"
     AltEndGameSoundName(0)="Sound"
     AltEndGameSoundName(1)="Sound"
     EpicNames(0)="Lt.Barker"
     EpicNames(1)="Pvt.Davin"
     EpicNames(2)="Cpl.Power"
     EpicNames(3)="Pvt.Barns"
     EpicNames(4)="Cpl.Hicks"
     EpicNames(5)="Sgt.Apone"
     EpicNames(6)="Pvt.Hudson"
     EpicNames(7)="Maj.Brale"
     EpicNames(8)="Lt.Derricks"
     EpicNames(9)="Pvt.Quick"
     EpicNames(10)="Sgt.Masterson"
     EpicNames(11)="Lt.Barker"
     EpicNames(12)="Pvt.Davin"
     EpicNames(13)="Cpl.Power"
     EpicNames(14)="Pvt.Barns"
     EpicNames(15)="Cpl.Hicks"
     EpicNames(16)="Sgt.Apone"
     EpicNames(17)="Pvt.Hudson"
     EpicNames(18)="Maj.Brale"
     EpicNames(19)="Lt.Derricks"
     EpicNames(20)="Pvt.Quick"
     MaleBackupNames(0)="Lt.Barker"
     MaleBackupNames(1)="Pvt.Davin"
     MaleBackupNames(2)="Cpl.Power"
     MaleBackupNames(3)="Pvt.Barns"
     MaleBackupNames(4)="Cpl.Hicks"
     MaleBackupNames(5)="Sgt.Apone"
     MaleBackupNames(6)="Pvt.Hudson"
     MaleBackupNames(7)="Maj.Brale"
     MaleBackupNames(8)="Lt.Derricks"
     MaleBackupNames(9)="Pvt.Quick"
     MaleBackupNames(10)="Sgt.Masterson"
     MaleBackupNames(11)="Lt.Barker"
     MaleBackupNames(12)="Pvt.Davin"
     MaleBackupNames(13)="Cpl.Power"
     MaleBackupNames(14)="Pvt.Barns"
     MaleBackupNames(15)="Cpl.Hicks"
     MaleBackupNames(16)="Sgt.Apone"
     MaleBackupNames(17)="Pvt.Hudson"
     MaleBackupNames(18)="Maj.Brale"
     MaleBackupNames(19)="Lt.Derricks"
     MaleBackupNames(20)="Pvt.Quick"
     MaleBackupNames(21)="Pvt.Davin"
     MaleBackupNames(22)="Cpl.Power"
     MaleBackupNames(23)="Pvt.Barns"
     MaleBackupNames(24)="Cpl.Hicks"
     MaleBackupNames(25)="Sgt.Apone"
     MaleBackupNames(26)="Pvt.Hudson"
     MaleBackupNames(27)="Maj.Brale"
     MaleBackupNames(28)="Lt.Derricks"
     MaleBackupNames(29)="Pvt.Quick"
     MaleBackupNames(30)="Sgt.Masterson"
     MaleBackupNames(31)="Lt.Barker"
     FemaleBackupNames(0)="Lt.Vasquez"
     FemaleBackupNames(1)="Pvt.Kara"
     FemaleBackupNames(2)="Sgt.Swanson"
     FemaleBackupNames(3)="Maj.Simons"
     FemaleBackupNames(4)="Pvt.Martinez"
     FemaleBackupNames(5)="Cpl.Sharpe"
     FemaleBackupNames(6)="Pvt.Faulkner"
     FemaleBackupNames(7)="Lt.Vasquez"
     FemaleBackupNames(8)="Pvt.Kara"
     FemaleBackupNames(9)="Sgt.Swanson"
     FemaleBackupNames(10)="Maj.Simons"
     FemaleBackupNames(11)="Pvt.Martinez"
     FemaleBackupNames(12)="Cpl.Sharpe"
     FemaleBackupNames(13)="Pvt.Faulkner"
     FemaleBackupNames(14)="Lt.Vasquez"
     FemaleBackupNames(15)="Pvt.Kara"
     FemaleBackupNames(16)="Sgt.Swanson"
     FemaleBackupNames(17)="Maj.Simons"
     FemaleBackupNames(18)="Pvt.Martinez"
     FemaleBackupNames(19)="Cpl.Sharpe"
     FemaleBackupNames(20)="Pvt.Faulkner"
     FemaleBackupNames(21)="Lt.Vasquez"
     FemaleBackupNames(22)="Pvt.Kara"
     FemaleBackupNames(23)="Sgt.Swanson"
     FemaleBackupNames(24)="Maj.Simons"
     FemaleBackupNames(25)="Pvt.Martinez"
     FemaleBackupNames(26)="Cpl.Sharpe"
     FemaleBackupNames(27)="Pvt.Faulkner"
     FemaleBackupNames(28)="Pvt.Kara"
     FemaleBackupNames(29)="Sgt.Swanson"
     FemaleBackupNames(30)="Maj.Simons"
     FemaleBackupNames(31)="Pvt.Martinez"
     LoginMenuClass="KFGUI.KFInvasionLoginMenu"
     DefaultVoiceChannel="Team"
     bAllowVehicles=True
     bAllowMPGameSpeed=True
     DefaultPlayerClassName="KFmod.KFHumanPawn"
     ScoreBoardType="KFMod.KFScoreBoardNew"
     HUDType="KFmod.HUDKillingFloor"
     MapListType="KFMod.KFMapList"
     MapPrefix="KF"
     BeaconName="KF"
     ResetTimeDelay=10
     DefaultPlayerName="Fresh Meat"
     TimeLimit=0
     DeathMessageClass=Class'KFMod.KFDeathMessage'
     GameMessageClass=Class'KFMod.KFGameMessages'
     MutatorClass="KFmod.KillingFloorMut"
     PlayerControllerClass=Class'KFMod.KFPlayerController'
     PlayerControllerClassName="KFmod.KFPlayerController"
     GameReplicationInfoClass=Class'KFMod.KFGameReplicationInfo'
     GameName="Killing Floor"
     Description="The premise is simple: you (and, hopefully, your team) have been flown in to 'cleanse' this area of specimens. The only things moving are specimens. They will launch at you in waves. Kill them. All of them. Any and every way you can. We'll even pay you a bounty for it! Between waves, you should be able to find the merc Trader lurking in some safe spot. She'll trade your bounty for ammo, equipment and Bigger Guns. Trust me - you're going to need them! If you can survive all the waves, you'll have to top the so-called Patriarch to finish the job. Don't worry about finding him - HE will come looking for YOU!"
     ScreenShotName="KillingFloorHUD.KFLogoFB"
     Acronym="KF"
     GIPropsDisplayText(0)="Difficulty"
     GIPropDescText(0)="Change the game difficulty. Anything above Normal will cause increased zombie speed, damage and health among other things..."
     GIPropsExtras(0)="1.000000;Beginner;2.000000;Normal;4.000000;Hard;5.000000;Suicidal;7.000000;Hell on Earth"
     GIPropsExtras(1)="0;Short;1;Medium;2;Long;3;Custom"
     TcpLinkClass=Class'KFMod.KFBufferedTCPLink'
}
