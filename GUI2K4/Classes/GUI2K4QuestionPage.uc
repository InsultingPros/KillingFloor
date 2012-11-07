//==============================================================================
// UT2004 Style Question Page
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class GUI2K4QuestionPage extends GUIQuestionPage;

function bool ButtonClick(GUIComponent Sender)
{
	local int T;

	T = GUIButton(Sender).Tag;
	ParentPage.InactiveFadeColor=ParentPage.Default.InactiveFadeColor;
	if ( NewOnButtonClick(T) ) Controller.CloseMenu( bool(T & (QBTN_Cancel|QBTN_Abort)) );
	OnButtonClick(T);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=imgBack
         Image=Texture'KF_InterfaceArt_tex.Menu.Med_border_SlightTransparent'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowY=10
         WinTop=0.297917
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.401563
     End Object
     Controls(0)=GUIImage'GUI2K4.GUI2K4QuestionPage.imgBack'

     Begin Object Class=GUILabel Name=lblQuestion
         TextAlign=TXTA_Center
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.366483
         WinLeft=0.150000
         WinWidth=0.700000
         WinHeight=0.065714
     End Object
     Controls(1)=GUILabel'GUI2K4.GUI2K4QuestionPage.lblQuestion'

     WinTop=0.352899
     WinLeft=0.116072
     WinWidth=0.765486
     WinHeight=0.319917
}
