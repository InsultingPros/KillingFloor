//=============================================================================
// Thompson DrumMag Ammo.
//=============================================================================
class ThompsonDrumAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=50
     MaxAmmo=300
     InitialAmount=150
     PickupClass=Class'KFMod.ThompsonDrumAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="45. ACP bullets"
}
