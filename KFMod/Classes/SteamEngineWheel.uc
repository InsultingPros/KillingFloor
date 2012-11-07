class SteamEngineWheel extends Decoration;     // Decoration

#exec OBJ LOAD FILE=Foundry_anim.ukx

simulated function PostBeginPlay()
{
    if( Level.NetMode != NM_DedicatedServer )
    {
        LoopAnim('Wheel_rotation');
    }
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     Mesh=SkeletalMesh'Foundry_anim.Steamengine_Wheel'
}
