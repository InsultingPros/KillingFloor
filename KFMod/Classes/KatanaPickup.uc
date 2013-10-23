//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KatanaPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=3.000000
     PowerValue=60
     SpeedValue=60
     RangeValue=-21
     Description="An incredibly sharp katana sword."
     ItemName="Katana"
     ItemShortName="Katana"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Katana_3rd'
     CorrespondingPerkIndex=4
     VariantClasses(0)=Class'KFMod.GoldenKatanaPickup'
     InventoryType=Class'KFMod.Katana'
     PickupMessage="You got the Katana."
     PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.Katana_pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
