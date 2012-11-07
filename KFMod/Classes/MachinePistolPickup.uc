//=============================================================================
// Machine Pistol Pickup
//=============================================================================
class MachinePistolPickup extends KFWeaponPickup ;

defaultproperties
{
     Weight=4.000000
     cost=300
     AmmoCost=10
     BuyClipSize=40
     PowerValue=20
     SpeedValue=80
     RangeValue=35
     Description="A 9mm machine pistol."
     ItemName="Machine Pistol"
     ItemShortName="Machine Pistol"
     InventoryType=Class'KFMod.MachinePistol'
     PickupMessage="You got the Machine Pistol"
     StaticMesh=StaticMesh'22Patch.9mmGround'
     CollisionHeight=5.000000
}
