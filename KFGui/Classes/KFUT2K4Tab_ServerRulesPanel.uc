//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFUT2K4Tab_ServerRulesPanel extends UT2K4Tab_ServerRulesPanel;

var automated GUISectionBackground sb_background;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super(IAMultiColumnRulesPanel).InitComponent(MyController, MyOwner);

	RemoveComponent(b_Symbols);

    sb_background.ManageComponent(lb_Rules);
    sb_background.ManageComponent(nu_Port);
    sb_background.ManageComponent(ch_Webadmin);
    sb_background.ManageComponent(ch_LANServer);
    sb_background.ManageComponent(ch_Advanced);
}

protected function bool ShouldDisplayRule(int Index)
{
	if ( GamePI.Settings[Index].bAdvanced && !Controller.bExpertMode )
		return false;

    // Only multiplayer-specific setting on this page
    return GamePI.Settings[Index].bMPOnly;
}

function Refresh()
{
    Super.Refresh();

    sb_background.ManageComponent(lb_Rules);
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
    	// Save our preference
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();

		// Reload the playinfo settings and repopulate the MultiOptionList
        p_Anchor.SetRuleInfo();

        //reload maplist
        p_Anchor.p_Main.InitMaps();

        return;
    }
    else
    {
    	super.InternalOnChange(Sender);
    }
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainer Name=myBackgroundGroup
         bNoCaption=True
         WinHeight=1.000000
         OnPreDraw=myBackgroundGroup.InternalPreDraw
     End Object
     sb_Background=ROGUIProportionalContainer'KFGui.KFUT2K4Tab_ServerRulesPanel.myBackgroundGroup'

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
         OnChange=KFUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=KFUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     ch_Webadmin=moCheckBox'KFGui.KFUT2K4Tab_ServerRulesPanel.EnableWebadmin'

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
         OnChange=KFUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=KFUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     ch_LANServer=moCheckBox'KFGui.KFUT2K4Tab_ServerRulesPanel.LANServer'

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
         OnChange=KFUT2K4Tab_ServerRulesPanel.Change
         OnLoadINI=KFUT2K4Tab_ServerRulesPanel.InternalOnLoadINI
     End Object
     nu_Port=moNumericEdit'KFGui.KFUT2K4Tab_ServerRulesPanel.WebadminPort'

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
         OnChange=KFUT2K4Tab_ServerRulesPanel.InternalOnChange
     End Object
     ch_Advanced=moCheckBox'KFGui.KFUT2K4Tab_ServerRulesPanel.AdvancedButton'

     i_bk=None

     Begin Object Class=GUIMultiOptionListBox Name=RuleListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=KFUT2K4Tab_ServerRulesPanel.ListBoxCreateComponent
         WinHeight=0.850000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFUT2K4Tab_ServerRulesPanel.InternalOnChange
     End Object
     lb_Rules=GUIMultiOptionListBox'KFGui.KFUT2K4Tab_ServerRulesPanel.RuleListBox'

}
