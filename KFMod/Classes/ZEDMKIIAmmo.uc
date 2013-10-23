//=============================================================================
// ZEDMKIIPickup
//=============================================================================
// Ammo class for the Zed Gun Mark II Weapon
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIIAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=240
     InitialAmount=120
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}
