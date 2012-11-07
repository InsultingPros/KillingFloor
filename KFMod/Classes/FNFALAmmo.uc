//=============================================================================
// FNFALAmmo Ammo.
//=============================================================================
class FNFALAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=20
     MaxAmmo=300
     InitialAmount=120
     PickupClass=Class'KFMod.FNFALAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="FNFAL bullets"
}
