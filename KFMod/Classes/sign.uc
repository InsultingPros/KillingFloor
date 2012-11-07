class Sign extends Decoration;

#exec OBJ LOAD FILE=KFMapObjects.ukx

simulated function PostBeginPlay()
{
	LoopAnim('swing');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.sign'
}
