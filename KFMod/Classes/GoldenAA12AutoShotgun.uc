//=============================================================================
// Golden AA12
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class GoldenAA12AutoShotgun extends AA12AutoShotgun;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_AA12'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_AA12_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_AA12_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_AA12"
     AppID=210944
     FireModeClass(0)=Class'KFMod.GoldenAA12Fire'
     PickupClass=Class'KFMod.GoldenAA12Pickup'
     AttachmentClass=Class'KFMod.GoldenAA12Attachment'
     ItemName="Golden AA12"
}
