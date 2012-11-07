class Scaff extends Decoration;

#exec OBJ LOAD FILE=KFMapObjects.ukx

function PostBeginPlay()
{
	LoopAnim('Flutter');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.Scaff'
}
