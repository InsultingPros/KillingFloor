//=============================================================================
// Bat Inventory class
//=============================================================================
class Bat extends KFMeleeGun;

defaultproperties
{
     weaponRange=80.000000
     ChopSlowRate=0.350000
     BloodyMaterial=Shader'KillingFloorWeapons.Bat.BatBloodyShader'
     BloodSkinSwitchArray=0
     bSpeedMeUp=True
     HudImage=Texture'KillingFloorHUD.WeaponSelect.machette'
     Weight=3.000000
     StandardDisplayFOV=70.000000
     FireModeClass(0)=Class'KFMod.BatFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     AIRating=0.400000
     CurrentRating=0.400000
     Description="This bit of broken pipe looks like it was pried from a gas-line."
     DisplayFOV=70.000000
     Priority=3
     GroupOffset=2
     PickupClass=Class'KFMod.BatPickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.BatAttachment'
     IconCoords=(Y1=407,X2=118,Y2=442)
     ItemName="Broken Pipe"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Pipe_Trip'
     Skins(0)=Shader'KillingFloorWeapons.Bat.BatShineShader'
     Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
}
