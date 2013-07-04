/*
	--------------------------------------------------------------
	Inv_GoldBar
	--------------------------------------------------------------

    Carryable Gold bar item for an Escort the VIP style objective
    in the 2013 Summer Sideshow map

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Inv_GoldBar extends KF_StoryInventoryItem;

function GiveTo( pawn Other, optional Pickup Pickup )
{
    local Controller C;
    local PlayerController PC;

	super.GiveTo( Other, Pickup );

	PC = PlayerController( Other.Controller );
	if( PC != none )
	{
	   BroadcastLocalizedMessage(class'Msg_GoldBarNotification', 1, PC.PlayerReplicationInfo);
	}
}

defaultproperties
{
     CarriedMaterial=Texture'Pier_T.Icons.Goldbar_Icon_64'
     MovementSpeedModifier=0.650000
     PickupClass=Class'SideShowScript.Pickup_GoldBar'
     AttachmentClass=None
}
