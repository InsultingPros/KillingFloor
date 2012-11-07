//=============================================================================
// Magnum44Pistol
//=============================================================================
// 44 Magnum Pistol Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Magnum44Pistol extends KFWeapon;

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
	if ( Instigator.PendingWeapon.class == class'Dual44Magnum' )
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

    if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
    {
		KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnRevolverReloaded();
	}
}

defaultproperties
{
     MagCapacity=6
     ReloadRate=2.525000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Revolver"
     Weight=2.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Revolver'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_Revolver.Revolver_Trip"
     SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.Revolver_cmb"
     SelectSoundRef="KF_RevolverSnd.WEP_Revolver_Foley_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Revolver_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Revolver"
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.Magnum44Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.450000
     CurrentRating=0.450000
     bShowChargingBar=True
     Description="44 Magnum pistol, the most 'powerful' handgun in the world. Do you feel lucky?"
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=105
     InventoryGroup=2
     GroupOffset=5
     PickupClass=Class'KFMod.Magnum44Pickup'
     PlayerViewOffset=(X=12.000000,Y=15.000000,Z=-7.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.Magnum44Attachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="44 Magnum"
     bUseDynamicLights=True
     TransientSoundVolume=1.000000
}
