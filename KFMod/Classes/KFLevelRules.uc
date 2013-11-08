//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFLevelRules extends ReplicationInfo
    config
	placeable;

const       MAX_CATEGORY        = 5;
const       MAX_BUYITEMS        = 63;

struct EquipmentCategory
{
	var    byte    EquipmentCategoryID;
	var    string  EquipmentCategoryName;
};

var()       EquipmentCategory   EquipmentCategories[MAX_CATEGORY];
//var(Shop)   class<Pickup>       ItemForSale[MAX_BUYITEMS];
var         array< class<Pickup> >      ItemForSale;

var(Shop)   array< class<Pickup> >      MediItemForSale;
var(Shop)   array< class<Pickup> >      SuppItemForSale;
var(Shop)   array< class<Pickup> >      ShrpItemForSale;
var(Shop)   array< class<Pickup> >      CommItemForSale;
var(Shop)   array< class<Pickup> >      BersItemForSale;
var(Shop)   array< class<Pickup> >      FireItemForSale;
var(Shop)   array< class<Pickup> >      DemoItemForSale;
var(Shop)   array< class<Pickup> >      NeutItemForSale;

var globalconfig  array< class<Pickup> >      FaveItemForSale;

var() float WaveSpawnPeriod;

simulated function bool IsFavorited( class<Pickup> Item )
{
    local int i;

    for( i = 0; i < FaveItemForSale.Length; ++i )
    {
        if( Item == FaveItemForSale[i] )
        {
            return true;
        }
    }

    return false;
}

simulated function AddToFavorites( class<Pickup> Item )
{
    local class<KFWeaponPickup> WeaponPickupClass;

    WeaponPickupClass = class<KFWeaponPickup>( Item );
    if( WeaponPickupClass != none )
    {
        FaveItemForSale[ FaveItemForSale.Length ] = WeaponPickupClass;
        SaveFavorites();
    }
}

simulated function RemoveFromFavorites( class<Pickup> Item )
{
    local int i;

    for( i = 0; i < FaveItemForSale.Length; ++i )
    {
        if( Item == FaveItemForSale[i] )
        {
            FaveItemForSale.Remove(i, 1);
            break;
        }
    }

    SaveFavorites();
}

simulated function SaveFavorites()
{
    SaveConfig();
}

defaultproperties
{
     EquipmentCategories(0)=(EquipmentCategoryName="Melee")
     EquipmentCategories(1)=(EquipmentCategoryID=1,EquipmentCategoryName="Secondary")
     EquipmentCategories(2)=(EquipmentCategoryID=2,EquipmentCategoryName="Primary")
     EquipmentCategories(3)=(EquipmentCategoryID=3,EquipmentCategoryName="Specials")
     EquipmentCategories(4)=(EquipmentCategoryID=4,EquipmentCategoryName="Equipment")
     MediItemForSale(0)=Class'KFMod.MP7MPickup'
     MediItemForSale(1)=Class'KFMod.BlowerThrowerPickup'
     MediItemForSale(2)=Class'KFMod.MP5MPickup'
     MediItemForSale(3)=Class'KFMod.CamoMP5MPickup'
     MediItemForSale(4)=Class'KFMod.M7A3MPickup'
     MediItemForSale(5)=Class'KFMod.KrissMPickup'
     SuppItemForSale(0)=Class'KFMod.ShotgunPickup'
     SuppItemForSale(1)=Class'KFMod.CamoShotgunPickup'
     SuppItemForSale(2)=Class'KFMod.BoomStickPickup'
     SuppItemForSale(3)=Class'KFMod.KSGPickup'
     SuppItemForSale(4)=Class'KFMod.NailGunPickup'
     SuppItemForSale(5)=Class'KFMod.SPShotgunPickup'
     SuppItemForSale(6)=Class'KFMod.BenelliPickup'
     SuppItemForSale(7)=Class'KFMod.GoldenBenelliPickup'
     SuppItemForSale(8)=Class'KFMod.AA12Pickup'
     SuppItemForSale(9)=Class'KFMod.GoldenAA12Pickup'
     ShrpItemForSale(0)=Class'KFMod.SinglePickup'
     ShrpItemForSale(1)=Class'KFMod.DualiesPickup'
     ShrpItemForSale(2)=Class'KFMod.WinchesterPickup'
     ShrpItemForSale(3)=Class'KFMod.Magnum44Pickup'
     ShrpItemForSale(4)=Class'KFMod.DeaglePickup'
     ShrpItemForSale(5)=Class'KFMod.GoldenDeaglePickup'
     ShrpItemForSale(6)=Class'KFMod.MK23Pickup'
     ShrpItemForSale(7)=Class'KFMod.CrossbowPickup'
     ShrpItemForSale(8)=Class'KFMod.Dual44MagnumPickup'
     ShrpItemForSale(9)=Class'KFMod.DualMK23Pickup'
     ShrpItemForSale(10)=Class'KFMod.DualDeaglePickup'
     ShrpItemForSale(11)=Class'KFMod.GoldenDualDeaglePickup'
     ShrpItemForSale(12)=Class'KFMod.SPSniperPickup'
     ShrpItemForSale(13)=Class'KFMod.M14EBRPickup'
     ShrpItemForSale(14)=Class'KFMod.M99Pickup'
     CommItemForSale(0)=Class'KFMod.BullpupPickup'
     CommItemForSale(1)=Class'KFMod.ThompsonPickup'
     CommItemForSale(2)=Class'KFMod.SPThompsonPickup'
     CommItemForSale(3)=Class'KFMod.ThompsonDrumPickup'
     CommItemForSale(4)=Class'KFMod.AK47Pickup'
     CommItemForSale(5)=Class'KFMod.GoldenAK47pickup'
     CommItemForSale(6)=Class'KFMod.M4Pickup'
     CommItemForSale(7)=Class'KFMod.CamoM4Pickup'
     CommItemForSale(8)=Class'KFMod.MKb42Pickup'
     CommItemForSale(9)=Class'KFMod.SCARMK17Pickup'
     CommItemForSale(10)=Class'KFMod.FNFAL_ACOG_Pickup'
     BersItemForSale(0)=Class'KFMod.KnifePickup'
     BersItemForSale(1)=Class'KFMod.MachetePickup'
     BersItemForSale(2)=Class'KFMod.AxePickup'
     BersItemForSale(3)=Class'KFMod.KatanaPickup'
     BersItemForSale(4)=Class'KFMod.GoldenKatanaPickup'
     BersItemForSale(5)=Class'KFMod.ScythePickup'
     BersItemForSale(6)=Class'KFMod.ChainsawPickup'
     BersItemForSale(7)=Class'KFMod.GoldenChainsawPickup'
     BersItemForSale(8)=Class'KFMod.DwarfAxePickup'
     BersItemForSale(9)=Class'KFMod.ClaymoreSwordPickup'
     BersItemForSale(10)=Class'KFMod.CrossbuzzsawPickup'
     FireItemForSale(0)=Class'KFMod.MAC10Pickup'
     FireItemForSale(1)=Class'KFMod.FlareRevolverPickup'
     FireItemForSale(2)=Class'KFMod.FlameThrowerPickup'
     FireItemForSale(3)=Class'KFMod.GoldenFTPickup'
     FireItemForSale(4)=Class'KFMod.DualFlareRevolverPickup'
     FireItemForSale(5)=Class'KFMod.TrenchgunPickup'
     FireItemForSale(6)=Class'KFMod.HuskGunPickup'
     DemoItemForSale(0)=Class'KFMod.M79Pickup'
     DemoItemForSale(1)=Class'KFMod.GoldenM79Pickup'
     DemoItemForSale(2)=Class'KFMod.SPGrenadePickup'
     DemoItemForSale(3)=Class'KFMod.PipeBombPickup'
     DemoItemForSale(4)=Class'KFMod.SealSquealPickup'
     DemoItemForSale(5)=Class'KFMod.SeekerSixPickup'
     DemoItemForSale(6)=Class'KFMod.M4203Pickup'
     DemoItemForSale(7)=Class'KFMod.LAWPickup'
     DemoItemForSale(8)=Class'KFMod.M32Pickup'
     DemoItemForSale(9)=Class'KFMod.CamoM32Pickup'
     NeutItemForSale(0)=Class'KFMod.ZEDMKIIPickup'
     NeutItemForSale(1)=Class'KFMod.ZEDGunPickup'
     WaveSpawnPeriod=2.000000
}
