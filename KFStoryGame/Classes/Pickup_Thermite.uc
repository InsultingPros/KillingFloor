/*
	--------------------------------------------------------------
	Pickup_Thermite
	--------------------------------------------------------------
*/

class Pickup_Thermite extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Thermite_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     bRenderIconThroughWalls=False
     InventoryType=Class'KFStoryGame.Inv_Thermite'
     StaticMesh=StaticMesh'KF_Swansong_SM.Metro.SM_Thermite'
     DrawScale=0.600000
     PrePivot=(Z=18.000000)
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=40.000000
     MessageClass=Class'KFStoryGame.Msg_ThermiteNotification'
}
