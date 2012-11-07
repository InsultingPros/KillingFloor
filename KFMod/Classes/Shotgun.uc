//=============================================================================
// Shotgun Inventory class
//=============================================================================
class Shotgun extends KFWeaponShotgun;

defaultproperties
{
     FirstPersonFlashlightOffset=(X=-25.000000,Y=-18.000000,Z=8.000000)
     MagCapacity=8
     ReloadRate=0.666667
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Shotgun"
     HudImage=Texture'KillingFloorHUD.WeaponSelect.combat_shotgun_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.combat_shotgun'
     Weight=8.000000
     bTorchEnabled=True
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Combat_Shotgun'
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'KFMod.ShotgunFire'
     FireModeClass(1)=Class'KFMod.ShotgunLightFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_PumpSGSnd.SG_Select'
     AIRating=0.600000
     CurrentRating=0.600000
     bShowChargingBar=True
     Description="A rugged tactical pump action shotgun common to police divisions the world over. It accepts a maximum of 8 shells and can fire in rapid succession. "
     DisplayFOV=65.000000
     Priority=135
     InventoryGroup=3
     GroupOffset=2
     PickupClass=Class'KFMod.ShotgunPickup'
     PlayerViewOffset=(X=20.000000,Y=18.750000,Z=-7.500000)
     BobDamping=7.000000
     AttachmentClass=Class'KFMod.ShotgunAttachment'
     IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
     ItemName="Shotgun"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Shotgun_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.Shotguns.shotgun_cmb'
     TransientSoundVolume=1.000000
}
