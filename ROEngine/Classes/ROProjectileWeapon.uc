//=============================================================================
// ROProjectileWeapon
//=============================================================================
// Base class for all projectile (bullets, rockets, etc) firing weapons
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROProjectileWeapon extends ROWeapon
	abstract;

//=============================================================================
// Variables
//=============================================================================

// Animations
var 		name 		MagEmptyReloadAnim;       	// anim for reloads when a weapon has an empty magazine/box, this anim will be used by bolt actions when inserting a full stripper clip
var 		name 		MagPartialReloadAnim;     	// anim for reloads when a weapon still has ammo in magazine/box

var 		name 		IronIdleAnim;        		// anim for weapon idling while in iron sight view
var 		name 		IronBringUp;         		// anim for weapon being brought up to iron sight view
var 		name 		IronBringUpRest;         	// anim for weapon being brought up to iron sight view when needing to bolt
var 		name 		IronPutDown;         		// anim for weapon being lowered out of iron sight view

var 		name 		BayoAttachAnim;         	// anim for attaching the bayonet
var 		name 		BayoDetachAnim;         	// anim for detaching the bayonet
var			name		BayonetBoneName;			// name for the bayonet bone, used in scaling the bayonet bone based on its attachment status
var			bool		bHasBayonet;				// Whether or not this weapon has a bayonet

var			float		IronSwitchAnimRate;			// the rate to play the ironsight animation at

// Empty animations used for weapons that have visible empty states (pistols, PTRD, etc)
var 		name 		IdleEmptyAnim;        		// anim for weapon idling empty
var 		name 		IronIdleEmptyAnim;        	// anim for weapon idling while in iron sight view empty

var 		name 		IronBringUpEmpty;         	// anim for weapon being brought up to iron sight view
var 		name 		IronPutDownEmpty;         	// anim for weapon being lowered out of iron sight view

var			name		SprintStartEmptyAnim;		// anim that shows the beginning of the sprint with empty weapon
var			name		SprintLoopEmptyAnim;      	// anim that is looped for when player is sprinting with empty weapon
var			name		SprintEndEmptyAnim;			// anim that shows the weapon returning to normal after sprinting with empty weapon

var()		name		CrawlForwardEmptyAnim; 		// Animation for crawling forward empty
var()		name		CrawlBackwardEmptyAnim;     // Animation for crawling backward empty
var()		name		CrawlStartEmptyAnim;        // Animation for starting to crawl empty
var()		name		CrawlEndEmptyAnim;          // Animation for ending crawling empty

var()		name		SelectEmptyAnim; 			// Animation for drawing an empty weapon
var()		name		PutDownEmptyAnim;     		// Animation for putting away an empty weapon

// Manual bolting anims
var()		name		BoltHipAnim; 				// Animation for crawling forward
var()		name		BoltIronAnim;          		// Animation for crawling backward
var()		name		PostFireIronIdleAnim; 		// Animation for crawling forward
var()		name		PostFireIdleAnim;          // Animation for crawling backward

// Ammo/Magazines
var 		array<int>	PrimaryAmmoArray;   		// The array of magazines and thier ammo amounts this weapon has
var 		int			CurrentMagCount;    		// Current number of magazines, this should be replicated to the client
var 		int			MaxNumPrimaryMags;  		// The maximum number of mags a solder can carry for this weapon, should move to the role info
var 		int			InitialNumPrimaryMags; 		// The number of mags the soldier starts with, should move to the role info
var			int			CurrentMagIndex;    		// The index of the magazine currently in use
var 		bool		bUsesMagazines;				// This weapon uses magazines, not single bullets, etc
var 		bool		bPlusOneLoading; 			// Can have an extra round in the chamber when you reload before empty

//=============================================================================
// replication
//=============================================================================
replication
{
    reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		CurrentMagCount;

    reliable if( Role==ROLE_Authority )
        ClientDoReload, ClientCancelReload;

    reliable if( Role<ROLE_Authority )
    	ServerRequestReload, ServerZoomIn, ServerZoomOut, ServerChangeBayoStatus,
		ServerWorkBolt;

}

// Implemented in subclasses
function ServerWorkBolt(){}

// Play an idle animation on the server so that the weapon will be
// in the right position for free-aim calculations (not the ref pose)
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
    {
		PlayAnim(IdleAnim, IdleAnimRate, 0.0);
    }
}

// Debug logging to show how much ammo we have in our mags
exec function LogAmmo()
{
	local int i;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	for( i=0; i<PrimaryAmmoArray.Length; i++ )
	{
		if (i == CurrentMagIndex)
        {
			log("Current mag has "$PrimaryAmmoArray[i]$" ammo");
        }
        else
        {
        	log("Stowed mag has "$PrimaryAmmoArray[i]$" ammo");
        }
	}

    log("Primary Ammo Count is "$AmmoAmount(0));
	log("There are "$PrimaryAmmoArray.Length$" mags");
}

//=============================================================================
// Rendering
//=============================================================================
simulated event RenderOverlays( Canvas Canvas )
{
	local int m;
    local rotator RollMod;
    local ROPlayer Playa;
	//For lean - Justin
	local ROPawn rpawn;
	local int leanangle;
	// Drawpos actor
	local rotator RotOffset;

    if (Instigator == none)
    	return;

    // Lets avoid having to do multiple casts every tick - Ramm
    Playa = ROPlayer(Instigator.Controller);

    // Don't draw the weapon if we're not viewing our own pawn
    if (Playa != none && Playa.ViewTarget != Instigator)
    	return;

    // draw muzzleflashes/smoke for all fire modes so idle state won't
    // cause emitters to just disappear
	Canvas.DrawActor(None, false, true); // amb: Clear the z-buffer here

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
    	if (FireMode[m] != None)
        {
        	FireMode[m].DrawMuzzleFlash(Canvas);
        }
    }

	// these seem to set the current position and rotation of the weapon
	// in relation to the player

	//Adjust weapon position for lean
	rpawn = ROPawn(Instigator);
	if (rpawn != none && rpawn.LeanAmount != 0)
	{
		leanangle += rpawn.LeanAmount;
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );

	if( bUsesFreeAim && !bUsingSights )
	{
    	// Remove the roll component so the weapon doesn't tilt with the terrain
    	RollMod = Instigator.GetViewRotation();

    	if( Playa != none )
		{
			RollMod.Pitch += Playa.WeaponBufferRotation.Pitch;
			RollMod.Yaw += Playa.WeaponBufferRotation.Yaw;

			RotOffset.Pitch -= Playa.WeaponBufferRotation.Pitch;
			RotOffset.Yaw -= Playa.WeaponBufferRotation.Yaw;
    	}

		RollMod.Roll += leanangle;

		if( IsCrawling() )
		{
			RollMod.Pitch = CrawlWeaponPitch;
			RotOffset.Pitch = CrawlWeaponPitch;
		}
    }
    else
    {
    	RollMod = Instigator.GetViewRotation();
		RollMod.Roll += leanangle;

		if( IsCrawling() )
		{
			RollMod.Pitch = CrawlWeaponPitch;
			RotOffset.Pitch = CrawlWeaponPitch;
		}
   	}

	// use the special actor drawing when in ironsights to avoid the ironsight "jitter"
	// TODO: This messes up the lighting, and texture environment map shader when using
	// ironsights. Maybe use a texrotator to simulate the texture environment map, or
	// just find a way to fix the problems.
	if( bUsingSights && Playa != none)
	{
		bDrawingFirstPerson = true;
      	Canvas.DrawBoundActor(self, false, false,DisplayFOV,Playa.Rotation,Playa.WeaponBufferRotation,Instigator.CalcZoomedDrawOffset(self));
      	bDrawingFirstPerson = false;
	}
	else
	{
	    SetRotation( RollMod );
		bDrawingFirstPerson = true;
	    Canvas.DrawActor(self, false, false, DisplayFOV);
	    bDrawingFirstPerson = false;
	}
}

function SetServerOrientation(rotator NewRotation)
{
	local rotator WeaponRotation;

	if( bUsesFreeAim && !bUsingSights )
	{
    	// Remove the roll component so the weapon doesn't tilt with the terrain
    	WeaponRotation = Instigator.GetViewRotation();// + FARotation;

		WeaponRotation.Pitch += NewRotation.Pitch;
		WeaponRotation.Yaw += NewRotation.Yaw;
        WeaponRotation.Roll += ROPawn(Instigator).LeanAmount;

    	SetRotation( WeaponRotation );
		SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    }
}

// Get the coords for the muzzle bone. Used for free-aim projectile spawning
function coords GetMuzzleCoords()
{
	// have to update the location of the weapon before getting the coords
	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	return GetBoneCoords('Muzzle');
}

// returns true if this weapon should use free-aim in this particular state
simulated function bool ShouldUseFreeAim()
{
	if( FireMode[1].bMeleeMode && FireMode[1].IsFiring())
	{
		return false;
	}

	if(bUsesFreeAim && !bUsingSights)
	{
		return true;
	}

	return false;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local AIController C;

	C = AIController(Instigator.Controller);
	if (C == None || C.Enemy == none)
		return 0;

	if( !FireMode[1].bMeleeMode )
	{
		return super.BestMode();
	}

	if ( VSize(C.Enemy.Location - Instigator.Location) < 125 && FRand() < 0.3)
		return 1;

	return 0;
}

state Hidden
{
	// Don't allow a reload if we're putting the weapon away
	simulated function bool AllowReload() {return false;}
}

// Overriden to support projectile weapon specific functionality
simulated state RaisingWeapon
{
    simulated function BeginState()
    {
	   	local int Mode;
		local name Anim;
		local ROPlayer player;

        // If we have quickly raised our sights right after putting the weapon away,
        // take us out of ironsight mode
        if( bUsingSights )
        	ZoomOut(false);

		// Reset any zoom values
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( DisplayFOV != default.DisplayFOV )
			{
				DisplayFOV = default.DisplayFOV;
			}

			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
		}

		if( AmmoAmount(0) < 1 && HasAnim(SelectEmptyAnim))
		{
			Anim = SelectEmptyAnim;
		}
		else
		{
			Anim = SelectAnim;
		}

		if ( ClientState == WS_Hidden )
		{
		    PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
			ClientPlayForceFeedback(SelectForce);  // jdf

		    if ( Instigator.IsLocallyControlled() )
		    {
		       	// determines if bayonet capable weapon should come up with bayonet on or off
		       	if( bHasBayonet )
		       	{
		           	if( bBayonetMounted )
		           	{
						ShowBayonet();
		           	}
		           	else
		            {
					    HideBayonet();
		            }
		        }

		        if ( (Mesh!=None) && HasAnim(Anim) )
		            PlayAnim(Anim, SelectAnimRate, 0.0);
		    }

		    ClientState = WS_BringUp;
		}

		SetTimer(GetAnimDuration(Anim, SelectAnimRate),false);

		for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
		{
			FireMode[Mode].bIsFiring = false;
			FireMode[Mode].HoldTime = 0.0;
			FireMode[Mode].bServerDelayStartFire = false;
			FireMode[Mode].bServerDelayStopFire = false;
			FireMode[Mode].bInstantStop = false;
		}

        // Hint check
        player = ROPlayer(Instigator.Controller);
        if (player != none)
            player.CheckForHint(11);
    }
}

// Overriden to support empty put away anims
simulated state LoweringWeapon
{
	// Don't zoom in when we're lowering the weapon
	simulated function PerformZoom(bool bZoomStatus){}
	// Don't allow a reload if we're putting the weapon away
	simulated function bool AllowReload() {return false;}
	// dont allow the bayo to be attached while lowering the weapon
	simulated exec function Deploy(){}

    simulated function BeginState()
    {
	    local int Mode;
		local name Anim;

		if( AmmoAmount(0) < 1 && HasAnim(PutDownEmptyAnim))
		{
			Anim = PutDownEmptyAnim;
		}
		else
		{
			Anim = PutDownAnim;
		}


	    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	    {
/*	        if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
	        {
	            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	            {
	                //if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
	                //    return false;
	                if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
						DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
	            }
	        }*/

	        if (Instigator.IsLocallyControlled())
	        {
	            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	            {
	                if ( FireMode[Mode].bIsFiring )
	                    ClientStopFire(Mode);
	            }

				if ( ClientState == WS_BringUp )
					TweenAnim(SelectAnim,PutDownTime);
				else if ( HasAnim(Anim) )
					PlayAnim(Anim, PutDownAnimRate, 0.0);
	        }

	        ClientState = WS_PutDown;
	    }

	    SetTimer(GetAnimDuration(Anim, PutDownAnimRate),false);

	    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	    {
			FireMode[Mode].bServerDelayStartFire = false;
			FireMode[Mode].bServerDelayStopFire = false;
		}
    }

    simulated function EndState()
    {
    	super.EndState();

		if( bUsingSights && Role == ROLE_Authority)
	    {
			ServerZoomOut(false);
		}
    }
// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
//		else
//			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
}

// Overriden to support taking you out of iron sights when using melee attacks
//// client & server ////
simulated function bool StartFire(int Mode)
{
    local int alt;

    if (!ReadyToFire(Mode))
        return false;

    if (Mode == 0)
        alt = 1;
    else
        alt = 0;

    FireMode[Mode].bIsFiring = true;
    FireMode[Mode].NextFireTime = Level.TimeSeconds + FireMode[Mode].PreFireTime;

    if (FireMode[alt].bModeExclusive)
    {
        // prevents rapidly alternating fire modes
        FireMode[Mode].NextFireTime = FMax(FireMode[Mode].NextFireTime, FireMode[alt].NextFireTime);
    }

    if (Instigator.IsLocallyControlled())
    {
        if (FireMode[Mode].PreFireTime > 0.0 || FireMode[Mode].bFireOnRelease)
        {
            FireMode[Mode].PlayPreFire();
        }
        FireMode[Mode].FireCount = 0;
    }

    // Take the weapon out of ironsights if we're trying to do a melee attack in ironsights
	if( FireMode[Mode].bMeleeMode )
    {
		ROPawn(Instigator).SetMeleeHoldAnims(true);
		GotoState('UnZoomImmediately');
	}

    return true;
}

//=============================================================================
// Crawling
//=============================================================================

simulated event NotifyCrawlMoving()
{
	if( !bUsingSights )
		super.NotifyCrawlMoving();
}

simulated state StartCrawling
{
	simulated function bool IsCrawling()
	{
		return true;
	}

	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

    simulated function Timer()
    {
    	GotoState('Crawling');
    }

	simulated event WeaponTick(float dt)
	{
		local int WeaponPitch;

		// This is only for the visual rotation of the first person weapon client side
		if( Level.NetMode == NM_DedicatedServer )
		{
			return;
		}

		// Looking straight forward
		CrawlWeaponPitch = 0;

	    if( Level.TimeSeconds - LastStartCrawlingTime < 0.15 )
		{
			WeaponPitch =  Rotation.Pitch & 65535;

			if( WeaponPitch != CrawlWeaponPitch )
			{

				if( WeaponPitch > 32768 )
				{
					WeaponPitch += CrawlPitchTweenRate * dt;

					if( WeaponPitch > 65535 )
					{
						WeaponPitch = CrawlWeaponPitch;
					}
				}
				else
				{
					WeaponPitch -= CrawlPitchTweenRate * dt;

					if( WeaponPitch <  0)
					{
						WeaponPitch = CrawlWeaponPitch;
					}
				}
			}

			CrawlWeaponPitch = WeaponPitch;
		}
	}

    simulated function PlayIdle()
    {
		local int Direction;

		if( Instigator.IsLocallyControlled() )
		{
	        Direction = ROPawn(Instigator).Get8WayDirection();

			if ( Direction == 0 ||  Direction == 2 ||  Direction == 3 || Direction == 4 ||
				Direction == 5 )
			{
				if( AmmoAmount(0) < 1 && HasAnim(CrawlForwardEmptyAnim))
				{
					LoopAnim(CrawlForwardEmptyAnim, 1.0, 0.2 );
				}
				else if( HasAnim(CrawlForwardAnim) )
				{
					LoopAnim(CrawlForwardAnim, 1.0, 0.2 );
				}
			}
			else
			{
				if( AmmoAmount(0) < 1 && HasAnim(CrawlBackwardEmptyAnim))
				{
					LoopAnim(CrawlBackwardEmptyAnim, 1.0, 0.2 );
				}
				else if( HasAnim(CrawlBackwardAnim) )
				{
					LoopAnim(CrawlBackwardAnim, 1.0, 0.2 );
				}
			}
		}
	}

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
	// Finish unzooming the player if they are zoomed
	else if( DisplayFOV != default.DisplayFOV )
    {
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			SmoothZoom(false);
		}
	}
}

simulated function PlayStartCrawl()
{
	local name Anim;
	local float AnimTimer;

	if( AmmoAmount(0) < 1 && HasAnim(CrawlStartEmptyAnim))
	{
		Anim = CrawlStartEmptyAnim;
	}
	else
	{
		Anim = CrawlStartAnim;
	}

	if( Instigator.IsLocallyControlled() )
	{
		PlayAnim( Anim, 1.0, FastTweenTime );
	}

    AnimTimer = GetAnimDuration(Anim, 1.0) + FastTweenTime;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
}

// Overriden to support empty crawling anims
simulated state Crawling
{
    simulated function PlayIdle()
    {
		local int Direction;

		if( Instigator.IsLocallyControlled() )
		{
	        Direction = ROPawn(Instigator).Get8WayDirection();

			if ( Direction == 0 ||  Direction == 2 ||  Direction == 3 || Direction == 4 ||
				Direction == 5 )
			{
				if( AmmoAmount(0) < 1 && HasAnim(CrawlForwardEmptyAnim))
				{
					LoopAnim(CrawlForwardEmptyAnim, 1.0, 0.2 );
				}
				else if( HasAnim(CrawlForwardAnim) )
				{
					LoopAnim(CrawlForwardAnim, 1.0, 0.2 );
				}
			}
			else
			{
				if( AmmoAmount(0) < 1 && HasAnim(CrawlBackwardEmptyAnim))
				{
					LoopAnim(CrawlBackwardEmptyAnim, 1.0, 0.2 );
				}
				else if( HasAnim(CrawlBackwardAnim) )
				{
					LoopAnim(CrawlBackwardAnim, 1.0, 0.2 );
				}
			}
		}
	}

// Finish unzooming the player if they are zoomed
Begin:
	if( DisplayFOV != default.DisplayFOV )
    {
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			SmoothZoom(false);
		}
	}
}

simulated function PlayEndCrawl()
{
	local name Anim;

	if( AmmoAmount(0) < 1 && HasAnim(CrawlEndEmptyAnim))
	{
		Anim = CrawlEndEmptyAnim;
	}
	else
	{
		Anim = CrawlEndAnim;
	}

	if( Instigator.IsLocallyControlled() )
	{
		PlayAnim( Anim, 1.0, FastTweenTime );
	}

	SetTimer(GetAnimDuration(Anim, 1.0) + FastTweenTime,false);
}

//=============================================================================
// Bayonet attach/detach functionality
//=============================================================================

// Hide the bayonet. Also called by anim notifies to hide bayonet during the attach/detach transition
simulated function HideBayonet()
{
    // scale down bayonet bone
    SetBoneScale( 0, 0.001, BayonetBoneName );
}

// Hide the bayonet. Also called by anim notifies to hide bayonet during the attach/detach transition
simulated function ShowBayonet()
{
    SetBoneScale( 0, 1.0, BayonetBoneName );
}

simulated exec function Deploy()
{
	if( IsBusy() || !bHasBayonet || (FireMode[1] != none && FireMode[1].bMeleeMode &&
	(FireMode[1].bIsFiring || FireMode[1].IsInState('MeleeAttacking'))))
		return;

	if( bBayonetMounted )
	{
        ChangeBayoStatus(false);
	}
	else
	{
		ChangeBayoStatus(true);
	}
}

simulated function ChangeBayoStatus(bool bBayoStatus)
{
	if( bBayoStatus )
	{
		GotoState('AttachingBayonet');

		if( Role < ROLE_Authority)
			ServerChangeBayoStatus(true);
	}
	else
	{
		GotoState('DetachingBayonet');

		if( Role < ROLE_Authority)
			ServerChangeBayoStatus(false);
	}
}

function ServerChangeBayoStatus(bool bBayoStatus)
{
	if( bBayoStatus )
	{
		GotoState('AttachingBayonet');
	}
	else
	{
		GotoState('DetachingBayonet');
	}
}

simulated state AttachingBayonet extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool WeaponAllowSprint()
	{
		return false;
	}

	simulated function bool CanStartCrawlMoving()
	{
		return false;
	}

    simulated function Timer()
    {
		if( Instigator.bIsCrawling && VSizeSquared(Instigator.Velocity) > 1.0 )
			GotoState('StartCrawling');
		else
			GotoState('Idle');
    }

    simulated function BeginState()
    {
		local float AnimTimer;

		bBayonetMounted = true;

		if( ROWeaponAttachment(ThirdPersonActor) != none )
			ROWeaponAttachment(ThirdPersonActor).bBayonetAttached = true;

		if( Instigator.IsLocallyControlled() )
		{
	    	PlayAnim(BayoAttachAnim, 1.0, FastTweenTime );
		}

		if( Role == ROLE_Authority )
		{
			ROPawn(Instigator).HandleBayoAttach();
		}

	    AnimTimer = GetAnimDuration(BayoAttachAnim, 1.0) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.1),false);
		else
			SetTimer(AnimTimer,false);
	}

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
}

simulated state DetachingBayonet extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool CanStartCrawlMoving()
	{
		return false;
	}

    simulated function Timer()
    {
		if( Instigator.bIsCrawling && VSizeSquared(Instigator.Velocity) > 1.0 )
			GotoState('StartCrawling');
		else
			GotoState('Idle');
    }

    simulated function BeginState()
    {
		local float AnimTimer;

		bBayonetMounted = false;

		if( ROWeaponAttachment(ThirdPersonActor) != none )
			ROWeaponAttachment(ThirdPersonActor).bBayonetAttached = false;

		if( Instigator.IsLocallyControlled() )
		{
	    	PlayAnim(BayoDetachAnim, 1.0, FastTweenTime );
		}

		if( Role == ROLE_Authority )
		{
			ROPawn(Instigator).HandleBayoDetach();
		}

	    AnimTimer = GetAnimDuration(BayoDetachAnim, 1.0) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.1),false);
		else
			SetTimer(AnimTimer,false);
	}

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
}

//=============================================================================
// Ironsight transition functionality
//=============================================================================
simulated function ROIronSights()
{
	if( bUsingSights )
	{
        PerformZoom(false);
	}
	else
	{
		PerformZoom(true);
	}
}

simulated function PerformZoom(bool bZoomStatus)
{
	if( IsBusy() && !IsCrawling() )
		return;

	if( bZoomStatus )
	{
        if( Instigator.Physics == PHYS_Falling )
            return;

    	//Don't allow them to go to iron sights during a melee attack
    	if( FireMode[1] != none && (FireMode[1].bIsFiring || FireMode[1].IsInState('MeleeAttacking')) )
    	{
    		return;
    	}

		ZoomIn(true);

		if( Role < ROLE_Authority)
			ServerZoomIn(true);
	}
	else
	{
		ZoomOut(true);

		if( Role < ROLE_Authority)
			ServerZoomOut(true);
	}
}

simulated function ZoomIn(bool bAnimateTransition)
{
    //Make the player stop firing when they go to iron sights
    if( FireMode[0] != none && FireMode[0].bIsFiring )
        FireMode[0].StopFiring();

    //Don't allow player to go to iron sights while in melee mode
    if( FireMode[1] != none && (FireMode[1].bIsFiring || FireMode[1].IsInState('MeleeAttacking')) )
        return;

	if( bAnimateTransition )
		GotoState('IronSightZoomIn');

	bUsingSights = true;
	ROPawn(Instigator).SetIronSightAnims(true);
}

function ServerZoomIn(bool bAnimateTransition)
{
	ZoomIn(bAnimateTransition);
}

simulated function ZoomOut(bool bAnimateTransition)
{
	if( bAnimateTransition )
		GotoState('IronSightZoomOut');

	bUsingSights = false;
	ROPawn(Instigator).SetIronSightAnims(false);
}

function ServerZoomOut(bool bAnimateTransition)
{
	ZoomOut(bAnimateTransition);
}

simulated function PlayerViewZoom(bool ZoomDirection)
{
	// currently, this instantly zooms the weapon into the new fov

	if( ZoomDirection )
	{
    	bPlayerViewIsZoomed = true;
    	PlayerController(Instigator.Controller).SetFOV(PlayerFOVZoom);
	}
	else
	{
    	bPlayerViewIsZoomed = false;
    	if( Instigator.Controller != none )
    	{
		    PlayerController(Instigator.Controller).DefaultFOV = 85;
		    PlayerController(Instigator.Controller).ResetFOV();
	    }
	}
}

simulated state IronSightZoomIn extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool CanStartCrawlMoving()
	{
		return false;
	}

    simulated function Timer()
    {
    	GotoState('Idle');
    }

    simulated function BeginState()
    {
		local name Anim;
		local float AnimTimer;

		if( AmmoAmount(0) < 1 && HasAnim(IronBringUpEmpty))
		{
			Anim = IronBringUpEmpty;
		}
		else if ( bWaitingToBolt && HasAnim(IronBringUpRest))
		{
		  	Anim = IronBringUpRest;
		}
		else
		{
			Anim = IronBringUp;
		}

		if( Instigator.IsLocallyControlled() )
		{
			PlayAnim( Anim, IronSwitchAnimRate, FastTweenTime );
		}

        AnimTimer = GetAnimDuration(Anim, IronSwitchAnimRate) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.15),false);
		else
			SetTimer(AnimTimer,false);
	}

	simulated function EndState()
	{
		local float TargetDisplayFOV;
		local vector TargetPVO;

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
		{
			if( ScopeDetail == RO_ModelScopeHigh )
			{
				TargetDisplayFOV = Default.IronSightDisplayFOVHigh;
				TargetPVO = Default.XoffsetHighDetail;
			}
			else if( ScopeDetail == RO_ModelScope )
			{
				TargetDisplayFOV = Default.IronSightDisplayFOV;
				TargetPVO = Default.XoffsetScoped;
			}
			else
			{
				TargetDisplayFOV = Default.IronSightDisplayFOV;
				TargetPVO = Default.PlayerViewOffset;
			}

			DisplayFOV = TargetDisplayFOV;
			PlayerViewOffset = TargetPVO;
		}
	}

Begin:
	if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
	{
		SmoothZoom(true);
		//DisplayFOV = IronSightDisplayFOV;
	}
}

simulated state IronSightZoomOut extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

    simulated function Timer()
    {
    	GotoState('Idle');
    }

    simulated function BeginState()
    {
		local name Anim;
		local float AnimTimer;

		if( AmmoAmount(0) < 1 && HasAnim(IronPutDownEmpty))
		{
			Anim = IronPutDownEmpty;
		}
		else
		{
			Anim = IronPutDown;
		}

		if( Instigator.IsLocallyControlled() )
		{
			PlayAnim( Anim, IronSwitchAnimRate, FastTweenTime );
		}

        AnimTimer = GetAnimDuration(Anim, IronSwitchAnimRate) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.15),false);
		else
			SetTimer(AnimTimer,false);
	}

    simulated function EndState()
    {
		if( Instigator.bIsCrawling && VSizeSquared(Instigator.Velocity) > 1.0 )
			NotifyCrawlMoving();

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
		{
			DisplayFOV = default.DisplayFOV;
			PlayerViewOffset = default.PlayerViewOffset;
		}
	}
Begin:
	if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
		if( bPlayerFOVZooms )
		{
	    	PlayerViewZoom(false);
		}
		SmoothZoom(false);
		//DisplayFOV = default.DisplayFOV;
	}
}

// Take the weapon out of iron sights if you jump
simulated function NotifyOwnerJumped()
{
	if( !IsBusy() || IsInState('IronSightZoomIn') )
	{
		GotoState('TweenDown');
	}
}

// Just go back to the idle animation and take us out of zoom if we are zoomed
simulated state TweenDown extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

    simulated function Timer()
    {
    	GotoState('Idle');
    }

	simulated function PlayIdle()
	{
		if( bUsingSights )
	    {
		    if( bWaitingToBolt && HasAnim(PostFireIronIdleAnim))
		    {
	         	TweenAnim(PostFireIronIdleAnim, FastTweenTime );
		    }
			else if( AmmoAmount(0) < 1 && HasAnim(IronIdleEmptyAnim) )
		    {
				TweenAnim(IronIdleEmptyAnim, FastTweenTime );
			}
			else
			{
				TweenAnim(IronIdleAnim, FastTweenTime );
			}
	    }
		else
	    {
		    if( bWaitingToBolt && HasAnim(PostFireIdleAnim))
		    {
	         	TweenAnim(PostFireIdleAnim, FastTweenTime );
		    }
		    else if(  AmmoAmount(0) < 1 && HasAnim(IdleEmptyAnim))
		    {
				TweenAnim(IdleEmptyAnim, FastTweenTime );
			}
			else
			{
				TweenAnim(IdleAnim, FastTweenTime );
			}
	    }
	}


    simulated function BeginState()
    {
	}

    simulated function EndState()
    {
		// Reset any zoom values
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			global.PlayIdle();
		}
	}

Begin:
	if( bUsingSights )
    {
		SetTimer(Default.ZoomOutTime + 0.1,false);

		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() || (Instigator.DrivenVehicle != none && Instigator.DrivenVehicle.IsLocallyControlled()))
		{
			PlayIdle();

			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}

			SmoothZoom(false);
		}
	}
	else
	{
		GotoState('Idle');
	}
}

simulated function PlayIdle()
{
	if( bUsingSights )
    {
	    if( bWaitingToBolt && HasAnim(PostFireIronIdleAnim))
	    {
         	LoopAnim(PostFireIronIdleAnim, IdleAnimRate, 0.2 );
	    }
		else if( AmmoAmount(0) < 1 && HasAnim(IronIdleEmptyAnim) )
	    {
			LoopAnim(IronIdleEmptyAnim, IdleAnimRate, 0.2 );
		}
		else
		{
			LoopAnim(IronIdleAnim, IdleAnimRate, 0.2 );
		}
    }
	else
    {
	    if( bWaitingToBolt && HasAnim(PostFireIdleAnim))
	    {
         	LoopAnim(PostFireIdleAnim, IdleAnimRate, 0.2 );
	    }
	    else if(  AmmoAmount(0) < 1 && HasAnim(IdleEmptyAnim))
	    {
			LoopAnim(IdleEmptyAnim, IdleAnimRate, 0.2 );
		}
		else
		{
			LoopAnim(IdleAnim, IdleAnimRate, 0.2 );
		}
    }
}

// Takes us out of zoom immediately. This is a non blocking state, and will not prevent
// firing, reloading, etc. Use this when some non state changing action needs to
// bring us out of iron sights immediately, without playing the idle animation
simulated state UnZoomImmediately extends Idle
{
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		// We'll want to sleep however long this zoom out takes
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}

	GotoState('Idle');
}

//=============================================================================
// Sprinting
//=============================================================================
simulated state StartSprinting
{
    simulated function PlayIdle()
    {
		local float LoopSpeed;
		local float Speed2d;
		local name Anim;

		if( Instigator.IsLocallyControlled() )
		{
			// Make the sprinting animation match the sprinting speed
	        LoopSpeed=1.5;

			Speed2d = VSize(Instigator.Velocity);
			LoopSpeed = ((Speed2d/(Instigator.Default.GroundSpeed * Instigator.SprintPct))*1.5);

			if( (AmmoAmount(0) <= 0) && HasAnim(SprintLoopEmptyAnim) )
				Anim = SprintLoopEmptyAnim;
			else
				Anim = SprintLoopAnim;

			if( HasAnim(SprintLoopAnim) )
	    		LoopAnim( Anim, LoopSpeed, 0.2);
		}
	}


    simulated function BeginState()
    {
    	PlayStartSprint();
	}

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
	// Finish unzooming the player if they are zoomed
	else if( DisplayFOV != default.DisplayFOV )
    {
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			SmoothZoom(false);
		}
	}
}

simulated function PlayStartSprint()
{
	local name Anim;

	if( (AmmoAmount(0) <= 0) && HasAnim(SprintStartEmptyAnim) )
		Anim = SprintStartEmptyAnim;
	else
		Anim = SprintStartAnim;

	if( Instigator.IsLocallyControlled() )
	{
     	PlayAnim( Anim, 1.5, FastTweenTime );
	}

	SetTimer(GetAnimDuration(Anim, 1.5) + FastTweenTime,false);
}

simulated state WeaponSprinting
{
    simulated function PlayIdle()
    {
		local float LoopSpeed;
		local float Speed2d;
		local name Anim;

		if( Instigator.IsLocallyControlled() )
		{
			// Make the sprinting animation match the sprinting speed
	        LoopSpeed=1.5;

			Speed2d = VSize(Instigator.Velocity);
			LoopSpeed = ((Speed2d/(Instigator.Default.GroundSpeed * Instigator.SprintPct))*1.5);

			if( (AmmoAmount(0) <= 0) && HasAnim(SprintLoopEmptyAnim) )
				Anim = SprintLoopEmptyAnim;
			else
				Anim = SprintLoopAnim;

			if( HasAnim(SprintLoopAnim) )
	    		LoopAnim( Anim, LoopSpeed, FastTweenTime);
		}
	}

// Finish unzooming the player if they are zoomed
Begin:
	if( DisplayFOV != default.DisplayFOV )
    {
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			SmoothZoom(false);
		}
	}
}

simulated function PlayEndSprint()
{
	local name Anim;

	if( (AmmoAmount(0) <= 0) && HasAnim(SprintEndEmptyAnim) )
		Anim = SprintEndEmptyAnim;
	else
		Anim = SprintEndAnim;

	if( Instigator.IsLocallyControlled() )
	{
     	PlayAnim( Anim, 1.5, FastTweenTime );
	}

	SetTimer(GetAnimDuration(Anim, 1.5) + FastTweenTime,false);
}


//=============================================================================
// Reloading/Ammunition
//=============================================================================
simulated function OutOfAmmo()
{
	if( !HasAmmo() )
	{
		if( ROWeaponAttachment(ThirdPersonActor) != none )
		{
			ROWeaponAttachment(ThirdPersonActor).bOutOfAmmo = true;
		}
	}

    if ( Instigator == None || !Instigator.IsLocallyControlled() || HasAmmo() )
        return;

	if( AIController(Instigator.Controller) != none )
	{
   		GotoState('Reloading');
	}
}

simulated exec function ROManualReload()
{
    local ROPlayer player;

	if( !AllowReload() )
		return;

	if( Level.Netmode == NM_Client && !IsBusy())
	{
		GotoState('PendingAction');
	}

	// Hint check
	player = ROPlayer(Instigator.Controller);
	if (player != none)
	    player.CheckForHint(16);

	ServerRequestReload();
}

simulated function bool AllowReload()
{
    if( IsFiring() || IsBusy() )
		return false;

	// Can't reload if we don't have a mag to put in
	if( CurrentMagCount	< 1)
		return false;

    return true;
}


simulated function int GetHudAmmoCount()
{
	return CurrentMagCount;
}


function ServerRequestReload()
{
	if( AllowReload() )
	{
		GotoState('Reloading');
		ClientDoReload();
	}
	else
	{
		// if we can't reload
		ClientCancelReload();
	}
}

simulated function ClientDoReload(optional int NumRounds)
{
 	GotoState('Reloading');
}

simulated function ClientCancelReload()
{
 	GotoState('Idle');
}

simulated state Reloading extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool WeaponAllowSprint()
	{
		return false;
	}

	simulated function bool CanStartCrawlMoving()
	{
		return false;
	}

    simulated function Timer()
    {
		if( Instigator.bIsCrawling && VSizeSquared(Instigator.Velocity) > 1.0 )
			GotoState('StartCrawling');
		else
			GotoState('Idle');
    }

    simulated function BeginState()
    {
		if( Role == ROLE_Authority )
		{
			ROPawn(Instigator).HandleStandardReload();
		}
		PlayReload();
    }

    simulated function EndState()
    {
		if( Role == ROLE_Authority )
			    PerformReload();

		bWaitingToBolt = false;
    }

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}

	// Sometimes the client will get switched out of ironsight mode before getting to
	// the reload function. This should catch that.
	if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
		if( DisplayFOV != default.DisplayFOV )
		{
			SmoothZoom(false);
		}

		if( bPlayerFOVZooms )
		{
	    	PlayerViewZoom(false);
		}
	}
}

// Client gets sent to this state when the client has requested an action
// that needs verified by the server. Once the server verifies they
// can start the action, the server will take the client out of this state
simulated state PendingAction extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool WeaponAllowSprint()
	{
		return false;
	}

// Take the player out of iron sights if they are in ironsights
Begin:
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);

		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if( bPlayerFOVZooms )
			{
		    	PlayerViewZoom(false);
			}
			SmoothZoom(false);
		}
	}
}

simulated function PlayReload()
{
	local name Anim;
	local float AnimTimer;

    if( AmmoAmount(0) > 0 )
    {
		Anim = MagPartialReloadAnim;
	}
	else
	{
		Anim = MagEmptyReloadAnim;
	}

    AnimTimer = GetAnimDuration(Anim, 1.0) + FastTweenTime;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);

	if( Instigator.IsLocallyControlled() )
	{
		PlayAnim(Anim, 1.0, FastTweenTime);
	}
}

// Do the actual ammo swapping
function PerformReload()
{
	local int CurrentMagLoad;
	local bool bDidPlusOneReload;

    CurrentMagLoad = AmmoAmount(0);

	if( PrimaryAmmoArray.Length == 0 )
	{
		return;
	}

	if ( CurrentMagLoad <= 0 )
	{
		PrimaryAmmoArray.Remove(CurrentMagIndex, 1);
	}
	else
	{
		if( bPlusOneLoading )
		{
		    //If there's only one bullet left(the one in the chamber), discard the clip
		    if ( CurrentMagLoad == 1 )
		        PrimaryAmmoArray.Remove(CurrentMagIndex, 1);
		    else
    			PrimaryAmmoArray[CurrentMagIndex] = CurrentMagLoad - 1;

			AmmoCharge[0] = 1;
			bDidPlusOneReload = true;
		}
		else
		{
			PrimaryAmmoArray[CurrentMagIndex] = CurrentMagLoad;
			AmmoCharge[0] = 0;
		}
	}

	if( PrimaryAmmoArray.Length == 0 )
	{
		return;
	}

	CurrentMagIndex++;

	if ( CurrentMagIndex > PrimaryAmmoArray.Length - 1)
	{
		CurrentMagIndex = 0;
	}

	if( bDidPlusOneReload )
	{
		AddAmmo(PrimaryAmmoArray[CurrentMagIndex] + 1, 0);
	}
	else
	{
		AddAmmo(PrimaryAmmoArray[CurrentMagIndex], 0);
	}

	if( Instigator.IsHumanControlled() )
	{
		if( AmmoStatus(0) > 0.5 )
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'ROAmmoWeightMessage',0);
		}
		else if(  AmmoStatus(0) > 0.2 )
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'ROAmmoWeightMessage',1);
		}
		else
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'ROAmmoWeightMessage',2);
		}
	}

	if( AmmoAmount(0) > 0 )
	{
		if( ROWeaponAttachment(ThirdPersonActor) != none )
		{
			ROWeaponAttachment(ThirdPersonActor).bOutOfAmmo = false;
		}
	}

	ClientForceAmmoUpdate(0, AmmoAmount(0));

	CurrentMagCount = PrimaryAmmoArray.Length - 1;
}

function bool FillAmmo()
{
	local int InitialAmount, i;

    if( PrimaryAmmoArray.Length == MaxNumPrimaryMags )
    {
    	return false;
    }

	InitialAmount = FireMode[0].AmmoClass.Default.InitialAmount;

    PrimaryAmmoArray.Length = MaxNumPrimaryMags;
	for( i=0; i<PrimaryAmmoArray.Length; i++ )
	{
		PrimaryAmmoArray[i] = InitialAmount;
	}
	CurrentMagIndex=0;
	CurrentMagCount = PrimaryAmmoArray.Length - 1;

	AddAmmo(InitialAmount,0);

	return true;
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    local bool bJustSpawnedAmmo;
    local int addAmount, InitialAmount, i;

    if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
    {
        Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
		bJustSpawnedAmmo = false;

		if ( (FireMode[m].AmmoClass == None) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )
			return;

		InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;

		if( bJustSpawned && WP == None)
		{
			PrimaryAmmoArray.Length = InitialNumPrimaryMags;
			for( i=0; i<PrimaryAmmoArray.Length; i++ )
			{
				PrimaryAmmoArray[i] = InitialAmount;
			}
			CurrentMagIndex=0;
			CurrentMagCount = PrimaryAmmoArray.Length - 1;
		}

		if ( (WP != None) /*&& ((WP.AmmoAmount[0] > 0) || (WP.AmmoAmount[1] > 0)) */ )
		{
			InitialAmount = WP.AmmoAmount[m];
			PrimaryAmmoArray[PrimaryAmmoArray.Length] = InitialAmount;
		}

		if ( Ammo[m] != None )
		{
			addamount = InitialAmount + Ammo[m].AmmoAmount;
			Ammo[m].Destroy();
		}
		else
			addAmount = InitialAmount;

		AddAmmo(addAmount,m);
    }
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
	if ( AmmoClass[0] == AmmoClass[mode] )
		mode = 0;
	if ( Level.GRI.WeaponBerserk > 1.0 )
		AmmoCharge[mode] = MaxAmmo(Mode);
	else if ( AmmoCharge[mode] < MaxAmmo(mode) )
		AmmoCharge[mode] = Min(MaxAmmo(mode), AmmoCharge[mode]+AmmoToAdd);

	NetUpdateTime = Level.TimeSeconds - 1;
	return true;
}

function bool HandlePickupQuery( pickup Item )
{
    local WeaponPickup wpu;
	local int i, j;
	local bool bAddedMags;

	if ( bNoAmmoInstances )
	{
		// handle ammo pickups
		for ( i=0; i<2; i++ )
		{
			if ( (item.inventorytype == AmmoClass[i]) && (AmmoClass[i] != None) )
			{
				if( PrimaryAmmoArray.Length < MaxNumPrimaryMags )
				{
					// Handle multi mag ammo type pickups
					if( ROMultiMagAmmoPickup(Item) != none )
					{
						for( j=0; j<ROMultiMagAmmoPickup(Item).AmmoMags.Length; j++ )
						{
							if (PrimaryAmmoArray.Length < MaxNumPrimaryMags)
					        {
					            PrimaryAmmoArray[PrimaryAmmoArray.Length] = ROMultiMagAmmoPickup(Item).AmmoMags[j];//DropAmmo( StartLocation, PrimaryAmmoArray[i]);
					        	bAddedMags=true;
							}
							else
							{
								break;
							}
						}
					}
					// Handle standard/old style ammo pickups
					else
					{
						PrimaryAmmoArray[PrimaryAmmoArray.Length] = Min(MaxAmmo(i), Ammo(item).AmmoAmount);
						bAddedMags=true;
					}
				}
				else
				{
				 	return true;
				}

				// if we added mags, update the mag count and force a net update
				if( bAddedMags )
				{
					CurrentMagCount = PrimaryAmmoArray.Length - 1;
					NetUpdateTime = Level.TimeSeconds - 1;
				}

				item.AnnouncePickup(Pawn(Owner));
				item.SetRespawn();
				return true;
			}
		}
	}

	if (class == Item.InventoryType)
    {
        wpu = WeaponPickup(Item);
        if (wpu != None)
            return !wpu.AllowRepeatPickup();
        else
            return false;
    }

    // Drop current weapon and pickup the one on the ground
    if( Instigator.Weapon != none && Instigator.Weapon.InventoryGroup == InventoryGroup &&
		Item.InventoryType.default.InventoryGroup == InventoryGroup && Instigator.CanThrowWeapon())
	{
		ROPlayer(Instigator.Controller).ThrowWeapon();
		return false;
	}

	// Avoid multiple weapons in the same slot
    if (Item.InventoryType.default.InventoryGroup == InventoryGroup)
		return true;

    if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function DropFrom(vector StartLocation)
{
    local int m, i, j;
    local int DropMagCount;
	local Pickup Pickup, TempPickup;
	local ROMultiMagAmmoPickup AmmoPickup;
	local rotator R;

    if (!bCanThrow )
        return;

	if( Instigator != none && bUsingSights )
	{
		bUsingSights = false;
		ROPawn(Instigator).SetIronSightAnims(false);
	}

    ClientWeaponThrown();

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m].bIsFiring)
            StopFire(m);
    }

	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);
	}

	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
    	Pickup.InitDroppedPickupFor(self);
	    Pickup.Velocity = Velocity;
        if (Instigator.Health > 0)
            WeaponPickup(Pickup).bThrown = true;
    }

    // Handle multi mag ammo type pickups
	if( class<ROMultiMagAmmoPickup>(AmmoPickupClass(0)) != none && CurrentMagCount > 0)
	{
		R.Yaw = rand(65536);
		TempPickup = spawn(AmmoPickupClass(0),,,StartLocation,R);

		AmmoPickup = ROMultiMagAmmoPickup(TempPickup);

		if ( AmmoPickup == None )
		{
			return;
		}
		AmmoPickup.InitDroppedPickupFor(self);

		AmmoPickup.Velocity.X = Rand(200);
		AmmoPickup.Velocity.Y = Rand(200);
		AmmoPickup.Velocity.Z = Rand(100);

		AmmoPickup.AmmoMags.Length = CurrentMagCount;

		for( j=0; j<PrimaryAmmoArray.Length; j++ )
		{
			if (j != CurrentMagIndex)
	        {
				AmmoPickup.AmmoMags[DropMagCount] = PrimaryAmmoArray[j];
	            DropMagCount++;
	        }
		}
	}
	// Handle standard/old style ammo pickups
	else
	{
	    for (i = 0; i < PrimaryAmmoArray.Length; i++)
	    {
	        if (i != CurrentMagIndex)
	        {
	            DropAmmo( StartLocation, PrimaryAmmoArray[i]);
	        }
	    }
    }

   	Destroy();

}

// Drop a mag of ammo of our ammo pickup class type
function DropAmmo( vector DropLocation, int MagAmmoAmount)
{
	local Pickup A;
	local rotator R;

	R.Yaw = rand(65536);
	A = spawn(AmmoPickupClass(0),,,DropLocation,R);

	if ( A == None )
	{
		return;
	}
	A.InitDroppedPickupFor(self);
	Ammo(A).AmmoAmount = MagAmmoAmount;

	A.Velocity.X = Rand(200);
	A.Velocity.Y = Rand(200);
	A.Velocity.Z = Rand(100);
}

// The empty sound if your out of ammo
simulated function Fire(float F)
{
    local ROPlayer player;

    // Hint check
    player = ROPlayer(Instigator.Controller);

	if( AmmoAmount(0) < 1 && !IsBusy())
	{
		PlayOwnedSound(FireMode[0].NoAmmoSound,SLOT_None,1.0,,,,false);

		if (player != none)
            player.CheckForHint(7);
	}

    if (player != none)
        player.CheckForHint(2);
}

defaultproperties
{
     IronSwitchAnimRate=1.000000
     FastTweenTime=0.200000
     Priority=9
     bUsesFreeAim=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=4.000000
     LightPeriod=3
}
