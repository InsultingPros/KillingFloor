//=============================================================================
// My Potato
//=============================================================================
class Potato extends KFWeaponPickup
	notplaceable;

defaultproperties
{
     Weight=0.000000
     cost=70000
     PowerValue=100
     SpeedValue=100
     RangeValue=100
     Description="Potato"
     ItemName="Potato"
     ItemShortName="Potato"
     CorrespondingPerkIndex=7
     EquipmentCategoryID=10
     PickupMessage="You gots a Potato"
     PickupSound=SoundGroup'KF_InventorySnd.Cash_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'Potato_S.Potato'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
