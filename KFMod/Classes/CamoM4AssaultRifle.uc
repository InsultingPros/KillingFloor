//=============================================================================
// CamoM4AssaultRifle
//=============================================================================
// An M4 Assault Rifle
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoM4AssaultRifle extends M4AssaultRifle
	config(user);

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M4Camo'
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Weapons.m4_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.M4Camo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M4Camo"
     AppID=258752
     FireModeClass(0)=Class'KFMod.CamoM4Fire'
     Description="A camouflaged compact assault rifle. Can be fired in semi or full auto with good damage and good accuracy."
     PickupClass=Class'KFMod.CamoM4Pickup'
     AttachmentClass=Class'KFMod.CamoM4Attachment'
     ItemName="Camo M4"
}
