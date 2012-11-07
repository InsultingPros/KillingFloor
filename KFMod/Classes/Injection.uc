class Injection extends Decoration;

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var globalconfig bool bBlobShadow;


//#exec OBJ LOAD FILE=KFCharactersB.ukx

function PostBeginPlay() {
  //LinkSkelAnim(MeshAnimation'Injection');

    PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
    PlayerShadow.ShadowActor = self;
    PlayerShadow.bBlobShadow = bBlobShadow;
    PlayerShadow.LightDirection = Normal(vect(1,1,3));
    PlayerShadow.LightDistance = 320;
    PlayerShadow.MaxTraceDistance = 350;
    PlayerShadow.InitShadow();
    PlayerShadow.bShadowActive = true;
}


// Triggered / Secondary Anim

function Trigger( actor Other, pawn EventInstigator )
{
   PlayAnim('Inject',,0.1);
}

/*

// Call knockout anim on Pound. Probably a better way to do this but meh.

function CauseKnockOut()
{
 local ChainedPound CP;

 foreach AllActors(class'ChainedPound',CP,' PoundEscape');
  CP.PlayAnim('Needled',,0.1);
}
*/

defaultproperties
{
     DrawType=DT_StaticMesh
     bStatic=False
     bStasis=False
     bReplicateAnimations=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFCharactersB.Injection'
     bMovable=False
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
}
