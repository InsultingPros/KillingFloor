class KF_StoryElevator_Door extends Mover;

var KF_StoryElevator				MyElevator;

var()	name						ElevatorTag;

var		vector						InitialClosedLoc,InitialBasePos;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	foreach DynamicActors(class 'KF_StoryElevator', MyElevator, ElevatorTag)
	{
		break;
	}

	InitialBasePos = BasePos;

	if(MyElevator != none)
	{
		MyElevator.Doors[MyElevator.Doors.length] = self;
	}
}

// when the doors close, Base on and then move the elevator */
function FinishedClosing()
{
	Super.FinishedClosing();

	if(MyElevator != none)
	{
		InitialClosedLoc = Location;
		MyElevator.NotifyDoorsClosed();
	}
}

// Toggle when triggered.
state() TriggerToggle
{
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		/* elevator is in motion.  would be a bad time to open the doors. */
		if(MyElevator != none && MyElevator.bInterpolating)
		{
			return;
		}

		Super.Trigger(Other,EventInstigator);
	}

	function Reset()
	{
		super.Reset();

		DetachFromElevator(true);

		// Reset instantly
		SetResetStatus( true );
		GotoState( 'TriggerToggle', 'Close' );

	}
}

function AttachToElevator()
{
	SetPhysics(PHYS_None);
	bHardAttach = true;
	SetBase(MyElevator);
}

function DetachFromElevator(optional bool bReset)
{
	if(bReset)
	{
		ResetKeyPositions();
	}
	else
	{
		UpdateKeyPositions();
	}

	SetPhysics(default.Physics);
	SetBase(none);
	bHardAttach = false;
}

function UpdateKeyPositions()
{
	BasePos.Z = Location.Z ;
}

function ResetKeyPositions()
{
	BasePos = InitialBasePos;
}

defaultproperties
{
     MoverEncroachType=ME_IgnoreWhenEncroach
     InitialState="TriggerToggle"
}
