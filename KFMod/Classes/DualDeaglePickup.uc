//=============================================================================
// Dual 50 Cal Pickup.
//=============================================================================
class DualDeaglePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=1000
     AmmoCost=30
     BuyClipSize=7
     PowerValue=85
     SpeedValue=35
     RangeValue=60
     Description="A pair of 50 Cal AE handguns."
     ItemName="Dual Handcannons"
     ItemShortName="Dual HCs"
     AmmoItemName=".300 JHP Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Handcannon_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.DeagleAmmo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.DualDeagle'
     PickupMessage="You found another Handcannon"
     PickupSound=Sound'KF_HandcannonSnd.50AE_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.pistol.deagle_pickup'
     CollisionHeight=5.000000
}
