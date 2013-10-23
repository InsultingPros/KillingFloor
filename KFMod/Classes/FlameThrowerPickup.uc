//=============================================================================
// L85 Pickup.
//=============================================================================
class FlameThrowerPickup extends KFWeaponPickup;

defaultproperties
{
     cost=750
     AmmoCost=30
     BuyClipSize=50
     PowerValue=30
     SpeedValue=100
     RangeValue=40
     Description="A deadly experimental weapon designed by Horzine industries. It can fire streams of burning liquid which ignite on contact."
     ItemName="FlameThrower"
     ItemShortName="FlameThrower"
     AmmoItemName="Napalm"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Flamethrower_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     VariantClasses(0)=Class'KFMod.GoldenFTPickup'
     InventoryType=Class'KFMod.FlameThrower'
     PickupMessage="You got the FlameThrower"
     PickupSound=Sound'KF_FlamethrowerSnd.FT_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Super.Flamethrower_pickup'
     CollisionRadius=30.000000
     CollisionHeight=5.000000
}
