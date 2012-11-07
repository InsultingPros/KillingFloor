//=============================================================================
// Machete Pickup.
//=============================================================================
class MachetePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=100
     PowerValue=35
     SpeedValue=56
     RangeValue=-20
     Description="A machete - commonly used for hacking through brush, or the limbs of ZEDs."
     ItemName="Machete"
     ItemShortName="Machete"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.machete_3rd'
     CorrespondingPerkIndex=4
     InventoryType=Class'KFMod.Machete'
     PickupMessage="You got a machete."
     PickupSound=Sound'KF_MacheteSnd.Machete_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.machette_pickup'
     CollisionRadius=28.000000
     CollisionHeight=5.000000
}
