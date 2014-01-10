//=============================================================================
// BlowerThrowerPickup
//=============================================================================
// Pickup class for the bloat bile thrower
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BlowerThrowerPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=1000
     AmmoCost=15
     BuyClipSize=25
     PowerValue=50
     SpeedValue=80
     RangeValue=20
     Description="A leaf blower modified to launch deadly bloat bile. Spray it around and watch 'em burn!"
     ItemName="Blower Thrower Bile Launcher"
     ItemShortName="Blower Thrower"
     AmmoItemName="Bile"
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.BlowerThrower'
     PickupMessage="You got the BlowerThrower"
     PickupSound=Sound'KF_FY_BlowerThrowerSND.foley.WEP_Bile_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps2.BlowerThrower_Pickup'
     DrawScale=0.900000
     CollisionRadius=30.000000
     CollisionHeight=5.000000
}
