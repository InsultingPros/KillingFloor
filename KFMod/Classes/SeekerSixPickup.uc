//=============================================================================
// SeekerSixPickup
//=============================================================================
// Pickup class for the SeekerSix mini rocket launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SeekerSixPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=7.000000
     cost=2250
     AmmoCost=15
     BuyClipSize=6
     PowerValue=90
     SpeedValue=65
     RangeValue=95
     Description="An advanced Horzine mini missile launcher. Fire one, or all six, lock on and let 'em rip!"
     ItemName="SeekerSix Rocket Launcher"
     ItemShortName="SeekerSix"
     AmmoItemName="SeekerSix Rockets"
     CorrespondingPerkIndex=6
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.SeekerSixRocketLauncher'
     PickupMessage="You got the SeekerSix Mini Rocket Launcher."
     PickupSound=Sound'KF_FY_SeekerSixSND.foley.WEP_SeekerSix_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps2.SeekerSix_Pickup'
     DrawScale=0.900000
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
