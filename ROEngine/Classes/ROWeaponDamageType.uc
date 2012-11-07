//=============================================================================
// ROWeaponDamageType
//=============================================================================
// Adds HUD icons.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROWeaponDamageType extends WeaponDamageType
	abstract;

//=============================================================================
// Variables
//=============================================================================

var	Material	HUDIcon;
var float TankDamageModifier;   // Tank damage
var float APCDamageModifier;    // HT type vehicle damage
var float VehicleDamageModifier;// Standard vehicle damage
var float TreadDamageModifier;   // Tank damage
var bool bCauseViewJarring; // Causes the player to be 'struck' and shake


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.Generic'
     VehicleDamageModifier=0.100000
     bKUseOwnDeathVel=True
     bExtraMomentumZ=False
}
