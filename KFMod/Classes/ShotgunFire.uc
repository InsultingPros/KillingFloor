//=============================================================================
// Shotgun Fire
//=============================================================================
class ShotgunFire extends KFShotgunFire;

defaultproperties
{
     KickMomentum=(X=-85.000000,Z=15.000000)
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     StereoFireSoundRef="KF_PumpSGSnd.SG_FireST"
     ProjPerFire=7
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnimRate=0.950000
     FireSound=SoundGroup'KF_PumpSGSnd.SG_Fire'
     NoAmmoSound=Sound'KF_PumpSGSnd.SG_DryFire'
     FireRate=0.965000
     AmmoClass=Class'KFMod.ShotgunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFMod.ShotgunBullet'
     BotRefireRate=1.500000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
     Spread=1125.000000
}
