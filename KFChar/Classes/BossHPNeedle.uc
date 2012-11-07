class BossHPNeedle extends Decoration
	NotPlaceable;

#exec obj load file="NewPatchSM.usx"

simulated function DroppedNow()
{
	SetCollision(True);
	SetPhysics(PHYS_Falling);
	bFixedRotationDir = True;
	RotationRate = RotRand(True);
}
simulated function HitWall( vector HitNormal, actor HitWall )
{
	local rotator R;

	if( VSize(Velocity)<40 )
	{
		SetPhysics(PHYS_None);
		R.Roll = Rand(65536);
		R.Yaw = Rand(65536);
		SetRotation(R);
		Return;
	}
	Velocity = MirrorVectorByNormal(Velocity,HitNormal)*0.75;
	if( HitWall!=None && HitWall.Physics!=PHYS_None )
		Velocity+=HitWall.Velocity;
}
simulated function Landed( vector HitNormal )
{
	HitWall(HitNormal,None);
}
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( Physics==PHYS_None )
	{
		SetPhysics(PHYS_Falling);
		bFixedRotationDir = True;
		RotationRate = RotRand(True);
		Velocity = vect(0,0,0);
	}
	Velocity+=momentum/10;
}
simulated function Destroyed();
function Bump( actor Other );
singular function PhysicsVolumeChange( PhysicsVolume NewVolume );

// Overriden so it doesn't damage the patriarch when he drops a needle!
singular function BaseChange()
{
	if( Velocity.Z < -500 )
		TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , class'Crushed');

	if( base == None )
	{
		if ( !bInterpolating && bPushable && (Physics == PHYS_None) )
			SetPhysics(PHYS_Falling);
	}
	else if( Pawn(Base) != None )
	{
		//Base.TakeDamage( (1-Velocity.Z/400)* mass/Base.Mass,Instigator,Location,0.5 * Velocity , class'Crushed');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else if( Decoration(Base)!=None && Velocity.Z<-500 )
	{
		Base.TakeDamage((1 - Mass/Base.Mass * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, class'Crushed');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else
		instigator = None;
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewPatchSM.BossSyringe'
     bStatic=False
     RemoteRole=ROLE_None
     LifeSpan=300.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bCollideWorld=True
     bProjTarget=True
     bBounce=True
}
