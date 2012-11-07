// for debugging
class BrainDeadBoss extends ZombieBoss;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
