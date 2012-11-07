//=============================================================================
// Deagle Pickup.
//=============================================================================
class DeaglePickup extends KFWeaponPickup;

/*
function ShowDeagleInfo(Canvas C)
{
  C.SetPos((C.SizeX - C.SizeY) / 2,0);
  C.DrawTile( Texture'KillingfloorHUD.ClassMenu.Deagle', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}
*/

function inventory SpawnCopy(pawn Other)
{
	local Inventory I;

	for ( I = Other.Inventory; I != none; I = I.Inventory )
	{
		if ( Deagle(I) != none )
		{
			if( Inventory != none )
				Inventory.Destroy();
			InventoryType = Class'DualDeagle';
            AmmoAmount[0] += Deagle(I).AmmoAmount(0);
            MagAmmoRemaining += Deagle(I).MagAmmoRemaining;
			I.Destroyed();
			I.Destroy();
			Return Super.SpawnCopy(Other);
		}
	}

	InventoryType = Default.InventoryType;
	Return Super.SpawnCopy(Other);
}

defaultproperties
{
     Weight=4.000000
     cost=500
     AmmoCost=15
     BuyClipSize=7
     PowerValue=65
     SpeedValue=35
     RangeValue=60
     Description="50 Cal AE handgun. A powerful personal choice for personal defense."
     ItemName="Handcannon"
     ItemShortName="Handcannon"
     AmmoItemName=".300 JHP Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Handcannon_3rd'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.Deagle'
     PickupMessage="You got the Handcannon"
     PickupSound=Sound'KF_HandcannonSnd.50AE_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.pistol.deagle_pickup'
     CollisionHeight=5.000000
}
