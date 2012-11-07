//=============================================================================
// ROVehicleHitEffect
//=============================================================================
// Hit effect for bullets hitting a vehicle
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================
// TODO: This should probably just be some type of emitter

class ROVehicleHitEffect extends Effects;

/*#exec OBJ LOAD FILE=ProjectileSounds.uax


//=============================================================================
// Variables
//=============================================================================

var	sound		HitSound;

//=============================================================================
// Functions
//=============================================================================


simulated function InitHitEffects(vector HitLoc, vector HitNormal)
{
	PlaySound(HitSound, SLOT_None, 3.0, false, 100.0);

	Spawn(class'ROBulletHitMetalArmorEffect',,, HitLoc, rotator(HitNormal));
}


//=============================================================================
// defaultproperties
//=============================================================================
*/

defaultproperties
{
}
