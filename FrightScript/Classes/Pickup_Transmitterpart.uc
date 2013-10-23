class Pickup_Transmitterpart extends KF_StoryInventoryPickup;

defaultproperties
{
     MaxHeldCopies=2
     bRender1PMesh=False
     bRenderIconThroughWalls=False
     AIThreatModifier=1.500000
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=40.000000
     MessageClass=Class'FrightScript.Msg_RemoteControlNotification'
}
