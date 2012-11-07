class Flag extends Decoration;

#exec OBJ LOAD FILE=KFMapObjects.ukx

function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Fly');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.flag'
}
