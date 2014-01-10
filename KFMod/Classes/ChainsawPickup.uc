//=============================================================================
// ChainsawPickup
//=============================================================================
// Chainsaw pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ChainsawPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=8.000000
     cost=2750
     PowerValue=60
     SpeedValue=90
     RangeValue=-25
     Description="A gas powered industrial strength chainsaw. This tool may rely on a steady supply of gasoline, but it can cut through a variety of surfaces with ease."
     ItemName="Chainsaw"
     ItemShortName="Chainsaw"
     CorrespondingPerkIndex=4
     VariantClasses(0)=Class'KFMod.GoldenChainsawPickup'
     InventoryType=Class'KFMod.Chainsaw'
     PickupMessage="You got the Chainsaw."
     PickupSound=Sound'KF_ChainsawSnd.Chainsaw_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.Chainsaw_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=10.000000
}
