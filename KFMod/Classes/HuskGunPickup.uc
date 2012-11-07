//=============================================================================
// HuskGunPickup
//=============================================================================
// Husk Gun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=8.000000
     cost=4000
     AmmoCost=50
     BuyClipSize=25
     PowerValue=85
     SpeedValue=25
     RangeValue=75
     Description="A fireball cannon ripped from the arm of a dead Husk. Does more damage when charged up."
     ItemName="Husk Fireball Launcher"
     ItemShortName="Husk Gun"
     AmmoItemName="Husk Gun Fuel"
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.Huskgun'
     PickupMessage="You got the Husk Fireball Launcher."
     PickupSound=Sound'KF_HuskGunSnd.foley.Husk_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups3_Trip.Rifles.HuskGun_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
