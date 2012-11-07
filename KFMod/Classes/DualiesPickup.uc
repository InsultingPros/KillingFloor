//=============================================================================
// Dualies Pickup.
//=============================================================================
class DualiesPickup extends KFWeaponPickup;

function ShowDualiesInfo(Canvas C)
{
	C.SetPos((C.SizeX - C.SizeY) / 2,0);
	C.DrawTile( Texture'KillingfloorHUD.ClassMenu.Dualies', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}

defaultproperties
{
     Weight=4.000000
     cost=150
     BuyClipSize=30
     PowerValue=35
     SpeedValue=85
     RangeValue=35
     Description="A pair of custom 9mm handguns."
     ItemName="Dual 9mms"
     ItemShortName="Dual 9mms"
     AmmoItemName="9mm Rounds"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Single9mm_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.Dualies'
     PickupMessage="You found another 9mm handgun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.pistol.double9mm_pickup'
     CollisionHeight=5.000000
}
