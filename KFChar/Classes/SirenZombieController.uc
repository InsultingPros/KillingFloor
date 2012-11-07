class SirenZombieController extends KFMonsterController;

var		bool		bDoneSpottedCheck;

state ZombieHunt
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
		{
			// 25% chance of first player to see this Siren saying something
			if ( !KFGameType(Level.Game).bDidSpottedSirenMessage && FRand() < 0.25 )
			{
				PlayerController(SeenPlayer.Controller).Speech('AUTO', 15, "");
				KFGameType(Level.Game).bDidSpottedSirenMessage = true;
			}

			bDoneSpottedCheck = true;
		}

		super.SeePlayer(SeenPlayer);
	}
}

defaultproperties
{
}
