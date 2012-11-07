//=============================================================================
// MK23Pickup
//=============================================================================
// MK23 pistol pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class MK23Pickup extends KFWeaponPickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( MK23Pistol(I)!=None )
		{
			if( Inventory!=None )
				Inventory.Destroy();
			InventoryType = class'DualMK23Pistol';
			AmmoAmount[0] += MK23Pistol(I).AmmoAmount(0);
			MagAmmoRemaining += MK23Pistol(I).MagAmmoRemaining;
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
     cost=500
     AmmoCost=16
     BuyClipSize=12
     PowerValue=50
     SpeedValue=45
     RangeValue=60
     Description="Match grade 45 caliber pistol. Good balance between power, ammo count and rate of fire."
     ItemName="MK23"
     ItemShortName="MK23"
     AmmoItemName=".45 ACP Ammo"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'KFMod.MK23Pistol'
     PickupMessage="You got the MK.23"
     PickupSound=Sound'KF_MK23Snd.MK23_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups4_Trip.Pistols.MK23_Pickup'
     CollisionHeight=5.000000
}
