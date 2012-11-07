//=============================================================================
// M99Ammo
//=============================================================================
// M99 Sniper Rifle ammo class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class M99Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=2
     MaxAmmo=25
     InitialAmount=5
     PickupClass=Class'KFMod.M99AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="50 Cal Bullets"
}
