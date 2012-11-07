//=============================================================================
// The weight bar from the trader menu
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class KFWeightBar extends GUIComponent;

var 			Material	BarBack;
var 			Material	BarTop;

var				int			MaxBoxes;
var				int			CurBoxes;
var				int 		NewBoxes;

var				string		EncString;

var 			float 		CurX;
var				float		CurY;
var 			float		BoxSizeX;
var 			float		BoxSizeY;
var 			float		Spacer;

var 			color		CurrentColor;
var 			color		NewColor;
var 			color		WarnColor;

var	localized	string		EncumbranceString;

function bool MyOnDraw(Canvas C)
{
	local int i;
	local float TextSizeX, TextSizeY;

	CurX = WinLeft;
	CurY = WinTop + WinHeight / 2.5;

	// Background boxes
	for ( i = 0; i < MaxBoxes; i++ )
	{
		C.SetPos(CurX * C.ClipX , CurY * C.ClipY);
		C.DrawTileStretched(BarBack, BoxSizeX * C.ClipX, BoxSizeY * C.ClipX);
		CurX += BoxSizeX;
	}

	// Encumbrance String
	EncString = EncumbranceString$":" @ CurBoxes $ "/" $ MaxBoxes;

	C.TextSize(EncString, TextSizeX, TextSizeY);
	C.SetPos(WinLeft * C.ClipX, ((CurY - (TextSizeY / C.ClipY)) - (((CurY - (TextSizeY / C.ClipY)) - WinTop) / 2)) * C.ClipY);
	C.DrawColor = CurrentColor;
	C.DrawText(EncString);

	CurX = WinLeft + Spacer;
	CurY = (WinTop + WinHeight / 2.5) + (Spacer * 1.5);

	// Our current weight
	for ( i = 0; i < CurBoxes && i < MaxBoxes; i++ )
	{
		C.SetPos(CurX * C.ClipX , CurY * C.ClipY);
		C.DrawTilePartialStretched(BarTop, (BoxSizeX - (Spacer * 2)) * C.ClipX, (BoxSizeY - (Spacer * 2)) * C.ClipX);
		CurX += BoxSizeX;
	}

	// Draw weight of selected weapon
	if ( NewBoxes != 0 )
	{
		// Selected weapon is not to heavy to carry
		if ( CurBoxes + NewBoxes <= MaxBoxes )
		{
			for ( i = 0; i < NewBoxes; i++ )
			{
				C.SetPos(CurX * C.ClipX , CurY * C.ClipY);
				C.DrawColor = NewColor;
				C.DrawTilePartialStretched(BarTop, (BoxSizeX - (Spacer * 2)) * C.ClipX, (BoxSizeY - (Spacer * 2)) * C.ClipX);
				CurX += BoxSizeX;
			}
		}
		// Selected weapon is too heavy
		else
		{
			for ( i = 0; i < NewBoxes && i < (MaxBoxes - CurBoxes); i++ )
			{
				C.SetPos(CurX * C.ClipX , CurY * C.ClipY);
				C.DrawColor = WarnColor;
				C.DrawTilePartialStretched(BarTop, (BoxSizeX - (Spacer * 2)) * C.ClipX, (BoxSizeY - (Spacer * 2)) * C.ClipX);
				CurX += BoxSizeX;
			}
		}
	}

	return false;
}

defaultproperties
{
     BarBack=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
     BarTop=Texture'KF_InterfaceArt_tex.Menu.Progress'
     MaxBoxes=15
     BoxSizeX=0.015000
     BoxSizeY=0.015000
     Spacer=0.001200
     CurrentColor=(B=158,G=176,R=175,A=255)
     NewColor=(G=128,R=255,A=255)
     WarnColor=(R=255,A=255)
     EncumbranceString="Encumbrance Level"
     OnDraw=KFWeightBar.MyOnDraw
}
