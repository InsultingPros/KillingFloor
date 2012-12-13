//=============================================================================
// KF Use Trigger. Now with bigger messages, and Refire delays for human users.
// This shit's used for Doors in Killing Floor.
// By: Alex
//=============================================================================
class KFGrabbable extends UseTrigger;

var bool bUsed;
var     float   LastMessageTimer;
var() sound PickupSound;

/*
function bool SelfTriggered()
{
	return true;
}         */

function UsedBy( Pawn user )
{
    local Controller C;
    if( !bUsed )
    {
        if( KFHumanPawn(user) != none )
        {
            For ( C=Level.ControllerList; C!=None; C=C.NextController )
            {
                 if( KFPlayerController(C) != none )
                 {
                     KFPlayerController(C).ClientPickedup(self);
                 }
            }
        }
       	PlaySound( PickupSound,SLOT_Interact );
       	TriggerEvent(Event, self, user);
	    bUsed = true;
        bHidden = true;
    }
}

// Modded to account for...Zombies, and the Sealing (removal) of the Door Movers.
function Touch( Actor Other )
{
	if( Pawn(Other)==None || Pawn(Other).Health <= 0 )
		Return;

	// Send a string message to the toucher.
	if(PlayerController(Pawn(Other).Controller)!=none && bUsed == false)
	{
		if( LastMessageTimer<Level.TimeSeconds && Message!="" )
		{
			LastMessageTimer = Level.TimeSeconds+0.6;
			if ( InStr(Message, "USE") != -1 )
			{
				PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(class'KFMod.WaitingMessage', 7);
			}
		}
	}
}

defaultproperties
{
     PickupSound=Sound'KF_InventorySnd.Ammo_GenericPickup'
     Message="Press USE to pick up Z.E.D. gun piece"
     RemoteRole=ROLE_SimulatedProxy
}
