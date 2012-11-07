class KeyPad extends Decoration;

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var globalconfig bool bBlobShadow;


//#exec OBJ LOAD FILE=KFCharactersB.ukx

function PostBeginPlay() {
  //LinkSkelAnim(MeshAnimation'KeyPad');

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
   PlayAnim('PunchIn',,0.1);
}

// Button Illums :)  (I am obsessive, I know. But the effect will be flippin' sweet!)

function FirstButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad1' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

function SecondButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad14' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

function ThirdButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad146' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

function FourthButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad1468' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

function FifthButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad14683' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

function SixthButtonGlow()
{
 Skins[0] = Texture 'KillingFloorLabTextures.Statics.Pad14683Go' ;
 Skins[1] =  Texture'KillingFloorWeapons.Deagle.HandSkinHazmat';
 Skins[2] =  Texture'KillingFloorWeapons.Deagle.ArmSkinNew';
 Skins[3] =  Combiner'KFCharacters.CombinerHazmat';
}

defaultproperties
{
     DrawType=DT_StaticMesh
     bStatic=False
     bStasis=False
     bReplicateAnimations=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFCharactersB.KeyPad'
     bMovable=False
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
}
