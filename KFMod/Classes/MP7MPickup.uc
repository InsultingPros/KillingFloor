//=============================================================================
// MP7M Pickup.
//=============================================================================
class MP7MPickup extends MedicGunPickup;

defaultproperties
{
     Weight=3.000000
     cost=3000
     AmmoCost=10
     BuyClipSize=20
     PowerValue=22
     SpeedValue=95
     RangeValue=45
     Description="Prototype sub machine gun. Modified to fire healing darts."
     ItemName="MP7M Medic Gun"
     ItemShortName="MP7M"
     AmmoItemName="4.6x30mm Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd2_Trip.mp7_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.MP7MMedicGun'
     PickupMessage="You got the MP7M Medic Gun"
     PickupSound=Sound'KF_MP7Snd.MP7_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.MP7_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
