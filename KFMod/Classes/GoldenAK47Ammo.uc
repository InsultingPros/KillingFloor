class GoldenAK47Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
//duplication of ak47ammo

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=300
     InitialAmount=120
     PickupClass=Class'KFMod.GoldenAk47AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="AK47 bullets"
}
