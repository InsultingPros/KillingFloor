//=============================================================================
// CamoMP5MMedicGun
//=============================================================================
// A modified MP5 SMG and Medic Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoMP5MMedicGun extends MP5MMedicGun;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MP5Camo'
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Weapons.MP5_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.MP5Camo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MP5Camo"
     AppID=258752
     FireModeClass(0)=Class'KFMod.CamoMP5MFire'
     Description="Camo MP5 description"
     PickupClass=Class'KFMod.CamoMP5MPickup'
     AttachmentClass=Class'KFMod.CamoMP5MAttachment'
     ItemName="Camo MP5M Medic Gun"
}
