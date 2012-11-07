class Trader extends Decoration;

#exec OBJ LOAD FILE=KFMapObjects.ukx

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Idle');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.Trader'
}
