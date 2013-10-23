//=============================================================================
// ROBallisticProjectile
//=============================================================================
// Projectiles that do true ballistics calculations. Calculations
// are done in native code for this class and its subclasses when
// the physics are set to PHYS_Projectile
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROBallisticProjectile extends Projectile
	abstract
	native;

//=============================================================================
// Variables
//=============================================================================

var float	AmbientVolumeScale; // Amount to scale this projectiles ambient sound

// Constants
const 		ScaleFactor = 18.4;						// 18.4 unreal units = 1 foot in our game.
const 		ScaleFactorInverse = 0.0543;            // 1/Scalefactor

// Behavior
var()		float				BallisticCoefficient;	// Ballistic coefficient for this bullet
var			float				BCInverse;

// Debug
var 		bool 				bDebugBallistics;       // Set to true to turn on ballistics debugging
var			float				FlightTime;
var			Vector				OrigLoc;
var			Vector				TraceHitLoc;

var			bool				bTrueBallistics;		// If this is true do the true ballistics calcs in native, instead of standard projectile calcs
var 		bool				bInitialAcceleration;	// If this is true and bTrueBallistics is true, the projectile will accellerate to full speed over .1 seconds. This prevents the problem where a just spawned projectile passes right through something without colliding
var()		float				SpeedFudgeScale;        // Scales the velocity by this amount. Used to keep the proper ballistic trajectory while making the projectile phyically move slower
var()		float				MinFudgeScale; 			// When bInitalAcceleration and bTrueBallistics are true, the projectile will accellerate from MinFudgeScale up to SpeedFudgeScale over InitialAccelerationTime seconds
var()		float				InitialAccelerationTime;// Time in seconds it takes for the shell to get up to the full SpeedFudgeScale
//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	local Vector	HitNormal;
	local Actor TraceHitActor;

	Velocity = Vector(Rotation) * Speed;
	BCInverse = 1 / BallisticCoefficient;

	if (Role == ROLE_Authority && Instigator != none && Instigator.HeadVolume.bWaterVolume)
		Velocity *= 0.5;

	if (bDebugBallistics)
	{
		FlightTime = 0;
		OrigLoc = Location;

		TraceHitActor = Trace(TraceHitLoc, HitNormal, Location + 65355 * Vector(Rotation), Location + (Instigator.CollisionRadius + 5) * vector(Rotation), true);

		if( TraceHitActor.IsA('ROBulletWhipAttachment'))
		{
			  TraceHitActor = Trace(TraceHitLoc, HitNormal, Location + 65355 * Vector(Rotation), TraceHitLoc + 5 * Vector(Rotation), true);
		}
				// super slow debugging
     	//Spawn(class 'RODebugTracerGreen',self,,TraceHitLoc,Rotation);
     	log("Debug Tracing TraceHitActor ="$TraceHitActor);
	}
}

simulated function HitWall(vector HitNormal, actor Wall)
{

	if (bDebugBallistics)
	{
		log("BulletImpactVel = "$VSize(Velocity) / ScaleFactor$" BulletDist = "$(VSize(Location - OrigLoc) / 60.352)$" BulletDrop = "$(((TraceHitLoc.Z - Location.Z) / ScaleFactor) * 12));

		if (Level.NetMode != NM_DedicatedServer)
			Spawn(class 'RODebugTracer',self,,Location,Rotation);

//		ROPawn(Instigator).BulletImpactVel = VSize(Velocity) / ScaleFactor;
//		ROPawn(Instigator).BulletFlightTime = FlightTime;
//		ROPawn(Instigator).BulletDist = VSize(Location - OrigLoc) / ScaleFactor;
//		ROPawn(Instigator).BulletRefDist = VSize(TraceHitLoc - OrigLoc) / ScaleFactor;
//		ROPawn(Instigator).BulletDrop = ((TraceHitLoc.Z - Location.Z) / ScaleFactor) * 12;
	}

}

defaultproperties
{
     AmbientVolumeScale=1.000000
     BallisticCoefficient=0.300000
     bTrueBallistics=True
     bInitialAcceleration=True
     SpeedFudgeScale=1.000000
     MinFudgeScale=0.025000
     InitialAccelerationTime=0.100000
     TossZ=0.000000
}
