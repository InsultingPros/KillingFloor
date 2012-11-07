//=============================================================================
// Axe Inventory class
//=============================================================================
class Axe extends KFMeleeGun;

defaultproperties
{
     weaponRange=80.000000
     ChopSlowRate=0.200000
     BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.axe_bloody_cmb'
     BloodSkinSwitchArray=0
     bSpeedMeUp=True
     HudImage=Texture'KillingFloorHUD.WeaponSelect.axe_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.Axe'
     Weight=5.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Axe'
     bIsTier2Weapon=True
     FireModeClass(0)=Class'KFMod.AxeFire'
     FireModeClass(1)=Class'KFMod.AxeFireB'
     SelectSound=SoundGroup'KF_AxeSnd.Axe_Select'
     AIRating=0.300000
     Description="A common two-handed fireman's axe."
     DisplayFOV=75.000000
     Priority=55
     GroupOffset=3
     PickupClass=Class'KFMod.AxePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.AxeAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Axe"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Axe_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.melee.axe_cmb'
}
