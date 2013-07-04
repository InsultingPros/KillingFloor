//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ACTION_CashReward extends ScriptedAction
editinlinenew;

var    ()       int       BaseCashAmount;

function bool InitActionFor(ScriptedController C)
{
	local Controller Controller;

	if(Abs(BaseCashAmount) > 0)
	{
		for ( Controller = C.Level.ControllerList; Controller != none; Controller = Controller.NextController )
		{
			if(Controller.PlayerReplicationInfo != none &&
			Controller.Pawn != none &&
			Controller.Pawn.Health > 0)
			{
				Controller.PlayerReplicationInfo.Score += BaseCashAmount ;

				if(PlayerController(Controller) != none)
				{
					PlayerController(Controller).ClientPlaySound(class 'CashPickup'.default.PickupSound);
                    PlayerController(Controller).ReceiveLocalizedMessage(class 'Msg_CashReward',BaseCashAmount);
				}
			}
		}
	}

    return false;
}

defaultproperties
{
}
