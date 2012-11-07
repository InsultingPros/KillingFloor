//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DoorGib extends Actor
	Abstract;

var() float DampenFactor;
var Sound	HitSounds[2];

var float NewGibSize;
var() float ScaleFactor; // Scale factor  < 1 = larger chunks.

simulated function PostBeginPlay()
{
	RandSpin( 64000 );
}
simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand(True);
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;
}
simulated function Landed( Vector HitNormal )
{
	HitWall( HitNormal, None );
}
simulated function HitWall( Vector HitNormal, Actor Wall )
{
	local float Speed, MinSpeed;

	Velocity = DampenFactor * ((Velocity dot HitNormal) * HitNormal*(-2.0) + Velocity);
	RandSpin(100000);
	Speed = VSize(Velocity);
	if (  Level.DetailMode == DM_Low )
		MinSpeed = 250;
	else MinSpeed = 150;
	if(Speed > MinSpeed)
	{
 		if( (Level.NetMode != NM_DedicatedServer) && !Level.bDropDetail )
 		{
 			if ( (LifeSpan < 7.3)  && (Level.DetailMode != DM_Low) )
				PlaySound(HitSounds[Rand(2)]);
		}
	}

	if( Speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     DampenFactor=0.500000
     ScaleFactor=0.700000
     Physics=PHYS_Falling
     RemoteRole=ROLE_None
     LifeSpan=15.000000
     TransientSoundVolume=100.000000
     bCollideWorld=True
     bBounce=True
     bFixedRotationDir=True
     Mass=120.000000
}
