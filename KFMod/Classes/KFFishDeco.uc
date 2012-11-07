class KFFishDeco extends Decoration;     // Decoration

#exec OBJ LOAD FILE=HillbillyHorror_anim.ukx

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('deadfish_anim');
}

defaultproperties
{
     bStatic=False
     bStasis=False
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.500000
     Mesh=SkeletalMesh'HillbillyHorror_anim.deadfish_anim'
     bClientAnim=True
}
