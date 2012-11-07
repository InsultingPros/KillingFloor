//=============================================================================
// Knife Inventory class
//=============================================================================
class Knife extends KFMeleeGun;

defaultproperties
{
     weaponRange=65.000000
     BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.knife_bloody_cmb'
     BloodSkinSwitchArray=0
     bSpeedMeUp=True
     HudImage=Texture'KillingFloorHUD.WeaponSelect.knife_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.knife'
     Weight=0.000000
     bKFNeverThrow=True
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Knife'
     FireModeClass(0)=Class'KFMod.KnifeFire'
     FireModeClass(1)=Class'KFMod.KnifeFireB'
     SelectSound=SoundGroup'KF_KnifeSnd.Knife_Select'
     AIRating=0.200000
     CurrentRating=0.200000
     Description="Military Combat Knife"
     DisplayFOV=75.000000
     Priority=45
     GroupOffset=1
     PickupClass=Class'KFMod.KnifePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.KnifeAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Knife"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Knife_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.melee.knife_cmb'
}
