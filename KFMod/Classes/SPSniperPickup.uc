//=============================================================================
// SPSniperPickup
//=============================================================================
// Steampunk Sniper Rifle Pickup.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPSniperPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=1500
     BuyClipSize=10
     PowerValue=60
     SpeedValue=10
     RangeValue=95
     Description="A finely crafted long rifle from the Victorian era fitted with telescopic aiming optics."
     ItemName="Single Piston Longmusket"
     ItemShortName="S.P. Musket"
     AmmoItemName="S.P. Musket bullets"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.SPSniperRifle'
     PickupMessage="You got the Single Piston Longmusket"
     PickupSound=Sound'KF_SP_LongmusketSnd.KFO_Sniper_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Summer_Weps.SniperRifle'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
