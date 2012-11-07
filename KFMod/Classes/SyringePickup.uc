//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SyringePickup extends KFWeaponPickup;

/*
function ShowAxeInfo(Canvas C)
{
  C.SetPos((C.SizeX - C.SizeY) / 2,0);
  C.DrawTile( Texture'KillingfloorHUD.ClassMenu.Axe', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}
*/

defaultproperties
{
     Weight=0.000000
     ItemName="Med-Syringe"
     InventoryType=Class'KFMod.Syringe'
     PickupMessage="You got the Med-Syringe."
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.equipment.Syringe_pickup'
     CollisionHeight=5.000000
}
