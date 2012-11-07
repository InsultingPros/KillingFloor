// HuskGunAmmo
//=============================================================================
// Ammo for the Husk Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunAmmo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=25
     MaxAmmo=150
     InitialAmount=75
     PickupClass=Class'KFMod.HuskGunAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="Husk Gun Fuel"
}
