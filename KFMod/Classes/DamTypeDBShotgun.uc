class DamTypeDBShotgun extends DamTypeShotgun
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( KFStatsAndAchievements!=None )
		KFStatsAndAchievements.AddHuntingShotgunKill();
}

defaultproperties
{
     WeaponClass=Class'KFMod.Crossbuzzsaw'
}
