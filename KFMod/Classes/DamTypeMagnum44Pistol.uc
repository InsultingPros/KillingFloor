//=============================================================================
// DamTypeM4AssaultRifle
//=============================================================================
// Damage type for the M4 assault rifle primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeMagnum44Pistol extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     bSniperWeapon=True
     WeaponClass=Class'KFMod.Magnum44Pistol'
     DeathString="%k killed %o (44 Magnum)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=3500.000000
     KDeathVel=175.000000
     KDeathUpKick=15.000000
     VehicleDamageScaling=0.800000
}
