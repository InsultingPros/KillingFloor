class KFDecoTrampoline extends Decoration;     // Decoration

#exec OBJ LOAD FILE=HillbillyHorror_anim.ukx

var bool bTriggered;

simulated function Trigger( actor Other, pawn EventInstigator )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
	// function PlayAnim(name AnimName, optional float Duration, optional bool bLoop, optional bool bRestartIfAlreadyPlaying = true, optional float StartTime=0.0f, optional bool bPlayBackwards=false)
		PlayAnim('Trampoline_Animation');
	}

	bClientTrigger = !bClientTrigger;
}

simulated event ClientTrigger()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim('Trampoline_Animation');
	}
}

defaultproperties
{
     bStatic=False
     bStasis=False
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.500000
     Mesh=SkeletalMesh'HillbillyHorror_anim.Trampoline_Anim'
     bClientAnim=True
}
