// for debugging
class BrainDeadCrawler extends ZombieCrawler;

event PostBeginPlay()
{
	Super.PostBeginPlay();

    SetMovementPhysics();
}

defaultproperties
{
     ControllerClass=None
}
