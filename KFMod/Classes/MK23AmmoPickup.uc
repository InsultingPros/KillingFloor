//=============================================================================
// MK23AmmoPickup
//=============================================================================
// Ammo pickup class for the MK23 Pistol
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC Development
//=============================================================================
class MK23AmmoPickup extends KFAmmoPickup;

defaultproperties
{
     KFPickupImage=Texture'KillingFloorHUD.ClassMenu.Deagle'
     AmmoAmount=12
     InventoryType=Class'KFMod.MK23Ammo'
     PickupMessage="Rounds (.45 ACP)"
     StaticMesh=None
}
