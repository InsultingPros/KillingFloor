/*
	--------------------------------------------------------------

	a runtime-spawnable version of the KF_StoryNPC

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryNPC_Spawnable extends KF_StoryNPC
notplaceable;

function Reset()
{
	bFireAtWill = bInitialFireAtWill ;
	SetActive(bInitialActive);
}

simulated function PostBeginPlay()
{
    /* need to manually spawn controllers for non editor-placed pawns */
    Super.PostBeginPlay();

    if(Controller == none)
    {
        Controller = Spawn(ControllerClass);
        Controller.Possess(self);
    }

    Skins.length = 0;
    SetMovementPhysics();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(Controller != none)
	{
	    // so that the controller will get garbage collected */
	    Controller.bIsPlayer = false;
	}

    /* skip the phoney corpse stuff in the superclass and just do a normal death */
    Super(KFPawn).Died(Killer,damageType,HitLocation);
}

defaultproperties
{
     bNoDelete=False
}
