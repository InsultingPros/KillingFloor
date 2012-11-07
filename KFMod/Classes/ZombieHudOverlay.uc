class ZombieHudOverlay extends ScriptedHudOverlay;

simulated function Render(Canvas C)
{
    local float X, Y, W, H;

    if (HUDMaterial == None)
        return;

    if (PosX <= 1.0)
        X = C.ClipX * PosX;
    else
        X = PosX;
    if (PosY <= 1.0)
        Y = C.ClipY * PosY;
    else
        Y = PosY;
    if (Width <= 1.0)
        W = C.ClipX * Width;
    else
        W = Width;
    if (Height <= 1.0)
        H = C.ClipY * Height;
    else
        H = Height;

    C.DrawColor = class'HUD'.default.WhiteColor;
    C.SetPos(X, Y);
    C.DrawTile(HUDMaterial, W, H, 0, 0, HUDMaterial.MaterialUSize(), HUDMaterial.MaterialVSize());
}

defaultproperties
{
     bHidden=False
}
