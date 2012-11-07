// Calls the Main Menu to appear. ( no triggering needed, just place it in a map)
class KFMMTrig extends Trigger;

function PostBeginPlay()
{
	SetTimer(0.25,False);
}
function Timer()
{
	local Controller C;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( CinematicPlayer(C)!=None )
			CinematicPlayer(C).ClientOpenMenu("KFGUI.KFMainMenu");
	}
}

defaultproperties
{
}
