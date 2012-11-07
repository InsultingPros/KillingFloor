class ChainsawAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     bAcceptsAmmoPickups=False
     MaxAmmo=100
     InitialAmount=100
     PickupClass=Class'KFMod.ChainsawAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=179,Y1=127,X2=241,Y2=175)
     ItemName="can of gas"
}
