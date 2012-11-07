//===================================================================
// ProjectileBodyPart
// Copyright (C) 2012 Tripwire Interactive LLC
// John "Ramm-Jaeger"  Gibson
//
// Base class for body parts that have been blown and attached to a
// projectile to fly through the air, stick to a wall, etc
//===================================================================
class ProjectileBodyPart extends Actor;

var class <Emitter>		BleedingEmitterClass;		// class of the bleeding emitter
var() Emitter Trail;
var() float	MaxSpeed;	// Maximum speed this Gib should move

simulated function PostBeginPlay()
{
   SpawnTrail();
}

simulated function Destroyed()
{
    if( Trail != none )
        Trail.Destroy();

	Super.Destroyed();
}

simulated function SpawnTrail()
{
    if ( Level.NetMode != NM_DedicatedServer )
    {
		Trail = Spawn(BleedingEmitterClass, self,, Location, Rotation);
		Trail.LifeSpan = LifeSpan;//1.8;

		Trail.SetPhysics( PHYS_Trailer );
	}
}

defaultproperties
{
     BleedingEmitterClass=Class'ROEffects.ROBloodSpurt'
     MaxSpeed=100000.000000
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_None
     LifeSpan=8.000000
     bHardAttach=True
     TransientSoundVolume=0.170000
     Mass=30.000000
}
