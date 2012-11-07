//=============================================================================
// DamTypeM7A3M
//=============================================================================
// Damage type for the M7A3 primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC Development
//=============================================================================
class DamTypeM7A3M extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.M7A3MMedicGun'
     DeathString="%k killed %o (M7A3)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=890.000000
     KDeathVel=185.000000
     KDeathUpKick=4.000000
}
