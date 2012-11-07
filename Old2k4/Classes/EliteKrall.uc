class EliteKrall extends Krall;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	//MyAmmo.ProjectileClass = class'EliteKrallBolt';
}

defaultproperties
{
     ScoringValue=3
}
