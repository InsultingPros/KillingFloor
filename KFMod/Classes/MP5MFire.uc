//=============================================================================
// MP5MFire
//=============================================================================
// MP5 Medic Gun primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MFire extends KFHighROFFire;

defaultproperties
{
     FireEndSoundRef="KF_MP5Snd.MP5_Fire_Loop_End_M"
     FireEndStereoSoundRef="KF_MP5Snd.MP5_Fire_Loop_End_S"
     AmbientFireSoundRef="KF_MP5Snd.MP5_Fire_Loop"
     RecoilRate=0.060000
     maxVerticalRecoilAngle=124
     maxHorizontalRecoilAngle=75
     RecoilVelocityScale=0.000000
     ShellEjectClass=Class'ROEffects.KFShellEjectMP5SMG'
     ShellEjectBoneName="Shell_eject"
     NoAmmoSoundRef="KF_MP7Snd.MP7_DryFire"
     DamageType=Class'KFMod.DamTypeMP5M'
     DamageMin=25
     DamageMax=30
     Momentum=5500.000000
     FireRate=0.075000
     AmmoClass=Class'KFMod.MP5MAmmo'
     ShakeRotMag=(X=25.000000,Y=25.000000,Z=125.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.000000,Y=2.500000,Z=5.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     Spread=0.010000
     SpreadStyle=SS_Random
}
