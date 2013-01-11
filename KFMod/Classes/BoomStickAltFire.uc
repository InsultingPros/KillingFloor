//=============================================================================
// BoomStick Single Fire
//=============================================================================
class BoomStickAltFire extends KFShotgunFire;

var()   name    FireLastAnim;
var()   name    FireLastAimedAnim;
var()   float   FireLastRate;

var()   Emitter     Flash2Emitter;
var()   name        MuzzleBoneLeft;
var()   name        MuzzleBoneRight;

var     bool        bVeryLastShotAnim;

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
    if( KFWeap.MagAmmoRemaining == 2)
    {
        if (Flash2Emitter != None)
            Flash2Emitter.Trigger(Weapon, Instigator);
    }
    else
    {
        if (FlashEmitter != None)
            FlashEmitter.Trigger(Weapon, Instigator);
    }
}

simulated function bool AllowFire()
{
	return (BoomStick(Weapon).SingleShotCount >= 1);
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
                if( !bVeryLastShotAnim && BoomStick(Weapon).SingleShotCount == 0 && Weapon.HasAnim(FireLastAimedAnim))
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
                if( !bVeryLastShotAnim && BoomStick(Weapon).SingleShotCount == 0 && Weapon.HasAnim(FireLastAnim))
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

// Overridden to support special anim functionality of the double barreled shotgun
event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Spread = Default.Spread;
	Rec = 1;
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

    // Code from WeaponFire	we have to override

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    BoomStick(Weapon).SingleShotCount--;

    bVeryLastShotAnim = Weapon.AmmoAmount(0) <= AmmoPerFire;

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        if( BoomStick(Weapon).SingleShotCount < 1 )
        {
            BoomStick(Weapon).SetPendingReload();
        }

        Weapon.ConsumeAmmo(ThisModeNum, Load);
        DoFireEffect();
        BoomStick(Weapon).SetSingleShotReplication();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if( BoomStick(Weapon).SingleShotCount == 0 )
        {
            if (bIsFiring)
                NextFireTime += MaxHoldTime + FireLastRate;
            else
                NextFireTime = Level.TimeSeconds + FireLastRate;
        }
        else
        {
            if (bIsFiring)
                NextFireTime += MaxHoldTime + FireRate;
            else
                NextFireTime = Level.TimeSeconds + FireRate;
        }
    }
    else
    {
        if( BoomStick(Weapon).SingleShotCount == 0 )
        {
            NextFireTime += FireLastRate;
            NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
        }
        else
        {
            NextFireTime += FireRate;
            NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
        }
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }
    // end code from WeaponFire

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
    }
}

defaultproperties
{
     FireLastAnim="Fire_Last"
     FireLastAimedAnim="Fire_Last_Iron"
     FireLastRate=2.750000
     MuzzleBoneLeft="Tip_Left"
     MuzzleBoneRight="Tip_Right"
     KickMomentum=(X=-50.000000,Z=22.000000)
     RecoilRate=0.070000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_DoubleSGSnd.2Barrel_Fire"
     StereoFireSoundRef="KF_DoubleSGSnd.2Barrel_FireST"
     NoAmmoSoundRef="KF_DoubleSGSnd.2Barrel_DryFire"
     ProjPerFire=10
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     TransientSoundRadius=500.000000
     FireRate=0.250000
     AmmoClass=Class'KFMod.DBShotgunAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFMod.BoomStickBullet'
     BotRefireRate=2.500000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=2.000000
     Spread=3000.000000
}
