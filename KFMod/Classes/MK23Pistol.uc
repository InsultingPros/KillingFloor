//=============================================================================
// MK23Pistol
//=============================================================================
// MK23 Pistol Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class MK23Pistol extends KFWeapon;

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType == Class )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).PendingAmmo = WeaponPickup(Item).AmmoAmount[0];
		}

		return false; // Allow to "pickup" so this weapon can be replaced with dual MK23.
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
	if ( Instigator.PendingWeapon.class == class'DualMK23Pistol' )
	{
		bIsReloading = false;
	}

	return super(KFWeapon).PutDown();
}

simulated function ActuallyFinishReloading()
{
    if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
    {
		KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnMK23Reloaded();
	}

	super.ActuallyFinishReloading();
}

defaultproperties
{
     MagCapacity=12
     ReloadRate=2.600000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Single9mm"
     Weight=2.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MK23'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_MK23.MK23"
     SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.MK23_SHDR"
     SelectSoundRef="KF_MK23Snd.MK23_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.MK23_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MK23"
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.MK23Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.450000
     CurrentRating=0.450000
     bShowChargingBar=True
     Description="Match grade 45 caliber pistol. Good balance between power, ammo count and rate of fire."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=65
     InventoryGroup=2
     GroupOffset=7
     PickupClass=Class'KFMod.MK23Pickup'
     PlayerViewOffset=(X=10.000000,Y=18.750000,Z=-7.000000)
     BobDamping=4.500000
     AttachmentClass=Class'KFMod.MK23Attachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="MK23"
     bUseDynamicLights=True
     TransientSoundVolume=1.000000
}
