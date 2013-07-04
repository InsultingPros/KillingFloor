class CashPickup_Story extends CashPickup ;



function GiveCashTo( Pawn Other )
{
	// You all love the mental-mad typecasting XD
	if( !bDroppedCash )
	{
	/* the parent class was randomizing the cash amount by default values ... so whatever the LD set as 'cash amount' was being ignored .
	@fixme -  This also appears to be *increasing* the amount of cash you gain from pickups the higher the difficulty level ...  that doesn't sound right. */

		CashAmount = ((rand(0.5 * CashAmount) + CashAmount) * (KFGameReplicationInfo(Level.GRI).GameDiff  * 0.5)) * Max(KFGameType(Level.Game).GetNumPlayers(),1) ;
	}
	else if ( Other.PlayerReplicationInfo != none && DroppedBy.PlayerReplicationInfo != none &&
			  ((DroppedBy.PlayerReplicationInfo.Score + float(CashAmount)) / Other.PlayerReplicationInfo.Score) >= 0.50 &&
			  PlayerController(DroppedBy) != none && KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements) != none )
	{
		if ( Other.PlayerReplicationInfo != DroppedBy.PlayerReplicationInfo )
		{
			KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements).AddDonatedCash(CashAmount);
		}
	}

	if( Other.Controller!=None && Other.Controller.PlayerReplicationInfo!=none )
	{
		Other.Controller.PlayerReplicationInfo.Score += CashAmount;
	}
	AnnouncePickup(Other);
	SetRespawn();
}

defaultproperties
{
     RespawnTime=0.000000
}
