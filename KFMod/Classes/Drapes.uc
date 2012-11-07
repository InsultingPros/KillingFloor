class Drapes extends Decoration;     // Decoration

#exec OBJ LOAD FILE=KFMapObjects.ukx

function PostBeginPlay() {
   LinkSkelAnim(MeshAnimation'Drapes');
   LoopAnim('Flap');

}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.Drapes'
}
