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

var ()                                  name                    UsePawn_Tag;

var                                     float                   FinishedUseSeconds;

var                                     float                   LastUseTime;

var                                     bool                    bAcquiredPawn;

var                                     bool                    bWasUsed;

var              const                  name                    UseActorName,InitialUseActorName,CurrentUserName,ControlledMoverName;

var ()   edfindable  private            Actor                   UseActor;    // this exists only for level designers.


function Reset()
{
    Super.Reset();
    FinishedUseSeconds = 0.f;
    bWasUsed = false;
}

function PostBeginPlay(KF_StoryObjective MyOwner)
{
    Super.PostBeginPlay(MyOwner);

    // Ditch any reference to this actor ASAP.
    if(UseActor != none)
    {
        SetTargetActor(InitialUseActorName,UseActor);
        SetTargetActor(UseActorName,UseActor);
        UseActor = none;
    }
}

function SetObjOwner(KF_StoryObjective NewOwner)
{
    local Actor MyUseActor;

    MyUseActor = GetTargetActor(UseActorName);
    if(MyUseActor == none || (NewOwner != MyUseActor && GetObjOwner() == MyUseActor))
    {
        SetTargetActor(UseActorName,NewOwner);
    }

    Super.SetObjOwner(NewOwner);
}

function ConditionActivated(pawn ActivatingPlayer)
{
    local Actor InitialUseActor,MyUseActor;
    local KF_UseableMover ControlledMover;

    Super.ConditionActivated(ActivatingPlayer);

    InitialUseActor = GetTargetActor(InitialUseActorName);
    MyUseActor = GetTargetActor(UseActorName);

    if(InitialuseActor != none &&
    !InitialuseActor.bPendingDelete)
    {
        SetTargetActor('UseActorName',InitialUseActor);
        if(KF_UseableMover(MyUseActor) != none)
        {
            SetTargetActor(ControlledMoverName,KF_UseableMover(MyUseActor));
            ControlledMover = KF_UseableMover(GetTargetActor(ControlledMoverName));
            if(ControlledMover != none)
            {
                ControlledMover.Notify_Controlled(self);
            }
        }
    }
}

function ConditionTick(float DeltaTime)
{
    local float RemainingHoldUseTime;
    local Actor MyUseActor;
    local Pawn CurrentUser;

    UpdateUseablePawnList();

    MyUseActor = GetTargetActor(UseActorName);
    CurrentUser = Pawn(GetTargetActor(CurrentUserName));

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
    local Actor MyUseActor;

    MyUseActor = GetTargetActor(UseActorName);

	if(UsePawn_Tag == '' ||
    (MyUseActor != none &&
    MyUseActor.Tag == UsePawn_Tag))
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
            SetTargetActor(UseActorName,C.Pawn);
            break;
        }
	}
}

function bool  InRangeAndView()
{
    local bool bhasLOS;
    local bool bInRange;
    local Pawn CurrentUser;

    CurrentUser = Pawn(GetTargetActor(CurrentUserName));

    if(CurrentUser == none)
    {
        return false;
    }

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
    local Actor MyUseActor;

    MyUseActor = GetTargetActor(UseActorName);

    if(Toucher != none && MyUseActor != none)
    {
        foreach Toucher.TouchingActors(class 'Actor', A)
        {
            if(A == MyUseActor)
            {
                return true;
            }
        }

        if(MyUseActor.bBlockActors)
        {
            DistSq = VsizeSquared(MyUseActor.Location - Toucher.Location) ;
            if(DistSq <= Square( (MyUseActor.CollisionRadius + (Toucher.CollisionRadius)) * 1.25 )  )
            {
                return true;
            }
        }
    }

    return false;
}

function Startedusing(pawn User)
{
    local Pawn CurrentUser;
    local KF_UseableMover ControlledMover;

    ControlledMover = KF_UseableMover(GetTargetActor(ControlledMoverName));
    CurrentUser = Pawn(GetTargetActor(CurrentUserName));

	if(CurrentUser == none && IsTouchingUseActor(User))
    {
        SetTargetActor(InstigatorName,User);
        SetTargetActor(CurrentUserName,User);
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
    local KF_UseableMover ControlledMover;

    ControlledMover = KF_USeableMover(GetTargetActor(ControlledMoverName));

    StopusingObj(User);
    if(ControlledMover != none)
    {
        ControlledMover.StoppedUsing();
    }
}

function StopUsingObj(pawn User)
{
    local Pawn CurrentUser;

    CurrentUser = Pawn(GetTargetActor(CurrentUserName));
    if(CurrentUser != none &&
    User == CurrentUser)
    {
     	/* Cache the amount of time we have been holding use for */
		if( bKeepUseProgress)
		{
   			FinishedUseSeconds += (User.Level.TimeSeconds - LastUseTime) ;
		}

        SetTargetActor(CurrentUserName,none);
    }
}

function vector    GetLocation(optional out actor LocActor)
{
    local Actor MyUseActor;

    if(ConditionIsActive())
    {
        MyUseActor = GetTargetActor(UseActorName);

        if(MyUseActor != none &&
        !MyUseActor.bPendingDelete)
        {
            LocActor = MyUseActor;
            return MyUseActor.Location;
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
    local Pawn CurrentUser;

    CurrentUser = Pawn(GetTargetActor(CurrentUserName));
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
     UseActorName="UseActor"
     InitialUseActorName="InitialUseActor"
     CurrentUserName="CurrentUser"
     ControlledMoverName="ControlledMover"
}
