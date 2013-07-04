/*
	--------------------------------------------------------------
	KF_RotatingMeshActor
	--------------------------------------------------------------

    A simple actor used in the 2013 Summer SideShow map.

    it spins around.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_RotatingMeshActor extends Actor
placeable;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'OfficeStatics.AirConditioner'
     bUseDynamicLights=True
     bNoDelete=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_None
     bShadowCast=True
     bStaticLighting=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideActors=True
     bFixedRotationDir=True
     RotationRate=(Yaw=5000)
     bEdShouldSnap=True
}
