//=============================================================================
// L85 Ammo.
//=============================================================================
class BullpupAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     MaxAmmo=400
     InitialAmount=160
     PickupClass=Class'KFMod.BullpupAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="Bullpup bullets"
}
