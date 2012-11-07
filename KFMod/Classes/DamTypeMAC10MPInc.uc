class DamTypeMAC10MPInc extends KFProjectileWeaponDamageType
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
	KFStatsAndAchievements.AddMac10BurnDamage(Amount);
}

defaultproperties
{
     bDealBurningDamage=True
     WeaponClass=Class'KFMod.MAC10MP'
     DeathString="%k killed %o (MAC-10)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=1850.000000
     KDeathVel=150.000000
     KDeathUpKick=5.000000
}
