//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4ServerBrowser extends UT2k4ServerBrowser;


// Commented out until we can finish up the functionality
//var   localized string          AllGameTypesText;   // Text to display in the game type filter tab when you want to show all game types

var private ROMasterServerClient  ROMSC;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
}

/*function bool ComboOnPreDraw(Canvas Canvas)
{
	co_GameType.WinTop = co_GameType.RelativeTop(t_Header.ActualTop() + t_Header.ActualHeight() + float(Controller.ResY) / 480.0) + 0.01;
	co_GameType.WinLeft = co_GameType.RelativeLeft((c_Tabs.ActualLeft() + c_Tabs.ActualWidth()) - (co_GameType.ActualWidth() + 3)) + 0.01;
    return false;
}*/

function InternalOnChange(GUIComponent Sender)
{
    if ( GUITabButton(Sender) != None )
    {
        // Update gametype combo box visibility
        co_GameType.SetVisibility(false);
    }
}

function MasterServerClient Uplink()
{
	if ( ROMSC == None && PlayerOwner() != None )
		ROMSC = PlayerOwner().Spawn( class'ROMasterServerClient' );

	return ROMSC;
}

function CreateTabs()
{
	local int i;

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		if ( PanelClass[i] != "" )
			AddTab(PanelCaption[i], PanelClass[i], PanelHint[i]);
	}

	// Must perform the first refresh manually, since the RefreshFooter delegate won't be assigned
	// when the first tab panel receives the first call to ShowPanel()
	RefreshFooter( UT2K4Browser_Page(c_Tabs.ActiveTab.MyPanel),"false" );
}

// Commented out until we can finish up the functionality
/*
function InitializeGameTypeCombo(optional bool ClearFirst)
{
    local int i, j;
    local UT2K4Browser_ServersList  ListObj;
    local array<CacheManager.MapRecord> Maps;

	co_GameType.MyComboBox.MaxVisibleItems = 10;
    PopulateGameTypes();
    if (ClearFirst)
        co_GameType.MyComboBox.List.Clear();

    j = -1;

    ListObj = new(None) class'GUI2K4.UT2K4Browser_ServersList';
    co_GameType.AddItem(AllGameTypesText, ListObj, "Any");

    // Create a seperate list for each gametype, and store the lists in the combo box
    for (i = 0; i < Records.Length; i++)
    {
    	class'CacheManager'.static.GetMapList( Maps, Records[i].MapPrefix );
//    	if ( Maps.Length == 0 )
//    		continue;

        ListObj = new(None) class'GUI2K4.UT2K4Browser_ServersList';
        co_GameType.AddItem(Records[i].GameName, ListObj, Records[i].ClassName);
//        if (Records[i].ClassName ~= CurrentGameType)
//            j = i;
    }

	j = co_GameType.FindIndex(CurrentGameType,true,true);
	//j = co_GameType.FindIndex("Any",true,true);
    if (j != -1)
    {
	    co_GameType.SetIndex(j);
	    SetFilterInfo();
    }
}*/

defaultproperties
{
     CurrentGameType="ROEngine.ROTeamGame"
     Begin Object Class=ROUT2K4Browser_Footer Name=FooterPanel
         Spacer=0.010000
         WinHeight=0.070000
         TabOrder=4
         OnPreDraw=FooterPanel.InternalOnPreDraw
     End Object
     t_Footer=ROUT2K4Browser_Footer'ROInterface.ROUT2k4ServerBrowser.FooterPanel'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'menuBackground.InterfaceBackgrounds.MultiMenuBack'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1024
         Y2=1024
     End Object
     i_Background=BackgroundImage'ROInterface.ROUT2k4ServerBrowser.PageBackground'

     i_bkChar=None

     PanelClass(0)="ROInterface.ROUT2k4Browser_MOTD"
     PanelClass(1)="ROInterface.ROUT2K4Browser_IRC"
     PanelClass(2)="ROInterface.ROUT2K4Browser_ServerListPageFavorites"
     PanelClass(3)="ROInterface.ROUT2K4Browser_ServerListPageLAN"
     PanelClass(4)="ROInterface.ROUT2K4Browser_ServerListPageInternet"
     PanelCaption(4)="Internet"
     PanelHint(1)="RO integrated IRC client"
     PanelHint(3)="View all RO servers currently running on your LAN"
     PanelHint(4)="Choose from hundreds of RO servers across the world"
}
