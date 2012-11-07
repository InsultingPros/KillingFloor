//=============================================================================
// Machine Pistol Ammo.
//=============================================================================
class MPistolAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     AmmoPickupAmount=64
     MaxAmmo=320
     InitialAmount=320
     PickupClass=Class'KFMod.SingleAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="9mm bullets"
}
