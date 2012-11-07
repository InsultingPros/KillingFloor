//=============================================================================
// Axe Pickup.
//=============================================================================
class AxePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.000000
     cost=150
     PowerValue=56
     SpeedValue=32
     RangeValue=-20
     Description="A sturdy fireman's axe."
     ItemName="Axe"
     ItemShortName="Axe"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Axe_3rd'
     CorrespondingPerkIndex=4
     InventoryType=Class'KFMod.Axe'
     PickupMessage="You got the Fire Axe."
     PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.Axe_Pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
