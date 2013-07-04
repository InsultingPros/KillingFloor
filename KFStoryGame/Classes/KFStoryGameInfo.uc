/*
	--------------------------------------------------------------
	KFStoryGameInfo
	--------------------------------------------------------------

	GameType scripts for 'Story' maps.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KFStoryGameInfo	extends KFGameType;

/* ===  Objective Structs & Enums ============================================
==============================================================================*/

enum    EFontScale
{
    Font_Small,
    Font_Medium,
    Font_Large,
    Font_VeryLarge,
};

/* 2D vector for storing draw coordinates on the canvas */
struct SVect2D
{
    var() float  Horizontal,Vertical;
};


struct SObjectiveHeaderInfo
{
    var () localized      string                      Header_Text;
    var ()                color                       Header_Color;
    var ()                KFStoryGameInfo.EFontScale  Header_Scale;
};

enum    EBackGroundAspectRatio
{
    Aspect_Stretched,
    Aspect_Scaled,
    Aspect_FromTexture,
};



struct SObjectiveBackgroundInfo
{
    var ()      Material                    Background_Texture;
    var ()      Material                    Background_Texture_Collapsed;
    var ()      float                       Background_Padding;
    var ()      EBackgroundAspectRatio      Background_AspectRatio;
    var         float                       Background_Scale;
    var ()      SVect2D                     BackGround_Offset;
};


/* A struct representing an event that can be fired off at various intermediate stages of completion (or failure) */

struct SObjectiveProgressEvent
{
	/* name of event to fire off */
	var	()									name					EventName;

	var	()									float					ProgressPct;

	var ()									bool					bReTriggerable;

	var										bool					bWasTriggered;

	var                                     float                   LastTriggeredPct;
};


/* == Conditions ==============================================================*/

enum EConditionInitialState
{
   Inactive,
   Active,
};

enum EConditionActivationMethod
{
   Null,
   TriggerToggled,
   TriggerActivates,
   TriggerDeActivates,
   RandomlyActivate,
};


  /* The importance of a conditions' progress to the Parent Objective's completion status

i.e  In a situation where there are two success conditions with equal progress importance,  both
will have to be completed before the objective is considered complete.

In a situation where there are 10 failure conditions but one of them is marked 'Critical' ,  the
objective would be considered failed at any point where that single condition was marked complete.

*/
enum EProgressImportance
{
    Normal,
    Critical,
    Ignore,
};


enum EDisplayStyle
{
   Count_Up,
   Count_Down,
   Hide_Counter,
};

enum	EHintDisplayStyle
{
    HDS_Hide,
	HDS_BarOnly,
	HDS_TextOnly,
	HDS_Combination,
};

struct SConditionDifficultyScale
{
    var ()     float                                      Scale_Beginner;
    var ()     float                                      Scale_Hard;
    var ()     float                                      Scale_Suicidal;
    var ()     float                                      Scale_HellOnEarth;
};


struct SConditionHintInfoHUD
{
    var ()     localized string                           Screen_Hint;
    var	()	   EDisplayStyle							  Screen_CountStyle;
    var ()     EHintDisplayStyle                          Screen_ProgressStyle;
    var ()     KFStoryGameInfo.EFontScale                 FontScale;
    var ()     bool                                       bShowCheckBox;
    var ()     Material                                   Screen_ProgressBarBG;
    var ()     Material                                   Screen_ProgressBarFill;
    var ()     color                                      Screen_Clr;
};

struct SConditionHintInfoWorld
{

	var  ()    Material                                   World_Texture;
	var  ()    float                                      World_Texture_Scale;
    var  ()    localized string                           World_Hint;
    var  ()    private edfindable Actor                   World_Location;
    var  ()    bool                                       bShowWhispTrail;
    var  ()    bool                                       bHide;
    var  ()    bool                                       bIgnoreWorldLocHidden;
    var  ()    color                                      World_Clr;
    var  ()    color                                      Whisp_Clr;
};


/* ===  Wave / Squad Designer Structs & Enums =================================
==============================================================================*/

enum    EZEDSpawnPriority
{
    Normal,
    Low,
    VeryLow,
    High,
    VeryHigh
};

/* ZED Archetypes */
enum EZEDType
{
    ZED_Clot,
    ZED_Bloat,
    ZED_Crawler,
    ZED_Gorefast,
    ZED_Stalker,
    ZED_Husk,
    ZED_Siren,
    ZED_Scrake,
    ZED_Fleshpound,
    ZED_Patriarch,
    ZED_CUSTOM,
};


struct SZEDSquadSpawnType
{
	var  transient     class<KFMonster>     					ZEDClass;               // assigned dynamically in code, not used by the level designer.
	var()	           int										NumToSpawn;             // number of zeds to spawn of the supplied type.
    var()              EZEDType                                 ZEDType;                // ZED archetype to spawn.  gets modified if we're running an event.
    var()              class<KFMonster>                         CustomZEDClass;         // if ZEDType is CUSTOM, spawn this class of ZED.
};

struct SZEDSquadType
{
    var()  string                                           Squad_Name;              // human-readable name for this squad.
    var()  array<SZedSquadSpawnType>                        Squad_ZEDs;              // the types of enemies this squad can spawn.
    var    EZEDSpawnPriority                                Squad_Priority;          // the likelihood of a wave designer choosing this squad over another.
    var    bool                                             bIgnoreLevelMaxZEDs;     // spawn this squad even if the number of ZEDS is capped out.
    var    float                                            MinTimeBetweenSpawns;    // the minimum time (in seconds) which must pass before this squad can be spawned again.
    var    float                                            LastSquadSpawnTime;      // Time at which this squad was last spawned.
};

var         array<string>                                   AllSquadNames;

var         array<SZEDSquadType>                            AllSquads;

/* ===  Dialogue Structs & Enums ==============================================
==============================================================================*/

struct SVoiceOver
{
	var()	    edfindable	actor				             SourceActor;
	var()		sound						                 VoiceOverSound;
};

enum	EBroadcastScope
{
    AllPlayers,                                         // Dialogue shows to all human players on the server.
    InstigatorOnly,                                     // Dialogue only shows to the player who instigated it (Triggered the required event, or DlgActor )
};

enum	EDialogueAlignment
{
    Left,
    Centered,
    Right
};

enum    EDialogueScaleStyle
{
    Stretched,
    Scaled
};

struct SDialogueDisplayInfo
{
    var()       EDialogueScaleStyle                     Screen_Scaling;
    var         EDialogueAlignment                      ScreenAlignment;
    var()       Material                                Screen_BGMaterial;
    var()       SVect2D                                 Screen_Position;
    var()       Material                                Portrait_Material;
    var()       string                                  Portrait_BinkMovie;
    var()       localized string                        Dialogue_Header;
    var()       localized string                        Dialogue_Text;
};

struct SDialogueEvent
{
    var()    name   RequiredEvent;                     // Event required to trigger this dialogue.
    var()    name   DisplayedEvent;                    // Event that triggers after this dialogue has been displayed
    var()    name   DisplayingEvent;                   // Event that triggers just as this dialogue is being displayed.
};


struct SDialogueEntry
{
    var()       SDialogueDisplayInfo                    Display;
    var()       SDialogueEvent                          Events;
    var()       EBroadCastScope                         BroadcastScope;
	var() 		SVoiceOver					            VoiceOver;				// voice over to play alongside dialogue text.
	var()		bool						            bLooping;				// if true, this message will continue to display until Required event happens
    var			Dialogue_EventListener		            EventListener;			// event listener actor - Used if 'RequiredEvent' is set.  Sets bWasTriggered when it receives the event associated with this Dialgoeu
	var			bool						            bWasTriggered;			//
};

/* ============================================================================
==============================================================================*/


/* level rules actored tailored to the story gametype. Can be used by mappers to configure things like Player default equipment */
var			KFLevelRules_Story				StoryRules;

/* Style manager for our HUD */
var         KF_HUDStyleManager              HUDManager;

/* cached reference to the last activated CheckPoint volume -  if the volume has bRespawnOnWipe,  the game will not end when the last player dies.
Instead, everyone they will respawn at one of the playerstarts encompassed by this volume */

var			KF_StoryCheckPointVolume		CurrentCheckPoint;

var			array<KF_StoryCheckPointVolume>	AllCheckPoints;

var         array<KF_DialogueSpot>          AllDialogue;

var         array<KF_StoryWaveDesigner>     AllWaveDesigners;

/* reference to the current active Objective in a story mission */
var			KF_StoryObjective				CurrentObjective,LastObjective;

var			int								CurrentObjectiveIdx;

var			string							CurrentMusicTrack;

/* cached references to Objective Actors in the map so we don't have to use Actor iterators all the time */
var			array<KF_StoryObjective>		AllObjectives,SortedObjectives;

var			class<LocalMessage>				CheckPointMessageClass;

var			bool							bPendingTeamRespawn;

var         bool                            bInitStoryMatch;

var         array<KF_UseableMover>          AllUseableMovers;

var         array<KFTraderDoor>             AllTraderDoors;


/* Matinee Vars  ==============================================================================================*/

var			bool							bPlayingCinematic;

/* ===========================================================================================================*/

/* Debugging *=================================================================================================
==============================================================================================================*/

var			bool							bDebugPlayerSpawning;

var         bool                            bSkipDialogue;

var         KF_StoryObjective               ForcedTargetObj;

// Force slomo for a longer period of time when the boss dies
/* Let's skip this in Story Mode
function DoBossDeath(){}*/

// stub - implementation in state MatchInProgress
function SetupPickups();
function GoToForcedObj();
function OnObjectiveCompleted(KF_StoryObjective CompletedObj);
function OnObjectiveFailed(KF_StoryObjective FailedObj);


event PostLogin( PlayerController NewPlayer )
{
    Super.PostLogin(NewPlayer);
    OnPlayerJoined(NewPlayer);
}

function Logout( Controller Exiting )
{
    Super.Logout(Exiting);
    OnPlayerLeft(Exiting);
}

function OnPlayerJoined(Controller JoiningPlayer)
{
	if(CurrentObjective != none)
    {
        CurrentObjective.OnPlayerJoined(JoiningPlayer);
	}
}

function OnPlayerLeft(Controller LeavingPlayer)
{
	if(CurrentObjective != none)
    {
        CurrentObjective.OnPlayerLeft(LeavingPlayer);
	}
}


function OnObjPopulationComplete()
{
	local int i;

	for(i = 0 ; i < AllObjectives.length ; i ++)
	{
		AllObjectives[i].OnObjPopulationComplete();
	}
}

event InitGame( string Options, out string Error )
{
	local KF_StoryCheckPointVolume	CheckPoint;
	local KF_DialogueSpot Dlg;
	local KF_StoryWaveDesigner Wave;
	local KFTraderDoor TraderDoor;


//    ConsoleCommand("Suppress Story_Debug");


	Super.InitGame(Options, Error);

	/* Cache the stuff we'll be looking up pretty frequently */

	foreach AllActors(class'KFLevelRules_Story',StoryRules)
	{
		break;
	}

	foreach AllActors(class 'KF_StoryCheckPointVolume', CheckPoint)
	{
		AllCheckPoints[AllCheckPoints.length] = CheckPoint ;
	}

	foreach AllActors(class 'KF_DialogueSpot', Dlg)
	{
	   AllDialogue[AllDialogue.length] = Dlg;
	}

	foreach AllActors(class 'KFTraderDoor', TraderDoor)
	{
	   AllTraderDoors[AllTraderDoors.length] = TraderDoor;
	}

	foreach AllActors(class 'KF_StoryWaveDesigner', Wave)
	{
        AllWaveDesigners[AllWaveDesigners.length] = Wave;
	}

	if(StoryRules == none)
	{
		StoryRules = spawn(class'KFLevelRules_Story');
	}

	KFGameLength = GL_Custom ;

	if(StoryRules != none)
	{
		StartingCash = StoryRules.StartingCashSum;
		bNoBots = !StoryRules.bAllowBots ;

        StartingCash /= (GameDifficulty/2.f) ;
	}

	PopulateObjectiveList();
}

/* builds a list of all the spawnable ZED squads in the current map */
function CacheSquadsFor(KF_StorySquadDesigner Squad)
{
    local int i;

    for(i = 0 ; i < Squad.Squads.length ; i ++)
    {
        if(Squad.Squads[i].Squad_Name != "")
        {
            AllSquadNames[AllSquadNames.length] = Squad.Squads[i].Squad_Name ;
            AllSquads[AllSquads.length] = Squad.Squads[i] ;

            log("Caching Squad - "@Squad.Squads[i].Squad_Name,'Story_Debug');
        }
    }
}
function LoadUpMonsterList()
{
    local int i,idx;
	local array<IMClassList> InitMList;
    local KF_StorySquadDesigner StorySquads;
    local class<KFMonster> NewZEDClass;

    foreach AllActors(class 'KF_StorySquadDesigner', StorySquads)
    {
        CacheSquadsFor(StorySquads);
    }

    /* No Squad Designers, or Squad designers have no squads specified */
    if(AllSquads.length == 0)
    {
        return;
    }

    InitMList = LoadUpMonsterListFromCollection();

    for( i = 0 ; i < AllSquads.length ; i ++)
    {
        for(idx = 0 ; idx < AllSquads[i].Squad_ZEDs.length ; idx ++)
        {
            /* Convert our enum index to the one that matches what's in the 'MonsterClasses' collection */
            switch( AllSquads[i].Squad_ZEDs[idx].ZEDType)
            {
                case ZED_Clot       :         NewZEDClass = InitMList[0].MClass;     break;
                case ZED_Bloat      :         NewZEDClass = InitMList[6].MClass;     break;
                case ZED_Crawler    :         NewZEDClass = InitMList[1].MClass;     break;
                case ZED_Gorefast   :         NewZEDClass = InitMList[2].MClass;     break;
                case ZED_Stalker    :         NewZEDClass = InitMList[3].MClass;     break;
                case ZED_Husk       :         NewZEDClass = InitMList[8].MClass;     break;
                case ZED_Siren      :         NewZEDClass = InitMList[7].MClass;     break;
                case ZED_Scrake     :         NewZEDClass = InitMList[4].MClass;     break;
                case ZED_Fleshpound :         NewZEDClass = InitMList[5].MClass;     break;
                case ZED_Patriarch  :         NewZEDClass = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.EndGameBossClass,Class'Class')); break;
                case ZED_CUSTOM     :         NewZEDClass = AllSquads[i].Squad_ZEDs[idx].CustomZEDClass;  break;
            }

            if(NewZEDClass != none)
            {
                AllSquads[i].Squad_ZEDs[idx].ZEDClass = NewZEDClass ;
                NewZEDClass = none;
            }
            else
            {
                log("ERROR !! Could not find suitable ZED Class im Monster Collection for -> "@GetEnum(enum 'KFStoryGameInfo.EZEDType',AllSquads[i].Squad_ZEDs[idx].ZEDType),'Story_Debug');
            }
        }
    }
}


/* 	Returns the total cash amount currently held by all living members of the player's team
	Used by Story Objective actors which are configured to complete when a cash goal is reached
*/

function int	GetTotalCashSum()
{
	local int i;
	local int Total;

	for(i = 0 ; i < GameReplicationInfo.PRIArray.length ; i ++)
	{
		Total +=	GameReplicationInfo.PRIArray[i].Score ;
	}

	return Total;
}

function int GetTotalActivePlayers()
{
	local int LivingCount;
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ((C.PlayerReplicationInfo != None) &&
		C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives &&
		!C.PlayerReplicationInfo.bOnlySpectator )
		{
			LivingCount ++ ;
		}
	}

//	log("TOTAL PLAYERS : "@LivingCount);

	return LivingCount ;
}

function PostBeginPlay()
{
	local KF_HUDStylemanager NewManager;
	local KF_StoryGRI StoryGRI;

	Super.PostBeginPlay();

	TriggerEvent('PostBeginPlay',self,none);

	if(GameReplicationInfo != none && StoryRules != none)
	{
        StoryGRI = KF_StoryGRI(GameReplicationInfo);
        if(StoryGRI != none)
        {
            StoryGRI.SetVictorymaterial(StoryRules.VictoryMaterial) ;
            StoryGRI.SetDefeatMaterial(StoryRules.DefeatMaterial) ;

            foreach AllActors(class 'KF_HUDStyleManager',NewManager)
            {
                if(HUDManager == none)
                {
                    if(NewManager.StylePreset.StyleName == StoryRules.HUDStyle)
                    {
                        HUDManager = NewManager;
                        StoryGRI.SetHUDStyleManager(HUDManager);
                        break;
                    }
                }
	       }
        }
	}
}

/* StartMatch()
This would  be a good place to Activate any checkpoints flagged 'StartEnabled'.
*/
function StartMatch()
{
    /* Needs to happen *before* we call super, as this is where the players are spawned and we need to work out
    which (if any) playerstarts are associated with starting checkpoints */
    EnableStartingCheckPoints();

	Super.StartMatch();

    if(StoryRules.bAutoStartObjectives)
    {
        CurrentObjectiveIdx = 0;
	    SetActiveObjective(SortedObjectives[CurrentObjectiveIdx], GetAHumanPlayerController().Pawn);
    }

	TriggerEvent('MatchInProgress', Self, GetAHumanPlayerPawn());
}

function EnableStartingCheckPoints()
{
	local int i;

	for( i = 0 ; i < AllCheckPoints.length ; i ++)
	{
		if(AllCheckPoints[i].bStartEnabled)
		{
			AllCheckPoints[i].CheckPointActivated(GetAHumanPlayerPawn(),true,false);
            break;
		}
	}
}

/*	 A little hack so that Checkpoints which are automatically activated when the match begins can still have a valid Instigator
	 If they dont,  activation events this checkpoint fires off may not work correctly.  ie.  If were trying to trigger a mover
	 with the checkpoint when it activates that would fail, because those actors require a human pawn to trigger them.
*/
function	Pawn		 GetAHumanPlayerPawn()
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( PlayerController(C) != none &&
		C.Pawn != none )
		{
			return C.Pawn ;
		}
	}

	return none;
}

function	PlayerController		 GetAHumanPlayerController()
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( PlayerController(C) != none)
		{
		   return PlayerController(C);
		}
	}

	return none;
}

/* Story Objectives =============================================================================================
==================================================================================================================*/

/* Builds a list of objective actors in the map -  Linear progression objectives go in the Sorted Objectives list
everything else gets dumped in the AllObjectives array*/

function PopulateObjectiveList()
{
	local KF_StoryObjective	Objective;

    AllObjectives.length = 0;

	foreach AllActors(class 'KF_StoryObjective', Objective)
	{
	   AllObjectives[AllObjectives.length] = Objective;
	}


    if(SortMissionObjectives())
    {
	   OnObjPopulationComplete();
    }
    else
    {
        log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",'Story_Debug');
        log(" WARNING - Unable to sort Map Objectives.  This map won't work correctly. ",'Story_Debug');
        log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",'Story_Debug');
    }
}


function bool SortMissionObjectives()
{
    local int i;
    local KF_StoryObjective LastSortedObj;

    SortedObjectives.Length = 0 ;

	for(i = 0 ; i < Level.StoryObjectives.length ; i ++)
	{
		if(Level.StoryObjectives[i] != '')
		{
            LastSortedObj = FindObjectiveNamed(Level.StoryObjectives[i],true);
            if(LastSortedObj != none)
            {
			    SortedObjectives[SortedObjectives.length] = LastSortedObj ;
            }
            else
            {
                log("Warning - Could not add : "@Level.StoryObjectives[i]@" to the Sorted Objectives list.  FindObjective() returned none . ",'Story_Debug');
            }
		}
	}

    return SortedObjectives.length == Level.StoryObjectives.length ;
}


function RewindToLastObjective()
{
	if(LastObjective != none && LastObjective != CurrentObjective)
	{
		SetActiveObjective(LastObjective,CurrentObjective.Instigator);
	}
}


function RestartEveryone()
{
	local Controller C;

	if(!WholeTeamIsWipedOut())
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( (C.PlayerReplicationInfo != None) &&
			C.bIsPlayer && C.Pawn != none )
			{
				C.Pawn.Died(C,class 'Suicided', C.Pawn.Location);
			}
		}
	}
}

/* Remove dead zombies from the ZEDList array so fresh ones can spawn */
function CleanUpZEDs()
{
    local KFMonster ZED;

    foreach DynamicActors(class 'KFMonster', ZED)
    {
        ZED.Died(ZED.Controller, class'Gibbed', ZED.Location );
    }
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local bool Result;

    /* skip the KFGameType implementation ... */
	Result = Super(TeamGame).CheckEndGame(Winner,Reason);

	switch(Reason)
	{
        case "LoseAction" :
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 1;
        Result = true;
        break;
        case "WinAction" :
		GameReplicationInfo.Winner = Teams[0];
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 2;
        Result = true;
        break;
        case "LastMan" :
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 1;
        break;
	}

	return Result;
}

/* Most of the stuff in here was moved from KFGameType.CheckEndGame()
Kinda weird that the function designed to Check whether the game should end was
instead just immediately ending the game ??? */

function EndGame(PlayerReplicationInfo	Winner, string  Reason)
{
	local PlayerController Player;
	local Controller P;
	local bool bSetAchievement;
	local string MapName;

	Super(GameInfo).EndGame(Winner,Reason);

	if(bGameEnded)
	{
        GotoState('MatchOver');
		EndTime = Level.TimeSeconds + EndTimeDelay;

		if ( Reason ~= "WinAction" )
		{
		if ( GameDifficulty >= 2.0 )
		{
			bSetAchievement = true;

			// Get the MapName out of the URL
			MapName = GetCurrentMapName(Level);
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
		}
		}

		P.GameHasEnded();

		if ( CurrentGameProfile != none )
		{
			CurrentGameProfile.bWonMatch = false;
		}
	}

	log("========== END GAME : REASON : "@Reason@"::::"@bGameEnded@"===============",'Story_Debug');
	log("=============================================================================",'Story_Debug');

}

/* We don't really use this function - our 'Focus' is set in EndGame() by calling Player.ClientSetBehindView(). */
function SetEndGameFocus(PlayerReplicationInfo Winner);

state MatchOver
{
    function SetActiveObjective( KF_StoryObjective NewObjective, optional pawn ObjInstigator){}
    function Beginstate()
    {
       super.BeginState();
       SetActiveObjective(none);
    }
}


/* 	Helper function for retrieving an Objective with the supplied name
	optionally returns the Index of the Objective in the supplied array */

function KF_StoryObjective FindObjectiveNamed(name	ObjName, optional bool bSearchAll, optional out Int ObjIndex)
{
	local int i;
	local array<KF_StoryObjective>      ArrayToUse;
	local KF_StoryObjective  UnsortedObj;

	/* by default just use the sorted objectives list */
	ArrayToUse = SortedObjectives ;
	if(bSearchAll)
	{
	     ArrayToUse = AllObjectives;
	}

	for(i = 0 ; i < ArrayToUse.length ; i ++)
	{
		if(ArrayToUse[i].ObjectiveName == ObjName)
		{
			ObjIndex = i;
			return ArrayToUse[i] ;
		}
	}

    /* Iterate unsorted objectives - Last resort time.  */

    foreach AllActors(class 'KF_StoryObjective', UnsortedObj)
    {
        if(UnsortedObj.ObjectiveName == ObjName)
        {
           return UnsortedObj ;
        }
    }

	log(" Warning - Failed to find objective named -"@ObjName,'Story_Debug');
	return none ;
}

/* Helper function for retrieving a CheckPoint with the supplied name */

function	KF_StoryCheckPointVolume		FindCheckPointNamed(string CheckPointName)
{
	local int i;

	for(i = 0 ; i < AllCheckPoints.length ; i ++)
	{
		if(AllCheckPoints[i].CheckPointName ~= CheckPointName)
		{
			return AllCheckPoints[i];
		}
	}

	return none;
}

function NotifyObjectiveFinished(KF_StoryObjective Obj)
{
    if(Obj == CurrentObjective)
    {
        SetActiveObjective(none);
    }
}

function SetActiveObjective( KF_StoryObjective NewObjective, optional pawn ObjInstigator)
{
	local KF_StoryGRI 	SGRI;
	local int NewIndex;
	local KF_StoryNPC StoryPawn;
	local Controller C;
	local name LastObjectiveName,CurrentObjectiveName;

	if(NewObjective != CurrentObjective &&
	(NewObjective == none ||  FindObjectiveNamed(NewObjective.ObjectiveName) == NewObjective &&
    NewObjective.IsValidForActivation())  )
	{
		SGRI = KF_StoryGRI(GameReplicationInfo);

	    if(NewObjective != none && NewObjective.bOptional)
	    {
            KFPlayerController(ObjInstigator.Controller).CheckForHint(61);
	    }

        if(NewObjective != none)
        {
	       log("Setting active game objective to -"@NewObjective.ObjectiveName,'Story_Debug');
        }

		if(CurrentObjective != none)
		{
			LastObjective = CurrentObjective;
            if(LastObjective != none)
            {
			    log("LastObjective was ... "@LastObjective.ObjectiveName,'Story_Debug');
		        LastObjective.Notify_ObjectiveDeActivated();
	        }
		}

		if((NewObjective == none ||
		NewObjective.ObjectiveInProgressMusic == "") &&
		(CurrentObjective == none || CurrentObjective.bStopMusicOnCompletion))
		{
			StopGameMusic();
			CurrentMusicTrack = "" ;
		}

		CurrentObjective = NewObjective;
		if(CurrentObjective != none)
		{
		    NewIndex = GetIndexForObj(CurrentObjective);
		    if(NewIndex >= 0 && NewIndex < SortedObjectives.Length )
		    {
			    CurrentObjectiveIdx = NewIndex;
            }

			CurrentObjective.Notify_ObjectiveActivated(ObjInstigator);

            /* Objective FastFoward Debug */
            if(ForcedTargetObj != none)
            {
                /* We made it. */
                if(ForcedTargetObj == CurrentObjective)
                {
                    log("!!!!! Forced OBJ Reached.  Stopping. ",'Story_Debug');

                    bSkipDialogue    = false;
                    ForcedTargetObj  = none;

	              	if(SGRI != none)
                    {
                        SGRI.SetDebugTargetObj(none);
                    }
                }
                else
                {
                    log("CurrentObjective : "@CurrentObjective.ObjectiveName@" is Not : "@ForcedTargetObj.ObjectiveName@" .. Proceeding to next  OBJ by force.",'Story_Debug');
                    GoToForcedObj();   // keep goin'...
                }
            }
		}

		SGRI = KF_StoryGRI(GameReplicationInfo);
		if(SGRI != none)
		{
			SGRI.SetCurrentObjective(NewObjective);
		}

		/* Let NPCs know that the objective changed .. */
		for (c = Level.ControllerList; c!=None; c=c.nextController)
		{
            if(C.Pawn != none)
            {
                StoryPawn = KF_StoryNPC(C.Pawn);
                if(StoryPawn != none)
                {
                    if(CurrentObjective != none)
                    {
                        CurrentObjectiveName = CurrentObjective.ObjectiveName;
                    }

                    if(LastObjective != none)
                    {
                        LastObjectiveName = LastObjective.ObjectiveName;
                    }

                  	StoryPawn.OnObjectiveChanged(LastObjectiveName,CurrentObjectiveName);
                }
            }
		}
    }
}

/* Displays a whisp trail leading to an Objective in story mode */

function ShowPathToObj(PlayerController P)
{
    local int i;
    local Objective_Whisp NewWhisp;
    local Actor DestPath,TargetActor;
    local vector DestLoc;
    local KFPlayerController_Story StoryPC;

	// Attempt to display the route to the currrent objective
	if( CurrentObjective != none )
	{
        for(i = 0 ; i < CurrentObjective.AllConditions.length ; i ++)
	    {
            if(CurrentObjective.AllConditions[i].ShouldShowWhispTrailFor(P))
            {
                DestLoc = CurrentObjective.AllConditions[i].GetWhispLocation(TargetActor) ;
                DestPath = P.FindPathTo(DestLoc) ;

                /* log("=====================================S=======================");
                log("SHOW WHISP PATH TO : "@CurrentObjective.AllConditions[i].name);
                log("Find Path to location ? "@DestPath);    */

                if(DestPath != none)
	            {
                    /* All these values need to be set *before* the whisp is actually spawned as the native code
                    assigns the particular colour from the mColorRange array the moment it is spawned. */

                    /* tint the whisp trail to the colour of the condition hint */

                    Class'Objective_Whisp'.default.mColorRange[0]=CurrentObjective.AllConditions[i].HUD_World.Whisp_Clr ;
                    Class'Objective_Whisp'.default.mColorRange[1]=CurrentObjective.AllConditions[i].HUD_World.Whisp_Clr ;
                    Class'Objective_Whisp'.default.DestLoc = DestLoc;

                    StoryPC = KFPlayerController_Story(P) ;
                    if(StoryPC != none)
                    {
                        StoryPC.SetClientWhispClr(CurrentObjective.AllConditions[i].HUD_World.Whisp_Clr);
                    }

                    NewWhisp = Spawn(class'Objective_Whisp',P,, P.Pawn.Location) ;
                }
            }
        }
    }
}

function Int		GetIndexForObj(KF_StoryObjective InObj)
{
	local int i;

	for(i = 0 ; i < SortedObjectives.length ; i ++)
	{
		if(SortedOBjectives[i] == InObj)
		{
			return i;
		}
	}

    log("Objective "@InObj.ObjectiveName@"is not in the sorted Objectives array.  Returning invalid index",'Story_Debug');
	return -1;
}

/* ================================================================================================================
==================================================================================================================*/

/* 	Returns true if all players are out of lives

	Extended because we don't want to end the game if we have an
	active Checkpoint in the map that can respawn a team when it wipes out ...

	NOTE -  this function gets called CONSTANTLY via. MatchInProgress.Timer()
	so long	as there is more than one active player in the match.  Any code added here
	should be structured accordingly.
*/

function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
	local KF_StoryCheckPointVolume	RespawnPoint;

	/* Team respawn is already taking place .. Don't bother checking anything else*/
	if(bPendingTeamRespawn)
	{
		return false;
	}

	if(WholeTeamIsWipedOut())
	{
        if(CurrentObjective != none)
        {
            CurrentObjective.ObjectiveFailed(Controller(Scorer.Owner),true);
        }

        if(	CurrentCheckPoint != none &&
            CurrentCheckPoint.GrantASecondChance(RespawnPoint) )
        {
            bPendingTeamRespawn = true;

            ResetGameState();

            /* Make sure the checkpoint is active so that it can respawn everyone */
            if( !RespawnPoint.bIsActive )
            {
                RespawnPoint.CheckPointActivated(RespawnPoint.Instigator,true,false);
            }

            BroadcastLocalizedMessage( CheckPointMessageClass, 1, none , None, RespawnPoint );

            return	false ;
        }
    }

	return Super.CheckMaxLives(Scorer);
}


/* Called by the currently active checkpoint volume when it has just finished respawning a wiped-out team
	Used to update the objective to what it was at the last checkpoint area*/

function NotifyTeamRestarted()
{
	local KF_StoryObjective		PreviousObjective;
	local int i;
	local actor A;

	/* Everyone should be alive and well now. -  Reset their objective to whatever was current at the time they checkpointed*/

	if(CurrentCheckPoint != none)
	{
		if(CurrentCheckPoint.RestartFromObjective != '')
		{
			PreviousObjective = FindObjectiveNamed(CurrentCheckPoint.RestartFromObjective) ;
			if(PreviousObjective != none)
			{
				log("TEAM WILL RESTART FROM PREVIOUS OBJECTIVE - "@PreviousObjective.ObjectiveName,'Story_Debug');

				/* Reset the Objective we're restrarting from as well as all objectives which come after it */
				for(i = GetIndexForObj(PreviousObjective) ; i < SortedObjectives.length ; i ++)
				{
					SortedObjectives[i].Reset();
				}

				SetActiveObjective(PreviousObjective,CurrentObjective.Instigator);

                // Hack time.
				if(CurrentCheckPoint.bStartEnabled)
				{
                    // tell all actors the game is starting
                    ForEach AllActors(class'Actor', A)
                    {
                        A.MatchStarting();
				    }
                }
            }
		}
		else
		{
			log(" WARNING - The checkpoint responsible for restarting this team has no 'RestartObjective'",'Story_Debug');
		}
	}
}


/* 	Called by the CheckpointVolume responsible for restarting a team that was wiped out,
	just before the players actually respawn. 	Resets all checkpoint-approved actors in
	the map to their initial state and then fires off 'Second chance' events .
*/


function ResetGameState()
{
	local int i;


	log("[CHECKPOINT RESTART -  Resetting Game state . ]",'Story_Debug');

	CleanUpZEDs();
	SetActiveObjective(none);

	/* Reset all relevant actors to their initial state before doing anything else */
	ResetCheckPointActors();

	/* get rid of stuff the players threw / dropped on the floor */
	if( CurrentCheckPoint.bRemoveDroppedWeapons)
	{
		RemoveDroppedWeapons();
	}

	// re-activate LD placed ammo & weapons
	SetupPickups();

	for(i = 0 ; i < CurrentCheckPoint.SecondChanceEvents.length ; i ++)
	{
		TriggerEvent(CurrentCheckPoint.SecondChanceEvents[i],CurrentCheckPoint, CurrentCheckPoint.ActivatingPlayer.Pawn);
	}

	if(bDebugPlayerSpawning)
	{
		log("Checkpoint : "$CurrentCheckPoint.CheckPointName@"is giving everyone a second chance!",'Story_Debug');
	}
}


/* reset story-relevant actors in the map to their initial state
- Note : this needs to happen BEFORE we trigger the Second Chance event  */

function	ResetCheckPointActors()
{
	local Actor A;
	local int i,idx;
	local KFDoorMover	KFDoor;

	if(StoryRules == none)
	{
		log("Warning - No StoryRules actor placed in the level. Cannot reset game state",'Story_Debug');
		return;
	}

	foreach AllActors(class 'Actor' , A)
	{
		/* reset by class */
		for( i = 0 ; i < StoryRules.CheckpointResetClasses.length ; i ++)
		{
			if(A != none && ClassIsChildOf(A.class,StoryRules.CheckpointResetClasses[i]))
			{
				if(AllowReset(A))
				{
					A.Reset();
				}
			}
		}

		/* or object reference */
		for(idx = 0 ; idx < CurrentCheckPoint.CheckPointResetactors.length ; idx ++ )
		{
			if(A != none && A == CurrentCheckPoint.CheckPointResetActors[idx])
			{
				if(AllowReset(A))
				{
					A.Reset();
				}
			}
		}

		/* re-weld DoorMovers with the 'bStartSealed' flag
		this should be done in the DoorMover's Reset() function really, but it isn't. */

		KFDoor = KFDoorMover(A);
		if(KFDoor != none)
		{
			KFDoor.RespawnDoor();
			// - door could also be damaged but not "dead"  need to make sure its @ full weld strength if it was pre-welded
			if(KFDoor.bStartSealed && KFDoor.MyTrigger != none)
			{
				KFDoor.MyTrigger.WeldStrength = 0;
				KFDoor.MyTrigger.AddWeld(KFDoor.MaxWeld*(KFDoor.StartSealedWeldPrc/100.f),False,None);
			}
		}
	}
}


function	bool		AllowReset(Actor A)
{
	local int i;

	if(CurrentCheckPoint != none )
	{
		for(i = 0 ; i < CurrentCheckPoint.ResetExcludeActors.length ; i ++)
		{
			if(A == CurrentCheckPoint.ResetExcludeActors[i])
			{
				return false;
			}
		}

		if(CurrentCheckPoint.ForcedRestartCheckPoint != none)
		{
			return A != CurrentCheckPoint.ForcedRestartCheckPoint;
		}
		else
		{
			return A != CurrentCheckPoint;
		}
	}


	return true;
}


/* Remove dropped weapon pickups from play if we're restarting a team from a checkpoint */

function RemoveDroppedWeapons()
{
	local WeaponPickup WP;

	foreach DynamicActors(class 'WeaponPickup' , WP)
	{
		if(WP.bDropped)
		{
			WP.Destroy();
		}
	}
}

/* Returns true if there are no living players left on the
   team (all spectators or OutOfLives) */

function bool WholeTeamIsWipedOut()
{
	local int LivingCount;
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (C.PlayerReplicationInfo != None) &&
		C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives &&
		!C.PlayerReplicationInfo.bOnlySpectator )
		{
			LivingCount ++ ;
		}
	}

	return LivingCount <= 0;
}

/* Returns true if there is no current objective, or the current objective does
not have a currently active 'TraderTime' success condition.  Used to determine whether players
should be able to switch their perks , etc. */

function bool IsTraderTime()
{
    return CurrentObjective == none || CurrentObjective.IsTraderObj() || NumMonsters <= 0;
}

/* Respawns a dead Player. Extended to give Checkpoints & LevelRules
a chance to modify the stats of the guy who's respawning */

function RestartPlayer( Controller aPlayer )
{
    if ( aPlayer.PlayerReplicationInfo.bOutOfLives || aPlayer.Pawn!=None )
        return;

	/* temporary hack ... fixme please.*/
	if(KF_StoryNPC_AI(aPlayer) != none)
	{
	    return;
	}

	if(bDebugPlayerSpawning)
	{
		ClearStayingDebugLines();
	}

    /* So what we're doing here is reproducing the code in KFGameType which checks 'bWaveInProgress'
    Since Objective mode doesn't use that bool, we are checking IsTraderObj() which returns true if
    the game is currently in trader time, and players should be able to respawn */

    if( PlayerController(aPlayer)!=None && !IsTraderTime() )
    {
        aPlayer.PlayerReplicationInfo.bOutOfLives = True;
        aPlayer.PlayerReplicationInfo.NumLives = 1;
        aPlayer.GoToState('Spectating');
        Return;
    }

    log("**********************************************************************",'Story_Debug');
    log(" GAMEINFO  RESTART PLAYER - "@aPlayer.PlayerReplicationInfo.PlayerName,'Story_Debug');

	aPlayer.StartSpot = none;	// If StartSpothas a value all the RatePlayerStart() logic gets skipped ...

	Super.RestartPlayer(aPlayer);

	if( aPlayer.Pawn!=None)
	{
		if(StoryRules!=none)
		{
			StoryRules.ModifyPlayer(aPlayer.Pawn);
		}

		/* 	Some story missions might be focused around survival & scrounging for health
			This gives LDs the option of adding a health penalty to checkpoint respawns
		*/
		if(CurrentCheckPoint != none &&
		!CurrentCheckPoint.bStartEnabled &&
        CurrentCheckPoint.LastRespawnedPlayer == aPlayer)
		{
            CurrentCheckPoint.ModifyPlayer(aPlayer.Pawn);
		}
	}
}

/* Overriden to add allow LDs to toggle certain features of the cash reward / penalty setup for their story maps*/

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local float KillScore;

	OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None )
	{
		OtherPRI.NumLives++;
//		OtherPRI.Score -= ((OtherPRI.Score * (GameDifficulty * 0.05))* StoryRules.CashPenalty_Death_Modifier) ;	// you Lose 35% of your current cash on Hell on Earth, 15% on normal.
//		OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05 * StoryRules.CashPenalty_Death_Modifier));

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
//			Other.PlayerReplicationInfo.Score -= 1;
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
		KillScore = (LastKilledMonsterClass.Default.ScoringValue * StoryRules.CashReward_ZEDKills_Modifier);

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

//		KillScore = Max(1,int(KillScore));    dont clamp it in story mode.  It's likely some story maps will want to do without any kill score / rewards at all.
		Killer.PlayerReplicationInfo.Kills++;

		ScoreKillAssists(KillScore, Other, Killer);

		Killer.PlayerReplicationInfo.Team.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
	}

	if (Killer.PlayerReplicationInfo !=none && Killer.PlayerReplicationInfo.Score < 0)
		Killer.PlayerReplicationInfo.Score = 0;
}


/* Use the default player load-out specified in our LevelRules actor*/
function AddGameSpecificInventory(Pawn p)
{
	if(KFHumanPawn_Story(P) != none)
	{
		if( StoryRules!=none )
			StoryRules.AddGameInv(p);
	}
}


function AddDefaultInventory( pawn PlayerPawn )
{
    /* Story NPC's load inventory the usual unreal way .. */

    if(PlayerPawn.IsA('KF_StoryNPC'))
    {
        Super.AddDefaultInventory(PlayerPawn);
        return;
    }

	if (StoryRules != none)
	{
		if ( UnrealPawn(PlayerPawn) != None )
		{
			UnrealPawn(PlayerPawn).AddDefaultInventory();
		}
	}

	SetPlayerDefaults(PlayerPawn);
}


/* Return the 'best' player start for this player to start from.
*/

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint	Result;
	local PlayerReplicationinfo	PlayerPRI;
	local string PlayerName;

	Result = Super.FindPlayerStart(Player,InTeam,incomingName);

	if(bDebugPlayerSpawning)
	{
		PlayerPRI = Player.PlayerReplicationinfo;
		if(PlayerPRI != none)
		{
			PlayerName = PlayerPRI.PlayerName ;
		}
		else
		{
			PlayerName = incomingName ;
		}

		log(" Attempting to spawn : "@PlayerName@" at :"@Result,'Story_Debug');
	}

	Return Result;
}


function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local float Score;

	if(bDebugPlayerSpawning)
	{
		if(PlayerStart(N) != none)
		{
			if(PlayerStart(N).bEnabled)
			{
				DrawStayingDebugLine(N.Location, N.Location + (100 * vect(0,0,1)), 0,255,0);
			}
			else
			{
				DrawStayingDebugLine(N.Location, N.Location + (100 * vect(0,0,1)), 255,0,0);
			}
		}
	}

	Score =  Super.RatePlayerStart(N,Team,Player);
	return Score;
}

State MatchInProgress
{
	function BeginState()
	{
		Super.beginState();
		SetupPickups();
	}

	function SetupPickups()
	{
        local int i;

        if(StoryRules.bRandomizeWeaponPickups)
        {
            Super.SetupPickups();
        }
        else    // just activate whatever's placed.
        {
            for(i = 0 ; i < AmmoPickups.Length; i ++)
            {
                if ( AmmoPickups[i].bSleeping )
                {
                    AmmoPickups[i].GoToState('Pickup');
                }
            }
        }
	}

	/* This is probably a little aggressive but .. It looks like most, if not all of the code crunching away in
	KFGameType & Invasion's Timer is only really relevant to the waves / Invasion monster spawning setup */

	function Timer()
	{
        local Controller C;
        local bool OldForceRespawn;

		if(!bPlayingCinematic)
		{
            OldForceRespawn = bForceRespawn;
            bForceRespawn = false;
			Super(DeathMatch).Timer();
		    bForceRespawn = OldForceRespawn;
        }

		/* Kill off stragglers - Copied from KFGameType */
        if ( StoryRules != none &&
        StoryRules.bAutoKillStragglers &&
        NumMonsters <= StoryRules.MaxStragglers &&
        TotalMaxMonsters<=StoryRules.MaxEnemiesAtOnce  )
		{
            for ( C = Level.ControllerList; C != None; C = C.NextController )
			{
                if ( KFMonsterController(C)!=None && C.Pawn.Health > 0 && C.Pawn != none &&
                KFMonsterController(C).CanKillMeYet())
                {
                    C.Pawn.KilledBy( C.Pawn );
				    Break;
                }
			}
        }
	}


    /* Debug function -  quickly jump to a specific objective */
    function GoToForcedObj()
    {
        local Controller C;
        local ScriptedController SC;
        local int i,idx;

        if(ForcedTargetObj == none ||
        CurrentObjective == ForcedTargetObj)
        {
            return;
        }

        /* Move Dialogue forwad*/
        for(i = 0 ; i < AllDialogue.length ; i ++)
        {
            for(idx = 0 ; idx < (AllDialogue[i].Dialogues.Length-AllDialogue[i].CurrentMsgIdx) ; idx ++)
            {
                AllDialogue[i].TraverseDialogue();
            }
        }

        /* Gotta move scripted sequences forward as well, in case they're pausing for Latent Actions */
        for(C = Level.ControllerList ; C!= none ; C=C.nextController)
        {
            SC = ScriptedController(C);
            if(SC != none &&
            SC.SequenceScript != none &&
            SC.GetStateName() == 'Scripting' &&
            SC.CurrentAction != none)
            {
                for(i = 0 ; i < (SC.SequenceScript.Actions.length); i ++)
                {
                    /* IF there's a MoveToGoal action in there just Teleport the dude to his destination */
                    if(SC.CurrentAction.MoveToGoal() && SC.Pawn != none )
                    {
//                      log("TELEPORT -> "@SC.Pawn@" to ----> "@SC.CurrentAction.GetMoveTargetFor(SC));
                        SC.Pawn.SetLocation(SC.CurrentAction.GetMoveTargetFor(SC).Location);
                    }

                    /* Timed Actions complete instantly */
                    if(SC.CurrentAction.CompleteWhenTimer())
                    {
                        SC.SetTimer(0.f,false);
                    }

                    /* No waiting for animations */
                    if(SC.CurrentAction.CompleteOnAnim(0))
                    {
                        SC.AnimEnd(0);
                    }
                    if(SC.CurrentAction.CompleteOnAnim(1))
                    {
                        SC.AnimEnd(1);
                    }
                }
            }
        }

        if(CurrentObjective != none)
        {
            CurrentObjective.ForceCompleteObjective();
        }

        /* And Turn off any active wave designers as well */
        for( i = 0 ; i < AllWaveDesigners.length ; i ++)
        {
            for(idx = 0 ; idx < AllWaveDesigners[i].Waves.length ; idx ++)
            {
                if(AllWaveDesigners[i].Waves[idx].WaveController != none &&
                AllWaveDesigners[i].Waves[idx].Wavecontroller.bActive)
                {
                    AllWaveDesigners[i].Waves[idx].WaveController.AbortWave(self);
                    AllWaveDesigners[i].Waves[idx].WaveController.KillStragglers();
                }
            }
        }
    }
}





/* 	KFGameType's implementation of ReduceDamage contains a wealth of bizarre hacks ..
	for simplicity's sake let's just jump back to Invasion's implementation


function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int Result;

	Result = Super(Invasion).ReduceDamage(Damage,Injured,InstigatedBy,HitLocation,Momentum,DamageType);
	return	Result;
}
*/

/* 	Differs from KillBots() in that it is not removing the bots from play,  just killing their pawns.
	Using this to debug Checkpoint spawning /w AIs
*/


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

		return Damage;
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


/*
exec function ExplodeBots(int num)
{
	local int NumKilled;
	local Controller C;

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
		if(NumKilled == Num)
		{
			break;
		}

		if(AIController(C) != none && C.Pawn != none)
		{
   			C.Pawn.Died(C,class 'Gibbed',C.Pawn.Location);
   			NumKilled ++ ;
		}
	}
}
*/

/*
exec function NPCGod(bool On)
{
	local Controller C;

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
        if(C.IsA('KF_StoryNPC_AI') ||
        C.Pawn != none &&
        C.Pawn.IsA('KF_StoryNPC'))
        {
            C.bGodMode = On;
        }
	}
}
*/

/* ==== Objective Debug Functions =================================*/

/*
exec function ShowObjs()
{
    local int i;

    for(i = 0 ; i < AllObjectives.length ; i ++)
    {
        Level.GetLocalPlayerController().ClientMessage("["$i+1$"]"@AllObjectives[i].ObjectiveName);
    }
}

exec function FailObj()
{
    if(CurrentObjective != none)
    {
        if(CurrentObjective.bFailed)
        {
            Level.GetLocalPlayerController().ClientMessage("WARNING : ["@CurrentObjective.ObjectiveName@"] is already FAILED.  ");
            return ;
        }

        CurrentObjective.ObjectiveFailed(CurrentObjective.Instigator.Controller);
    }
}
*/


/* ===== Extended Zombie Spawning Support ===========================================================================
======================================================================================================================*/


function	bool	 SpawnZEDsInVolume(ZombieVolume 	V,  int DesiredSquadSize, optional out int NumZEDsSpawned, optional bool TryOtherVolumesOnFail )
{
	local int numspawned;
	local int TotalZombiesValue;
	//local int i;

	if(V == none || DesiredSquadSize == 0 || NextSpawnSquad.length == 0)
	{
	    return false;
	}

	if( V.StorySpawnInHere(NextSpawnSquad,,numspawned,DesiredSquadSize,DesiredSquadSize,TotalZombiesValue) )
	{
		NumZEDsSpawned  = numSpawned;
		NumMonsters    += numspawned;
		WaveMonsters   += numspawned;
//      TotalMaxMonsters = DesiredMaxZEDs - NumMonsters;

        // Log what the squad is after spawning
        /*for(i=0; i < NextSpawnSquad.length ; i ++)
        {
            log("SpawnZEDsInVolume NextSpawnSquad after spawn: zombie "$NextSpawnSquad[i]$" number "$i);
        }*/

		return true;
	}

    return false;
}

/* Difficulty Scaling Accessors =============================================
============================================================================= */
/* Returns modifiers to use with the max zombie spawn count
*/

function float GetGameDifficultyModifier()
{
	local float DifficultyMod;

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

	return DifficultyMod;
}


function float GetPlayerCountModifier()
{
	local int UsedNumPlayers;
	local float NumPlayersMod;

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

	return NumPlayersMod;
}

/* Returns a modifier to apply to ZED SpawnIntervals (Wave Designer & Story Volumes) */
function float GetAdjustedSpawnInterval(float BaseInterval, float UsedWaveTimeElapsed, bool bIgnoreSineMod)
{
    local float SineMod;
    local float FinalInterval;
    local int TotalNumPlayers;
    local float PlayerCountMultiplier;
    local float DifficultyMultiplier;

    PlayerCountMultiplier  = 1.f;
	SineMod                = 1.0 - Abs(sin(UsedWaveTimeElapsed * SineWaveFreq));
    DifficultyMultiplier   = 1.f;

    // Make the zeds come a little faster at all times on harder and above
    if ( GameDifficulty >= 4.0 ) // Hard
    {
        DifficultyMultiplier = 0.85;
    }

    /* Scale the spawn interval by the number of players */
    TotalnumPlayers = NumPlayers + NumBots ;
    if( TotalnumPlayers == 1 )
    {
        PlayerCountMultiplier = 3.0;
    }
    else if( TotalnumPlayers == 2 )
    {
        PlayerCountMultiplier = 1.5;
    }
    else if( TotalnumPlayers == 3 )
    {
        PlayerCountMultiplier = 1.0;
    }
    else if( TotalnumPlayers == 4 )
    {
        PlayerCountMultiplier = 0.85;
    }
    else if( TotalnumPlayers == 5 )
    {
         PlayerCountMultiplier = 0.65;
    }
    else if( TotalnumPlayers >= 6 )
    {
         PlayerCountMultiplier = 0.3;
    }

    //log("Base Spawn Interval    : "@BaseInterval,'Story_Debug');
    if( bIgnoreSineMod )
    {
        //log("Sine Multiplier        : Ignored",'Story_Debug');
        FinalInterval = FMax(BaseInterval * PlayerCountMultiplier * DifficultyMultiplier,0.1);
    }
    else
    {
        //log("Sine Multiplier        : "@SineMod,'Story_Debug');
        FinalInterval = FMax((BaseInterval +  (SineMod * (BaseInterval*2))) * PlayerCountMultiplier * DifficultyMultiplier,0.1) ;
    }

    /*log("Player Multiplier      : "@PlayerCountMultiplier,'Story_Debug');
    log("Difficulty Multiplier  : "@DifficultyMultiplier,'Story_Debug');
    log("Final Interval         : "@FinalInterval);
    log("UsedWaveTimeElapsed    : "@UsedWaveTimeElapsed);*/

	return FinalInterval;

}

/*==================================================================================
====================================================================================*/

/* looks up a squad of the supplied name in the GameInfo's cached Squads list */

function KFStoryGameInfo.SZEDSquadType     FindSquadByName(string SquadName, optional out int Index)
{
    local int i;
    local SZEDSquadType ExportSquad;

    for(i = 0 ; i < AllSquads.length ; i ++)
    {
        if(AllSquads[i].Squad_Name == SquadName)
        {
            Index = i;
            ExportSquad = AllSquads[i] ;
            break;
        }
    }

    if(ExportSquad.Squad_Name == "")
    {
       log("Warning - could not find a suitable struct for Squad of Name : "@SquadName);
    }

    return ExportSquad;
}

/* looks like this function is only implemented in State MatchInProgress .. adding a stub here so we don't get weird results / crashes */
function float CalcNextSquadSpawnTime()
{
	return 1.f;
}

/* Matinee Support  ==============================================================================================
===================================================================================================================*/


event SceneEnded( SceneManager SM, Actor Other )
{
	bPlayingCinematic = false ;
}

/* cinematic started... */
event SceneStarted( SceneManager SM, Actor Other )
{
	if ( SM != none  )
	{
		bPlayingCinematic = true;
	}
}

function bool IsPlayingMatinee()
{
	return bPlayingCinematic ;
}


function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
	/* No ZED time during matinee */
	if(IsPlayingMatinee())
	{
		return;
	}

	Super.DramaticEvent(BaseZedTimePOssibility);
}

defaultproperties
{
     CurrentObjectiveIdx=-1
     CheckPointMessageClass=Class'KFStoryGame.Msg_CheckPoint'
     bNoBots=False
     bUseZEDThreatAssessment=True
     TeamAIType(0)=Class'KFStoryGame.KFTeamAI_Story'
     TeamAIType(1)=Class'KFStoryGame.KFTeamAI_Story'
     DefaultEnemyRosterClass="KFStoryGame.KFStoryRoster"
     ScoreBoardType="KFStoryGame.KFScoreboard_Story"
     HUDType="KFStoryGame.HUD_StoryMode"
     MapListType="KFStoryGame.KFOMapList"
     MapPrefix="KFO"
     MutatorClass="Engine.Mutator"
     PlayerControllerClass=Class'KFStoryGame.KFPlayerController_Story'
     GameReplicationInfoClass=Class'KFStoryGame.KF_StoryGRI'
     GameName="Objective Mode"
     Description="Custom objective/story mode for Killing Floor."
     Acronym="KFO"
}
