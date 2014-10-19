//=============================================================================
// Neon SCARMK17 Ammo.
//=============================================================================
class NeonSCARMK17Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=20
     MaxAmmo=300
     InitialAmount=120
     PickupClass=Class'KFMod.NeonSCARMK17AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="SCARMK17 bullets"
}
