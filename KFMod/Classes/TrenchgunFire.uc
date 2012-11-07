//=============================================================================
// Trenchgun Dragon's Breath Fire
//=============================================================================
class TrenchgunFire extends KFShotgunFire;

defaultproperties
{
     KickMomentum=(X=-85.000000,Z=15.000000)
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_ShotgunDragonsBreathSnd.ShotgunDragon_Fire_Single_M"
     StereoFireSoundRef="KF_ShotgunDragonsBreathSnd.ShotgunDragon_Fire_Single_S"
     NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
     ProjPerFire=14
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnimRate=0.950000
     FireRate=0.965000
     AmmoClass=Class'KFMod.TrenchgunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFMod.TrenchgunBullet'
     BotRefireRate=1.500000
     FlashEmitterClass=Class'KFMod.TrenchgunMuzzFlash'
     aimerror=1.000000
     Spread=1125.000000
}
