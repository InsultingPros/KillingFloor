// Spawn Random items / weapons in to keep the envirments searchable and dynamic :)
// Modded from WildcardBase to allow for all pickup classtypes, not just tournament ones.
class KFRandomAmmoSpawn extends KFRandomSpawn;

defaultproperties
{
     PickupClasses(0)=Class'KFMod.SingleAmmoPickup'
     PickupClasses(1)=Class'KFMod.ShotgunAmmoPickup'
     PickupClasses(2)=Class'KFMod.BullpupAmmoPickup'
     PickupClasses(3)=Class'KFMod.DeagleAmmoPickup'
     PickupClasses(4)=Class'KFMod.WinchesterAmmoPickup'
     PickupClasses(5)=Class'KFMod.CrossbowAmmoPickup'
     PickupClasses(6)=Class'KFMod.LAWAmmoPickup'
     PickupClasses(7)=Class'KFMod.DBShotgunAmmoPickup'
     PickupClasses(8)=Class'KFMod.FragAmmoPickup'
     PickupClasses(9)=Class'KFMod.FTAmmoPickup'
     PickupClasses(10)=Class'KFMod.CashPickup'
     PickupWeight(0)=3
     PickupWeight(1)=3
     PickupWeight(2)=3
     PickupWeight(3)=3
     PickupWeight(4)=3
     PickupWeight(8)=3
     PickupWeight(9)=3
     Texture=Texture'PatchTex.Common.AmmoSpawnIcon'
}
