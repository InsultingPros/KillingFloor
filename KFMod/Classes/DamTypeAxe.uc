class DamTypeAxe extends DamTypeMelee;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( KFStatsAndAchievements!=None )
		KFStatsAndAchievements.AddFireAxeKill();
}

defaultproperties
{
     WeaponClass=Class'KFMod.Axe'
     PawnDamageSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     VehicleDamageScaling=0.700000
}
