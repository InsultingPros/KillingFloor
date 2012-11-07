//SoccerBallTwo as part of the GoodKarma package
//Build 8 Beta 4.5 Release
//By: Jonathan Zepp
//A basic demo of the beta 3 capabilities and new functionality for beta 4

#exec OBJ LOAD FILE=..\textures\HumanoidArchitecture.utx

class SoccerBallTwo extends NetKActor
 placeable;

defaultproperties
{
     bBlockedPath=False
     bCriticalObject=True
     RelativeImpactVolume=240
     ShoveModifier=1.400000
     DamageSpeed=550.000000
     HitDamageScale=0.700000
     StaticMesh=StaticMesh'GKStaticMeshes.basicShapes.BasicSphere'
     DrawScale=0.800000
     bUnlit=True
     Begin Object Class=KarmaParams Name=SoccerBallKarma
         KMass=0.200000
         KLinearDamping=0.150000
         KAngularDamping=0.100000
         KBuoyancy=1.800000
         bHighDetailOnly=False
         bDoSafetime=True
         KFriction=0.250000
         KRestitution=0.750000
     End Object
     KParams=KarmaParams'GoodKarma.SoccerBallTwo.SoccerBallKarma'

}
