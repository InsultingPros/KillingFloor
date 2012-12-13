//=============================================================================
// Laser beam effect for a third person laser site on the ZED gun.
//=============================================================================
class LaserBeamEffectZED extends LaserBeamEffect;

simulated function Tick(float dt)
{
    local Vector BeamDir;
    local BaseKFWeaponAttachment Attachment;
    local rotator NewRotation;
    local float LaserDist;
    local coords C;

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
                Spot = Spawn(class'LaserDotZED', self);
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
                C = Attachment.GetBoneCoords('tip2');
                StartEffect= C.Origin;
                NewRotation = Rotator(-Attachment.GetBoneCoords('tip2').XAxis);
                SetLocation( StartEffect + Attachment.GetBoneCoords('tip2').XAxis * LaserDist );
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
     Skins(0)=Texture'kf_fx_trip_t.Misc.Green_Laser'
}
