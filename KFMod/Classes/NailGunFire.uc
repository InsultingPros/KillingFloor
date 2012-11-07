//=============================================================================
// NailGunFire
//=============================================================================
// Nailgun primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class NailGunFire extends KFShotgunFire;

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Spread = Default.Spread;

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
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

	super(BaseProjectileFire).ModeDoFire();

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
    }
}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

    //log("Spread = "$Spread);

	return super(WeaponFire).AllowFire();
}

defaultproperties
{
     KickMomentum=(X=-25.000000)
     maxVerticalRecoilAngle=1250
     maxHorizontalRecoilAngle=750
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_NailShotgun.NailShotgun_Fire_Single_M"
     StereoFireSoundRef="KF_NailShotgun.NailShotgun_Fire_Single_S"
     NoAmmoSoundRef="KF_NailShotgun.KF_NailShotgun_Dryfire"
     ProjPerFire=7
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireRate=0.500000
     AmmoClass=Class'KFMod.NailGunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'KFMod.NailGunProjectile'
     BotRefireRate=0.500000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stNailGun'
     aimerror=1.000000
     Spread=2500.000000
}
