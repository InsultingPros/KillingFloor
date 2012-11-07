//=============================================================================
// Laser beam effect for a third person laser site.
// This class is pretty placeholder right now and needs to be cleaned up
//=============================================================================
class LaserBeamEffect extends xEmitter;

#exec OBJ LOAD FILE=kf_fx_trip_t.utx

var Vector StartEffect, EndBeamEffect;
var() vector EffectOffset;
var vector EffectHitNormal;
var LaserDot Spot;
var() float SpotProjectorPullback;

var bool    bLaserActive;
var bool    bCurrentLaserActive;

replication
{
    reliable if (Role == ROLE_Authority)
        StartEffect, EndBeamEffect, EffectHitNormal, bLaserActive;
}

simulated event PostNetReceive()
{
    if( bLaserActive != bCurrentLaserActive )
    {
        bCurrentLaserActive = bLaserActive;

        if( !bLaserActive )
        {
            bHidden = true;
            Spot.Destroy();
        }
        else
        {
            bHidden = false;
        }
    }
}

simulated function SetActive(bool bNewActive)
{
    bLaserActive = bNewActive;
    bCurrentLaserActive = bLaserActive;

    if( !bLaserActive )
    {
        bHidden = true;
        if (Spot != None)
            Spot.Destroy();

        NetUpdateFrequency=5;
    }
    else
    {
        bHidden = false;
        NetUpdateFrequency=100;
    }
}

simulated function Destroyed()
{
    if (Spot != None)
        Spot.Destroy();

    Super.Destroyed();
}

simulated function Tick(float dt)
{
    local Vector BeamDir;
    local BaseKFWeaponAttachment Attachment;
    local rotator NewRotation;
    local float LaserDist;

    if (Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None))
    {
        Destroy();
        return;
    }

    // set beam start location
    if ( Instigator == None )
    {
        // do nothing
    }
    else
    {
        if ( Instigator.IsFirstPerson() && Instigator.Weapon != None )
        {
            bHidden=True;
            if (Spot != None)
            {
                Spot.Destroy();
            }
        }
        else
        {
            bHidden=!bLaserActive;
            if( Level.NetMode != NM_DedicatedServer && Spot == none && bLaserActive)
            {
                Spot = Spawn(class'LaserDot', self);
            }

            LaserDist = VSize(EndBeamEffect - StartEffect);
            if( LaserDist > 100 )
            {
                LaserDist = 100;
            }
            else
            {
                LaserDist *= 0.5;
            }

            Attachment = BaseKFWeaponAttachment(xPawn(Instigator).WeaponAttachment);
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
            {
                StartEffect= Attachment.GetTipLocation();
                NewRotation = Rotator(-Attachment.GetBoneCoords('tip').XAxis);
                SetLocation( StartEffect + Attachment.GetBoneCoords('tip').XAxis * LaserDist );
            }
            else
            {
                StartEffect = Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(EndBeamEffect - Instigator.Location) * 25.0;
                SetLocation( StartEffect + Normal(EndBeamEffect - StartEffect) * LaserDist );
                NewRotation = Rotator(Normal(StartEffect - Location));
            }
        }
    }

    BeamDir = Normal(StartEffect - Location);
    SetRotation(NewRotation);

    mSpawnVecA = StartEffect;


    if (Spot != None)
    {
        Spot.SetLocation(EndBeamEffect + BeamDir * SpotProjectorPullback);

        if( EffectHitNormal == vect(0,0,0) )
        {
            Spot.SetRotation(Rotator(-BeamDir));
        }
        else
        {
            Spot.SetRotation(Rotator(-EffectHitNormal));
        }
    }
}

defaultproperties
{
     SpotProjectorPullback=1.000000
     mParticleType=PT_Beam
     mMaxParticles=3
     mRegenDist=100.000000
     mSizeRange(0)=4.000000
     mSizeRange(1)=5.000000
     mColorRange(0)=(B=100,G=100,R=100)
     mColorRange(1)=(B=100,G=100,R=100)
     mAttenuate=False
     mAttenKa=1.000000
     bHidden=True
     bNetTemporary=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=5.000000
     LifeSpan=100000000.000000
     Skins(0)=Texture'kf_fx_trip_t.Misc.Red_Laser'
     Style=STY_Additive
     SoundVolume=45
     SoundRadius=120.000000
     bNetNotify=True
}
