//=============================================================================
// DualFlareRevolverPickup
//=============================================================================
// Dual Flare Revolver pistol pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development
//=============================================================================
class DualFlareRevolverPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=1000
     AmmoCost=26
     BuyClipSize=6
     PowerValue=80
     SpeedValue=50
     RangeValue=65
     Description="A pair of Flare Revolvers. Two classic wild west revolvers modified to shoot fireballs!"
     ItemName="Dual Flare Revolvers"
     ItemShortName="Dual Flare Revolvers"
     AmmoItemName="Liquid Gas Cartridges"
     AmmoMesh=StaticMesh'KillingFloorStatics.DeagleAmmo'
     CorrespondingPerkIndex=5
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.DualFlareRevolver'
     PickupMessage="You found another Flare Revolver"
     PickupSound=Sound'KF_RevolverSnd.foley.WEP_Revolver_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps.flaregun_pickup'
     CollisionHeight=5.000000
}
