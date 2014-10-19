/*
	--------------------------------------------------------------
	Pickup_Nitroglycerin
	--------------------------------------------------------------
*/

class Pickup_Nitroglycerin extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Nitroglycerin_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     bRenderIconThroughWalls=False
     InventoryType=Class'KFStoryGame.Inv_Nitroglycerin'
     StaticMesh=StaticMesh'KF_Swansong_SM.LAB.SM_Nitroglycerin_Bottle'
     DrawScale=0.250000
     PrePivot=(Z=100.000000)
     CollisionRadius=25.000000
     CollisionHeight=25.000000
     MessageClass=Class'KFStoryGame.Msg_NitroglycerinNotification'
}
