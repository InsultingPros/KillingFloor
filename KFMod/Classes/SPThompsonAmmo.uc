//=============================================================================
// SPThompsonAmmo
//=============================================================================
// Steampunk SMG Ammo
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     MaxAmmo=300
     InitialAmount=120
     PickupClass=Class'KFMod.SPThompsonAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="L.D.S. bullets"
}
