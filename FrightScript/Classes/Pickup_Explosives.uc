class Pickup_Explosives extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'FrightYard_T.TNT_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     AIThreatModifier=1.500000
     InventoryType=Class'FrightScript.Inv_Explosives'
     StaticMesh=StaticMesh'FrightYard_SM.Dynamite.SM_Dynamite_Open'
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=40.000000
     MessageClass=Class'FrightScript.Msg_ExplosivePickupNotification'
}
