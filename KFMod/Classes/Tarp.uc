class Tarp extends Decoration;     // Decoration

#exec OBJ LOAD FILE=KFMapObjects.ukx

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('bLow');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.Tarp'
}
