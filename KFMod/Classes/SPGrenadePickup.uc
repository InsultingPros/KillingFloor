//=============================================================================
// SPGrenadePickup
//=============================================================================
// Steampunk Grenade Launcher Pickup.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPGrenadePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=1250
     AmmoCost=10
     BuyClipSize=3
     PowerValue=85
     SpeedValue=5
     RangeValue=75
     Description="The Orca Bomb Propeller tosses little delayed explosive bombs. Good for those bank shots!"
     ItemName="The Orca Bomb Propeller"
     ItemShortName="The Orca"
     AmmoItemName="Orca Bombs"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=6
     EquipmentCategoryID=2
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.SPGrenadeLauncher'
     PickupMessage="You got The Orca Bomb Propeller."
     PickupSound=Sound'KF_SP_OrcaSnd.KFO_Orca_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Summer_Weps.Grenade'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
