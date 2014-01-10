//=============================================================================
// AA12 Shotgun Pickup.
//=============================================================================
class AA12Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=4000
     AmmoCost=40
     BuyClipSize=20
     PowerValue=85
     SpeedValue=65
     RangeValue=20
     Description="An advanced fully automatic shotgun."
     ItemName="AA12 Shotgun"
     ItemShortName="AA12 Shotgun"
     AmmoItemName="12-gauge drum"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     VariantClasses(0)=Class'KFMod.GoldenAA12Pickup'
     InventoryType=Class'KFMod.AA12AutoShotgun'
     PickupMessage="You got the AA12 auto shotgun."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Shotguns.AA12_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
