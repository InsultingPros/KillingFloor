//=============================================================================
// GoldenDeagle
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class GoldenDeagle extends Deagle;

simulated function bool PutDown()
{
	if ( Instigator.PendingWeapon.class == class'GoldenDualDeagle' )
	{
		bIsReloading = false;
	}

	return super(KFWeapon).PutDown();
}

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Deagle'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_deagle_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Deagle_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Deagle"
     AppID=210944
     FireModeClass(0)=Class'KFMod.GoldenDeagleFire'
     PickupClass=Class'KFMod.GoldenDeaglePickup'
     AttachmentClass=Class'KFMod.GoldenDeagleAttachment'
     ItemName="Golden Handcannon"
}
