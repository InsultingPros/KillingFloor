class CrossbuzzsawPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=WeaponStaticMesh.usx

defaultproperties
{
     Weight=7.000000
     cost=2500
     BuyClipSize=1
     PowerValue=80
     SpeedValue=30
     RangeValue=40
     Description="The Buzzsaw Bow is no ordinary crossbow. Why shoot little bolts when you can send a circular sawblade spinning instead?"
     ItemName="Buzzsaw Bow"
     ItemShortName="Buzzsaw Bow"
     AmmoItemName="Saw Blades"
     showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Crossbow_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=4
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.Crossbuzzsaw'
     PickupMessage="You got the Cheetah."
     PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps.cheetah_pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
