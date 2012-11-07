//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Katana extends KFMeleeGun;

defaultproperties
{
     weaponRange=90.000000
     BloodSkinSwitchArray=0
     BloodyMaterialRef="KF_Weapons2_Trip_T.melee.Katana_Bloody_cmb"
     bSpeedMeUp=True
     Weight=3.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Katana'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons2_Trip.Katana_Trip"
     SkinRefs(0)="KF_Weapons2_Trip_T.melee.Katana_cmb"
     SelectSoundRef="KF_KatanaSnd.Katana_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.katana_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Katana"
     FireModeClass(0)=Class'KFMod.KatanaFire'
     FireModeClass(1)=Class'KFMod.KatanaFireB'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="An incredibly sharp katana sword."
     DisplayFOV=75.000000
     Priority=110
     GroupOffset=4
     PickupClass=Class'KFMod.KatanaPickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.KatanaAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Katana"
}
