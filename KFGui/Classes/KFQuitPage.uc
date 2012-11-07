// ====================================================================
// ====================================================================

class KFQuitPage extends UT2K4QuitPage;


function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==Controls[1])
	{
	   if(PlayerOwner().Level.IsDemoBuild())
		  Controller.ReplaceMenu("XInterface.UT2DemoQuitPage");
	   else
		  PlayerOwner().ConsoleCommand("exit");
	}
	else
	   Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=QuitBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=QuitBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'KFGui.KFQuitPage.QuitBackground'

     Begin Object Class=GUIButton Name=YesButton
         Caption="YES"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=KFQuitPage.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'KFGui.KFQuitPage.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="NO"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=KFQuitPage.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'KFGui.KFQuitPage.NoButton'

     Begin Object Class=GUILabel Name=QuitDesc
         Caption="Are you sure you want to Exit?"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=0.041667
     End Object
     Controls(3)=GUILabel'KFGui.KFQuitPage.QuitDesc'

     Begin Object Class=GUILabel Name=QuitDescLine2
         Caption="You can run. But they'll find you before dawn."
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         WinTop=0.458333
         WinHeight=0.041667
     End Object
     Controls(4)=GUILabel'KFGui.KFQuitPage.QuitDescLine2'

     WinTop=0.375000
     WinHeight=0.250000
}
