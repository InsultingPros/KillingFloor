class KFProfileAndAchievements_Footer extends ButtonFooter;

var automated GUIButton b_Save;

delegate OnSaveButtonClicked();

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_Save )
	{
		OnSaveButtonClicked();
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=BackB
         Caption="SAVE"
         StyleName="FooterButton"
         Hint="Save and return to the previous menu"
         WinTop=0.085678
         WinWidth=0.090000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=1
         bBoundToParent=True
         OnClick=KFProfileAndAchievements_Footer.InternalOnClick
         OnKeyEvent=BackB.InternalOnKeyEvent
     End Object
     b_Save=GUIButton'KFGui.KFProfileAndAchievements_Footer.BackB'

     bAutoSize=False
}
