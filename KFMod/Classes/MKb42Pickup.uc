//=============================================================================
// MKb42 Pickup.
//=============================================================================
class MKb42Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=1100
     AmmoCost=10
     BuyClipSize=30
     PowerValue=40
     SpeedValue=85
     RangeValue=55
     Description="German WWII era prototype assault rifle. Many heroes were known to have used this weapon in Stalingrad."
     ItemName="MKb42"
     ItemShortName="MKb42"
     AmmoItemName="7.92mm Kurz Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.AK47_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=2
     InventoryType=Class'KFMod.MKb42AssaultRifle'
     PickupMessage="You got the MKb42"
     PickupSound=Sound'KF_mkb42Snd.Handling.mkb42_Handling_Bolt_Back'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups5_Trip.Rifles.MKB42_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
