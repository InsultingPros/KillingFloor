/*
	--------------------------------------------------------------
	Story_SceneManager
	--------------------------------------------------------------

	Custom SceneManager class for use in Killing Floor 'Story' maps.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Story_SceneManager extends SceneManager;


/* Matinee is broken in network play so just dont let the Scene start if we're on a server */

function Trigger( actor Other, Pawn EventInstigator )
{
	if(Level.NetMode == NM_Standalone)
	{
		Super.Trigger(other,EventInstigator);
	}
}

defaultproperties
{
}
