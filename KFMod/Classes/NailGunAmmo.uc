//=============================================================================
// NailGunAmmo
//=============================================================================
// Nail Gun ammo class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class NailGunAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=12
     MaxAmmo=48
     InitialAmount=24
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}
