//=============================================================================
// FlareRevolver
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development
//=============================================================================
class FlareRevolver extends KFWeapon;

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType == Class )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).PendingAmmo = WeaponPickup(Item).AmmoAmount[0];
		}

		return false; // Allow to "pickup" so this weapon can be replaced with dual deagle.
	}

	return Super.HandlePickupQuery(Item);
}

function float GetAIRating()
{
	local Bot B;


	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
    return 0;
}

simulated function bool PutDown()
{
	if ( Instigator.PendingWeapon.class == class'DualFlareRevolver' )
	{
		bIsReloading = false;
	}

	return super(KFWeapon).PutDown();
}

simulated function AddReloadedAmmo()
{
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(AmmoAmount(0) >= MagCapacity)
			MagAmmoRemaining = MagCapacity;
		else
			MagAmmoRemaining = AmmoAmount(0) ;

	// Don't do this on a "Hold to reload" weapon, as it can update too quick actually and cause issues maybe - Ramm
	if( !bHoldToReload )
	{
		ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
	}
}

defaultproperties
{
     MagCapacity=6
     ReloadRate=3.200000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_SingleFlare"
     Weight=2.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_FlareGun'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Halloween_Weps3.FlareRevolver"
     SkinRefs(0)="KF_IJC_Halloween_Weapons.FlareGun.flaregun_cmb"
     SkinRefs(1)="KF_IJC_Halloween_Weapons.FlareGun.flaregun_flame_shader"
     SelectSoundRef="KF_RevolverSnd.WEP_Revolver_Foley_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.FlareGun_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.FlareGun"
     AppID=210934
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.FlareRevolverFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.450000
     CurrentRating=0.450000
     bShowChargingBar=True
     Description="Flare Revolver. A classic wild west revolver modified to shoot fireballs!"
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=105
     InventoryGroup=2
     GroupOffset=5
     PickupClass=Class'KFMod.FlareRevolverPickup'
     PlayerViewOffset=(X=20.000000,Y=18.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.FlareRevolverAttachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="Flare Revolver"
     bUseDynamicLights=True
     TransientSoundVolume=1.000000
}
