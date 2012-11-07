//=============================================================================
// Chainsaw
//=============================================================================
// Chainsaw inventory class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Chainsaw extends KFMeleeGun;

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )
	   return false;

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop')  )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
	if(!FireMode[0].IsInState('FireLoop'))
	{
	  	Super.AnimEnd(channel);
	}
}

defaultproperties
{
     weaponRange=150.000000
     BloodSkinSwitchArray=0
     bDoCombos=True
     BloodyMaterialRef="KF_Weapons_Trip_T.melee.Chainsaw_bloody_cmb"
     Weight=8.000000
     StandardDisplayFOV=70.000000
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Chainsaw'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons_Trip.Chainsaw_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.melee.Chainsaw_cmb"
     SkinRefs(1)="KF_Specimens_Trip_T.scrake_saw_panner"
     SelectSoundRef="KF_ChainsawSnd.Chainsaw_Select"
     HudImageRef="KillingFloorHUD.WeaponSelect.Chainsaw_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.Chainsaw"
     FireModeClass(0)=Class'KFMod.ChainsawFire'
     FireModeClass(1)=Class'KFMod.ChainsawAltFire'
     Description="A gas powered industrial strength chainsaw."
     DisplayFOV=70.000000
     Priority=150
     InventoryGroup=4
     GroupOffset=3
     PickupClass=Class'KFMod.ChainsawPickup'
     PlayerViewOffset=(X=25.000000,Z=-10.000000)
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.ChainsawAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Chainsaw"
}
