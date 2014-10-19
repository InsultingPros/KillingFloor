/*
	--------------------------------------------------------------
	Pickup_PatriarchEyeBall
	--------------------------------------------------------------
*/

class Pickup_PatriarchEyeBall extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'KF_Swansong_Tex.Icons.Eyeball_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     bRenderIconThroughWalls=False
     DroppedSound=Sound'KFPawnDamageSound.MeleeDamageSounds.bathitflesh2'
     InventoryType=Class'KFStoryGame.Inv_PatriarchEyeball'
     StaticMesh=StaticMesh'kf_gore_trip_sm.gibbs.eyeball'
     bOrientOnSlope=True
     DrawScale=2.000000
     PrePivot=(Z=11.500000)
     Skins(0)=Texture'kf_fx_trip_t.Gore.eyeball_diff'
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=25.000000
     CollisionHeight=25.000000
     MessageClass=Class'KFStoryGame.Msg_EyeBallNotification'
}
