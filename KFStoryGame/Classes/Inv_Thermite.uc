/*
	--------------------------------------------------------------
	Inv_Thermite
	--------------------------------------------------------------
*/

class Inv_Thermite extends KF_StoryInventoryItem;

defaultproperties
{
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Thermite_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bDropFromCameraLoc=True
     PickupClass=Class'KFStoryGame.Pickup_Thermite'
     AttachmentClass=None
}
