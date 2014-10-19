class AnimatedRachel extends Decoration;     // Decoration

#exec OBJ LOAD FILE=KF_RachelC_anim.ukx

var bool bTriggered;
var bool bTriggeredAnimation;

simulated function PostBeginPlay()
{
If ( Level.NetMode != NM_DedicatedServer)
	{
		LoopAnim('Idle_Fidget');
	}
}

simulated function Trigger( actor Other, pawn EventInstigator )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!bTriggeredAnimation)
		{
			bTriggeredAnimation = TRUE;
			LoopAnim('Idle_Gesticulate');
		}
		ELSE
		{
			bTriggeredAnimation = FALSE;
			LoopAnim('Idle_Fidget');
		}
	}

	bClientTrigger = !bClientTrigger;

}

simulated event ClientTrigger()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!bTriggeredAnimation)
		{
			bTriggeredAnimation = TRUE;
			LoopAnim('Idle_Gesticulate');
		}
		ELSE
		{
			bTriggeredAnimation = FALSE;
			LoopAnim('Idle_Fidget');
		}
	}
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.500000
     Mesh=SkeletalMesh'KF_RachelC_anim.RachelC_mesh'
}
