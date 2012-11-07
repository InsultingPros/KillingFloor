// Single player Killing Floor Gametype
class KFSPGameType extends KFGameType;

// Config
var()	 config	int						 RoundLimit;				 // number of pair of rounds
var						 int						 MaxRounds;					// converted to actual number of rounds played
var()	 config	int						 RoundTimeLimit;		 // max round duration (in minutes)
var()	 config	int						 PracticeTimeLimit;	// practice duration (in seconds)

var		 config	int						 ReinforcementsFreq;				 // Reinforcement frequency (seconds, 0 = no reinforcements)
var						 int						 ReinforcementsValidTime;		// delay while players are allowed to join last reinforcement
var						 int						 ReinforcementsCount;

var int SuccessfulAssaultTimeLimit;		 // if first attacking team sucessfully attacked, defenders will have to beat that time to win.

const ASPROPNUM = 5;
var localized string		ASPropsDisplayText[ASPROPNUM];
var localized string		ASPropDescText[ASPROPNUM];

var(LoadingHints) private localized array<string> ASHints;

// internal
var		 byte				CurrentAttackingTeam;	 // Current Attacking team index
var		 byte				FirstAttackingTeam;
var		 byte				CurrentRound;
var		 int				 RoundStartTime;
var		 bool				bDisableReinforcements;

var name		AttackerWinRound[2];
var name		DefenderWinRound[2];
var name		DrawGameSound;

var GameObjective	 CurrentObjective, LastDisabledObjective;
var vehicle KeyVehicle;

var Array<PlayerSpawnManager>	 SpawnManagers;					// Handling player spawning

var SceneManager								CurrentMatineeScene;		// SP matinee intro cinematic
var KFSceneManager		EndCinematic;					 // MP outro cinematic

var bool		bWeakObjectives;		// cheat


// Story Mode Specific Variables

var KFSPLevelInfo SPInfo;	// The reigning Level Info

var bool bDefKFEquips; // Sets whether pawns spawn with regular gear or not.	(KFSP)
var int PlayerStartingHealth;	// The starting amount of Hitpoints for all players.
var int PlayerStartingArmor;

var bool bPlayedIntro;

var KFTeamProgressVolume SpawnVolume;

function LoadUpMonsterList();

event PostNetBeginPlay()
{
	local KFSPLevelInfo LI;

	foreach AllActors(class'KFSPLevelInfo',LI)
	{
		if (LI != none)
			SPInfo = LI;
	}

	if(SPInfo != none)
		KFGameReplicationInfo(GameReplicationInfo).bHUDShowCash = SPInfo.bHUDShowCash;
}

function OverrideInitialBots()
{
	InitialBots = 0;
}

function bool TooManyBots(Controller botToRemove)
{
	 return true;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	if (SPInfo != none)
		if ( KFHumanPawn(PlayerPawn) != None )
			KFHumanPawn(PlayerPawn).AddDefaultInventory();

	SetPlayerDefaults(PlayerPawn);
}

function RestartPlayer( Controller aPlayer )
{
	Super(gameinfo).RestartPlayer(aPlayer);
	if( aPlayer.Pawn!=None && SPInfo!=none )
		SPInfo.ModifyPlayer(aPlayer.Pawn);
}
function AddGameSpecificInventory(Pawn p)
{
	if( SPInfo!=none )
		SPInfo.AddGameInv(p);
}

function ForceAddBot();

function InitPlacedBot(Controller C, RosterEntry R){}

function InitializeBot(Bot NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen);

function bool AddBot(optional string botName)
{
	return false;
}

exec function AddBots(int num);

function Bot SpawnBot(optional string botName)
{
	Return None;
}

event PlayerController Login( string Portal, string Options, out string Error )
{
	local PlayerController NewPlayer;
	local Controller C;
	local bool bTempLate;

	bTempLate = bNoLateJoiners;
	bNoLateJoiners = False;
	NewPlayer = Super.Login(Portal,Options,Error);
	bNoLateJoiners = bTempLate;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (C.PlayerReplicationInfo != None) && C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator && !GameReplicationInfo.bMatchHasBegun )
		{
			NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
			NewPlayer.PlayerReplicationInfo.NumLives = 1;
			Break;
		}

	NewPlayer.SetGRI(GameReplicationInfo);

	if ( bDelayedStart ) //!
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;
	}
	return NewPlayer;

}

event KFSceneEnded( KFSceneManager SM, Actor Other )
{
	GotoState('MatchInProgress');
}

/* cinematic started... */
event KFSceneStarted( KFSceneManager SM, Actor Other )
{
	if ( Other != None && Other.IsA('KFSceneManager') )
		GotoState('MPOutroCinematic');
}

/* network friendly outro */
state MPOutroCinematic
{
}

function bool IsPlayingIntro()
{
	return false;
}

State MatchInProgress
{
	function beginstate()
	{
		if (!bPlayedIntro)
		{
			TriggerEvent('IntroScene', Self, None);		 // try to play Matinee intro
			bPlayedIntro = true;
		}
	}
}

function GetServerInfo( out ServerResponseLine ServerState )
{
	Super.GetServerInfo(ServerState);
	ServerState.GameType = string('KFGameType');
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local float Dec;

	if( SpawnVolume==None )
		Return Super.RatePlayerStart(N,Team,Player);
	if( N.PhysicsVolume!=SpawnVolume || PlayerStart(N)==None )
		Return -100000;
	PlayerStart(N).bEnabled = True;
	Dec = Super.RatePlayerStart(N,Team,Player);
	PlayerStart(N).bEnabled = False;
	Return FMax(0,Dec);
}

defaultproperties
{
     ScoreBoardType="KFMod.KFSPObjectiveBoardNew"
     HUDType="KFmod.HUDKillingFloorSP"
     MapListType="KFMod.KFMapListSP"
     MapPrefix="KFS"
     BeaconName="KFS"
     GameReplicationInfoClass=Class'KFMod.KFSGameReplicationInfo'
     GameName="Story"
     Description="Story Based Cooperative Gameplay."
     Acronym="KFS"
}
