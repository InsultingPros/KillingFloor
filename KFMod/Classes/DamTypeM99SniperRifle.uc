//=============================================================================
// DamTypeM99SniperRifle
//=============================================================================
// M99 Sniper Rifle damage class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class DamTypeM99SniperRifle extends KFProjectileWeaponDamageType;

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
     HeadShotDamageMult=1.000000
     bSniperWeapon=True
     WeaponClass=Class'KFMod.M99SniperRifle'
     DeathString="%k put a bullet in %o's head."
     FemaleSuicide="%o shot herself in the head."
     MaleSuicide="%o shot himself in the head."
     bThrowRagdoll=True
     bRagdollBullet=True
     DamageThreshold=1
     KDamageImpulse=10000.000000
     KDeathVel=300.000000
     KDeathUpKick=100.000000
}
