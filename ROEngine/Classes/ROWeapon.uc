//=============================================================================
// ROWeapon
//=============================================================================
// Base class for all Red Orchestra weapons
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROWeapon extends Weapon
	native
	abstract;

//#exec OBJ LOAD FILE=..\textures\Weapons1st_tex.utx

//=============================================================================
// Variables
//=============================================================================

// Animations
var()		name			SprintStartAnim;     		// anim that shows the beginning of the sprint
var()		name			SprintLoopAnim;      		// anim that is looped for when player is sprinting
var()		name			SprintEndAnim;      		// anim that shows the weapon returning to normal after sprinting

var()		name			CrawlForwardAnim; 			// Animation for crawling forward
var()		name			CrawlBackwardAnim;          // Animation for crawling backward
var()		name			CrawlStartAnim;             // Animation for starting to crawl
var()		name			CrawlEndAnim;               // Animation for ending crawling

var			int				CrawlWeaponPitch;	    	// The current pitch the weapon should be at when crawling
var			int				CrawlPitchTweenRate;		// How quickly to twean the pitch when crawling forward/back
var			float 			LastEndCrawlingTime; 		// Used in smoothing out transitions to/from crawling forward/back

var 		float   		FastTweenTime;				// A short tween time we'll use for animations

// Iron sights
var 		float 			IronSightDisplayFOV;   		// Weapon fov when in iron sights
var			float			IronSightDisplayFOVHigh; 	// The IronSight FOV on high detail

// Zooming vars
var()       float       	ZoomInTime;                 // The length of time to spend zooming in
var()       float       	ZoomOutTime;                // The length of time to spend zooming out
var			float			StartingDisplayFOV;			// Used by the native code for ironsight zooming
var 		bool 			bPlayerViewIsZoomed;   		// CLIENTSIDE VAR this will track if the player is zoomed or not
var 		float 			PlayerFOVZoom;      		// The PlayerFOV the player's FOV will change too when using scoped weapons
var 		bool 			bPlayerFOVZooms;			// when true, the player FOV will zoom when in iron sights, lower end scopes will use this, model and texture
var()		vector			XoffsetHighDetail;			// Xoffset for using high detail scopes
var()		vector			XoffsetScoped;				// Xoffset for using regular scopes
var 		bool 			bIsSniper;                  // true for any sniper weapons, aka they'll have scopes

var config enum ScopeDetailSettings
{
	RO_ModelScope,
	RO_TextureScope,
	RO_ModelScopeHigh,
	RO_None
} 	ScopeDetail;   		// Which detail setting for the scope


// Added so we can do team specific sleeves, and later role specific - Ramm
var()		material		GermanSleevetex;
var()		material		RussianSleevetex;
var()		material		Handtex;
var()		byte			SleeveNum; 					// Which skin is the sleeve? Wouldn't have to do this if the modellers were consistent
var()		byte			HandNum; 					// Which skin is the hand? Wouldn't have to do this if the modellers were consistent

// Free-Aim
var()		float			FreeAimRotationSpeed;		// How fast the free-aim rotation speed should be for this weapon

var 		bool			bWaitingToBolt;				// The gun has fired and is waiting to work the bolt
var 		bool			bHasSelectFire;				// This weapon has multiple selectable primary fire modes

//=============================================================================
// replication
//=============================================================================
replication
{
    reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		bWaitingToBolt;
}

//=============================================================================
// Native functions
//=============================================================================

native simulated latent function SmoothZoom( bool ZoomDirection );

//=============================================================================
// Functions
//=============================================================================

simulated function PostBeginPlay()
{
	// Weapon will handle FireMode instantiation
	Super.PostBeginPlay();

    if ( Level.NetMode == NM_DedicatedServer )
        return;

	if( !bIsSniper )
	{
		ScopeDetail = RO_None;
	}
}

//=============================================================================
// Functions that need to be implemented
//=============================================================================
function bool FillAmmo(){return false;}
function bool ResupplyAmmo(){return false;}
simulated function bool UsingAutoFire(){return false;} // Only implemented for weapons with a selectable primary fire mode (like the STG). Used by the hud for the fire mode indicator

//=============================================================================
// Sound
//=============================================================================

// Called by anim notifies to play a sound for this weapon
simulated function PlayWeaponSound(sound ThisSound, float NewVolume, int NewRadius)
{
    PlaySound(ThisSound,,NewVolume,,NewRadius,1.0,false);
}

//=============================================================================
// Shell ejections
//=============================================================================

simulated function AnimNotifiedShellEject()
{
	if( ROWeaponFire(FireMode[0]) != none && Instigator.IsFirstPerson())
	{
//		ROWeaponFire(FireMode[0]).EjectShell();
	}
}

//=============================================================================
// Scopes
//=============================================================================

//------------------------------------------------------------------------------
// SetScopeDetail(RO) - Allow the players to change scope detail while ingame.
//	Changes are saved to the ini file.
//------------------------------------------------------------------------------
//simulated exec function SetScopeDetail()
//{
//	if( !bIsSniper )
//		return;
//
//	if (ScopeDetail == RO_ModelScope)
//		ScopeDetail = RO_TextureScope;
//	else if ( ScopeDetail == RO_TextureScope)
//		ScopeDetail = RO_ModelScopeHigh;
//	else if ( ScopeDetail == RO_ModelScopeHigh)
//		ScopeDetail = RO_ModelScope;
//
//	AdjustIngameScope();
//	class'ROEngine.ROWeapon'.default.ScopeDetail = ScopeDetail;
//	class'ROEngine.ROWeapon'.static.StaticSaveConfig();		// saves the new scope detail value to the ini
//}

//------------------------------------------------------------------------------
// AdjustIngameScope(RO) - Takes the changes to the ScopeDetail variable and
//	sets the scope to the new detail mode. Called when the player switches the
//	scope setting ingame, or when the scope setting is changed from the menu
//------------------------------------------------------------------------------
simulated function AdjustIngameScope()
{
	if( !bIsSniper )
		return;

	switch (ScopeDetail)
	{
		case RO_ModelScope:
			if( bUsingSights )
				DisplayFOV = default.IronSightDisplayFOV;
			if ( bUsingSights && bPlayerViewIsZoomed)
				PlayerViewZoom(false);
			break;

		case RO_TextureScope:
			if( bUsingSights )
				DisplayFOV = default.IronSightDisplayFOV;
			if ( bUsingSights && !bPlayerViewIsZoomed)
				PlayerViewZoom(true);
			break;

		case RO_ModelScopeHigh:
			if( bUsingSights )
			{
				if( IronSightDisplayFOVHigh > 0 )
					DisplayFOV = default.IronSightDisplayFOVHigh;
				else
					DisplayFOV = default.IronSightDisplayFOV;
			}
			if ( bUsingSights && bPlayerViewIsZoomed)
				PlayerViewZoom(false);
			break;
	}

	// Make any chagned to the scope setup
	UpdateScopeMode();
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
	    PlayerController(Instigator.Controller).DefaultFOV = 85;
	    PlayerController(Instigator.Controller).ResetFOV();
	}
}

// Defined in subclass, updates the scope shader
simulated function UpdateScopeMode(){}
simulated function PreTravelCleanUp(){}

// Implemented in subclass. Put here to avoid casting
simulated function bool ShouldDrawPortal(){ return false;}

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

    if (Instigator == None)
    	return;

    // Lets avoid having to do multiple casts every tick - Ramm
    Playa = ROPlayer(Instigator.Controller);

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

	//Adjust weapon position for lean
	rpawn = ROPawn(Instigator);
	if (rpawn != none && rpawn.LeanAmount != 0)
	{
		leanangle += rpawn.LeanAmount;
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );

	RollMod = Instigator.GetViewRotation();
	RollMod.Roll += leanangle;

	if( IsCrawling() )
	{
		RollMod.Pitch = CrawlWeaponPitch;
	}

    SetRotation( RollMod );

    bDrawingFirstPerson = true;
    Canvas.DrawActor(self, false, false, DisplayFOV);
    bDrawingFirstPerson = false;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	// We don't want poeple looking at the debug info to get thier ammo count
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText("DisplayFOV is " $DisplayFOV$" default is "$default.DisplayFOV$" Zoomed default is "$IronSightDisplayFOV);
    YPos += YL;
    Canvas.SetPos(4,YPos);
}


// Overriden to set additional RO Variables when a weapon is given to the player
function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local ROWeaponPickup Pick;

    if( Pickup != none )
    {
	    Pick = ROWeaponPickup(Pickup);

		if( Pick != none )
		{
			bBayonetMounted = Pick.bHasBayonetMounted;
		}
	}

	super.GiveTo(Other,Pickup);
}

//===========================================
// Used for debugging the weapons and scopes- Ramm
//===========================================

// commented these out for release
/*
simulated exec function dfov(int thisFOV)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	DisplayFOV = thisFOV;
}

simulated exec function xoffset(float offset)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	PlayerViewOffset.x = offset;
}

simulated exec function yoffset(float offset)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	PlayerViewOffset.y = offset;
}

simulated exec function zoffset(float offset)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	PlayerViewOffset.z = offset;
} */


// Implemented in various states to show whether the weapon is busy performing
// some action that normally shouldn't be interuppted
simulated function bool IsBusy()
{
	// We're busy if the weaponfire class won't let us fire. Used primarily for MeleeAttacking
	if( FireMode[1] != none && !FireMode[1].AllowFire() )
	{
		return true;
	}

	return false;
}

simulated function bool WeaponCanSwitch()
{
	if( IsBusy() || Instigator.bBipodDeployed )
	{
		return false;
	}

	//Don't allow them to switch weapons if they are firing
	if( (FireMode[0] != none && (FireMode[0].bIsFiring || FireMode[0].IsInState('FireLoop'))) ||
        (FireMode[1] != none && (FireMode[1].bIsFiring || FireMode[1].IsInState('MeleeAttacking'))) )
	{
		return false;
	}

	return super.WeaponCanSwitch();
}

// Overriden to support our melee system
simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

/*    // Don't play the idle anim after a bayo strike or bash
    if (ClientState == WS_ReadyToFire && FireMode[1].bMeleeMode)
    {
		if (anim == ROWeaponFire(FireMode[1]).BashAnim || anim == ROWeaponFire(FireMode[1]).BayoStabAnim ||
			anim == ROWeaponFire(FireMode[1]).BashEmptyAnim)
        {
            return;
        }
    }
*/
    super.AnimEnd(channel);
}

simulated state Idle
{
	simulated function bool IsBusy()
	{
		return global.IsBusy();
	}

    simulated function Timer()
    {
    }

    simulated function BeginState()
    {
	    if (ClientState == WS_BringUp)
	    {
	        PlayIdle();
	        ClientState = WS_ReadyToFire;
	    }

	    // If we started sprinting during another activity, as soon as it completes
	    // start the weapon sprinting
		if( Instigator.bIsSprinting )
		{
			SetSprinting(true);
		}

		// Send the weapon to craawling if we started crawling during some other activity
		// that couldn't be interuppted
		if( Instigator.bIsCrawling && VSizeSquared(Instigator.Velocity) > 1.0 && CanStartCrawlMoving())
			GotoState('StartCrawling');
    }

    simulated function EndState()
    {
    }
}

simulated state Busy
{
	ignores ClientStartFire, PutDown, BringUp/*, SetScopeDetail*/;

	simulated function bool IsBusy()
	{
		return true;
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	HandleSleeveSwapping();

	if( ROPlayer(Instigator.Controller) != none )
	{
     	ROPlayer(Instigator.Controller).FAAWeaponRotationFactor = FreeAimRotationSpeed;
    }

	GotoState('RaisingWeapon');

	if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
		OldWeapon = PrevWeapon;
	else
		OldWeapon = None;
}

//------------------------------------------------------------------------------
// HandleSleeveSwapping(RO) - This function will handle sleeve swapping for
//	weapons depending on which side the person who picked the weapon up is on.
//------------------------------------------------------------------------------
// TODO: Hacked up right now until the new sleeves are in - Ramm
simulated function HandleSleeveSwapping()
{
	local Material SleeveTexture;
	local RORoleInfo RI;

	// don't bother with AI players
	if( !Instigator.IsHumanControlled() || !Instigator.IsLocallyControlled() )
		return;

    RI = ROPlayer(Instigator.Controller).GetRoleInfo();

	if( RI != none )
		SleeveTexture = RI.static.GetSleeveTexture();

	if( SleeveTexture != none )
		Skins[SleeveNum] = SleeveTexture;
	Skins[HandNum]	= Handtex;
}


simulated state RaisingWeapon
{
    simulated function Timer()
    {
		GotoState('Idle');
    }

    simulated function BeginState()
    {
	   local int Mode;

	    if ( ClientState == WS_Hidden )
	    {
	        PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
			ClientPlayForceFeedback(SelectForce);  // jdf

	        if ( Instigator.IsLocallyControlled() )
	        {
	            if ( (Mesh!=None) && HasAnim(SelectAnim) )
	                PlayAnim(SelectAnim, SelectAnimRate, 0.0);
	        }

	        ClientState = WS_BringUp;
	    }

	    SetTimer(GetAnimDuration(SelectAnim, SelectAnimRate),false);

	    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
		{
			FireMode[Mode].bIsFiring = false;
			FireMode[Mode].HoldTime = 0.0;
			FireMode[Mode].bServerDelayStartFire = false;
			FireMode[Mode].bServerDelayStopFire = false;
			FireMode[Mode].bInstantStop = false;
		}
    }

    simulated function EndState()
    {
		local int Mode;

		// Clear any prevent weapon fire flags after the weapon is completely raised
		if( Role < ROLE_Authority )
		{
			if( Instigator != none && ROPawn(Instigator) != none )
				ROPawn(Instigator).bPreventWeaponFire = false;
		}

	    if (ClientState == WS_BringUp)
	    {
			for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
		       FireMode[Mode].InitEffects();
	    }
    }
}

simulated state LoweringWeapon
{
    simulated function Timer()
    {
		GotoState('Idle');
    }

    simulated function BeginState()
    {
	    local int Mode;

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
				else if ( HasAnim(PutDownAnim) )
					PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
	        }

	        ClientState = WS_PutDown;
	    }

	    SetTimer(GetAnimDuration(PutDownAnim, PutDownAnimRate),false);

	    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	    {
			FireMode[Mode].bServerDelayStartFire = false;
			FireMode[Mode].bServerDelayStopFire = false;
		}
    }

    simulated function EndState()
    {
		local int Mode;

		if (ClientState == WS_PutDown)
	    {
			if ( Instigator.PendingWeapon == none )
			{
				PlayIdle();
				ClientState = WS_ReadyToFire;
			}
			else
			{
				ClientState = WS_Hidden;
				Instigator.ChangedWeapon();
				if ( Instigator.Weapon == self )
				{
					PlayIdle();
					ClientState = WS_ReadyToFire;
				}
				else
				{
					for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
						FireMode[Mode].DestroyEffects();
				}
			}
	    }
    }
}


simulated function bool PutDown()
{
 	GotoState('LoweringWeapon');

	if (ROWeaponAttachment(ThirdPersonActor) != None)
	{
		ROWeaponAttachment(ThirdPersonActor).AmbientSound = None;
	}

    OldWeapon = None;
    return true; // return false if preventing weapon switch
}

// Overriden to prevent the player from firing on the client while swapping weapons
// This was causing the nade exploding in hands bug
simulated function bool ReadyToFire(int Mode)
{
    local int alt;

    if( ROPawn(Instigator).bPreventWeaponFire )
        return false;

    if( bWaitingToBolt && Mode == 0 )
    	return false;

    if ( Mode == 0 )
        alt = 1;
    else
        alt = 0;

    if ( ((FireMode[alt] != FireMode[Mode]) && FireMode[alt].bModeExclusive && (FireMode[alt].bIsFiring || FireMode[alt].IsInState('MeleeAttacking')))
		|| !FireMode[Mode].AllowFire()
		|| (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime) )
    {
        return false;
    }

    // Don't fire if hud is capturing mouse input
    if (Instigator != none && Instigator.Controller != none &&
        ROPlayer(Instigator.Controller) != none && ROPlayer(Instigator.Controller).bHudCapturesMouseInputs)
    {
        return false;
    }


	return true;
}

//=============================================================================
// Crawling
//=============================================================================

simulated function bool CanStartCrawlMoving()
{
	if( Instigator.bBipodDeployed || bUsingSights )
		return false;

	return true;
}

simulated event NotifyCrawlMoving()
{
	if( CanStartCrawlMoving() )
	{
		GotoState('StartCrawling');
	}
}

simulated event NotifyStopCrawlMoving()
{
	if( !Instigator.bBipodDeployed && (IsInState('Crawling') || IsInState('StartCrawling')) )
		GotoState('EndCrawling');
}

simulated state StartCrawling extends Busy
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
				if( HasAnim(CrawlForwardAnim) )
					LoopAnim(CrawlForwardAnim, 1.0, 0.2 );
			}
			else
			{
				if( HasAnim(CrawlBackwardAnim) )
					LoopAnim(CrawlBackwardAnim, 1.0, 0.2 );
			}
		}
	}

    simulated function BeginState()
    {
    	PlayStartCrawl();
    	LastStartCrawlingTime = Level.TimeSeconds;
	}
}

simulated function PlayStartCrawl()
{
	local float AnimTimer;

	if( Instigator.IsLocallyControlled() )
	{
		if( HasAnim(CrawlStartAnim) )
			PlayAnim( CrawlStartAnim, 1.0, 0.2 );
	}

    AnimTimer = GetAnimDuration(CrawlStartAnim, 1.0) + 0.2;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
}

simulated state Crawling extends Busy
{
	//ignores PutDown, BringUp;

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

	// catch any missed "stopcrawling" events and stop the crawling
	simulated function Timer()
	{
		if((VSizeSquared(Instigator.Velocity) <= 1.0 && Instigator.Acceleration == vect(0,0,0)) ||
			!Instigator.bIsCrawling)
		{
			NotifyStopCrawlMoving();
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
				if( HasAnim(CrawlForwardAnim) )
					LoopAnim(CrawlForwardAnim, 1.0, 0.2 );
			}
			else
			{
				if( HasAnim(CrawlBackwardAnim) )
					LoopAnim(CrawlBackwardAnim, 1.0, 0.2 );
			}
		}
	}

	simulated function AnimEnd(int channel)
	{
		PlayIdle();		// start the loop anim
    }

    simulated function BeginState()
    {
    	SetTimer(0.1, true);

		CrawlWeaponPitch = 0;
		PlayIdle();
	}
}

simulated state EndCrawling extends Busy
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

	simulated event WeaponTick(float dt)
	{
		local int WeaponPitch;
		local int PositivePitchAdjust;
		local int NegativePitchAdjust;

		// This is only for the visual rotation of the first person weapon client side
		if( Level.NetMode == NM_DedicatedServer )
		{
			return;
		}

	    if( Level.TimeSeconds - LastEndCrawlingTime < 0.15 )
		{
			CrawlWeaponPitch = Instigator.GetViewRotation().Pitch & 65535;
			WeaponPitch =  Rotation.Pitch & 65535;

			if( WeaponPitch != CrawlWeaponPitch )
			{
				if( CrawlWeaponPitch > WeaponPitch )
				{
					PositivePitchAdjust = CrawlWeaponPitch - WeaponPitch;
					NegativePitchAdjust = 65535 - PositivePitchAdjust;
				}
				else
				{
					NegativePitchAdjust = WeaponPitch - CrawlWeaponPitch;
					PositivePitchAdjust = 65535 - NegativePitchAdjust;
				}

				if( PositivePitchAdjust < NegativePitchAdjust )
				{
					WeaponPitch += CrawlPitchTweenRate * dt;

					WeaponPitch =  WeaponPitch & 65535;

					if( WeaponPitch > CrawlWeaponPitch )
					{
						WeaponPitch = CrawlWeaponPitch;
					}
				}
				else
				{
					WeaponPitch -= CrawlPitchTweenRate * dt;

                    WeaponPitch =  WeaponPitch & 65535;

					if( WeaponPitch <  CrawlWeaponPitch)
					{
						WeaponPitch = CrawlWeaponPitch;
					}
				}
			}

			CrawlWeaponPitch = WeaponPitch;
		}
		else
		{
			CrawlWeaponPitch = Instigator.GetViewRotation().Pitch & 65535;
		}
	}

    simulated function Timer()
    {
    	GotoState('Idle');
    }

    simulated function BeginState()
    {
    	LastEndCrawlingTime = Level.TimeSeconds;
		PlayEndCrawl();
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
	local float AnimTimer;

	if( Instigator.IsLocallyControlled() )
	{
		if( HasAnim(CrawlEndAnim) )
			PlayAnim( CrawlEndAnim, 1.0, 0.2 );
	}

    AnimTimer = GetAnimDuration(CrawlEndAnim, 1.0) + 0.2;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
}
//=============================================================================
// Sprinting
//=============================================================================
simulated function SetSprinting(bool bNewSprintStatus)
{
	if( FireMode[1].bMeleeMode && FireMode[1].bIsFiring )
	{
		return;
	}

	if( bNewSprintStatus && !IsInState('WeaponSprinting') && !IsInState('RaisingWeapon') &&
		!IsInState('LoweringWeapon') && ClientState != WS_PutDown && ClientState != WS_Hidden )
	{
		GotoState('StartSprinting');
	}
	else if ( !bNewSprintStatus && IsInState('WeaponSprinting') ||
		IsInState('StartSprinting') )
	{
		GotoState('EndSprinting');
	}
}

simulated state StartSprinting extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool WeaponCanSwitch()
	{
		return false;
	}

    simulated function Timer()
    {
		GotoState('WeaponSprinting');
    }

    simulated function PlayIdle()
    {
		local float LoopSpeed;
		local float Speed2d;

		if( Instigator.IsLocallyControlled() )
		{
			// Make the sprinting animation match the sprinting speed
	        LoopSpeed=1.5;

			Speed2d = VSize(Instigator.Velocity);
			LoopSpeed = ((Speed2d/(Instigator.Default.GroundSpeed * Instigator.SprintPct))*1.5);

			if( HasAnim(SprintLoopAnim) )
				LoopAnim(SprintLoopAnim, LoopSpeed, 0.2 );
		}
	}


    simulated function BeginState()
    {
    	PlayStartSprint();
	}
}

simulated function PlayStartSprint()
{
	local float AnimTimer;

	if( Instigator.IsLocallyControlled() )
	{
		if( HasAnim(SprintStartAnim) )
			PlayAnim( SprintStartAnim, 1.5, 0.2 );
	}

    AnimTimer = GetAnimDuration(SprintStartAnim, 1.5) + 0.2;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
}


simulated state WeaponSprinting// extends Busy
{
	ignores PutDown, BringUp;

	simulated event ClientStartFire(int Mode)
	{
	    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
	        return;

		if( !FireMode[Mode].bMeleeMode )
		{
			return;
		}

	    if (Role < ROLE_Authority)
	    {
	        if (StartFire(Mode))
	        {
	            ServerStartFire(Mode);
	        }
	    }
	    else
	    {
	        StartFire(Mode);
	    }
	}

	simulated function bool ReadyToFire(int Mode)
	{
		if( FireMode[Mode].bMeleeMode )
		{
			return global.ReadyToFire(Mode);
		}

		return false;
	}

	simulated function bool IsBusy()
	{
		return true;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function Timer()
	{
		if( !Instigator.bIsSprinting )
		{
			SetSprinting(false);
		}
	}

    simulated function PlayIdle()
    {
		local float LoopSpeed;
		local float Speed2d;

		if( Instigator.IsLocallyControlled() )
		{
			// Make the sprinting animation match the sprinting speed
	        LoopSpeed=1.5;

			Speed2d = VSize(Instigator.Velocity);
			LoopSpeed = ((Speed2d/(Instigator.Default.GroundSpeed * Instigator.SprintPct))*1.5);

			if( HasAnim(SprintLoopAnim) )
	    		LoopAnim( SprintLoopAnim, LoopSpeed, 0.2);
		}
	}

	simulated function AnimEnd(int channel)
	{
		PlayIdle();		// start the loop anim
    }

    simulated function BeginState()
    {
    	PlayIdle();
    	SetTimer(0.1, true);
	}
}

simulated state EndSprinting extends Busy
{
	simulated function bool ReadyToFire(int Mode)
	{
		return false;
	}

	simulated function bool ShouldUseFreeAim()
	{
		return false;
	}

	simulated function bool WeaponCanSwitch()
	{
		return false;
	}

    simulated function Timer()
    {
		GotoState('Idle');
    }

    simulated function BeginState()
    {
    	PlayEndSprint();
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
	local float AnimTimer;

	if( Instigator.IsLocallyControlled() )
	{
		if( HasAnim(SprintEndAnim) )
			PlayAnim( SprintEndAnim, 1.5, 0.2 );
	}

    AnimTimer = GetAnimDuration(SprintEndAnim, 1.5) + 0.2;

	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
}


//=============================================================================
// UT Functions overloaded for RO
//=============================================================================

// Overloaded to allow switching to weapons that don't have any ammo
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( (CurrentChoice == None) )
    {
        if ( CurrentWeapon != self )
            CurrentChoice = self;
    }
    else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
    {
        if ( (GroupOffset < CurrentWeapon.GroupOffset)
            && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset > CurrentChoice.GroupOffset)) )
            CurrentChoice = self;
	}
    else if ( InventoryGroup == CurrentChoice.InventoryGroup )
    {
        if ( GroupOffset > CurrentChoice.GroupOffset )
            CurrentChoice = self;
    }
    else if ( InventoryGroup > CurrentChoice.InventoryGroup )
    {
		if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
            || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
    }
    else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
            && (InventoryGroup < CurrentWeapon.InventoryGroup) )
        CurrentChoice = self;

    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

// Overloaded to allow switching to weapons that don't have any ammo
simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( (CurrentChoice == None) )
    {
        if ( CurrentWeapon != self )
            CurrentChoice = self;
    }
    else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
    {
        if ( (GroupOffset > CurrentWeapon.GroupOffset)
            && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset < CurrentChoice.GroupOffset)) )
            CurrentChoice = self;
    }
    else if ( InventoryGroup == CurrentChoice.InventoryGroup )
    {
		if ( GroupOffset < CurrentChoice.GroupOffset )
            CurrentChoice = self;
    }

    else if ( InventoryGroup < CurrentChoice.InventoryGroup )
    {
        if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
            || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
    }
    else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
            && (InventoryGroup > CurrentWeapon.InventoryGroup) )
        CurrentChoice = self;

    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

// Overloaded to allow switching to weapons that don't have any ammo
simulated function Weapon WeaponChange( byte F, bool bSilent )
{

    if ( InventoryGroup == F )
    {
        return self;
    }
    else if ( Inventory == None )
        return None;
    else
        return Inventory.WeaponChange(F,bSilent);
}

// Overloaded to allow throwing out weapons that don't have any ammo
simulated function bool CanThrow()
{
	local int Mode;

    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
        if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
            return false;
        if ( FireMode[Mode].NextFireTime > Level.TimeSeconds)
			return false;
    }
    return (bCanThrow && (ClientState == WS_ReadyToFire || (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)));
}

function DropFrom(vector StartLocation)
{
    local int m;
	local Pickup Pickup;

    if (!bCanThrow )
        return;

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

    Destroy();
}

simulated function ClientWeaponThrown()
{
    local int m;

    AmbientSound = None;

	if (ROWeaponAttachment(ThirdPersonActor) != None)
	{
		ROWeaponAttachment(ThirdPersonActor).AmbientSound = None;
	}

/*	if( Level.NetMode == NM_StandAlone && bPlayerViewIsZoomed )
	{
    	PlayerViewZoom();
    }*/

    if( Level.NetMode != NM_Client )
        return;

    Instigator.DeleteInventory(self);
    // reset the player FOV if this is a sniper weapon and getting thrown away

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if(Ammo[m] != none)
           	Instigator.DeleteInventory(Ammo[m]);
    }
}

// Don't autoswitch when we run out of ammo
simulated function OutOfAmmo()
{
	if( !HasAmmo() )
	{
		if( ROWeaponAttachment(ThirdPersonActor) != none )
		{
			ROWeaponAttachment(ThirdPersonActor).bOutOfAmmo = true;
		}
	}

	if ( !Instigator.IsLocallyControlled() || HasAmmo() )
    	return;
}

//Pseudohack to signify if this weapon is a grenade
function bool IsGrenade()
{
    return false;
}

defaultproperties
{
     SprintStartAnim="Sprint_Start"
     SprintLoopAnim="Sprint_Middle"
     SprintEndAnim="Sprint_end"
     CrawlPitchTweenRate=60000
     SleeveNum=1
     FreeAimRotationSpeed=8.000000
     bCanSway=True
}
