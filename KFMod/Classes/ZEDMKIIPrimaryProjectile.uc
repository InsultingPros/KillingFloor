//=============================================================================
// ZEDMKIIPrimaryProjectile
//=============================================================================
// Energy ball projectile for the ZEDGun MKII
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIIPrimaryProjectile extends LAWProj;

var()   float       HeadShotDamageMult;

var     Emitter     FlameTrail;
var     class<Emitter> ExplosionEmitter;
var     class<Emitter> FlameTrailEmitterClass;
var     float       ExplosionSoundVolume;

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------
simulated function PostBeginPlay()
{

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
		}
	}

    OrigLoc = Location;

    if( !bDud )
    {
        Dir = vector(Rotation);
        Velocity = speed * Dir;
    }

    super(ROBallisticProjectile).PostBeginPlay();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController  LocalPlayer;
    local float ShakeScale;

    bHasExploded = True;

    // Don't explode if this is a dud
    if( bDud )
    {
        Velocity = vect(0,0,0);
        LifeSpan=1.0;
        SetPhysics(PHYS_Falling);
    }

    PlaySound(ExplosionSound,,ExplosionSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitter,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ( LocalPlayer != none )
    {
        ShakeScale = GetShakeScale(Location, LocalPlayer.ViewTarget.Location);
        if( ShakeScale > 0 )
        {
            LocalPlayer.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
        }
    }

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if ( PlayerController(C) != None && C != LocalPlayer )
        {
            ShakeScale = GetShakeScale(Location, PlayerController(C).ViewTarget.Location);
            if( ShakeScale > 0 )
            {
                C.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
            }
        }
    }
}

// Get the shake amount for when this projectile explodes
simulated function float GetShakeScale(vector ViewLocation, vector EventLocation)
{
    local float Dist;
    local float scale;

    Dist = VSize(ViewLocation - EventLocation);

	if (Dist < DamageRadius * 2.0 )
	{
		scale = (DamageRadius*2.0  - Dist) / (DamageRadius*2.0);
	}

	return scale;
}

// Overridden to not do explosive damage
simulated function BlowUp(vector HitLocation)
{
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;

	// Don't let it hit this player, or blow up on another player
	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

    // Don't collide with bullet whip attachments
    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    // Don't allow hits on poeple on the same team
    if( KFHumanPawn(Other) != none && Instigator != none
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

	// Use the instigator's location if it exists. This fixes issues with
	// the original location of the projectile being really far away from
	// the real Origloc due to it taking a couple of milliseconds to
	// replicate the location to the client and the first replicated location has
	// already moved quite a bit.
	if( Instigator != none )
	{
		OrigLoc = Instigator.Location;
	}

    X = Vector(Rotation);

    if( Role == ROLE_Authority )
    {
     	if( ROBulletWhipAttachment(Other) != none )
    	{
            if(!Other.Base.bDeleteMe)
            {
    	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

    			if( Other == none || HitPoints.Length == 0 )
    				return;

    			HitPawn = KFPawn(Other);

                if (Role == ROLE_Authority)
                {
        	    	if ( HitPawn != none )
        	    	{
         				// Hit detection debugging
        				/*log("Bullet hit "$HitPawn.PlayerReplicationInfo.PlayerName);
        				HitPawn.HitStart = HitLocation;
        				HitPawn.HitEnd = HitLocation + (65535 * X);*/

                        if( !HitPawn.bDeleteMe )
                        	HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,HitPoints);


                        // Hit detection debugging
        				//if( Level.NetMode == NM_Standalone)
        				//	HitPawn.DrawBoneLocation();
        	    	}
        		}
    		}
    	}
        else
        {
            if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
            {
                Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
            }
            else
            {
                Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
            }
        }
    }

	if( !bDud )
	{
	   Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function Destroyed()
{
	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
        FlameTrail.SetPhysics(PHYS_None);
	}

	Super.Destroyed();
}

defaultproperties
{
     HeadShotDamageMult=1.500000
     ExplosionEmitter=Class'KFMod.ZEDMKIIPrimaryProjectileImpact'
     FlameTrailEmitterClass=Class'KFMod.ZEDMKIIPrimaryProjectileTrail'
     ExplosionSoundVolume=1.650000
     ArmDistSquared=0.000000
     StaticMeshRef="ZED_FX_SM.Energy.ZED_FX_Energy_Card"
     ExplosionSoundRef="KF_FY_ZEDV2SND.WEP_ZEDV2_Projectile_Explode"
     AmbientSoundRef="KF_FY_ZEDV2SND.WEP_ZEDV2_Projectile_Loop"
     AmbientVolumeScale=2.500000
     Speed=1500.000000
     MaxSpeed=1700.000000
     Damage=50.000000
     DamageRadius=0.000000
     MyDamageType=Class'KFMod.DamTypeZEDGunMKII'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
     LightType=LT_Steady
     LightHue=128
     LightSaturation=64
     LightBrightness=255.000000
     LightRadius=4.000000
     LightCone=16
     bDynamicLight=True
     DrawScale=0.500000
     AmbientGlow=254
     bUnlit=True
}
