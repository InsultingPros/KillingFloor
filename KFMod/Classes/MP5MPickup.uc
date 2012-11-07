//=============================================================================
// MP5MPickup
//=============================================================================
// Pickup class for the MP5 Medic Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MPickup extends MedicGunPickup;

defaultproperties
{
     Weight=3.000000
     cost=5000
     AmmoCost=10
     BuyClipSize=32
     PowerValue=30
     SpeedValue=85
     RangeValue=45
     Description="MP5 sub machine gun. Modified to fire healing darts. Better damage and healing than MP7M with a larger mag."
     ItemName="MP5M Medic Gun"
     ItemShortName="MP5M"
     AmmoItemName="9x19mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.MP5MMedicGun'
     PickupMessage="You got the MP5M Medic Gun"
     PickupSound=Sound'KF_MP5Snd.foley.WEP_MP5_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups3_Trip.Rifles.Mp5_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
