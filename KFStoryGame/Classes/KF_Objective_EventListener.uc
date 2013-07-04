/*
	--------------------------------------------------------------
	KF_Objective_EventListener
	--------------------------------------------------------------

    Bzsic Proxy actor which receives trigger events for Objective conditions.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_Objective_EventListener extends actor;

var private KF_ObjectiveCondition        ConditionOwner;

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
