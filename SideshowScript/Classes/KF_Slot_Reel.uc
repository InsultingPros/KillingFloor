/*
	--------------------------------------------------------------
	KF_Slot_Reel
	--------------------------------------------------------------

	Reel Actor used in conjunction with KF_Slot_Machines.
    It spins around.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_Slot_Reel extends Actor
placeable;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Props_ObjectiveMode.Slot_Reel'
     Physics=PHYS_Rotating
     NetUpdateFrequency=5.000000
     bUnlit=True
     RotationRate=(Roll=190000)
}
