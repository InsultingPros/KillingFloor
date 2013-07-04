//=============================================================================
// ThompsonDrum Pickup.
//=============================================================================
class ThompsonDrumPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.000000
     cost=975
     AmmoCost=15
     BuyClipSize=50
     PowerValue=35
     SpeedValue=80
     RangeValue=45
     Description="This Tommy gun with a drum magazine was used heavily during the WWII pacific battles as seen in Rising Storm."
     ItemName="Rising Storm Tommy Gun"
     ItemShortName="R.S. Tommy Gun"
     AmmoItemName="45. ACP Ammo"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.AK47_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.ThompsonDrumSMG'
     PickupMessage="You got the Rising Storm Thompson with Drum Mag"
     PickupSound=Sound'KF_IJC_HalloweenSnd.Handling.Thompson_Handling_Bolt_Back'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Summer_Weps.Thompson_Drum'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
