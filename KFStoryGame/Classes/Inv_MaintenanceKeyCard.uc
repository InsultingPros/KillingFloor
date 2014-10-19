/*
	--------------------------------------------------------------
	Inv_MaintenanceKeyCard
	--------------------------------------------------------------
*/

class Inv_MaintenanceKeyCard extends KF_StoryInventoryItem;

defaultproperties
{
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Keycard_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bDropFromCameraLoc=True
     PickupClass=Class'KFStoryGame.Pickup_MaintenanceKeyCard'
     AttachmentClass=None
}
