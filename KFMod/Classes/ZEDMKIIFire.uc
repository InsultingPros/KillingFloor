//=============================================================================
// ZEDMKIIFire
//=============================================================================
// Primary fire class for the Zed Gun Mark II Weapon
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIIFire extends KFShotgunFire;

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
     maxVerticalRecoilAngle=225
     maxHorizontalRecoilAngle=125
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_FY_ZEDV2SND.WEP_ZEDV2_Fire_M"
     StereoFireSoundRef="KF_FY_ZEDV2SND.WEP_ZEDV2_Fire_S"
     NoAmmoSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Dryfire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=18.000000,Z=-14.500000)
     bModeExclusive=False
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.125000
     AmmoClass=Class'KFMod.ZEDMKIIAmmo'
     ShakeRotMag=(X=30.000000,Y=30.000000,Z=250.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.500000,Y=1.500000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.000000
     ProjectileClass=Class'KFMod.ZEDMKIIPrimaryProjectile'
     BotRefireRate=0.250000
     FlashEmitterClass=Class'KFMod.ZEDMKIIPrimaryMuzzleFlash1P'
     aimerror=42.000000
     Spread=0.017500
}
