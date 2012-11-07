// Spawns Trail on PostBeginPlay.

class ClotGibHead extends KFGib;

simulated function PostBeginPlay()
{
   SpawnTrail();
}

defaultproperties
{
     GibGroupClass=Class'KFMod.KFHumanGibGroup'
     TrailClass=Class'ROEffects.BloodTrail'
     DampenFactor=0.300000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'22Patch.ClotGibHead'
     Skins(0)=Texture'22CharTex.GibletsSkin'
     bUnlit=False
     TransientSoundVolume=25.000000
     CollisionRadius=5.000000
     CollisionHeight=2.500000
}
