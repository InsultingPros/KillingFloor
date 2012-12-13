//=============================================================================
// ChainsawFire
//=============================================================================
// Looping chainsaw fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ChainsawFire extends KFMeleeFire;

// sound
var 	sound   				FireStartSound;				// The sound to play at the beginning of the ambient fire sound
var 	sound   				FireEndSound;				// The sound to play at the end of the ambient fire sound
var 	float   				AmbientFireSoundRadius;		// The sound radius for the ambient fire sound
var		sound					AmbientFireSound;           // The ambient fire sound
var		sound					AmbientIdleSound;           // The ambient idle sound
var		byte					AmbientFireVolume;          // How loud to play the looping ambient fire sound

var		string			FireStartSoundRef;
var		string			FireEndSoundRef;
var		string			AmbientFireSoundRef;
var		string			AmbientIdleSoundRef;

var int maxAdditionalDamage;

static function PreloadAssets(optional KFMeleeFire Spawned)
{
	super.PreloadAssets(Spawned);

	default.FireStartSound = sound(DynamicLoadObject(default.FireStartSoundRef, class'sound', true));
	default.FireEndSound = sound(DynamicLoadObject(default.FireEndSoundRef, class'sound', true));
	default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
	default.AmbientIdleSound = sound(DynamicLoadObject(default.AmbientIdleSoundRef, class'sound', true));

	if ( ChainsawFire(Spawned) != none )
	{
		ChainsawFire(Spawned).FireStartSound = default.FireStartSound;
		ChainsawFire(Spawned).FireEndSound = default.FireEndSound;
		ChainsawFire(Spawned).AmbientFireSound = default.AmbientFireSound;
		ChainsawFire(Spawned).AmbientIdleSound = default.AmbientIdleSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.FireStartSound = none;
	default.FireEndSound = none;
	default.AmbientFireSound = none;
	default.AmbientIdleSound = none;

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

function PlayDefaultAmbientSound()
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

    if ( Weapon == none || (WA == none))
        return;

	WA.SoundVolume = WA.default.SoundVolume;
	WA.SoundRadius = WA.default.SoundRadius;
	WA.AmbientSound=WA.default.AmbientSound;
}

// Make sure we are in the fire looping state when we fire
event ModeDoFire()
{
	local float Rec;

	if( AllowFire() && IsInState('FireLoop'))
	{
    	Rec = GetFireSpeed();

    	FireRate = default.FireRate/Rec;
    	FireAnimRate = default.FireAnimRate*Rec;
    	ReloadAnimRate = default.ReloadAnimRate*Rec;

    	if (MaxHoldTime > 0.0)
    		HoldTime = FMin(HoldTime, MaxHoldTime);

    	// server
    	if (Weapon.Role == ROLE_Authority)
    	{
    		Weapon.ConsumeAmmo(ThisModeNum, Load);
    		DoFireEffect();

    		HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
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
    		ClientPlayForceFeedback(FireForce);
    	}
    	else // server
    		ServerPlayFiring();

    	Weapon.IncrementFlashCount(ThisModeNum);

    	// set the next firing time. must be careful here so client and server do not get out of sync
    	if (bFireOnRelease)
    	{
    		if (bIsFiring)
    			NextFireTime += MaxHoldTime + FireRate;
    		else
    			NextFireTime = Level.TimeSeconds + FireRate;
    	}
    	else
    	{
    		NextFireTime += FireRate;
    		NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    	}

    	Load = AmmoPerFire;
    	HoldTime = 0;

    	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    	{
    		bIsFiring = false;
    		Weapon.PutDown();
    	}


    	if( Weapon.Owner != none && Weapon.Owner.Physics != PHYS_Falling )
    	{
            Weapon.Owner.Velocity.x *= KFMeleeGun(Weapon).ChopSlowRate;
        	Weapon.Owner.Velocity.y *= KFMeleeGun(Weapon).ChopSlowRate;
    	}
	}
}

function DoFireEffect()
{
	local KFMeleeGun kf;
	local int damage ;
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local bool bBackStabbed;

	if(KFMeleeGun(Weapon) == none)
		return;

	kf = KFMeleeGun(Weapon);
	damage = MeleeDamage + Rand(MaxAdditionalDamage) ;

	MyDamage = MeleeDamage + Rand(MaxAdditionalDamage);

	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamage + Rand(MaxAdditionalDamage);
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( Instigator.Controller!=None && PlayerController(Instigator.Controller)==None && Instigator.Controller.Enemy!=None )
		{
        	PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
        }
		else
        {
            PointRot = Instigator.GetViewRotation();
        }

		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (HitActor!=None)
		{
			//ImpactShakeView();

			if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
                HitActor.Base.IsA('KFMonster') )
            {
                HitActor = HitActor.Base;
            }

			if ( (HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && KFMeleeGun(Weapon).BloodyMaterial!=none )
			{
				Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] = KFMeleeGun(Weapon).BloodyMaterial;
				Weapon.texture = Weapon.default.Texture;
			}
			if( Level.NetMode==NM_Client )
            {
                Return;
            }

			if( HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle')
			 && (Normal(HitActor.Location-Instigator.Location) Dot vector(HitActor.Rotation))>0 )
			{
				bBackStabbed = true;
				MyDamage*=2; // Backstab >:P
			}

			if( (KFMonster(HitActor)!=none) )
			{
			//	log(VSize(Instigator.Velocity));

				KFMonster(HitActor).bBackstabbed = bBackStabbed;

                HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;

            	if(MeleeHitSounds.Length > 0)
            	{
            		Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
            	}

				if(VSize(Instigator.Velocity) > 300 && KFMonster(HitActor).Mass <= Instigator.Mass)
				{
				    KFMonster(HitActor).FlipOver();
				}

			}
			else
			{
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				if( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
                    KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitActor,HitLocation,HitNormal);
			}
		}
	}

}

function Timer()
{
    PlayDefaultAmbientSound();
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
        Weapon.PlayOwnedSound(FireStartSound,SLOT_Interact,AmbientFireVolume/127,,AmbientFireSoundRadius,,false);

        SetTimer(Weapon.GetSoundDuration(FireStartSound) / (1.1/Weapon.Level.TimeDilation), False);
    }

    function Timer()
    {
        PlayAmbientSound(AmbientFireSound);
    }

	// Overriden because we play an anbient fire sound
    function PlayFiring() {}
	function ServerPlayFiring() {}

    function EndState()
    {
        Weapon.AnimStopLooping();
        PlayAmbientSound(none);
        Weapon.PlayOwnedSound(FireEndSound,SLOT_Interact,AmbientFireVolume/127,,AmbientFireSoundRadius,,false);
        SetTimer(Weapon.GetSoundDuration(FireEndSound) / (1.1/Weapon.Level.TimeDilation), False);
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
    return weaponRange;
}

defaultproperties
{
     AmbientFireSoundRadius=500.000000
     AmbientFireVolume=255
     FireStartSoundRef="KF_ChainsawSnd.Chainsaw_RevLong_Start"
     FireEndSoundRef="KF_ChainsawSnd.Chainsaw_RevLong_End"
     AmbientFireSoundRef="KF_ChainsawSnd.Chainsaw_RevLong_Loop"
     maxAdditionalDamage=5
     MeleeDamage=14
     hitDamageClass=Class'KFMod.DamTypeChainsaw'
     HitEffectClass=Class'KFMod.ChainsawHitEffect'
     NoAmmoSoundRef="KF_FlamethrowerSnd.FT_DryFire"
     MeleeHitSoundRefs(0)="KF_AxeSnd.Axe_HitFlesh"
     TransientSoundVolume=2.000000
     FireAnim="'"
     FireLoopAnim="Fire"
     FireEndAnim="Idle"
     FireRate=0.100000
}
