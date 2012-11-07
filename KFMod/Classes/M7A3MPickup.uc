//=============================================================================
// M7A3MPickup
//=============================================================================
// M7A3M pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class M7A3MPickup extends MedicGunPickup;

defaultproperties
{
     Weight=6.000000
     cost=7500
     AmmoCost=10
     BuyClipSize=15
     PowerValue=45
     SpeedValue=60
     RangeValue=55
     Description="An advanced Horzine prototype assault rifle. Modified to fire healing darts."
     ItemName="M7A3 Medic Gun"
     ItemShortName="M7A3M"
     AmmoItemName="7.6x40mm Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd2_Trip.mp7_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.M7A3MMedicGun'
     PickupMessage="You got the M7A3 Medic Gun"
     PickupSound=Sound'KF_M7A3Snd.M7A3_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups4_Trip.Rifles.M7A3_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
