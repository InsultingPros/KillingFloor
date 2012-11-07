// Custom code to make the Gorefast act abit more interesting.
class GorefastController extends KFMonsterController;

var	bool	bDoneSpottedCheck;

state ZombieHunt
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
		{
			// 25% chance of first player to see this Gorefast saying something
			if ( !KFGameType(Level.Game).bDidSpottedGorefastMessage && FRand() < 0.25 )
			{
				PlayerController(SeenPlayer.Controller).Speech('AUTO', 13, "");
				KFGameType(Level.Game).bDidSpottedGorefastMessage = true;
			}

			bDoneSpottedCheck = true;
		}

		global.SeePlayer(SeenPlayer);
	}
}

defaultproperties
{
     StrafingAbility=0.500000
}
