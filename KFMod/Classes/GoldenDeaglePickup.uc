//=============================================================================
// GoldenDeaglePickup
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class GoldenDeaglePickup extends DeaglePickup;

function inventory SpawnCopy(pawn Other)
{
	local Inventory I;

	for ( I = Other.Inventory; I != none; I = I.Inventory )
	{
		if ( GoldenDeagle(I) != none )
		{
			if( Inventory != none )
				Inventory.Destroy();
			InventoryType = Class'GoldenDualDeagle';
            AmmoAmount[0] += GoldenDeagle(I).AmmoAmount(0);
            MagAmmoRemaining += GoldenDeagle(I).MagAmmoRemaining;
			I.Destroyed();
			I.Destroy();
			// skip DeaglePickup.SpawnCopy, because that spawns a regular Deagle
			Return Super(KFWeaponPickup).SpawnCopy(Other);
		}
	}

	InventoryType = Default.InventoryType;
	// skip DeaglePickup.SpawnCopy, because that spawns a regular Deagle
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     ItemName="Golden Handcannon"
     ItemShortName="Golden Handcannon"
     InventoryType=Class'KFMod.GoldenDeagle'
     PickupMessage="You got the gold handcannon."
     StaticMesh=StaticMesh'KF_pickupsGold_Trip.HandcannonGold_Pickup'
     Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_Handcannon_3rd'
}
