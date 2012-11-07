// A very stupid hack for large zombies.
class ExtendedZCollision extends Actor
	NotPlaceable
	Transient;

// Damage the player this is attached to
function TakeDamage( int Damage, Pawn EventInstigator, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( Owner!=None )
		Owner.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitIndex);
}

defaultproperties
{
     DrawType=DT_None
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     SurfaceType=EST_Flesh
     bCollideActors=True
     bProjTarget=True
     bUseCylinderCollision=True
}
