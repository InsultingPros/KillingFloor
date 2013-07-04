class ACTION_GiveWaveEndCash extends ScriptedAction
editinlinenew;

function bool InitActionFor(ScriptedController C)
{
	local Controller PC;
	local int moneyPerPlayer,div;
	local TeamInfo T;

	for ( PC = C.Level.ControllerList; PC != none; PC = PC.NextController )
	{
		if ( PC.Pawn != none && PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.Team != none )
		{
			T = PC.PlayerReplicationInfo.Team;
			div++;
		}
	}

	if ( T == none || T.Score <= 0 )
	{
		return false;
	}

	moneyPerPlayer = int(T.Score / float(div));

	for ( PC = C.Level.ControllerList; PC != none; PC = PC.NextController )
	{
		if ( PC.Pawn != none && PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.Team != none )
		{
			if ( div == 1 )
			{
				PC.PlayerReplicationInfo.Score += T.Score;
				T.Score = 0;
			}
			else
			{
				PC.PlayerReplicationInfo.Score += moneyPerPlayer;
				T.Score-=moneyPerPlayer;
				div--;
			}

			if(PlayerController(PC) != none)
			{
				PlayerController(PC).ClientPlaySound(class 'CashPickup'.default.PickupSound);
                PlayerController(PC).ReceiveLocalizedMessage(class 'Msg_CashReward',MoneyPerPlayer);
            }

			PC.PlayerReplicationInfo.NetUpdateTime = C.Level.TimeSeconds - 1;

			if( T.Score <= 0 )
			{
				T.Score = 0;
				Break;
			}
		}
	}


    return false;

}

defaultproperties
{
}
