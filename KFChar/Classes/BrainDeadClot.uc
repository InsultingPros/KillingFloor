// for debugging
class BrainDeadClot extends ZombieClot;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
