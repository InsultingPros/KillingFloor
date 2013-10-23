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

var	()		   edfindable private   	Actor		        TargetActor;

var            bool                     bAcquiredPawn;
/* if we are defending a pawn, this is the minimum health that pawn can drop to before we fail */
var	()									float				MinHealthPct;
/* tag for actors that are spawned at runtime which we must also defend */
var ()									Name    			TargetPawnTag;

var ()                                  EHealthMethod       HealthCondition;

var            float                    CurrentHealth,HealthMax;

var   const    name                     InitialHealthActorName,HealthActorName;

function PostBeginPlay(KF_StoryObjective MyOwner)
{
    Super.PostBeginPlay(MyOwner);

    // Ditch any reference to this actor ASAP.
    if(TargetActor != none)
    {
        SetTargetActor(HealthActorName,TargetActor);
        SetTargetActor(InitialHealthActorName,TargetActor);
        TargetActor = none;
    }
}


function Reset()
{
    Super.Reset();
    CurrentHealth = 0;
    HealthMax = 0;
    bAcquiredPawn = false;
}

function ConditionActivated(pawn ActivatingPlayer)
{
    local Actor InitialActor;

    Super.ConditionActivated(ActivatingPlayer);

    InitialActor = GetTargetActor(InitialHealthActorName) ;

    if(InitialActor != none &&
    !InitialActor.bPendingDelete)
    {
        SetTargetActor(HealthActorName,InitialActor);
    }
}

function bool               ConditionIsRelevant()
{
    local Actor MyTargetActor;

    MyTargetActor = GetTargetActor(HealthActorName);

    if(MyTargetActor != none &&
    KF_StoryNPC(MyTargetActor) != none)
    {
        return KF_StoryNPC(MyTargetActor).bActive ;
    }

    return true;
}

function ConditionTick(float DeltaTime)
{
	local KFDoorMover 	DoorActor;
	local Pawn			PawnActor;
    local Actor         MyTargetActor;

    UpdatePawnList();

    MyTargetActor = GetTargetActor(HealthActorName);

    if(MyTargetActor != none &&
    !MyTargetActor.bDeleteMe &&
    !MyTargetActor.bPendingDelete)
    {
        PawnActor 	= Pawn(MyTargetActor);
        DoorActor	= KFDoorMover(MyTargetActor);

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
            CurrentHealth	=   float(MyTargetActor != none && !MyTargetActor.bHidden && !MyTargetActor.bPendingDelete) * 100.f ;
        }
    }
    else
    {
        CurrentHealth = 0;
    }

    Super.ConditionTick(DeltaTime);
}


function UpdatePawnList()
{
	local Controller C;
    local Actor MyTargetActor;

    MyTargetActor = GetTargetActor(HealthActorName);

	if(bAcquiredPawn ||
    TargetpawnTag == '' ||
    (MyTargetActor != none &&
    MyTargetActor.Tag == TargetPawnTag))
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
            SetTargetActor(HealthActorName,C.Pawn);
            bAcquiredPawn = true;
            break;
        }
	}
}


function        vector       GetLocation(optional out Actor LocActor)
{
    local Actor MyTargetActor;
    local Actor HUDWorldLocActor;

    if(ConditionIsActive())
    {
        MyTargetActor = GetTargetActor(HealthActorName);

        if(MyTargetActor != none &&
        !MyTargetActor.bPendingDelete)
        {
            LocActor = MyTargetActor;
            return MyTargetActor.Location ;
        }

        HUDWorldLocActor = GetTargetActor(WorldLocActorName);
        if( HUDWorldLocActor != none)
        {
            LocActor = HUDWorldLocActor ;
            return HUDWorldLocActor.Location ;
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
     InitialHealthActorName="InitialHealthActor"
     HealthActorName="HealthActor"
}
