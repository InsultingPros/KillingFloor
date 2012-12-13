//=============================================================================
// BaseKFWeapon
//=============================================================================
// Base class for Killing Floor weapon functionality that needs native code.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class BaseKFWeapon extends Weapon
	native
	abstract;

/*********************************************************************************************
 Zooming
********************************************************************************************* */

// Ironsights
var(Zooming)	float		PlayerIronSightFOV; 	// The fov to use for this weapon when in ironsights
var				bool		bZoomingIn;				// We are transitioning to zoomed in. When set to true native code will attempt to interpolate to the zoomed in ironsight position
var				bool		bZoomingOut;			// We are transitioning to zoomed out. When set to true native code will attempt to interpolate to the zoomed out ironsight position
var(Zooming)	float		ZoomTime;				// How long the transition to/from iron sights should take
var(Zooming)	rotator		ZoomInRotation;			// Amount to rotate to when zooming in to give the feeling of an animation playing
var				rotator		ZoomRotInterp;			// Set by the native code when zooming in/out. This is the interpolated rotation over time of the value set in ZoomInRotation
var				vector		ZoomStartOffset;		// When we start zooming what player view location is the first person weapon in. Used by the native code to calculate where to start zooming from
var				bool		bZoomInInterrupted;		// We were zooming in and it was interrupted. Used by the native code to handle smooth interpolations between zoomed positions
var				bool		bZoomOutInterrupted;	// We were zooming out and it was interrupted. Used by the native code to handle smooth interpolations between zoomed positions
var				float		ZoomPartialTime;		// How much time we have to finish a partial zoom out. Used by the native code to handle smooth interpolations between zoomed positions
var				rotator		ZoomRotStartOffset; 	// When we start zooming what rotation offset is the weapon. Used by the native code to handle smooth interpolations between zoomed positions
var				float		LastZoomOutTime;		// The last time we zoomed out. Used by the native code to determine if we can go to shouldered.
var(Zooming)	float		FastZoomOutTime;		// How long to take to zoom out when we're doing a fast zoom out (i.e. when an action like reloading interupts ironsights)
var             bool        bFastZoomOut;           // The weapon is doing a fast zoom out without animating, and won't get ZoomStart/End Notifies
var             float       ZoomStartDisplayFOV;    // What is the DisplayFOV when we start zooming
var(Zooming)    float       ZoomedDisplayFOV;       // What is the DisplayFOV when zoomed in

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
	reliable if(Role < ROLE_Authority)
		ServerZoomIn,ServerZoomOut;
}

/**
 * Handles the logic of which zoom functions to call based on if
 * we are a client or a server
 *
 * @param bZoomStatus which direction we are zooming
 */
simulated function PerformZoom(bool bZoomStatus)
{
	if( bZoomStatus )
	{
        if( Owner != none && Owner.Physics == PHYS_Falling &&
            Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            return;
        }

		ZoomIn(true);

		if( Role < ROLE_Authority)
			ServerZoomIn(false);
	}
	else
	{
		ZoomOut(true);

		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
}

/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
	if( bAnimateTransition )
	{
		// If the zoom out was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingOut )
		{
			bZoomingOut=false;
			// Flag so the native code knows the zoom was interupted
			bZoomOutInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming out
			ZoomTime=default.ZoomTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
			ZoomStartDisplayFOV=DisplayFOV;
		}
		else
		{
			ZoomTime=default.ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomStartDisplayFOV=DisplayFOV;
		}
		bZoomingIn=true;
	}
}

/**
 * Handles calling the zoom in function on the server
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
function ServerZoomIn(bool bAnimateTransition)
{
	ZoomIn(bAnimateTransition);
}

/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
	if( bAnimateTransition )
	{
		// If the zoom in was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingIn )
		{
			bZoomingIn=false;
			// Flag so the native code knows the zoom was interupted
			bZoomInInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming in
			ZoomTime=default.ZoomTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
			ZoomStartDisplayFOV=DisplayFOV;
		}
		else
		{
			ZoomTime=default.ZoomTime;
		}
		bZoomingOut=true;
	}
	else
	{
        // do a fast zoomout with no notifies
        bFastZoomOut = true;

		// If the zoom in was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingIn )
		{
			bZoomingIn=false;
			// Flag so the native code knows the zoom was interupted
			bZoomInInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming in
			ZoomTime=default.ZoomTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
			ZoomStartDisplayFOV=DisplayFOV;
		}
		else
		{
			ZoomTime=FastZoomOutTime;
		}
		bZoomingOut=true;

		LastZoomOutTime=Level.TimeSeconds+ZoomTime;
	}
}

/**
 * Handles calling the zoom out function on the server
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
function ServerZoomOut(bool bAnimateTransition)
{
	ZoomOut(bAnimateTransition);
}


/**
 * Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
 */
simulated event OnZoomInFinished(){}

/**
 * Called by the native code when the interpolation of the first person weapon from the zoomed position finishes
 */
simulated event OnZoomOutFinished(){}

defaultproperties
{
     PlayerIronSightFOV=75.000000
     ZoomTime=0.250000
     ZoomInRotation=(Pitch=-910,Roll=2910)
     FastZoomOutTime=0.200000
     ZoomedDisplayFOV=75.000000
}
