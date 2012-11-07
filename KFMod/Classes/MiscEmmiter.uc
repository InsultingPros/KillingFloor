class MiscEmmiter extends Emitter;

//Just to spawn nothing....

var class<DamageType> DamageType;
var vector HitLoc;

function PostBeginPlay()
{

}

simulated function Tick(float deltaTime)
{

}

simulated function Destroyed()
{
	if ( xPawn(Owner) != None )
	{
		xPawn(Owner).bFrozenBody = false;
		xPawn(Owner).PlayDyingAnimation(DamageType, HitLoc);
	}
}

defaultproperties
{
     DrawType=DT_Mesh
}
