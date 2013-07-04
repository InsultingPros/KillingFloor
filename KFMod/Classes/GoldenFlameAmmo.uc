//=============================================================================
// Fuel
//=============================================================================
class GoldenFlameAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=80
     MaxAmmo=400
     InitialAmount=400
     PickupClass=Class'KFMod.GoldenFTAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="Fuel Canisters"
}
