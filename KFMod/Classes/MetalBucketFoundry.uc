class MetalBucketFoundry extends Decoration;     // Decoration

#exec OBJ LOAD FILE=Foundry_anim.ukx

simulated function PostBeginPlay()
{
    if( Level.NetMode != NM_DedicatedServer )
    {
        LoopAnim('metal_puring');
    }
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     Mesh=SkeletalMesh'Foundry_anim.Metal_Bucket'
}
