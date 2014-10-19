//=============================================================================
// NeonKrissMMedicGun
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2014 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class NeonKrissMMedicGun extends KrissMMedicGun;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_NeonKris'
     SkinRefs(0)="KF_Weapons_Neon_Trip_T.1stPerson.Kriss_Neon_SHDR"
     HudImageRef="KillingFloor2HUD.WeaponSelect.NeonKris_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.NeonKris"
     AppID=309991
     FireModeClass(0)=Class'KFMod.NeonKrissMFire'
     Description="Neon Schneidzekk Medic Gun"
     PickupClass=Class'KFMod.NeonKrissMPickup'
     AttachmentClass=Class'KFMod.NeonKrissMAttachment'
     ItemName="Neon Schneidzekk Medic Gun"
}
