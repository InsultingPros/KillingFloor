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
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.CombatShotgunCamo_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.CombatShotgunCamo'
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_CombatShotgunCamo'
     AppID=258752
     FireModeClass(0)=Class'KFMod.CamoShotgunFire'
     Description="A camoflaged, rugged tactical pump action shotgun common to police divisions the world over. It accepts a maximum of 8 shells and can fire in rapid succession. "
     PickupClass=Class'KFMod.CamoShotgunPickup'
     AttachmentClass=Class'KFMod.CamoShotgunAttachment'
     Skins(0)=Combiner'KF_Weapons_camo_Trip_T.Weapons.Combat_Shotgun_camo_cmb'
}
