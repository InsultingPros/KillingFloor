class FlareRevolverFire extends KFShotgunFire;

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
     RecoilRate=0.070000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=250
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_IJC_HalloweenSnd.FlarePistol_Fire_M"
     StereoFireSoundRef="KF_IJC_HalloweenSnd.FlarePistol_Fire_S"
     NoAmmoSoundRef="KF_HandcannonSnd.50AE_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000,Z=-5.000000)
     bWaitForRelease=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.400000
     AmmoClass=Class'KFMod.FlareRevolverAmmo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=10000.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(X=6.000000,Y=1.000000,Z=8.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.500000
     ProjectileClass=Class'KFMod.FlareRevolverProjectile'
     BotRefireRate=0.850000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stFlareRevolver'
     aimerror=42.000000
     Spread=0.017500
}
