//=============================================================================
// M4203Pickup
//=============================================================================
// M4 203 Assault Rifle pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class M4203Pickup extends M4Pickup;

defaultproperties
{
     cost=3500
     BuyClipSize=1
     PowerValue=90
     RangeValue=75
     Description="An assault rifle with an attached grenade launcher."
     ItemName="M4 203"
     ItemShortName="M4 203"
     SecondaryAmmoShortName="M4 203 Grenades"
     PrimaryWeaponPickup=Class'KFMod.M4Pickup'
     CorrespondingPerkIndex=6
     InventoryType=Class'KFMod.M4203AssaultRifle'
     PickupMessage="You got the M4 203"
     StaticMesh=StaticMesh'KF_pickups3_Trip.Rifles.M4M203_Pickup'
}
