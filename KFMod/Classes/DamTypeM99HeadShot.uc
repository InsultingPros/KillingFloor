class DamTypeM99HeadShot extends DamTypeM99SniperRifle
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if ( KFStatsAndAchievements != none )
	{
		if ( Killed.IsA('ZombieScrake'))
		{
			KFStatsAndAchievements.AddM99Kill();
		}
		if (Killed.IsA('ZombieHusk'))
		{
			KFStatsAndAchievements.AddHuskAndZedOneShotKill(true, false);
		}
		else
		{
        	KFStatsAndAchievements.AddHuskAndZedOneShotKill(false, true);
		}
	}
}

defaultproperties
{
     bBulletHit=True
     FlashFog=(X=600.000000)
     VehicleDamageScaling=0.650000
}
