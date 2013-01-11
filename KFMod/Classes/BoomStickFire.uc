//=============================================================================
// BoomStick Dual Fire
//=============================================================================
class BoomStickFire extends KFShotgunFire;

var()   Emitter     Flash2Emitter;
var()   name        MuzzleBoneLeft;
var()   name        MuzzleBoneRight;

var()   name    FireLastAnim;
var()   name    FireLastAimedAnim;

var     bool        bVeryLastShotAnim;

event ModeDoFire()
{
	if (!AllowFire())
		return;

    bVeryLastShotAnim = Weapon.AmmoAmount(0) <= AmmoPerFire;

    super.ModeDoFire();

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        BoomStick(Weapon).SingleShotCount = 0;
        BoomStick(Weapon).SetSingleShotReplication();
        BoomStick(Weapon).SetPendingReload();
    }
}

// Overridden to support special anim functionality of the double barreled shotgun
function PlayFiring()
{
    local float RandPitch;

	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if( KFWeap.bAimingRifle )
			{
                if ( Weapon.HasAnim(FireLoopAimedAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAimedAnim, FireLoopAnimRate, 0.0);
    			}
    			else if( Weapon.HasAnim(FireAimedAnim) )
    			{
    				Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
    			}
    			else
    			{
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
			else
			{
                if ( Weapon.HasAnim(FireLoopAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
    			}
    			else
    			{
    				Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
		}
		else
		{
            if( KFWeap.bAimingRifle )
			{
                if( bVeryLastShotAnim && Weapon.HasAnim(FireLastAimedAnim))
                {
                    Weapon.PlayAnim(FireLastAimedAnim, FireAnimRate, TweenTime);
                }
                else if( Weapon.HasAnim(FireAimedAnim) )
    			{
                    Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
    			}
    			else
    			{
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
			else
			{
                if( bVeryLastShotAnim && Weapon.HasAnim(FireLastAnim))
                {
                    Weapon.PlayAnim(FireLastAnim, FireAnimRate, TweenTime);
                }
                else
                {
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
                }
			}
		}
	}
	if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
	   Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
	{
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    else
    {
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
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
	return (BoomStick(Weapon).SingleShotCount >= 2);
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
    	// Overridden to support special anim functionality of the double barreled shotgun
        if( Weapon.GetFireMode(1).bIsFiring )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.75, maxVerticalRecoilAngle );
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
     MuzzleBoneLeft="Tip_Left"
     MuzzleBoneRight="Tip_Right"
     FireLastAnim="Fire"
     FireLastAimedAnim="Fire_Iron"
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
