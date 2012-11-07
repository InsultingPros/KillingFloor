class DamTypeFNFALAssaultRifle extends KFProjectileWeaponDamageType
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( Killed.IsA('ZombieStalker') )
		KFStatsAndAchievements.AddStalkerKill();
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
}

defaultproperties
{
     WeaponClass=Class'KFMod.FNFAL_ACOG_AssaultRifle'
     DeathString="%k killed %o (FNFAL)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=6500.000000
     KDeathVel=175.000000
     KDeathUpKick=20.000000
}
