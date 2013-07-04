//=============================================================================
// SPThompsonPickup
//=============================================================================
// Steampunk SMG Pickup
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.000000
     cost=950
     AmmoCost=12
     BuyClipSize=40
     PowerValue=35
     SpeedValue=80
     RangeValue=50
     Description="Thy weapon is before you. May it's drum beat a sound of terrible fear into your enemies."
     ItemName="Dr. T's Lead Delivery System"
     ItemShortName="Dr. T's L.D.S."
     AmmoItemName="L.D.S. Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.SPThompsonSMG'
     PickupMessage="You got Dr. T's Lead Dispensing System"
     PickupSound=Sound'KF_SP_ThompsonSnd.KFO_SP_Thompson_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Summer_Weps.Steampunk_Thompson'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
