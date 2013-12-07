//=============================================================================
// CamoShotgun
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoShotgun extends Shotgun;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_CombatShotgunCamo'
     MeshRef="KF_Weapons_Trip.Shotgun_Trip"
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Shotguns.combat_shotgun_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.CombatShotgunCamo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.CombatShotgunCamo"
     AppID=258752
     FireModeClass(0)=Class'KFMod.CamoShotgunFire'
     Description="A camoflaged, rugged tactical pump action shotgun common to police divisions the world over. It accepts a maximum of 8 shells and can fire in rapid succession. "
     PickupClass=Class'KFMod.CamoShotgunPickup'
     AttachmentClass=Class'KFMod.CamoShotgunAttachment'
     ItemName="Camo Shotgun"
     Mesh=None
     Skins(0)=None
}
