//=========================================
// BESpawnVolume - Slinky - 4/28/05
//=========================================
//  Spawns an actor of the associated type
// on trigger.  Good for various things.
//=========================================
//  Black Ether Studios, 2005.
//=========================================
class BESpawnVolume extends Volume;

var(Events) class<Actor> CreateOnTrigger;
var(Events) bool SpawnObjectAtStart;

var Actor myActor;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(SpawnObjectAtStart && CreateOnTrigger != None)
		myActor = Spawn(CreateOnTrigger);
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if(myActor != None)
		myActor.Destroy();
	if(CreateOnTrigger != None)
		myActor = Spawn(CreateOnTrigger);
}

defaultproperties
{
}
