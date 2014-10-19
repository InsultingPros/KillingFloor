/*
	--------------------------------------------------------------
	Pickup_MaintenanceKeyCard
	--------------------------------------------------------------
*/

class Pickup_MaintenanceKeyCard extends KF_StoryInventoryPickup
placeable;

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Keycard_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     bRenderIconThroughWalls=False
     InventoryType=Class'KFStoryGame.Inv_MaintenanceKeyCard'
     StaticMesh=StaticMesh'KF_Swansong_SM.Metro.SM_Keycard'
     bOrientOnSlope=True
     PrePivot=(Z=25.000000)
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=25.000000
     CollisionHeight=25.000000
     MessageClass=Class'KFStoryGame.Msg_MaintenanceKeyCardNotification'
}
