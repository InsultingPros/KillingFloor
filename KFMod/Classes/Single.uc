//=============================================================================
// Tac 9mm SP only  (Dual Possible)
//=============================================================================
class Single extends KFWeapon;

var bool bDualMode;
var bool bWasDualMode;
var bool bFireLeft;
var float DualPickupTime;

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType == Class )
	{
		if ( KFHumanPawn(Owner) != none && !KFHumanPawn(Owner).CanCarry(Class'Dualies'.Default.Weight) )
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
			return true;
		}

		return false; // Allow to "pickup" so this weapon can be replaced with dualies.
	}
	Return Super.HandlePickupQuery(Item);
}

function byte BestMode()
{
	return 0;
}

simulated function bool PutDown()
{
	if (  Instigator.PendingWeapon != none && Instigator.PendingWeapon.class == class'Dualies' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}

defaultproperties
{
     FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
     MagCapacity=15
     ReloadRate=2.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Single9mm"
     ModeSwitchAnim="LightOn"
     HudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm'
     Weight=0.000000
     bKFNeverThrow=True
     bTorchEnabled=True
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_9mm'
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'KFMod.SingleFire'
     FireModeClass(1)=Class'KFMod.SingleALTFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_9MMSnd.9mm_Select'
     AIRating=0.250000
     CurrentRating=0.250000
     bShowChargingBar=True
     Description="A 9mm Pistol"
     DisplayFOV=70.000000
     Priority=60
     InventoryGroup=2
     GroupOffset=1
     PickupClass=Class'KFMod.SinglePickup'
     PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-10.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.SingleAttachment'
     IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
     ItemName="9mm Tactical"
     Mesh=SkeletalMesh'KF_Weapons_Trip.9mm_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_cmb'
}
