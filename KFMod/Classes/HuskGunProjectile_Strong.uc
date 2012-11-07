//=============================================================================                                                                                                                      //=============================================================================
// HuskGunProjectile_Strong
//=============================================================================
// Fireball projectile for the Husk zombie, stronger effects
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunProjectile_Strong extends HuskGunProjectile;

defaultproperties
{
     ExplosionEmitter=Class'KFMod.FlameImpact_Strong'
     FlameTrailEmitterClass=Class'KFMod.FlameThrowerHusk_Strong'
     ExplosionSoundVolume=2.000000
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Large'
}
