//=============================================================================
// BlowerThrowerFire
//=============================================================================
// Primary fire mode class for the bloat bile thrower
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BlowerThrowerFire extends CrossbowFire ;

// sound
var 	sound   				FireEndSound;				// The sound to play at the end of the ambient fire sound
var 	sound   				FireEndStereoSound;    		// The sound to play at the end of the ambient fire sound in first person stereo
var 	float   				AmbientFireSoundRadius;		// The sound radius for the ambient fire sound
var		sound					AmbientFireSound;           // How loud to play the looping ambient fire sound
var		byte					AmbientFireVolume;          // The ambient fire sound

var		string			FireEndSoundRef;
var		string			FireEndStereoSoundRef;
var		string			AmbientFireSoundRef;

static function PreloadAssets(LevelInfo LevelInfo, optional KFShotgunFire Spawned)
{
	super.PreloadAssets(LevelInfo, Spawned);

	if ( default.FireEndSoundRef != "" )
	{
		default.FireEndSound = sound(DynamicLoadObject(default.FireEndSoundRef, class'sound', true));
	}

	if ( LevelInfo.bLowSoundDetail || (default.FireEndStereoSoundRef == "" && default.FireEndStereoSound == none) )
	{
		default.FireEndStereoSound = default.FireEndSound;
	}
	else
	{
		default.FireEndStereoSound = sound(DynamicLoadObject(default.FireEndStereoSoundRef, class'Sound', true));
	}

	if ( default.AmbientFireSoundRef != "" )
	{
		default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
	}

	if ( BlowerThrowerFire(Spawned) != none )
	{
		BlowerThrowerFire(Spawned).FireEndSound = default.FireEndSound;
		BlowerThrowerFire(Spawned).FireEndStereoSound = default.FireEndStereoSound;
		BlowerThrowerFire(Spawned).AmbientFireSound = default.AmbientFireSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.FireEndSound = none;
	default.FireEndStereoSound = none;
	default.AmbientFireSound = none;

	return true;
}

// Sends the fire class to the looping state
function StartFiring()
{
   GotoState('FireLoop');
}

// Handles toggling the weapon attachment's ambient sound on and off
function PlayAmbientSound(Sound aSound)
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

    if ( Weapon == none || (WA == none))
        return;

	if(aSound == None)
	{
		WA.SoundVolume = WA.default.SoundVolume;
		WA.SoundRadius = WA.default.SoundRadius;
	}
	else
	{
		WA.SoundVolume = AmbientFireVolume;
		WA.SoundRadius = AmbientFireSoundRadius;
	}

    WA.AmbientSound = aSound;
}

// Make sure we are in the fire looping state when we fire
event ModeDoFire()
{
	if( AllowFire() && IsInState('FireLoop'))
	{
	    Super.ModeDoFire();
	}
}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
		if(Level.TimeSeconds - LastClickTime > FireRate)
		{
			Weapon.PlayOwnedSound(NoAmmoSound, SLOT_Interact, TransientSoundVolume,,,, false);
			LastClickTime = Level.TimeSeconds;
			if(Weapon.HasAnim(EmptyAnim))
				weapon.PlayAnim(EmptyAnim, EmptyAnimRate, 0.0);
		}
		return false;
	}
	LastClickTime = Level.TimeSeconds;
	return Super.AllowFire();
}

/* =================================================================================== *
* FireLoop
* 	This state handles looping the firing animations and ambient fire sounds as well
*	as firing rounds.
*
* modified by: Ramm 1/17/05
* =================================================================================== */
state FireLoop
{
    function BeginState()
    {
		NextFireTime = Level.TimeSeconds - 0.1; //fire now!

        Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);

		PlayAmbientSound(AmbientFireSound);
    }

	// Overriden because we play an anbient fire sound
    function PlayFiring() {}
	function ServerPlayFiring() {}

    function EndState()
    {
        Weapon.AnimStopLooping();
        PlayAmbientSound(none);
    	if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
    	   Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
    	{
            Weapon.PlayOwnedSound(FireEndStereoSound,SLOT_None,AmbientFireVolume/127,,AmbientFireSoundRadius,,false);
        }
        else
        {
            Weapon.PlayOwnedSound(FireEndSound,SLOT_None,AmbientFireVolume/127,,AmbientFireSoundRadius);
        }
        Weapon.StopFire(ThisModeNum);
    }

    function StopFiring()
    {
        GotoState('');
    }

    function ModeTick(float dt)
    {
	    Super.ModeTick(dt);

		if ( !bIsFiring ||  !AllowFire()  )  // stopped firing, magazine empty
        {
			GotoState('');
			return;
		}
    }
}

function float MaxRange()
{
    return 1500;
}

defaultproperties
{
     AmbientFireSoundRadius=500.000000
     AmbientFireVolume=255
     FireEndSoundRef="KF_FY_BlowerThrowerSND.WEP_Bile_Fire_End_M"
     FireEndStereoSoundRef="KF_FY_BlowerThrowerSND.WEP_Bile_Fire_End_S"
     AmbientFireSoundRef="KF_FY_BlowerThrowerSND.BlowerThrower_Fire_LP"
     EffectiveRange=1500.000000
     maxVerticalRecoilAngle=300
     maxHorizontalRecoilAngle=150
     NoAmmoSoundRef="KF_FlamethrowerSnd.FT_DryFire"
     ProjSpawnOffset=(Y=5.000000,Z=-6.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bWaitForRelease=False
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.000000
     TransientSoundRadius=500.000000
     FireAnim="'"
     FireLoopAnim="Fire"
     FireEndAnim="Fire_End"
     FireRate=0.070000
     AmmoClass=Class'KFMod.BlowerThrowerAmmo'
     ShakeRotMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotRate=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeOffsetMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ProjectileClass=Class'KFMod.BlowerBileProjectile'
     BotRefireRate=0.070000
     FlashEmitterClass=Class'KFMod.BlowerThrowerMuzzleFlash1P'
     Spread=1500.000000
     SpreadStyle=SS_Random
}
