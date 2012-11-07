//=============================================================================
// ROGrenadeDamType
//=============================================================================
//
// Damage Type for Grenades.
//
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 John "Ramm-Jaeger" Gibson
//=============================================================================


class ROGrenadeDamType extends ROWeaponDamageType
	abstract;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     APCDamageModifier=0.200000
     VehicleDamageModifier=0.500000
     DeathString="%o was torn apart by %k's grenade."
     FemaleSuicide="%o was careless with her own grenade."
     MaleSuicide="%o was careless with his own grenade."
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bExtraMomentumZ=True
     GibModifier=1.500000
     KDamageImpulse=2000.000000
     KDeathVel=120.000000
     KDeathUpKick=30.000000
     KDeadLinZVelScale=0.005000
     KDeadAngVelScale=0.003600
}
