class MechanicalManDance extends Decoration;     // Decoration

#exec OBJ LOAD FILE=KF_RobotDance.ukx
#exec OBJ LOAD FILE=AbusementParkSND.uax

var bool bTriggered;

simulated function Trigger( actor Other, pawn EventInstigator )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim('RobotDance');
		PlaySound(Sound'AbusementParkSND.MechanicalDancer.breakbeat_freak', SLOT_Misc, 2.0,,500.0);
	}

	bClientTrigger = !bClientTrigger;
}

simulated event ClientTrigger()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim('RobotDance');
		PlaySound(Sound'AbusementParkSND.MechanicalDancer.breakbeat_freak', SLOT_Misc, 2.0,,500.0);
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
     Mesh=SkeletalMesh'KF_RobotDance.Circus_Husk_Deco'
     DrawScale=1.400000
}
