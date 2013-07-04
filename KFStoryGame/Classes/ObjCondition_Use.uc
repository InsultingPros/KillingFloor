/*
	--------------------------------------------------------------
	Condition_Use
	--------------------------------------------------------------

    This Condition is marked complete when a player presses the 'Use'
    key while in range of its owning actor.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Use extends KF_ObjectiveCondition
editinlinenew;

/* requires that line of sight be maintained with the objective during the use process.  Only really relevant if HoldUseSeconds is something > 0 */
var	()	 								bool					bMaintainUseLOS;
/* Min View angle cosine required to perform a 'use' action */
var	()									float					MinUseViewAngle;
/* Number of seconds a player must hold the use key for before the objective completes.  Releasing the key will abort any progress. */
var ()									float					HoldUseSeconds;
/* if true, any progress made 'Using' this objective will be kept if the player stops holding the use key. only relevant if HoldUseSeconds is > 0 */
var ()									bool					bKeepUseProgress;

/* Actor who we are actually 'interacting with'. We only need this guy for location & collision properties */
var ()           private                Actor                   UseActor;

var              private                Actor                   InitialUseActor;

var ()                                  name                    UsePawn_Tag;

var                                     float                   FinishedUseSeconds;

var              private                pawn                    CurrentUser;

var                                     float                   LastUseTime;

var              private                KF_UseableMover         ControlledMover;

var                                     bool                    bAcquiredPawn;

var                                     bool                    bWasUsed;


function Reset()
{
    Super.Reset();
    FinishedUseSeconds = 0.f;
    bWasUsed = false;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(UseActor != none)
    {
        InitialUseActor = UseActor;
    }
}

/* Objects shouldn't have references to Actors for any longer than they need to.
- Manually clear these vars when the condition is disabled so they dont access
none and crash the game.
*/
function ClearActorReferences()
{
    Super.ClearActorReferences();
    bAcquiredPawn = false;
    CurrentUser = none;
    UseActor = none;
    ControlledMover = none;
}

function SetObjOwner(KF_StoryObjective NewOwner)
{
    if(UseActor == none || (NewOwner != UseActor && GetObjOwner() == UseActor))
    {
        UseActor = NewOwner;
    }

    Super.SetObjOwner(NewOwner);
}

function ConditionActivated(pawn ActivatingPlayer)
{
    Super.ConditionActivated(ActivatingPlayer);

    if(InitialuseActor != none &&
    !InitialuseActor.bPendingDelete)
    {
        UseActor = InitialUseActor ;
        if(KF_UseableMover(UseActor) != none)
        {
            ControlledMover = KF_UseableMover(UseActor);
            ControlledMover.Notify_Controlled(self);
        }
    }
}

function ConditionTick(float DeltaTime)
{
    local float RemainingHoldUseTime;

    UpdateUseablePawnList();

    if(bAcquiredPawn &&
    UseActor == none ||
    UseActor.bDeleteMe ||
    UseActor.bPendingDelete)
    {
        ClearActorReferences();
    }

    /* Important we call this before the Range checks or it won't register completion */
    Super.ConditionTick(DeltaTime);

    if(CurrentUser != none && CurrentUser.Controller != none)
    {
        RemainingHoldUseTime = GetRemainingUseTime() ;
		if(!InRangeAndView() || RemainingHoldUseTime <= 0)
		{
			StopUsingObj(CurrentUser);
		}
    }
}

function UpdateUseablePawnList()
{
	local Controller C;

	if(UsePawn_Tag == '' ||
    (UseActor != none &&
    UseActor.Tag == UsePawn_Tag))
	{
        return;
	}

	for ( C= GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
	{
        if(C.Pawn != none &&
        !C.Pawn.bDeleteMe &&
        !C.Pawn.bPendingDelete &&
        C.Pawn.Health > 0 &&
        C.Pawn.Tag == UsePawn_Tag)
        {
            UseActor = C.Pawn;
            break;
        }
	}
}

function bool  InRangeAndView()
{
    local bool bhasLOS;
    local bool bInRange;


    bHasLOS = (!bMaintainUseLOS ||
	KFPlayerController_Story(CurrentUser.Controller) != none &&
	KFPlayerController_Story(CurrentUser.Controller).IsLookingAtLocation(GetLocation(),MinUseViewAngle));

    bInRange = IsTouchingUseActor(CurrentUser) ;

    return bInRange && bHasLOS;
}

function bool     IsTouchingUseActor(pawn Toucher)
{
    local Actor A;
    local float DistSq;

    if(Toucher != none && UseActor != none)
    {
        foreach Toucher.TouchingActors(class 'Actor', A)
        {
            if(A == UseActor)
            {
                return true;
            }
        }

        if(UseActor.bBlockActors)
        {
            DistSq = VsizeSquared(UseActor.Location - Toucher.Location) ;
            if(DistSq <= Square( (UseActor.CollisionRadius + (Toucher.CollisionRadius)) * 1.25 )  )
            {
                return true;
            }
        }
    }

    return false;
}

function Startedusing(pawn User)
{
	if(CurrentUser == none && IsTouchingUseActor(User))
    {
        Instigator  = user;
	    CurrentUser = user;
		LastUseTime = User.Level.TimeSeconds;

		if(AllowCompletion())
		{
            bWasUsed = true;
        }

        if(ControlledMover != none)
        {
            ControlledMover.StartedUsing();
        }
	}
}

function StoppedUsing(pawn User)
{
    StopusingObj(User);
    if(ControlledMover != none)
    {
        ControlledMover.StoppedUsing();
    }
}

function StopUsingObj(pawn User)
{
    if(CurrentUser != none &&
    User == CurrentUser)
    {
     	/* Cache the amount of time we have been holding use for */
		if( bKeepUseProgress)
		{
   			FinishedUseSeconds += (User.Level.TimeSeconds - LastUseTime) ;
		}

        CurrentUser = none;
    }
}

function vector    GetLocation(optional out actor LocActor)
{
    if(ConditionIsActive())
    {
        if(UseActor != none &&
        !UseActor.bPendingDelete)
        {
            LocActor = UseActor;
            return UseActor.Location;
        }

        return Super.GetLocation(LocActor);
    }
}


/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
     if(HoldUseSeconds > 0)
     {
         return 1.f - (GetRemainingUseTime() / HoldUseSeconds);
     }
     else
     {
         return float(bWasUsed);
     }
}

/* Wrapper for finding the amount of time a player needs to hold down the USE key to complete this condition */
function	float		GetRemainingUseTime()
{
    if(CurrentUser != none)
    {
	     return	FMax(HoldUseSeconds - ((GetObjOwner().Level.TimeSeconds - LastUseTime) + FinishedUseSeconds), 0.f)  ;
    }

    return (HoldUseSeconds - FinishedUseSeconds);
}

function        string      GetDataString()
{
     if(HoldUseSeconds > 0)
     {
        return Round((1.f-(GetRemainingUseTime() / HoldUseSeconds))*100.f)$"%" ;
     }

     return "" ;
}

defaultproperties
{
}
