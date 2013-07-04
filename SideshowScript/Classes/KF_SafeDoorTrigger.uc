/*
	--------------------------------------------------------------
	KF_SafeDoorTrigger
	--------------------------------------------------------------

	Activates the doors to Lockheart's safe in the Summer Steamland map.

	only allow players who can carry the Gold bar inside the safe to
	activate the door!

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_SafeDoorTrigger extends KFUseTrigger_Story;

/* True if the player successfully interacted with the safe */
var bool bSafeDoorOpened;

function UsedBy(Pawn user)
{
    if(AllowOpenSafe(user))
    {
        bSafeDoorOpened = true;
        Super.UsedBy(user);
    }
    else    // can't pick it up.
    {
        if(!bSafeDoorOpened &&
        User != none &&
        PlayerController(User.Controller) != none)
        {
            PlayerController(User.Controller).ReceiveLocalizedMessage(class'Msg_GoldSafe');
        }
    }
}

function bool AllowOpenSafe(Pawn User)
{
	if ( User == None ||
    !User.bCanPickupInventory ||
    User.FindInventoryType(class 'Inv_GoldBar') != none )
		return false;

    return true;
}

defaultproperties
{
}
