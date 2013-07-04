class Deco_FerrisWheel extends Decoration;

#exec OBJ LOAD FILE=Pier_anim.ukx


simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Ferriswheel_Spin');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'Pier_anim.Ferriswheel'
}
