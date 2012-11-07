//=============================================================================
// ROArtilleryDamType
//=============================================================================
//
// Damage Type for Artillery.
//
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 John "Ramm-Jaeger" Gibson
//=============================================================================


class ROArtilleryDamType extends ROWeaponDamageType
	abstract;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.artkill'
     TankDamageModifier=1.000000
     APCDamageModifier=1.000000
     VehicleDamageModifier=1.000000
     DeathString="%o was torn apart by an artillery shell."
     FemaleSuicide="%o was careless with her own artillery shell."
     MaleSuicide="%o was careless with his own artillery shell."
     bArmorStops=False
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bExtraMomentumZ=True
     bFlaming=True
     GibModifier=10.000000
     DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
     DeathOverlayTime=999.000000
     GibPerterbation=0.150000
     KDamageImpulse=7000.000000
     KDeathVel=350.000000
     KDeathUpKick=600.000000
     KDeadLinZVelScale=0.000250
     KDeadAngVelScale=0.002000
     VehicleMomentumScaling=1.300000
     HumanObliterationThreshhold=300
}
