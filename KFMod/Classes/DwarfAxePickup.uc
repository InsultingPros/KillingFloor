//=============================================================================
// DwarfAxePickup
//=============================================================================
// Dwarf Axe pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DwarfAxePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=3000
     PowerValue=75
     SpeedValue=40
     RangeValue=-23
     Description="A battle axe like you might see in a game called Dwarfs!?"
     ItemName="Dwarfs!? Axe"
     ItemShortName="Dwarfs!? Axe"
     CorrespondingPerkIndex=4
     InventoryType=Class'KFMod.DwarfAxe'
     PickupMessage="You got the Dwarfs!? Axe."
     PickupSound=Sound'KF_DwarfAxeSnd.Handling.KF_WEP_DwarfAxe_Handling_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups6_Trip.Rifles.Dwarven_Axe_Pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
