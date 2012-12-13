//=============================================================================
// DamTypeDwarfAxe
//=============================================================================
// Dwarf Axe damage type class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeDwarfAxe extends DamTypeMelee;

defaultproperties
{
     HeadShotDamageMult=1.100000
     WeaponClass=Class'KFMod.DwarfAxe'
     bExtraMomentumZ=True
     PawnDamageSounds(0)=Sound'KFPawnDamageSound.MeleeDamageSounds.axehitflesh'
     KDamageImpulse=25000.000000
     KDeathVel=300.000000
     KDeathUpKick=350.000000
     VehicleDamageScaling=0.500000
}
