class KFBroadcastHandler extends BroadcastHandler;

/*
 Broadcast a localized message to all players.
 Most messages deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event AllowTeamBroadcastLocalized(Actor Sender, class<LocalMessage> Message, int Switch1, int Switch2, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local Controller C;
	local PlayerController P;

	For ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		P = PlayerController(C);
		if ( P != None )
		{
			if ( P.GetTeamNum() == 0 )
				BroadcastLocalized(Sender, P, Message, Switch1, RelatedPRI_1, RelatedPRI_2, OptionalObject);
			else if ( P.GetTeamNum() == 1 )
				BroadcastLocalized(Sender, P, Message, Switch2, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
	}
}

defaultproperties
{
}
