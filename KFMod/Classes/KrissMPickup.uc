//=============================================================================
// KrissMPickup
//=============================================================================
// Pickup class for the Kriss Medic Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KrissMPickup extends MedicGunPickup;

defaultproperties
{
     Weight=3.000000
     cost=2750
     AmmoCost=10
     BuyClipSize=40
     PowerValue=50
     SpeedValue=90
     RangeValue=40
     Description="The 'Zekk has a very high rate of fire and is equipped with the attachment for the Horzine medical darts."
     ItemName="Schneidzekk Medic Gun"
     ItemShortName="Schneidzekk"
     AmmoItemName="45. ACP Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     EquipmentCategoryID=3
     VariantClasses(0)=Class'KFMod.NeonKrissMPickup'
     InventoryType=Class'KFMod.KrissMMedicGun'
     PickupMessage="You got the Schneidzekk Medic Gun"
     PickupSound=Sound'KF_KrissSND.Handling.KF_WEP_KRISS_Handling_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups6_Trip.Rifles.Kriss_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
