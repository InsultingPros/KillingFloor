//=============================================================================
// MP7MHealinglProjectile
//=============================================================================
// Healing projectile for the MP7M
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive
// Author - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP7MHealinglProjectile extends HealingProjectile;

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
	 	KFSteamStats.AddDamageHealed(MedicReward, true);
	}
}

defaultproperties
{
}
