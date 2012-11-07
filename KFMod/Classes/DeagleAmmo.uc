//=============================================================================
// Deagle Ammo.
//=============================================================================
class DeagleAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     AmmoPickupAmount=16
     MaxAmmo=96
     InitialAmount=48
     PickupClass=Class'KFMod.DeagleAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="Deagle bullets"
}
