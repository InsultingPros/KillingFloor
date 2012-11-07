// for debugging
class BrainDeadFleshPound extends ZombieFleshPound;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
