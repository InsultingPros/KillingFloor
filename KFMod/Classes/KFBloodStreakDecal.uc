// KFs very own higher-res Bloodstains

class KFBloodStreakDecal extends KFBloodSplatterDecal;

#exec OBJ LOAD File=KFX.utx

simulated function PostBeginPlay()
{
    /*
    local Vector RX, RY, RZ;
    local Rotator R;

    if ( PhysicsVolume.bNoDecals )
    {
        Destroy();
        return;
    }
    if( RandomOrient )
    {
        R.Yaw = 0;
        R.Pitch = 0;
        R.Roll = 0;
       // R.Roll = Rand(65535);
       // GetAxes(R,RX,RY,RZ);
       // RX = RX >> Rotation;
       // RY = RY >> Rotation;
       // RZ = RZ >> Rotation;
       // R = OrthoRotation(RX,RY,RZ);

        SetRotation(R);
    }
    SetLocation( Location - Vector(Rotation)*PushBack );

    Lifespan = FMax(0.5, LifeSpan + (Rand(4) - 2));

    if ( Level.bDropDetail )
        LifeSpan *= 0.5;
    AbandonProjector(LifeSpan*Level.DecalStayScale);
    Destroy();
    */

    ProjTexture = splats[Rand(3)];
    FOV = 1;
    SetDrawScale((Rand(2)-0.6));

    Super.PostBeginPlay();
    

}

defaultproperties
{
     Splats(0)=Texture'KFX.BloodStreak'
     Splats(1)=Texture'KFX.BloodStreak'
     Splats(2)=Texture'KFX.BloodStreak'
     PushBack=5.000000
     RandomOrient=False
     ProjTexture=Texture'KFX.BloodStreak'
}
