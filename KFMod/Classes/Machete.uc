//=============================================================================
// Machete Inventory class
//=============================================================================
class Machete extends KFMeleeGun;

defaultproperties
{
     weaponRange=80.000000
     ChopSlowRate=0.350000
     BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.machete_bloody_cmb'
     BloodSkinSwitchArray=0
     bSpeedMeUp=True
     HudImage=Texture'KillingFloorHUD.WeaponSelect.machette_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.machette'
     Weight=1.000000
     StandardDisplayFOV=70.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Machete'
     FireModeClass(0)=Class'KFMod.MacheteFire'
     FireModeClass(1)=Class'KFMod.MacheteFireB'
     SelectSound=SoundGroup'KF_MacheteSnd.Machete_Select'
     AIRating=0.400000
     CurrentRating=0.400000
     Description="A machete - commonly used for hacking through brush, or the limbs of ZEDs."
     DisplayFOV=70.000000
     Priority=50
     GroupOffset=2
     PickupClass=Class'KFMod.MachetePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.MacheteAttachment'
     IconCoords=(Y1=407,X2=118,Y2=442)
     ItemName="Machete"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Machete_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.melee.Machete_cmb'
     Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
}
