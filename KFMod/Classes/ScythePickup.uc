//=============================================================================
// Scythe Pickup.
//=============================================================================
class ScythePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=6.000000
     cost=2500
     PowerValue=70
     SpeedValue=25
     RangeValue=-20
     Description="It's a scythe. Long handle. Long blade. Good for reaping corn, wheat - or shambling monsters."
     ItemName="Scythe"
     ItemShortName="Scythe"
     CorrespondingPerkIndex=4
     InventoryType=Class'KFMod.Scythe'
     PickupMessage="You got the Scythe."
     PickupSound=SoundGroup'KF_KatanaSnd.Katana_Select'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_IJC_Halloween_Weps.scythe_pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
