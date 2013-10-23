//=============================================================================
// BlowerThrowerAltFire
//=============================================================================
// Secondary fire mode class for the bloat bile thrower
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BlowerThrowerAltFire extends KFShotgunFire;

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

	return super(WeaponFire).AllowFire();
}

// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
    	if( Weapon.GetFireMode(1).bIsFiring )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( Rand( 2 ) == 1 )
             	NewRecoilRotation.Yaw *= -1;

            if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
            {
                AdjustedVelocity = Weapon.Owner.Velocity;
                // Ignore Z velocity in low grav so we don't get massive recoil
                AdjustedVelocity.Z = 0;
                AdjustedSpeed = VSize(AdjustedVelocity);
                //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

                // Reduce the falling recoil in low grav
                NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
        	    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
    	    }
    	    else
    	    {
                //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
        	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
        	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
    	    }

    	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation *= Rec;

 		    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
    	}
 	}
}

defaultproperties
{
     KickMomentum=(X=-85.000000,Z=15.000000)
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="FireALL_Iron"
     bRandomPitchFireSound=False
     FireSoundRef="KF_FY_BlowerThrowerSND.WEP_Blower_Secondary_Fire_M"
     StereoFireSoundRef="KF_FY_BlowerThrowerSND.WEP_Blower_Secondary_Fire_S"
     ProjPerFire=1
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnim="FireALL"
     FireAnimRate=0.950000
     NoAmmoSound=Sound'KF_PumpSGSnd.SG_DryFire'
     FireRate=0.965000
     AmmoClass=Class'KFMod.BlowerThrowerAmmo'
     AmmoPerFire=7
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFMod.BlowerBileAltProjectile'
     BotRefireRate=1.500000
     FlashEmitterClass=Class'KFMod.BlowerThroweraAltMuzzleFlash1P'
     aimerror=1.000000
     Spread=2000.000000
     SpreadStyle=SS_Line
}
