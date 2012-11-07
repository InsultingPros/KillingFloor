//=============================================================================
// M14EBR Ammo.
//=============================================================================
class M14EBRAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=20
     MaxAmmo=160
     InitialAmount=60
     PickupClass=Class'KFMod.M14EBRAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="M14EBR bullets"
}
