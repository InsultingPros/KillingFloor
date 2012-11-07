//=============================================================================
// ROBipodWeapon
//=============================================================================
// Base Class for weapons that use bipods. Still contains a lot of Ant's
// legacy MG bipod code. Clear that up as you have time.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROBipodWeapon extends ROProjectileWeapon
	abstract;

//=============================================================================
// Variables
//=============================================================================

// Animations for bipod mounted weapon hipped and deployed states
var		name		  	IdleToBipodDeploy;			// anim for bipod rest state to deployed state
var		name		  	BipodDeployToIdle;       	// anim for bipod deployed state to rest state
var		name		  	BipodIdleToHip;		        // anim for bipod rest state to hip state
var		name		  	BipodHipToIdle;           	// anim for bipod hip state to rest state
var		name		  	BipodHipIdle;             	// anim for idle bipod hip state
var		name		  	BipodHipToDeploy;         	// anim for bipod hip state to deployed state
var		name		  	BipodDeployToHip;         	// anim for bipod deployed state to hip state

var		name		  	IdleToBipodDeployEmpty;		// anim for bipod rest state to deployed empty state
var		name		  	BipodDeployToIdleEmpty;   	// anim for bipod deployed state to rest empty state

//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (Role < ROLE_Authority)
		ServerBipodDeploy;
}

simulated function Fire(float F)
{
    if ( Instigator != none )
    {
       if ( !(bUsingSights || Instigator.bBipodDeployed)
            && Instigator.Controller != none
            && PlayerController(Instigator.Controller) != none)
          class'ROBipodWarningMsg'.Static.ClientReceive(PlayerController(Instigator.Controller),0);
       else
           super.Fire(F);
    }
    else
    {
        super.Fire(F);
    }
}

simulated function NotifyOwnerJumped()
{
	if( !Instigator.bBipodDeployed )
	{
		super.NotifyOwnerJumped();
	}
	else if( !IsBusy() || IsInState('DeployingBipod') )
	{
		if( Instigator.bBipodDeployed )
		{
			BipodDeploy(false);

			if( Role < ROLE_Authority)
				ServerBipodDeploy(false);
		}
	}
}

// Switch deployment status
simulated exec function Deploy()
{
	if( IsBusy() )
		return;

	if( Instigator.bBipodDeployed )
	{
		BipodDeploy(false);

		if( Role < ROLE_Authority)
			ServerBipodDeploy(false);
	}
	else if( Instigator.bCanBipodDeploy )
	{
		BipodDeploy(true);

		if( Role < ROLE_Authority)
			ServerBipodDeploy(true);
	}
}

// Forces the bipod to undeploy when needed
simulated function ForceUndeploy()
{
	if( IsBusy() )
		return;

	if( Instigator.bBipodDeployed )
	{
		BipodDeploy(false);

		if( Role < ROLE_Authority)
			ServerBipodDeploy(false);
	}
}

// Called by the client on the server
simulated function BipodDeploy( bool bNewDeployedStatus )
{
	ROPawn(Instigator).SetBipodDeployed( bNewDeployedStatus );

	if( bNewDeployedStatus )
	{
	 	GotoState('DeployingBipod');
	}
	else
	{
		GotoState('UnDeployingBipod');
	}
}

function ServerBipodDeploy( bool bNewDeployedStatus )
{
	if( Instigator.bCanBipodDeploy )
		BipodDeploy( bNewDeployedStatus );
}

simulated state DeployingBipod extends Busy
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

    simulated function Timer()
    {
    	GotoState('Idle');
    }

    simulated function BeginState()
    {
		local name Anim;
		local float AnimTimer;

		if( bUsingSights )
	    {
	    	Anim = BipodHipToDeploy;
		}
		else if( AmmoAmount(0) < 1 && HasAnim(IdleToBipodDeployEmpty) )
		{
			Anim = IdleToBipodDeployEmpty;
		}
		else
		{
			Anim = IdleToBipodDeploy;
		}

		if( Instigator.IsLocallyControlled() )
		{
	    	PlayAnim(Anim, IronSwitchAnimRate, FastTweenTime );
		}

	    AnimTimer = GetAnimDuration(Anim, IronSwitchAnimRate) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.1),false);
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
	if( bUsingSights )
    {
		if( Role == ROLE_Authority)
			ServerZoomOut(false);
		else
			ZoomOut(False);
	}

	if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
	{
		// Later this will be a latent function to zoom
		SmoothZoom(true);
		//DisplayFOV = IronSightDisplayFOV;
	}
}

simulated state UndeployingBipod extends Busy
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

    simulated function Timer()
    {
    	GotoState('Idle');
    }

    simulated function BeginState()
    {
		local name Anim;
		local float AnimTimer;

		if( AmmoAmount(0) < 1 && HasAnim(BipodDeployToIdleEmpty) )
		{
			Anim = BipodDeployToIdleEmpty;
		}
		else
		{
			Anim = BipodDeployToIdle;
		}

		if( Instigator.IsLocallyControlled() )
		{
	    	PlayAnim(Anim, IronSwitchAnimRate, FastTweenTime );
		}

	    AnimTimer = GetAnimDuration(Anim, IronSwitchAnimRate) + FastTweenTime;

		if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
			SetTimer(AnimTimer - (AnimTimer * 0.1),false);
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
		SmoothZoom(false);
		//DisplayFOV = default.DisplayFOV;
	}
}

simulated function PlayIdle()
{
	if( Instigator.bBipodDeployed )
    {
        LoopAnim(IronIdleAnim, IdleAnimRate, 0.2 );
    }
	else if( bUsingSights )
    {
        LoopAnim(BipodHipIdle, IdleAnimRate, 0.2 );
    }
	else
    {
        LoopAnim(IdleAnim, IdleAnimRate, 0.2 );
    }
}

//=============================================================================
// Rendering
//=============================================================================
// Don't need to do the special rendering for bipod weapons since they won't
// really sway while deployed
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

//=============================================================================
// Reloading/Ammunition
//=============================================================================
simulated function bool AllowReload()
{
    if( !Instigator.bBipodDeployed
        && Instigator.Controller != none
        && PlayerController(Instigator.Controller) != none)
          class'ROBipodWarningMsg'.Static.ClientReceive(PlayerController(Instigator.Controller),1);

    if( IsFiring() || IsBusy() || !Instigator.bBipodDeployed)
		return false;

	// Can't reload if we don't have a mag to put in
	if( CurrentMagCount	< 1)
		return false;

    return true;
}

// Overriden to support bipod weapon firing functionality
simulated function bool ReadyToFire(int Mode)
{
    if( !bUsingSights && !Instigator.bBipodDeployed )
        return false;

	return super.ReadyToFire(Mode);
}

simulated state Reloading
{
	simulated function bool WeaponAllowProneChange()
	{
		return false;
	}

	simulated function bool WeaponAllowCrouchChange()
	{
		return false;
	}

    simulated function EndState()
    {
		super.EndState();
		if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	    {
	    	DisplayFOV = IronSightDisplayFOV;
	    }
    }
// Take the player out of zoom and then zoom them back in
Begin:
	if( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
    {
		if( DisplayFOV != default.DisplayFOV )
		{
		 	SmoothZoom(false);
		}

		if( AmmoAmount(0) < 1 && HasAnim(MagEmptyReloadAnim))
		{
			Sleep(((GetAnimDuration(MagEmptyReloadAnim, 1.0)) * 1.0) - (default.ZoomInTime + default.ZoomOutTime));
		}
		else
		{
			Sleep(((GetAnimDuration(MagPartialReloadAnim, 1.0)) * 1.0) - (default.ZoomInTime + default.ZoomOutTime));
		}

		SmoothZoom(true);
	}
}

// Client gets sent to this state when the client has requested an action
// that needs verified by the server. Once the server verifies they
// can start the action, the server will take the client out of this state
simulated state PendingAction
{
 	simulated function bool WeaponAllowProneChange()
	{
		return false;
	}

	simulated function bool WeaponAllowCrouchChange()
	{
		return false;
	}
}

//=============================================================================
// Sprinting
//=============================================================================
simulated state StartSprinting
{
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
	else if ( DisplayFOV != default.DisplayFOV && Instigator.IsLocallyControlled() )
	{
		SmoothZoom(false);
	}
}

simulated state StartCrawling
{
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
	else if ( DisplayFOV != default.DisplayFOV && Instigator.IsLocallyControlled() )
	{
		SmoothZoom(false);
	}
}

//=============================================================================
// Default Properties
//=============================================================================

defaultproperties
{
     Priority=10
     bCanBipodDeploy=True
}
