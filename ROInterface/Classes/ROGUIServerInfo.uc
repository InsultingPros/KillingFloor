//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROGUIServerInfo extends LargeWindow;

var automated GUITabControl c_Tabs;
var automated GUIFooter     t_Footer;

var array<string>               PanelClass;
var localized array<string>     PanelCaption;
var localized array<string>     PanelHint;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	if ( PlayerOwner() != None && PlayerOwner().GameReplicationInfo != None )
	    SetTitle();

    Super.InitComponent(MyController, MyOwner);

    c_Tabs.MyFooter = t_Footer;
	for ( i = 0; i < PanelClass.Length && i < PanelCaption.Length && i < PanelHint.Length; i++ )
	    c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i]);

	t_Footer.SetVisibility(false);
}

function SetTitle()
{
    local string temp;
    temp = PlayerOwner().GameReplicationInfo.ServerName;
    if (temp != "")
	   WindowName = temp;
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=ServerInfoTabs
         bFillSpace=True
         bDockPanels=True
         TabHeight=0.040000
         WinTop=0.070000
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=ServerInfoTabs.InternalOnActivate
     End Object
     c_Tabs=GUITabControl'ROInterface.ROGUIServerInfo.ServerInfoTabs'

     Begin Object Class=GUIFooter Name=ServerInfoFooter
         StyleName=
         WinTop=0.950000
         WinHeight=0.050000
     End Object
     t_Footer=GUIFooter'ROInterface.ROGUIServerInfo.ServerInfoFooter'

     PanelClass(0)="GUI2K4.UT2K4Tab_ServerMOTD"
     PanelClass(1)="GUI2K4.UT2K4Tab_ServerInfo"
     PanelClass(2)="GUI2K4.UT2K4Tab_ServerMapList"
     PanelCaption(0)="MOTD"
     PanelCaption(1)="Rules"
     PanelCaption(2)="Maps"
     PanelHint(0)="Message of the Day"
     PanelHint(1)="Game Rules"
     PanelHint(2)="Map Rotation"
     WindowName="Server Info"
     bAllowedAsLast=True
     WinTop=0.100000
     WinHeight=0.800000
}
