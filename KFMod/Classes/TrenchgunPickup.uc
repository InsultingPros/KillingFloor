//=============================================================================
// Trenchgun Pickup.
//=============================================================================
class TrenchgunPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=8.000000
     cost=1250
     BuyClipSize=6
     PowerValue=75
     SpeedValue=40
     RangeValue=15
     Description="A WWII era trench shotgun. Oh, this one has been filled with dragon's breath flame rounds."
     ItemName="Trenchgun"
     ItemShortName="Trenchgun"
     AmmoItemName="Dragon's breath shells"
     CorrespondingPerkIndex=5
     EquipmentCategoryID=2
     InventoryType=Class'KFMod.TrenchGun'
     PickupMessage="You got the Trenchgun."
     PickupSound=Sound'KF_ShotgunDragonsBreathSnd.Handling.TrenchGun_Pump_Back'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups5_Trip.Rifles.TrenchGun_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
