class KFPC extends xPlayer;

var	bool	bChangedVeterancyThisWave;	// Whether or not this player has changed their Veterancy this Wave

simulated function SendSelectedVeterancyToServer(optional bool bForceChange);
function NotifyPerkAvailable(int Type, int Level);

replication
{
	reliable if ( Role == ROLE_Authority )
		bChangedVeterancyThisWave;
		
	reliable if( Role < ROLE_Authority )
		ServerSetCanGetAxe;
}

function ServerSetCanGetAxe()
{
	if ( SteamStatsAndAchievements != none && Role == ROLE_Authority )
	{
		KFSteamStatsAndAchievements(SteamStatsAndAchievements).SetCanGetAxe();
	}
}

defaultproperties
{
}
