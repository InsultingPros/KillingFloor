//=============================================================================
// SPSniperAmmoPickup
//=============================================================================
// Steampunk Sniper Rifle Ammo pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPSniperAmmoPickup extends KFAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     InventoryType=Class'KFMod.SPSniperAmmo'
     PickupMessage="S.P. Musket bullets"
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
