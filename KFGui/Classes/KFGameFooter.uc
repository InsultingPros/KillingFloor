//==============================================================================
//==============================================================================
class KFGameFooter extends UT2K4GameFooter;

defaultproperties
{
     Begin Object Class=GUIButton Name=GamePrimaryButton
         AutoSizePadding=(HorzPerc=0.400000)
         bAutoSize=True
         MenuState=MSAT_Disabled
         WinTop=0.906146
         WinHeight=0.033203
         TabOrder=0
         bBoundToParent=True
         OnKeyEvent=GamePrimaryButton.InternalOnKeyEvent
     End Object
     b_Primary=GUIButton'KFGui.KFGameFooter.GamePrimaryButton'

     Begin Object Class=GUIButton Name=GameSecondaryButton
         AutoSizePadding=(HorzPerc=0.400000)
         bAutoSize=True
         MenuState=MSAT_Disabled
         WinTop=0.906146
         WinHeight=0.033203
         TabOrder=1
         bBoundToParent=True
         OnKeyEvent=GameSecondaryButton.InternalOnKeyEvent
     End Object
     b_Secondary=GUIButton'KFGui.KFGameFooter.GameSecondaryButton'

     Begin Object Class=GUIButton Name=GameBackButton
         Caption="BACK"
         AutoSizePadding=(HorzPerc=0.400000)
         bAutoSize=True
         Hint="Return to Previous Menu"
         WinTop=0.906146
         WinHeight=0.033203
         TabOrder=2
         bBoundToParent=True
         OnKeyEvent=GameBackButton.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'KFGui.KFGameFooter.GameBackButton'

     Justification=TXTA_Right
}
