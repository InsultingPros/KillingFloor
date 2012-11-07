//=============================================================================
// M99AmmoPickup
//=============================================================================
// M99 Sniper Rifle ammo pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class M99AmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=2
     InventoryType=Class'KFMod.M99Ammo'
     PickupMessage="50 Cal Bullets"
     StaticMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CollisionRadius=25.000000
}
