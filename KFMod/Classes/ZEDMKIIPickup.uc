//=============================================================================
// ZEDMKIIPickup
//=============================================================================
// Pickup class for the Zed Gun Mark II Weapon
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIIPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=750
     AmmoCost=15
     BuyClipSize=30
     PowerValue=40
     SpeedValue=45
     RangeValue=75
     Description="The second revision of the ZED gun. Smaller and more light weight, but not quite as powerful as the original."
     ItemName="Zed Eradication Device MKII"
     ItemShortName="ZED GUN MKII"
     AmmoItemName="ZED MKII Power Cells"
     CorrespondingPerkIndex=7
     EquipmentCategoryID=3
     InventoryType=Class'KFMod.ZEDMKIIWeapon'
     PickupMessage="You got the Zed Eradication Device MKII."
     PickupSound=Sound'KF_FY_ZEDV2SND.foley.WEP_ZEDV2_Foley_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps2.ZEDV2_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
