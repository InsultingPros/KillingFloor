//=============================================================================
// MP5MHealinglProjectile
//=============================================================================
// Healing projectile for the MP5M
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive
// Author - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MHealinglProjectile extends HealingProjectile;

function AddDamagedHealStats( int MedicReward )
{
	local KFSteamStatsAndAchievements KFSteamStats;

	if ( Instigator == none || Instigator.PlayerReplicationInfo == none )
	{
		return;
	}

	KFSteamStats = KFSteamStatsAndAchievements( Instigator.PlayerReplicationInfo.SteamStatsAndAchievements );

	if ( KFSteamStats != none )
	{
	 	KFSteamStats.AddDamageHealed(MedicReward, false, true);
	}
}

defaultproperties
{
     HealBoostAmount=30
}
