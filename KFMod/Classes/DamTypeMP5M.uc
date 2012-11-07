//=============================================================================
// DamTypeMP5M
//=============================================================================
// Damage type for the MP5 medic gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeMP5M extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.MP5MMedicGun'
     DeathString="%k killed %o (MP5M)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=750.000000
     KDeathVel=100.000000
     KDeathUpKick=1.000000
}
