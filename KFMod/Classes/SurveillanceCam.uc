class SurveillanceCam extends Decoration;     // Decoration

#exec OBJ LOAD FILE=KFMapObjects.ukx

simulated function PostBeginPlay()
{
    if( Level.NetMode != NM_DedicatedServer )
    {
        LinkSkelAnim(MeshAnimation'camera_rotation');
        LoopAnim('Cam_rotation');
    }
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.Trader_Cam'
}
