//=============================================================================
// GoldenM79GrenadeLauncher
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================

class GoldenM79GrenadeLauncher extends M79GrenadeLauncher;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_M79'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_M79_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_M79_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_M79"
     AppID=210938
     FireModeClass(0)=Class'KFMod.GoldenM79Fire'
     Description="Gold plating. Gold filigree inlay on the woodwork. You probably want the rounds gold as well. Bosh! "
     PickupClass=Class'KFMod.GoldenM79Pickup'
     AttachmentClass=Class'KFMod.GoldenM79Attachment'
     ItemName="Gold M79 Grenade Launcher"
}
