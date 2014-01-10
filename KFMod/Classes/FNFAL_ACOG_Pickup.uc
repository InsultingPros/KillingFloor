//=============================================================================
// FN FAL Pickup.
//=============================================================================
class FNFAL_ACOG_Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=2750
     AmmoCost=15
     BuyClipSize=20
     PowerValue=45
     SpeedValue=90
     RangeValue=70
     Description="Classic NATO battle rifle. Has a high rate of fire and decent accuracy, with good power."
     ItemName="FNFAL ACOG"
     ItemShortName="FNFAL ACOG"
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.FNFAL_ACOG_AssaultRifle'
     PickupMessage="You got the FN FAL with ACOG Sight"
     PickupSound=Sound'KF_FNFALSnd.FNFAL_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups4_Trip.Rifles.Fal_Acog_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
