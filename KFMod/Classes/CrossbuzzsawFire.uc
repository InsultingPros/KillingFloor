class CrossbuzzsawFire extends KFShotgunFire;

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

defaultproperties
{
     EffectiveRange=7500.000000
     RecoilRate=0.100000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=125
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     FireSoundRef="KF_IJC_HalloweenSnd.CrossBuzzSaw_Fire_M"
     StereoFireSoundRef="KF_IJC_HalloweenSnd.CrossBuzzSaw_Fire_S"
     NoAmmoSoundRef="KF_XbowSnd.Xbow_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=7.000000,Z=-8.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireForce="AssaultRifleFire"
     FireRate=2.000000
     AmmoClass=Class'KFMod.CrossbuzzsawAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'KFMod.CrossbuzzsawBlade'
     BotRefireRate=1.800000
     aimerror=1.000000
     Spread=0.100000
}
