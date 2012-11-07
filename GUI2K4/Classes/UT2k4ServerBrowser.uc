// ====================================================================
//  Written by Ron Prestenback (based on XInterface.ServerBrowser)
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class UT2K4ServerBrowser extends UT2K4MainPage
    config;

// if _RO_
// else
//#exec OBJ LOAD FILE=InterfaceContent.utx
// end if _RO_

var() globalconfig bool         bStandardServersOnly;
var() config    string          CurrentGameType;
var   config    bool            bPlayerVerified;
var             string          InternetSettingsPage;

var automated   moComboBox      co_GameType;
var private MasterServerClient  MSC;
var BrowserFilters              FilterMaster;
var PlayInfo                    FilterInfo;
var UT2K4Browser_Footer         f_Browser;
var transient   bool            Verified;

// Number of open network connections
var int ThreadCount;

var array<CacheManager.GameRecord>      Records;
var UT2K4Browser_Page tp_Active;

var localized string InternetOptionsText;

var bool bHideNetworkMessage;

var string OfficialSubnets[2];

struct eServerCacheInfo
{
	var	string GameType;
	var int	SubnetIndex;
	var GameInfo.ServerResponseLine SRL;
};

var() globalconfig array<eServerCacheInfo> ServerCache;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    f_Browser = UT2K4Browser_Footer(t_Footer);

    f_Browser.p_Anchor = Self;
    f_Browser.ch_Standard.OnChange = StandardOptionChanged;
    f_Browser.ch_Standard.SetComponentValue(bStandardServersOnly, True);

    if (FilterMaster == None)
    {
        FilterMaster = new(Self) class'GUI2K4.BrowserFilters';
        FilterMaster.InitCustomFilters();
    }

    if (FilterInfo == None)
        FilterInfo = new(None) class'Engine.PlayInfo';

    Background=MyController.DefaultPens[0];

    InitializeGameTypeCombo();
    co_GameType.MyComboBox.Edit.bCaptureMouse = True;
    CreateTabs();
}

function MasterServerClient Uplink()
{
	if ( MSC == None && PlayerOwner() != None )
		MSC = PlayerOwner().Spawn( class'MasterServerClient' );

	return MSC;
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	bHideNetworkMessage = false;

	if ( tp_Active != None )
		UT2K4Browser_Footer(t_Footer).UpdateActiveButtons( tp_Active );
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender,bCancelled);
	if ( MSC != None )
		MSC.CancelPings();

	SaveConfig();

}


function bool ComboOnPreDraw(Canvas Canvas)
{
	co_GameType.WinTop = co_GameType.RelativeTop(t_Header.ActualTop() + t_Header.ActualHeight() + float(Controller.ResY) / 480.0);
	co_GameType.WinLeft = co_GameType.RelativeLeft((c_Tabs.ActualLeft() + c_Tabs.ActualWidth()) - (co_GameType.ActualWidth() + 3));
    return false;
}

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
    if (j != -1)
    {
	    co_GameType.SetIndex(j);
	    SetFilterInfo();
    }
}

function BrowserOpened()
{
    if ( !bPlayerVerified )
 	   CheckPlayerOptions();
}

function MOTDVerified(bool bMSVerified)
{
    EnableMSTabs();
    Verified = bMSVerified;
}

function CheckPlayerOptions()
{
	local PlayerController PC;
	local string CurrentName;

	PC = PlayerOwner();
	if ( PC.PlayerReplicationInfo != None )
		CurrentName = PC.PlayerReplicationInfo.PlayerName;
	else CurrentName = PC.GetURLOption( "Name" );

	if ( CurrentName ~= "Player" || class'Player'.default.ConfiguredInternetSpeed == 9636 )
	{
		if ( Controller.OpenMenu( Controller.QuestionMenuClass ) )
		{
			GUIQuestionPage(Controller.ActivePage).SetupQuestion(InternetOptionsText, QBTN_YesNoCancel);
			GUIQuestionPage(Controller.ActivePage).NewOnButtonClick = InternetOptionsConfirm;
		}
	}

	else
	{
		bPlayerVerified = True;
		SaveConfig();
	}
}

function bool InternetOptionsConfirm( byte ButtonMask )
{
	local GUIQuestionPage pg;

	if ( bool(ButtonMask & QBTN_No) )
		return true;

	if ( bool(ButtonMask & QBTN_Cancel) )
	{
		bPlayerVerified = True;
		SaveConfig();
		return true;
	}

	pg = GUIQuestionPage(Controller.ActivePage);
	if ( pg == None )
		return true;

	if ( bool(ButtonMask & QBTN_Yes) )
	{
		if ( Controller.ReplaceMenu( InternetSettingsPage ) )
			Controller.ActivePage.OnClose = InternetOptionsClosed;

		return True;
	}

	return false;
}

function InternetOptionsClosed( bool bCancelled )
{
	bPlayerVerified = True;
	SaveConfig();
}

function CreateTabs()
{
	local int i;

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		if ( PanelClass[i] != "" )
			AddTab(PanelCaption[i], PanelClass[i], PanelHint[i]);
	}

	DisableMSTabs();


	// Must perform the first refresh manually, since the RefreshFooter delegate won't be assigned
	// when the first tab panel receives the first call to ShowPanel()
	RefreshFooter( UT2K4Browser_Page(c_Tabs.ActiveTab.MyPanel),"false" );
}

function EnableMSTabs()
{
	local UT2K4Browser_ServerListPageBuddy BuddyPanel;
	local int i;

	i = c_Tabs.TabIndex( PanelCaption[4] );
	if ( i != -1 )
	{
		EnableComponent(c_Tabs.TabStack[i]);
		BuddyPanel = UT2K4Browser_ServerListPageBuddy(c_Tabs.TabStack[i].MyPanel);
	}

	i = c_Tabs.TabIndex( PanelCaption[5] );
	if ( i != -1 )
		EnableComponent(c_Tabs.TabStack[i]);

	if ( BuddyPanel == None )
		return;

    // All players lists need a reference to the buddy page
    for (i = 0; i < c_Tabs.TabStack.Length; i++)
    {
        if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel) != None)
        {
            if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players != None)
                UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players.tp_Buddy = BuddyPanel;
        }
    }
}

function DisableMSTabs()
{
	local int i;

	Verified = False;
	i = c_Tabs.TabIndex( PanelCaption[4] );
	if ( i != -1 )
		DisableComponent(c_Tabs.TabStack[i]);

	i = c_Tabs.TabIndex( PanelCaption[5] );
	if ( i != -1 )
		DisableComponent(c_Tabs.TabStack[i]);

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		if ( UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel) != None )
        {
            if (UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players != None)
                UT2K4Browser_ServerListPageBase(c_Tabs.TabStack[i].MyPanel).lb_Players.tp_Buddy = None;
        }
    }
}

function UT2K4Browser_Page AddTab( string TabCaption, string PanelClassName, string TabHint )
{
	local UT2K4Browser_Page Tab;

	if ( TabCaption != "" && PanelClassName != "" && TabHint != "" )
	{
		Tab = UT2K4Browser_Page(c_Tabs.AddTab(TabCaption, PanelClassName,, TabHint));
		if ( Tab != None )
		{
			Tab.RefreshFooter = RefreshFooter;
			Tab.OnOpenConnection = ConnectionOpened;
			Tab.OnCloseConnection = ConnectionClosed;
		}
	}

	return Tab;
}

delegate OnAddFavorite( GameInfo.ServerResponseLine Server );

// Server browser must remain persistent across level changes, in order for the IRC client to function properly
event bool NotifyLevelChange()
{
	if ( MSC != None )
	{
		MSC.Stop();
		MSC.Destroy();
	}

	MSC = None;
	LevelChanged();
	return false;
}

function InternalOnChange(GUIComponent Sender)
{
	local bool bShowGameType;

    if ( GUITabButton(Sender) != None )
    {
        // Update gametype combo box visibility
        bShowGameType = tp_Active != None && tp_Active.ShouldDisplayGameType();
        if ( co_GameType.bVisible != bShowGameType )
        	co_GameType.SetVisibility(bShowGameType);
    }
}

function StandardOptionChanged( GUIComponent Sender )
{
	SetStandardServersOption( moCheckBox(Sender).IsChecked() );
}

function SetStandardServersOption( bool bOnlyStandard )
{
	if ( bOnlyStandard != bStandardServersOnly )
	{
		bStandardServersOnly = bOnlyStandard;
		SaveConfig();

		Refresh();
	}
}

function RefreshFooter( optional UT2K4Browser_Page NewActive, optional string bPerButtonSizes )
{
	if ( NewActive != None )
	{
		tp_Active = NewActive;
		if ( UT2K4Browser_Footer(t_Footer) != None )
			UT2K4Browser_Footer(t_Footer).UpdateActiveButtons(tp_Active);
	}

	if ( t_Footer != None )
		t_Footer.SetupButtons(bPerButtonSizes);
}

function InternalOnLoadIni(GUIComponent Sender, string s)
{
    local int i;

    if (Sender == co_GameType)
    {
        if (CurrentGameType == "")
        {
            CurrentGameType = S;
            SaveConfig();

            i = co_GameType.FindExtra(CurrentGameType);
            if (i != -1)
            {
            	Log("#### - Load INI setting Index to: "@i);
                co_GameType.SetIndex(i);
            }

            SetFilterInfo();
        }
    }
}

function PopulateGameTypes()
{
    local array<CacheManager.GameRecord> Games;
    local int i, j;

    if (Records.Length > 0)
        Records.Remove(0, Records.Length);

    class'CacheManager'.static.GetGameTypeList(Games);
    for (i = 0; i < Games.Length; i++)
    {
        for (j = 0; j < Records.Length; j++)
        {
            if ((Games[i].GameName <= Records[j].GameName) || (Games[i].GameTypeGroup <= Records[j].GameTypeGroup))
            {
                if (Games[i].GameTypeGroup <= Records[j].GameTypeGroup)
                    continue;
                else break;
            }
        }

        Records.Insert(j, 1);
        Records[j] = Games[i];
    }
}

function string GetDesc(string Desc)
{
    local int i;

    i = InStr(Desc, "|");
    if (i >= 0)
        Desc = Mid(Desc, i+1);

    i = InStr(Desc, "|");
    if (i >= 0)
        Desc = Left(Desc, i);

    return Desc;
}

function SetFilterInfo(optional string NewGameType)
{
    local class<GameInfo>       GI;
    local class<AccessControl>  AC;
    local class<Mutator>        Mut;    // Only add basemutator playinfo settings for now

	return;

    Assert(FilterInfo != None);
    FilterInfo.Clear();

    if (NewGameType == "")
        NewGameType = CurrentGameType;

    GI = class<GameInfo>(DynamicLoadObject(NewGameType, class'Class'));
    if (GI != None)
    {
        GI.static.FillPlayInfo(FilterInfo);
        FilterInfo.PopClass();

        AC = class<AccessControl>(DynamicLoadObject(GI.default.AccessControlClass, class'Class'));
        if (AC != None)
        {
            AC.static.FillPlayInfo(FilterInfo);
            FilterInfo.PopClass();
        }

        Mut = class<Mutator>(DynamicLoadObject(GI.default.MutatorClass, class'Class'));
        if (Mut != None)
        {
            Mut.static.FillPlayInfo(FilterInfo);
            FilterInfo.PopClass();
        }
    }
}

function JoinClicked()
{
	if ( tp_Active != None )
		tp_Active.JoinClicked();
}

function SpectateClicked()
{
	if ( tp_Active != None )
		tp_Active.SpectateClicked();
}

function RefreshClicked()
{
	if ( tp_Active != None )
		tp_Active.RefreshClicked();
}

function FilterClicked()
{
	if ( tp_Active != None )
		tp_Active.FilterClicked();
}

function Refresh()
{
	local int i;
	local string dummy;

	if ( c_Tabs == None )
		return;

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		if ( c_Tabs.TabStack[i].MenuState != MSAT_Disabled &&
		     UT2K4Browser_Page(c_Tabs.TabStack[i].MyPanel) != None &&
			 UT2K4Browser_Page(c_Tabs.TabStack[i].MyPanel).IsFilterAvailable(dummy) )
			c_Tabs.TabStack[i].MyPanel.Refresh();
	}
}

static function int CalculateMaxConnections()
{
	local int i;

	if ( class'GUIController'.default.MaxSimultaneousPings < 1 )
	{
		i = class'Player'.default.ConfiguredInternetSpeed;

		if ( i <= 2600 )
			return 10;

		if ( i <= 5000 )
			return 15;

		if ( i <= 10000 )
			return 20;

		if ( i <= 20000 )
			return 35;
	}

	return Min( class'GUIController'.default.MaxSimultaneousPings, 35 );
}

// Returns the maximum number of concurrent UDP connections we're allowed to open
// Specify bCurrentlyAvailable = True to get the difference from the number of connections currently open
function int GetMaxConnections(optional bool bCurrentlyAvailable)
{
	local int Max;

	Max = CalculateMaxConnections();
	if ( bCurrentlyAvailable )
		return Max - ThreadCount;

	return Max;
}

function ConnectionOpened(optional int Num)
{
	if ( Num <= 0 )
		Num = 1;

	ThreadCount += Num;
}

function ConnectionClosed(optional int Num)
{
	if ( Num <= 0 )
		Num = 1;

	ThreadCount -= Num;
	if ( ThreadCount < 0 )
		ThreadCount = 0;
}

/*

struct eServerCacheInfo
{
	var	string GameType;
	var GameInfo.ServerResponseLine SRL;
}

var() globalconfig bool ServerCache;


*/

function ClearServerCache()
{
	local int i;

	i = 0;
	while (i<ServerCache.Length)
	{
		if (ServerCache[i].GameType ~= CurrentGameType)
			ServerCache.Remove(i,1);
		else
			i++;
	}

}

function string FixString(string s)
{
	local string t;
	local int i;

	if (len(s)>200)
		t = left(s,200);
	else
		t = s;

	s = "";
	for (i=0;i<len(t);i++)
	{
		if ( Asc(mid(t,i,1))==34 )
			s = s$"`";

		else if ( Asc(mid(t,i,1))>=32 )
			s = s$mid(t,i,1);
//ifdef _RO_
		if ( i > 200 )
			return s;
//endif
	}

	return s;
}

function AddToServerCache(GameInfo.ServerResponseLine Entry)
{
	ServerCache.Insert(0,1);
	ServerCache[0].GameType 	= CurrentGameType;

	ServerCache[0].SRL.IP 			= Entry.IP;
	ServerCache[0].SRL.ServerName 	= FixString(Entry.ServerName);
	ServerCache[0].SRL.QueryPort    = Entry.QueryPort;
	ServerCache[0].SRL.GameType		= FixString(Entry.GameType);
	ServerCache[0].SRL.Flags		= Entry.Flags;
}

function GetFromServerCache(UT2K4Browser_ServersList List)
{
	local int i;
	local GameInfo.ServerResponseLine SRL;
	for (i=0;i<ServerCache.Length;i++)
	{
		if (ServerCache[i].GameType ~= CurrentGameType)
		{
			SRL = ServerCache[i].SRL;
			SRL.Ip = ServerCache[i].SRL.IP;
			SRL.MapName = "Unknown";
    		List.MyOnReceivedServer( SRL );
    	}
    }
}

defaultproperties
{
     bStandardServersOnly=True
     CurrentGameType="KFMod.KFGameType"
     InternetSettingsPage="GUI2K4.UT2K4InternetSettingsPage"
     Begin Object Class=moComboBox Name=GameTypeCombo
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Game Type"
         OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         Hint="Choose the gametype to query"
         WinTop=0.050160
         WinLeft=0.638878
         WinWidth=0.358680
         WinHeight=0.035000
         RenderWeight=1.000000
         TabOrder=0
         OnPreDraw=UT2k4ServerBrowser.ComboOnPreDraw
         OnLoadINI=UT2k4ServerBrowser.InternalOnLoadINI
     End Object
     co_GameType=moComboBox'GUI2K4.UT2k4ServerBrowser.GameTypeCombo'

     InternetOptionsText="You have not fully configured your internet play options.  It is recommended that you configure a unique player name and review your netspeed setting before joining a multiplayer game.|Would you like to do this now?"
     OfficialSubnets(0)="69.25.22."
     OfficialSubnets(1)="64.74.139."
     Begin Object Class=GUIHeader Name=ServerBrowserHeader
         bUseTextHeight=True
         Caption="Server Browser"
     End Object
     t_Header=GUIHeader'GUI2K4.UT2k4ServerBrowser.ServerBrowserHeader'

     Begin Object Class=UT2k4Browser_Footer Name=FooterPanel
         WinTop=0.917943
         TabOrder=4
         OnPreDraw=FooterPanel.InternalOnPreDraw
     End Object
     t_Footer=UT2k4Browser_Footer'GUI2K4.UT2k4ServerBrowser.FooterPanel'

     PanelClass(0)="GUI2K4.UT2K4Browser_MOTD"
     PanelClass(1)="GUI2K4.UT2K4Browser_IRC"
     PanelClass(2)="GUI2K4.UT2K4Browser_ServerListPageFavorites"
     PanelClass(3)="GUI2K4.UT2K4Browser_ServerListPageLAN"
     PanelClass(4)="GUI2K4.UT2K4Browser_ServerListPageBuddy"
     PanelClass(5)="GUI2K4.UT2K4Browser_ServerListPageInternet"
     PanelCaption(0)="News"
     PanelCaption(1)="Chat"
     PanelCaption(2)="Favorites"
     PanelCaption(3)="LAN"
     PanelCaption(4)="Buddies"
     PanelCaption(5)="Internet"
     PanelHint(0)="Get the latest news from Tripwire"
     PanelHint(1)="Killing Floor integrated IRC client"
     PanelHint(2)="Choose a server to join from among your favorites"
     PanelHint(3)="View all Killing Floor servers currently running on your LAN"
     PanelHint(4)="See where your buddies are currently playing, or join them in the game"
     PanelHint(5)="Choose from hundreds of Killing Floor servers across the world"
     bCheckResolution=True
     OnOpen=UT2k4ServerBrowser.BrowserOpened
     bDrawFocusedLast=False
}
