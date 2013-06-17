//=============================================================================
// M99Fire
//=============================================================================
// M99 Sniper Rifle primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class M99Fire extends KFShotgunFire;

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function float MaxRange()
{
    return 25000;
}

function DoFireEffect()
{
   Super(KFShotgunFire).DoFireEffect();
}

defaultproperties
{
     EffectiveRange=25000.000000
     RecoilRate=0.100000
     maxVerticalRecoilAngle=4000
     maxHorizontalRecoilAngle=90
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     FireSoundRef="KF_M99Snd.M99_Fire_M"
     StereoFireSoundRef="KF_M99Snd.M99_Fire_S"
     NoAmmoSoundRef="KF_SCARSnd.SCAR_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(Y=0.000000,Z=0.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireForce="AssaultRifleFire"
     FireRate=3.030000
     AmmoClass=Class'KFMod.M99Ammo'
     ShakeRotMag=(X=5.000000,Y=7.000000,Z=3.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=5.000000,Y=5.000000,Z=5.000000)
     ProjectileClass=Class'KFMod.M99Bullet'
     BotRefireRate=3.570000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stPTRD'
     aimerror=0.000000
     Spread=0.004000
}
