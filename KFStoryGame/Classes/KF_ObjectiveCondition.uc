/*
	--------------------------------------------------------------
	KF_ObjectiveCondition
	--------------------------------------------------------------

	Object used to store gameplay conditions for KF_StoryObjectives
    Configured by level designers.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

#exec OBJ LOAD FILE=KFStoryGame_Tex.utx

class KF_ObjectiveCondition extends Object
abstract
dependson(KFStoryGameInfo)
hidecategories(Object);


const HintCharLimit = 35;


/* Pawn responsible for Activating and / or completing this condition. */
var         protected                   Pawn              Instigator;

var                                     bool              bComplete,SavedbComplete;

var                                     float             LastActivatedTime;

var                                     float             LastRepTime;

/* Minimum time between client updates of condition data */
var                                     float             ConditionRepInterval;

/* HUD properties ======================================================================
=======================================================================================*/

/* HUD Properties that pertain to the world (Wisp trail, projected icons, etc.) */
var (HUD) KFStoryGameInfo.SConditionHintInfoWorld         HUD_World;

/* HUD Properties that pertain to the player's On-screen display */
var (HUD) KFStoryGameInfo.SConditionHintInfoHUD           HUD_Screen;

var                                     float             OldCompletionPct,NewCompletionPct;

var                                     bool              OldComplete,NewComplete;

var                                     string            OldDataString,NewDataString;

var                                     vector            OldWorldLoc,NewLocation;

var                                     Actor             OldLocActor,NewLocActor;


/* =====================================================================================
=======================================================================================*/

var                                     bool              bActive,SavedbActive;

var                                     bool              bWasTriggered,SavedbWasTriggered;

var                                     byte              ConditionType;    // 0 = failure, 1 = success , 2 = optional



/* An array that stores Condition dependencies.
ie.  We only want this condition to be considered for completion if the
conditions in this list are already completed and share the same instigator as us.

an example of this would be a Key locked door */

var() array <KF_ObjectiveCondition>                         DependentConditions;

/* If true this objective cannot be 'uncompleted' once it is complete, without being reset */
var() bool                                                  bCompleteOnce;

var   bool                                                  bLockCompletion;

/* Difficulty Modifiers ============================================================*/

enum	EKFGameDifficulty
{
    All,
    Beginner,
    Normal,
    Hard,
    Suicidal,
    HellOnEarth,
};

/* Only use this condition above MinDifficulty and below MaxDifficulty */
var(Difficulty)                         EKFGameDifficulty Difficulty_Min,Difficulty_Max;


var(Difficulty)                         int               PlayerCount_Min,PlayerCount_Max;

/* Scales the Condition's requirements based on the server's difficulty setting */
var(Difficulty)                         KFStoryGameInfo.SConditionDifficultyScale           Scale_GameDifficulty;

/* Scales the Condition's requirements based on the number of players on the server */
var(Difficulty)                         float                                               Scale_PlayerCount;

var          private   transient        KF_StoryObjective ObjOwner;

/* =====================================================================================
=======================================================================================*/

var(Events)						        array<KFStoryGameInfo.SObjectiveProgressEvent>	    ProgressEvents;

/* =====================================================================================
=======================================================================================*/

var                                     KF_Objective_EventListener   Eventlistener;

var(Events)                             name              Tag;

var()                                   KFStoryGameInfo.EConditionInitialState        InitialState;

var()                                   KFStoryGameInfo.EConditionActivationMethod    ActivationMethod;

var()                                   KFStoryGameInfo.EProgressImportance           ProgressImportance;

var         private                     Actor                                         InitialWorldLocActor;


/*========== AUDIO =====================================================================*/

var(Audio)                              sound                                         Sound_Completion;


function StoppedUsing(pawn User){}
function StartedUsing(pawn User){}

function PostBeginPlay()
{
    if(HUD_World.World_Location != none)
    {
        InitialWorldLocActor = HUD_World.World_Location;
    }
}

function SaveState()
{
    SavedbComplete      = bComplete;
    SavedbActive        = bActive;
    SavedbWasTriggered  = bWasTriggered;
}

function ClearActorReferences()
{
    HUD_World.World_Location = none;
    Instigator = none;
}

function Reset()
{
    local int i;

    if(GetObjOwner().ActiveCheckPoint == none)
    {
        bWasTriggered = false;
        bActive = false;
        bComplete = false;

	}
	else
	{
        bWasTriggered = SavedbWasTriggered;
        bActive = SavedbActive;
        bComplete = SavedbComplete;
	}

	for(i = 0 ; i < ProgressEvents.Length ; i ++)
	{
        ProgressEvents[i].bWasTriggered = false;
	}

    OldDataString = "";
    OldCompletionPct = 0.f;
    OldWorldLoc = vect(0,0,0);
    NewLocation = vect(0,0,0);
    bLockCompletion = false;
}

function Trigger(actor Other, pawn EventInstigator)
{
    if(ConditionIsValid())
    {
        Instigator = EventInstigator;

        switch(ActivationMethod)
        {
            case TriggerToggled :
            if(!bActive)
            {
                log("**********************************************");
                log("Activating Condition By Trigger - :"@name);
                GetObjOwner().ActivateCondition(self);
                return;
            }
            else
            {
                log("**********************************************");
                log("Deactivating Condition By Trigger - :"@name);
                GetObjOwner().DeActivateCondition(self);
                return;
            }
            break;
            case TriggerActivates :
            if(!bActive)
            {
                GetObjOwner().ActivateCondition(self);
                return;
            }
            break;
            case TriggerDeActivates :
            if(bActive)
            {
                GetObjOwner().DeActivateCondition(self);
                return;
            }
            break;
        }
    }

    if(bActive)
    {
        bWasTriggered = true;
    }

}

function bool               ConditionIsRelevant()
{
    return true;
}

function bool               ConditionIsActive()
{
//  log(self@"Owner : "@GetObjOwner().ObjectiveName@" Complete ? : "@bComplete@" Active ? : "@bActive,'Story_Debug');
    return GetObjOwner() != none && bActive;
}

/* Returns true if this condition should initialize automatically when its owning objective becomes active
In most cases this will be true ... except for complex conditions which the LD intentionally wants to activate
manually (after certain events in the mission , etc.)
*/

function bool               ShouldInitOnActivation()
{
    local bool Result;

    if(InitialState == Active ||
    (ActivationMethod == RandomlyActivate &&
    FRand() > 0.5))  // condition is valid for activation
    {
        Result = true;
    }

    return Result && ConditionIsValid();
}

/* Only returns true if this condition is valid for activation - based on various factors like Game Difficulty, Player Count, etc.
*/

function bool               ConditionIsValid()
{
    local int NumPlayers;
    local float CurrentDifficulty,MaxDifficulty,MinDifficulty;
    local bool Result;

    Result = true;

    /* =============== Check Difficulty & Player Count validitiy ======*/

    /* Make sure the values are in range first .. */
    PlayerCount_Min = Min(PlayerCount_Min,PlayerCount_Max);
    PlayerCount_Max = Max(PlayerCount_Max,PlayerCount_Min);


    NumPlayers = KFStoryGameInfo(GetObjOwner().Level.Game).GetTotalActivePlayers();
    if((PlayerCount_Max > 0 && NumPlayers > PlayerCount_Max) ||
    (PlayerCount_Min > 0 && NumPlayers < PlayerCount_Min))
    {
        return false;
    }

    CurrentDifficulty = GetObjOwner().Level.Game.GameDifficulty;
    if(Difficulty_Max > 0)
    {
        switch(Difficulty_Max)
        {
            case Beginner     :  MaxDifficulty = 1.f ; break;
            case Normal       :  MaxDifficulty = 2.f ; break;
            case Hard         :  MaxDifficulty = 4.f ; break;
            case Suicidal     :  MaxDifficulty = 5.f ; break;
            case HellOnEarth  :  MaxDifficulty = 7.f ; break;
        }

        Result = CurrentDifficulty <= MaxDifficulty ;
    }
    if(Difficulty_Min > 0)
    {
        switch(Difficulty_Min)
        {
            case Beginner     :  MinDifficulty = 1.f ; break;
            case Normal       :  MinDifficulty = 2.f ; break;
            case Hard         :  MinDifficulty = 4.f ; break;
            case Suicidal     :  MinDifficulty = 5.f ; break;
            case HellOnEarth  :  MinDifficulty = 7.f ; break;
        }

        return Result && CurrentDifficulty >= MinDifficulty ;
    }

    return Result;
}

/* Returns a value that scales this condition's requirements based on the Game Difficulty setting of the server */
function float GetGameDifficultyModifier()
{
    local float CurrentDifficulty,DiffModifier;

    CurrentDifficulty = GetObjOwner().Level.Game.GameDifficulty;
    DiffModifier = 1.f;

    switch(CurrentDifficulty)
    {
        case 1            :         DiffModifier = Scale_GameDifficulty.Scale_Beginner;     break;                 // Beginner.
        case 3            :         DiffModifier = Scale_GameDifficulty.Scale_Hard;         break;                 // Hard.
        case 5            :         DiffModifier = Scale_GameDifficulty.Scale_Suicidal;     break;                 // Suicidal.
        case 7            :         DiffModifier = Scale_GameDifficulty.Scale_HellOnEarth;  break;                 // Hell On Earth.
    }

    return DiffModifier;
}

/* Returns a value that scales this condition's requirements based on the number of players on the server */
function float GetPlayerCountModifier()
{
    local int NumPlayers;

    NumPlayers = KFStoryGameInfo(GetObjOwner().Level.Game).GetTotalActivePlayers();

    if(NumPlayers <= 1)
    {
        return 1.f;
    }

    return FMax(NumPlayers * Scale_PlayerCount,  1.f);
}

function float GetTotalDifficultyModifier()
{
    return GetGameDifficultyModifier() * GetPlayerCountModifier();
}

function ConditionActivated(pawn ActivatingPlayer)
{
    Instigator = ActivatingPlayer;

    LastActivatedTime = GetObjOwner().Level.TimeSeconds;
    bActive = true;

    if(InitialWorldLocActor != none)
    {
        HUD_World.World_Location = InitialWorldLocActor;
    }

    ReliableConditionUpdate();
}

function ConditionDeActivated()
{
    ClearActorReferences();
    Reset();
}

function     bool IsOptionalCondition()
{
     return ConditionType == 2;
}


function SpawnEventListener()
{
    if(GetObjOwner() != none && Eventlistener == none )
    {
        EventListener = GetObjOwner().Spawn(class 'KF_Objective_EventListener');
        EventListener.SetConditionOwner(self);
    }
}

/* Allow Completion of this Condition
always true unless there is an outstanding dependency */
function    bool AllowCompletion()
{
    local int i;
    local bool Result;

    Result = true;

    for(i = 0 ; i < DependentConditions.length ; i ++)
    {
        if(!DependentConditions[i].bComplete ||
        !DependentConditions[i].FindInstigator(Instigator))
        {
            Result = false;
            break;
        }
    }

    return Result;

}

/* Some conditions may have multiple instigators */
function bool   FindInstigator(Pawn TestInstigator)
{
    return Instigator == TestInstigator;
}

function ConditionTick(float DeltaTime)
{
    local float PctComplete;

    PctComplete = GetCompletionPct();
    TriggerProgressEvents(PctComplete);

    if(!bComplete)
    {
        if(PctComplete >= 1.f &&
        AllowCompletion())
        {
            ConditionCompleted();
        }
    }
    else
    {
        if(!bLockCompletion &&
        !bCompleteOnce &&
        PctComplete < 1.f)
        {
            bComplete = false;
        }
    }

    /* Timed HUD Update - replicated , so do it only when the values actually change.*/
    UnreliableConditionUpdate();

}

/* Progress Event updates -  Fired off at different stages in the condition's completion */
function TriggerProgressEvents(float PctComplete)
{
    local int EventIdx;

    for(EventIdx = 0 ; EventIdx < ProgressEvents.length ; EventIdx ++)
    {
		if(PctComplete  >= ProgressEvents[EventIdx].ProgressPct &&
		(!ProgressEvents[EventIdx].bWasTriggered ||
        (ProgressEvents[EventIdx].bReTriggerable &&
        PctComplete != ProgressEvents[EventIdx].LastTriggeredPct ) ) )
		{
			ProgressEvents[EventIdx].bWasTriggered = true;
			GetObjOwner().TriggerEvent( ProgressEvents[EventIdx].EventName,GetObjOwner(),Instigator);
		}

		ProgressEvents[EventIdx].LastTriggeredPct = PctComplete;
	}
}

function bool AllowConditionRepUpdate()
{
    if( GetObjOwner().Level.TimeSeconds - LastRepTime < ConditionRepInterval ||
        (HUD_World.bHide && HUD_Screen.Screen_ProgressStyle == 0 ))
    {
        return false;
    }

    return true;
}

/* Reliable HUD Update - Sends condition information to clients.   Only used when a player
absolutely MUST get accurate data from this condition.
*/
function ReliableConditionUpdate(optional KFPlayerController_Story TargetPlayer)
{
    local KFPlayerController_Story StoryPC;
    local Controller C;
    local float CompletionPct;
    local string HUDHint;

    GetLocation(NewLocActor);
    CompletionPct = GetCompletionPct();
    HUDHint = GetHUDHint();

    if(HUD_Screen.Screen_CountStyle != Hide_Counter)
    {
        HUDHint @=GetDataString();
    }

    /* We want to update a specific Client's HUD */
    if(TargetPlayer != none)
    {
        TargetPlayer.ReliableConditionUpdate(self,
        GetObjOwner().name,
        CompletionPct,
        NewLocActor,
        NewLocActor.Tag,
        HUDHint,
        bComplete);
    }
    else    // update everyone at once
    {
        For( C=GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
        {
            StoryPC = KFPlayerController_Story(C);
            if(StoryPC != none)
            {
                StoryPC.ReliableConditionUpdate(self,
                GetObjOwner().name,
                CompletionPct,
                NewLocActor,
                NewLocActor.Tag,
                HUDHint,
                bComplete);
            }
        }
    }
}


/* Replicates relevant info for this condition to clients
VERY expensive - for this reason it is throttled and only
set to replicate dirty values

@Todo - is there a more efficient way to do this ?

*/

function UnreliableConditionUpdate()
{
    local KFPlayerController_Story StoryPC;
    local Controller C;
    local bool bUpdateHUD;

    if((GetObjOwner().AllowConditionRepUpdate() &&  AllowConditionRepUpdate()) )
    {
        OldComplete = NewComplete;
        NewComplete = bComplete || !bActive;

        OldDataString = NewDataString;
        NewDataString = GetHUDHint();

        if(HUD_Screen.Screen_CountStyle != Hide_Counter)
        {
            NewDataString @=GetDataString();
        }

        OldCompletionPct = NewCompletionPct;
        NewCompletionPct = GetCompletionPct();

        OldLocActor = NewLocActor;
        GetLocation(NewLocActor);

        bUpdateHUD  =   (OldLocActor      != NewLocActor        ||
                        NewCompletionPct != OldCompletionPct    ||
                        NewComplete      != OldComplete         ||
                        NewDataString    != OldDataString);

        if(bUpdateHUD)
        {
            LastRepTime = GetObjOwner().Level.TimeSeconds;
            GetObjOwner().CurrentRepUpdates ++ ;

            For( C=GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
            {
                StoryPC = KFPlayerController_Story(C);
                if(StoryPC != none)
                {
                    StoryPC.UnreliableConditionUpdate(self,
                    GetObjOwner().name,
                    NewCompletionPct,
                    NewLocActor,
                    NewDataString,
                    NewComplete);
                }
            }
        }
    }
}


/* Set the 'bComplete' bool to notify the parent Objective that this Condition is complete */
function ConditionCompleted()
{
    local actor SourceActor;
    local Controller C;

    /* NOTE - any completion event stuff should be done *Before* bComplete is marked true*/

    if(Sound_Completion != none)
    {
        GetLocation(SourceActor);
        if(SourceActor != none &&
        SourceActor != GetObjOwner())
        {
            SourceActor.PlaySound(Sound_Completion,,SourceActor.SoundVolume,,SourceActor.SoundRadius,SourceActor.SoundPitch,true);
        }
        else
        {
            for (C = GetObjOwner().Level.ControllerList; C != None; C = C.NextController)
            {
                if(PlayerController(C) != none)
                {
                    PlayerController(C).ClientPlaySound(Sound_Completion,true,2.f,SLOT_Talk);
                }
            }
       //     log("Warning -  Attempted to play Completion sound for"@name@" with no Source Actor!",'Story_Debug');
        }
    }


    bComplete = true;
    log("==============================================================================================", 'Story_Debug');
    log("============= "@self@" a condition of "@GetObjOwner().ObjectiveName@" was just marked complete. ", 'Story_Debug');

    ReliableConditionUpdate();

}

/* Accessor functions ========================== */

function SetObjOwner(KF_StoryObjective NewOwner)
{
    ObjOwner = NewOwner;
}

function KF_StoryObjective             GetObjOwner()
{
    return ObjOwner;
}

/* Returns a reference to the pawn which instigated this condition last */
function Pawn                          GetInstigator()
{
    return Instigator;
}

function int                           GetOwnerArrayIndex()
{
    return GetObjOwner().FindIndexForCondition(self);
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
     return float(bComplete);
}

function        string      GetDataString()
{
     return "" ;
}

/* Hint to display over the world icon */
function        string      GetWorldHint()
{
     return HUD_World.World_Hint ;
}

function        string      GetHUDHint()
{
     return     ClampHUDHint(HUD_Screen.Screen_Hint);
}

function        string      ClampHUDHint(string Hint)
{
	if( Len(Hint) > HintCharLimit )
	{
		Hint = left(Hint,HintCharLimit);
		Hint $= "..";
	}

	return Hint;
}

function        vector       GetLocation(optional out Actor LocActor)
{
    if(ConditionIsActive())
    {
        if(GetWorldLocActor(LocActor))
        {
            return LocActor.Location ;
        }

        LocActor = GetObjOwner();
        return GetObjOwner().Location;
    }
}

function       bool        GetWorldLocActor(out Actor LocActor)
{
    if(ConditionIsActive() &&
    HUD_World.World_Location != none &&
    !HUD_World.World_Location.bPendingDelete &&
    !HUD_World.World_Location.bDeleteMe)
    {
        LocActor = HUD_World.World_Location;
        return true; ;
    }

    return false;
}

function       vector       GetWhispLocation(optional out Actor LocActor)
{
    return   GetNearestPathNodeTo(GetLocation(LocActor)).Location;
}

function       bool         ShouldShowWhispTrailFor(PlayerController C)
{
    return HUD_World.bShowWhispTrail;
}

function       NavigationPoint  GetNearestPathNodeTo( vector DesiredLocation)
{
    local navigationpoint N,Closest;
    local float ClosestDistSq,DistSq;

    for ( N=GetObjOwner().Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
        DistSq = VSizeSquared(N.Location - DesiredLocation) ;
        if(Closest == none || DistSq < ClosestDistSq)
        {
            Closest = N ;
            ClosestDistSq = DistSq;
        }
	}

	return Closest;
}

/* TimeFormatting string function Copied from Scoreboard.uc */

function String FormatTime( int Seconds )
{
	local int Minutes, Hours;
	local String Time;

	if( Seconds > 3600 )
	{
		Hours = Seconds / 3600;
		Seconds -= Hours * 3600;

		Time = Hours$":";
	}
	Minutes = Seconds / 60;
	Seconds -= Minutes * 60;

	if( Minutes >= 10 )
		Time = Time $ Minutes $ ":";
	else
		Time = Time $ "0" $ Minutes $ ":";

	if( Seconds >= 10 )
		Time = Time $ Seconds;
	else
		Time = Time $ "0" $ Seconds;

	return Time;
}

defaultproperties
{
     ConditionRepInterval=0.500000
     HUD_World=(World_Texture_Scale=1.000000,World_Clr=(B=50,G=50,R=255,A=255),Whisp_Clr=(B=50,G=50,R=255,A=255))
     HUD_Screen=(Screen_ProgressStyle=HDS_Combination,FontScale=Font_Medium,Screen_ProgressBarBG=Texture'KFStoryGame_Tex.HUD.Hud_Rectangel_W_Stroke_Neutral',Screen_ProgressBarFill=Texture'KFStoryGame_Tex.HUD.Hud_Rectangle_W_Stroke_Fill',Screen_Clr=(B=50,G=50,R=255,A=255))
     Scale_GameDifficulty=(Scale_Beginner=1.000000,Scale_Hard=1.000000,Scale_Suicidal=1.000000,Scale_HellOnEarth=1.000000)
     Scale_PlayerCount=1.000000
     InitialState=Active
}
