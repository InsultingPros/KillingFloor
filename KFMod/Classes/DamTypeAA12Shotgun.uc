class DamTypeAA12Shotgun extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     bIsPowerWeapon=True
     WeaponClass=Class'KFMod.AA12AutoShotgun'
     DeathString="%k killed %o (AA12 Shotgun)."
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
