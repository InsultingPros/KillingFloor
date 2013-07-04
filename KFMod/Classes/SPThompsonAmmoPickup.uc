//=============================================================================
// SPThompsonAmmoPickup
//=============================================================================
// Steampunk SMG Ammo pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=40
     InventoryType=Class'KFMod.SPThompsonAmmo'
     PickupMessage="L.D.S. Ammo"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
