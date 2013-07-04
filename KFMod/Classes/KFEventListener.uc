//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFEventListener extends Actor;

var Actor MyActor;

function SetEventListenerInfo( Actor AttachedActor, Name EventName )
{
	MyActor = AttachedActor;
	Tag = EventName;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( MyActor != none )
	{
	 	MyActor.ReceivedEvent( Tag );
 	}
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
