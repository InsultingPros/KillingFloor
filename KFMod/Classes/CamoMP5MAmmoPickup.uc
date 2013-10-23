//=============================================================================
// CamoMP5MPickup
//=============================================================================
// Ammo pickup class for the MP5 Medic Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoMP5MAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=20
     InventoryType=Class'KFMod.CamoMP5MAmmo'
     PickupMessage="Rounds 9x19mm"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
