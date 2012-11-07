class KFPC extends xPlayer;

var	bool	bChangedVeterancyThisWave;	// Whether or not this player has changed their Veterancy this Wave

simulated function SendSelectedVeterancyToServer(optional bool bForceChange);
function NotifyPerkAvailable(int Type, int Level);

replication
{
	reliable if ( Role == ROLE_Authority )
		bChangedVeterancyThisWave;
}

defaultproperties
{
}
