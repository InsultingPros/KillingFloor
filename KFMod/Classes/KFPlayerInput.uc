//=============================================================================
// KFPlayerInput
//=============================================================================
// Object within KFPlayerController that manages player input
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFPlayerInput extends PlayerInput within KFPlayerController
	config(User);

// Postprocess the player's input.
event PlayerInput( float DeltaTime )
{
	local float FOVScale, MouseScale;

	// Ignore input if we're playing back a client-side demo.
	if( Outer.bDemoOwner && !Outer.default.bDemoOwner )
		return;

	// Check for Double click move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe < 0));
	bEdgeRight = (bWasRight ^^ (aStrafe > 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe < 0);
	bWasRight = (aStrafe > 0);

	// Modify mouse sensitivity based on the scope - Ramm
	if( Outer.GetMouseModifier() < 0 )
	{
	    FOVScale = DesiredFOV * 0.01111; // 0.01111 = 1/90
	}
	else
	{
	    FOVScale = Outer.GetMouseModifier() * 0.01111; // 0.01111 = 1/90
	}

	// Smooth and amplify mouse movement
	MouseScale = MouseSensitivity * FOVScale;
	aMouseX = SmoothMouse(aMouseX*MouseScale, DeltaTime,bXAxis,0);
	aMouseY = SmoothMouse(aMouseY*MouseScale, DeltaTime,bYAxis,1);

	aMouseX = AccelerateMouse(aMouseX);
	aMouseY = AccelerateMouse(aMouseY);

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 ) // strafe
		aStrafe += aBaseX * 7.5 + aMouseX;
	else // forward
		aTurn  += aBaseX * FOVScale + aMouseX;
	aBaseX = 0;

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= aMouseY;
		else
			aLookUp += aMouseY;
	}
	else // Move forward/backward.
		aForward += aMouseY;

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

defaultproperties
{
}
