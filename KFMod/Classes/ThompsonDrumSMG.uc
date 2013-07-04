//=============================================================================
// ThompsonDrumSMG
//=============================================================================
// A ThompsonDrum Sub Machine Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class ThompsonDrumSMG extends ThompsonSMG
	config(user);

defaultproperties
{
     MagCapacity=50
     ReloadRate=3.800000
     WeaponReloadAnim="Reload_IJC_spThompson_Drum"
     SleeveNum=0
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_Thompson_Drum'
     MeshRef="KF_IJC_Summer_Weps1.ThompsonDrum"
     SkinRefs(1)="KF_IJC_Summer_Weapons.Thompson_Drum.thompson_drum_cmb"
     HudImageRef="KF_IJC_HUD.WeaponSelect.Thompson_Drum_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.Thompson_Drum"
     AppID=210942
     FireModeClass(0)=Class'KFMod.ThompsonDrumFire'
     Description="This Tommy gun with a drum magazine was used heavily during the WWII pacific battles as seen in Rising Storm."
     Priority=124
     GroupOffset=20
     PickupClass=Class'KFMod.ThompsonDrumPickup'
     AttachmentClass=Class'KFMod.ThompsonDrumAttachment'
     ItemName="Rising Storm Tommy Gun"
}
