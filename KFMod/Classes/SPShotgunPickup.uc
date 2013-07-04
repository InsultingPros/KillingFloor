//=============================================================================
// SPShotgunPickup
//=============================================================================
// Steampunk Shotgun Pickup.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPShotgunPickup extends KFWeaponPickup;

defaultproperties
{
     AmmoCost=30
     BuyClipSize=10
     PowerValue=60
     SpeedValue=50
     RangeValue=20
     Description="A device for throwing lead and getting sodding enemies out of your face."
     ItemName="Multichamber ZED Thrower"
     ItemShortName="M.C.Z. Thrower"
     AmmoItemName="M.C.Z. Drum"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.SPAutoShotgun'
     PickupMessage="You got the Multichamber Lead Thrower."
     PickupSound=Sound'KF_SP_ZEDThrowerSnd.KFO_Shotgun_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Summer_Weps.Jackhammer'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
