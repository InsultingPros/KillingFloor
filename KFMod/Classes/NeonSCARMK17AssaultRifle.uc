//=============================================================================
// Neon SCAR MK17 Inventory class
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2014 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class NeonSCARMK17AssaultRifle extends SCARMK17AssaultRifle;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_NeonScar'
     SkinRefs(0)="KF_Weapons_Neon_Trip_T.1stPerson.Scar_Neon_SHDR"
     HudImageRef="KillingFloor2HUD.WeaponSelect.NeonScar_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.NeonScar"
     AppID=309991
     FireModeClass(0)=Class'KFMod.NeonSCARMK17Fire'
     Description="Neon SCAR"
     PickupClass=Class'KFMod.NeonSCARMK17Pickup'
     AttachmentClass=Class'KFMod.NeonSCARMK17Attachment'
     ItemName="Neon SCAR"
}
