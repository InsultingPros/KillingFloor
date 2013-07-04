/*
	--------------------------------------------------------------
	Condition_ActorHealth
	--------------------------------------------------------------

    A Condition which tracks the health state of specified Actor(s)
    and is marked complete when it drops below a specified threshold.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_ActorHealth extends KF_ObjectiveCondition
editinlinenew;

enum EHealthMethod
{
    Health_Empty,
    Health_Full,
};

/* array of actors we need to defend or we wiwwwll fail this objective */
	var	()		   edfindable private   	Actor		        TargetActor;

	var            bool                     bAcquiredPawn;

/* if we are defending a pawn, this is the minimum health that pawn can drop to before we fail */
	var	()									float				MinHealthPct;
/* tag for actors that are spawned at runtime which we must also defend */
	var ()									Name    			TargetPawnTag;

	var            private                  Actor               InitialActor;

	var ()                                  EHealthMethod       HealthCondition;

	var            float                    CurrentHealth,HealthMax;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(TargetActor != none)
    {
        InitialActor = TargetActor;
    }
}


function Reset()
{
    Super.Reset();
    CurrentHealth = 0;
    HealthMax = 0;
}

function ConditionActivated(pawn ActivatingPlayer)
{
    Super.ConditionActivated(ActivatingPlayer);

    if(InitialActor != none &&
    !InitialActor.bPendingDelete)
    {
        TargetActor = InitialActor ;
    }
}

function bool               ConditionIsRelevant()
{
    if(TargetActor != none &&
    KF_StoryNPC(TargetActor) != none)
    {
        return KF_StoryNPC(TargetActor).bActive ;
    }

    return true;
}

/* Objects shouldn't have references to Actors for any longer than they need to.
- Manually clear these vars when the condition is disabled so they dont access
none and crash the game.
*/
function ClearActorReferences()
{
    bAcquiredPawn = false;
    TargetActor = none;
    Super.ClearActorReferences();
}

function ConditionTick(float DeltaTime)
{
	local KFDoorMover 	DoorActor;
	local Pawn			PawnActor;

    UpdatePawnList();

    if(TargetActor != none &&
    !TargetActor.bDeleteMe &&
    !TargetActor.bPendingDelete)
    {
        PawnActor 	= Pawn(TargetActor);
        DoorActor	= KFDoorMover(TargetActor);

        if(DoorActor != none && DoorActor.MyTrigger != none )
        {
            HealthMax		= DoorActor.MyTrigger.MaxWeldStrength ;
            CurrentHealth	= DoorActor.MyTrigger.WeldStrength ;
        }
        else
        if(PawnActor != none)
        {
            HealthMax		= PawnActor.HealthMax;
            CurrentHealth	= PawnActor.Health;
        }
        else
        {
            HealthMax 		=	100.f;
            CurrentHealth	=   float(TargetActor != none && !TargetActor.bHidden && !TargetActor.bPendingDelete) * 100.f ;
        }
    }
    else
    {
        /* So if we get to this point it probably means that our target pawn was destroyed quite abruptly
        We need to shut the condition down before it crashes the game by looking up a non existant actor
        */
        if(bAcquiredPawn)
        {
            CurrentHealth = 0;
            ClearActorReferences();
        }
    }

    Super.ConditionTick(DeltaTime);
}


function UpdatePawnList()
{
	local Controller C;

	if(bAcquiredPawn ||
    TargetpawnTag == '' ||
    (TargetActor != none &&
    TargetActor.Tag == TargetPawnTag))
	{
        return;
	}

	for ( C= GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
	{
        if(C.Pawn != none &&
        !C.Pawn.bDeleteMe &&
        !C.Pawn.bPendingDelete &&
        C.Pawn.Health > 0 &&
        C.Pawn.Tag == TargetpawnTag)
        {
            TargetActor = C.Pawn;
            bAcquiredPawn = true;
            break;
        }
	}
}


function        vector       GetLocation(optional out Actor LocActor)
{

    if(ConditionIsActive())
    {
        if(TargetActor != none &&
        !TargetActor.bPendingDelete)
        {
            LocActor = TargetActor;
            return TargetActor.Location ;
        }

        if( HUD_World.World_Location != none)
        {
            LocActor = HUD_World.World_Location ;
            return HUD_World.World_Location.Location ;
        }
    }


    return vect(0,0,0);  // force not to display.
}



/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
    local float Pct;

    if(HealthMax == 0)
    {
        return 0.f;
    }

    if(HealthCondition == Health_Empty)
    {
    	Pct = 1.f - FClamp(CurrentHealth / HealthMax,0.f,1.f) ;
    }
    else
    {
    	Pct = FClamp(CurrentHealth / HealthMax,0.f,1.f) ;
    }

	return Pct;
}

function        string      GetDataString()
{
     if(HUD_Screen.Screen_CountStyle == 1)
     {
         return Int(Round((1.f-GetCompletionPct())*100))$"%" ;
     }
     else
     {
         return Int(Round((GetCompletionPct())*100))$"%" ;
     }
}

defaultproperties
{
}
