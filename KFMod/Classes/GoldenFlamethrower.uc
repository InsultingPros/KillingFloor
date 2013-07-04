//=============================================================================
// GoldenFlamethrower
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class GoldenFlamethrower extends Flamethrower;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Flamethrower'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_Flamethrower_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Flamethrower_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Flamethrower"
     AppID=210944
     FireModeClass(0)=Class'KFMod.GoldenFlameBurstFire'
     PickupClass=Class'KFMod.GoldenFTPickup'
     AttachmentClass=Class'KFMod.GoldenFTAttachment'
     ItemName="Golden Flamethrower"
}
