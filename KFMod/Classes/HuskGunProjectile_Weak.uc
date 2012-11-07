//=============================================================================                                                                                                                      //=============================================================================
// HuskGunProjectile_Weak
//=============================================================================
// Fireball projectile for the Husk zombie, weaker effects
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunProjectile_Weak extends HuskGunProjectile;

defaultproperties
{
     ExplosionEmitter=Class'KFMod.FlameImpact_Weak'
     FlameTrailEmitterClass=Class'KFMod.FlameThrowerHusk_Weak'
     ExplosionSoundVolume=1.250000
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Small'
}
