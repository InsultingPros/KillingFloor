//=============================================================================
// PipeBombPickup Pickup.
//=============================================================================
class PipeBombPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=1500
     AmmoCost=750
     BuyClipSize=1
     PowerValue=100
     SpeedValue=5
     RangeValue=15
     Description="An improvised proximity explosive. Blows up when enemies get close."
     ItemName="Pipe Bomb"
     ItemShortName="Pipe Bomb"
     AmmoItemName="Pipe Bomb"
     showMesh=SkeletalMesh'KF_Weapons3rd2_Trip.pipebomb_3rd'
     CorrespondingPerkIndex=6
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.PipeBombExplosive'
     PickupMessage="You got the PipeBomb proximity explosive."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.Pipebomb_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
