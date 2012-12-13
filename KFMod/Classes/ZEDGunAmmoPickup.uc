//=============================================================================
// ZEDGunAmmoPickup
//=============================================================================
// Ammo pickup class for the ZEDGun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDGunAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=100
     InventoryType=Class'KFMod.ZEDGunAmmo'
     PickupMessage="ZED Gun Power Cells"
     StaticMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CollisionRadius=25.000000
}
