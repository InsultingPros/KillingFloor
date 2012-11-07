//=============================================================================
// BoomStick Dual Fire
//=============================================================================
class BoomStickFire extends KFShotgunFire;

var()   Emitter     Flash2Emitter;
var()   name        MuzzleBoneLeft;
var()   name        MuzzleBoneRight;

event ModeDoFire()
{
	if (!AllowFire())
		return;

    super.ModeDoFire();

    BoomStick(Weapon).ClientSetSingleShotCount( 0 );

    BoomStick(Weapon).SetPendingReload();
}

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
        return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(FlashEmitter, MuzzleBoneLeft);
    }
    if ( (FlashEmitterClass != None) && ((Flash2Emitter == None) || Flash2Emitter.bDeleteMe) )
    {
        Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(Flash2Emitter, MuzzleBoneRight);
    }

    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (Flash2Emitter != None)
        Flash2Emitter.Destroy();
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();

    if (Flash2Emitter != None)
        Flash2Emitter.Trigger(Weapon, Instigator);
}

simulated function bool AllowFire()
{
	return (BoomStick(Weapon).SingleShotCount >= 1 && Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
    	// Overridden to support special anim functionality of the double barreled shotgun
        if( Weapon.GetFireMode(1).bIsFiring )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.75, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( Rand( 2 ) == 1 )
             	NewRecoilRotation.Yaw *= -1;

    	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation *= Rec;

 		    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
    	}
 	}
}

defaultproperties
{
     MuzzleBoneLeft="Tip_Left"
     MuzzleBoneRight="Tip_Right"
     KickMomentum=(X=-105.000000,Z=55.000000)
     RecoilRate=0.070000
     maxVerticalRecoilAngle=3200
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Both_Iron"
     FireSoundRef="KF_DoubleSGSnd.2Barrel_Fire_Dual"
     StereoFireSoundRef="KF_DoubleSGSnd.2Barrel_Fire_DualST"
     NoAmmoSoundRef="KF_DoubleSGSnd.2Barrel_DryFire"
     ProjPerFire=10
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.900000
     TransientSoundRadius=500.000000
     FireAnim="Fire_Both"
     FireRate=2.750000
     AmmoClass=Class'KFMod.DBShotgunAmmo'
     AmmoPerFire=2
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=600.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.500000
     ProjectileClass=Class'KFMod.BoomStickBullet'
     BotRefireRate=2.500000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=2.000000
     Spread=3000.000000
}
