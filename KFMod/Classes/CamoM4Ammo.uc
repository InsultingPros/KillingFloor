//=============================================================================
// CamoM4Ammo
//=============================================================================
// Ammo for the M4 assault rifle primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class CamoM4Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=400
     InitialAmount=160
     PickupClass=Class'KFMod.CamoM4AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="M4 bullets"
}
