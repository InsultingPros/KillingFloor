//=============================================================================
// MK23Pickup
//=============================================================================
// Dual MK23 pistol pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class DualMK23Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=1000
     AmmoCost=16
     BuyClipSize=12
     PowerValue=70
     SpeedValue=45
     RangeValue=60
     Description="Dual MK23 match grade pistols. Dual 45's is double the fun."
     ItemName="DualMK23"
     ItemShortName="DualMK23"
     AmmoItemName=".45 ACP Ammo"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.DualMK23Pistol'
     PickupMessage="You found another - MK23"
     PickupSound=Sound'KF_MK23Snd.MK23_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups4_Trip.Pistols.MK23_Pickup'
     CollisionHeight=5.000000
}
