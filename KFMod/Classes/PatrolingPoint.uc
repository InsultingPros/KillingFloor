Class PatrolingPoint extends PathNode;

var() edfindable PatrolingPoint nextPatrolPoint;
var() float PatrolPauseTime;
var() name PatrolWaitForEvent;
var() bool bRunToThisPoint;
var vector LookDirection;

function PostBeginPlay()
{
	LookDirection = vector(Rotation)*2000+Location;
	Super.PostBeginPlay();
}

defaultproperties
{
     Texture=Texture'Engine.S_NavP'
}
