//=============================================================================
// ClaymoreSword
//=============================================================================
// A medieval claymore long sword
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ClaymoreSword extends KFMeleeGun;

defaultproperties
{
     weaponRange=100.000000
     BloodSkinSwitchArray=0
     BloodyMaterialRef="KF_Weapons4_Trip_T.Claymore_Bloody_cmb"
     bSpeedMeUp=True
     Weight=6.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Claymore'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_Claymore.Claymore_Trip"
     SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.Claymore_cmb"
     SelectSoundRef="KF_ClaymoreSnd.WEP_Claymore_Foley_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Claymore_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Claymore"
     FireModeClass(0)=Class'KFMod.ClaymoreSwordFire'
     FireModeClass(1)=Class'KFMod.ClaymoreSwordFireB'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="A medieval claymore sword."
     DisplayFOV=75.000000
     Priority=115
     GroupOffset=5
     PickupClass=Class'KFMod.ClaymoreSwordPickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.ClaymoreSwordAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Claymore Sword"
}
