class KFServerBrowser extends UT2K4ServerBrowser;

var private ROMasterServerClient  ROMSC;
var localized string AllTypesString;
var string AllTypesClassName;

var localized string ServerPerkGatedHeading;

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

    // Adds the option to search all game types
	co_GameType.AddItem(AllTypesString, none, AllTypesClassName);
	CurrentGameType = AllTypesClassName;

	// Create a seperate list for each gametype, and store the lists in the combo box
	for (i = 0; i < Records.Length; i++)
	{
		class'CacheManager'.static.GetMapList( Maps, Records[i].MapPrefix );
		if ( Maps.Length == 0 )
			continue;

		ListObj = new(None) class'GUI2K4.UT2K4Browser_ServersList';
		co_GameType.AddItem(Records[i].GameName, ListObj, Records[i].ClassName);
	}



	j = co_GameType.FindIndex(CurrentGameType,true,true);
	if (j != -1)
	{
		co_GameType.SetIndex(j);
		SetFilterInfo();
	}
}

function MasterServerClient Uplink()
{
	if ( ROMSC == None && PlayerOwner() != None )
		ROMSC = PlayerOwner().Spawn(class'ROMasterServerClient');

	return ROMSC;
}

// Server browser must remain persistent across level changes, in order for the IRC client to function properly
event bool NotifyLevelChange()
{
	local int i;

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		if ( KFServerListPageInternet(c_Tabs.TabStack[i].MyPanel) != none )
		{
			KFServerListPageInternet(c_Tabs.TabStack[i].MyPanel).NotifyLevelChange();
		}
	}

	if ( ROMSC != None )
	{
		ROMSC.Stop();
		ROMSC.Destroy();
		ROMSC = None;
	}

	LevelChanged();
	return false;
}

function EnableMSTabs()
{
}

function DisableMSTabs()
{
	Verified = False;
}

function AddToServerCache(GameInfo.ServerResponseLine Entry)
{
}

function bool ComboOnPreDraw(Canvas Canvas)
{
	co_GameType.WinTop = co_GameType.RelativeTop(t_Header.ActualTop() + t_Header.ActualHeight() + float(Controller.ResY) / 100.0);
	co_GameType.WinLeft = co_GameType.RelativeLeft((c_Tabs.ActualLeft() + c_Tabs.ActualWidth()) - (co_GameType.ActualWidth() + 12));
	return false;
}

function JoinClicked()
{
    local int InternetPageIndex, CurrentServerDifficulty, PlayerHighestPerkLevel;
    local KFServerListPageInternet InternetPage;
    local string PerkLevels;

    InternetPageIndex = c_Tabs.TabIndex( PanelCaption[4] );
    InternetPage = KFServerListPageInternet( c_Tabs.TabStack[InternetPageIndex].MyPanel );
    CurrentServerDifficulty = InternetPage.GetCurrentServerDifficulty();
    PlayerHighestPerkLevel = CalcPlayerHighestPerkLevel( PlayerOwner() );

    if( PlayerHighestPerkLevel < 2 && CurrentServerDifficulty > 1 ) // 0 - beginner, 1 - normal
    {
        Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",ServerPerkGatedHeading,"");
    }
    else
    {
        super.JoinClicked();
    }
}

static function int CalcPlayerHighestPerkLevel( PlayerController P )
{
    local int i, HPL, NumPerks;
    local array< class<KFVeterancyTypes> > PerkClasses;
    local KFSteamStatsAndAchievements KFSS;

    HPL = -1;

    if( P != none )
	{
	    KFSS = KFSteamStatsAndAchievements(P.SteamStatsAndAchievements);
	    if ( KFSS != none )
    	{
    	    PerkClasses = class'KFGameType'.default.LoadedSkills;
            NumPerks = class'KFGameType'.default.LoadedSkills.Length;
            for( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; ++i )
            {
                HPL = Max(HPL, KFSS.PerkHighestLevelAvailable(class'KFGameType'.default.LoadedSkills[i].default.PerkIndex) );
            }
        }
	}

	return HPL;
}

defaultproperties
{
     AllTypesClassName="All Types"
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
         OnPreDraw=KFServerBrowser.ComboOnPreDraw
         OnLoadINI=KFServerBrowser.InternalOnLoadINI
     End Object
     co_GameType=moComboBox'KFGui.KFServerBrowser.GameTypeCombo'

     Begin Object Class=GUIHeader Name=ServerBrowserHeader
         bUseTextHeight=True
         Caption="Server Browser"
     End Object
     t_Header=GUIHeader'KFGui.KFServerBrowser.ServerBrowserHeader'

     Begin Object Class=KFBrowser_Footer Name=FooterPanel
         Justification=TXTA_Center
         WinTop=0.917943
         TabOrder=4
         OnPreDraw=FooterPanel.InternalOnPreDraw
     End Object
     t_Footer=KFBrowser_Footer'KFGui.KFServerBrowser.FooterPanel'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFServerBrowser.PageBackground'

     PanelClass(0)="KFGUI.KFMOTD"
     PanelClass(1)="GUI2K4.UT2k4Browser_ServerListPageFavorites"
     PanelClass(2)="KFGUI.KFServerListPageFriends"
     PanelClass(4)="KFGUI.KFServerListPageInternet"
     PanelClass(5)="none"
     PanelCaption(1)="Favorites"
     PanelCaption(2)="Friends"
     PanelCaption(4)="Internet Games"
     PanelHint(0)="The latest on KF"
     PanelHint(1)="View Killing Floor servers your Steam Friends are currently playing on"
     PanelHint(2)="View Killing Floor servers currently added to your Favorites"
     PanelHint(4)="Choose from hundreds of Killing Floor servers around the world"
     bRenderWorld=True
     BackgroundColor=(B=0,G=0,R=0)
     OnOpen=KFServerBrowser.BrowserOpened
}
