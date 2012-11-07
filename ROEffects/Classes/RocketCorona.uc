class RocketCorona extends Effects;

auto state Start
{
    simulated function Tick(float dt)
    {
        SetDrawScale(FMin(DrawScale + dt*2.0, 0.20));
        if (DrawScale >= 0.20)
        {
            SetDrawScale(0.20);
			GotoState('');
        }
    }
}

defaultproperties
{
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     Texture=Texture'Effects_Tex.explosions.fire_quad'
     DrawScale=0.010000
     Skins(0)=Texture'Effects_Tex.explosions.fire_quad'
     Style=STY_Additive
     Mass=13.000000
}
