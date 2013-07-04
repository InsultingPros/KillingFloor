/*
	--------------------------------------------------------------
	KFUseTrigger_Story
	--------------------------------------------------------------

	Custom Use Trigger that can trigger additional events.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KFUseTrigger_Story extends KFUseTrigger;

/* event to fire off when the doors associated with this trigger have been fully welded shut */
var(Events)		name		FullWeldEvent;

/* if true, this trigger starts life dormant. it can only be 'used' once it has been triggered */
var()			bool		bTriggerEnabled;

var()   		bool 		bEnabled;

var()           bool        bAllowZEDInteraction;

function AddWeld( float ExtraWeld, bool bZombieAttacking, Pawn WelderInst )
{
	Super.AddWeld(ExtraWeld,bZombieAttacking,WelderInst);

	if(WeldStrength >= MaxWeldStrength)
	{
		TriggerEvent(FullWeldEvent,self,none);
	}
}

function UsedBy(Pawn user)
{
	if(!bEnabled)
	{
		return;
	}

	Super.UsedBy(user);
}

function Touch( Actor Other )
{
    if(bEnabled && (!Other.IsA('KFMonster') || bAllowZEDInteraction))
    {
        Super.Touch(Other);
    }
}

function Reset()
{
	Super.Reset();
	bEnabled = !bTriggerEnabled ;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(bTriggerEnabled)
	{
		bEnabled = !bEnabled;
	}

	Super.Trigger(other,EventInstigator);
}

defaultproperties
{
     bEnabled=True
}
