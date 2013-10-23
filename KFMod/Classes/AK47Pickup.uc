//=============================================================================
// AK47 Pickup.
//=============================================================================
class AK47Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=1000
     AmmoCost=10
     BuyClipSize=30
     PowerValue=40
     SpeedValue=80
     RangeValue=50
     Description="Standard issue military rifle. Equipped with an integrated 2X scope."
     ItemName="AK47"
     ItemShortName="AK47"
     AmmoItemName="7.62mm Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.AK47_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=2
     VariantClasses(0)=Class'KFMod.GoldenAK47pickup'
     InventoryType=Class'KFMod.AK47AssaultRifle'
     PickupMessage="You got the AK47"
     PickupSound=Sound'KF_AK47Snd.AK47_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Rifle.AK47_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
