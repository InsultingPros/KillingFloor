//=============================================================================
// HuskGunFire
//=============================================================================
// Husk Gun primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class HuskGunFire extends KFShotgunFire;

// sound
var 	sound                  AmbientChargeUpSound;           // The charging up of the weapon
var 	float                  AmbientFireSoundRadius;         // The sound radius for the ambient fire sound
var		sound                  AmbientFireSound;               // How loud to play the looping ambient fire sound
var		byte                   AmbientFireVolume;              // The ambient fire sound

var		string                 AmbientChargeUpSoundRef;
var		string                 AmbientFireSoundRef;

var()   float                  MaxChargeTime;                   // The maximum amount of time for a full charged shot
var() class<Projectile> WeakProjectileClass;
var() class<Projectile> StrongProjectileClass;

var() class<Emitter> ChargeEmitterClass;
var() Emitter ChargeEmitter;

static function PreloadAssets(LevelInfo LevelInfo, optional KFShotgunFire Spawned)
{
	super.PreloadAssets(LevelInfo, Spawned);

	if ( default.AmbientChargeUpSoundRef != "" )
	{
		default.AmbientChargeUpSound = sound(DynamicLoadObject(default.AmbientChargeUpSoundRef, class'sound', true));
	}

	if ( default.AmbientFireSoundRef != "" )
	{
		default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
	}

	if ( HuskGunFire(Spawned) != none )
	{
		HuskGunFire(Spawned).AmbientChargeUpSound = default.AmbientChargeUpSound;
		HuskGunFire(Spawned).AmbientFireSound = default.AmbientFireSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.AmbientChargeUpSound = none;
	default.AmbientFireSound = none;

	return true;
}

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function float MaxRange()
{
    return 2500;
}

function DoFireEffect()
{
   Super(KFShotgunFire).DoFireEffect();
}


function PlayPreFire()
{
	if( KFWeapon(Weapon).bAimingRifle )
	{
		Weapon.PlayAnim('Charge_Iron', 1.0, 0.1);
	}
	else
	{
		Weapon.PlayAnim('Charge', 1.0, 0.1);
	}
}

function ModeHoldFire()
{
    // Play the chargeup sound
    PlayAmbientSound(AmbientChargeUpSound);
    InitChargeEffect();
    SetTimer(0.15, true);
}

// Handles toggling the weapon attachment's ambient sound on and off
function PlayAmbientSound(Sound aSound)
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

    if ( Weapon == none || (WA == none))
        return;

	if(aSound == None)
	{
		WA.SoundVolume = WA.default.SoundVolume;
		WA.SoundRadius = WA.default.SoundRadius;
	}
	else
	{
		WA.SoundVolume = AmbientFireVolume;
		WA.SoundRadius = AmbientFireSoundRadius;
	}

    WA.AmbientSound = aSound;
}

function Timer()
{
    local float ChargeScale;
	local HuskGunAttachment WA;

	WA = HuskGunAttachment(Weapon.ThirdPersonActor);

    if (HoldTime > 0.0 && !bNowWaiting)
    {
        if( HoldTime < MaxChargeTime )
        {
            PlayAmbientSound(AmbientChargeUpSound);
            ChargeScale = HoldTime/MaxChargeTime;
            WA.HuskGunCharge = ChargeScale * 255;
            WA.UpdateHuskGunCharge();
            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = Lerp( ChargeScale, 4, 10 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = Lerp( ChargeScale, 2, 6 );
            }
        }
        else
        {
            PlayAmbientSound(AmbientFireSound);
            WA.HuskGunCharge = 255;
            WA.UpdateHuskGunCharge();

            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = 10;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = 300;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = 300;
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = 6;
            }
        }
    }
    else
    {
        PlayAmbientSound(none);
        DestroyChargeEffect();
        WA.HuskGunCharge = 0;
        WA.UpdateHuskGunCharge();

        SetTimer(0, false);
    }
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( HoldTime < (MaxChargeTime * 0.33) )
    {
        ProjectileClass = WeakProjectileClass;
    }
    else if( HoldTime < (MaxChargeTime * 0.66) )
    {
        ProjectileClass = default.ProjectileClass;
    }
    else
    {
        ProjectileClass = StrongProjectileClass;
}

    p = super.SpawnProjectile(Start, Dir);

    if( p == None )
        return None;

    if( HoldTime < MaxChargeTime )
    {
        HuskGunProjectile(p).ImpactDamage *= HoldTime * 2.5;
        HuskGunProjectile(p).Damage *= (1.0 + (HoldTime/MaxChargeTime));// up to double damage
        HuskGunProjectile(p).DamageRadius *= (1.0 + (HoldTime/(MaxChargeTime/2.0)));// up 3x the damage radius
    }
    else
    {
        HuskGunProjectile(p).ImpactDamage *= MaxChargeTime * 2.5;
        HuskGunProjectile(p).Damage *= 2.0;// up to double damage
        HuskGunProjectile(p).DamageRadius *= 3.0;// up 3x the damage radius
    }
    return p;
}

// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
      	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
     	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

      	if( Rand( 2 ) == 1 )
         	NewRecoilRotation.Yaw *= -1;

        if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
            Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
        {
            AdjustedVelocity = Weapon.Owner.Velocity;
            // Ignore Z velocity in low grav so we don't get massive recoil
            AdjustedVelocity.Z = 0;
            AdjustedSpeed = VSize(AdjustedVelocity);
            //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

            // Reduce the falling recoil in low grav
            NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
    	    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
	    }
	    else
	    {
            //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
    	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
	    }

	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation *= Rec;

	    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
 	}
}

event ModeDoFire()
{
	local float Rec;
	local float AmmoAmountToUse;

	if (!AllowFire())
		return;

	Spread = Default.Spread;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        if( HoldTime < MaxChargeTime )
        {
            AmmoAmountToUse = (1.0 + (HoldTime/(MaxChargeTime/9.0)));// 10 ammo for full charge, at least 1 ammo used
        }
        else
        {
            AmmoAmountToUse = 10.0;// 10 ammo for full charge, at least 1 ammo used
        }

        if( Weapon.AmmoAmount(ThisModeNum) < AmmoAmountToUse )
        {
            AmmoAmountToUse = Weapon.AmmoAmount(ThisModeNum);
        }

        Weapon.ConsumeAmmo(ThisModeNum, AmmoAmountToUse);


        DoFireEffect();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
    }
}

simulated function InitChargeEffect()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;

    if ( (ChargeEmitterClass != None) && ((ChargeEmitter == None) || ChargeEmitter.bDeleteMe) )
    {
        ChargeEmitter = Weapon.Spawn(ChargeEmitterClass);
        if ( ChargeEmitter != None )
    		Weapon.AttachToBone(ChargeEmitter, 'tip');
    }
}

simulated function DestroyChargeEffect()
{
    if (ChargeEmitter != None)
        ChargeEmitter.Destroy();
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    DestroyChargeEffect();
}

defaultproperties
{
     AmbientFireSoundRadius=500.000000
     AmbientFireVolume=255
     AmbientChargeUpSoundRef="KF_HuskGunSnd.ChargeUp"
     AmbientFireSoundRef="KF_HuskGunSnd.ChargedLoop"
     MaxChargeTime=3.000000
     WeakProjectileClass=Class'KFMod.HuskGunProjectile_Weak'
     StrongProjectileClass=Class'KFMod.HuskGunProjectile_Strong'
     ChargeEmitterClass=Class'ROEffects.ChargeUp1stHusk'
     EffectiveRange=5000.000000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=250
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_HuskGunSnd.HuskGun_Fire"
     StereoFireSoundRef="KF_HuskGunSnd.HuskGun_FireST"
     NoAmmoSoundRef="KF_BaseHusk.Husk_WindDown01"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000,Z=-20.000000)
     bFireOnRelease=True
     bWaitForRelease=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireForce="AssaultRifleFire"
     FireRate=0.750000
     AmmoClass=Class'KFMod.HuskGunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFMod.HuskGunProjectile'
     BotRefireRate=1.800000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stHusk'
     aimerror=42.000000
     Spread=0.015000
}
