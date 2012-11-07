//=============================================================================
// ROMineDamType
//=============================================================================
// Damage type
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROMineDamType extends ROWeaponDamageType
	abstract;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.mine'
     TankDamageModifier=1.000000
     APCDamageModifier=1.000000
     VehicleDamageModifier=1.100000
     TreadDamageModifier=1.000000
     DeathString="%o was killed by a mine."
     FemaleSuicide="%o was killed by a mine."
     MaleSuicide="%o was killed by a mine."
     bArmorStops=False
     bLocationalHit=False
     KDeathUpKick=100.000000
}
