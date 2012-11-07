//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DamTypeUnWeld extends WeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFMod.Welder'
     DeathString="ÿ%k welded %o (Welder)."
     FemaleSuicide="%o was welded."
     MaleSuicide="%o was welded."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.800000
}
