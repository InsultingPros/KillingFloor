// Gib Pert. fix.
class KFWeaponDamageType extends WeaponDamageType;

var()   float	HeadShotDamageMult;
var	    bool	bIsPowerWeapon,
			    bIsMeleeDamage,
			    bSniperWeapon;
var     bool    bIsExplosive;   // This weapon does explosive damage
var		bool	bDealBurningDamage; // This weapon does burning damage

var()   bool    bCheckForHeadShots;     // This damagetype is capabable of removing heads with headshots (doesn't mean it can't blow heads off, just means it shouldn't do headshot check if this is false);

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed );

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	if ( Default.bIsMeleeDamage )
		KFStatsAndAchievements.AddMeleeDamage(Amount);
	else if ( Default.bIsPowerWeapon )
		KFStatsAndAchievements.AddShotgunDamage(Amount);

	if( Default.bIsExplosive )
    {
        KFStatsAndAchievements.AddExplosivesDamage(Amount);
    }
}
static function ScoredHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> MonsterClass, bool bLaserSightedM14EBRKill)
{
	if ( KFStatsAndAchievements != none && Default.bSniperWeapon )
		KFStatsAndAchievements.AddHeadshotKill(bLaserSightedM14EBRKill);
}

defaultproperties
{
     HeadShotDamageMult=1.100000
     bCheckForHeadShots=True
     bKUseOwnDeathVel=True
     bExtraMomentumZ=False
     GibPerterbation=0.250000
}
