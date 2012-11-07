//=============================================================================
// NailGunPickup
//=============================================================================
// NailGun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class NailGunPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=8.000000
     cost=1500
     AmmoCost=30
     BuyClipSize=12
     PowerValue=70
     SpeedValue=55
     RangeValue=25
     Description="The Black and Wrecker Vlad 9000 nail gun. Designed for putting barns together. Or nailing Zeds to them."
     ItemName="Vlad the Impaler"
     ItemShortName="Vlad 9000"
     AmmoItemName="Nails"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.NailGun'
     PickupMessage="You got the Vlad 9000."
     PickupSound=Sound'KF_NailShotgun.Handling.KF_NailShotgun_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups5_Trip.Rifles.Vlad9000_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
