class GUIVeterancyButton extends GUIButton;

#exec obj load file="UT2003Fonts.utx"

var Material PerksIcon;
var bool bNoSelectMe;

function MakeMeUnavailable()
{
	OnClickSound = CS_None;
	bNoSelectMe = True;
	bMouseOverSound = False;
}
function bool RenderPerkIcon(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height)
{
	local Material T;
	local float TX,TY,XL,YL;

	TX = Canvas.ClipX;
	TY = Canvas.ClipY;
	Canvas.OrgX = left;
	Canvas.OrgY = top;
	Canvas.ClipX = width;
	Canvas.ClipY = height;
	Canvas.CurX = 0;
	Canvas.CurY = 0;

	if( bNoSelectMe )
		MenuState = MSAT_Disabled;
	T = Style.Images[MenuState];
	if( T!=None )
		Canvas.DrawTile(T,width,height,0,0,T.MaterialUSize(),T.MaterialVSize());
	if( PerksIcon!=None )
	{
		Canvas.CurX = 0;
		Canvas.CurY = 0;
		Canvas.DrawColor.A = 255;
		if( MenuState==MSAT_Disabled )
			Canvas.SetDrawColor(120,120,120,180);
		Canvas.DrawTile(PerksIcon,width,height,0,0,PerksIcon.MaterialUSize(),PerksIcon.MaterialVSize());
	}
	if( Len(Caption)>0 )
	{
		if( MenuState==MSAT_Disabled )
			Canvas.SetDrawColor(120,120,120,200);
		else Canvas.SetDrawColor(250,100,100,225);
		Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);//Font'ROFonts.ROBtsrmVr9';
		Canvas.TextSize(Caption,XL,YL);
		Canvas.CurX = Canvas.ClipX/2-XL/2;
		Canvas.CurY = Canvas.ClipY-YL-1;
		Canvas.DrawTextClipped(Caption,False);
	}
	Canvas.OrgX = 0;
	Canvas.OrgY = 0;
	Canvas.ClipX = TX;
	Canvas.ClipY = TY;
	Canvas.SetDrawColor(255,255,255,255);
	Return True;
}

defaultproperties
{
     StyleName="VeterancyButtonStyle"
     Begin Object Class=GUIVeterancyToolTip Name=GUIVetToolTip
     End Object
     ToolTip=GUIVeterancyToolTip'KFGui.GUIVeterancyButton.GUIVetToolTip'

}
