//=============================================================================
// MKb42 Ammo.
//=============================================================================
class MKb42Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=300
     InitialAmount=120
     PickupClass=Class'KFMod.MKb42AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="MKb42 bullets"
}
