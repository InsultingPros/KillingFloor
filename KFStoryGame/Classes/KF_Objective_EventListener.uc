/*
	--------------------------------------------------------------
	KF_Objective_EventListener
	--------------------------------------------------------------

    Bzsic Proxy actor which receives trigger events for Objective conditions.

    As of 10/17/13 we are also using this to store actor references for conditions.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_Objective_EventListener extends Actor;

// Condition which this actor stores actor References for.
var private KF_ObjectiveCondition        ConditionOwner;

// A struct which contains a reference to an actor.
// Objects cannot have references to actors which are being garbage collected
// or the game will crash.  So we cache them here instead.

struct SConditionActorReference
{
    var Actor   TargetActor;
    var name    ActorName;
};

// This array contains a list of all the Actors which are relevant to its ConditionOwner.
var protected array<SConditionActorReference>   AssociatedActors;

// This function is called to cache an Actor that is relevant to ConditionOwner.
function AddAssociatedActor(name NewActorName,Actor NewActor )
{
    local int Index;

    if(!FindAssociatedActor(NewActorName,,Index))
    {
        AssociatedActors.Length = AssociatedActors.length + 1;
        AssociatedActors[AssociatedActors.length - 1].TargetActor  = NewActor;
        AssociatedActors[AssociatedActors.length - 1].ActorName  = NewActorName;
    }
    else
    {
        AssociatedActors[Index].TargetActor = NewActor;
    }
}

// This function is called to remove an Actor associated with ConditionOwner from the AssociatedActors cache.
function RemoveAssociatedActor(name ActorToRemove)
{
    local int Index;

    if(FindAssociatedActor(ActorToRemove,,Index))
    {
        AssociatedActors.Remove(Index,1);
    }
}

// Search the AssociatedActors cache by name.
function bool FindAssociatedActor( name TargetActorName, optional out Actor TargetActor , optional out int Index)
{
    local int i;

    for(i = 0 ; i < AssociatedActors.length ; i ++)
    {
        if(AssociatedActors[i].ActorName != '' &&
        AssociatedActors[i].ActorName == TargetActorName)
        {
            TargetActor = AssociatedActors[i].TargetActor;
            Index = i;
            return true;
        }
    }

    return false;
}

function SetConditionOwner(KF_ObjectiveCondition NewOwner)
{
    ConditionOwner = NewOwner;
    Tag = ConditionOwner.Tag;
}

function KF_ObjectiveCondition   GetConditionOwner()
{
    return ConditionOwner;
}

function Trigger( actor Other, pawn EventInstigator )
{
   if(ConditionOwner != none)
   {
       ConditionOwner.Trigger(Other,EventInstigator);
   }
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
