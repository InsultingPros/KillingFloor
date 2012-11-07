//=============================================================================
// © 2004 Matt 'SquirrelZero' Farber
//=============================================================================
// Similar to ShadowProjector, just a lot better.  This shadow projector, while
// always in the same relative location to the player model, will dynamically
// adjust its FOV and also feed the ShadowBitmapMaterial new lighting data on
// the fly.  It uses a more exaggerated FOV than the standard UT200x shadows,
// because it looks so much cooler :).  It also uses the ShadowCrispness
// setting of the ShadowController to set a larger ShadowBitmapMaterial size.
// Note that the bigger the shadow material the more data is being passed to
// video each frame, so performance will worsen exponentially as you go higher.
// I had to do a lot of little tweaks and hack some settings in to get the
// projector to do what i wanted, and not cut off at strange angles.
//=============================================================================
class Effect_ShadowProjector extends Projector;

var() vector LightDirection;
var() float LightDistance, InterpolationRate, MaxFOV, FadeSpeed, DarknessScale;
var ShadowBitmapMaterial ShadowTexture;
var bool bFadeIn;

function PostBeginPlay()
{
    Super(Actor).PostBeginPlay();
}

// these don't need to tick, we update all shadows at the same time in the controller
function Tick(float dt) {}

// this turns the shadow off
function DisableShadow()
{
    // detach
    DetachProjector();

    // stop shadow texture from being reuploaded to video here
    if (ShadowTexture != None)
    {
        ShadowTexture.Dirty = false;
        ShadowTexture.ShadowActor = None;
    }
}

// initialize
function InitializeFor(Effect_ShadowController ShadowController)
{
    if (ShadowController.Instigator != None)
    {
        // set the instigator
        Instigator = ShadowController.Instigator;

        // allocate the shadow texture
        switch (ShadowController.ShadowCrispness)
        {
            case Medium:
                ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'Effect_ShadowBitmapMaterialMedium'));
                break;

            case High:
                ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'Effect_ShadowBitmapMaterialHigh'));
                break;

            case Maximum:
                ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'Effect_ShadowBitmapMaterialMax'));
                break;

            Default:
                ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'Effect_ShadowBitmapMaterialLow'));
                break;

        }

        // set projector texture
        ProjTexture = ShadowTexture;

        // initialize the shadow texture
        if (ShadowTexture != None)
        {
            ShadowTexture.Invalid = false;
            ShadowTexture.ShadowActor = Instigator;
            ShadowTexture.bBlobShadow = false;
            ShadowTexture.CullDistance = CullDistance;
        }
        else
        {
            log(Name$".InitializeFor: No shadow texture!  Escaping...");
            Destroy();
        }
    }
    else
        log(Name$".InitializeFor: No Instigator!");
}

// updates this shadow's location, rotation, and FOV
function UpdateShadow(float dt, int LN, Effect_ShadowController ShadowController)
{
    local Plane BoundingSphere;
    local Actor ShadowLight;
    local vector Diff, ShadowLocation, Origin;
    local rotator LightRotation, AdjustedRotation;
    local float Interpolation;
    local bool bFadeOut;

    // detach projector
    DetachProjector(true);

    // fallback, don't draw if hidden or no shadow texture
    if (Instigator == None || Instigator.bHidden || ShadowTexture == None)
        return;

    // fallback and destroy
    if (ShadowTexture.Invalid)
    {
        Destroy();
        return;
    }

    // cull more if we haven't rendered this pawn in 5 seconds
    if (Level.TimeSeconds - Instigator.LastRenderTime > 5)
        CullDistance = 0.5*Default.CullDistance;
    else
        CullDistance = Default.CullDistance;

    // cull shadows much earlier if below min framerate, important
    if (Level.bDropDetail)
        ShadowTexture.CullDistance = 0.6*CullDistance;
    else
        ShadowTexture.CullDistance = CullDistance;

    // in case shadow was disabled earlier
    ShadowTexture.ShadowActor = Instigator;

    // set light
    ShadowLight = ShadowController.Lights[LN].CurrentLight;

    // fade out if necessary
    if (ShadowController.Lights[LN].LastLight != None)
    {
        if (ShadowTexture.ShadowDarkness > 5)
        {
            ShadowLight = ShadowController.Lights[LN].LastLight;
            bFadeOut = true;
        }
        else
        {
            ShadowController.Lights[LN].LastLight = None;
            bFadeOut = false;
            bFadeIn = true;
            DarknessScale = 0;
        }
    }

    // fallback if no more lights after fadeout
    if (ShadowLight == None)
        return;

    // get the direction of the light
    Diff = ShadowLight.Location - Instigator.Location;

    // set light distance
    if (ShadowLight.LightEffect == LE_Sunlight)
        LightDistance = ShadowController.MaxLightDistance*0.75;
    else
        LightDistance = FMin(VSize(Diff), ShadowController.MaxLightDistance);

    // get a location along the path of the light slightly away from center of player
    ShadowLocation = Instigator.Location + (4*vector(rotator(Diff)));

    // if the projector is behind the light, move it forward
    if (VSize(ShadowLocation-Instigator.Location) > LightDistance)
        ShadowLocation = ShadowLight.Location;

    // set location
    SetLocation(ShadowLocation + vect(0,0,-8));

    // determine correct rotation, interpolate
    Origin = ShadowLocation + ShadowTexture.LightDirection * ShadowTexture.LightDistance;
    Interpolation = FMin(1.0, (dt*InterpolationRate));
    Origin += (ShadowLight.Location - Origin) * Interpolation;
    Diff = ShadowLocation - Origin;
    LightRotation = rotator(Diff);

    // calculate FOV
    BoundingSphere = Instigator.GetRenderBoundingSphere();
    FOV = (Atan(BoundingSphere.W*2 + 160, LightDistance) * 180/PI)*0.9;

    // set rotation, compensate for FOV warping -- kinda hackish, but fixes shadows that
    // bend so much they detach from the pawn
    AdjustedRotation = rotator(Instigator.Location-ShadowLight.Location);
    AdjustedRotation.Pitch -= 1280*(FOV/MaxFOV);
    SetRotation(AdjustedRotation);

    // determine correct direction of light
    LightDirection = -vector(rotator(Instigator.Location-ShadowLight.Location))*LightDistance;

    // set light direction
    ShadowTexture.LightDirection = Normal(LightDirection);

    // set lightdistance
    ShadowTexture.LightDistance = LightDistance;

    // update shadow texture FOV
    ShadowTexture.LightFOV = FOV;

    // set the drawscale, exaggerate a bit
    SetDrawScale( (LightDistance*0.82) * tan(0.5*FOV*PI/180) / (0.45*ShadowTexture.USize));

    // fade out gracefully
    if (bFadeOut)
        ShadowTexture.ShadowDarkness = Max(ShadowTexture.ShadowDarkness - (FadeSpeed*dt), 0);
    else
    {
        ShadowTexture.ShadowDarkness = 180*(1.0-(FClamp(VSize(ShadowLight.Location-Instigator.Location)/ShadowController.MaxLightDistance, 0.0, 1.0))) + 70;
        if (bFadeIn && DarknessScale < 1.0)
        {
            DarknessScale = FMin(DarknessScale + ((FadeSpeed*0.007)*dt), 1.0);
            ShadowTexture.ShadowDarkness = float(ShadowTexture.ShadowDarkness)*DarknessScale;
        }
        else
            bFadeIn = false;
    }

    // dirty texture for reuploading to video
    ShadowTexture.Dirty = true;

    // reattach projector
    AttachProjector();
}

simulated function Destroyed()
{
    // free shadow texture from the object pool
    if (ShadowTexture != None)
    {
        ShadowTexture.ShadowActor = None;

        if (!ShadowTexture.Invalid)
            Level.ObjectPool.FreeObject(ShadowTexture);

        // must set to none
        ShadowTexture = None;
        ProjTexture = None;
    }
    Super.Destroyed();
}

defaultproperties
{
     InterpolationRate=2.500000
     MaxFOV=80.000000
     FadeSpeed=550.000000
     MaxTraceDistance=275
     bClipBSP=True
     bProjectOnParallelBSP=True
     bDynamicAttach=True
     bNoProjectOnOwner=True
     CullDistance=1200.000000
     bStatic=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bOwnerNoSee=True
}
