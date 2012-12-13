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
     ItemForSale(3)=Class'KFMod.KrissMPickup'
     ItemForSale(4)=Class'KFMod.ShotgunPickup'
     ItemForSale(5)=Class'KFMod.BoomStickPickup'
     ItemForSale(6)=Class'KFMod.KSGPickup'
     ItemForSale(7)=Class'KFMod.NailGunPickup'
     ItemForSale(8)=Class'KFMod.BenelliPickup'
     ItemForSale(9)=Class'KFMod.GoldenBenelliPickup'
     ItemForSale(10)=Class'KFMod.AA12Pickup'
     ItemForSale(11)=Class'KFMod.SinglePickup'
     ItemForSale(12)=Class'KFMod.DualiesPickup'
     ItemForSale(13)=Class'KFMod.WinchesterPickup'
     ItemForSale(14)=Class'KFMod.Magnum44Pickup'
     ItemForSale(15)=Class'KFMod.DeaglePickup'
     ItemForSale(16)=Class'KFMod.MK23Pickup'
     ItemForSale(17)=Class'KFMod.CrossbowPickup'
     ItemForSale(18)=Class'KFMod.Dual44MagnumPickup'
     ItemForSale(19)=Class'KFMod.DualMK23Pickup'
     ItemForSale(20)=Class'KFMod.DualDeaglePickup'
     ItemForSale(21)=Class'KFMod.M14EBRPickup'
     ItemForSale(22)=Class'KFMod.M99Pickup'
     ItemForSale(23)=Class'KFMod.BullpupPickup'
     ItemForSale(24)=Class'KFMod.ThompsonPickup'
     ItemForSale(25)=Class'KFMod.AK47Pickup'
     ItemForSale(26)=Class'KFMod.GoldenAK47pickup'
     ItemForSale(27)=Class'KFMod.M4Pickup'
     ItemForSale(28)=Class'KFMod.MKb42Pickup'
     ItemForSale(29)=Class'KFMod.SCARMK17Pickup'
     ItemForSale(30)=Class'KFMod.FNFAL_ACOG_Pickup'
     ItemForSale(31)=Class'KFMod.KnifePickup'
     ItemForSale(32)=Class'KFMod.MachetePickup'
     ItemForSale(34)=Class'KFMod.AxePickup'
     ItemForSale(35)=Class'KFMod.KatanaPickup'
     ItemForSale(36)=Class'KFMod.GoldenKatanaPickup'
     ItemForSale(37)=Class'KFMod.ScythePickup'
     ItemForSale(38)=Class'KFMod.ChainsawPickup'
     ItemForSale(39)=Class'KFMod.DwarfAxePickup'
     ItemForSale(40)=Class'KFMod.ClaymoreSwordPickup'
     ItemForSale(41)=Class'KFMod.CrossbuzzsawPickup'
     ItemForSale(42)=Class'KFMod.MAC10Pickup'
     ItemForSale(43)=Class'KFMod.FlareRevolverPickup'
     ItemForSale(44)=Class'KFMod.FlameThrowerPickup'
     ItemForSale(45)=Class'KFMod.DualFlareRevolverPickup'
     ItemForSale(46)=Class'KFMod.TrenchgunPickup'
     ItemForSale(47)=Class'KFMod.HuskGunPickup'
     ItemForSale(48)=Class'KFMod.M79Pickup'
     ItemForSale(49)=Class'KFMod.GoldenM79Pickup'
     ItemForSale(50)=Class'KFMod.PipeBombPickup'
     ItemForSale(51)=Class'KFMod.M32Pickup'
     ItemForSale(52)=Class'KFMod.LAWPickup'
     ItemForSale(53)=Class'KFMod.M4203Pickup'
     ItemForSale(54)=Class'KFMod.ZEDGunPickup'
     WaveSpawnPeriod=2.000000
}
