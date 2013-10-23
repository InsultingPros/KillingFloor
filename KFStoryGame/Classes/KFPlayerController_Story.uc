/*
	--------------------------------------------------------------
	KFPlayerController_Story
	--------------------------------------------------------------

	Custom PlayerController class for use in Killing Floor 'Story' maps.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KFPlayerController_Story extends KFPlayerController ;

/* number of times this player has been respawned by the current CheckpointVolume */
var			int						    NumCheckPointRespawns;

/* reference to the last Trader Shop we used */
var			KFShopVolume_Story		    CurrentShopVolume;

var         KF_StoryCheckPointVolume    CurrentCheckPoint;

var         bool                        bShowObjectiveDebug;

/* == Checkpoint Data ===================================================================

Stuff we want to keep track of when this player is 'checkpointed' during a story mission.

=========================================================================================
*/

/* array of equipment the pawn was holding when he last activated a checkpoint */
var			array<String>           SavedLoadOut;

/* the ammo counts for weapons this player had at the time they last activated a checkpoint */
var         array<Int>              SavedAmmo;

/* the magazine ammo counts for weapons this player had at the time they last activated a checkpoint */
var         array<Int>              SavedMagAmmo;

/* the cash this player had at the time he last activated a checkpoint */
var         float                   SavedCash;

/* the amount of health this player had at the time he last activated a checkpoint */
var         int                     SavedHealth;

/* the amount of body armor this player had at the time he last activated a checkpoint */
var         int                     SavedArmor;

/* If we are doing a trader time objective this is the number of seconds left before it completes */
var         float                   RemainingTraderTime;


replication
{
	unreliable if(Role == Role_Authority)
		SetClientWhispClr,ClientSetUV2Tex,UnReliableConditionUpdate;

	reliable if(Role == Role_Authority)
	   CurrentShopVolume,ReliableConditionUpdate,ClientShowStoryDialogue, ClientPlayStorySound;

	unreliable if( Role<ROLE_Authority )
		ServerStopUsing,ServerCompleteObj,ServerFFObj;

	reliable if (Role <ROLE_Authority)
	   ServerReadyLateJoiner;
}

simulated function ClientSetUV2Tex(Actor TargetActor , Material NewUV2Tex)
{
    TargetActor.UV2Texture = NewUV2Tex;
}

simulated function ClientShowStoryDialogue(name DialogueActor, int DlgIndex, float DisplayDuration)
{
	if(HUD_StoryMode(myHUD)  != none)
	{
		HUD_StoryMode(myHUD).AddDialogue(DialogueActor,DlgIndex,DisplayDuration);
	}
}

// Play a story mode sound on the client
// If bAdjustPitch = true then the sound will be adjusted to the game pitch
// based on the game speed (i.e. lower pitch if zed time is enabled). If it
// is false it will not be adjusted with the game speed
simulated function ClientPlayStorySound(sound ASound, float Volume, bool bAdjustPitch )
{
    local float UsedPitch;

    UsedPitch = 1.0;

    if( bAdjustPitch )
    {
        UsedPitch = 1.0;
    }
    else
    {
        UsedPitch = 1.1 / Level.TimeDilation;
    }

	if ( ViewTarget != None )
		ViewTarget.PlayOwnedSound(ASound,Slot_Interface,Volume,true,,UsedPitch,false);
	else
        PlayOwnedSound(ASound,Slot_Interface,Volume,true,, 1.1 / Level.TimeDilation, false);
}

exec simulated function ToggleConditionStack()
{
	if(HUD_StoryMode(myHUD)  != none)
	{
        HUD_StoryMode(myHUD).bCollapseConditions = !HUD_StoryMode(myHUD).bCollapseConditions;
	}
}

/* Called on the client - Updates condition data unreliably */
simulated function UnreliableConditionUpdate(
KF_ObjectiveCondition UpdatedCondition,
KF_StoryObjective ObjOwner,
float NewProgressPct,
Actor NewLocActor,
string NewDataString,
bool NewComplete)
{
    DoConditionUpdate(UpdatedCondition,ObjOwner.Name,NewProgressPct,NewLocActor,UpdatedCondition.GetHUDHint()@NewDataString,NewComplete, '');
}

/* Called on the client - Updates condition data reliably */
simulated function ReliableConditionUpdate(
KF_ObjectiveCondition UpdatedCondition,
KF_StoryObjective ObjOwner,
float NewProgressPct,
Actor NewLocActor,
string NewDataString,
bool NewComplete)
{
	local name PendingLocActorTag;
	/*
    log(" *** RELIABLE CONDITION UPDATE ******************************************************");
    log(" >>> "@UpdatedCondition);
    log(" *** Progress Percent :"@NewProgressPct);
    log(" *** Data String      :"@NewDataString);
    log(" *** Complete?        :"@NewComplete);
    */
    // If we have an actors tag, but no actor Queue him with PendingLocActorTag to grab his reference later.
    // This is pretty much a hack to get around cases where we are trying to grab a reference to an actor which
    // does not yet exist on the client .

	if (NewLocActor == none )
	{
	    if( UpdatedCondition.IsA('ObjCondition_ActorHealth') )
	    {
		    PendingLocActorTag = ObjCondition_ActorHealth(UpdatedCondition).TargetPawnTag;
		}
		else if( UpdatedCondition.IsA('ObjCondition_Use') )
		{
		    PendingLocActorTag = ObjCondition_Use(UpdatedCondition).UsePawn_Tag;
		}
    }

    DoConditionUpdate(UpdatedCondition,ObjOwner.Name,NewProgressPct,NewLocActor,UpdatedCondition.GetHUDHint()@NewDataString,NewComplete,PendingLocActorTag);
}

simulated function DoConditionUpdate(
KF_ObjectiveCondition UpdatedCondition,
name ObjOwner,
float NewProgressPct,
Actor NewLocActor,
string NewDataString,
bool NewComplete,
name PendingLocActorTag)
{
    local ObjCondition_Timed  TimeCondition;

    if(HUD_StoryMode(myHUD) == none)
    {
        log(" WARNING -  NO HUD AVAILABLE FOR : "@self@" CLIENT CONDITION UPDATE WILL FAIL. ",'Story_Debug');
    }

    if(Level.NetMode == NM_DedicatedServer ||
    HUD_StoryMode(myHUD) == none ||
    UpdatedCondition == none ||
    ObjOwner == '')
    {
        return;
    }

    TimeCondition = ObjCondition_Timed(UpdatedCondition);
    if(TimeCondition != none &&
    TimeCondition.bTraderTime)
    {
        RemainingTraderTime = TimeCondition.Duration - (TimeCondition.Duration * NewProgressPct);
    }

    HUD_StoryMode(myHUD).UpdateConditionHint(
    UpdatedCondition.name,
    ObjOwner,
    NewProgressPct,
    NewLocActor,
    NewDataString,
    NewComplete,
	PendingLocActorTag);
}


simulated function SetClientWhispClr(color NewWhispClr)
{
    Class'Objective_Whisp'.default.mColorRange[0] = NewWhispClr;
	Class'Objective_Whisp'.default.mColorRange[1] = NewWhispClr;
}


/* This player's progress was saved at a checkpoint */
function SaveLoadOut()
{
    if(PlayerReplicationInfo != none)
    {
        SavedCash = PlayerReplicationInfo.Score;
    }

    if(KFHumanPawn_Story(Pawn) != none)
    {
        KFHumanPawn_Story(Pawn).SaveLoadOut() ;
    }
}

/* Overriden to ensure it opens up the story-friendly version of the Trader Buy Menu */

function ShowBuyMenu(string wlTag,float maxweight)
{
	StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu
	ClientOpenMenu("KFStoryUI.GUIBuyMenu_Story",,wlTag,string(maxweight));
}

// Send a voice message of a certain type to a certain player.

/* Added a hack to filter out trader voices */

function ServerSpeech( name Type, int Index, string Callsign )
{
	if(Type != 'TRADER')
	{
		Super.ServerSpeech(Type,Index,Callsign);
	}
}

function SetPawnClass(string inClass, string inCharacter)
{
	Super.SetPawnClass(inClass,inCharacter);
	/* @todo -  why doesn't GetDefaultPlayerClass() work ? */
//	PawnClass = Level.Game.GetDefaultPlayerClass(self);  //	PawnClass = Class'KFHumanPawn';
	PawnClass = class 'KFStoryGame.KFHumanPawn_Story';
}


/*
	Helper function for quickly determining whether a player is looking at a point in space.
	original author :  Ron Prestenback.

 * @param	TargetLocation	the location to check
 * @param	MinDotResult	a value between 0 and 1 representing the minimum dot result value that should be
 *							considered acceptable for testing whether the location is within our field of
 *							view.  (Default value is corresponds to a maximum angle of around 47 degrees)
 *
 * @return	TRUE if the location is within the angle specified from the player's line of sight.
 */
simulated function bool IsLookingAtLocation( vector TargetLocation, optional float MinDotResult)
{
	local vector DirectionNormal, EyesLoc;
	local rotator EyesRot;
	local float ViewAngleCosine;

	// get the location and rotation of the camera
	EyesLoc = CalcViewLocation;;
	EyesRot = CalcViewRotation;

	// get the normalized distance between the two locations
	DirectionNormal = Normal(TargetLocation - EyesLoc);

	// get the dot result of the player's view location and the target location
	ViewAngleCosine = DirectionNormal dot vector(EyesRot);

	// determine if the angle between our camera's rotation and the target location is within range.
//	log("IS LOOKING AT LOCATION - "@ViewAngleCosine@" Required : "@MinDotResult);
	return ViewAngleCosine >= MinDotResult;
}


simulated function bool HasLineOfSightTo( vector TargetLocation)
{
	return IsLookingAtLocation(TargetLocation,0.5f) && FastTrace(CalcViewLocation, TargetLocation) && FastTrace(TargetLocation,CalcViewLocation);	//EyePostion() is returning a funny value sometimes.  Not sure why. C.Pawn./*EyePosition()*/Location
}

/* Extended 'Use' functionality - Support for OnRelease events */

// The player wants to stop using something in the level.
exec function StopUsing()
{
	ServerStopUsing();
//	log(self@"stopped pressing Use");
}


/* === Server Debug Commands ==================
===============================================*/

/* Fast Forward*/
exec function FFObj(name ObjName)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        return;
    }

    ServerFFObj(ObjName);
}

/* Helpful function for level Designers testing objectives at different stages in their map

Changes the active objective to the one provided.  If bSimulateCompletion,  it will also fast forward
through the Objective chain in an attempt to simulate actual player progression.  */

function ServerFFObj(name ObjName)
{
    local KF_StoryObjective NewObj;
    local KFStoryGameInfo StoryGI;

    StoryGI = KFStoryGameInfo(Level.Game);
    if(StoryGI == none)
    {
        return;
    }

    NewObj = StoryGI.FindObjectiveNamed(ObjName);
    if(NewObj != none && !StoryGI.bGameEnded )
    {
        if(!NewObj.IsValidForActivation())
        {
            ClientMessage("WARNING : ["@NewObj.ObjectiveName@"] has already been completed and is a non-recurring objective. It cannot be activated");
            return ;
        }

        if(NewObj != StoryGI.CurrentObjective)
        {
            StoryGI.ForcedTargetObj = NewObj;
            StoryGI.bSkipDialogue = true;

            if(KF_StoryGRI(StoryGI.GameReplicationInfo) != none)
            {
                KF_StoryGRI(StoryGI.GameReplicationInfo).SetDebugTargetObj(NewObj);
            }

            StoryGI.GoToForcedObj();
            ClientMessage("Fast tracking to ... "@NewObj.ObjectiveName,'CriticalEventPlus');
        }
    }
    else
    {
        ClientMessage("WARNING : cannot find objective : "@ObjName);
    }
}



exec function CompleteObj()
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        return;
    }

    ServerCompleteObj();
}

function ServerCompleteObj()
{
    local KF_StoryObjective CurrentObjective;

    if(KFStoryGameInfo(Level.Game) != none )
    {
        CurrentObjective = KFStoryGameInfo(Level.Game).CurrentObjective ;
        if(CurrentObjective != none)
        {
            if(CurrentObjective.bCompleted)
            {
                Level.GetLocalPlayerController().ClientMessage("WARNING : ["@CurrentObjective.ObjectiveName@"] is already COMPLETE.  ",'Story_Debug');
                return ;
            }

              CurrentObjective.ForceCompleteObjective();
        }
    }
}

exec function StartUsing()
{
	Super.ServerUse();
}

function ServerUse()
{
    Super.ServerUse();

    /* Hackey hack time!*/
    if(KFStoryGameInfo(Level.Game) != none &&
    KFStoryGameInfo(Level.Game).CurrentObjective != none)
    {
        KFStoryGameInfo(Level.Game).CurrentObjective.UsedBy(pawn);
    }
}

function ServerStopUsing()
{
	if ( Role < ROLE_Authority )
		return;

	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}

	if (Pawn == None || !Pawn.bCanUse)
		return;

   /* Hackey hack time!*/
   if(KFStoryGameInfo(Level.Game) != none &&
   KFStoryGameInfo(Level.Game).CurrentObjective != none)
   {
       KFStoryGameInfo(Level.Game).CurrentObjective.StoppedUsing(pawn);
   }
}

exec function SoakAI()
{
	local AIController Bot;

	log("Start Soaking");
	UnrealMPGameInfo(Level.Game).bSoaking = true;
	ForEach DynamicActors(class'AIController',Bot)
		Bot.bSoaking = true;
}

exec function ObjDebug()
{
    bShowObjectiveDebug = !bShowObjectiveDebug;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local KFStoryGameInfo StoryGI;
    local int i;

    StoryGI = KFStoryGameInfo(Level.Game);
	if (StoryGI != none && bShowObjectiveDebug)
	{
		Canvas.SetDrawColor(50, 255, 50);
		Canvas.DrawText("========== OBJECTIVE LIST ======================");

		for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
		{
            Canvas.DrawText("["$i+1$"]"@StoryGI.AllObjectives[i].ObjectiveName);
		}

		YPos += YL/2;
		Canvas.SetPos(4, YPos);
	}
	else
	{
	   Super.DisplayDebug(Canvas, YL, YPos);
	}
}

simulated function UpdateHintManagement(bool bUseHints)
{
    if (Level.GetLocalPlayerController() == self)
    {
        if (bUseHints && HintManager == none)
        {
            HintManager = spawn(class'KFHintManager_Story', self);
            if (HintManager == none)
                warn("Unable to spawn hint manager");
        }
        else if (!bUseHints && HintManager != none)
        {
            HintManager.Destroy();
            HintManager = none;
        }

        if (!bUseHints)
            if (HUDKillingFloor(myHUD) != none)
                HUDKillingFloor(myHUD).bDrawHint = false;
    }
}

function ServerThrowWeapon()
{
	// If we have any story items, throw them one at a time
    if( KFHumanPawn_Story(Pawn) != none &&
		KFHumanPawn_Story(Pawn).IsCarryingThrowableInventory())
    {
    	KFHumanPawn_Story(Pawn).TossSingleCarriedItem();
    }
    else
    {
	    super.ServerThrowWeapon();
    }
}

/* A late joining client wants to tell the server he's ready to play .. */
function ServerReadyLateJoiner()
{
	if ( !Level.Game.bWaitingToStartMatch )
		PlayerReplicationInfo.bReadyToPlay = true;
}

function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange)
{
	if ( VetSkill == none || KFPlayerReplicationInfo(PlayerReplicationInfo) == none )
	{
		return;
	}

	if ( KFSteamStatsAndAchievements(SteamStatsAndAchievements) != none )
	{
		SetSelectedVeterancy( VetSkill );

		if ( KFStoryGameInfo(Level.Game) != none &&              // another place where we gotta use IsTraderObj()  instead of bWaveInProgress ...
        !KFStoryGameInfo(Level.Game).IsTraderTime() &&
         VetSkill != KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill )
		{
			bChangedVeterancyThisWave = false;
			ClientMessage(Repl(YouWillBecomePerkString, "%Perk%", VetSkill.Default.VeterancyName));
		}
		else if ( !bChangedVeterancyThisWave || bForceChange )
		{
			if ( VetSkill != KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill )
			{
				ClientMessage(Repl(YouAreNowPerkString, "%Perk%", VetSkill.Default.VeterancyName));
			}

			if ( GameReplicationInfo.bMatchHasBegun )
			{
				bChangedVeterancyThisWave = true;
			}

			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill = VetSkill;
			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = KFSteamStatsAndAchievements(SteamStatsAndAchievements).PerkHighestLevelAvailable(VetSkill.default.PerkIndex);

			if( KFHumanPawn(Pawn) != none )
			{
				KFHumanPawn(Pawn).VeterancyChanged();
			}
		}
		else
		{
			ClientMessage(PerkChangeOncePerWaveString);
		}
	}
}


state Dead
{     /*
	function Timer()
	{
			There was some forced respawn code in KFGameType's implementation ...
			I'm trying to cut out anything that could interfere with
			the Story game's checkpoint respawn system

		super(PlayerController).Timer();
	} 	*/

	function Timer()
	{
        /* I REALLY hate to do this, but it's the only way to get it to work like it does in KFGameType*/
	    if ( KFGameType(Level.Game) != none && Level.Game.GameReplicationInfo.bMatchHasBegun &&
			 Role == ROLE_Authority && KFStoryGameInfo(Level.Game).IsTraderTime() )
		{
			PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash, int(PlayerReplicationInfo.Score));
			SetViewTarget(self);
			ClientSetBehindView(false);
			bBehindView = False;
			ClientSetViewTarget(Pawn);
			PlayerReplicationInfo.bOutOfLives = false;
			Pawn = none;
			ServerReStartPlayer();
		}

		super.Timer();
	}

}

defaultproperties
{
     LobbyMenuClassString="KFStoryUI.LobbyMenu_Story"
     PlayerReplicationInfoClass=Class'KFStoryGame.KF_StoryPRI'
}
