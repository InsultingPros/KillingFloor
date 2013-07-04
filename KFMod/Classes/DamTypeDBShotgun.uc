class DamTypeDBShotgun extends DamTypeShotgun
	abstract;


static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
 	super.AwardDamage(KFStatsAndAchievements, Amount);

	if( KFStatsAndAchievements != None )
	{
		KFStatsAndAchievements.CheckAndSetAchievementComplete( KFStatsAndAchievements.KFACHIEVEMENT_PushScrakeSPJ );
	}
}
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( KFStatsAndAchievements!=None )
		KFStatsAndAchievements.AddHuntingShotgunKill();
}

defaultproperties
{
     WeaponClass=Class'KFMod.Crossbuzzsaw'
}
