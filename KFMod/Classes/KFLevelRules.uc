//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFLevelRules extends ReplicationInfo
	placeable;

const       MAX_CATEGORY        = 5;
const       MAX_BUYITEMS        = 63;

struct EquipmentCategory
{
	var    byte    EquipmentCategoryID;
	var    string  EquipmentCategoryName;
};

var()       EquipmentCategory   EquipmentCategories[MAX_CATEGORY];
var(Shop)   class<Pickup>       ItemForSale[MAX_BUYITEMS];

var() float WaveSpawnPeriod;

defaultproperties
{
     EquipmentCategories(0)=(EquipmentCategoryName="Melee")
     EquipmentCategories(1)=(EquipmentCategoryID=1,EquipmentCategoryName="Secondary")
     EquipmentCategories(2)=(EquipmentCategoryID=2,EquipmentCategoryName="Primary")
     EquipmentCategories(3)=(EquipmentCategoryID=3,EquipmentCategoryName="Specials")
     EquipmentCategories(4)=(EquipmentCategoryID=4,EquipmentCategoryName="Equipment")
     ItemForSale(0)=Class'KFMod.MP7MPickup'
     ItemForSale(1)=Class'KFMod.MP5MPickup'
     ItemForSale(2)=Class'KFMod.M7A3MPickup'
     ItemForSale(3)=Class'KFMod.ShotgunPickup'
     ItemForSale(4)=Class'KFMod.KSGPickup'
     ItemForSale(5)=Class'KFMod.BoomStickPickup'
     ItemForSale(6)=Class'KFMod.BenelliPickup'
     ItemForSale(7)=Class'KFMod.LAWPickup'
     ItemForSale(8)=Class'KFMod.AA12Pickup'
     ItemForSale(9)=Class'KFMod.NailGunPickup'
     ItemForSale(10)=Class'KFMod.SinglePickup'
     ItemForSale(11)=Class'KFMod.DualiesPickup'
     ItemForSale(12)=Class'KFMod.MK23Pickup'
     ItemForSale(13)=Class'KFMod.DualMK23Pickup'
     ItemForSale(14)=Class'KFMod.Magnum44Pickup'
     ItemForSale(15)=Class'KFMod.Dual44MagnumPickup'
     ItemForSale(16)=Class'KFMod.DeaglePickup'
     ItemForSale(17)=Class'KFMod.DualDeaglePickup'
     ItemForSale(18)=Class'KFMod.WinchesterPickup'
     ItemForSale(19)=Class'KFMod.CrossbowPickup'
     ItemForSale(20)=Class'KFMod.M14EBRPickup'
     ItemForSale(21)=Class'KFMod.M99Pickup'
     ItemForSale(22)=Class'KFMod.BullpupPickup'
     ItemForSale(23)=Class'KFMod.AK47Pickup'
     ItemForSale(24)=Class'KFMod.MKb42Pickup'
     ItemForSale(25)=Class'KFMod.M4Pickup'
     ItemForSale(26)=Class'KFMod.SCARMK17Pickup'
     ItemForSale(27)=Class'KFMod.FNFAL_ACOG_Pickup'
     ItemForSale(28)=Class'KFMod.ThompsonPickup'
     ItemForSale(30)=Class'KFMod.KnifePickup'
     ItemForSale(31)=Class'KFMod.MachetePickup'
     ItemForSale(32)=Class'KFMod.AxePickup'
     ItemForSale(33)=Class'KFMod.ChainsawPickup'
     ItemForSale(34)=Class'KFMod.KatanaPickup'
     ItemForSale(35)=Class'KFMod.ClaymoreSwordPickup'
     ItemForSale(36)=Class'KFMod.CrossbuzzsawPickup'
     ItemForSale(37)=Class'KFMod.ScythePickup'
     ItemForSale(38)=Class'KFMod.FlameThrowerPickup'
     ItemForSale(39)=Class'KFMod.TrenchgunPickup'
     ItemForSale(40)=Class'KFMod.FlareRevolverPickup'
     ItemForSale(41)=Class'KFMod.DualFlareRevolverPickup'
     ItemForSale(42)=Class'KFMod.MAC10Pickup'
     ItemForSale(43)=Class'KFMod.HuskGunPickup'
     ItemForSale(44)=Class'KFMod.PipeBombPickup'
     ItemForSale(45)=Class'KFMod.M79Pickup'
     ItemForSale(46)=Class'KFMod.M32Pickup'
     ItemForSale(47)=Class'KFMod.M4203Pickup'
     WaveSpawnPeriod=2.000000
}
