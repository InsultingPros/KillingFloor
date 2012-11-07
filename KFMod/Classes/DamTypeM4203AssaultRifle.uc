//=============================================================================
// DamTypeM4203AssaultRifle
//=============================================================================
// Damage type for the M4 with M203 launcher assault rifle primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeM4203AssaultRifle extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.M4203AssaultRifle'
     DeathString="%k killed %o (M4 203)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=1500.000000
     KDeathVel=110.000000
     KDeathUpKick=2.000000
}
