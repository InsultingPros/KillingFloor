//=============================================================================
// ROWeaponfire
//=============================================================================
// Base class for all Red Orchestra weapon firing
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROWeaponFire extends WeaponFire;

/*#exec OBJ LOAD File="Inf_Weapons.uax"

//=============================================================================
// Variables
//=============================================================================

// Firing effects
var()		name			MuzzleBone; 				// The bone to attache the muzzle flash to

// Sounds
var() 		array<sound>	FireSounds; 				// An array of the weapon firing sounds
var()		float			FireVolume;

// Animation
var()		float			FireTweenTime;


// Recoil
var() 		int 			maxVerticalRecoilAngle;    	// max vertical angle a weapon muzzle can climb from recoil
var() 		int 			maxHorizontalRecoilAngle;  	// max horizontal angle a weapon muzzle can move from recoil
var() 		float 			PctStandIronRecoil;      	// the percentage of recoil felt standing while in iron sights compared to hip shots standing
var() 		float 			PctCrouchRecoil;         	// the percentage of recoil felt in crouch compared to standing
var() 		float 			PctCrouchIronRecoil;     	// the percentage of recoil felt crouching while in iron sights compared to hip shots crouching
var() 		float 			PctProneRecoil;          	// the percentage of recoil felt in prone compared to standing
var() 		float 			PctProneIronRecoil;      	// the percentage of recoil felt in prone while in iron sights compared to unaimed shots in prone
var()		float			PctBipodDeployRecoil;		// the percentage of recoil felt when a player's weapon is bipod deployed
var()		float			PctRestDeployRecoil;		// the percentage to reduce recoil when the player is rest deployed
var()		float			PctLeanPenalty;				// The amount of recoil to add when the player is leaning
var()		float			RecoilRate;					// Time in seconds each recoil should take to be applied. Must be less than the fire rate or the full recoil wont be applied

// Delayed Recoil for bolt actions and semis
var		bool				bDelayedRecoil;		// Delay the recoil so that accurate weapons have a chance for the bullet to fire before the recoil is carried over
var()	float				DelayedRecoilTime;  // Amount of time to wait before applying recoil

var() class<ROShellEject>   ShellEjectClass;			// class of our first person shell ejection emitter
//var() RO1stShellEject 		ShellEmitter;       	// First person shell ejection emitter instance
var() 	name	 			ShellEmitBone;      		// First person shell ejection bone
var()	vector				ShellIronSightOffset;		// Distance to offset the ShellEject in first person
var()	vector				ShellHipOffset;				// Distance to offset the ShellEject in first person
var()	rotator				ShellRotOffsetIron;			// The rotational shell spawning offset for this weapon in ironsights
var()	rotator				ShellRotOffsetHip;			// The rotational shell spawning offset for this weapon in ironsights
var()	bool				bAnimNotifiedShellEjects;	// This firing class only ejects shells with anim notifies
var()	bool				bReverseShellSpawnDirection;// Hack for some weapons having backward shell ejection bones

// Melee Animations
var			name			BashBackAnim;				// Animation for pulling the weapon back before the butt smack
var			name			BashHoldAnim;				// Animation for the idle before the butt smack
var			name			BashAnim;					// Animation for the butt smack
var			name			BashFinishAnim;				// Animation for the end of the butt smack
var			name			BayoBackAnim;				// Animation for pulling the weapon back before the bayonet stab
var			name			BayoHoldAnim;				// Animation for the idle before the v
var			name			BayoStabAnim;				// Animation for the bayonet stab
var			name			BayoFinishAnim;				// Animation for the end of the bayonet stab
var			name			BashBackEmptyAnim;			// Animation for pulling the weapon back before the butt smack Empty
var			name			BashHoldEmptyAnim;			// Animation for the idle before the butt smack Empty
var			name			BashEmptyAnim;				// Animation for the butt smack Empty
var			name			BashFinishEmptyAnim;		// Animation for the end of the butt smack Empty

//=============================================================================
// Functions
//=============================================================================

// Overriden to support our recoil system
event ModeDoFire()
{
    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        Weapon.ConsumeAmmo(ThisModeNum, Load);
        DoFireEffect();
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
		if( !bDelayedRecoil )
      		HandleRecoil();
		else
			SetTimer(DelayedRecoilTime, False);

        ShakeView();
        PlayFiring();

        if( !bMeleeMode )
        {
	        if(Instigator.IsFirstPerson() && !bAnimNotifiedShellEjects )
				EjectShell();
			FlashMuzzleFlash();
	        StartMuzzleSmoke();
        }
    }
    else // server
    {
        ServerPlayFiring();
    }

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
}

function Timer()
{
	if( bDelayedRecoil )
		HandleRecoil();
}

simulated function HandleRecoil()
{
	local rotator NewRecoilRotation;
	local ROPlayer ROP;
	local ROPawn ROPwn;

    if( Instigator != none )
    {
		ROP = ROPlayer(Instigator.Controller);
		ROPwn = ROPawn(Instigator);
	}

    if( ROP == none || ROPwn == none )
    	return;

	if( !ROP.bFreeCamera )
	{
      	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.75, maxVerticalRecoilAngle );
     	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.75, maxHorizontalRecoilAngle );

      	if( Rand( 2 ) == 1 )
         	NewRecoilRotation.Yaw *= -1;

        if( Instigator.Physics == PHYS_Falling )
        {
      		NewRecoilRotation *= 3;
        }

		// WeaponTODO: Put bipod and resting modifiers in here
	    if( Instigator.bIsCrouched )
	    {
	        NewRecoilRotation *= PctCrouchRecoil;

			// player is crouched and in iron sights
	        if( Weapon.bUsingSights )
	        {
	            NewRecoilRotation *= PctCrouchIronRecoil;
	        }
	    }
	    else if( Instigator.bIsCrawling )
	    {
	        NewRecoilRotation *= PctProneRecoil;

	        // player is prone and in iron sights
	        if( Weapon.bUsingSights )
	        {
	            NewRecoilRotation *= PctProneIronRecoil;
	        }
	    }
	    else if( Weapon.bUsingSights )
	    {
	        NewRecoilRotation *= PctStandIronRecoil;
	    }

        if( ROPwn.bRestingWeapon )
        	NewRecoilRotation *= PctRestDeployRecoil;

        if( Instigator.bBipodDeployed )
		{
			NewRecoilRotation *= PctBipodDeployRecoil;
		}

		if( ROPwn.LeanAmount != 0 )
		{
			NewRecoilRotation *= PctLeanPenalty;
		}

		// Need to set this value per weapon
 		ROP.SetRecoil(NewRecoilRotation,RecoilRate);
 	}
}

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
        if ( FlashEmitter != None && MuzzleBone != '')
        	Weapon.AttachToBone(FlashEmitter, MuzzleBone);
    }
    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass, Instigator);
        if ( SmokeEmitter != None && MuzzleBone != '')
        	Weapon.AttachToBone(SmokeEmitter, MuzzleBone);
    }
}

simulated function EjectShell()
{
	local coords EjectCoords;
	local vector EjectOffset;
	local vector X,Y,Z;
	local rotator EjectRot;
	local ROShellEject Shell;

	if( Weapon.bUsingSights )
	{
    	if ( ShellEjectClass != None )
    	{
			Weapon.GetViewAxes(X,Y,Z);

			EjectOffset = Instigator.Location + Instigator.EyePosition();
			EjectOffset = EjectOffset + X * ShellIronSightOffset.X + Y * ShellIronSightOffset.Y +  Z * ShellIronSightOffset.Z;

    		EjectRot = Rotator(Y);
			EjectRot.Yaw += 16384;
			Shell=Weapon.Spawn(ShellEjectClass,none,,EjectOffset,EjectRot);
			EjectRot = Rotator(Y);
			EjectRot += ShellRotOffsetIron;

			EjectRot.Yaw = EjectRot.Yaw + Shell.RandomYawRange - Rand(Shell.RandomYawRange * 2);
			EjectRot.Pitch = EjectRot.Pitch + Shell.RandomPitchRange - Rand(Shell.RandomPitchRange * 2);
			EjectRot.Roll = EjectRot.Roll + Shell.RandomRollRange - Rand(Shell.RandomRollRange * 2);

    		Shell.Velocity = (Shell.MinStartSpeed + FRand() * (Shell.MaxStartSpeed-Shell.MinStartSpeed)) * vector(EjectRot);
    	}
	}
	else
	{
	    if ( ShellEjectClass != None )
	    {
        	EjectCoords = Weapon.GetBoneCoords(ShellEmitBone);

			// Find the shell eject location then scale it down 5x (since the weapons are scaled up 5x)
			EjectOffset = EjectCoords.Origin - Weapon.Location;
        	EjectOffset = EjectOffset * 0.2;
        	EjectOffset = Weapon.Location + EjectOffset;

        	EjectOffset = EjectOffset + EjectCoords.XAxis * ShellHipOffset.X + EjectCoords.YAxis * ShellHipOffset.Y +  EjectCoords.ZAxis * ShellHipOffset.Z;

			if( bReverseShellSpawnDirection )
			{
            	EjectRot = Rotator(EjectCoords.YAxis);
            }
            else
            {
            	EjectRot = Rotator(-EjectCoords.YAxis);
            }
	    	Shell=Weapon.Spawn(ShellEjectClass,none,,EjectOffset,EjectRot);
	    	EjectRot = Rotator(EjectCoords.XAxis);
	    	EjectRot += ShellRotOffsetHip;

			EjectRot.Yaw = EjectRot.Yaw + Shell.RandomYawRange - Rand(Shell.RandomYawRange * 2);
			EjectRot.Pitch = EjectRot.Pitch + Shell.RandomPitchRange - Rand(Shell.RandomPitchRange * 2);
			EjectRot.Roll = EjectRot.Roll + Shell.RandomRollRange - Rand(Shell.RandomRollRange * 2);

			Shell.Velocity = (Shell.MinStartSpeed + FRand() * (Shell.MaxStartSpeed-Shell.MinStartSpeed)) * vector(EjectRot);
	    }
	}
}

//// server propagation of firing ////
function ServerPlayFiring()
{
	if( FireSounds.Length > 0 )
    	Weapon.PlayOwnedSound(FireSounds[Rand(FireSounds.Length)],SLOT_None,FireVolume,,,,false);
}


function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
			{
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else
			{
				Weapon.PlayAnim(FireAnim, FireAnimRate, FireTweenTime);
			}
		}
		else
		{
			Weapon.PlayAnim(FireAnim, FireAnimRate, FireTweenTime);
		}
	}

    if( FireSounds.Length > 0 )
		Weapon.PlayOwnedSound(FireSounds[Rand(FireSounds.Length)],SLOT_None,FireVolume,,,,false);

    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

function PlayFireEnd()
{
    if ( Weapon.Mesh != None && Weapon.HasAnim(FireEndAnim) )
    {
        Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, FireTweenTime);
    }
}
*/

defaultproperties
{
}
