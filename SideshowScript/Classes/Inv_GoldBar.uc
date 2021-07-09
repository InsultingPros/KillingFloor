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

defaultproperties
{
     CarriedMaterial=Texture'Pier_T.Icons.Goldbar_Icon_64'
     GroundMaterial=Texture'Pier_T.Icons.Goldbar_Icon_64'
     ForcedGroundSpeed=120.000000
     bUseForcedGroundSpeed=True
     PickupClass=Class'SideshowScript.Pickup_GoldBar'
     AttachmentClass=None
}
