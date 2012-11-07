//=============================================================================
// Thompson Pickup.
//=============================================================================
class ThompsonPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.000000
     cost=900
     AmmoCost=10
     BuyClipSize=30
     PowerValue=35
     SpeedValue=80
     RangeValue=45
     Description="The Thompson sub-machine gun. An absolute classic of design and functionality, beloved by soldiers and gangsters for decades!"
     ItemName="Tommy Gun"
     ItemShortName="Tommy Gun"
     AmmoItemName="45. ACP Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.AK47_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.ThompsonSMG'
     PickupMessage="You got the Thompson"
     PickupSound=Sound'KF_IJC_HalloweenSnd.Handling.Thompson_Handling_Bolt_Back'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps.thompson_pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
