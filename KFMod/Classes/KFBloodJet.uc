//=============================================================================
// KF BloodJet.
//=============================================================================
class KFBloodJet extends  BloodJet;

#exec OBJ LOAD File=KFX.utx

state Ticking
{
    simulated function Tick( float dt )
    {
        if( LifeSpan < 1.0 )
        {
            mRegenRange[0] *= LifeSpan;
            mRegenRange[1] = mRegenRange[0];
        }
    }
}

simulated function timer()
{
    GotoState('Ticking');
}

simulated function PostNetBeginPlay()
{
    SetTimer(LifeSpan - 1.0,false);
    if ( Level.NetMode != NM_DedicatedServer )
        WallSplat();
    Super.PostNetBeginPlay();
}

simulated function WallSplat()
{
    local vector WallHit, WallNormal;
    local Actor WallActor;

    if ( FRand() > 0.8 )
        return;
    WallActor = Trace(WallHit, WallNormal, Location + vect(0,0,-200), Location, false);
    if ( WallActor != None )
        spawn(SplatterClass,,,WallHit + 20 * (WallNormal + VRand()), rotator(-WallNormal));
}

defaultproperties
{
     Skins(0)=Texture'KFX.BloodySpray'
}
