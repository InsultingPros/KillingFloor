//=============================================================================
// 9mm Ammo.
//=============================================================================
class SingleAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=240
     InitialAmount=120
     PickupClass=Class'KFMod.SingleAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="9mm bullets"
}
