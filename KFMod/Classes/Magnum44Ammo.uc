//=============================================================================
// M4Ammo
//=============================================================================
// Ammo for the 44 Magnum pistol
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Magnum44Ammo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=18
     MaxAmmo=128
     InitialAmount=64
     PickupClass=Class'KFMod.Magnum44AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="44 Magnum bullets"
}
