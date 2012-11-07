//=============================================================================
// MP5MAmmo
//=============================================================================
// Ammo for the MP5 Medic Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MAmmo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=32
     MaxAmmo=400
     InitialAmount=200
     PickupClass=Class'KFMod.MP5MAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="MP5M bullets"
}
