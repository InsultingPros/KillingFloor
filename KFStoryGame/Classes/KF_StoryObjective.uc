/*
	--------------------------------------------------------------
	KF_StoryObjective
	--------------------------------------------------------------

    Placeable Objective Actor which stores a set of Conditions and
    Actions.

    Conditions determine how to complete the objective while actions
    determine what happens once the objective is completed. Objective
    progress is handled server-side and there can only be one active
    objective at a time per server.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryObjective extends StoryObjectiveBase
	HideCategories(Sound)
	dependson(KFStoryGameInfo)
	placeable ;

#exec OBJ LOAD FILE=KFStoryGame_Tex.utx

const MAXCONDITIONS = 6;


var(Debug)                                  bool                         bDebugConditionInstancing;

/* Cached reference to Story gameinfo to cut down on typecasting */
var											KFStoryGameInfo	 		     StoryGI;

/* Assigned when a checkpoint has set this Objective as its 'RestartFromObjective'. */
var                                         KF_StoryCheckPointVolume     ActiveCheckPoint;

var array<Actor> RelevantActors;

/* ====================== HUD =======================================================================

=====================================================================================================*/

var(Objective_HUD)                          KFStoryGameInfo.SObjectiveHeaderInfo        HUD_Header;

var(Objective_HUD)                          KFStoryGameInfo.SObjectiveBackGroundInfo    HUD_Background;

/* should we show this objective on the HUD at all ? */
var(Objective_HUD)							bool					bShowOnHUD;

/* displays on the HUD -  gives the player a hint about what his current objective is */
var							                localized string   	    ObjectiveHint;

/* for letting the player know what kind of failure condition this objective has (if any) */
var/*(Objective_HUD)*/						string				    ObjectiveFailureHint;

/* local message to display when the objective is successfully completed */
var                 						localized string	    SuccessText;

/* local message to display when the objective is failed */
var             							localized string		FailureText;

var                                         texture                 BackgroundTexture;

var                                         bool                    bBGScaleUniform;

var(Objective_HUD)                          KFStoryGameInfo.SVect2D HUD_ScreenPosition;

var                                         color                   Header_Clr;


/* Un-touched Hintstring ( before we append timer info )*/
var											string					InitialHint;

var                                         float                   StartTime;

/* Replication Throttling ===========================================================================*/

/* Number of replication updates that have been pushed in the last second for conditions belonging to this objective */
var                                         int                     CurrentRepUpdates;

/* Maximum number of condition replication updates per second for conditions belonging to this objective */
var                                         int                     MaxRepUpdatesPerSecond;

/* ====================== Audio =======================================================================

=====================================================================================================*/


/* Sounds to play when the Objective is completed or becomes active, respectively. */
var(Objective_Audio)    					Sound   				CompletionSound,ActivationSound,FailureSound;

var(Objective_Audio)						localized string		ObjectiveInProgressMusic;

var(Objective_Audio)						float					MusicFadeInTime,MusicFadeOutTime;

var(Objective_Audio)						bool					bStopMusicOnCompletion;

var											string					CompletionSoundName,ActivationSoundName;


/* ====================== General Settings ===========================================================

=====================================================================================================*/

/* Can checkpoints save/restart from this objective ? */
var(Objective_Settings)                     bool                    bCheckPointable;

/* Can this objective be completed more than once without a checkpoint / level reset ? */
var(Objective_Settings)                     bool                    bRecurring;

/* Is this whole objective not mandatory for players to complete ? */
var(Objective_Settings)                     bool                    bOptional;

/* if true this objective & its conditions should revert to their starting state when this obj is no longer active .  Defaults true*/
var(Objective_Settings)                     bool                    bResetOnDeactivation;

/* ====================== Events =====================================================================

=====================================================================================================*/


/* Events to use when the Objective becoems active / completes respectively.  Reduces the need for multiple trigger actors / scripted actions */
var(Objective_Events)						array<name>				ActivationEvents;

/* Events to call when the Objective is de-activated (either by failing, succeeding, or simply switching to another objective via cheats */
var(Objective_Events)                       array<name>             DeActivationEvents;

/* Events to fire off when the Objective is marked 'Complete' */
var(Objective_Events)						array<name>				CompletionEvents;

/* Events to fire off when the Objecvtive is marked 'Failed ' */
var(Objective_Events)						array<name>				FailureEvents;

/* =====================================================================================
=======================================================================================*/

/* true when ObjectiveCompleted() has been called. This Objective cannot be activated again */
var											bool					bCompleted;

/* true if this objective had a secondary condition that was not met */
var											bool					bFailed;


/* ====================== Success CONDITIONS ========================================================

Specifies a type of condition the player will succeed in completing the objective if he satisfies

=====================================================================================================*/

var(Objective_Conditions)                   export editinlineuse array<KF_ObjectiveCondition>  SuccessConditions;

var(Objective_Conditions)                   export editinlineuse array<KF_ObjectiveCondition>  OptionalConditions;

var                                         bool                                               bPendingSuccessActions;

var                                         bool                                               bPendingFailureActions;


/* OBJ_Touch vars ============================================================================
==============================================================================================*/

/* true if Touch() was called on this objective by a valid instigator. OBJ_Touch objectives will be considered complete the next tick */
var											bool					bWasTouched;

/* OBJ_Triggered vars ========================================================================
==============================================================================================*/

var                                         bool                    bWasUsed;

/* ====================== FAILURE CONDITIONS ========================================================

Specifies a type of condition the player will fail the objective if he does not satisfy.

=====================================================================================================*/

var(Objective_Conditions)                   export editinlineuse array<KF_ObjectiveCondition>    FailureConditions;

/* Conditions in this array are active & ticked */
var                                         array<KF_ObjectiveCondition>                         AllConditions;

/* Condition Instancing ================================================================================ */

/* If set - this objective's own failure condition will be ignored in place of the F.C in the specified Objective. */
var(Objective_Instancing)		            name						                         Copy_FailureConditions_From;

/* first objective in the Failure conditions' linked list */
var										    KF_StoryObjective		                             FirstFailureParent;

/* If set - this objective's own success condition will be ignored in place of the F.C in the specified Objective. */
var(Objective_Instancing)		            name					                             Copy_SuccessConditions_From;

var									        KF_StoryObjective		                             FirstSuccessParent;

var                                         KF_StoryObjective                                    FirstOptionalParent;

/* If set - this objective's own success condition will be ignored in place of the F.C in the specified Objective. */
var(Objective_Instancing)		 	        name					                             Copy_OptionalConditions_From;

var(Objective_Instancing)                   name                                                 Copy_FailureActions_From;

var(Objective_Instancing)                   name                                                 Copy_SuccessActions_From;

var                                         KF_StoryObjective                                    Action_FirstFailureParent;

var                                         KF_StoryObjective                                    Action_FirstSuccessParent;

var                                         float                                                LastWhispTime;

var                                         float                                                WhispInterval;

var                                         bool                                                 bShowWhispTrails;

var                                         float                                                RemainingTime;


/* Called in GameInfo.PostLogin() */
function OnPlayerJoined(Controller JoiningPlayer)
{
    local int i;
    local KFPlayerController_Story KFSPC;

    KFSPC = KFPlayerController_Story(JoiningPlayer);
    if(KFSPC == none)
    {
        return;
    }

    /* Push Existing Condition data through to newly connected client */
    for(i = 0 ; i < AllConditions.Length ; i ++)
    {
        AllConditions[i].ReliableConditionUpdate(KFSPC);
    }
}

/* Event called when player leaves the game - Update Condition values*/
function OnPlayerLeft(Controller LeavingPlayer){}
/* Event called when the objective list finishes sorting / populating in the gameinfo */
function OnObjPopulationComplete(){}


simulated function PostBeginPlay()
{
    local int i;

	Super.PostBeginPlay();

	InitialHint = ObjectiveHint;
	StoryGI = KFStoryGameInfo(level.Game);

    /* No KFO Gametype, no Initialization */
	if(StoryGI == none)
	{
	   return;
	}

	for(i = 0 ; i < SuccessConditions.length ; i ++)
	{
	   SuccessConditions[i].PostBeginPlay(self);
	}
	for(i = 0 ; i < OptionalConditions.length ; i ++)
	{
	   OptionalConditions[i].PostBeginPlay(self);
	}
	for(i = 0 ; i < FailureConditions.length ; i ++)
	{
	   FailureConditions[i].PostBeginPlay(self);
	}

	SetTimer(1.0,true);
}

/* Throttle the amount of data that is being replicated to clients */
function bool AllowConditionRepUpdate()
{
    if(CurrentRepUpdates >= MaxRepUpdatesPerSecond ||
    Level.Pauser != none)
    {
        return false;
    }

    return true;
}

function Timer()
{
    CurrentRepUpdates = 0;
}


/* Adds a condition to the 'AllConditions' array in this objective.  This means that
the condition will then be ticked & Displayed on the HUD, etc. */

function ActivateCondition( KF_ObjectiveCondition NewCondition)
{
    if(FindConditionByName(NewCondition.name) == none)
    {
        AllConditions[AllConditions.length] = NewCondition;
        NewCondition.ConditionActivated(Instigator);
    }
}

function DeActivateCondition( KF_ObjectiveCondition OldCondition)
{
    local int i;

    for(i = 0 ; i < AllConditions.length ; i ++)
    {
        if(AllConditions[i] == OldCondition)
        {
            AllConditions[i].ConditionDeActivated();
            AllConditions.Remove(i,1);
            i -- ;
        }
    }
}

/* 0 == Failure Condition, 1 == Success */
simulated function byte GetNamedConditionType( name ConditionName)
{
    local int i;

    for(i = 0 ; i < SuccessConditions.length ; i ++)
    {
        if(SuccessConditions[i].name == ConditionName)
        {
            return 1;
        }
    }

    for(i = 0 ; i < FailureConditions.length ; i ++)
    {
        if(FailureConditions[i].name == ConditionName)
        {
            return 0;
        }
    }

    return 255;
}

/*
   Init Conditions

-  Fill the AllConditions array so we can easily iterate conditions
-  Set this Objective as the owner of each condition
-  Spawn event listeners for each condition so they can receive trigger events


*/

function InitConditions()
{
    local int i;

    AllConditions.length = 0;

    for( i = 0 ; i < SuccessConditions.length ; i ++)
    {
        SuccessConditions[i].ConditionType = 1;
        SuccessConditions[i].SetObjOwner(self);

        if(SuccessConditions[i].ShouldInitOnActivation())
        {
            ActivateCondition(SuccessConditions[i]);
        }
    }
    i = 0 ;
    for( i = 0 ; i < FailureConditions.length ; i ++)
    {
        FailureConditions[i].ConditionType = 0;
        FailureConditions[i].SetObjOwner(self);

        if(FailureConditions[i].ShouldInitOnActivation())
        {
            ActivateCondition(FailureConditions[i]);
        }
    }

    i = 0 ;
    for( i = 0 ; i < OptionalConditions.length ; i ++)
    {
        OptionalConditions[i].ConditionType = 2;
        OptionalConditions[i].SetObjOwner(self);

        if(OptionalConditions[i].ShouldInitOnActivation())
        {
            ActivateCondition(OptionalConditions[i]);
        }
    }
}


function float    GetGameDifficulty()
{
   return Level.Game.GameDifficulty ;
}

function InitActions()
{
    if(SuccessAction != none)
    {
        SuccessAction.SetObjOwner(self);
        SuccessAction.ActionType = 1;
    }

    if(FailureAction != none)
    {
        FailureAction.SetObjOwner(self);
        FailureAction.ActionType = 0;
    }
}

function UpdateInstancedConditions()
{
	local KF_StoryObjective		FP,SP,FPA,SPA,OP;
	local int i,idx;

	FindFirstSuccessParent();
	FindFirstOptionalParent();
	FindFirstFailureParent();
	FindFirstActionSuccessParent();
	FindFirstActionFailureParent();

	SP  = GetSuccessParent() ;
	FP  = GetFailureParent() ;
	OP  = GetOptionalParent();
	SPA = GetActionSuccessParent();
	FPA = GetActionFailureParent();

    if(bDebugConditionInstancing)
    {
        log(" OBJ INSTANCE DEBUG  ===============================================================",'Story_Debug');
        log(ObjectiveName@":::: Success Condition Parent ---> "@SP.ObjectiveName,'Story_Debug');
    	log(ObjectiveName@":::: Failure Condition Parent ---> "@FP.ObjectiveName,'Story_Debug');
    	log(ObjectiveName@":::: Optional Condition Parent ---> "@OP.ObjectiveName,'Story_Debug');
    	log(ObjectiveName@":::: Success Action Parent ---> "@SPA.ObjectiveName,'Story_Debug');
        log(ObjectiveName@":::: Failure Action Parent ---> "@FPA.ObjectiveName,'Story_Debug');
    }

	if(SP != none && SP != self && SP.SuccessConditions.length > 0)
	{
        if(bDebugConditionInstancing)
	       log("=========== Copying ("$SP.SuccessConditions.length$") Success Condition(s) from : "@SP.ObjectiveName@" to : "@ObjectiveName,'Story_Debug');

        for(i = 0 ; i < SP.SuccessConditions.length ; i ++)
        {
           if(SP.SuccessConditions[i].ConditionisValid())
           {
               SuccessConditions[i] = SP.SuccessConditions[i];
           }
        }
	}

	if(SPA != none && SPA != self && SPA.SuccessAction != none)
	{
        if(bDebugConditionInstancing)
            log("=========== Copying Success Action from : "@SPA.ObjectiveName@" to : "@ObjectiveName,'Story_Debug');

        SuccessAction = SPA.SuccessAction;
	}

	if(FP != none && FP != self && FP.FailureConditions.length > 0)
	{
        if(bDebugConditionInstancing)
	       log("=========== Copying ("$FP.FailureConditions.length$") Failure Condition(s) from : "@FP.ObjectiveName@" to : "@ObjectiveName,'Story_Debug');

        for(idx = 0 ; idx < FP.FailureConditions.length ; idx ++)
        {
           if(FP.FailureConditions[idx].ConditionisValid())
           {
               FailureConditions[idx] = FP.FailureConditions[idx];
           }
        }
	}

	if(FPA != none && FPA != self && FPA.FailureAction != none)
	{
        if(bDebugConditionInstancing)
	       log("=========== Copying Failure Action from : "@FPA.ObjectiveName@" to : "@ObjectiveName,'Story_Debug');

        FailureAction = FPA.FailureAction;
	}
	if(OP != none && OP != self && OP.OptionalConditions.length > 0)
	{
        if(bDebugConditionInstancing)
	       log("=========== Copying ("$OP.OptionalConditions.length$") Optional Condition(s) from : "@OP.ObjectiveName@" to : "@ObjectiveName,'Story_Debug');

        for(i = 0 ; i < OP.OptionalConditions.length ; i ++)
        {
           if(OP.OptionalConditions[i].ConditionIsValid())
           {
               OptionalConditions[i] = OP.OptionalConditions[i];
           }
        }
	}
}

/* Returns the first SuccessCondition Parent Objective in the Linked list */
function 	FindFirstSuccessParent()
{
	local int i;
	local KF_StoryObjective	Obj;

	if(FirstSuccessParent != none ||
    StoryGI == none ||
	Copy_SuccessConditions_From == '' ||
	Copy_SuccessConditions_From == ObjectiveName)
	{
		return;
	}

	for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
	{
		Obj = StoryGI.AllObjectives[i];
		if(Obj.ObjectiveName == Copy_SuccessConditions_From)
		{
			FirstSuccessParent = Obj;
			break;
		}
	}
}

/* Returns the first FailureCondition Parent Objective in the Linked list */
function 	FindFirstFailureParent()
{
	local int i;
	local KF_StoryObjective	Obj;

	if(FirstFailureParent != none ||
    StoryGI == none ||
	Copy_FailureConditions_From == '' ||
	Copy_FailureConditions_From == ObjectiveName)
	{
		return;
	}

	for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
	{
		Obj = StoryGI.AllObjectives[i];
		if(Obj.ObjectiveName == Copy_FailureConditions_From)
		{
			FirstFailureParent = Obj;
			break;
		}
	}
}

/* Returns the first Optional Condition Parent Objective in the Linked list */
function 	FindFirstOptionalParent()
{
	local int i;
	local KF_StoryObjective	Obj;

	if(FirstOptionalParent != none ||
    StoryGI == none ||
	Copy_OptionalConditions_From == '' ||
	Copy_OptionalConditions_From == ObjectiveName)
	{
		return;
	}

	for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
	{
		Obj = StoryGI.AllObjectives[i];
		if(Obj.ObjectiveName == Copy_OptionalConditions_From)
		{
			FirstOptionalParent = Obj;
			break;
		}
	}
}

/* Returns the first FailureCondition Parent Objective in the Linked list */
function 	FindFirstActionSuccessParent()
{
	local int i;
	local KF_StoryObjective	Obj;

	if(Action_FirstSuccessParent != none ||
    StoryGI == none ||
	Copy_SuccessActions_From == '' ||
	Copy_SuccessActions_From == ObjectiveName)
	{
		return;
	}

	for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
	{
		Obj = StoryGI.AllObjectives[i];
		if(Obj.ObjectiveName == Copy_SuccessActions_From)
		{
			Action_FirstSuccessParent = Obj;
			break;
		}
	}
}


/* Returns the first FailureCondition Parent Objective in the Linked list */
function 	FindFirstActionFailureParent()
{
	local int i;
	local KF_StoryObjective	Obj;

	if(Action_FirstFailureParent != none ||
    StoryGI == none ||
	Copy_FailureActions_From == '' ||
	Copy_FailureActions_From == ObjectiveName)
	{
		return;
	}

	for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
	{
		Obj = StoryGI.AllObjectives[i];
		if(Obj.ObjectiveName == Copy_FailureActions_From)
		{
			Action_FirstFailureParent = Obj;
			break;
		}
	}
}



/* accessor for retrieving this objective's Success parent.  (if using instanced conditions) */
function KF_StoryObjective	GetSuccessParent()
{
	if(FirstSuccessParent == none)
	{
		return none;
	}
	else
	{
		return FirstSuccessParent ;
	}
}


/* accessor for retrieving this objective's Optional objective parent.  (if using instanced conditions) */
function KF_StoryObjective	GetOptionalParent()
{
	if(FirstOptionalParent == none)
	{
		return self;
	}
	else
	{
		return FirstOptionalParent.GetOptionalParent() ;
	}
}

function KF_StoryObjective  GetActionSuccessParent()
{
  	if(Action_FirstSuccessParent == none)
	{
		return self;
	}
	else
	{
		return Action_FirstSuccessParent.GetActionSuccessParent() ;
	}
}

/* accessor for retrieving this objective's Failure parent.  (if using instanced conditions) */
function KF_StoryObjective	GetFailureParent()
{
	if(FirstFailureParent == none)
	{
		return self;
	}
	else
	{
		return FirstFailureParent.GetFailureParent() ;
	}
}

function KF_StoryObjective  GetActionFailureParent()
{
  	if(Action_FirstFailureParent == none)
	{
		return self;
	}
	else
	{
		return Action_FirstFailureParent.GetActionFailureParent() ;
	}
}


/* reset objective to its initial state - used when restarting from a checkpoint */

function Reset()
{
	StartTime = 0.f;
	InitialHint = ObjectiveHint;
	bCompleted = false;
	bFailed = false;
	bWasUsed = false;
	bWasTouched = false;
    ResetConditions();
    ResetActions();
//	UpdateInstancedConditions();
}

function ResetConditions()
{
   local int i;

   for(i = 0 ; i < AllConditions.length ; i ++)
   {
       if(AllConditions[i].GetObjOwner() == self)
       {
          AllConditions[i].ConditionDeActivated();
       }
   }
}

function ResetActions()
{
    if(SuccessAction!=none)
    {
        SuccessAction.ActionDeActivated();
    }

    if(FailureAction != none)
    {
        FailureAction.ActionDeActivated();
    }
}


/* Wrapper for checking if this objective is the player's current goal */
function bool		IsCurrentObjective()
{
	if(StoryGI != none)
	{
		return StoryGI.CurrentObjective == self ;
	}

	return false;
}

/* Returns true if this objective is able to be set as active (ie. Not already Completed or failed) */
function bool IsValidForActivation()
{
    return !bCompleted && !bFailed ;
}

/* Notification that this objective has just been assigned as the current goal in GameInfo*/

function Notify_ObjectiveActivated(pawn	ActivatingPlayer)
{
	local int i;
	local Controller C;
	local PlayerController PC;

    StartTime = Level.TimeSeconds;
	NetUpdateFrequency = 10.f;
	SetHumanInstigator(ActivatingPlayer);

    UpdateInstancedConditions();
    InitConditions();
    InitActions();

  	for(i = 0 ; i  < ActivationEvents.length ; i ++)
	{
  		TriggerEvent(ActivationEvents[i],self,ActivatingPlayer);
// 		log("===========================================================",'Story_Debug');
// 		log(self@"is triggering Activation event : "@ActivationEvents[i],'Story_Debug');
  	}

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
//		log("Playing sound : "@ActivationSound,'Story_Debug');
		PC = PlayerController(C);
		if(PC != none )
		{
		    if(ActivationSound != none)
		    {
			    PC.ClientPlaySound(ActivationSound,,,SLOT_MISC);
		    }
        }
	}

    ShowWhispTrails(true);
	PlayObjectiveMusic();
  	Notify_ConditionsActivated(ActivatingPlayer);
}


function Notify_ObjectiveDeActivated()
{
    local int i;

    NetUpdateFrequency = 1.f ;
    ShowWhispTrails(false);

  	for(i = 0 ; i  < DeActivationEvents.length ; i ++)
	{
  		TriggerEvent(DeActivationEvents[i],self,Instigator);
  	}

    /* even if the objective isn't recurring we still need to reset the conditions (since they could be instanced
     by other objectives and need to be returned to their default states     */

    if(bResetOnDeactivation)
    {
        if(!bRecurring)
        {
            ResetConditions();
            ResetActions();
        }
        else
        {
            Reset();      // if its a recurring objective then just reset everything.
        }
    }

}


function Notify_ConditionsActivated(pawn ActivatingPlayer)
{
    local int i;

    for(i = 0 ; i < AllConditions.length ; i ++)
    {
        AllConditions[i].ConditionActivated(ActivatingPlayer);
    }
}

function ShowWhispTrails(bool On)
{
    bShowWhispTrails = On ;
}


function PlayObjectiveMusic()
{
	local Controller C;

	if(ObjectiveInProgressMusic != "" &&
	ObjectiveInProgressMusic != StoryGI.CurrentMusicTrack)
	{
		for( C=Level.ControllerList;C!=None;C=C.NextController )
		{
			if (KFPlayerController(C)!= none)
			{
				KFPlayerController(C).NetPlayMusic(ObjectiveInProgressMusic, MusicFadeInTime,MusicFadeOutTime);
			}
		}

		StoryGI.CurrentMusicTrack = ObjectiveInProgressMusic;
	}
}

function ForceCompleteObjective()
{
    local int i,idx;

    bCompleted = false;

    for(i = 0 ; i < SuccessConditions.length ; i ++)
    {
        for(idx = 0 ; idx < SuccessConditions[i].ProgressEvents.Length ; idx ++)
        {
            if(!SuccessConditions[i].ProgressEvents[idx].bWasTriggered)
            {
                TriggerEvent(SuccessConditions[i].ProgressEvents[idx].EventName,self,Instigator);
            }
        }

        SuccessConditions[i].bLockCompletion = true;
        SuccessConditions[i].ConditionCompleted();
    }
}

/* Called when this Actor's conditions have been met -  notify the gameinfo that it may proceed to the next objective */
function ObjectiveCompleted(Controller Scorer, optional bool SkipActions)
{
	local int i;
	local Controller C;
	local PlayerController PC;
	local KFSteamStatsAndAchievements KFSteamStats;
	local KFGameReplicationInfo KFGRI;

	if(IsValidForActivation())
	{
		bCompleted = true;

		Log("======================================",'Story_Debug');
		Log("OBJECTIVE "@ObjectiveName@" COMPLETE ",'Story_Debug');
		Log("======================================",'Story_Debug');

        for(i = 0 ; i < CompletionEvents.length ; i ++)
		{
			TriggerEvent(CompletionEvents[i],self,Instigator);
		}

		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			PC = PlayerController(C);
			if(PC != none)
			{
				if(CompletionSound != none )
				{
					PC.ClientPlaySound(CompletionSound,,,SLOT_MISC);
				}

				if(SuccessText != "")
				{
					PC.ClientMessage( SuccessText, 'CriticalEvent');
				}

                KFGRI = KFGameReplicationInfo( Level.GRI );
                if( KFGRI != none )
                {
                    if( !KFGRI.bObjectiveAchievementFailed )
                    {
        				KFSteamStats = KFSteamStatsAndAchievements( PC.SteamStatsAndAchievements );
        				if ( KFSteamStats != none )
        				{
                         	KFSteamStats.OnObjectiveCompleted( ObjectiveName );
        				}
        			}
    		    }
			}
		}

		KFGRI.bObjectiveAchievementFailed = false;

		if(!SkipActions)
		{
            bPendingSuccessActions = true;
        }

        if(StoryGI != none)
        {
            StoryGI.OnObjectiveCompleted(self);
        }
	}
	else
	{
	//	log(" WARNING - OBJECTIVE : "@ObjectiveName@" is already complete. ",'Story_Debug');
	}
}

/* Deferred execution of actions to allow Actors which are triggered by Success / Failure events to be ticked before
the objective is changed */

function ExecuteSuccessActions()
{
    if(SuccessAction != none)
    {
        SuccessAction.ExecuteAction(Instigator.Controller);
    }
}

/* Counterpart to ObjectiveCompleted() - Called when this Objective's Failure condition has not been satisfied -  notify the gameinfo that it should end the game in defeat */
function 	ObjectiveFailed(Controller Failer, optional bool SkipActions)
{
	local int i;
	local Controller C;
	local PlayerController PC;

	if(IsValidForActivation())
	{
		bFailed = true;

        Log("======================================",'Story_Debug');
		Log("OBJECTIVE "@ObjectiveName@" FAILED ",'Story_Debug');
		Log("======================================",'Story_Debug');


		for(i = 0 ; i < FailureEvents.length ; i ++)
		{
			TriggerEvent(FailureEvents[i],self,Instigator);
		}

		if(FailureText != "")
		{
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
			{
				PC = PlayerController(C);
				if(PC != none)
				{
					PC.ClientMessage( FailureText, 'CriticalEvent');
				}
			}
		}

        if(!SkipActions)
        {
            bPendingFailureActions = true;
        }

        if(StoryGI != none)
        {
            StoryGI.OnObjectiveFailed(self);
        }
	}
}

/* Deferred execution of actions to allow Actors which are triggered by Success / Failure events to be ticked before
the objective is changed */

function ExecuteFailureActions()
{
    if(FailureAction != none)
    {
        FailureAction.ExecuteAction(Instigator.Controller);
    }
}

/* for triggering events - Some actors require a human pawn instigator to receive trigger events. Movers for example.*/
function SetHumanInstigator(Actor NewInstigator)
{
    local Controller C;

    if(Pawn(NewInstigator) != none &&
	PlayerController(Pawn(NewInstigator).Controller) != none)
	{
	    Instigator = Pawn(NewInstigator);
	}
	else //  time to get a little more creative ...
	{
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            if(PlayerController(C) != none && C.Pawn != none)
            {
                Instigator = C.Pawn ;
                break;
            }
        }
	}
}


function Touch( Actor Other )
{
	if(IsCurrentObjective())
	{
  		if(Pawn(Other) != none && Pawn(Other).Controller != none && Pawn(Other).Controller.bIsPlayer)
  		{
  			bWasTouched = true;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(PendingGameRestart() || bCompleted || bFailed)
	{
		return ;
	}

	/* triggering an inactive objective will activate it and set it as the current objective .. */
	if(!IsCurrentObjective())
	{
 	    StoryGI.SetActiveObjective(self,Instigator);
	}
}


function Tick(float DeltaTime)
{
    if(bCompleted || bFailed)
    {
        if(bPendingFailureActions)
        {
            bPendingFailureActions = false;
            ExecuteFailureActions();
        }

        if(bPendingSuccessActions)
        {
            bPendingSuccessActions = false;
            ExecuteSuccessActions();
        }

        /* This would only happen if we didn't have any success / failure action defined
        that transitioned to another objective.*/

        if(IsCurrentObjective() &&
        (bCompleted || bFailed))
        {
            StoryGI.SetActiveObjective(none);
        }
    }
    else
    {
    	if(IsCurrentObjective())
        {
            TickConditions(DeltaTime);
            RefreshWhispTrails();

            if(CheckConditions())
            {
	   	       ObjectiveCompleted(Instigator.Controller);
            }
		}
    }
}

function RefreshWhispTrails()
{
    local Controller C;
    local PlayerController PC;

    if( bShowWhispTrails && Level.TimeSeconds - LastWhispTime > WhispInterval)
    {
        LastWhispTime = Level.TimeSeconds;

        For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
            PC = PlayerController(C);
    		if( PC != none && PC.Pawn!=None && PC.Pawn.Health>0 )
			{
				StoryGI.ShowPathToObj(PC);
			}
        }
    }
}

function TickConditions(float DeltaTime)
{
    local int i;
    local bool bUpdatedTime;

    for(i = 0 ; i < AllConditions.length ; i ++)
    {
        if(AllConditions[i].GetObjOwner() == self &&
        AllConditions[i].ConditionIsActive())
        {
            AllConditions[i].ConditionTick(DeltaTime);

            /* Kind of a hack - we need to grab the remaining time for an
            active timer condition to use on the trader menu */
            if(!bUpdatedTime && ObjCondition_Timed(AllConditions[i]) != none)
            {
                bUpdatedTime = true;
                RemainingTime = ObjCondition_Timed(AllConditions[i]).RemainingSeconds ;
            }
        }
    }
}

/* Returns true if this Objective has a 'TraderTime' condition that is currently active */
function bool  IsTraderObj()
{
    local int i;

    for(i = 0 ; i < SuccessConditions.length ; i ++)
    {
        if(SuccessConditions[i].GetObjOwner() == self &&
        SuccessConditions[i].ConditionIsActive() &&
        ObjCondition_TraderTime(SuccessConditions[i]) != none )
        {
            return true;
        }
    }

    return false;
}

function bool		PendingGameRestart()
{
	return StoryGI != none && StoryGI.bPendingTeamRespawn ;
}


/* Returns true if this condition's progress should be used to determine the
completion state of the objective.  Inactive or optional conditions are ignored .. */
function    bool    CheckConditionProgress(KF_ObjectiveCondition  TestCondition)
{
    return TestCondition != none &&
           TestCondition.ProgressImportance != Ignore &&
           TestCondition.bActive &&
           TestCondition.ConditionIsValid();
}

/* 	Verifies when and If this objective has satisfied (or failed)
	all its	conditions

    We failed/Succeeded if ...

	A.  a condition marked 'Critical' was completed.
	B.  all conditions with normal importance were completed *
*/

function	bool	 CheckConditions()
{
	local int i;
	local bool bNewFailedObj;
	local int NumGoals,NumComplete,NumFailed;
	local int NumFailConditions;
	local bool bNewComplete;

	if(bCompleted || PendingGameRestart())
	{
		return false;
	}

	/* Check the failure conditions first - If we screwed this objective up, no point checking anything else */

	for(i = 0 ; i < FailureConditions.length ; i ++)
	{
	    if(CheckConditionProgress(FailureConditions[i]))
        {
            NumFailConditions ++ ;
            if(FailureConditions[i].bComplete)
            {
                NumFailed ++ ;
            }

            bNewFailedObj = (FailureConditions[i].bComplete &&
                            FailureConditions[i].ProgressImportance == Critical) ;

            if(bNewFailedObj)
            {
                SetHumanInstigator(FailureConditions[i].GetInstigator());
                break;
            }
        }
	}
	i = 0;

	bNewFailedObj = bNewFailedObj || (NumFailConditions > 0 && NumFailed >= NumFailConditions);
	if(bNewFailedObj != bFailed)
	{
		if(bNewFailedObj)
		{
			ObjectiveFailed(Instigator.Controller);
		}
	}

	if(	bFailed )
	{
		return false;
	}

	/* Ok -  If we got this far we haven't failed this objective so ... Check to see if we've succeeded instead */

	for(i = 0 ; i < SuccessConditions.length ; i ++)
	{
	    if(CheckConditionProgress(SuccessConditions[i]))
        {
            NumGoals ++ ;
            if(SuccessConditions[i].bComplete)
            {
               NumComplete ++ ;
            }

            bNewComplete = (SuccessConditions[i].bComplete &&
                            SuccessConditions[i].ProgressImportance == Critical) ;

            if(bNewComplete)
            {
                SetHumanInstigator(SuccessConditions[i].GetInstigator());
                break;
            }
        }
	}

	bNewComplete = bNewComplete || (NumGoals > 0 && NumComplete >= NumGoals) ;

    if(NumGoals == 0)
    {
        log("WARNING - no Success Conditions assigned to : "@ObjectiveName@". It is impossible to complete this objective.",'Story_Debug');
    }

	return bNewComplete;

}

// called if this Actor was touching a Pawn who pressed Use
event UsedBy( Pawn user )
{
    local int i;

	/* If we don't have to hold the key down, just immediately complete */
	if(!bCompleted && IsCurrentObjective() && User != none)
	{
		bWasUsed = true;

	    for(i = 0 ; i < AllConditions.length ; i ++)
	    {
	        AllConditions[i].StartedUsing(user);
	    }
	}
}

/* We walked away from this Objective - stop using it */
event UnTouch( Actor Other )
{
    if(Pawn(Other) != none)
    {
        StoppedUsing(Pawn(Other));
    }
}

/* called by KFPlayerController_Story when the player releases the Use key */
function StoppedUsing( Pawn user)
{
    local int i;

	for(i = 0 ; i < AllConditions.length ; i ++)
	{
	    AllConditions[i].StoppedUsing(user);
	}
}

/* Average completion %age of active failure conditions */

function 	float		GetFailureProgressPct()
{
	local float Pct;
    local int i;
    local float HighestPct;

	if(bFailed)
	{
        return 1.f;
	}

    for( i = 0 ; i < FailureConditions.length ; i ++)
    {
         Pct = FailureConditions[i].GetCompletionPct();
         if(Pct > HighestPct)
         {
            HighestPct = Pct;
         }
    }

    return HighestPct;
}


/* Average completion %age of active success conditions */

function 	float		GetSuccessProgressPct()
{
	local float Pct;
    local int i;

	if(bCompleted)
	{
	   return 1.f;
	}

    for( i = 0 ; i < SuccessConditions.length ; i ++)
    {
         Pct += SuccessConditions[i].GetCompletionPct();
    }
    Pct /= SuccessConditions.length ;

    return Pct;
}

simulated function KF_ObjectiveCondition FindConditionByName(name ConditionName)
{
    local int i;

    for(i = 0 ; i < AllConditions.length ; i++)
    {
        if(AllConditions[i].Name == ConditionName)
        {
            return AllConditions[i];
        }
    }
}

simulated function int FindIndexForCondition(KF_ObjectiveCondition TestCondition, optional name TestConditionName, optional bool bSearchAllConditionArray)
{
   local int i;
   local array<KF_ObjectiveCondition>  SearchArray;

   if(TestCondition == none && TestConditionName != '')
   {
      for(i = 0 ; i < Allconditions.length ; i ++)
      {
         if(AllConditions[i].name == TestConditionName)
         {
            TestCondition = AllConditions[i] ;
            if(bSearchAllConditionArray)
            {
                return i;
            }

            break;
         }
      }
   }

   i = 0;

   switch(TestCondition.ConditionType)
   {
       case 0 : SearchArray = FailureConditions; break;
       case 1 : SearchArray = SuccessConditions; break;
       case 2 : SearchArray = OptionalConditions; break;
   }

   for(i = 0 ; i < SearchArray.length ; i ++)
   {
      if(SearchArray[i] == TestCondition)
      {
          return i;
      }
   }


   log("Warning - Could not find index for condition : "@TestCondition@" in "@ObjectiveName,'Story_Debug');
   return -1 ;
}

/* Debug helper function - Returns the names of the next Objective after this one */

function name GetNextObjectiveName()
{
    return '' ;
}

function SetCheckPoint(KF_StoryCheckPointVolume Instigator)
{
    local int i;

    if(bCheckPointable)
    {
        ActiveCheckPoint = Instigator;

        for(i = 0 ; i < AllConditions.length ; i ++)
        {
            AllConditions[i].SaveState();
        }
    }
}

function ClearCheckPoint()
{
    ActiveCheckPoint = none;
}



/* ======= UnrealED Storymode Visualisation ====================================================================================
================================================================================================================================*/

function GetEvents(out array<name> TriggeredEvents,  out array<name>  ReceivedEvents)
{
    local int i,idx;

    Super.GetEvents(TriggeredEvents,ReceivedEvents);


    /* Things this Objective Triggers */

    for(i = 0 ; i < ActivationEvents.length ; i ++)
    {
        if(ActivationEvents[i] != '')
        {
            TriggeredEvents[TriggeredEvents.length] = ActivationEvents[i];
        }
    }
    for(i = 0 ; i < DeActivationEvents.length ; i ++)
    {
        if(DeActivationEvents[i] != '')
        {
            TriggeredEvents[TriggeredEvents.length] = DeActivationEvents[i];
        }
    }
    for(i = 0 ; i < CompletionEvents.length ; i ++)
    {
        if(CompletionEvents[i] != '')
        {
            TriggeredEvents[TriggeredEvents.length] = CompletionEvents[i];
        }
    }
    for(i = 0 ; i < FailureEvents.length ; i ++)
    {
        if(FailureEvents[i] != '')
        {
            TriggeredEvents[TriggeredEvents.length] = FailureEvents[i];
        }
    }
    for(i = 0 ; i < SuccessConditions.length ; i ++)
    {
        for(idx = 0 ; idx < SuccessConditions[i].ProgressEvents.length ;idx ++)
        {
            if(SuccessConditions[i].ProgressEvents[idx].EventName != '')
            {
                TriggeredEvents[TriggeredEvents.length] = SuccessConditions[i].ProgressEvents[idx].EventName;
            }
        }

        if(SuccessConditions[i].Tag != '' &&
        SuccessConditions[i].ActivationMethod > 0 &&
        SuccessConditions[i].ActivationMethod < 4)
        {
            ReceivedEvents[ReceivedEvents.length] = SuccessConditions[i].Tag ;
        }

    }
    for(i = 0 ; i < FailureConditions.length ; i ++)
    {
        for(idx = 0 ; idx <FailureConditions[i].ProgressEvents.length ;idx ++)
        {
            if(FailureConditions[i].ProgressEvents[idx].EventName != '')
            {
                TriggeredEvents[TriggeredEvents.length] = FailureConditions[i].ProgressEvents[idx].EventName;
            }
        }

        if(FailureConditions[i].Tag != '' &&
        FailureConditions[i].ActivationMethod > 0 &&
        FailureConditions[i].ActivationMethod < 4)
        {
            ReceivedEvents[ReceivedEvents.length] = FailureConditions[i].Tag ;
        }
    }
    for(i = 0 ; i < OptionalConditions.length ; i ++)
    {
        for(idx = 0 ; idx <OptionalConditions[i].ProgressEvents.length ;idx ++)
        {
            if(OptionalConditions[i].ProgressEvents[idx].EventName != '')
            {
                TriggeredEvents[TriggeredEvents.length] = OptionalConditions[i].ProgressEvents[idx].EventName;
            }
        }

        if(OptionalConditions[i].Tag != '' &&
        OptionalConditions[i].ActivationMethod > 0 &&
        OptionalConditions[i].ActivationMethod < 4)
        {
            ReceivedEvents[ReceivedEvents.length] = OptionalConditions[i].Tag ;
        }
    }
}

/* ======= UnrealED Storymode Visualisation ====================================================================================
================================================================================================================================*/

defaultproperties
{
     HUD_Header=(Header_Color=(B=255,G=255,R=255,A=255),Header_Scale=Font_Large)
     HUD_Background=(Background_Texture=Texture'KFStoryGame_Tex.HUD.ObjectiveHUDBG',Background_Texture_Collapsed=Texture'KFStoryGame_Tex.HUD.ObjectiveHUDBG_Collapsed',Background_Padding=64.000000,Background_AspectRatio=Aspect_FromTexture,Background_Scale=1.000000)
     bShowOnHUD=True
     HUD_ScreenPosition=(Horizontal=1.000000,Vertical=0.020000)
     MaxRepUpdatesPerSecond=10
     MusicFadeInTime=1.000000
     MusicFadeOutTime=2.000000
     bStopMusicOnCompletion=True
     bCheckPointable=True
     bResetOnDeactivation=True
     WhispInterval=1.100000
     Begin Object Class=ObjAction_GoToNextObjective Name=DefaultSuccessAction
     End Object
     SuccessAction=ObjAction_GoToNextObjective'KFStoryGame.KF_StoryObjective.DefaultSuccessAction'

     bHidden=True
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'KFStoryGame_Tex.Editor.KFObj_Ico'
     DrawScale=0.500000
     bCollideActors=True
}
