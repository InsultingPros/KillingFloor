// Fancy new in-game disconnect page

class KFDisconnectPage extends GUIPage;

var bool bIgnoreEsc;

var		localized string LeaveMPButtonText;
var		localized string LeaveSPButtonText;

var		float ButtonWidth;
var		float ButtonHeight;
var		float ButtonHGap;
var		float ButtonVGap;
var		float BarHeight;
var		float BarVPos;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender==Controls[1] ) // OK
    {
		Controller.OpenMenu("KFGui.KFServerBrowser");
	}

	return true;
}

event HandleParameters(string Param1, string Param2)
{
	GUILabel(Controls[2]).Caption = Param1$"|"$Param2;
	PlayerOwner().ClearProgressMessages();
}

defaultproperties
{
     bIgnoreEsc=True
     bRequire640x480=False
     OpenSound=Sound'ROMenuSounds.Generic.msfxEdit'
     Begin Object Class=AltSectionBackground Name=NetStatBackground
         WinTop=0.375000
         WinLeft=0.125000
         WinWidth=0.750000
         WinHeight=0.250000
         bNeverFocus=True
         OnPreDraw=NetStatBackground.InternalPreDraw
     End Object
     Controls(0)=AltSectionBackground'KFGui.KFDisconnectPage.NetStatBackground'

     Begin Object Class=GUIButton Name=NetStatOk
         Caption="OK"
         StyleName="MidGameButton"
         WinTop=0.675000
         WinLeft=0.375000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         OnClick=KFDisconnectPage.InternalOnClick
         OnKeyEvent=NetStatOk.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'KFGui.KFDisconnectPage.NetStatOk'

     Begin Object Class=GUILabel Name=NetStatLabel
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         bMultiLine=True
         WinTop=0.125000
         WinHeight=0.500000
         bBoundToParent=True
     End Object
     Controls(2)=GUILabel'KFGui.KFDisconnectPage.NetStatLabel'

     WinTop=0.375000
     WinHeight=0.250000
}
