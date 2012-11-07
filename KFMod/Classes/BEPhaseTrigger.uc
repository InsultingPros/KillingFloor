//==============================================
// BEPhaseTrigger - Slinky - 4/28/05
//==============================================
// Trigger which calls target object back to
// its original location/rotation when triggered
// DO NOT use this class on dynamically generated
// actors.  And one Actor per trigger.
//==============================================
// Black Ether Studios, 2005
//==============================================

class BEPhaseTrigger extends Triggers;

var Actor PhaseActor;
var vector PhaseLocation;
var rotator PhaseRotation;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Event != '' )
		ForEach AllActors(class'Actor',PhaseActor, Event)
			break;
	if ( PhaseActor != None )
	{
		PhaseLocation = PhaseActor.Location;
		PhaseRotation = PhaseActor.Rotation;
	}
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if(PhaseActor != None)
	{
		PhaseActor.SetRotation(PhaseRotation);
		PhaseActor.SetLocation(PhaseLocation);
	}
}

defaultproperties
{
}
