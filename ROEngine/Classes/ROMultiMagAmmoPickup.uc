//=============================================================================
// ROMultiMagAmmoPickup
//=============================================================================
// Base class for weapon ammunition pickups that represent multiple magazines
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROMultiMagAmmoPickup extends ROAmmoPickup
	abstract;

//=============================================================================
// Variables
//=============================================================================
var 		array<int>		AmmoMags;		// The array of magazines and thier ammo amounts this pickup has

defaultproperties
{
}
