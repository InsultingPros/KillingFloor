//=============================================================================
// CamoM4AmmoPickup
//=============================================================================
// Ammo pickup class for the M4 assault rifle primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoM4AmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=30
     InventoryType=Class'KFMod.CamoM4Ammo'
     PickupMessage="Rounds 5.56mm"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
