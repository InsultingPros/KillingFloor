//=============================================================================
// CamoMP5MAmmo
//=============================================================================
// Ammo for the MP5 Medic Gun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoMP5MAmmo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=32
     MaxAmmo=400
     InitialAmount=200
     PickupClass=Class'KFMod.CamoMP5MAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="MP5M bullets"
}
