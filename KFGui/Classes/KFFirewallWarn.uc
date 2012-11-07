//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFFirewallWarn extends UT2K4GenericMessageBox;

var automated moCheckbox ch_NeverShowAgain;
var localized string WarnString;

function HandleParameters( string Param1, string Param2 )
{
	local float f;

	l_Text2.Caption = WarnString;

	f = float(Param1);
	if ( f != 0.0 )
		SetTimer(f);
}

function Timer()
{
	Controller.CloseMenu(false);
}

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function CheckBoxClick(GUIComponent Sender)
{
	class'KFGamePageMP'.default.bExpert = ch_NeverShowAgain.IsChecked();
	class'KFGamePageMP'.static.StaticSaveConfig();
}

function InternalOnLoadIni( GUIComponent Sender, string Value )
{
	ch_NeverShowAgain.Checked(class'KFGamePageMP'.default.bExpert);
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=HideCheckbox
         bFlipped=True
         CaptionWidth=0.990000
         ComponentWidth=0.070000
         Caption="  do not display this warning again"
         OnCreateComponent=HideCheckbox.InternalOnCreateComponent
         FontScale=FNS_Small
         IniOption="@Internal"
         Hint="Check this to disable showing warning messages"
         WinTop=0.500000
         WinLeft=0.375000
         WinWidth=0.250000
         TabOrder=1
         OnChange=KFFirewallWarn.CheckBoxClick
         OnLoadINI=KFFirewallWarn.InternalOnLoadINI
     End Object
     ch_NeverShowAgain=moCheckBox'KFGui.KFFirewallWarn.HideCheckbox'

     WarnString="Please make sure Universal Plug and Play is enabled, or the ports 7707 UDP, 7708 UDP, 7717 UDP, 28852 TCP & UDP, 8075 TCP and 20560 TCP & UDP are opened on your router/firewall."
     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.620000
         WinLeft=0.439063
         WinWidth=0.121875
         TabOrder=0
         OnClick=KFFirewallWarn.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'KFGui.KFFirewallWarn.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="WARNING"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.340000
         WinHeight=0.040000
     End Object
     l_Text=GUILabel'KFGui.KFFirewallWarn.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         TextAlign=TXTA_Center
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.400000
         WinLeft=0.200000
         WinWidth=0.650000
         WinHeight=0.300000
     End Object
     l_Text2=GUILabel'KFGui.KFFirewallWarn.DialogText2'

     OpenSound=Sound'KF_MenuSnd.Generic.msfxEdit'
}
