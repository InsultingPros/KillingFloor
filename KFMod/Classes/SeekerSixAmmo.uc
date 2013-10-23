//=============================================================================
// SeekerSixAmmo
//=============================================================================
// Ammunition class for the SeekerSix mini rocket launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SeekerSixAmmo extends KFAmmunition;

defaultproperties
{
     AmmoPickupAmount=6
     MaxAmmo=96
     InitialAmount=48
     PickupClass=Class'KFMod.SeekerSixAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="SeekerSix Rockets"
}
