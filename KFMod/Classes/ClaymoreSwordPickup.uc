//=============================================================================
// ClaymoreSwordPickup
//=============================================================================
// Claymore sword pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ClaymoreSwordPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=3000
     PowerValue=75
     SpeedValue=40
     RangeValue=-23
     Description="A medieval claymore sword."
     ItemName="Claymore Sword"
     ItemShortName="Claymore"
     CorrespondingPerkIndex=4
     InventoryType=Class'KFMod.ClaymoreSword'
     PickupMessage="You got the Claymore Sword."
     PickupSound=Sound'KF_ClaymoreSnd.foley.WEP_Claymore_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups3_Trip.melee.Claymore_Pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
