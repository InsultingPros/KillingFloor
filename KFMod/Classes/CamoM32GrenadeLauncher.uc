//=============================================================================
// Camo M32 MGL Semi automatic grenade launcher Inventory class
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoM32GrenadeLauncher extends M32GrenadeLauncher;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M32Camo'
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Weapons.M32_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.M32Camo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M32Camo"
     AppID=258752
     FireModeClass(0)=Class'KFMod.CamoM32Fire'
     Description="CAMO NADER!"
     PickupClass=Class'KFMod.CamoM32Pickup'
     AttachmentClass=Class'KFMod.CamoM32Attachment'
     ItemName="Camo M32 Grenade Launcher"
}
