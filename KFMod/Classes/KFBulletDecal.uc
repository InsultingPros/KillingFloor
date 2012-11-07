class KFBulletDecal extends ProjectedDecal
	abstract
	hidedropdown;

var() Array<Texture> Marks;

simulated function PostBeginPlay()
{
      if (Marks.Length != 0)
        ProjTexture = Marks[Rand(Marks.Length)];

      Super.PostBeginPlay();
}

defaultproperties
{
     PushBack=16.000000
     RandomOrient=False
     bClipStaticMesh=True
     CullDistance=2000.000000
     LifeSpan=60.000000
     DrawScale=0.130000
}
