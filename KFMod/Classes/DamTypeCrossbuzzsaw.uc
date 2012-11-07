class DamTypeCrossbuzzsaw extends KFProjectileWeaponDamageType;

 static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if ( KFStatsAndAchievements != none )
	{
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
     HeadShotDamageMult=1.000000
     bIsMeleeDamage=True
     WeaponClass=Class'KFMod.Crossbuzzsaw'
     bThrowRagdoll=True
     bRagdollBullet=True
     DamageThreshold=1
     KDamageImpulse=7500.000000
     KDeathVel=250.000000
     KDeathUpKick=25.000000
}
