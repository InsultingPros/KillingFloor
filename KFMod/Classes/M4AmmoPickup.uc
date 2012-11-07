//=============================================================================
// M4AmmoPickup
//=============================================================================
// Ammo pickup class for the M4 assault rifle primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class M4AmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=30
     InventoryType=Class'KFMod.M4Ammo'
     PickupMessage="Rounds 5.56mm"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
