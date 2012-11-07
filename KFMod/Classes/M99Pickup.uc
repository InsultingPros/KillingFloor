//=============================================================================
// M99Pickup
//=============================================================================
// M99 Sniper Rifle Pickup Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================

class M99Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=13.000000
     cost=3500
     AmmoCost=250
     BuyClipSize=2
     PowerValue=95
     SpeedValue=30
     RangeValue=100
     Description="M99 50 Caliber Single Shot Sniper Rifle - The ultimate in long range accuracy and knock down power."
     ItemName="M99 AMR"
     ItemShortName="M99 AMR"
     AmmoItemName="50 Cal Bullets"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.M99SniperRifle'
     PickupMessage="You got the M99 Sniper Rifle."
     PickupSound=Sound'KF_M99Snd.M99_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups4_Trip.Rifles.M99_Sniper_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
