//-----------------------------------------------------------
//  edited emh 11/24/05
//-----------------------------------------------------------
class ROUT2K4Tab_ServerRulesPanel extends UT2K4Tab_ServerRulesPanel;

var GUIController localController;

var automated GUISectionBackground sb_background;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    localController = MyController;

    super(IAMultiColumnRulesPanel).InitComponent(MyController, MyOwner);

    RemoveComponent(b_Symbols);

    sb_background.ManageComponent(lb_Rules);
    sb_background.ManageComponent(nu_Port);
    sb_background.ManageComponent(ch_Webadmin);
    sb_background.ManageComponent(ch_LANServer);
    sb_background.ManageComponent(ch_Advanced);
}

function Refresh()
{
    Super.Refresh();

    sb_background.ManageComponent(lb_Rules);
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainer Name=myBackgroundGroup
         bNoCaption=True
         WinHeight=1.000000
         OnPreDraw=myBackgroundGroup.InternalPreDraw
     End Object
     sb_Background=ROGUIProportionalContainer'ROInterface.ROUT2K4Tab_ServerRulesPanel.myBackgroundGroup'

     Begin Object Class=moCheckBox Name=EnableWebadmin
         Caption="Enable WebAdmin"
         OnCreateComponent=EnableWebadmin.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enables remote web-based administration of the server"
         WinTop=0.900000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.040000
         TabOrder=4
         OnChange=ROUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=ROUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     ch_Webadmin=moCheckBox'ROInterface.ROUT2K4Tab_ServerRulesPanel.EnableWebadmin'

     Begin Object Class=moCheckBox Name=LANServer
         Caption="LAN Server"
         OnCreateComponent=LANServer.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Optimizes various engine and network settings for LAN-based play.  Enabling this option when running an internet server will cause EXTREME lag during the match!"
         WinTop=0.950000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         TabOrder=3
         OnChange=ROUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=ROUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     ch_LANServer=moCheckBox'ROInterface.ROUT2K4Tab_ServerRulesPanel.LANServer'

     Begin Object Class=moNumericEdit Name=WebadminPort
         MinValue=1
         MaxValue=65536
         CaptionWidth=0.700000
         ComponentWidth=0.300000
         Caption="WebAdmin Port"
         OnCreateComponent=WebadminPort.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Select which port should be used to connect to the remote web-based administration"
         WinTop=0.950000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.040000
         TabOrder=5
         OnChange=ROUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=ROUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     nu_Port=moNumericEdit'ROInterface.ROUT2K4Tab_ServerRulesPanel.WebadminPort'

     Begin Object Class=moCheckBox Name=AdvancedButton
         Caption="View Advanced Options"
         OnCreateComponent=AdvancedButton.InternalOnCreateComponent
         Hint="Toggles whether advanced properties are displayed"
         WinTop=0.900000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=ROUT2K4Tab_ServerRulesPanel.InternalOnChange
     End Object
     ch_Advanced=moCheckBox'ROInterface.ROUT2K4Tab_ServerRulesPanel.AdvancedButton'

     i_bk=None

     Begin Object Class=GUIMultiOptionListBox Name=RuleListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=ROUT2K4Tab_ServerRulesPanel.ListBoxCreateComponent
         WinHeight=0.850000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=ROUT2K4Tab_ServerRulesPanel.InternalOnChange
     End Object
     lb_Rules=GUIMultiOptionListBox'ROInterface.ROUT2K4Tab_ServerRulesPanel.RuleListBox'

}
