//==============================================
//  BEControlTrigger - Slinky - 4/28/05
//==============================================
//  Enables/disables a single trigger/whatever
// by replacing its event tag with ''/putting
// it back.
//==============================================
// Black Ether Studios, 2005.
//==============================================
class BEControlTrigger extends Triggers;

var(Events) bool bInitiallyDisable; //Required if you want
                                    //to use this trigger
                                    //to activate object

var Actor ControlledActor;
var name stolenEvent;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Event != '' )
		ForEach AllActors(class'Actor',ControlledActor, Event)
			break;
	if ( ControlledActor != None)
	{
		stolenEvent = ControlledActor.Event;
		if(bInitiallyDisable)
		    ControlledActor.Event = '';
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
    ControlledActor.Event = stolenEvent;
}

function Untrigger(Actor Other, pawn EventInstigator)
{
    ControlledActor.Event = '';
}

defaultproperties
{
}
