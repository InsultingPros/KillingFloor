//=============================================================================
// GoldenBenelliShotgun
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class GoldenBenelliShotgun extends BenelliShotgun;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Benelli'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_Benelli_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Benelli_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Benelli"
     AppID=210938
     FireModeClass(0)=Class'KFMod.GoldenBenelliFire'
     Description="Gold plating, polished until it shines and twinkles. Just the thing for the serious Zed-slayer."
     PickupClass=Class'KFMod.GoldenBenelliPickup'
     AttachmentClass=Class'KFMod.GoldenBenelliAttachment'
     ItemName="Golden Combat Shotgun"
}
