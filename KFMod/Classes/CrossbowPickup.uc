class CrossbowPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=WeaponStaticMesh.usx

defaultproperties
{
     Weight=9.000000
     cost=800
     BuyClipSize=6
     PowerValue=64
     SpeedValue=50
     RangeValue=100
     Description="Recreational hunting weapon, equipped with powerful scope and firing trigger. Exceptional headshot damage."
     ItemName="Crossbow"
     ItemShortName="Crossbow"
     AmmoItemName="Crossbow Bolts"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.Crossbow'
     PickupMessage="You got the Xbow."
     PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Rifle.crossbow_pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
