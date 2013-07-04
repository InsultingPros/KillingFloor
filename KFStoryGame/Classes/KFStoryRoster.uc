class KFStoryRoster extends xTeamRoster;

function bool AddToTeam( Controller Other )
{
	if(Other.PlayerReplicationinfo == none)
	{
		return false;
	}

	return Super.AddToTeam(Other);
}

defaultproperties
{
}
