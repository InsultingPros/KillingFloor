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

var()           bool        bShouldBeEnabledInWaveMode;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(KFStoryGameinfo(Level.Game) == none)
    {
        bEnabled = bShouldBeEnabledInWaveMode;
    }
}

function bool TriggerIsUseable()
{
    return bEnabled && bCollideActors;
}

function AddWeld( float ExtraWeld, bool bZombieAttacking, Pawn WelderInst )
{
    if(!TriggerIsUseable() && WelderInst != none)
    {
        return;
    }

	Super.AddWeld(ExtraWeld,bZombieAttacking,WelderInst);

	if(WeldStrength >= MaxWeldStrength)
	{
		TriggerEvent(FullWeldEvent,self,none);
	}
}

function UnWeld(float DeWeldage,bool bZombieAttacking, Pawn WelderInst)
{
    if(!TriggerIsUseable() && WelderInst != none)
    {
        return;
    }

    Super.UnWeld(DeWeldage,bZombieAttacking,WelderInst);
}

function UsedBy(Pawn user)
{
    if(!TriggerIsUseable())
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
     bShouldBeEnabledInWaveMode=True
}
