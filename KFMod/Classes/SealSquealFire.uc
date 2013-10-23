//=============================================================================
// SealSquealFire
//=============================================================================
// Weapon fire class for the seal squeal harpoon bomb launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SealSquealFire extends KFShotgunFire;

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


function float MaxRange()
{
    return 2500;
}

defaultproperties
{
     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=250
     FireAimedAnim="Iron_Fire"
     FireSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Fire_M"
     StereoFireSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Fire"
     NoAmmoSoundRef="KF_M79Snd.M79_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=30.000000,Y=4.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireForce="AssaultRifleFire"
     FireRate=0.750000
     AmmoClass=Class'KFMod.SealSquealAmmo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=10000.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(X=6.000000,Y=1.000000,Z=8.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.500000
     ProjectileClass=Class'KFMod.SealSquealProjectile'
     BotRefireRate=1.800000
     FlashEmitterClass=Class'KFMod.SealSquealMuzzleFlash1P'
     aimerror=42.000000
     Spread=0.015000
}
