//=============================================================================
// FlareRevolverProjectile
//=============================================================================
// Fireball projectile for the flare revolver
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development
//=============================================================================
class FlareRevolverProjectile extends LAWProj;

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

	// Difficulty Scaling
//	if (Level.Game != none)
//	{
//        if( Level.Game.GameDifficulty < 2.0 )
//        {
//            Damage = default.Damage * 0.75;
//        }
//        else if( Level.Game.GameDifficulty < 4.0 )
//        {
//            Damage = default.Damage * 1.0;
//        }
//        else if( Level.Game.GameDifficulty < 5.0 )
//        {
//            Damage = default.Damage * 1.15;
//        }
//        else // Hardest difficulty
//        {
//            Damage = default.Damage * 1.3;
//        }
//	}

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
                        	HitPawn.ProcessLocationalDamage(ImpactDamage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType,HitPoints);


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
                Pawn(Other).TakeDamage(ImpactDamage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType);
            }
            else
            {
                Other.TakeDamage(ImpactDamage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType);
            }
        }
    }

	if( !bDud )
	{
	   Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
 Overriden so it doesn't attemt to damage the bullet whiz cylinder - TODO: maybe implement the same thing in the superclass - Ramm
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

    if ( bHurtEntry )
        return;

    bHurtEntry = true;

    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Victims != Instigator) &&(Hurtwall != Victims)
            && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
            && ExtendedZCollision(Victims)==None && KFBulletWhipAttachment(Victims)==None )
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

                KFMonsterVictim = KFMonster(Victims);

    			if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
    			{
                    KFMonsterVictim = none;
    			}

                KFP = KFPawn(Victims);

                if( KFMonsterVictim != none )
                {
                    damageScale *= KFMonsterVictim.GetExposureTo(HitLocation);
                }
                else if( KFP != none )
                {
				    damageScale *= KFP.GetExposureTo(HitLocation);
                }

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					P = none;
				}
			}

            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
                (damageScale * Momentum * dirs),
                DamageType
            );
            if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
            {
                NumKilled++;
            }
        }
    }
    if ( (LastTouched != None) && (LastTouched != self) && (LastTouched != Instigator) &&
        (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
        Victims = LastTouched;
        LastTouched = None;
        dirs = Victims.Location - HitLocation;
        dist = FMax(1,VSize(dirs));
        dirs = dirs/dist;
        damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
        if ( Instigator == None || Instigator.Controller == None )
            Victims.SetDelayedDamageInstigatorController(InstigatorController);

        log("Part 2 Doing "$(damageScale * DamageAmount)$" damage to "$Victims);
        Victims.TakeDamage
        (
            damageScale * DamageAmount,
            Instigator,
            Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
            (damageScale * Momentum * dirs),
            DamageType
        );
        if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
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

//==============
// Touching
// Overridden to not touch the bulletwhip attachment
//simulated singular function Touch(Actor Other)
//{
//	if ( Other == None || KFBulletWhipAttachment(Other)!=None )
//		return;
//
//    super.Touch(Other);
//}


// Don't hit Zed extra collision cylinders
//simulated function ProcessTouch(Actor Other, Vector HitLocation)
//{
//    if( ExtendedZCollision(Other) != none )
//    {
//        return;
//    }
//
//    super.ProcessTouch(Other, HitLocation);
//}

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
     ExplosionEmitter=Class'KFMod.FlareRevolverImpact'
     FlameTrailEmitterClass=Class'KFMod.FlareRevolverTrail'
     ExplosionSoundVolume=1.650000
     ArmDistSquared=0.000000
     ImpactDamageType=Class'KFMod.DamTypeFlareProjectileImpact'
     ImpactDamage=100
     StaticMeshRef="EffectsSM.Ger_Tracer"
     ExplosionSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Hit"
     AmbientSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop"
     AmbientVolumeScale=2.500000
     Speed=1500.000000
     MaxSpeed=1700.000000
     Damage=25.000000
     DamageRadius=100.000000
     MyDamageType=Class'KFMod.DamTypeFlareRevolver'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
     LightType=LT_Steady
     LightHue=255
     LightSaturation=64
     LightBrightness=255.000000
     LightRadius=16.000000
     LightCone=16
     bDynamicLight=True
     DrawScale=1.000000
     AmbientGlow=254
     bUnlit=True
}
