class KF_StoryElevator extends Mover;

var		array<KF_StoryElevator_Door>		Doors;


// Elevator stopped.  Detach the doors */
function FinishNotify()
{
	Super.FinishNotify();
	DetachDoors();
}

function NotifyDoorsClosed()
{
	if(!bInterpolating)
	{
		AttachDoors();
		Trigger(self,none);
	}
}

function DetachDoors()
{
	local int i;
	for(i = 0 ; i < Doors.length ; i ++)
	{
		Doors[i].DetachFromElevator();
		Doors[i].Trigger(self,none);
	}
}

function AttachDoors()
{
	local int i;
	for(i = 0 ; i < Doors.length ; i ++)
	{
		Doors[i].AttachToElevator();
	}
}


state() TriggerToggle
{
	function Reset()
	{
		super.Reset();

		// Reset instantly
		SetResetStatus( true );
		GotoState( 'TriggerToggle', 'Close' );
	}
}

defaultproperties
{
     MoverEncroachType=ME_CrushWhenEncroach
     InitialState="TriggerToggle"
}
