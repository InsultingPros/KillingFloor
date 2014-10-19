/*
	--------------------------------------------------------------
	Inv_PatriarchEyeBall
	--------------------------------------------------------------
*/

class Inv_PatriarchEyeball extends KF_StoryInventoryItem;

defaultproperties
{
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Eyeball_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bDropFromCameraLoc=True
     PickupClass=Class'KFStoryGame.Pickup_PatriarchEyeBall'
     AttachmentClass=None
}
