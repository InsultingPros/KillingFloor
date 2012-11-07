// for debugging
class BrainDeadZombie extends ZombieClot;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
