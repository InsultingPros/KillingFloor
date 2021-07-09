//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Browser_Footer extends UT2k4Browser_Footer;

defaultproperties
{
     Begin Object Class=GUITitleBar Name=BrowserStatus
         bUseTextHeight=False
         Justification=TXTA_Right
         FontScale=FNS_Small
         WinTop=0.030495
         WinLeft=0.238945
         WinWidth=0.761055
         WinHeight=0.450000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     t_StatusBar=GUITitleBar'ROInterface.ROUT2K4Browser_Footer.BrowserStatus'

     Begin Object Class=GUIButton Name=BrowserJoin
         Caption="JOIN"
         MenuState=MSAT_Disabled
         StyleName="FooterButton"
         WinTop=0.500000
         WinLeft=611.000000
         WinWidth=124.000000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=2
         bBoundToParent=True
         OnClick=ROUT2K4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserJoin.InternalOnKeyEvent
     End Object
     b_Join=GUIButton'ROInterface.ROUT2K4Browser_Footer.BrowserJoin'

     Begin Object Class=GUIButton Name=BrowserSpec
         Caption="SPECTATE"
         MenuState=MSAT_Disabled
         StyleName="FooterButton"
         WinTop=0.500000
         WinLeft=0.771094
         WinWidth=0.114648
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=1
         bBoundToParent=True
         OnClick=ROUT2K4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserSpec.InternalOnKeyEvent
     End Object
     b_Spectate=GUIButton'ROInterface.ROUT2K4Browser_Footer.BrowserSpec'

     Begin Object Class=GUIButton Name=BrowserBack
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to the previous menu"
         WinTop=0.500000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=4
         bBoundToParent=True
         OnClick=ROUT2K4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserBack.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'ROInterface.ROUT2K4Browser_Footer.BrowserBack'

     Begin Object Class=GUIButton Name=BrowserRefresh
         Caption="REFRESH"
         MenuState=MSAT_Disabled
         StyleName="FooterButton"
         WinTop=0.500000
         WinLeft=0.885352
         WinWidth=0.114648
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=3
         bBoundToParent=True
         OnClick=ROUT2K4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserRefresh.InternalOnKeyEvent
     End Object
     b_Refresh=GUIButton'ROInterface.ROUT2K4Browser_Footer.BrowserRefresh'

     Begin Object Class=GUIButton Name=BrowserFilter
         Caption="FILTERS"
         bAutoSize=True
         StyleName="FooterButton"
         Hint="Filters allow more control over which servers will appear in the server browser lists."
         WinTop=0.500000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=0
         bBoundToParent=True
         OnClick=ROUT2K4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserFilter.InternalOnKeyEvent
     End Object
     b_Filter=GUIButton'ROInterface.ROUT2K4Browser_Footer.BrowserFilter'

}
