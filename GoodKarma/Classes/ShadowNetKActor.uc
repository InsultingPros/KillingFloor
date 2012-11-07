// A NetKActor with real time shadows....

class ShadowNetKActor extends NetKActor;

// shadow decal
simulated function PostBeginPlay()
{
    PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
    PlayerShadow.ShadowActor = self;
    PlayerShadow.bBlobShadow = bBlobShadow;
    PlayerShadow.LightDirection = Normal(vect(1,1,3));
    PlayerShadow.LightDistance = 320;
    PlayerShadow.MaxTraceDistance = 350;
    PlayerShadow.InitShadow();

    PlayerShadow.bShadowActive = true;
}

defaultproperties
{
}
