class Pickup_GasCan extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=2
     CarriedMaterial=Texture'FrightYard_T.Gas_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     bRender1PMesh=False
     AIThreatModifier=1.500000
     InventoryType=Class'FrightScript.Inv_GasCan'
     StaticMesh=StaticMesh'FrightYard_SM.GasolineCan.SM_GasolineCan'
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=40.000000
     MessageClass=Class'FrightScript.Msg_GasCanNotification'
}
