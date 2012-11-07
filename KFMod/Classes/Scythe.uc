//=============================================================================
// Scythe Inventory class
//=============================================================================
class Scythe extends KFMeleeGun;

defaultproperties
{
     weaponRange=115.000000
     ChopSlowRate=0.200000
     BloodSkinSwitchArray=0
     BloodyMaterialRef="KF_IJC_Halloween_Weapons.Scythe.scythe_blood_cmb"
     bSpeedMeUp=True
     Weight=6.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_Scythe'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Halloween_Weps3.Scythe"
     SkinRefs(0)="KF_IJC_Halloween_Weapons.Scythe.scythe_cmb"
     SelectSoundRef="KF_KatanaSnd.Katana_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.Scythe_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.Scythe"
     AppID=210934
     FireModeClass(0)=Class'KFMod.ScytheFire'
     FireModeClass(1)=Class'KFMod.ScytheFireB'
     AIRating=0.300000
     Description="It's a scythe. Long handle. Long blade. Good for reaping corn, wheat - or shambling monsters."
     DisplayFOV=75.000000
     Priority=125
     GroupOffset=6
     PickupClass=Class'KFMod.ScythePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.ScytheAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Scythe"
}
