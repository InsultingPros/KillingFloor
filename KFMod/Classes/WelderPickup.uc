//=============================================================================
// Welder Pickup.
//=============================================================================
class WelderPickup extends KFWeaponPickup;

#exec obj load file="..\StaticMeshes\NewPatchSM.usx"

defaultproperties
{
     Weight=0.000000
     ItemName="Welder"
     InventoryType=Class'KFMod.Welder'
     PickupMessage="You got the Welder."
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.equipment.welder_pickup'
     CollisionHeight=5.000000
}
