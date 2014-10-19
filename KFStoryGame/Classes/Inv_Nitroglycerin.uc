/*
	--------------------------------------------------------------
	Inv_Nitroglycerin
	--------------------------------------------------------------
*/

class Inv_Nitroglycerin extends KF_StoryInventoryItem;

defaultproperties
{
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Nitroglycerin_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     ForcedGroundSpeed=120.000000
     bUseForcedGroundSpeed=True
     bDropFromCameraLoc=True
     PickupClass=Class'KFStoryGame.Pickup_Nitroglycerin'
     AttachmentClass=None
}
