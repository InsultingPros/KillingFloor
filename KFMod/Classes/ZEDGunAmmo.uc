//=============================================================================
// ZEDGunAmmo
//=============================================================================
// Ammo for the ZEDGun primary fire
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDGunAmmo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=100
     MaxAmmo=400
     InitialAmount=200
     PickupClass=Class'KFMod.ZEDGunAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="ZED Gun Power Cells"
}
