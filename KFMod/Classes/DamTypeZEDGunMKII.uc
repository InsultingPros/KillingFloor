//=============================================================================
// DamTypeZEDGunMKII
//=============================================================================
// Damage class for the ZEDGun MKII
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeZEDGunMKII extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.ZEDMKIIWeapon'
     DeathString="%k killed %o (ZED MKII)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=10000.000000
     KDeathVel=300.000000
     KDeathUpKick=100.000000
     VehicleDamageScaling=0.700000
}
