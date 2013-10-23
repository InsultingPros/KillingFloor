class M79Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=1250
     AmmoCost=10
     BuyClipSize=3
     PowerValue=85
     SpeedValue=5
     RangeValue=75
     Description="A classic Vietnam era grenade launcher. Launches single high explosive grenades."
     ItemName="M79 Grenade Launcher"
     ItemShortName="M79 Launcher"
     AmmoItemName="M79 Grenades"
     showMesh=SkeletalMesh'KF_Weapons3rd2_Trip.M79_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=6
     EquipmentCategoryID=2
     VariantClasses(0)=Class'KFMod.GoldenM79Pickup'
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.M79GrenadeLauncher'
     PickupMessage="You got the M79 Grenade Launcher."
     PickupSound=Sound'KF_M79Snd.M79_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.M79_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
