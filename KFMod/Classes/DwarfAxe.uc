//=============================================================================
// DwarfAxe
//=============================================================================
// An Axe from the game Dwarfs
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DwarfAxe extends KFMeleeGun;

defaultproperties
{
     weaponRange=80.000000
     BloodSkinSwitchArray=0
     BloodyMaterialRef="Kf_Weapons9_Trip_T.Dwarven_Axe_Bloody_cmb"
     bSpeedMeUp=True
     Weight=6.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Dwarven_Battle_Axe'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_Dwarf_Axe.Dwarf_Axe_Trip"
     SkinRefs(0)="Kf_Weapons9_Trip_T.Weapons.Dwarven_Axe_cmb"
     SelectSoundRef="KF_DwarfAxeSnd.KF_WEP_DwarfAxe_Handling_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Dwarven_Battle_Axe_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Dwarven_Battle_Axe"
     AppID=210939
     UnlockedByAchievement=208
     FireModeClass(0)=Class'KFMod.DwarfAxeFire'
     FireModeClass(1)=Class'KFMod.DwarfAxeFireB'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="Two-handed monster of an axe, liberated from some Dwarven stronghold. Even if it doesn't kill them, it'll certainly give them a headache!"
     DisplayFOV=75.000000
     Priority=75
     GroupOffset=6
     PickupClass=Class'KFMod.DwarfAxePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.DwarfAxeAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Dwarf Axe"
}
