class DamTypeMelee extends KFWeaponDamageType
	abstract;

defaultproperties
{
     HeadShotDamageMult=1.250000
     bIsMeleeDamage=True
     WeaponClass=Class'KFMod.KFMeleeGun'
     DeathString="%o was beat down by %k."
     FemaleSuicide="%o beat herself down."
     MaleSuicide="%o beat himself down."
     bRagdollBullet=True
     bBulletHit=True
     PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
     LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
     LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
     FlashFog=(X=600.000000)
     KDamageImpulse=2000.000000
     KDeathVel=100.000000
     KDeathUpKick=25.000000
     VehicleDamageScaling=0.600000
}
