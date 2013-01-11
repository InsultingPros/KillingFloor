//=============================================================================
// BoomStick Pickup.
//=============================================================================
class BoomStickPickup extends KFWeaponPickup;

var int SingleShotCount;

function ShowShotgunInfo(Canvas C)
{
	C.SetPos((C.SizeX - C.SizeY) / 2,0);
	C.DrawTile( Texture'KillingfloorHUD.ClassMenu.Shotgun', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}

function InitDroppedPickupFor(Inventory Inv)
{
	local KFWeapon W;
	local Inventory InvIt;
	local byte bSaveAmmo[2];
	local int m;

    Super.InitDroppedPickupFor(Inv);

	if ( Boomstick(Inv) != none )
	{
        SingleShotCount = BoomStick(Inv).SingleShotCount;
	}
}

defaultproperties
{
     SingleShotCount=2
     cost=750
     AmmoCost=15
     BuyClipSize=6
     PowerValue=90
     SpeedValue=30
     RangeValue=12
     Description="A double barreled shotgun used by big game hunters."
     ItemName="Hunting Shotgun"
     ItemShortName="Hunting Shotgun"
     AmmoItemName="12-gauge Hunting shells"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.HuntingShot_3rd'
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.BoomStick'
     PickupMessage="You got the Hunting Shotgun"
     PickupSound=Sound'KF_DoubleSGSnd.2Barrel_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Shotgun.boomstick_pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
