//=============================================================================
// Deagle Inventory class
//=============================================================================
class Deagle extends KFWeapon;

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
	if ( Instigator.PendingWeapon.class == class'DualDeagle' )
	{
		bIsReloading = false;
	}

	return super(KFWeapon).PutDown();
}

defaultproperties
{
     MagCapacity=8
     ReloadRate=2.200000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Single9mm"
     Weight=4.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Handcannon'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons_Trip.Handcannon_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.Pistols.deagle_cmb"
     HudImageRef="KillingFloorHUD.WeaponSelect.handcannon_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.handcannon"
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.DeagleFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_HandcannonSnd.50AE_Select'
     AIRating=0.450000
     CurrentRating=0.450000
     bShowChargingBar=True
     Description=".50 calibre action express handgun. This is about as big and nasty as personal weapons are going to get. But with a 7 round magazine, it should be used conservatively.  "
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=100
     InventoryGroup=2
     GroupOffset=3
     PickupClass=Class'KFMod.DeaglePickup'
     PlayerViewOffset=(X=5.000000,Y=20.000000,Z=-10.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.DeagleAttachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="Handcannon"
     bUseDynamicLights=True
     TransientSoundVolume=1.000000
}
