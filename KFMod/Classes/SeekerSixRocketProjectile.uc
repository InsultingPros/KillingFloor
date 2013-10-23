//=============================================================================
// SeekerSixRocketProjectile
//=============================================================================
// Rocket projectile class for the SeekerSix mini rocket launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SeekerSixRocketProjectile extends LAWProj;

//var Emitter Corona;
var xEmitter RocketTrail;
var xEmitter RocketSmoke;

var byte FlockIndex;
var SeekerSixRocketProjectile Flock[6];

var(Flocking) float	FlockRadius;
var(Flocking) float	FlockStiffness;
var(Flocking) float FlockMaxForce;
var(Flocking) float	FlockCurlForce;
var bool bCurl;

var		string	AmbientSoundTwoRef;
var		string	AmbientSoundThreeRef;
var(Sound) sound AmbientSoundTwo;  // Ambient sound effect.
var(Sound) sound AmbientSoundThree;  // Ambient sound effect.

var()	InterpCurve     AppliedMomentumCurve;             // How much momentum to apply to a zed based on how much mass it has

replication
{
    reliable if ( bNetInitial && (Role == ROLE_Authority) )
        FlockIndex, bCurl;
}

static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
    default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));
    default.AmbientSoundTwo = sound(DynamicLoadObject(default.AmbientSoundTwoRef, class'Sound', true));
    default.AmbientSoundThree = sound(DynamicLoadObject(default.AmbientSoundThreeRef, class'Sound', true));
	default.DisintegrateSound = sound(DynamicLoadObject(default.DisintegrateSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.AmbientSound = none;
	default.AmbientSoundTwo = none;
	default.AmbientSoundThree = none;
	default.DisintegrateSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostBeginPlay()
{
	BCInverse = 1 / BallisticCoefficient;

	if( FRand() < 0.33 )
	{
	   AmbientSound = AmbientSoundTwo;
	}
	else if( FRand() < 0.33 )
	{
	   AmbientSound = AmbientSoundThree;
	}

	if ( Level.NetMode != NM_DedicatedServer)
	{
        RocketSmoke = Spawn(class'SeekerSixRocketSmokeX',self);
	    RocketTrail = Spawn(class'SeekerSixRocketTrailX',self);
	}

	OrigLoc = Location;

	if( !bDud )
	{
		Dir = vector(Rotation);
		Velocity = speed * Dir;
	}

	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
	super(Projectile).PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local SeekerSixRocketProjectile R;
	local int i, p, q;
	local Array<SeekerSixRocketProjectile> Rockets;

	Super.PostNetBeginPlay();

	if ( FlockIndex != 0 )
	{
	    SetTimer(0.1, true);

	    // look for other rockets and set thier flock values
	    if ( Flock[1] == None )
	    {
			Rockets[0]=self;
			i=1;

            ForEach DynamicActors(class'SeekerSixRocketProjectile',R)
				if ( R.FlockIndex == FlockIndex )
				{
                    if( R == Self )
                    {
                        continue;
                    }
                    Rockets[i] = R;
					i++;
					if ( i == 6 )
						break;
				}

            for ( p = 0; p < Rockets.Length; p++ )
            {
        		if ( Rockets[p] != None )
        		{
                    i = 0;
        			for ( q=0; q<Rockets.Length; q++ )
        			{
        				if ( (p != q) && (Rockets[q] != None) )
        				{
        					Rockets[p].Flock[i] = Rockets[q];
        					i++;
        				}
        			}
        		}
        	}
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local Controller C;
	local PlayerController  LocalPlayer;

	bHasExploded = True;

	// Don't explode if this is a dud
	if( bDud )
	{
		Velocity = vect(0,0,0);
		LifeSpan=1.0;
		SetPhysics(PHYS_Falling);
	}

	PlaySound(ExplosionSound,,2.0);
	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(class'KFMod.SeekerSixExplosionEmitter',,,HitLocation + HitNormal*20,rotator(HitNormal));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}

	BlowUp(HitLocation);
	Destroy();

	// Shake nearby players screens
	LocalPlayer = Level.GetLocalPlayerController();
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (PlayerController(C) != None) && (C != LocalPlayer)
			&& (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius) )
			C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
}

simulated function Timer()
{
    local vector ForceDir, CurlDir;
    local float ForceMag;
    local int i;

    // Handle disintegration
    if( bDisintegrated && Role == ROLE_Authority )
    {
        Destroy();
        return;
    }

	Velocity =  Default.Speed * Normal(Dir * 0.5 * Default.Speed + Velocity);

	// Work out force between flock to add madness
	for(i=0; i<6; i++)
	{
		if(Flock[i] == None)
			continue;

		// Attract if distance between rockets is over 2*FlockRadius, repulse if below.
		ForceDir = Flock[i].Location - Location;
		ForceMag = FlockStiffness * ( (2 * FlockRadius) - VSize(ForceDir) );
		Acceleration = Normal(ForceDir) * Min(ForceMag, FlockMaxForce);

		// Vector 'curl'
		CurlDir = Flock[i].Velocity Cross ForceDir;
		if ( bCurl == Flock[i].bCurl )
			Acceleration += Normal(CurlDir) * FlockCurlForce;
		else
			Acceleration -= Normal(CurlDir) * FlockCurlForce;
	}
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( damageType == class'SirenScreamDamage')
	{
		Disintegrate(HitLocation, vect(0,0,1));
	}
}

simulated function Destroyed()
{
//	if( Corona != none )
//    {
//        Corona.Kill();
//    }
//
   	if ( RocketTrail != none )
	{
		RocketTrail.mRegen=False;
		RocketTrail.SetPhysics(PHYS_None);
		RocketTrail.GotoState('');
	}

	if ( RocketSmoke != none )
	{
		RocketSmoke.mRegen=False;
		RocketSmoke.SetPhysics(PHYS_None);
		RocketSmoke.GotoState('');
	}


	Super.Destroyed();
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
 Overridden to scale the momentum of the zeds hit by mass based on a curve we define
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dirs;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	local float UsedMomentum;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
		{
			dirs = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dirs));
			dirs = dirs/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;

			P = Pawn(Victims);

			UsedMomentum = Momentum;

			if( P != none )
			{
		        for (i = 0; i < CheckedPawns.Length; i++)
				{
		        	if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}

				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}

				// Scale the momentum by the mass of the pawn hit
                UsedMomentum *= InterpCurveEval(AppliedMomentumCurve,Victims.Mass);

				KFMonsterVictim = KFMonster(Victims);

				if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
				{
					KFMonsterVictim = none;
				}

				KFP = KFPawn(Victims);

				if( KFMonsterVictim != none )
				{
					damageScale *= KFMonsterVictim.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
				}
				else if( KFP != none )
				{
				    damageScale *= KFP.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
				}

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					//Victims = P;
					P = none;
				}
			}


			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
				(damageScale * UsedMomentum * dirs),
				DamageType
			);

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, UsedMomentum, HitLocation);

			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
			{
				NumKilled++;
			}
		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dirs = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dirs));
		dirs = dirs/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);

        UsedMomentum = Momentum;

		if( Pawn(Victims) != none )
        {
            UsedMomentum *= InterpCurveEval(AppliedMomentumCurve,Victims.Mass);
        }

		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
			(damageScale * UsedMomentum * dirs),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, UsedMomentum, HitLocation);
	}

	if( Role == ROLE_Authority )
	{
		if( NumKilled >= 4 )
		{
			KFGameType(Level.Game).DramaticEvent(0.05);
		}
		else if( NumKilled >= 2 )
		{
			KFGameType(Level.Game).DramaticEvent(0.03);
		}
	}

	bHurtEntry = false;
}

defaultproperties
{
     FlockRadius=12.000000
     FlockStiffness=-100.000000
     FlockMaxForce=600.000000
     FlockCurlForce=450.000000
     AmbientSoundTwoRef="KF_FY_SeekerSixSND.WEP_Seeker_Rocket_LP_02"
     AmbientSoundThreeRef="KF_FY_SeekerSixSND.WEP_Seeker_Rocket_LP_03"
     AppliedMomentumCurve=(Points=((OutVal=0.500000),(InVal=100.000000,OutVal=0.500000),(InVal=350.000000,OutVal=1.000000),(InVal=600.000000,OutVal=1.000000)))
     ArmDistSquared=10000.000000
     ImpactDamageType=Class'KFMod.DamTypeSeekerRocketImpact'
     ImpactDamage=75
     StaticMeshRef="KF_IJC_Halloween_Weps2.seeker6_projectile"
     ExplosionSoundRef="KF_FY_SeekerSixSND.WEP_Seeker_Explode"
     AmbientSoundRef="KF_FY_SeekerSixSND.WEP_Seeker_Rocket_LP"
     Speed=2000.000000
     MaxSpeed=2000.000000
     Damage=100.000000
     DamageRadius=150.000000
     MyDamageType=Class'KFMod.DamTypeSeekerSixRocket'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
     DrawScale=2.500000
     RotationRate=(Roll=50000)
}
