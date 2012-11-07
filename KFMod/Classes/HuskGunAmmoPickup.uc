//=============================================================================
// HuskGunAmmoPickup
//=============================================================================
// Ammo pickup class for the Husk Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=25
     InventoryType=Class'KFMod.HuskGunAmmo'
     PickupMessage="Husk Gun Fuel"
     StaticMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CollisionRadius=25.000000
}
