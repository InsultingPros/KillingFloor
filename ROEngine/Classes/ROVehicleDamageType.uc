class ROVehicleDamageType extends WeaponDamageType//DamageType
	abstract;

//=============================================================================
// Variables
//=============================================================================

var	Material	HUDIcon;
var float TankDamageModifier;   // Tank damage
var float APCDamageModifier;    // HT type vehicle damage
var float VehicleDamageModifier;// Standard vehicle damage
var float TreadDamageModifier;   // Tank damage


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.Generic'
     APCDamageModifier=0.025000
     VehicleDamageModifier=0.050000
     bKUseOwnDeathVel=True
}
