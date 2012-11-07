class GUIWeaponBar extends GUIProgressBar;

function ResetColor()
{
	BarColor.R=255;
	BarColor.G=255;
	BarColor.B=255;
	BarColor.A=255;
}

function SetValue(float val)
{
	Value=val+20;
	ResetColor();
}

function float GetValue()
{
	return Value-20;
}

defaultproperties
{
     BarBack=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
     BarTop=Texture'InterfaceArt_tex.Menu.progress_bar'
     Low=20.000000
     High=120.000000
     CaptionWidth=0.000000
     ValueRightWidth=0.000000
     bShowValue=False
}
