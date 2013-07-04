//=============================================================================
// SPGrenadeAmmoPickup
//=============================================================================
// Steampunk Grenade Ammo pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPGrenadeAmmoPickup extends KFAmmoPickup;

//duplicated by goldenSPGrenadeammopickup

defaultproperties
{
     AmmoAmount=3
     InventoryType=Class'KFMod.SPGrenadeAmmo'
     PickupMessage="Orca Bombs"
     StaticMesh=StaticMesh'KillingFloorStatics.FragPickup'
     CollisionRadius=25.000000
}
