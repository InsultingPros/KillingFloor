// Spawns Trail on PostBeginPlay.

class GibHeadStump extends KFGib;

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
     StaticMesh=StaticMesh'22Patch.Severed_Head'
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=10.000000
     LifeSpan=9999.000000
     DrawScale=0.600000
     Skins(0)=Texture'22CharTex.SeveredSkin'
     bUnlit=False
     TransientSoundVolume=25.000000
     CollisionRadius=5.000000
     CollisionHeight=2.500000
}
