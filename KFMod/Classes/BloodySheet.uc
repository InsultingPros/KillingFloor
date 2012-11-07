class BloodySheet extends Decoration;

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Sway');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.BloodySheet'
}
