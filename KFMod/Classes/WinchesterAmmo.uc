//=============================================================================
// Winchester Rifle Ammo.
//=============================================================================
class WinchesterAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     AmmoPickupAmount=10
     MaxAmmo=80
     InitialAmount=40
     PickupClass=Class'KFMod.WinchesterAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="Rifle bullets"
}
