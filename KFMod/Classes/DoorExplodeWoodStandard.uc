//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DoorExplodeWoodStandard extends DoorExplode
	Abstract;

defaultproperties
{
     ShrapnelAreaHeight=150.000000
     ShrapnelAreaWidth=80.000000
     GibSpeed=150.000000
     DoorGibClasses(0)=Class'KFMod.DoorGibWoodA'
     DoorGibClasses(1)=Class'KFMod.DoorGibWoodB'
     DoorGibClasses(2)=Class'KFMod.DoorGibWoodC'
     DoorGibClasses(3)=Class'KFMod.DoorGibWoodD'
     DoorDustClass=Class'KFMod.KFDoorExplosionDustWood'
     SpreadFactor=0.700000
}
