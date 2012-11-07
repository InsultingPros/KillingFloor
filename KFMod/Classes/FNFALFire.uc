//=============================================================================
// FNFALFire
//=============================================================================
// FN FAL Assault rifle primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class FNFALFire extends KFHighROFFire;

defaultproperties
{
     FireEndSoundRef="KF_FNFALSnd.FNFAL_Fire_Loop_End_M"
     FireEndStereoSoundRef="KF_FNFALSnd.FNFAL_Fire_Loop_End_S"
     AmbientFireSoundRef="KF_FNFALSnd.FNFAL_Fire_Loop"
     RecoilRate=0.080000
     maxVerticalRecoilAngle=150
     maxHorizontalRecoilAngle=115
     ShellEjectClass=Class'KFMod.KFShellEjectFAL'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     FireSoundRef="KF_FNFALSnd.FNFAL_Fire_Single_M"
     StereoFireSoundRef="KF_FNFALSnd.FNFAL_Fire_Single_S"
     NoAmmoSoundRef="KF_SCARSnd.SCAR_DryFire"
     DamageType=Class'KFMod.DamTypeFNFALAssaultRifle'
     DamageMin=60
     DamageMax=65
     Momentum=8500.000000
     FireRate=0.085700
     AmmoClass=Class'KFMod.FNFALAmmo'
     ShakeRotMag=(X=80.000000,Y=80.000000,Z=450.000000)
     ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     ShakeRotTime=0.650000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=8.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.150000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=42.000000
     Spread=0.008500
     SpreadStyle=SS_Random
}
