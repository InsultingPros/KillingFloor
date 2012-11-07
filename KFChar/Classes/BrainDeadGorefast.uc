// for debugging
class BrainDeadGorefast extends ZombieGorefast;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
