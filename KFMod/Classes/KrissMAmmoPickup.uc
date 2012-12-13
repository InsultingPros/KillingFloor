//=============================================================================
// KrissMAmmoPickup
//=============================================================================
// Ammo pickup class for the Kriss Medic Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KrissMAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=25
     InventoryType=Class'KFMod.KrissMAmmo'
     PickupMessage="Rounds 45. ACP"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
