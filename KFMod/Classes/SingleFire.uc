//=============================================================================
// 9mm Fire
//=============================================================================
class SingleFire extends KFFire;

var name FireAnim2;

function StartBerserk()
{
	DamageMin = default.DamageMin * 1.33;
	DamageMax = default.DamageMax * 1.33;
}

function StopBerserk()
{
	DamageMin = default.DamageMin;
	DamageMax = default.DamageMax;
}

function StartSuperBerserk()
{

}

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=300
     maxHorizontalRecoilAngle=50
     ShellEjectClass=Class'ROEffects.KFShellEject9mm'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     StereoFireSoundRef="KF_9MMSnd.9mm_FireST"
     DamageType=Class'KFMod.DamTypeDualies'
     DamageMin=25
     DamageMax=35
     Momentum=10000.000000
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireAnimRate=1.500000
     TweenTime=0.025000
     FireSound=SoundGroup'KF_9MMSnd.9mm_Fire'
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.175000
     AmmoClass=Class'KFMod.SingleAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.350000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     aimerror=30.000000
     Spread=0.015000
     SpreadStyle=SS_Random
}
