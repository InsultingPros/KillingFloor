//=============================================================================
// Magnum44Pickup
//=============================================================================
// 44 Magnum pistol pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Magnum44Pickup extends KFWeaponPickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	for ( I = Other.Inventory; I != none; I = I.Inventory )
	{
		if ( Magnum44Pistol(I) != none )
		{
			if( Inventory != none )
				Inventory.Destroy();
			InventoryType = Class'Dual44Magnum';
            AmmoAmount[0] += Magnum44Pistol(I).AmmoAmount(0);
            MagAmmoRemaining += Magnum44Pistol(I).MagAmmoRemaining;
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
     Weight=2.000000
     cost=450
     AmmoCost=13
     BuyClipSize=6
     PowerValue=60
     SpeedValue=40
     RangeValue=65
     Description="44 Magnum pistol, the most 'powerful' handgun in the world. Do you feel lucky?"
     ItemName="44 Magnum"
     ItemShortName="44 Magnum"
     AmmoItemName="44 Magnum Ammo"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.Magnum44Pistol'
     PickupMessage="You got the 44 Magnum"
     PickupSound=Sound'KF_RevolverSnd.foley.WEP_Revolver_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups3_Trip.Pistols.revolver_Pickup'
     CollisionHeight=5.000000
}
