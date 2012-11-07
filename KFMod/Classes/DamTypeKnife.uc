class DamTypeKnife extends DamTypeMelee
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( KFStatsAndAchievements!=None && Killer.SelectedVeterancy==class'KFVetFieldMedic' )
		KFStatsAndAchievements.AddMedicKnifeKill();
}

defaultproperties
{
     WeaponClass=Class'KFMod.knife'
     KDamageImpulse=1500.000000
     VehicleDamageScaling=0.500000
}
