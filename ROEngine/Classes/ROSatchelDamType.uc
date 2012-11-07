//=============================================================================
// ROSatchelDamType
//=============================================================================
// Satchel Charge.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROSatchelDamType extends ROWeaponDamageType
	abstract;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.satchel'
     TankDamageModifier=1.000000
     APCDamageModifier=1.000000
     VehicleDamageModifier=1.000000
     TreadDamageModifier=1.000000
     DeathString="%o was blown up by %k's satchel charge."
     FemaleSuicide="%o was careless with her own satchel charge."
     MaleSuicide="%o was careless with his own satchel charge."
     bArmorStops=False
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bExtraMomentumZ=True
     GibModifier=4.000000
     DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
     DeathOverlayTime=999.000000
     KDamageImpulse=5000.000000
     KDeathVel=300.000000
     KDeathUpKick=75.000000
     KDeadLinZVelScale=0.001500
     KDeadAngVelScale=0.001500
     HumanObliterationThreshhold=400
}
