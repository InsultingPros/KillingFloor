//=============================================================================
// ZEDGunFire
//=============================================================================
// ZEDGun primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ZEDGunFire extends KFShotgunFire;

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

	return super(WeaponFire).AllowFire();
}

function float MaxRange()
{
    return 10000;
}

defaultproperties
{
     RecoilRate=0.100000
     maxVerticalRecoilAngle=350
     maxHorizontalRecoilAngle=200
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Primary_M"
     StereoFireSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Primary_S"
     NoAmmoSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Dryfire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=18.000000,Z=-14.500000)
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.200000
     AmmoClass=Class'KFMod.ZEDGunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'KFMod.ZEDGunProjectile'
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stZEDGunPrimary'
     aimerror=42.000000
     Spread=0.017500
}
