//=============================================================================
// Dual44MagnumPickup
//=============================================================================
// Dual 44 Magnum pistol pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Dual44MagnumPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=900
     AmmoCost=26
     BuyClipSize=6
     PowerValue=80
     SpeedValue=50
     RangeValue=65
     Description="A pair of 44 Magnum Pistols. Make my day!"
     ItemName="Dual 44 Magnums"
     ItemShortName="Dual 44s"
     AmmoItemName="44 Magnum Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.DeagleAmmo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.Dual44Magnum'
     PickupMessage="You found another 44 Magnum"
     PickupSound=Sound'KF_RevolverSnd.foley.WEP_Revolver_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups3_Trip.Pistols.revolver_Pickup'
     CollisionHeight=5.000000
}
