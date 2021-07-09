//=============================================================================
// ROTeamGame
//=============================================================================
// Game rules for Red Orchestra
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROTeamGame extends TeamGame;

//#exec OBJ LOAD FILE=..\StaticMeshes\WeaponPickupSM.usx
//#exec OBJ LOAD FILE=..\StaticMeshes\EffectsSM.usx
//#exec OBJ LOAD FILE=..\textures\ScopeShaders.utx
//#exec OBJ LOAD FILE=..\Textures\Effects_Tex.utx

//=============================================================================
// Variables
//=============================================================================

// New rules for the server
var()	config	int					WinLimit;				  // If set to anything other than 0, the game will end when either team wins this many rounds. (default = 0)
var()	config	int					RoundLimit;				  // If set to anything other than 0, the game will end after this many rounds have been played. (default = 0)
var()	config	int					PreStartTime;			  // Sets the time before gameplay starts for players to join. (default = 20)
var()	config	int					FFDamageLimit;			  // Maximum amount of damage allowed to friendlies
var()	config	int					FFKillLimit;			  // Maximum number of friendly kills tolerated
var()	config	float				FFArtyScale;			  // Amount to scale FF kill limit when the damage is artillery damage
var()	config	float				FFExplosivesScale;		  // Amount to scale FF kill limit when the damage is explosive damage
var()   config  int                 MaxTeamDifference;        // Maximum allowable difference in players between two teams when using team balancing
var()   config  int                 MaxPlayersOverride;       // Overrides the Server's Max Players setting if set to a lower non-zero amount
var()   config  bool                bForgiveFFKillsEnabled;   // Toggles on/off the Forgive Friendly Fire Kills system
var()   config  bool                bShowServerIPOnScoreboard;// Toggles on/off displaying the IP of the current server on the scoreboard
var()   config  bool                bShowTimeOnScoreboard;    // Toggles on/off displaying the current time on the scoreboard

// Spectating
var()	config	bool				bSpectateFirstPersonOnly;
var()	config	bool				bSpectateLockedBehindView;
var()	config	bool				bSpectateAllowViewPoints;
var()	config	bool				bSpectateAllowRoaming;
var()	config	bool				bSpectateAllowDeadRoaming;
var()	config	bool				bSpectateBlackoutWhenDead;
var()	config	bool				bSpectateBlackoutWhenNotViewingPlayers;
var()   config	bool	            bAutoBalanceTeamsOnDeath; // Forces lowest scoring players to switch teams on death if teams are unbalanced
var		array<SpectatorCam> 		ViewPoints;					// An array of viewpoints to spectate


var(LoadingHints) private localized array<string> ROHints;

enum EFFPunishment
{
	FFP_None,			// Disables any punishment
	FFP_Kick,			// Kicks the player
	FFP_SessionBan,		// Adds a session ban for the player
	FFP_GlobalBan,		// Adds a global ban for the player
};

var()	config	EFFPunishment		FFPunishment;				// What to do to the TKers

enum EDeathMessageMode
{
	DM_None,			// No death messages
	DM_OnDeath,			// Show only who killed you personally
	DM_Personal,		// Show messages for people you killed and are killed by
	DM_All,				// Show all death messages
};

var()	config	EDeathMessageMode	DeathMessageMode;			// Used to set what death messages are displayed

// Round system
var		float						RoundStartTime;				// Time this round started
var		int							RoundDuration;				// Length of a round in seconds
var		int							RoundCount;					// Number of rounds completed so far
var		float						LastReinforcementTime[2];	// Time when reinforcements last arrived
var		int							SpawnCount[2];				// Spawn counters for both sides

// Spawn Areas
var		array<ROSpawnArea>			SpawnAreas;
var		ROSpawnArea					CurrentSpawnArea[2];		// Stores the current spawn areas being used
var		array<ROSpawnArea>			TankCrewSpawnAreas;
var		ROSpawnArea					CurrentTankCrewSpawnArea[2];// Stores the current tank crew spawn areas being used

var		MasterObjectiveManager      ObjectiveManager;

// Ammo resupply
var		ROAmmoResupplyVolume		ResupplyAreas[10];  		// Ammo resupply area

// Mine areas
var		array<ROMineVolume>			MineVolumes;                // Mine areas
// General
var		ROLevelInfo					LevelInfo;					// Stores the ROLevelInfo so we can access its properties
var		ROObjective					Objectives[16];				// Stores all objectives
var		RORoleInfo					AxisRoles[10];				// Stores the roles
var		RORoleInfo					AlliesRoles[10];

var		int							AxisRoleIndex, AlliesRoleIndex;

const ROPROPNUM = 42;
var	private	localized	string		PropsDisplayText[ROPROPNUM];
var private	localized 	string 		PropDescText[ROPROPNUM];
var	private	localized	string		PropsExtras[3];

var		vector					    AlternateSpawns[9];  // An array of vectors arranged in a circle around a position. Used for spawn locations in case the original spawn location fails.
var string SomeSavedString;

var string RussianNames[16]; 		// Array of names for russian bots
var string GermanNames[16];         // Array of names for german bots

var int RussianNameOffset, GermanNameOffset;

// Net debugging
var   bool	                         bAllowNetDebug;           // Server allows the use of net debugging info

//Uncomment the 2 variables below when using AddPlayers/RemovePlayers
//var ROPlayer PlayerList[128];
//var int      PlayerCount[2];
//var bool     bLogInfo;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// Empty
//-----------------------------------------------------------------------------

static function bool NeverAllowTransloc() { return true; }
function bool AllowTransloc() { return false; }
function AddGameSpecificInventory(Pawn p) {}
function CheckScore(PlayerReplicationInfo Scorer) {}
function NotifySpree(Controller Other, int num) {}
function EndSpree(Controller Killer, Controller Other) {}
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason) { return false; }
function bool ShouldRespawn(Pickup Other) { return false; }
function InitTeamSymbols() {}
static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds) {}
function PlayEndOfMatchMessage() {}
function bool CheckMaxLives(PlayerReplicationInfo Scorer) { return false; }
function Reset() {}

// This sucks.  Let's not use UT2004 bullshit - Erik
// Ok, feel free to implement something else Erik - Jay
// overload so that only RO specific hints get loaded
static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	for ( i = 0; i < default.ROHints.Length; i++ )
		Hints[Hints.Length] = default.ROHints[i];

	return Hints;
}

// Copied from Onslaught
function bool ApplyOrder( PlayerController Sender, int RecipientID, int OrderID )
{
	local controller P;

	if ( OrderID == 299 )
	{
/*		for ( P=Level.ControllerList; P!= None; P=P.NextController )
		{
			if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
				&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
			{
				Bot(P).GetOutOfVehicle();
				if ( RecipientID == P.PlayerReplicationInfo.TeamID )
					break;
			}
		}*/

	for ( P=Level.ControllerList; P!= None; P=P.NextController )
		{
			if ( (Bot(P) != None) /*&& (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
				&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID))*/ )
			{
				Bot(P).GetOutOfVehicle();
				//if ( RecipientID == P.PlayerReplicationInfo.TeamID )
				//	break;
			}
		}
		return true;
	}

	return Super.ApplyOrder(Sender,RecipientID,OrderID);
}

function int ParseOrder(string OrderString)
{
	switch ( OrderString )
	{
		case "DEFEND":
		case "TAKE ALPHA":
			return 1;
		case "ATTACK":
		case "TAKE BRAVO":
			return 0;
		case "COVER":
			return 3;
		case "HOLD":
			return 2;
		case "FREELANCE":
			return 4;
		case "GIMME":
			return 256;
		case "JUMP":
			return 257;
		case "STATUS":
			return 258;
		case "TAUNT":
			return 259;
		case "SUICIDE":
			return 260;
		case "GET OUT":
			return 299;
	}
}

//-----------------------------------------------------------------------------
// PostBeginPlay - Find the level info and objectives
//-----------------------------------------------------------------------------

function PostBeginPlay()
{
	local ROLevelInfo LI;
	local ROGameReplicationInfo ROGRI;
    local ROMapBoundsNE NE;
    local ROMapBoundsSW SW;
    local ROArtilleryTrigger RAT;
    local ROAmmoResupplyVolume ARV;
    local ROMineVolume MV;
    local int i, j, k, m, n, o;
    local SpectatorCam ViewPoint;
    local float MaxPlayerRatio;

	Super.PostBeginPlay();

	if ( MaxIdleTime > 0 )
		Level.bKickLiveIdlers = true;
	else
		Level.bKickLiveIdlers = false;

	// Find the ROLevelInfo
	foreach AllActors(class'ROLevelInfo', LI)
	{
		if (LevelInfo == None)
		{
			LevelInfo = LI;
		}
		else
		{
			log("ROTeamGame: More than one ROLevelInfo detected!");
			break;
		}
	}

	if (LevelInfo == None)
	{
		log("ROTeamGame: No ROLevelInfo detected!");
	}
	else
	{
		// Spectator Viewpoints
		for (n = 0; n < LevelInfo.EntryCamTags.Length; n++)
		{
			foreach AllActors(class'SpectatorCam', ViewPoint, LevelInfo.EntryCamTags[n])
			{
				ViewPoints[ViewPoints.Length] = ViewPoint;
				//log("Added Viewpoint "$ViewPoint.Tag);
			}
		}

		RoundDuration = LevelInfo.RoundDuration * 60;

		// Setup some GRI stuff
		ROGRI = ROGameReplicationInfo(GameReplicationInfo);

		if (ROGRI == None)
			return;

		ROGRI.bAllowNetDebug = bAllowNetDebug;
		ROGRI.PreStartTime = PreStartTime;
		ROGRI.RoundDuration = RoundDuration;
		ROGRI.bReinforcementsComing[AXIS_TEAM_INDEX] = 0;
		ROGRI.bReinforcementsComing[ALLIES_TEAM_INDEX] = 0;
		ROGRI.ReinforcementInterval[AXIS_TEAM_INDEX] = LevelInfo.Axis.ReinforcementInterval;
		ROGRI.ReinforcementInterval[ALLIES_TEAM_INDEX] = LevelInfo.Allies.ReinforcementInterval;
		ROGRI.UnitName[AXIS_TEAM_INDEX] = LevelInfo.Axis.UnitName;
		ROGRI.UnitName[ALLIES_TEAM_INDEX] = LevelInfo.Allies.UnitName;
		ROGRI.NationIndex[AXIS_TEAM_INDEX] = LevelInfo.Axis.Nation;
		ROGRI.NationIndex[ALLIES_TEAM_INDEX] = LevelInfo.Allies.Nation;
		ROGRI.UnitInsignia[AXIS_TEAM_INDEX] = LevelInfo.Axis.UnitInsignia;
		ROGRI.UnitInsignia[ALLIES_TEAM_INDEX] = LevelInfo.Allies.UnitInsignia;
		ROGRI.MapImage = LevelInfo.MapImage;
        ROGRI.bPlayerMustReady = bPlayersMustBeReady;
        ROGRI.RoundLimit = RoundLimit;
	    ROGRI.MaxPlayers = MaxPlayers;
	    ROGRI.bShowServerIPOnScoreboard = bShowServerIPOnScoreboard;
	    ROGRI.bShowTimeOnScoreboard = bShowTimeOnScoreboard;

        // Artillery
		ROGRI.ArtilleryStrikeLimit[AXIS_TEAM_INDEX] = LevelInfo.Axis.ArtilleryStrikeLimit;
		ROGRI.ArtilleryStrikeLimit[ALLIES_TEAM_INDEX] = LevelInfo.Allies.ArtilleryStrikeLimit;
		ROGRI.bArtilleryAvailable[AXIS_TEAM_INDEX] = 0;
		ROGRI.bArtilleryAvailable[ALLIES_TEAM_INDEX] = 0;
		ROGRI.LastArtyStrikeTime[AXIS_TEAM_INDEX] = LevelInfo.GetStrikeInterval(AXIS_TEAM_INDEX);
		ROGRI.LastArtyStrikeTime[ALLIES_TEAM_INDEX] = LevelInfo.GetStrikeInterval(ALLIES_TEAM_INDEX);
		ROGRI.TotalStrikes[AXIS_TEAM_INDEX] = 0;
		ROGRI.TotalStrikes[ALLIES_TEAM_INDEX] = 0;

		for (k = 0; k < ArrayCount(ROGRI.AxisRallyPoints); k++)
		{
			ROGRI.AlliedRallyPoints[k].OfficerPRI = none;
			ROGRI.AlliedRallyPoints[k].RallyPointLocation = vect(0,0,0);
			ROGRI.AxisRallyPoints[k].OfficerPRI = none;
			ROGRI.AxisRallyPoints[k].RallyPointLocation = vect(0,0,0);
		}

		// Clear help requests array
		for (k = 0; k < ArrayCount(ROGRI.AlliedHelpRequests); k++)
		{
			ROGRI.AlliedHelpRequests[k].OfficerPRI = none;
			ROGRI.AlliedHelpRequests[k].requestType = 255;
			ROGRI.AxisHelpRequests[k].OfficerPRI = none;
			ROGRI.AxisHelpRequests[k].requestType = 255;
		}

		if( LevelInfo.OverheadOffset == OFFSET_90 )
		{
		    ROGRI.OverheadOffset = 90;
        }
        else if( LevelInfo.OverheadOffset == OFFSET_180 )
        {
            ROGRI.OverheadOffset = 180;
        }
        else if( LevelInfo.OverheadOffset == OFFSET_270 )
        {
            ROGRI.OverheadOffset = 270;
        }
        else
        {
            ROGRI.OverheadOffset = 0;
        }

	    // Find the location of the map bounds
        foreach AllActors(class'ROMapBoundsNE', NE)
        {
             //NorthEastCorner = NE;
             ROGRI.NorthEastBounds = NE.Location;
            // log( "Found Northeastcorner");
        }
        foreach AllActors(class'ROMapBoundsSW', SW)
        {
             //SouthWestCorner = SW;
             ROGRI.SouthWestBounds = SW.Location;
            // log( "Found SouthWestcorner");
        }

        // Find all the radios
        foreach AllActors(class'ROArtilleryTrigger', RAT)
        {
                if ( RAT.TeamCanUse == AT_Axis || RAT.TeamCanUse == AT_Both)
                {
                   ROGRI.AxisRadios[i] = RAT;
                   i++;
                }

        }

        foreach AllActors(class'ROArtilleryTrigger', RAT)
        {
                if ( RAT.TeamCanUse == AT_Allies || RAT.TeamCanUse == AT_Both)
                {
                   ROGRI.AlliedRadios[j] = RAT;
                   j++;
                }

        }

        foreach AllActors(class'ROAmmoResupplyVolume', ARV)
        {
			ResupplyAreas[m] = ARV;
			ROGRI.ResupplyAreas[m].ResupplyVolumeLocation = ARV.Location;
			ROGRI.ResupplyAreas[m].Team = ARV.Team;
			ROGRI.ResupplyAreas[m].bActive = !ARV.bUsesSpawnAreas;
			if( ARV.ResupplyType == RT_Players )
			{
			  	ROGRI.ResupplyAreas[m].ResupplyType = 0;
			}
			else if ( ARV.ResupplyType == RT_Vehicles )
			{
			  	ROGRI.ResupplyAreas[m].ResupplyType = 1;
			}
			else if ( ARV.ResupplyType == RT_All )
			{
			  	ROGRI.ResupplyAreas[m].ResupplyType = 2;
			}
			m++;
        }

        foreach AllActors(class'ROMineVolume', MV)
        {
			MineVolumes[o] = MV;
			//MineVolumes[o].bActive = !MV.bUsesSpawnAreas
			o++;
        }

        //Scale the Reinforcement limits based on the server's capacity
        if ( MaxPlayersOverride != 0 && MaxPlayersOverride < MaxPlayers)
            MaxPlayerRatio = MaxPlayersOverride / 32.0f;
        else
        {
            MaxPlayersOverride = 0;
            MaxPlayerRatio = MaxPlayers / 32.0f;
        }
        LevelInfo.Allies.SpawnLimit *= MaxPlayerRatio;
        LevelInfo.Axis.SpawnLimit *= MaxPlayerRatio;

        log("MaxPlayerRatio = "$MaxPlayerRatio);

        //Make sure MaxTeamDifference is an acceptable value
        if ( MaxTeamDifference < 1 )
            MaxTeamDifference = 1;
	}
}

// Set the team AI for this team's objective to a new specified objective
function SetTeamAIObjectives(int NewObjectiveNum, int TeamNum)
{
	//ROTeamAI(TeamGame(Level.Game).Teams[PlayerReplicationInfo.Team.TeamIndex].AI).MakeBotDoIt(objectivenum);

	ROTeamAI(Teams[TeamNum].AI).SetAllSquadObjectivesTo(NewObjectiveNum);
}

// Set the AI for a specific squad to the specified new objective (squad is referenced by its squad leader)
function SetSquadObjectives(int NewObjectiveNum, int TeamNum, PlayerReplicationInfo SquadLeader)
{
    ROTeamAI(Teams[TeamNum].AI).SetSquadObjectivesTo(NewObjectiveNum, SquadLeader);
}

//-----------------------------------------------------------------------------
// Sets the NorthEast map bound to a new location
//-----------------------------------------------------------------------------
function SetNEBound(vector NewLocation)
{
    local ROMapBoundsNE NE;

	    // Find the location of the map bounds
    foreach AllActors(class'ROMapBoundsNE', NE)
    {
         //NorthEastCorner = NE;
         NE.SetLocation(NewLocation);
         ROGameReplicationInfo(GameReplicationInfo).NorthEastBounds = NewLocation;
         log( "Changed Northeastcorner to: "$ROGameReplicationInfo(GameReplicationInfo).NorthEastBounds);
    }
}

//-----------------------------------------------------------------------------
// Sets the southwest map bound to a new location
//-----------------------------------------------------------------------------
function SetSWBound(vector NewLocation)
{
    local ROMapBoundsSW SW;

    foreach AllActors(class'ROMapBoundsSW', SW)
    {
         //SouthWestCorner = SW;
         SW.SetLocation(NewLocation);
         ROGameReplicationInfo(GameReplicationInfo).SouthWestBounds = NewLocation;
         log( "Changed SouthWestcorner to: "$ROGameReplicationInfo(GameReplicationInfo).SouthWestBounds);
    }

}

//-----------------------------------------------------------------------------
// AddRole - Called by the roles so they can add themselves to the game
//-----------------------------------------------------------------------------

function AddRole(RORoleInfo NewRole)
{
	if (NewRole.Side == SIDE_Allies)
	{
		if (AlliesRoleIndex >= ArrayCount(AlliesRoles))
		{
			log("ROTeamGame: Too many Allied roles detected!");
			return;
		}

		AlliesRoles[AlliesRoleIndex] = NewRole;
		ROGameReplicationInfo(GameReplicationInfo).AlliesRoles[AlliesRoleIndex] = NewRole;
		AlliesRoleIndex++;
	}
	else
	{
		if (AxisRoleIndex >= ArrayCount(AxisRoles))
		{
			log("ROTeamGame: Too many Axis roles detected!");
			return;
		}

		AxisRoles[AxisRoleIndex] = NewRole;
		ROGameReplicationInfo(GameReplicationInfo).AxisRoles[AxisRoleIndex] = NewRole;
		AxisRoleIndex++;
	}
}

//-----------------------------------------------------------------------------
// InitGame - Sets up game config properties
//-----------------------------------------------------------------------------

event InitGame(string Options, out string Error)
{
	local string InOpt;

	Super.InitGame(Options, Error);

	InOpt = ParseOption( Options, "MaxIdleTime");
	if (InOpt != "")
	{
		log("MaxIdleTime: "$float(InOpt));
		MaxIdleTime = Max(float(InOpt), 0);
	}

	InOpt = ParseOption( Options, "RoundLimit");
	if (InOpt != "")
	{
		log("RoundLimit: "$int(InOpt));
		RoundLimit = Max(int(InOpt), 0);
	}

	InOpt = ParseOption( Options, "WinLimit");
	if (InOpt != "")
	{
		log("WinLimit: "$int(InOpt));
		WinLimit = Max(int(InOpt), 0);
	}

	InOpt = ParseOption( Options, "PreStartTime");
	if (InOpt != "")
	{
		log("PreStartTime: "$int(InOpt));
		PreStartTime = int(InOpt);
	}

	InOpt = ParseOption( Options, "AutoBalanceTeamsOnDeath");
	if (InOpt != "")
	{
		log("AutoBalanceTeamsOnDeath: "$bool(InOpt));
		bAutoBalanceTeamsOnDeath = bool(InOpt);

		if ( bAutoBalanceTeamsOnDeath )
		    bPlayersBalanceTeams = true;
	}

	InOpt = ParseOption( Options, "MaxTeamDifference");
	if (InOpt != "")
	{
		log("MaxTeamDifference: "$int(InOpt));
		MaxTeamDifference = int(InOpt);
	}

	InOpt = ParseOption( Options, "MaxPlayersOverride");
	if (InOpt != "")
	{
		log("MaxPlayersOverride: "$int(InOpt));
		MaxPlayersOverride = int(InOpt);
	}

	InOpt = ParseOption( Options, "ForgiveFFKillsEnabled");
	if (InOpt != "")
	{
		log("ForgiveFFKillsEnabled: "$bool(InOpt));
		bForgiveFFKillsEnabled = bool(InOpt);
	}

   	InOpt = ParseOption( Options, "ShowServerIPOnScoreboard");
	if (InOpt != "")
	{
		log("ShowServerIPOnScoreboard: "$bool(InOpt));
		bShowServerIPOnScoreboard = bool(InOpt);
	}

   	InOpt = ParseOption( Options, "ShowTimeOnScoreboard");
	if (InOpt != "")
	{
		log("ShowTimeOnScoreboard: "$bool(InOpt));
		bShowTimeOnScoreboard = bool(InOpt);
	}

	InOpt = ParseOption( Options, "DeathMessageMode");
	if (InOpt != "")
	{
		log("DeathMessageMode: "$int(InOpt));
		DeathMessageMode = EDeathMessageMode(Clamp(int(InOpt), 0, 3));
	}

	InOpt = ParseOption( Options, "FFDamageLimit");
	if (InOpt != "")
	{
		log("FFDamageLimit: "$int(InOpt));
		FFDamageLimit = Max(int(InOpt), 0);
	}

	InOpt = ParseOption( Options, "FFKillLimit");
	if (InOpt != "")
	{
		log("FFKillLimit: "$int(InOpt));
		FFKillLimit = Max(int(InOpt), 0);
	}

	InOpt = ParseOption( Options, "FFPunishment");
	if (InOpt != "")
	{
		log("FFPunishment: "$int(InOpt));
		FFPunishment = EFFPunishment(Clamp(int(InOpt), 0, 3));
	}

	InOpt = ParseOption(Options, "SpectateFirstPersonOnly");
	if ( InOpt != "" )
	{
		log("SpectateFirstPersonOnly: "$bool(InOpt));
		bSpectateLockedBehindView = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateLockedBehindView");
	if ( InOpt != "" )
	{
		log("SpectateFirstPersonOnly: "$bool(InOpt));
		bSpectateFirstPersonOnly = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateAllowViewPoints");
	if ( InOpt != "" )
	{
		log("SpectateAllowViewPoints: "$bool(InOpt));
		bSpectateAllowViewPoints = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateAllowRoaming");
	if ( InOpt != "" )
	{
		log("SpectateAllowRoaming: "$bool(InOpt));
		bSpectateAllowRoaming = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateAllowDeadRoaming");
	if ( InOpt != "" )
	{
		log("SpectateAllowDeadRoaming: "$bool(InOpt));
		bSpectateAllowDeadRoaming = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateBlackoutWhenDead");
	if ( InOpt != "" )
	{
		log("SpectateBlackoutWhenDead: "$bool(InOpt));
		bSpectateBlackoutWhenDead = bool(InOpt);
	}

	InOpt = ParseOption(Options, "SpectateBlackoutWhenNotViewingPlayers");
	if ( InOpt != "" )
	{
		log("SpectateBlackoutWhenNotViewingPlayers: "$bool(InOpt));
		bSpectateBlackoutWhenNotViewingPlayers = bool(InOpt);
	}

	InOpt = ParseOption( Options, "FFArtyScale");
	if (InOpt != "")
	{
		log("FFArtyScale: "$int(InOpt));
		FFArtyScale = FMax(float(InOpt), 0);
	}

	InOpt = ParseOption( Options, "FFExplosivesScale");
	if (InOpt != "")
	{
		log("FFExplosivesScale: "$int(InOpt));
		FFExplosivesScale = FMax(float(InOpt), 0);
	}

	InOpt = ParseOption( Options, "AllowNetDebugging");
	if (InOpt != "")
	{
		log("AllowNetDebugging: "$bool(InOpt));
		bAllowNetDebug = bool(InOpt);
	}

	// Some options need to be forced
	//bAttractCam = false;
	SpawnProtectionTime = 0.0;
	bAllowWeaponThrowing = true;
	bTeamScoreRounds = true;
	bSpawnInTeamArea = true;
	bAllowTaunts = false;
}

//-----------------------------------------------------------------------------
// PostLogin - Copied from TeamGame, but modified to not call the DeathMatch version (unnecessary replication)
//-----------------------------------------------------------------------------

event PostLogin( PlayerController NewPlayer )
{
	//local NavigationPoint Cam;
	local SpectatorCam Cam;

	Super.PostLogin( NewPlayer );

    if ( NewPlayer.Pawn == None && Role == ROLE_Authority )
	{
		foreach AllActors(class'SpectatorCam', Cam, LevelInfo.StartCamTag)
		{
			break;
		}

		if( Cam != none)
		{
			NewPlayer.SetLocation(Cam.Location);
	        NewPlayer.ClientSetLocation(Cam.Location,Cam.Rotation);
        }
    }

	NewPlayer.bLockedBehindView = bSpectateLockedBehindView;
	NewPlayer.bFirstPersonSpectateOnly = bSpectateFirstPersonOnly;
	NewPlayer.bAllowRoamWhileSpectating = bSpectateAllowRoaming;
	NewPlayer.bViewBlackWhenDead = bSpectateBlackoutWhenDead;
	NewPlayer.bViewBlackOnDeadNotViewingPlayers = bSpectateBlackoutWhenNotViewingPlayers;
	NewPlayer.bAllowRoamWhileDeadSpectating = bSpectateAllowDeadRoaming;
}

//-----------------------------------------------------------------------------
// StartMatch - Signals the start of actual play
//-----------------------------------------------------------------------------

function StartMatch()
{
	//local bool bTemp;
	local int Num;
	local Actor A;

	GotoState('RoundInPlay');

	if ( Level.NetMode == NM_Standalone )
		RemainingBots = InitialBots;
	else
		RemainingBots = 0;

	GameReplicationInfo.RemainingMinute = RemainingTime;

	if (GameStats!=None)
		GameStats.StartGame();

	// tell actors the game is starting
	foreach AllActors(class'Actor', A)
		A.MatchStarting();

	bWaitingToStartMatch = false;
	GameReplicationInfo.bMatchHasBegun = true;

	//bTemp = bMustJoinBeforeStart;
	//bMustJoinBeforeStart = false;

	while ( NeedPlayers() && (Num<16) )
	{
		if ( AddBot() )
			RemainingBots--;
		Num++;
	}

	//bMustJoinBeforeStart = bTemp;
	log("ROUND PLAY HAS STARTED");
}

//-----------------------------------------------------------------------------
// RestartPlayer - Adds a few things
// **NOTE** Added the code from all the superclasses here so that we could
// modify different parts of the Super's functionality. This was done to
// work on fixing the spawn bug. Once it's verified that that is fixed,
// Get rid of what we don't need here. - Ramm 08/30/04
//-----------------------------------------------------------------------------

function RestartPlayer( Controller aPlayer )
{
    local ROPlayer playa;

    if( aPlayer == none )
    	return;

    SetCharacter(aPlayer);
	Super.RestartPlayer(aPlayer);

	if (aPlayer.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX && LevelInfo.Allies.SpawnLimit > 0)
	{
		ROGameReplicationInfo(GameReplicationInfo).SpawnCount[ALLIES_TEAM_INDEX] = byte((1 - (float(++SpawnCount[ALLIES_TEAM_INDEX]) / LevelInfo.Allies.SpawnLimit)) * 100);

        //If the Allies have used up 85% of their reinforcements, send them a reinforcements low message
		if (SpawnCount[ALLIES_TEAM_INDEX] == int(LevelInfo.Allies.SpawnLimit * 0.85))
			SendReinforcementMessage(ALLIES_TEAM_INDEX, 0);
	}
	else if (aPlayer.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX && LevelInfo.Axis.SpawnLimit > 0)
	{
		ROGameReplicationInfo(GameReplicationInfo).SpawnCount[AXIS_TEAM_INDEX] = byte((1 - (float(++SpawnCount[AXIS_TEAM_INDEX]) / LevelInfo.Axis.SpawnLimit)) * 100);

        //If Axis has used up 85% of their reinforcements, send them a reinforcements low message
		if (SpawnCount[AXIS_TEAM_INDEX] == int(LevelInfo.Axis.SpawnLimit * 0.85))
			SendReinforcementMessage(AXIS_TEAM_INDEX, 0);
	}

	// hax?
	playa = ROPlayer(aPlayer);
	if (playa != none)
	{
        if (playa.bFirstRoleAndTeamChange && GetStateName() == 'RoundInPlay')
        {
            playa.NotifyOfMapInfoChange();
            playa.bFirstRoleAndTeamChange = true;
        }
	}
}

//-----------------------------------------------------------------------------
// SetCharacter - Sets the appropriate model for the player
//-----------------------------------------------------------------------------

function SetCharacter(Controller aPlayer)
{
	local RORoleInfo RI;

	if( ROPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).RoleInfo != none )
		RI = ROPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).RoleInfo;

	if (ROPlayer(aPlayer) != None && RI != None)
		ROPlayer(aPlayer).ChangeCharacter(RI.static.GetModel(),RI.static.GetPawnClass());
	else if (ROBot(aPlayer) != None && RI != None)
		ROBot(aPlayer).ChangeCharacter(RI.static.GetModel(),RI.static.GetPawnClass());
}

//-----------------------------------------------------------------------------
// SpawnLimitReached - Checks if all spawns have been exhausted for the given team
//-----------------------------------------------------------------------------

function bool SpawnLimitReached(int Team)
{
	if ((Team == AXIS_TEAM_INDEX && LevelInfo.Axis.SpawnLimit >= 0 && SpawnCount[AXIS_TEAM_INDEX] >= LevelInfo.Axis.SpawnLimit)
		|| (Team == ALLIES_TEAM_INDEX && LevelInfo.Allies.SpawnLimit >= 0 && SpawnCount[ALLIES_TEAM_INDEX] >= LevelInfo.Allies.SpawnLimit))
		return true;

	return false;
}

//-----------------------------------------------------------------------------
// ChangeTeam - Resets role after team is changed
//-----------------------------------------------------------------------------

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local UnrealTeamInfo NewTeam;
	local ROPlayer P;

	//log("Old team was "$num);
	if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		return false;	// only allow team changes before match starts

	if (CurrentGameProfile != none)
	{
		if (!CurrentGameProfile.CanChangeTeam(Other, num)) return false;
	}

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	NewTeam = Teams[PickTeam(num,Other)];

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

		P = ROPlayer(Other);

		if (P != None)
		{
			P.DesiredRole = -1;
			P.CurrentRole = -1;
			ROPlayerReplicationInfo(Other.PlayerReplicationInfo).RoleInfo = None;
			P.PrimaryWeapon = -1;
			P.SecondaryWeapon = -1;
			P.GrenadeWeapon = -1;
			P.bWeaponsSelected = false;
		}
	}

	if ( NewTeam.AddToTeam(Other) )
	{
		if (NewTeam == Teams[ALLIES_TEAM_INDEX])
			BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
		else
			BroadcastLocalizedMessage( GameMessageClass, 12, Other.PlayerReplicationInfo, None, NewTeam );

		if ( bNewTeam && PlayerController(Other)!=None )
			GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
	}

	// Since we're changing teams, remove all rally points/help requests/etc
	ClearSavedRequestsAndRallyPoints(ROPlayer(Other), false);

	return true;
}

function byte PickTeam(byte num, Controller C)
{
	local UnrealTeamInfo NewTeam;
	local Controller B;
	local int BigTeamBots, SmallTeamBots;
    local int TeamSizes[2], SmallTeam, BigTeam;

	if ( bPlayersVsBots && (Level.NetMode != NM_Standalone) )
	{
		if ( PlayerController(C) != None )
			return 1;
		return 0;
	}

    //Get the current TeamSizes for all players/bots who have selected a role
    GetTeamSizes(TeamSizes);

	if ( TeamSizes[0] > TeamSizes[1] )
	{
		SmallTeam = 1;
		BigTeam = 0;
    }
    else
    {
	    SmallTeam = 0;
    	BigTeam = 1;
	}

	if ( num < 2 )
		NewTeam = Teams[num];

	if ( NewTeam == None )
		NewTeam = Teams[SmallTeam];
	else if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) && (PlayerController(C) != None) )
	{
		//If the teams are on the verge of being off balance, force the player onto the small team
		if ( TeamSizes[BigTeam] - TeamSizes[SmallTeam] >= MaxTeamDifference )
			NewTeam = Teams[SmallTeam];
		//If the player is trying to switch to the bigger team, make sure the switch will not exceed the maximum team difference
		else if ( C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.Team != none &&
                  ROPlayerReplicationInfo(C.PlayerReplicationInfo) != none && ROPlayerReplicationInfo(C.PlayerReplicationInfo).RoleInfo != none &&
                  (NewTeam.TeamIndex == BigTeam || TeamSizes[BigTeam] == TeamSizes[SmallTeam]) &&
                  TeamSizes[BigTeam] - TeamSizes[SmallTeam] + 1 >= MaxTeamDifference )
        {
			NewTeam = UnrealTeamInfo(C.PlayerReplicationInfo.Team);
		}
		else
		{
			// count number of bots on each team
			for ( B=Level.ControllerList; B!=None; B=B.NextController )
			{
				if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot )
				{
					if ( B.PlayerReplicationInfo.TeamID == BigTeam )
						BigTeamBots++;
					else if ( B.PlayerReplicationInfo.TeamID == SmallTeam )
						SmallTeamBots++;
				}
			}

			if ( BigTeamBots > 0 )
			{
				// balance the number of players on each team
				if ( (TeamSizes[BigTeam] - BigTeamBots) - (TeamSizes[SmallTeam] - SmallTeamBots) > MaxTeamDifference)
					NewTeam = Teams[SmallTeam];
	            else if ( (TeamSizes[SmallTeam] - SmallTeamBots) - (TeamSizes[BigTeam] - BigTeamBots)  > MaxTeamDifference)
					NewTeam = Teams[BigTeam];
				else if ( BigTeamBots - SmallTeamBots > MaxTeamDifference)
					NewTeam = Teams[BigTeam];
			}
			else if ( SmallTeamBots > MaxTeamDifference )
				NewTeam = Teams[SmallTeam];
			//else if ( UnrealTeamInfo(C.PlayerReplicationInfo.Team) != None )
			//	NewTeam = UnrealTeamInfo(C.PlayerReplicationInfo.Team);
		}
	}

	return NewTeam.TeamIndex;
}

function int GetTeamUnbalanceCount(out UnrealTeamInfo BigTeam, out UnrealTeamInfo SmallTeam)
{
    local int TeamSizes[2];

    //Get the current TeamSizes for all players/bots who have selected a role
    GetTeamSizes(TeamSizes);

    //If Team0 is bigger than Team1
	if ( TeamSizes[0] > TeamSizes[1] )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
    	return ceil( float(TeamSizes[0] - TeamSizes[1] - MaxTeamDifference) / 2.0 );
	}
	else
	{
        SmallTeam = Teams[0];
    	BigTeam = Teams[1];
    	return ceil( float(TeamSizes[1] - TeamSizes[0] - MaxTeamDifference) / 2.0 );
	}
}

function GetTeamSizes( out int TeamSizes[2] )
{
    local int i;

    //Clear out the Team Sizes, just to be safe
    TeamSizes[0] = 0;
    TeamSizes[1] = 0;

    //If we don't have any players, return
    if( GameReplicationInfo == none )
    {
        return;
    }

    //Loop through all the PlayerReplicationInfo for the current players and bots
    for( i = 0; i < GameReplicationInfo.PRIArray.Length; i++ )
    {
        //Only count the players who have selected their Role Info
        if( GameReplicationInfo.PRIArray[i] != none && ROPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]) != none &&
            GameReplicationInfo.PRIArray[i].Team != none && ROPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]).RoleInfo != none )
            TeamSizes[GameReplicationInfo.PRIArray[i].Team.TeamIndex]++;
    }
}

function bool HandleDeath(ROPlayer Player)
{
    local UnrealTeamInfo BigTeam, SmallTeam;
    local int OffBalanceCount, PositionsFromBottom, i;

	if (Role == ROLE_Authority)
    {
        //If teams should be balanced on death
        if ( bPlayersBalanceTeams && bAutoBalanceTeamsOnDeath )
        {
            OffBalanceCount = GetTeamUnbalanceCount(BigTeam, SmallTeam);

            //If teams are off balance
            if ( OffBalanceCount > 0 && Player.PlayerReplicationInfo.Team == BigTeam )
            {
            	//Figure out how far from the bottom this player is
            	PositionsFromBottom = 0;
                for(i = 0; i < GameReplicationInfo.PRIArray.Length; i++)
            	{
                    if ( Player.PlayerReplicationInfo.Team == GameReplicationInfo.PRIArray[i].Team &&
                         Player.PlayerReplicationInfo.Score > GameReplicationInfo.PRIArray[i].Score )
                    {
                        PositionsFromBottom++;
                    }
                }

                //If the player is in the bottom X positions, where X is the number of players the teams are off balanced by
                if ( PositionsFromBottom < OffBalanceCount )
                {
                    //Switch the player to the other team
                    ChangeTeam(Player, SmallTeam.TeamIndex, true);

                    //Select a default role for them so that they get counted as part of their new team
                    for (i = 0; i < 10; i++)
                    {
                        if ( !RoleLimitReached(BigTeam.TeamIndex, i) )
                        {
                            ChangeRole(Player, i, false);
                            break;
                        }
                    }

                    //Open the "Select Role" menu
					Player.ClientForcedTeamChange(SmallTeam.TeamIndex, Player.DesiredRole);

					//We switched teams
					return true;
                }
            }
        }
    }

    //We didn't switch teams
    return false;
}

//-----------------------------------------------------------------------------
// ChangeWeapons - Entry point for changing the player's selected weapons
//-----------------------------------------------------------------------------

function ChangeWeapons(Controller aPlayer, int Primary, int Secondary, int Grenade)
{
	local RORoleInfo RI;
	local int i;
	local ROPlayer P;
	local ROBot B;

	if (aPlayer == None || !aPlayer.bIsPlayer || aPlayer.PlayerReplicationInfo.Team == None || aPlayer.PlayerReplicationInfo.Team.TeamIndex > 1)
		return;

	RI = ROPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).RoleInfo;

	if (RI == None)
		return;

	P = ROPlayer(aPlayer);
	B = ROBot(aPlayer);

	if (P == None && B == None)
		return;

	// Set the weapon to negative if it is out of bounds or not available so it will try to auto-select the first one
	if (Primary >= ArrayCount(RI.PrimaryWeapons) || Primary < 0 || RI.PrimaryWeapons[Primary].Item == None)
		Primary = -2;

	// If i is less than 0, then that selects no weapon and we have to make sure none are actually available
	if (Primary < 0)
	{
		for (i = 0; i < ArrayCount(RI.PrimaryWeapons); i++)
		{
			if (RI.PrimaryWeapons[i].Item != None)
			{
				Primary = i;
				break;
			}
		}

		if (P != None)
		{
			if (Primary < 0)
				P.PrimaryWeapon = -2;
			else
				P.PrimaryWeapon = Primary;
		}
		else
		{
			if (Primary < 0)
				B.PrimaryWeapon = -2;
			else
				B.PrimaryWeapon = Primary;
		}
	}
	else
	{
		if (P != None)
			P.PrimaryWeapon = Primary;
		else
			B.PrimaryWeapon = Primary;
	}

	// Same deal for secondary and grenades
	if (Secondary >= ArrayCount(RI.SecondaryWeapons) || Secondary < 0 || RI.SecondaryWeapons[Secondary].Item == None)
		Secondary = -2;

	if (Secondary < 0)
	{
		for (i = 0; i < ArrayCount(RI.SecondaryWeapons); i++)
		{
			if (RI.SecondaryWeapons[i].Item != None)
			{
				Secondary = i;
				break;
			}
		}

		if (P != None)
		{
			if (Secondary < 0)
				P.SecondaryWeapon = -2;
			else
				P.SecondaryWeapon = Secondary;
		}
		else
		{
			if (Secondary < 0)
				B.SecondaryWeapon = -2;
			else
				B.SecondaryWeapon = Secondary;
		}
	}
	else
	{
		if (P != None)
			P.SecondaryWeapon = Secondary;
		else
			B.SecondaryWeapon = Secondary;
	}

	if (Grenade >= ArrayCount(RI.Grenades) || Grenade < 0 || RI.Grenades[Grenade].Item == None)
		Grenade = -2;

	if (Grenade < 0)
	{
		for (i = 0; i < ArrayCount(RI.Grenades); i++)
		{
			if (RI.Grenades[i].Item != None)
			{
				Grenade = i;
				break;
			}
		}

		if (P != None)
		{
			if (Grenade < 0)
				P.GrenadeWeapon = -2;
			else
				P.GrenadeWeapon = Grenade;
		}
		else
		{
			if (Grenade < 0)
				B.GrenadeWeapon = -2;
			else
				B.GrenadeWeapon = Grenade;
		}
	}
	else
	{
		if (P != None)
			P.GrenadeWeapon = Grenade;
		else
			B.GrenadeWeapon = Grenade;
	}

	// Set replicated flag to tell players they're all set with selection
	if (P != None)
	{
		P.bWeaponsSelected = true;

		if (P.IsInState('PlayerWaiting') && P.HasSelectedTeam() && P.HasSelectedRole() && P.HasSelectedWeapons())
			P.ServerSpectate();
	}
}

//-----------------------------------------------------------------------------
// ChangeRole - Handles the role changing process
// Why is there bot code in here, bots never use this - Ramm
//-----------------------------------------------------------------------------

function ChangeRole(Controller aPlayer, int i, optional bool bForceMenu)
{
	local RORoleInfo RI;
	local ROPlayer Playa;
	local ROBot MrRoboto;

	if (aPlayer == None || !aPlayer.bIsPlayer || aPlayer.PlayerReplicationInfo.Team == None || aPlayer.PlayerReplicationInfo.Team.TeamIndex > 1)
		return;

	RI = GetRoleInfo(aPlayer.PlayerReplicationInfo.Team.TeamIndex, i);

	if (RI == None)
		return;

	// Lets try and avoid 50 casts - Ramm
	Playa = ROPlayer(aPlayer);

	if( Playa == none )
	{
		MrRoboto = ROBot(aPlayer);
	}


	if (Playa != None)
	{
		Playa.DesiredRole = i;

		//if (Playa.CurrentRole == i)
		//	return;

		if (aPlayer.Pawn == None)
		{
			// Try and kick a bot out of this role if bots are occupying it
			if (RoleLimitReached(aPlayer.PlayerReplicationInfo.Team.TeamIndex, i))
			{
				 HumanWantsRole(aPlayer.PlayerReplicationInfo.Team.TeamIndex, i);
			}

			if (!RoleLimitReached(aPlayer.PlayerReplicationInfo.Team.TeamIndex, i))
			{
				if (bForceMenu)
				{
					Playa.ClientReplaceMenu("ROInterface.ROUT2K4PlayerSetupPage", false, "Weapons");
				}
                else
                {
    				// Decrement the RoleCounter for the old role
					if(Playa.CurrentRole != -1)
					{
						if( aPlayer.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX )
							ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[Playa.CurrentRole]--;
						else if ( aPlayer.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX )
							ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[Playa.CurrentRole]--;
					}

    				Playa.CurrentRole = i;

    				// Increment the RoleCounter for the new role
					if( aPlayer.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX )
						ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[Playa.CurrentRole]++;
					else if ( aPlayer.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX )
						ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[Playa.CurrentRole]++;

    				ROPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).RoleInfo = RI;
    				Playa.PrimaryWeapon = -1;
    				Playa.SecondaryWeapon = -1;
    				Playa.GrenadeWeapon = -1;
    				Playa.bWeaponsSelected = false;
    				SetCharacter(aPlayer);
                }
			}
			else
			{
				Playa.DesiredRole = Playa.CurrentRole;
				PlayerController(aPlayer).ReceiveLocalizedMessage(GameMessageClass, 17, None, None, RI);
			}

			// Since we're changing roles, clear all associated requests/rally points
			ClearSavedRequestsAndRallyPoints(Playa, false);
		}
		else
		{
			PlayerController(aPlayer).ReceiveLocalizedMessage(GameMessageClass, 16, None, None, RI);
		}
	}
	else if (MrRoboto != None)
	{
		if (MrRoboto.CurrentRole == i)
			return;

		MrRoboto.DesiredRole = i;

		if (aPlayer.Pawn == None)
		{
			if (!RoleLimitReached(aPlayer.PlayerReplicationInfo.Team.TeamIndex, i))
			{
				// Decrement the RoleCounter for the old role
				if(MrRoboto.CurrentRole != -1)
				{
					if( aPlayer.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX )
						ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[MrRoboto.CurrentRole]--;
					else if ( aPlayer.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX )
						ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[MrRoboto.CurrentRole]--;
				}

				MrRoboto.CurrentRole = i;

				// Increment the RoleCounter for the new role
				if( aPlayer.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX )
					ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[MrRoboto.CurrentRole]++;
				else if ( aPlayer.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX )
					ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[MrRoboto.CurrentRole]++;

				ROPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).RoleInfo = RI;
				SetCharacter(aPlayer);
			}
			else
			{
				MrRoboto.DesiredRole = ROBot(aPlayer).CurrentRole;
			}
		}
	}
}

//-----------------------------------------------------------------------------
// GetRoleInfo - Looks up the RORoleInfo for a given role number
//-----------------------------------------------------------------------------

function RORoleInfo GetRoleInfo(int Team, int Num)
{
	if (Team > 1 || Num < 0 || Num >= ArrayCount(AxisRoles))
		return None;

	if (Team == AXIS_TEAM_INDEX)
		return AxisRoles[Num];
	else if (Team == ALLIES_TEAM_INDEX)
		return AlliesRoles[Num];

	return None;
}

//-----------------------------------------------------------------------------
// RoleLimitReached - Returns true if there are already enough players with a given role
//-----------------------------------------------------------------------------

function bool RoleLimitReached(int Team, int Num)
{
    local ROGameReplicationInfo ROGRI;

	// This shouldn't even happen, but if it does, just say the limit was reached
	if (Team > 1 || Num < 0 || Num >= ArrayCount(AxisRoles) || (Team == AXIS_TEAM_INDEX && AxisRoles[Num] == None) || (Team == ALLIES_TEAM_INDEX && AlliesRoles[Num] == None))
		return true;

    ROGRI = ROGameReplicationInfo(GameReplicationInfo);

	if (Team == AXIS_TEAM_INDEX && AxisRoles[Num].GetLimit(ROGRI.MaxPlayers) != 0 && ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[Num] >= AxisRoles[Num].GetLimit(ROGRI.MaxPlayers))
		return true;
	else if (Team == ALLIES_TEAM_INDEX && AlliesRoles[Num].GetLimit(ROGRI.MaxPlayers) != 0 && ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[Num] >= AlliesRoles[Num].GetLimit(ROGRI.MaxPlayers))
		return true;

	return false;
}

//-----------------------------------------------------------------------------
// HumanWantsRole - Tries to clear out a bot using a particular role to make
// space for a human player. Returns true if a bot was succesfully removed
//-----------------------------------------------------------------------------
function bool HumanWantsRole(int Team, int Num)
{
	local Controller C;
	local ROBot BotHasRole;

	// This shouldn't even happen, but if it does, just return
	if (Team > 1 || Num < 0 || Num >= ArrayCount(AxisRoles) || (Team == AXIS_TEAM_INDEX && AxisRoles[Num] == None) || (Team == ALLIES_TEAM_INDEX && AlliesRoles[Num] == None))
		return false;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team != None && C.PlayerReplicationInfo.Team.TeamIndex == Team)
		{
			if (ROBot(C) != None && ROBot(C).CurrentRole == Num)
			{
				BotHasRole = ROBot(C);
				break;
			}
		}
	}

    if (BotHasRole != none)
    {
		BotHasRole.Destroy();

 		if (Team == AXIS_TEAM_INDEX)
		{
			ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[Num] --;
			ROGameReplicationInfo(GameReplicationInfo).AxisRoleBotCount[Num] --;
		}
		else if (Team == ALLIES_TEAM_INDEX)
		{
			ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[Num] --;
			ROGameReplicationInfo(GameReplicationInfo).AlliesRoleBotCount[Num] --;
		}

		return true;
	}

	return false;
}

//-----------------------------------------------------------------------------
// GetVehicleRole - Returns a vehicle role for a bot
//-----------------------------------------------------------------------------
function int GetVehicleRole(int Team, int Num)
{
	local int i;

	// This shouldn't even happen, but if it does, return -1
	if (Team > 1 || Num < 0 || Num >= ArrayCount(AxisRoles) || (Team == AXIS_TEAM_INDEX && AxisRoles[Num] == None) || (Team == ALLIES_TEAM_INDEX && AlliesRoles[Num] == None))
		return -1;


	// Should probably do this team specific in case the teams have different amounts of roles
	for ( i = 0; i < ArrayCount(AxisRoles); i++ )
	{
		if( GetRoleInfo(Team, i) != none && GetRoleInfo(Team, i).bCanBeTankCrew && !RoleLimitReached(Team, i) )
		{
			return i;
		}
	}

	return -1;
}

//-----------------------------------------------------------------------------
// GetBotNewRole - Get a new random role for a bot. If a new role is
// successfully found the role number for that role will be returned. If
// A role cannot be found, returns -1
//-----------------------------------------------------------------------------
function int GetBotNewRole(ROBot ThisBot, int BotTeamNum)
{
	local int MyRole, Count, AltRole;

	if ( ThisBot != None )
	{
		MyRole = Rand(ArrayCount(AxisRoles));

		do
		{
			if( FRand() < LevelInfo.VehicleBotRoleBalance /*0.3*/ )
			{
				AltRole = GetVehicleRole(ThisBot.PlayerReplicationInfo.Team.TeamIndex, MyRole);
				if (AltRole != -1)
				{
					MyRole = AltRole;
					break;
				}
			}

			// Temp hack to prevent bots from getting MG roles
			if (RoleLimitReached(ThisBot.PlayerReplicationInfo.Team.TeamIndex, MyRole) || (GetRoleInfo(BotTeamNum, MyRole).PrimaryWeaponType == WT_LMG) ||
				(GetRoleInfo(BotTeamNum, MyRole).PrimaryWeaponType == WT_PTRD))
			{
				Count++;

				if (Count > 10)
				{
					log("ROTeamGame: Unable to find a suitable role in SpawnBot()");
					return -1;
				}
				else
				{
					MyRole++;

					if (MyRole >= ArrayCount(AxisRoles))
						MyRole = 0;
				}
			}
			else
			{
				break;
			}
		}

		return MyRole;
	}

	return -1;
}

//-----------------------------------------------------------------------------
// UpdateRoleCounts - Updates the GRI's role counts
//-----------------------------------------------------------------------------

function UpdateRoleCounts()
{
	local Controller C;
	local int i;

	for (i = 0; i < ArrayCount(AxisRoles); i++)
	{
		if (AxisRoles[i] != None)
		{
			ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[i] = 0;
			ROGameReplicationInfo(GameReplicationInfo).AxisRoleBotCount[i] = 0;
		}

		if (AlliesRoles[i] != None)
		{
			ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[i] = 0;
			ROGameReplicationInfo(GameReplicationInfo).AlliesRoleBotCount[i] = 0;
		}
	}

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if( C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.Team != none )
		{
			if (ROPlayer(C) != None && ROPlayer(C).CurrentRole != -1)
			{
				if (C.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX)
				{
					ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[ROPlayer(C).CurrentRole]++;
				}
				else if (C.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
				{
					ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[ROPlayer(C).CurrentRole]++;
				}
			}
			else if (ROBot(C) != None && ROBot(C).CurrentRole != -1)
			{
				if (C.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX)
				{
					ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[ROBot(C).CurrentRole]++;
					ROGameReplicationInfo(GameReplicationInfo).AlliesRoleBotCount[ROBot(C).CurrentRole]++;
				}
				else if (C.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
				{
					ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[ROBot(C).CurrentRole]++;
					ROGameReplicationInfo(GameReplicationInfo).AxisRoleBotCount[ROBot(C).CurrentRole]++;
				}
			}
		}
	}
}

//-----------------------------------------------------------------------------
// AddDefaultInventory
//-----------------------------------------------------------------------------

function AddDefaultInventory(Pawn aPawn)
{
	if (ROPawn(aPawn) != None)
		ROPawn(aPawn).AddDefaultInventory();

	SetPlayerDefaults(aPawn);
}

// Get a russian name for the bot
function string GetRussianName()
{
	local string S;

	S = RussianNames[RussianNameOffset%16];
	RussianNameOffset++;

	return S;
}

// Get a german name for the bot
function string GetGermanName()
{
	local string S;

	S = GermanNames[GermanNameOffset%16];
	GermanNameOffset++;

	return S;
}


/* Initialize bot - Overriden to support german and russian bot names
*/
function InitializeBot(Bot NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
    NewBot.InitializeSkill(AdjustedDifficulty);
 	Chosen.InitBot(NewBot);
    BotTeam.AddToTeam(NewBot);

    if ( Chosen.ModifiedPlayerName != "" )
    {
 		ChangeName(NewBot, Chosen.ModifiedPlayerName, false);
 	}
    else
    {
		if( BotTeam.TeamIndex == AXIS_TEAM_INDEX )
		{
			ChangeName(NewBot, GetGermanName(), false);
		}
		else if ( BotTeam.TeamIndex == ALLIES_TEAM_INDEX )
		{
			ChangeName(NewBot, GetRussianName(), false);
		}
		else
		{
			ChangeName(NewBot, Chosen.PlayerName, false);
		}
	}
	if ( bEpicNames && (NewBot.PlayerReplicationInfo.PlayerName ~= "The_Reaper") )
	{
		NewBot.Accuracy = 1;
		NewBot.StrafingAbility = 1;
		NewBot.Tactics = 1;
		NewBot.InitializeSkill(AdjustedDifficulty+2);
	}

	BotTeam.SetBotOrders(NewBot,Chosen);
}

//-----------------------------------------------------------------------------
// SpawnBot - Spawns the bot and randomly give them a role
//-----------------------------------------------------------------------------

function Bot SpawnBot(optional string botName)
{
	local ROBot NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;
	local int MyRole;
	local RORoleInfo RI;

	BotTeam = GetBotTeam();
	Chosen = BotTeam.ChooseBotClass(botName);

	if (Chosen.PawnClass == None)
		Chosen.Init(); //amb

	// Change default bot class

	Chosen.PawnClass = class<Pawn>(DynamicLoadObject(DefaultPlayerClassName, class'class'));

	// log("Chose pawn class "$Chosen.PawnClass);
	NewBot = ROBot(Spawn(Chosen.PawnClass.Default.ControllerClass));


	if ( NewBot != None )
	{
		InitializeBot(NewBot,BotTeam,Chosen);

		MyRole = GetBotNewRole(NewBot,BotTeam.TeamIndex);

		if ( MyRole >= 0 )
		{
			RI = GetRoleInfo(BotTeam.TeamIndex, MyRole);
		}

		if( MyRole == -1 || RI == none )
		{
			NewBot.Destroy();
			return None;
		}

		NewBot.CurrentRole = MyRole;
		NewBot.DesiredRole = MyRole;

		// Increment the RoleCounter for the new role
		if( BotTeam.TeamIndex == AXIS_TEAM_INDEX )
			ROGameReplicationInfo(GameReplicationInfo).AxisRoleCount[NewBot.CurrentRole]++;
		else if ( BotTeam.TeamIndex == ALLIES_TEAM_INDEX )
			ROGameReplicationInfo(GameReplicationInfo).AlliesRoleCount[NewBot.CurrentRole]++;

		// Tone down the "gamey" bot parameters
		NewBot.Jumpiness = 0.0;
		NewBot.TranslocUse = 0.0;

		// Set the bots favorite weapon to thier primary weapon
		NewBot.FavoriteWeapon=class<ROWeapon>(RI.PrimaryWeapons[0].Item);

       	// Tweak the bots abilities and characteristics based on thier role
        switch(RI.PrimaryWeaponType)
        {
			case WT_SMG:
				NewBot.CombatStyle = 1 - (FRand() * 0.2);
				NewBot.Accuracy = 0.3;
				NewBot.StrafingAbility = 0.0;
				break;

			case WT_SemiAuto:
				NewBot.CombatStyle = 0;
				NewBot.Accuracy = 0.5;
				NewBot.StrafingAbility = -1.0;
			   	break;

			case WT_Rifle:
				NewBot.CombatStyle = -1 + (FRand() * 0.4);
				NewBot.Accuracy = 0.75;
				NewBot.StrafingAbility = -1.0;
			   	break;

			case WT_LMG:
				NewBot.CombatStyle = -1;
				NewBot.Accuracy = 0.75;
				NewBot.StrafingAbility = -1.0;
			   	break;

			case WT_Sniper:
				NewBot.CombatStyle = -1;
				NewBot.Accuracy = 1.0;
				NewBot.StrafingAbility = -1.0;
			   	break;
        }


		ROPlayerReplicationInfo(NewBot.PlayerReplicationInfo).RoleInfo = RI;
		ChangeWeapons(NewBot, -2, -2, -2);
		SetCharacter(NewBot);
	}

	return NewBot;
}

//-----------------------------------------------------------------------------
// AddBot
//-----------------------------------------------------------------------------

function bool AddBot(optional string botName)
{
    local Bot NewBot;

    NewBot = SpawnBot(botName);
    if ( NewBot == None )
    {
        warn("Failed to spawn bot.");
        return false;
    }
    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;
    /*if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else*/
		NewBot.GotoState('Dead');

    return true;
}

//-----------------------------------------------------------------------------
// RatePlayerStart - Use moving spawns if enabled
//-----------------------------------------------------------------------------

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);

	if (P == None)
		return -10000000;

	if (LevelInfo.bUseSpawnAreas && CurrentSpawnArea[Team] != None)
	{
		if (CurrentTankCrewSpawnArea[Team]!= None && Player != none && ROPlayerReplicationInfo(Player.PlayerReplicationInfo).RoleInfo.bCanBeTankCrew)
		{
			if (P.Tag != CurrentTankCrewSpawnArea[Team].Tag)
				return -9000000;
		}
		else
		{
			if (P.Tag != CurrentSpawnArea[Team].Tag)
				return -9000000;
		}
	}
	else if (Team != P.TeamNumber)
		return -9000000;

	return Super(DeathMatch).RatePlayerStart(N,Team,Player);
}

//-----------------------------------------------------------------------------
// EndGame - Fixed end of game bug - butto 7/13/03
//-----------------------------------------------------------------------------

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P, NextController;
	local PlayerController Player;
	local Actor Cam;
	local ROMinefieldBase Minefield;

	// don't end game if not really ready
	/*if ( !CheckEndGame(Winner, Reason) )
	{
		bOverTime = true;
		return;
	}*/

	//Turn off all minefields
	foreach AllActors(class'ROMinefieldBase', Minefield)
        Minefield.Deactivate();

	foreach AllActors(class'Actor', Cam, LevelInfo.EndCamTag)
		break;

	EndGameFocus = Cam; //Controller(Winner.Owner).Pawn;

	if (EndGameFocus != None)
		EndGameFocus.bAlwaysRelevant = true;

	for (P = Level.ControllerList; P != None; P = NextController )
	{
		Player = PlayerController(P);

		if ( Player != None )
		{
			//PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
			if ( EndGameFocus != None )
			{
				Player.ClientSetBehindView(false);
				Player.ClientSetViewTarget(EndGameFocus);
				Player.SetViewTarget(EndGameFocus);
			}
			else
			{
				Player.ClientSetBehindView(true);
			}

			Player.ClientGameEnded();
		}
		NextController = P.NextController;
		P.GameHasEnded();
	}


	EndTime = Level.TimeSeconds + EndTimeDelay;
	bGameEnded = true;
	TriggerEvent('EndGame', self, None);
	EndLogging(Reason);
	GotoState('MatchOver');
}

//-----------------------------------------------------------------------------
// BroadcastDeathMessage - Handles the death message modes
//-----------------------------------------------------------------------------

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	local Controller P;

	switch (DeathMessageMode)
	{
		case DM_None:
			return;
		case DM_OnDeath:
			if (PlayerController(Other) != None)
			{
				if ((Killer == Other) || (Killer == None))
					ROPlayer(Other).AddHudDeathMessage(None, Other.PlayerReplicationInfo, DamageType);
				else
					ROPlayer(Other).AddHudDeathMessage(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, DamageType);
			}
			break;
		case DM_Personal:
			if (PlayerController(Other) != None)
			{
				if ((Killer == Other) || (Killer == None))
				{
					ROPlayer(Other).AddHudDeathMessage(None, Other.PlayerReplicationInfo, DamageType);
				}
				else
				{
					ROPlayer(Other).AddHudDeathMessage(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, DamageType);

					if (PlayerController(Killer) != None)
						ROPlayer(Killer).AddHudDeathMessage(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, DamageType);
				}
			}
			break;
		case DM_All:
		default:
			for (P = Level.ControllerList; P != None; P = P.NextController)
			{
			if (ROPlayer(P) == None)
				continue;
			if ((Killer == Other) || (Killer == None))
				ROPlayer(P).AddHudDeathMessage(None, Other.PlayerReplicationInfo, DamageType);
			else
				ROPlayer(P).AddHudDeathMessage(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, DamageType);
			}
			break;
	}
}

//-----------------------------------------------------------------------------
// ReduceDamage - Handles reduction or elimination of damage
//-----------------------------------------------------------------------------

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	// Check if the player is in a spawn area and should be protected from damage
	if (LevelInfo.bUseSpawnAreas && (InstigatedBy != none)
		&& (InstigatedBy != Injured) && (Injured.PlayerReplicationInfo != none)
    	&& (Injured.PlayerReplicationInfo.Team != none))
	{
		if (CurrentSpawnArea[Injured.PlayerReplicationInfo.Team.TeamIndex] != none
        && CurrentSpawnArea[Injured.PlayerReplicationInfo.Team.TeamIndex].PreventDamage(Injured))
			return 0;

		if (CurrentTankCrewSpawnArea[Injured.PlayerReplicationInfo.Team.TeamIndex] != none
        && CurrentTankCrewSpawnArea[Injured.PlayerReplicationInfo.Team.TeamIndex].PreventDamage(Injured))
			return 0;
	}

	Damage = Super.ReduceDamage(Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType);

	// Check for FF damage here since it's convenient
	if (Damage > 0 && (ROPawn(instigatedBy) != none) && PlayerController(instigatedBy.Controller) != None
		&& ROPawn(injured) != none
		&& (injured != instigatedBy) && (InstigatedBy.PlayerReplicationInfo != none)
		&& (injured.PlayerReplicationInfo != none)
		&& instigatedBy.PlayerReplicationInfo.Team == injured.PlayerReplicationInfo.Team)
	{
		ROPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).FFDamage += Damage;
		PlayerController(InstigatedBy.Controller).ReceiveLocalizedMessage(GameMessageClass, 15);

		if (ROPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).FFDamage > FFDamageLimit && FFDamageLimit != 0)
			HandleFFViolation(PlayerController(InstigatedBy.Controller));
	}

// Antarian 12/12/03
// HACK HACK HACK
// I know this is shitty, but I found that offline grenade damage to yourself would be halved
// if you're skill level was set low enough.  This would result in a german player surviving a
// grenade exploding in their hand.  Maybe take this out at a later point if we do an SP option.
/*	if ( Level.Game.GameDifficulty <= 3 )
    {
        if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone)
		&& (DamageType == class'ROF1GrenadeDamType' || DamageType == class'ROStielGranateDamType') )
            Damage *= 2;
    }*/
    // Problems with this right now - Erik
// end of Antarian's addition

	return Damage;
}

//-----------------------------------------------------------------------------
// HandleFFViolation - Handles punishment for TKers
//-----------------------------------------------------------------------------

function HandleFFViolation(PlayerController Offender)
{
	local bool bSuccess;

	if (FFPunishment == FFP_None || Level.NetMode == NM_Standalone)
		return;

	BroadcastLocalizedMessage(GameMessageClass, 14, Offender.PlayerReplicationInfo);
	log("Kicking"@Offender.GetHumanReadableName()@"due to a friendly fire violation.");

	if (FFPunishment == FFP_Kick)
		bSuccess = KickPlayer(Offender);//AccessControl.KickPlayer(Offender);
	else if (FFPunishment == FFP_SessionBan)
		bSuccess = AccessControl.BanPlayer(Offender, true);
	else
		bSuccess = AccessControl.BanPlayer(Offender);

	if (!bSuccess)
		log("Unable to remove"@Offender.GetHumanReadableName()@"from the server.");
}

// Added this here so we could give the player the correct message when they are kicked
function bool KickPlayer(PlayerController C)
{
	// Do not kick logged admins
	if (C != None && !IsAdmin(C) && NetConnection(C.Player)!=None )
    {
		// TODO implement a way for admins to specify the reason
		C.ClientNetworkMessage("AC_Kicked","You have been kicked due to too many team kills");
		if (C.Pawn != none && Vehicle(C.Pawn) == none )
			C.Pawn.Destroy();
		if (C != None)
			C.Destroy();
		return true;
    }
	return false;
}

// Returns true is the player is an admin
function bool IsAdmin(PlayerController P)
{
	return P.PlayerReplicationInfo.bAdmin || P.PlayerReplicationInfo.bSilentAdmin;
}

//-----------------------------------------------------------------------------
// Killed - Checks if all players are dead if the spawn limit for the team was reached
//-----------------------------------------------------------------------------

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	local Controller P;
	local int i, num;
	local float FFPenalty;

	if ((Killer != None) && Killer.bIsPlayer && (Killed != None) && Killed.bIsPlayer)
		DamageType.static.IncrementKills(Killer);

	if (Killed != None && Killed.bIsPlayer)
	{
		Killed.PlayerReplicationInfo.Deaths += 1;
		BroadcastDeathMessage(Killer, Killed, damageType);

		// Remove any help requests that the killed player might have had
		ClearSavedRequestsAndRallyPoints(ROPlayer(Killed), true);

		if ( (Killer == Killed) || (Killer == None) )
		{
			if ( Killer == None )
				KillEvent("K", None, Killed.PlayerReplicationInfo, DamageType);
			else
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);
		}
		else
		{
			if ( bTeamGame && (Killer.PlayerReplicationInfo != None) && (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) )
			{
				//ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills++;
				// Allow admins to handle different types of damage differently

				//log("DamageType = "$DamageType$" DamageType ChildOf NadeDamage = "$ClassIsChildOf(DamageType,class'ROGrenadeDamType')$" DamageType.ISA(NadeDamage) = "$DamageType.IsA('ROGrenadeDamType'));
				if( DamageType.IsA('ROArtilleryDamType') || ClassIsChildOf(DamageType,class'ROArtilleryDamType') )
				{
					FFPenalty = (1.0 * FFArtyScale);
					//log("Damage was arty FFArtyScale = "$FFArtyScale$" FFKills = "$ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills);
				}
				else if( ClassIsChildOf(DamageType,class'ROGrenadeDamType') || ClassIsChildOf(DamageType,class'ROSatchelDamType') || ClassIsChildOf(DamageType,class'ROTankShellExplosionDamage'))
				{
					FFPenalty = (1.0 * FFExplosivesScale);
					//log("Damage was explosion FFExplosivesScale = "$FFExplosivesScale$" FFKills = "$ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills);
				}
				else
				{
					FFPenalty = 1.0;
					//log("Damage was "$DamageType$" FriendlyFireScale = "$FriendlyFireScale$" FFKills = "$ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills);
				}

				ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills += FFPenalty;

				if (PlayerController(Killer) != None)
				{
					BroadcastLocalizedMessage(GameMessageClass, 13, Killer.PlayerReplicationInfo);

					//Store the last killer into the Killed player's controller
					if (bForgiveFFKillsEnabled && ROPlayer(Killed) != none)
					{
					    PlayerController(Killed).ReceiveLocalizedMessage(GameMessageClass, 18, Killer.PlayerReplicationInfo);
					    ROPlayer(Killed).LastFFKiller = ROPlayerReplicationInfo(Killer.PlayerReplicationInfo);
					    ROPlayer(Killed).LastFFKillAmount = FFPenalty;
					}

					if (ROPlayerReplicationInfo(Killer.PlayerReplicationInfo).FFKills > FFKillLimit)
						HandleFFViolation(PlayerController(Killer));
				}

				KillEvent("TK", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);
			}
			else
			{
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);
			}
		}
	}

	if (Killed != None)
		ScoreKill(Killer, Killed);

	DiscardInventory(KilledPawn);
	NotifyKilled(Killer,Killed,KilledPawn);

	for (i = 0; i < 2; i++)
	{
		if (SpawnLimitReached(i))
		{
			num = 0;

			for (P = Level.ControllerList; P != None; P = P.NextController)
			{
				if (P.bIsPlayer && P.Pawn != None && P.Pawn.Health > 0 && P.PlayerReplicationInfo.Team.TeamIndex == i)
					num++;
			}

			if (num == 0)
				EndRound(int(!bool(i)));	// It looks like a hack, but hey, it's the easiest way to find the opposite team :)
		}
	}
}

//-----------------------------------------------------------------------------
// ScoreKill
//-----------------------------------------------------------------------------

function ScoreKill(Controller Killer, Controller Other)
{
	local float Amount;
	local int i;
    local ROPlayerReplicationInfo roPRI;
    local ROPlayer roKiller;
    local array<PlayerController> vehicleOccupants;

	if (Killer == Other || Killer == None)
	{
		Other.PlayerReplicationInfo.Score -= 1;
		ScoreEvent(Other.PlayerReplicationInfo, -1, "self_frag");
	}
	else if (Other.bIsPlayer && Killer.bIsPlayer && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
	{
		if (ROPlayerReplicationInfo(Other.PlayerReplicationInfo) != None && ROPlayerReplicationInfo(Other.PlayerReplicationInfo).RoleInfo != None)
		{
			Amount = -2 * ROPlayerReplicationInfo(Other.PlayerReplicationInfo).RoleInfo.default.PointValue;
			Killer.PlayerReplicationInfo.Score += Amount;

		}
		else
		{
			Amount = -2;
			Killer.PlayerReplicationInfo.Score += Amount;
		}

		ScoreEvent(Killer.PlayerReplicationInfo, Amount, "team_frag");
	}
	else if (Killer.PlayerReplicationInfo != None) //  re-written to support vehicle scoring, plus optimized code a bit - MrMethane 01/23/2005
	{
	    roPRI = ROPlayerReplicationInfo(Other.PlayerReplicationInfo);

		if (roPRI != None && roPRI.RoleInfo != None)
		{
			Amount = roPRI.RoleInfo.default.PointValue;
		}
		else
		{
			Amount = 1;
		}

		// is the killer in a vehicle?
		if(Killer.Pawn != none && (Killer.Pawn.IsA('ROVehicle') || Killer.Pawn.IsA('ROVehicleWeaponPawn')))
		{
           roKiller = ROPlayer(Killer.PlayerReplicationInfo.Owner);

		   if(roKiller != none)
		   {
				// Score kill for everyone in vehicle
				vehicleOccupants = roKiller.GetVehicleOccupants(roKiller);

				for(i=0; i< vehicleOccupants.Length; i++)
				{
					vehicleOccupants[i].PlayerReplicationInfo.Score += Amount;
					vehicleOccupants[i].PlayerReplicationInfo.Kills++;
				}
		   }

		   ScoreEvent(Killer.PlayerReplicationInfo, Amount, "frag");
		}
		else
		{
            Killer.PlayerReplicationInfo.Score += Amount;

		    Killer.PlayerReplicationInfo.Kills++;
		    ScoreEvent(Killer.PlayerReplicationInfo, Amount, "frag");
		}
	}

	if (GameRulesModifiers != None)
		GameRulesModifiers.ScoreKill(Killer, Other);
}

//-----------------------------------------------------------------------------
// ScoreMGResupply - give player a point for resupplying a gunner
//-----------------------------------------------------------------------------
function ScoreMGResupply( Controller Dropper, Controller Gunner )
{
	local int ResupplyAward;

	if( Dropper == Gunner )
	{
		return;
	}

	else if( (ROPlayerReplicationInfo(Dropper.PlayerReplicationInfo) != none)
		&& (ROPlayerReplicationInfo(Dropper.PlayerReplicationInfo).RoleInfo != none) )
	{
		ResupplyAward = 5;
		Dropper.PlayerReplicationInfo.Score += ResupplyAward;

		ScoreEvent(Dropper.PlayerReplicationInfo, ResupplyAward, "MG_resupply");
	}
}

//-----------------------------------------------------------------------------
// FillPlayInfo - PlayInfo
//-----------------------------------------------------------------------------

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local class<Mutator>	mutClass;
	local int i;

	Super(Info).FillPlayInfo(PlayInfo);  // Always begin with calling parent

	i=0;
	PlayInfo.AddSetting(default.BotsGroup,   "GameDifficulty",     default.PropsDisplayText[i++], 0, 50, "Select", default.PropsExtras[0], "Xb");
	PlayInfo.AddSetting(default.GameGroup, "bChangeLevels",      default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting(default.GameGroup,   "GameSpeed",          default.PropsDisplayText[i++], 0, 80, "Text", "8;0.1:3.5",,,true);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",      default.PropsDisplayText[i++], 1, 30, "Text", "3;0:32",,true);
	if ( default.bIgnore32PlayerLimit )
	    PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",         default.PropsDisplayText[i++], 0, 25, "Text", "3;0:64",,true);
	else
	    PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",         default.PropsDisplayText[i++], 0, 25, "Text", "3;0:32",,true);
	PlayInfo.AddSetting(default.RulesGroup,  "TimeLimit",          default.PropsDisplayText[i++], 0, 33, "Text", "3;0:999");

	PlayInfo.AddSetting(default.GameGroup,   "bAllowBehindview",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateFirstPersonOnly",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateLockedBehindView",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateAllowViewPoints",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateAllowRoaming",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateAllowDeadRoaming",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bAdminCanPause",       default.PropsDisplayText[i++], 1, 60, "Check",,,true);

	PlayInfo.AddSetting(default.BotsGroup,  "MinPlayers",       default.PropsDisplayText[i++], 0, 40, "Text", "3;0:32");
	PlayInfo.AddSetting(default.BotsGroup,  "BotMode",			 default.PropsDisplayText[i++], 0,  40, "Select", default.BotModeText);

	PlayInfo.AddSetting(default.GameGroup,  "EndTimeDelay",     default.PropsDisplayText[i++], 0, 40, "Text",,,true,true);
 //AddSetting(string Group, string PropertyName, string Description, byte SecLevel, byte Weight, string RenderType, optional string Extras, optional string ExtraPrivs, optional bool bMultiPlayerOnly, optional bool bAdvanced);

	PlayInfo.AddSetting(default.BotsGroup,   "bAdjustSkill",        default.PropsDisplayText[i++], 0,  30, "Check");

	PlayInfo.AddSetting(default.RulesGroup, "WinLimit",         default.PropsDisplayText[i++], 0, 33, "Text", "3;0:999");
	PlayInfo.AddSetting(default.RulesGroup, "RoundLimit",         default.PropsDisplayText[i++], 0, 33, "Text", "3;0:999");
	PlayInfo.AddSetting(default.GameGroup, "PreStartTime",         default.PropsDisplayText[i++], 0, 40, "Text", "3;0:60");
	//PlayInfo.AddSetting("Server", "VoteKickPct",         default.PropsDisplayText[i++], 0, 40, "Text", "3;0.0:1.0",,true);

	// new admin requested server settings
	PlayInfo.AddSetting(default.GameGroup, "NetWait",             default.PropsDisplayText[i++], 2,  40, "Text", "3;0:60",,true,true);
	PlayInfo.AddSetting(default.GameGroup, "MinNetPlayers",       default.PropsDisplayText[i++], 1,  25, "Text", "3;0:32",,true,true);
	PlayInfo.AddSetting(default.GameGroup, "bPlayersMustBeReady", default.PropsDisplayText[i++], 1,  20, "Check",,,true,true);

	// FriendlyFire
	PlayInfo.AddSetting(default.RulesGroup, "FriendlyFireScale",   default.PropsDisplayText[i++], 2, 50, "Text", "3;0.0:10.0");
	PlayInfo.AddSetting(default.RulesGroup, "FFArtyScale",         default.PropsDisplayText[i++], 1, 55, "Text", "3;0.0:10.0",,true,true);
	PlayInfo.AddSetting(default.RulesGroup, "FFExplosivesScale",   default.PropsDisplayText[i++], 2, 60, "Text", "3;0.0:10.0",,true,true);

	// From TeamGame
	PlayInfo.AddSetting(default.BotsGroup,  "bBalanceTeams",            default.PropsDisplayText[i++], 0,   2, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bPlayersBalanceTeams",     default.PropsDisplayText[i++], 0,   1, "Check", ,    , True);
	PlayInfo.AddSetting(default.ChatGroup,  "bAllowNonTeamChat",	    default.PropsDisplayText[i++], 60,  1, "Check", ,"Xv", True, True);

    // From GameInfo
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",			default.PropsDisplayText[i++], 	0, 1, "Text",      "3;0:300",            ,True,True);

	PlayInfo.AddSetting(default.RulesGroup,  "FFPunishment",      	default.PropsDisplayText[i++], 0, 65, "Select", default.PropsExtras[1],,true,true);
    PlayInfo.AddSetting(default.RulesGroup,  "DeathMessageMode",    default.PropsDisplayText[i++], 0, 25, "Select", default.PropsExtras[2],,false,true);

	PlayInfo.AddSetting(default.GameGroup,   "bSpectateBlackoutWhenDead",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);
	PlayInfo.AddSetting(default.GameGroup,   "bSpectateBlackoutWhenNotViewingPlayers",     default.PropsDisplayText[i++], 1, 60, "Check",,,true);

	PlayInfo.AddSetting(default.RulesGroup,  "bAutoBalanceTeamsOnDeath", default.PropsDisplayText[i++], 0,  2, "Check",        ,,true);
	PlayInfo.AddSetting(default.RulesGroup,  "MaxTeamDifference",        default.PropsDisplayText[i++], 0,  3, "Text", "3;1:32",,true);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayersOverride",       default.PropsDisplayText[i++], 0,  27,"Text", "3;0:64",,true,true);
	PlayInfo.AddSetting(default.RulesGroup,  "bForgiveFFKillsEnabled",   default.PropsDisplayText[i++], 0,  70,"Check",        ,,true);
	PlayInfo.AddSetting(default.RulesGroup,  "FFKillLimit",              default.PropsDisplayText[i++], 1,  40,"Text", "3;0.0:1000.0",,true);
	PlayInfo.AddSetting(default.RulesGroup,  "FFDamageLimit",            default.PropsDisplayText[i++], 1,  45,"Text", "3;0.0:100000.0",,true);

	PlayInfo.AddSetting(default.ServerGroup, "bShowServerIPOnScoreboard",default.PropsDisplayText[i++], 0,  50,"Check",        ,,true,true);
	PlayInfo.AddSetting(default.ServerGroup, "bShowTimeOnScoreboard",    default.PropsDisplayText[i++], 0,  60,"Check",        ,,true,true);



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

	if (default.MutatorClass != "")
		mutClass=class<Mutator>(DynamicLoadObject(default.MutatorClass, class'Class'));
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "GameDifficulty":				return default.PropDescText[0];
		case "bChangeLevels":				return default.PropDescText[1];
		case "GameSpeed":					return default.PropDescText[2];
		case "MaxSpectators":				return default.PropDescText[3];
		case "MaxPlayers":					return default.PropDescText[4];
		case "TimeLimit":					return default.PropDescText[5];
		case "bAllowBehindview":			return default.PropDescText[6];
		case "bSpectateFirstPersonOnly":	return default.PropDescText[7];
		case "bSpectateLockedBehindView":	return default.PropDescText[8];
		case "bSpectateAllowViewPoints":	return default.PropDescText[9];
		case "bSpectateAllowRoaming":		return default.PropDescText[10];
		case "bSpectateAllowDeadRoaming":	return default.PropDescText[11];
		case "bAdminCanPause":				return default.PropDescText[12];
		case "MinPlayers":					return default.PropDescText[13];
		case "BotMode":						return default.PropDescText[14];
		case "EndTimeDelay":				return default.PropDescText[15];
		case "bAdjustSkill":				return default.PropDescText[16];
		case "WinLimit":					return default.PropDescText[17];
		case "RoundLimit":					return default.PropDescText[18];
		case "PreStartTime":				return default.PropDescText[19];
		case "NetWait":						return default.PropDescText[20];
		case "MinNetPlayers":				return default.PropDescText[21];
		case "bPlayersMustBeReady":			return default.PropDescText[22];
		case "FriendlyFireScale":			return default.PropDescText[23];
		case "FFArtyScale":					return default.PropDescText[24];
		case "FFExplosivesScale":			return default.PropDescText[25];
		case "bBalanceTeams":				return default.PropDescText[26];
		case "bPlayersBalanceTeams":		return default.PropDescText[27];
		case "bAllowNonTeamChat":			return default.PropDescText[28];
		case "MaxIdleTime":					return default.PropDescText[29];
		case "FFPunishment":				return default.PropDescText[30];
		case "DeathMessageMode":			return default.PropDescText[31];
		case "bSpectateBlackoutWhenDead":	return default.PropDescText[32];
		case "bSpectateBlackoutWhenNotViewingPlayers":	return default.PropDescText[33];
		case "bAutoBalanceTeamsOnDeath":    return default.PropDescText[34];
		case "MaxTeamDifference":           return default.PropDescText[35];
		case "MaxPlayersOverride":          return default.PropDescText[36];
		case "bForgiveFFKillsEnabled":      return default.PropDescText[37];
		case "FFKillLimit":                 return default.PropDescText[38];
		case "FFDamageLimit":               return default.PropDescText[39];
		case "bShowServerIPOnScoreboard":   return default.PropDescText[40];
	    case "bShowTimeOnScoreboard":       return default.PropDescText[41];
	}

	return Super.GetDescriptionText(PropName);
}

//-----------------------------------------------------------------------------
// GetServerDetails - Server info shown in browsers
//-----------------------------------------------------------------------------

function GetServerDetails( out ServerResponseLine ServerState )
{
	Super(GameInfo).GetServerDetails( ServerState );

	AddServerDetail( ServerState, "PreStartTime", PreStartTime );
	AddServerDetail( ServerState, "TimeLimit", TimeLimit );
	AddServerDetail( ServerState, "RoundLimit", RoundLimit );
	AddServerDetail( ServerState, "WinLimit", WinLimit );
	AddServerDetail( ServerState, "ForceRespawn", bForceRespawn );
	AddServerDetail( ServerState, "MinPlayers", minplayers );
	AddServerDetail( ServerState, "FFKillLimit", ffkilllimit );
	AddServerDetail( ServerState, "FFDamageLimit", ffdamagelimit );
	AddServerDetail( ServerState, "FFArtyScale", ffartyscale );
	AddServerDetail( ServerState, "FFExplosivesScale", ffexplosivesscale );
	AddServerDetail( ServerState, "FFPunishment", GetEnum( enum'EFFPunishment', FFPunishment));
	AddServerDetail( ServerState, "DeathMessageMode", GetEnum( enum'EDeathMessageMode', DeathMessageMode) );
	AddServerDetail( ServerState, "FirstPersonOnly", bSpectateFirstPersonOnly );
	AddServerDetail( ServerState, "LockBehindView", bSpectateLockedBehindView );
	AddServerDetail( ServerState, "SpectateViewPoints", bSpectateAllowViewPoints );
	AddServerDetail( ServerState, "SpectateAllowRoaming", bSpectateAllowRoaming );
	AddServerDetail( ServerState, "AllowDeadRoaming", bSpectateAllowDeadRoaming );
	AddServerDetail( ServerState, "SpectateBlackoutWhenDead", bSpectateBlackoutWhenDead );
	AddServerDetail( ServerState, "SpectateBlackoutWhenNotViewingPlayers", bSpectateBlackoutWhenNotViewingPlayers );
    AddServerDetail( ServerState, "AutoBalanceTeamsOnDeath", bAutoBalanceTeamsOnDeath );
    AddServerDetail( ServerState, "MaxPlayersOverride", MaxPlayersOverride );
}

//-----------------------------------------------------------------------------
// PrecacheGameTextures
//-----------------------------------------------------------------------------

static function PrecacheGameTextures(LevelInfo myLevel)
{
	// Gore
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.GoreEmitters.BloodCircle');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.metalsmokefinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.GoreEmitters.BloodPuff');
//
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_001');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_002');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_003');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_004');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_005');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Splatter_006');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Drip_001');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Drip_002');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Drip_003');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.PlayerDeathOverlay');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Gore_Effects');
//
//	// Muzzle flashes
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.MuzzleCorona1stP');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Karmuzzle_2frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.STGmuzzleflash_4frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.MPmuzzleflash_4frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.PPSHmuzzle_4frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.PTRDmuzzle_2frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.muzzle_4frame3rd');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.MP3rdPmuzzle_smoke1frame');
//
//	// Arty - TODO: Need to somehow tie this to the artillery radio actor so we don't precache this for every level
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.artillerymark_dirt');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.artillerymark_snow');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.LSmoke3');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.impact_2frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.LSmoke1');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_1');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.artilleryblast_1frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.explosion_1frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_2');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowfinal2');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.exp_dirt');
//
//	// Explosives
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel1');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowchunksfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.radialexplosion_1frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.grenademark_snow');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.concrete_chunks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel3');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.waterring_2frame');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplashcloud');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplatter2');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersmoke');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodchunksfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.rock_chunks');
//
//	// Bullet hits
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_cloth');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_concrete');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_dirt');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_flesh');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_ice');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_metal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_metalarmor');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_snow');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHoles.bullethole_wood');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.Sparks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.papersmoke');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonesmokefinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtclouddark');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtcloud');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundthick');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.grasschunks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonefinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.stonechunksfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.icechunks');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.sparkfinal2');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.groundchunksfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.rubbersmokefinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodfinal');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodsmokefinal2');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.rocketmark_dirt');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.explosions.rocketmark_snow');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Smoke.LightSmoke_8Frame');
//
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.russian_sleeves');
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.german_sleeves');
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Flesh');
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Bullets.Bullet_Shell_Rifle');
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Bullet_Shell_Rifle_MN');
//	myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Zoomscope.zoomblur10');
//	myLevel.AddPrecacheMaterial(Material'ROEffects.Skins.Rexpt');
//	myLevel.AddPrecacheMaterial(Material'ROEffects.SmokeAlphab_t');
//
//	// Adding scope texturs so they don't lag up when you bring them up
//	//myLevel.AddPrecacheMaterial(Material'ScopeShaders.ScriptedLense');
//	myLevel.AddPrecacheMaterial(Material'ScopeShaders.Zoomblur.Xhair');
//	//myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Zoomscope.LensShader');
//	//myLevel.AddPrecacheMaterial(Material'Weapons1st_tex.Zoomscope.Texture_Scope_Post');
//
//	// Tracer Textures
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Ger_Tracer_Final');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Ger_Tracer_Flare_Final');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Russ_Tracer_Final');
//	myLevel.AddPrecacheMaterial(Material'Effects_Tex.Weapons.Russ_TracerFlare_Final');
//	myLevel.AddPrecacheMaterial(Material'Effects_tex.Weapons.TrailBlur');
}

//-----------------------------------------------------------------------------
// PrecacheGameStaticMeshes
//-----------------------------------------------------------------------------

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
//	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponPickupSM.TT33_Shell');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponPickupSM.S762_Rifle_MG');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponPickupSM.S9mm_SMG_Pistol');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponPickupSM.S556_Automatic_Rifle');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'WeaponPickupSM.Ammo.Warhead3rd');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tracer');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Russ_Tracer');
//
//	// Gore
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Winter_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tanker_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tunic_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Winter_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Tanker_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Tunic_Arm');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Winter_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tanker_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Ger_Tunic_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Winter_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Tanker_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.Sov_Tunic_Leg');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.PlayerGibbs.Hand_Gibb');
//	myLevel.AddPrecacheStaticMesh(StaticMesh'EffectsSM.PlayerGibbs.Chunk1_Gibb');
}

//-----------------------------------------------------------------------------
// CheckSpawnAreas - Sees if the spawns need to be moved now
//-----------------------------------------------------------------------------

function CheckSpawnAreas()
{
	local int i, j, h, k;
	local ROSpawnArea Best[2];
	local bool bReqsMet, bSomeReqsMet;

	for (i = 0; i < SpawnAreas.Length; i++)
	{
        if (!SpawnAreas[i].bEnabled)
		{
            continue;
		}

		if (SpawnAreas[i].bAxisSpawn && (Best[AXIS_TEAM_INDEX] == None || SpawnAreas[i].AxisPrecedence > Best[AXIS_TEAM_INDEX].AxisPrecedence))
		{
			bReqsMet = true;
			bSomeReqsMet = false;

			for (j = 0; j < SpawnAreas[i].AxisRequiredObjectives.Length; j++)
			{
                if (Objectives[SpawnAreas[i].AxisRequiredObjectives[j]].ObjState != OBJ_Axis)
				{
					bReqsMet = false;
					break;
				}
			}

            // Added in conjunction with TeamMustLoseAllRequired enum in SpawnAreas
            // Allows Mappers to force all objectives to be lost/won before moving spawns
            // Instead of just one - Ramm
			for (h = 0; h < SpawnAreas[i].AxisRequiredObjectives.Length; h++)
			{
                if (Objectives[SpawnAreas[i].AxisRequiredObjectives[h]].ObjState == OBJ_Axis )
				{
					bSomeReqsMet = true;
					break;
				}
			}

            // Added in conjunction with bIncludeNeutralObjectives in SpawnAreas
            // allows mappers to have spawns be used when objectives are neutral, not just captured
            if( SpawnAreas[i].bIncludeNeutralObjectives )
            {
    			for (k = 0; k < SpawnAreas[i].NeutralRequiredObjectives.Length; k++)
    			{
                    if (Objectives[SpawnAreas[i].NeutralRequiredObjectives[k]].ObjState == OBJ_Neutral )
    				{
    					bSomeReqsMet = true;
    					break;
    				}
    			}
            }

			if (bReqsMet)
			{
				Best[AXIS_TEAM_INDEX] = SpawnAreas[i];
			}
			else if ( bSomeReqsMet && SpawnAreas[i].TeamMustLoseAllRequired == SPN_Axis )
			{
			    Best[AXIS_TEAM_INDEX] = SpawnAreas[i];
			}
		}

		if (SpawnAreas[i].bAlliesSpawn && (Best[ALLIES_TEAM_INDEX] == None || SpawnAreas[i].AlliesPrecedence > Best[ALLIES_TEAM_INDEX].AlliesPrecedence))
		{
			bReqsMet = true;
			bSomeReqsMet = false;

			for (j = 0; j < SpawnAreas[i].AlliesRequiredObjectives.Length; j++)
			{
				if (Objectives[SpawnAreas[i].AlliesRequiredObjectives[j]].ObjState != OBJ_Allies)
				{
					bReqsMet = false;
					break;
				}
			}

            // Added in conjunction with TeamMustLoseAllRequired enum in SpawnAreas
            // Allows Mappers to force all objectives to be lost/won before moving spawns
            // Instead of just one - Ramm
			for (h = 0; h < SpawnAreas[i].AlliesRequiredObjectives.Length; h++)
			{
                if (Objectives[SpawnAreas[i].AlliesRequiredObjectives[h]].ObjState == OBJ_Allies)
				{
					bSomeReqsMet = true;
					break;
					//log("Setting Allied  bSomeReqsMet to true");
				}
			}

            // Added in conjunction with bIncludeNeutralObjectives in SpawnAreas
            // allows mappers to have spawns be used when objectives are neutral, not just captured
            if( SpawnAreas[i].bIncludeNeutralObjectives )
            {
    			for (k = 0; k < SpawnAreas[i].NeutralRequiredObjectives.Length; k++)
    			{
                    if (Objectives[SpawnAreas[i].NeutralRequiredObjectives[k]].ObjState == OBJ_Neutral )
    				{
    					bSomeReqsMet = true;
    					break;
    				}
    			}
            }

			if (bReqsMet)
			{
				Best[ALLIES_TEAM_INDEX] = SpawnAreas[i];
			}
			else if ( bSomeReqsMet && SpawnAreas[i].TeamMustLoseAllRequired == SPN_Allies )
			{
			    Best[ALLIES_TEAM_INDEX] = SpawnAreas[i];
			}
		}
	}

	CurrentSpawnArea[AXIS_TEAM_INDEX] = Best[AXIS_TEAM_INDEX];
	CurrentSpawnArea[ALLIES_TEAM_INDEX] = Best[ALLIES_TEAM_INDEX];

	if (CurrentSpawnArea[AXIS_TEAM_INDEX] == None)
		log("ROTeamGame: No valid Axis spawn area found!");

	if (CurrentSpawnArea[ALLIES_TEAM_INDEX] == None)
		log("ROTeamGame: No valid Allied spawn area found!");
}

function CheckTankCrewSpawnAreas()
{
	local int i, j, h, k;
	local ROSpawnArea Best[2];
	local bool bReqsMet, bSomeReqsMet;

	for (i = 0; i < TankCrewSpawnAreas.Length; i++)
	{
        if (!TankCrewSpawnAreas[i].bEnabled)
		{
            continue;
		}

		if (TankCrewSpawnAreas[i].bAxisSpawn && (Best[AXIS_TEAM_INDEX] == None || TankCrewSpawnAreas[i].AxisPrecedence > Best[AXIS_TEAM_INDEX].AxisPrecedence))
		{
			bReqsMet = true;
			bSomeReqsMet = false;

			for (j = 0; j < TankCrewSpawnAreas[i].AxisRequiredObjectives.Length; j++)
			{
                if (Objectives[TankCrewSpawnAreas[i].AxisRequiredObjectives[j]].ObjState != OBJ_Axis)
				{
					bReqsMet = false;
					break;
				}
			}

            // Added in conjunction with TeamMustLoseAllRequired enum in SpawnAreas
            // Allows Mappers to force all objectives to be lost/won before moving spawns
            // Instead of just one - Ramm
			for (h = 0; h < TankCrewSpawnAreas[i].AxisRequiredObjectives.Length; h++)
			{
                if (Objectives[TankCrewSpawnAreas[i].AxisRequiredObjectives[h]].ObjState == OBJ_Axis )
				{
					bSomeReqsMet = true;
					break;
				}
			}

            // Added in conjunction with bIncludeNeutralObjectives in SpawnAreas
            // allows mappers to have spawns be used when objectives are neutral, not just captured
            if( TankCrewSpawnAreas[i].bIncludeNeutralObjectives )
            {
    			for (k = 0; k < TankCrewSpawnAreas[i].NeutralRequiredObjectives.Length; k++)
    			{
                    if (Objectives[TankCrewSpawnAreas[i].NeutralRequiredObjectives[k]].ObjState == OBJ_Neutral )
    				{
    					bSomeReqsMet = true;
    					break;
    				}
    			}
            }

			if (bReqsMet)
			{
				Best[AXIS_TEAM_INDEX] = TankCrewSpawnAreas[i];
			}
			else if ( bSomeReqsMet && TankCrewSpawnAreas[i].TeamMustLoseAllRequired == SPN_Axis )
			{
			    Best[AXIS_TEAM_INDEX] = TankCrewSpawnAreas[i];
			}
		}

		if (TankCrewSpawnAreas[i].bAlliesSpawn && (Best[ALLIES_TEAM_INDEX] == None || TankCrewSpawnAreas[i].AlliesPrecedence > Best[ALLIES_TEAM_INDEX].AlliesPrecedence))
		{
			bReqsMet = true;
			bSomeReqsMet = false;

			for (j = 0; j < TankCrewSpawnAreas[i].AlliesRequiredObjectives.Length; j++)
			{
				if (Objectives[TankCrewSpawnAreas[i].AlliesRequiredObjectives[j]].ObjState != OBJ_Allies)
				{
					bReqsMet = false;
					break;
				}
			}

            // Added in conjunction with TeamMustLoseAllRequired enum in SpawnAreas
            // Allows Mappers to force all objectives to be lost/won before moving spawns
            // Instead of just one - Ramm
			for (h = 0; h < TankCrewSpawnAreas[i].AlliesRequiredObjectives.Length; h++)
			{
                if (Objectives[TankCrewSpawnAreas[i].AlliesRequiredObjectives[h]].ObjState == OBJ_Allies)
				{
					bSomeReqsMet = true;
					break;
					//log("Setting Allied  bSomeReqsMet to true");
				}
			}

            // Added in conjunction with bIncludeNeutralObjectives in SpawnAreas
            // allows mappers to have spawns be used when objectives are neutral, not just captured
            if( TankCrewSpawnAreas[i].bIncludeNeutralObjectives )
            {
    			for (k = 0; k < TankCrewSpawnAreas[i].NeutralRequiredObjectives.Length; k++)
    			{
                    if (Objectives[TankCrewSpawnAreas[i].NeutralRequiredObjectives[k]].ObjState == OBJ_Neutral )
    				{
    					bSomeReqsMet = true;
    					break;
    				}
    			}
            }

			if (bReqsMet)
			{
				Best[ALLIES_TEAM_INDEX] = TankCrewSpawnAreas[i];
			}
			else if ( bSomeReqsMet && TankCrewSpawnAreas[i].TeamMustLoseAllRequired == SPN_Allies )
			{
			    Best[ALLIES_TEAM_INDEX] = TankCrewSpawnAreas[i];
			}
		}
	}

	CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX] = Best[AXIS_TEAM_INDEX];
	CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX] = Best[ALLIES_TEAM_INDEX];
}

// Will turn on/off vehicle factories based on the status of the spawn areas.
// Must be called after  CheckTankCrewSpawnAreas and CheckSpawnAreas
function CheckVehicleFactories()
{
	local ROVehicleFactory VehFact;

    // Activate any vehicle factories that are actived based on spawn areas
    foreach AllActors(class'ROVehicleFactory', VehFact)
    {
     	if( VehFact.bUsesSpawnAreas )
     	{
			if( class<ROVehicle>(VehFact.VehicleClass).default.VehicleTeam == AXIS_TEAM_INDEX )
	     	{
	     		if((CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX] != none && CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX].Tag == VehFact.Tag ) ||
				 	(CurrentSpawnArea[AXIS_TEAM_INDEX] != none && CurrentSpawnArea[AXIS_TEAM_INDEX].Tag == VehFact.Tag))
				{
					 VehFact.ActivatedBySpawn(AXIS_TEAM_INDEX);
				}
				else
				{
					VehFact.Deactivate();
				}
	     	}

	     	if( class<ROVehicle>(VehFact.VehicleClass).default.VehicleTeam == ALLIES_TEAM_INDEX )
	     	{
	     		if((CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX] != none && CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX].Tag == VehFact.Tag ) ||
				 	(CurrentSpawnArea[ALLIES_TEAM_INDEX] != none && CurrentSpawnArea[ALLIES_TEAM_INDEX].Tag == VehFact.Tag))
				{
					 VehFact.ActivatedBySpawn(ALLIES_TEAM_INDEX);
				}
				else
				{
					VehFact.Deactivate();
				}
	     	}
     	}
    }
}

function CheckResupplyVolumes()
{
	local ROGameReplicationInfo ROGRI;
	local int i;

    // Activate any vehicle factories that are actived based on spawn areas
    ROGRI = ROGameReplicationInfo(GameReplicationInfo);
    for( i = 0; i < ArrayCount(ResupplyAreas); i++)
    {
    	if( ResupplyAreas[i] == none )
    		continue;

     	if( ResupplyAreas[i].bUsesSpawnAreas )
     	{
			if( ResupplyAreas[i].Team == AXIS_TEAM_INDEX )
	     	{
	     		if( (CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX] != none &&
				 	CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX].Tag == ResupplyAreas[i].Tag) ||
				 	CurrentSpawnArea[AXIS_TEAM_INDEX].Tag == ResupplyAreas[i].Tag)
				{
					 ROGRI.ResupplyAreas[i].bActive = true;
					 ResupplyAreas[i].Activate();
				}
				else
				{
					ROGRI.ResupplyAreas[i].bActive = false;
					ResupplyAreas[i].Deactivate();
				}
	     	}

	     	if( ResupplyAreas[i].Team == ALLIES_TEAM_INDEX )
	     	{
	     		if( (CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX] != none &&
				 	CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX].Tag == ResupplyAreas[i].Tag) ||
				 	CurrentSpawnArea[ALLIES_TEAM_INDEX].Tag == ResupplyAreas[i].Tag)
				{
					 ROGRI.ResupplyAreas[i].bActive = true;
					 ResupplyAreas[i].Activate();
				}
				else
				{
					ROGRI.ResupplyAreas[i].bActive = false;
					ResupplyAreas[i].Deactivate();
				}
	     	}
     	}
     	else
     	{
     		ROGRI.ResupplyAreas[i].bActive = !ResupplyAreas[i].bUsesSpawnAreas;
     		ResupplyAreas[i].Activate();
     	}
    }
}

function CheckMineVolumes()
{
	local int i;

    // Activate any Mine Volumes that are actived based on spawn areas

    for( i = 0; i < MineVolumes.Length; i++)
    {
    	if( MineVolumes[i] == none )
    		continue;

     	if( MineVolumes[i].bUsesSpawnAreas )
     	{
     		if( ((CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX] != none &&
			 	CurrentTankCrewSpawnArea[AXIS_TEAM_INDEX].Tag == MineVolumes[i].Tag) ||
			 	CurrentSpawnArea[AXIS_TEAM_INDEX].Tag == MineVolumes[i].Tag) ||
				( (CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX] != none &&
			 	CurrentTankCrewSpawnArea[ALLIES_TEAM_INDEX].Tag == MineVolumes[i].Tag) ||
			 	CurrentSpawnArea[ALLIES_TEAM_INDEX].Tag == MineVolumes[i].Tag) )
			{
				 MineVolumes[i].Activate();
			}
			else
			{

				MineVolumes[i].Deactivate();
			}
     	}
     	else
     	{
     		MineVolumes[i].Activate();
     	}
    }
}

function NotifyObjectiveManagers()
{
	if( ObjectiveManager != none )
		ObjectiveManager.ObjectiveStateChanged();
}

//-----------------------------------------------------------------------------
// Timer - Manages the time and stuff
//-----------------------------------------------------------------------------

function Timer()
{
	Super.Timer();

	ElapsedTime++;

	if (ElapsedTime % 10 == 0)
	{
	    UpdateSteamUserData();
	}

	if (bGameEnded)
		return;

    GameReplicationInfo.ElapsedTime = ElapsedTime; // + 3;

	if (ElapsedTime % 15 == 0)
		ROGameReplicationInfo(GameReplicationInfo).ElapsedQuarterMinute = ElapsedTime;

	if (TimeLimit > 0)
    {
        GameReplicationInfo.bStopCountDown = false;
        RemainingTime--;
        GameReplicationInfo.RemainingTime = RemainingTime;
        if ( RemainingTime % 60 == 0 )
            GameReplicationInfo.RemainingMinute = RemainingTime;
        if ( RemainingTime <= 0 )
            EndGame(None,"TimeLimit");
    }

	UpdateRoleCounts();
}

//-----------------------------------------------------------------------------
// EndRound - Ends the round in progress (implemented in RoundInPlay state)
//-----------------------------------------------------------------------------

function EndRound(int Winner)
{
}

//-----------------------------------------------------------------------------
// NotifyObjStateChanged - Signal to look for objective victory (implemented in RoundInPlay state)
//-----------------------------------------------------------------------------

function NotifyObjStateChanged()
{
}

//-----------------------------------------------------------------------------
// ResetGame - Handles the admin's Reset command
//-----------------------------------------------------------------------------

exec function ResetGame()
{
    GotoState('ResetGameCountdown');
}

function ResetScores()
{
    local int i;

	RemainingTime = 60 * TimeLimit;
	ElapsedTime = 0;
	GameReplicationInfo.ElapsedTime = 0;
	// Reset this to force a sync of the timing at the beginning of the round
	GameReplicationInfo.ElapsedQuarterMinute = 1;
	RoundCount = 0;
	Teams[AXIS_TEAM_INDEX].Score = 0;
	Teams[ALLIES_TEAM_INDEX].Score = 0;

	for(i = 0; i < GameReplicationInfo.PRIArray.Length; i++)
	{
		if( GameReplicationInfo.PRIArray[i] != none )
		{
            GameReplicationInfo.PRIArray[i].Score = 0;
		}
	}
}

//-----------------------------------------------------------------------------
// Start of Debug Only Functions, make sure you uncomment the 2 variables at the top of this file
//-----------------------------------------------------------------------------
/*
exec function AddPlayers(int i, int Team)
{
    local int NewTeam;
    local ROPlayer NewPlayer;

    bLogInfo = false;

    for ( i = i; i > 0; i-- )
    {
        if ( bLogInfo )
        {
            log("Team0:" @ Teams[0].Size);
            log("Team1:" @ Teams[1].Size);
        }

        //Spawn a new Player Controller
        NewPlayer = ROPlayer(Spawn(PlayerControllerClass));

        //Add the Player to the "Best Fit" team
        NewTeam = PickTeam(Team, NewPlayer);
        Teams[NewTeam].AddToTeam(NewPlayer);
        PlayerList[NewTeam * 64 + PlayerCount[NewTeam]++] = NewPlayer;

        //Set the players name
        NewPlayer.SetName("Player" $ NewTeam * 64 + PlayerCount[NewTeam]);

        //Set the players role(Sets role to rifleman on Danzig...must be changed to work on other maps correctly)
        ChangeRole(NewPlayer, 2);

        //Set the players weapons
        ChangeWeapons(NewPlayer, 0, 0, 0);

        //Add the player to the vote list
        if( VotingHandler != None )
    		VotingHandler.PlayerJoin(NewPlayer);

        //Spawn the physical player
        RestartPlayer(NewPlayer);

        //We added another player
        NumPlayers++;

        if ( bLogInfo )
            log("Attempted to join Team" $ Team @ "joined Team" $ NewTeam);
    }
}

exec function RemovePlayers(int i, int Team)
{
    local int RandNum;

    for ( i = i; i > 0; i-- )
    {
        if ( bLogInfo )
        {
            log("Team0:" @ Teams[0].Size);
            log("Team1:" @ Teams[1].Size);
            log("Removing player from Team" $ Team);
        }

        //Select a random player to remove
        RandNum = Team * 64 + rand(PlayerCount[Team]) + 1;

        //Make sure this player exists
        if( PlayerList[RandNum] != none )
        {
            //Destroy the player's pawn object
    		if (PlayerList[RandNum].Pawn != none && Vehicle(PlayerList[RandNum].Pawn) == none )
    			PlayerList[RandNum].Pawn.Destroy();

            //Destroy the player's controller object
            PlayerList[RandNum].Destroy();

            //Decrement the player count for this team
            PlayerCount[Team]--;
        }
    }
}

exec function KillPlayer(int Team)
{
    local ROPlayer DeadMan;

    DeadMan = PlayerList[Team * 64 + rand(PlayerCount[Team])];
    DeadMan.Pawn.Suicide();
}

exec function SendVote(int Team, int Player, int MapIndex)
{
    local ROPlayer Voter;

    Voter = PlayerList[Team * 64 + Player];
    VotingReplicationInfo(Voter.VoteReplicationInfo).SendMapVote(MapIndex, 0);
}
*/
//-----------------------------------------------------------------------------
// End of Debug Only Functions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// SendReinforcementMessage - Tell players when reinforcements are low
//-----------------------------------------------------------------------------

function SendReinforcementMessage(int Team, int Num)
{
	local Controller P;

	for (P = Level.ControllerList; P != None; P = P.NextController)
	{
		if (PlayerController(P) != None && P.PlayerReplicationInfo.Team != None
			&& P.PlayerReplicationInfo.Team.TeamIndex == Team)
			PlayerController(P).ReceiveLocalizedMessage(class'ROReinforcementMsg', Num);
	}
}


/* only allow pickups if they are in the pawns loadout
*/
// Overload to prevent pick up ammo if weapon not in inventory
function bool PickupQuery(Pawn Other, Pickup item)
{
	local byte bAllowPickup;
	local inventory Inv;
	local bool bWeaponFound;

    // check to see if pickup is ammunition
	if(ROAmmoPickup(item) != none && !ROAmmoPickup(item).bAmmoPickupIsWeapon)
	{
	   bWeaponFound = false;
	   // do not add ammo if no weapon
	   if ( Other.Inventory == None )
		   return false;

	   // check if Other has a primary weapon
	   if( Other != none && Other.Inventory != none )
	   {
		  for ( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
		  {
            if ( Inv != none && Weapon(Inv) != None )
            {
                if( item.class == Weapon(Inv).AmmoPickupClass(0))
                {
                   bWeaponFound = true;
                }
             }
          }
       }


       // if ammo and no matching weapon return false
       if(!bWeaponFound)
       {
          return false;
       }
    }



	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( (ROPawn(Other) != None) && !ROPawn(Other).IsInLoadout(item.inventorytype) )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

// Empty. Implemented in RoundInPlay, since that's the only place it's actually useful.
function NotifyPlayersOfMapInfoChange(int team_id, optional Controller sender, optional bool bForce);

//=============================================================================
// States
//=============================================================================

//-----------------------------------------------------------------------------
// PreStart - Wait period before play begins
//-----------------------------------------------------------------------------

auto state PreStart
{
	function RestartPlayer( Controller aPlayer )
    {
       //log("ROTeamGame::RestartPlayer, [PreStart] player = "$aPlayer);
    }

	function bool AddBot(optional string botName)
	{
		if ( Level.NetMode == NM_Standalone )
			InitialBots++;
		if ( botName != "" )
			PreLoadNamedBot(botName);
		else
			PreLoadBot();
		return true;
	}

	function Timer()
	{
		local bool bReady,bFoundAController;
        local Controller P;

		Global.Timer();

		if (NumPlayers == 0)
			bWaitForNetPlayers = true;

        bReady = true;
        bFoundAController = false;

        // new Clan Match code requested by admins. Will wait til everyone is ready to start the round
        if ( bPlayersMustBeReady && Level.NetMode != NM_Standalone )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
            {
				if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.bIsPlayer && ROPlayer(P) != none)
				{
                    bFoundAController=true;
				    if (P.PlayerReplicationInfo.bWaitingPlayer)
				    {
					 	if( ROPlayer(P).CanRestartPlayer() )
					 	{
					 		P.PlayerReplicationInfo.bReadyToPlay = true;
					 	}
					 	else
					 	{
							bReady = false;
						}
					}
                }
            }
			if(!bFoundAController || !bReady)
				return;
        }

		// New Clan Match code requested by admins. Causes the game to wait for all the players - Ramm
        if ( bWaitForNetPlayers && (Level.NetMode != NM_Standalone) )
        {
             if ( NumPlayers >= MinNetPlayers )
                ElapsedTime++;
            else
                ElapsedTime = 0;
            if ( (MaxPlayersOverride > 0 && NumPlayers == MaxPlayersOverride) || (NumPlayers == MaxPlayers) || (ElapsedTime > NetWait) )
            {
                bWaitForNetPlayers = false;
				if ((ElapsedTime > RoundStartTime + PreStartTime) && (LevelInfo != None))
				{
					bWaitForNetPlayers = false;
					StartMatch();
				}
            }
        }
  		// end experiment
		else if ((ElapsedTime > RoundStartTime + PreStartTime) && (LevelInfo != None))
		{
			bWaitForNetPlayers = false;
			StartMatch();
		}
	}

	function BeginState()
	{
		local PlayerReplicationInfo PRI;

		bWaitingToStartMatch = true;
		StartupStage = 0;
		ElapsedTime = 0;
		GameReplicationInfo.ElapsedTime = ElapsedTime;

		ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
			PRI.StartTime = 0;

		RoundStartTime = ElapsedTime;
		ROGameReplicationInfo(GameReplicationInfo).RoundStartTime = RoundStartTime;
	}
}

//-----------------------------------------------------------------------------
// RoundInPlay - A round is live and in progress
//-----------------------------------------------------------------------------

state RoundInPlay
{
	function NotifyObjStateChanged()
	{
		local int i, Num[2], NumReq[2], NumObj, NumObjReq;

		for (i = 0; i < ArrayCount(Objectives); i++)
		{
			if (Objectives[i] == None)
				break;
			else if (Objectives[i].ObjState == OBJ_Axis)
			{
				Num[AXIS_TEAM_INDEX]++;

				if (Objectives[i].bRequired)
					NumReq[AXIS_TEAM_INDEX]++;
			}
			else if (Objectives[i].ObjState == OBJ_Allies)
			{
				Num[ALLIES_TEAM_INDEX]++;

				if (Objectives[i].bRequired)
					NumReq[ALLIES_TEAM_INDEX]++;
			}

			if (Objectives[i].bRequired)
				NumObjReq++;

			NumObj++;
		}

		if (LevelInfo.NumObjectiveWin == 0)
		{
			if (Num[AXIS_TEAM_INDEX] == NumObj && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Allies))
				EndRound(AXIS_TEAM_INDEX);
			else if (Num[ALLIES_TEAM_INDEX] == NumObj && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Axis))
				EndRound(ALLIES_TEAM_INDEX);
            else
            {
    			// Check if we're down to last objective..
                if (Num[AXIS_TEAM_INDEX] == NumObj - 1 && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Allies))
    			    BroadcastLastObjectiveMessage(AXIS_TEAM_INDEX);
    			if (Num[ALLIES_TEAM_INDEX] == NumObj - 1 && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Axis))
    			    BroadcastLastObjectiveMessage(ALLIES_TEAM_INDEX);
    		}
		}
		else if (Num[AXIS_TEAM_INDEX] >= LevelInfo.NumObjectiveWin && NumReq[AXIS_TEAM_INDEX] == NumObjReq && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Allies))
		{
			EndRound(AXIS_TEAM_INDEX);
		}
		else if (Num[ALLIES_TEAM_INDEX] >= LevelInfo.NumObjectiveWin && NumReq[ALLIES_TEAM_INDEX] == NumObjReq && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Axis))
		{
			EndRound(ALLIES_TEAM_INDEX);
		}
        else
        {
    		// Check if we're down to last objective..
    		      // One non-required objective missing
            if (Num[AXIS_TEAM_INDEX] == LevelInfo.NumObjectiveWin - 1 && NumReq[AXIS_TEAM_INDEX] == NumObjReq && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Allies))
    		    BroadcastLastObjectiveMessage(AXIS_TEAM_INDEX);
    		      // One required objective missing
    		else if (Num[AXIS_TEAM_INDEX] >= LevelInfo.NumObjectiveWin - 1 && NumReq[AXIS_TEAM_INDEX] == NumObjReq - 1 && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Allies))
    		    BroadcastLastObjectiveMessage(AXIS_TEAM_INDEX);

    		if (Num[ALLIES_TEAM_INDEX] == LevelInfo.NumObjectiveWin - 1 && NumReq[ALLIES_TEAM_INDEX] == NumObjReq && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Axis))
    		    BroadcastLastObjectiveMessage(ALLIES_TEAM_INDEX);
    		else if (Num[ALLIES_TEAM_INDEX] >= LevelInfo.NumObjectiveWin - 1 && NumReq[ALLIES_TEAM_INDEX] == NumObjReq - 1 && (LevelInfo.DefendingSide == SIDE_None || LevelInfo.DefendingSide == SIDE_Axis))
    		    BroadcastLastObjectiveMessage(ALLIES_TEAM_INDEX);
        }

		if (LevelInfo.bUseSpawnAreas)
		{
			CheckSpawnAreas();
			CheckTankCrewSpawnAreas();
			CheckVehicleFactories();
			CheckResupplyVolumes();
			CheckMineVolumes();
		}

		// Notify the objective managers
		NotifyObjectiveManagers();
	}

	function EndRound(int Winner)
	{
		switch (Winner)
		{
			case AXIS_TEAM_INDEX:
				Teams[AXIS_TEAM_INDEX].Score += 1.0;
				BroadcastLocalizedMessage(class'RORoundOverMsg', 0);
				TeamScoreEvent(AXIS_TEAM_INDEX, 1, "team_victory");
				break;
			case ALLIES_TEAM_INDEX:
				Teams[ALLIES_TEAM_INDEX].Score += 1.0;
				BroadcastLocalizedMessage(class'RORoundOverMsg', 1);
				TeamScoreEvent(ALLIES_TEAM_INDEX, 1, "team_victory");
				break;
			default:
				BroadcastLocalizedMessage(class'RORoundOverMsg', 2);
				break;
		}

		RoundCount++;

		if (RoundLimit != 0 && RoundCount >= RoundLimit)
			EndGame(None, "RoundLimit");
		else if (WinLimit != 0 && (Teams[AXIS_TEAM_INDEX].Score >= WinLimit || Teams[ALLIES_TEAM_INDEX].Score >= WinLimit))
			EndGame(None, "WinLimit");
		else
			GotoState('RoundOver');
	}

	function Timer()
	{
		local int i, ReinforceInt, ArtilleryStrikeInt;
		local Controller P;
		local ROGameReplicationInfo GRI;

		Global.Timer();

        GRI = ROGameReplicationInfo(GameReplicationInfo);

		if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;

		// Go through both teams and spawn reinforcements if necessary
		for (i = 0; i < 2; i++)
		{
			if (i == ALLIES_TEAM_INDEX)
				ReinforceInt = LevelInfo.Allies.ReinforcementInterval;
			else
				ReinforceInt = LevelInfo.Axis.ReinforcementInterval;

			if (!SpawnLimitReached(i) && ElapsedTime > LastReinforcementTime[i] + ReinforceInt)
			{
				for (P = Level.ControllerList; P != None; P = P.NextController)
				{
					if (!P.bIsPlayer || P.Pawn != None || P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.Team == None || P.PlayerReplicationInfo.Team.TeamIndex != i)
						continue;

					if (ROPlayer(P) != None && ROPlayer(P).CanRestartPlayer())
						RestartPlayer(P);
					else if (ROBot(P) != None && ROPlayerReplicationInfo(P.PlayerReplicationInfo).RoleInfo != None)
						RestartPlayer(P);

					// If spawn limit has now been reached, send a message out
					if (SpawnLimitReached(i))
					{
						SendReinforcementMessage(i, 1);
						break;
					}
				}

				LastReinforcementTime[i] = ElapsedTime;
				ROGameReplicationInfo(GameReplicationInfo).LastReinforcementTime[i] = LastReinforcementTime[i];
			}
		}

		// Go through both teams and update artillery availability
		for (i = 0; i < 2; i++)
		{
			ArtilleryStrikeInt = LevelInfo.GetStrikeInterval(i);

			if ((GRI.TotalStrikes[i] < GRI.ArtilleryStrikeLimit[i]) && ElapsedTime > GRI.LastArtyStrikeTime[i] + ArtilleryStrikeInt)
			{
                	GRI.bArtilleryAvailable[i] = 1;
			}
			else
			{
			    	GRI.bArtilleryAvailable[i] = 0;
			}
		}

		// If round time is up, the defending team wins, if any
		if (ElapsedTime > RoundStartTime + RoundDuration)
		{
			if (LevelInfo.DefendingSide == SIDE_Axis)
				EndRound(AXIS_TEAM_INDEX);
			else if (LevelInfo.DefendingSide == SIDE_Allies)
				EndRound(ALLIES_TEAM_INDEX);
			else
				ChooseWinner();
		}
	}

	function BeginState()
	{
		local Controller P, NextC;
		local Actor A;
		local int i;
		local ROGameReplicationInfo GRI;
		local ROVehicleFactory ROV;

		// Reset all round properties
		RoundStartTime = ElapsedTime;
		GRI = ROGameReplicationInfo(GameReplicationInfo);
		GRI.RoundStartTime = RoundStartTime;

		SpawnCount[AXIS_TEAM_INDEX] = 0;
		SpawnCount[ALLIES_TEAM_INDEX] = 0;

		LastReinforcementTime[AXIS_TEAM_INDEX] = ElapsedTime;
		LastReinforcementTime[ALLIES_TEAM_INDEX] = ElapsedTime;
		GRI.LastReinforcementTime[AXIS_TEAM_INDEX] = LastReinforcementTime[AXIS_TEAM_INDEX];
		GRI.LastReinforcementTime[ALLIES_TEAM_INDEX] = LastReinforcementTime[ALLIES_TEAM_INDEX];

        // Arty
		GRI.bArtilleryAvailable[AXIS_TEAM_INDEX] = 0;
		GRI.bArtilleryAvailable[ALLIES_TEAM_INDEX] = 0;
		GRI.LastArtyStrikeTime[AXIS_TEAM_INDEX] = ElapsedTime - LevelInfo.GetStrikeInterval(AXIS_TEAM_INDEX);
		GRI.LastArtyStrikeTime[ALLIES_TEAM_INDEX] = ElapsedTime - LevelInfo.GetStrikeInterval(ALLIES_TEAM_INDEX);
		GRI.TotalStrikes[AXIS_TEAM_INDEX] = 0;
		GRI.TotalStrikes[ALLIES_TEAM_INDEX] = 0;
		for (i = 0; i < ArrayCount(GRI.AxisRallyPoints); i++)
		{
			GRI.AlliedRallyPoints[i].OfficerPRI = none;
			GRI.AlliedRallyPoints[i].RallyPointLocation = vect(0,0,0);
			GRI.AxisRallyPoints[i].OfficerPRI = none;
			GRI.AxisRallyPoints[i].RallyPointLocation = vect(0,0,0);
		}

		// Clear help requests
		for (i = 0; i < ArrayCount(GRI.AxisHelpRequests); i++)
		{
			GRI.AlliedHelpRequests[i].OfficerPRI = none;
			GRI.AlliedHelpRequests[i].requestType = 255;
			GRI.AxisHelpRequests[i].OfficerPRI = none;
			GRI.AxisHelpRequests[i].requestType = 255;
		}

		// Just in case the limit is set to a ridiculously low value, handle it right
		if (!SpawnLimitReached(AXIS_TEAM_INDEX))
		{
			GRI.bReinforcementsComing[AXIS_TEAM_INDEX] = 1;
			GRI.SpawnCount[AXIS_TEAM_INDEX] = 100;
		}
		if (!SpawnLimitReached(ALLIES_TEAM_INDEX))
		{
			GRI.bReinforcementsComing[ALLIES_TEAM_INDEX] = 1;
			GRI.SpawnCount[ALLIES_TEAM_INDEX] = 100;
		}

		// Reset all controllers
		P = Level.ControllerList;
		while ( P != None )
		{
			NextC = P.NextController;

			if ( P.PlayerReplicationInfo == None || !P.PlayerReplicationInfo.bOnlySpectator )
			{
				if ( PlayerController(P) != None )
					PlayerController(P).ClientReset();
				P.Reset();
			}

			P = NextC;
		}

		// Reset ALL actors (except controllers and ROVehicleFactorys)
		foreach AllActors(class'Actor', A)
		{
			if (!A.IsA('Controller') && !A.IsA('ROVehicleFactory'))
				A.Reset();
		}

		// Reset ALL ROVehicleFactorys - must reset these after vehicles, otherwise the vehicles that get spawned by the vehicle factories get destroyed instantly as they are reset
		foreach AllActors(class'ROVehicleFactory', ROV)
		{
			ROV.Reset();
		}

		// Use the starting spawns
		if (LevelInfo.bUseSpawnAreas)
		{
			CheckSpawnAreas();
			CheckTankCrewSpawnAreas();
			CheckVehicleFactories();
			CheckResupplyVolumes();
			CheckMineVolumes();
		}

		// Respawn all players
		for (P = Level.ControllerList; P != None; P = P.NextController)
		{
			if (!P.bIsPlayer || P.PlayerReplicationInfo.Team == None)
				continue;

			if (ROPlayer(P) != None && ROPlayer(P).CanRestartPlayer())
				RestartPlayer(P);
			else if (ROBot(P) != None && ROPlayerReplicationInfo(P.PlayerReplicationInfo).RoleInfo != None)
				RestartPlayer(P);
		}

		// Make the bots find objectives when the round starts
		FindNewObjectives(None);

		// Notify players that the map has been updated
		NotifyPlayersOfMapInfoChange(NEUTRAL_TEAM_INDEX, none, true);
	}

    // Go through all controllers and notify them that the status map's
    // information has changed
	function NotifyPlayersOfMapInfoChange(int team_id, optional Controller sender, optional bool bForce)
    {
        local Controller C;
        for (C = Level.ControllerList; C != None; C = C.NextController)
	    {
    		if (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team != None &&
                (C.PlayerReplicationInfo.Team.TeamIndex == team_id || team_id == NEUTRAL_TEAM_INDEX) )
    		{
    			// Don't notify bots & don't notify whoever it was who initated the event
    			if (ROPlayer(C) != none && C != sender)
    			{
    		        // Don't notify dead players & spectators
    		        if ((C.GetStateName() != 'Dead' &&
                         C.GetStateName() != 'DeadSpectating' &&
                         C.GetStateName() != 'Spectating') ||
                        bForce)
                    {
                        ROPlayer(C).NotifyOfMapInfoChange();
                    }
    			}
    		}
	    }
    }
}

//-----------------------------------------------------------------------------
// If neither side has taken all objectives, then choose a winner based
// on who has the most objectives, kills, etc. Should only be called
// to Choose a winner for maps that aren't attack/defend style
//-----------------------------------------------------------------------------
function ChooseWinner()
{
	local Controller C;
	local int i, Num[2], NumReq[2], AxisScore, AlliedScore;
	local float AxisReinforcementsPercent, AlliedReinforcementsPercent;

	for (i = 0; i < ArrayCount(Objectives); i++)
	{
		if (Objectives[i] == None)
			break;
		else if (Objectives[i].ObjState == OBJ_Axis)
		{
			Num[AXIS_TEAM_INDEX]++;

			if (Objectives[i].bRequired)
				NumReq[AXIS_TEAM_INDEX]++;
		}
		else if (Objectives[i].ObjState == OBJ_Allies)
		{
			Num[ALLIES_TEAM_INDEX]++;

			if (Objectives[i].bRequired)
				NumReq[ALLIES_TEAM_INDEX]++;
		}
	}

	if( NumReq[AXIS_TEAM_INDEX] != NumReq[ALLIES_TEAM_INDEX] )
	{
		if( NumReq[AXIS_TEAM_INDEX] > NumReq[ALLIES_TEAM_INDEX] )
		{
		 	EndRound(AXIS_TEAM_INDEX);
		 	return;
		}
		else
		{
		  	EndRound(ALLIES_TEAM_INDEX);
		  	return;
		}
	}
	else if( Num[AXIS_TEAM_INDEX] != Num[ALLIES_TEAM_INDEX] )
	{
		if( Num[AXIS_TEAM_INDEX] > Num[ALLIES_TEAM_INDEX] )
		{
		 	EndRound(AXIS_TEAM_INDEX);
		 	return;
		}
		else
		{
		  	EndRound(ALLIES_TEAM_INDEX);
		  	return;
		}
	}

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team != None )
		{
			if (C.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
			{
				AxisScore += C.PlayerReplicationInfo.Score;
			}
			else if(C.PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX)
			{
			 	AlliedScore += C.PlayerReplicationInfo.Score;
			}
		}
	}

	if( AxisScore != AlliedScore )
	{
		if( AxisScore > AlliedScore )
		{
		 	EndRound(AXIS_TEAM_INDEX);
		 	return;
		}
		else
		{
		  	EndRound(ALLIES_TEAM_INDEX);
		  	return;
		}
	}

    AxisReinforcementsPercent = (1 - (float(SpawnCount[AXIS_TEAM_INDEX]) / LevelInfo.Axis.SpawnLimit)) * 100;
    AlliedReinforcementsPercent = (1 - (float(SpawnCount[ALLIES_TEAM_INDEX]) / LevelInfo.Allies.SpawnLimit)) * 100;

	if( AxisReinforcementsPercent != AlliedReinforcementsPercent )
	{
		if( AxisReinforcementsPercent > AlliedReinforcementsPercent )
		{
		 	EndRound(AXIS_TEAM_INDEX);
		 	return;
		}
		else
		{
		  	EndRound(ALLIES_TEAM_INDEX);
		  	return;
		}
	}

	// If by some crazy turn of events everything above this is still equal, then STILL do a "No Decisive Victory"
	EndRound(2);
}

state ResetGameCountdown
{
	function Timer()
	{
		Global.Timer();

		if (ElapsedTime > RoundStartTime - 1.0) //The -1.0 gets rid of "The game will restart in 0 seconds"
		{
		    Level.Game.BroadcastLocalized(none, class'ROResetGameMsg', 11);
		    ResetScores();
			GotoState('RoundInPlay');
		}
		else
		    Level.Game.BroadcastLocalized(none, class'ROResetGameMsg', RoundStartTime - ElapsedTime);
	}

	function BeginState()
	{
        local ROArtillerySpawner RAS;

		RoundStartTime = ElapsedTime + 10;

		ROGameReplicationInfo(GameReplicationInfo).bReinforcementsComing[AXIS_TEAM_INDEX] = 0;
		ROGameReplicationInfo(GameReplicationInfo).bReinforcementsComing[ALLIES_TEAM_INDEX] = 0;

        // Destroy any artillery spawners so they don't keep calling airstrikes.
	    foreach DynamicActors(class'ROArtillerySpawner', RAS)
		{
			RAS.Destroy();
		}

        Level.Game.BroadcastLocalized(none, class'ROResetGameMsg', 10);
	}
}

//-----------------------------------------------------------------------------
// RoundOver - Wait period before a new round begins
//-----------------------------------------------------------------------------

state RoundOver
{
	function Timer()
	{
		Global.Timer();

		if (ElapsedTime > RoundStartTime + 5)
			GotoState('RoundInPlay');
	}

	function BeginState()
	{
        local ROArtillerySpawner RAS;

		RoundStartTime = ElapsedTime;
		ROGameReplicationInfo(GameReplicationInfo).bReinforcementsComing[AXIS_TEAM_INDEX] = 0;
		ROGameReplicationInfo(GameReplicationInfo).bReinforcementsComing[ALLIES_TEAM_INDEX] = 0;
		//ROGameReplicationInfo(GameReplicationInfo).SpawnCount[AXIS_TEAM_INDEX] = 0;
		//ROGameReplicationInfo(GameReplicationInfo).SpawnCount[AXIS_TEAM_INDEX] = 0;
		//ROGameReplicationInfo(GameReplicationInfo).RoundStartTime = RoundStartTime;

        // Destroy any artillery spawners so they don't keep calling airstrikes.
	    foreach DynamicActors(class'ROArtillerySpawner', RAS)
		{
			RAS.Destroy();
		}

	}
}

//-----------------------------------------------------------------------------
// MatchOver - The game is over
//-----------------------------------------------------------------------------

state MatchOver
{
	function RestartPlayer( Controller aPlayer ) {}
	function ScoreKill(Controller Killer, Controller Other) {}
	function ScoreMGResupply( Controller Dropper, Controller Gunner ) {}
	function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
	{
		return 0;
	}

	function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
	{
		return false;
	}

	function Timer()
	{
		local Controller C;

		Global.Timer();

		if ( !bGameRestarted && (Level.TimeSeconds > EndTime + RestartWait) )
			RestartGame();

		if ( EndGameFocus != None )
		{
			EndGameFocus.bAlwaysRelevant = true;
			for ( C = Level.ControllerList; C != None; C = C.NextController )
				if ( PlayerController(C) != None )
					PlayerController(C).ClientSetViewtarget(EndGameFocus);
		}

		 // play end-of-match message for winner/losers (for single and muli-player)
		//EndMessageCounter++;
		//if ( EndMessageCounter == EndMessageWait )
		//	 PlayEndOfMatchMessage();
	}


	function bool NeedPlayers()
	{
		return false;
	}

	function BeginState()
	{
		local Controller C;
		local PlayerController P;

		GameReplicationInfo.bStopCountDown = true;
		if ( CurrentGameProfile != None )
		{
			EndTime = Level.TimeSeconds + SinglePlayerWait;
			for ( c=Level.ControllerList; c!=None; c=c.NextController )
			{
				P = PlayerController(C);
				if ( P != None )
					break;
			}
			P.myHUD.bShowScoreboard=true;
			CurrentGameProfile.RegisterGame(self,P.PlayerReplicationInfo);
			SavePackage(CurrentGameProfile.PackageName);
		}
	}
}

// emh: this is used to parse a loading hint and exclude color tags
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

function ClearSavedRequestsAndRallyPoints(ROPlayer player, bool bKeepRallyPoints)
{
    if (player == none || player.PlayerReplicationInfo == none)
        return;

    if (ROGameReplicationInfo(GameReplicationInfo) != none)
    {
        // Clear rally points & help requests
        ROGameReplicationInfo(GameReplicationInfo).AddHelpRequest(player.PlayerReplicationInfo, 0, -1);
        if (!bKeepRallyPoints)
            ROGameReplicationInfo(GameReplicationInfo).AddRallyPoint(player.PlayerReplicationInfo, vect(0,0,0), true);
    }
}

// Remove any help requests at the specified objective
function RemoveHelpRequestsForObj(int objID)
{
    if (ROGameReplicationInfo(GameReplicationInfo) != none)
	    ROGameReplicationInfo(GameReplicationInfo).RemoveHelpRequestsForObjective(objID);
}

function NotifyLogout(Controller Exiting)
{
    ClearSavedRequestsAndRallyPoints(ROPlayer(Exiting), false);
    super.Destroyed();
}

function BroadcastLastObjectiveMessage(int team_that_is_about_to_win)
{
    BroadcastLocalizedMessage(class'ROLastObjectiveMsg', team_that_is_about_to_win);
}

// modified from GameInfo and DeathMatch versions to allow spectators to become players when game
// has not started yet
function bool AllowBecomeActivePlayer(PlayerController P)
{
    // Removed the  if (!GameReplicationInfo.bMatchHasBegun) check
    if ( (P.PlayerReplicationInfo == None) || bMustJoinBeforeStart || (MaxPlayersOverride > 0 && NumPlayers >= MaxPlayersOverride) ||
	     (NumPlayers >= MaxPlayers) || (MaxLives > 0) || P.IsInState('GameEnded') || P.IsInState('RoundEnded') )
	{
	    P.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}

	if ( (Level.NetMode == NM_Standalone) && (NumBots > InitialBots) )
	{
		RemainingBots--;
		bPlayerBecameActive = true;
	}

	return true;
}

function bool AtCapacity(bool bSpectator)
{
    if ( Level.NetMode == NM_Standalone )
        return false;

    if ( bSpectator )
        return ( (NumSpectators >= MaxSpectators) && ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
    else
        return ( (MaxPlayersOverride > 0 && NumPlayers >= MaxPlayersOverride) || (MaxPlayers > 0 && NumPlayers >= MaxPlayers) );
}

static function string GetPropsExtra(int i)
{
    return default.PropsExtras[i];
}

function int GetNumPlayers()
{
	return Max(NumPlayers, Min(NumPlayers + NumBots, MaxPlayers - 1));
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RoundLimit=3
     PreStartTime=30
     FFDamageLimit=800
     FFKillLimit=3
     FFArtyScale=1.000000
     FFExplosivesScale=5.000000
     MaxTeamDifference=2
     bForgiveFFKillsEnabled=True
     bSpectateAllowViewPoints=True
     bSpectateAllowRoaming=True
     bSpectateAllowDeadRoaming=True
     ROHints(0)="You can see a map of the objectives that need to be captured or defended by pressing %SHOWOBJECTIVES%."
     ROHints(1)="You can 'cook' a Soviet F-1 grenade by pressing the opposite fire button while holding the grenade back."
     ROHints(2)="To capture an objective, you must first enter the objective area. You'll likely need more than one additional teammate to initiate and complete the capture."
     ROHints(3)="Press %PLAYERMENU 2% to change your player role while in-game, %PLAYERMENU% to change your team."
     ROHints(4)="To aim down the sights of your weapon and thus have better precision and accuracy, press the %ROIRONSIGHTS% key."
     ROHints(5)="You receive 10 points for helping to capture an objective."
     ROHints(6)="Crouching and going prone stabilizes your weapon and lowers recoil when firing."
     ROHints(7)="To regenerate stamina, stop and rest for a bit."
     ROHints(8)="You can deploy a Machine Gun on almost any object - press %DEPLOY% when you see the deployment icon appear to deploy it."
     ROHints(9)="When reloading, 'Magazine Heavy' indicates that the magazine you're loading into your weapon is more than half full of ammunition."
     ROHints(10)="You can reload your Machine Gun only when in the deployed state."
     ROHints(11)="Players receive 1 point for resupplying Machine Gunners who need ammo."
     ROHints(12)="The Machine Gun is more effective when fired in short, controllable bursts."
     ROHints(13)="You cannot change the DP 28 barrel, be careful not to overheat!"
     ROHints(14)="When taking an objective, the presence of an officer boosts moral and makes your task easier!"
     ROHints(15)="Machine Gunners should never setup alone, find a comrade to watch your back."
     ROHints(16)="Machine Gunners have a limited field of vision while deployed, so try attacking them from the side."
     FFPunishment=FFP_Kick
     DeathMessageMode=DM_All
     PropsDisplayText(0)="Bots Skill"
     PropsDisplayText(1)="Use Map Rotation"
     PropsDisplayText(2)="Game Speed"
     PropsDisplayText(3)="Max Spectators"
     PropsDisplayText(4)="Max Players"
     PropsDisplayText(5)="Time Limit"
     PropsDisplayText(6)="Allow Behind View"
     PropsDisplayText(7)="1st Person Spectate Only"
     PropsDisplayText(8)="Lock 3rd Person Spectating"
     PropsDisplayText(9)="Allow ViewPoint Spectating"
     PropsDisplayText(10)="Allow Roaming Spectating"
     PropsDisplayText(11)="Allow Dead Roaming"
     PropsDisplayText(12)="Allow Admin Pausing"
     PropsDisplayText(13)="Min Players"
     PropsDisplayText(14)="Bot Mode"
     PropsDisplayText(15)="Delay at End of Game"
     PropsDisplayText(16)="Adjust Skill"
     PropsDisplayText(17)="Win Limit"
     PropsDisplayText(18)="Round Limit"
     PropsDisplayText(19)="Pre-Start Duration"
     PropsDisplayText(20)="Net Wait"
     PropsDisplayText(21)="Min Net Players"
     PropsDisplayText(22)="Players Must Be Ready"
     PropsDisplayText(23)="Friendly Fire Scale"
     PropsDisplayText(24)="FF Artillery Scale"
     PropsDisplayText(25)="FF Explosives Scale"
     PropsDisplayText(26)="Bots Balance Teams"
     PropsDisplayText(27)="Players Balance Teams"
     PropsDisplayText(28)="Cross-Team Priv. Chat"
     PropsDisplayText(29)="Kick Idlers Time"
     PropsDisplayText(30)="Friendly Fire Punishment"
     PropsDisplayText(31)="Death Message Mode"
     PropsDisplayText(32)="Black Hud When Dead"
     PropsDisplayText(33)="Black Hud On Non-Playerview"
     PropsDisplayText(34)="Auto Balance Teams On Death"
     PropsDisplayText(35)="Max Team Difference"
     PropsDisplayText(36)="Override Max Players"
     PropsDisplayText(37)="Team Kill Forgiving Enabled"
     PropsDisplayText(38)="Friendly Fire Kill Limit"
     PropsDisplayText(39)="Friendly Fire Damage Limit"
     PropsDisplayText(40)="Show Server IP on Scoreboard"
     PropsDisplayText(41)="Show Time on Scoreboard"
     PropDescText(0)="Set the skill of your AI opponents."
     PropDescText(1)="The map will change after a match is complete or the time runs out."
     PropDescText(2)="Controls how fast time passes in the game."
     PropDescText(3)="Sets the maximum number of spectators that can watch the game."
     PropDescText(4)="Maximum number of players on each team"
     PropDescText(5)="The game ends after this many minutes of play."
     PropDescText(6)="If enabled a view from behind the player is allowed."
     PropDescText(7)="If enabled players will only be able to spectate from the 1st person view."
     PropDescText(8)="If enabled 3rd person specating will be locked to the rotation of the player being viewed."
     PropDescText(9)="If enabled players will be able to spectate scenic viewpoints throughout the level."
     PropDescText(10)="If enabled players will be able to freely move around the map while spectating."
     PropDescText(11)="If enabled players will be able to freely move around the map while dead spectating."
     PropDescText(12)="Controls whether administrators can pause the game."
     PropDescText(13)="Bots fill server if necessary to make sure at least this many participant in the match."
     PropDescText(14)="Specify how the number of bots in the match is determined."
     PropDescText(15)="How long to wait after the match ends before switching to the next map."
     PropDescText(16)="If enabled the AI skill level will change dynamically to match the skill of the human players."
     PropDescText(17)="The number of rounds that must be won to win this match."
     PropDescText(18)="The maximum number of rounds for this match."
     PropDescText(19)="Delay before game starts to allow other players to join."
     PropDescText(20)="Delay before game starts to allow other players to join."
     PropDescText(21)="How many players must join before net game will start."
     PropDescText(22)="If enabled, players must choose a team and a weapon before the game starts."
     PropDescText(23)="Specifies how much damage players from the same team can do to each other."
     PropDescText(24)="How much to increase/decrease friendly fire punishment from artillery damage."
     PropDescText(25)="How much to increase/decrease friendly fire damage from explosive damage (grenades/satchels)."
     PropDescText(26)="Bots will join or change teams to make sure they are even."
     PropDescText(27)="Players are forced to join the smaller team when they enter."
     PropDescText(28)="Determines whether members of opposing teams are allowed to join the same private chat room"
     PropDescText(29)="Specifies how long to wait before kicking idle player from server."
     PropDescText(30)="Determines how friendly fire punishment is handled."
     PropDescText(31)="Determines how death messages are handled."
     PropDescText(32)="Force a blacked out hud when the player is dead and spectating."
     PropDescText(33)="Force a blacked out hud only when the player is dead and spectating without actually viewing a player."
     PropDescText(34)="Players join the smaller team when they die if teams are off-balance by more than Max Team Difference(Players Balance Teams must be on)."
     PropDescText(35)="The maximum acceptable difference in team sizes(used for Players Balance Teams and auto Balance Teams On Death)."
     PropDescText(36)="Allows for overriding of the Server's Max Players setting to a lower amount(Set to 0 to disable)."
     PropDescText(37)="Allows players that get killed by a team mate to say np or forgive, which erases that TK from the killer's record."
     PropDescText(38)="The number of teammates that a player can kill before the Friendly Fire Punishment takes place."
     PropDescText(39)="The amount of damage that a player can do to teammates before the Friendly Fire Punishment takes place."
     PropDescText(40)="Displays the Server's IP on the scoreboard."
     PropDescText(41)="Displays the Date and Time on the scoreboard."
     PropsExtras(0)="0.000000;Untrained;1.000000;Raw recruit;2.000000;Green soldier;3.000000;Front line soldier;4.000000;Experienced soldier;5.000000;Battle-hardened;6.000000;Highly-decorated;7.000000;Party fanatic"
     PropsExtras(1)="FFP_None;No Punishment;FFP_Kick;Kick;FFP_SessionBan;Session Ban;FFP_GlobalBan;Permanent Ban"
     PropsExtras(2)="DM_None;None;DM_OnDeath;Personal Deaths;DM_Personal;Personal Kills/Deaths;DM_All;All"
     AlternateSpawns(0)=(Y=76.000000,Z=8.000000)
     AlternateSpawns(1)=(X=-52.000000,Y=64.000000,Z=8.000000)
     AlternateSpawns(2)=(X=-84.000000,Y=4.000000,Z=16.000000)
     AlternateSpawns(3)=(X=-60.000000,Y=-56.000000,Z=12.000000)
     AlternateSpawns(4)=(X=20.000000,Y=-72.000000,Z=12.000000)
     AlternateSpawns(5)=(X=80.000000,Y=-48.000000,Z=12.000000)
     AlternateSpawns(6)=(X=80.000000,Y=8.000000,Z=12.000000)
     AlternateSpawns(7)=(X=76.000000,Y=60.000000,Z=8.000000)
     AlternateSpawns(8)=(Z=128.000000)
     RussianNames(0)="Anatolii"
     RussianNames(1)="Aleksandr"
     RussianNames(2)="Nikita"
     RussianNames(3)="Aleksei"
     RussianNames(4)="Chakan"
     RussianNames(5)="Iosef"
     RussianNames(6)="Pakoslav"
     RussianNames(7)="Petr"
     RussianNames(8)="Rasputa"
     RussianNames(9)="Vladislav"
     RussianNames(10)="Zhegor"
     RussianNames(11)="Vladimir"
     RussianNames(12)="Leon"
     RussianNames(13)="Nikolai"
     RussianNames(14)="Dirge"
     GermanNames(0)="Ramm"
     GermanNames(1)="Friedrich"
     GermanNames(2)="Otto"
     GermanNames(3)="Christoph"
     GermanNames(4)="Roland"
     GermanNames(5)="Dietrich"
     GermanNames(6)="Lothar"
     GermanNames(7)="Manfred"
     GermanNames(8)="Günther"
     GermanNames(9)="Wolfgang"
     GermanNames(10)="Christian"
     GermanNames(11)="Klaus"
     GermanNames(12)="Rolf"
     GermanNames(13)="Ernst"
     GermanNames(14)="Gustav"
     GermanNames(15)="Berthold"
     bSpawnInTeamArea=True
     FriendlyFireScale=1.000000
     TeamAIType(0)=Class'ROEngine.ROTeamAI'
     TeamAIType(1)=Class'ROEngine.ROTeamAI'
     NetWait=0
     RestartWait=0
     bAllowTaunts=False
     SpawnProtectionTime=0.000000
     CountDown=0
     DefaultEnemyRosterClass="ROEngine.ROTeamRoster"
     LoginMenuClass="ROInterface.ROUT2K4PlayerSetupPage"
     EndTimeDelay=15.000000
     DefaultVoiceChannel="Team"
     bTeamScoreRounds=True
     bAllowVehicles=True
     bLiberalVehiclePaths=True
     DefaultPlayerClassName="ROEngine.ROPawn"
     ScoreBoardType="ROInterface.ROScoreBoard"
     HUDType="ROEngine.ROHud"
     MapListType="ROInterface.ROMapList"
     MapPrefix="RO"
     BeaconName="RO"
     GoalScore=0
     TimeLimit=0
     DeathMessageClass=Class'ROEngine.RODeathMessage'
     GameMessageClass=Class'ROEngine.ROGameMessage'
     OtherMesgGroup="ROGame"
     BroadcastHandlerClass="ROEngine.ROBroadcastHandler"
     PlayerControllerClassName="ROEngine.ROPlayer"
     GameReplicationInfoClass=Class'ROEngine.ROGameReplicationInfo'
     GameName="Red Orchestra"
     ScreenShotName="MapThumbnails.ShotCTFGame"
     DecoTextName="ROEngine.ROTeamGame"
     Acronym="RO"
}
