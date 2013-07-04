//=============================================================================
// DamTypeKrissM
//=============================================================================
// Damage type for the Kriss medic gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeKrissM extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.KrissMMedicGun'
     DeathString="%k killed %o (Schneidzekk)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=5500.000000
     KDeathVel=175.000000
     KDeathUpKick=15.000000
}
