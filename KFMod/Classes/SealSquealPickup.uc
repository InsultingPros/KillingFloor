//=============================================================================
// SealSquealPickup
//=============================================================================
// Pickup class for the seal squeal harpoon bomb launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SealSquealPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     AmmoCost=30
     BuyClipSize=3
     PowerValue=90
     SpeedValue=35
     RangeValue=85
     Description="Shoot the zeds with this harpoon gun and watch them squeal.. and then explode!"
     ItemName="SealSqueal Harpoon Bomber"
     ItemShortName="SealSqueal"
     AmmoItemName="SealSqueal Harpoon Bombs"
     CorrespondingPerkIndex=6
     EquipmentCategoryID=2
     MaxDesireability=0.790000
     InventoryType=Class'KFMod.SealSquealHarpoonBomber'
     PickupMessage="You got the SealSqueal Harpoon Bomb Launcher."
     PickupSound=Sound'KF_FY_SealSquealSND.foley.WEP_Harpoon_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps2.SealSqueal_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
