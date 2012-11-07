//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4QuitPage extends UT2K4QuitPage;

defaultproperties
{
     Begin Object Class=GUIButton Name=cYesButton
         Caption="YES"
         StyleName="SelectButton"
         WinTop=0.515625
         WinLeft=0.164063
         WinWidth=0.200000
         TabOrder=0
         OnClick=UT2K4QuitPage.InternalOnClick
         OnKeyEvent=cYesButton.InternalOnKeyEvent
     End Object
     YesButton=GUIButton'ROInterface.ROUT2K4QuitPage.cYesButton'

     Begin Object Class=GUIButton Name=cNoButton
         Caption="NO"
         StyleName="SelectButton"
         WinTop=0.515625
         WinLeft=0.610937
         WinWidth=0.200000
         TabOrder=1
         OnClick=UT2K4QuitPage.InternalOnClick
         OnKeyEvent=cNoButton.InternalOnKeyEvent
     End Object
     NoButton=GUIButton'ROInterface.ROUT2K4QuitPage.cNoButton'

}
