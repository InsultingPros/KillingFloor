class KFMapPage extends UT2K4Tab_MainSP;

var     automated           moComboBox                          co_Difficulty;
var     automated           moComboBox                          co_GameLength;
var     automated           moCheckBox                          ch_Sandbox;

var()   editconst noexport  PlayInfo                            GamePI;
var                         array<PlayInfo.PlayInfoData>        InfoRules;
var                         byte                                LastGameLengthIndex;
var                         int                                 DefaultInitialCountDownValue;
var							bool								bDisableCombos;

function bool Tick(Canvas Canvas)
{
	if ( bDisableCombos )
	{
		co_Difficulty.DisableMe();
		co_GameLength.DisableMe();
	}

	return super.OnDraw(Canvas);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<CacheManager.MapRecord> TutMaps;

	OnDraw = Tick;

    super(UT2K4GameTabBase).InitComponent(MyController, MyOwner);

	if ( lb_Maps != None )
		li_Maps = lb_Maps.List;

	if ( li_Maps != None )
	{
	    li_Maps.OnDblClick = MapListDblClick;
	    li_Maps.bSorted = True;
	    lb_Maps.NotifyContextSelect = HandleContextSelect;
	}

	class'CacheManager'.static.InitCache();
    MapHandler = PlayerOwner().Spawn(class'MaplistManager');
    class'CacheManager'.static.GetMaplist(TutMaps, "TUT");

	lb_Maps.bBoundToParent=false;
	lb_Maps.bScaleToParent=false;

	sb_Selection.ManageComponent(lb_Maps);

	asb_Scroll.ManageComponent(lb_MapDesc);

    LastGameLengthIndex = 0;

    sb_Options.ManageComponent(co_Difficulty);
    sb_Options.ManageComponent(co_GameLength);
    sb_Options.ManageComponent(ch_Sandbox);
    sb_Options.ManageComponent(b_Maplist);

    SetGamePI();
}

protected function SetGamePI()
{
    p_Anchor.SetRuleInfo();
    GamePI = p_Anchor.RuleInfo;
	GamePI.Sort(0);
}

function ShowPanel(bool bShow)
{
	local int DifficultyIndex;

	super.ShowPanel(bShow);

	DifficultyIndex = GamePI.FindIndex("GameDifficulty");

	if ( float(GamePI.Settings[DifficultyIndex].Value) < 2.0000 )
	{
		co_Difficulty.SetIndex(0);
	}
	else if ( float(GamePI.Settings[DifficultyIndex].Value) < 4.0000 )
	{
		co_Difficulty.SetIndex(1);
	}
	else if ( float(GamePI.Settings[DifficultyIndex].Value) < 5.0000 )
	{
		co_Difficulty.SetIndex(2);
	}
	else if ( float(GamePI.Settings[DifficultyIndex].Value) < 7.0000 )
	{
		co_Difficulty.SetIndex(3);
	}
	else
	{
	 	co_Difficulty.SetIndex(4);
	}
}

function RefreshOptions()
{
    local int i, j;
    local array<string> Range;

	SetGamePI();
    GamePI.GetSettings("", InfoRules);
	co_Difficulty.MyComboBox.Clear();
	co_GameLength.MyComboBox.Clear();

	for ( i = 0; i < InfoRules.Length; i++)
    {
        if ( InfoRules[i].DisplayName == co_Difficulty.Caption )
        {
            GamePI.SplitStringToArray(Range, InfoRules[i].Data, ";");

			for ( j = 0; j + 1 < Range.Length; j += 2 )
            {
                co_Difficulty.AddItem(Range[j+1], , Range[j]);
                co_Difficulty.Tag = i;
            }
        }
        else if ( InfoRules[i].DisplayName == co_GameLength.Caption )
        {
            GamePI.SplitStringToArray(Range, InfoRules[i].Data, ";");

			for ( j = 0; j + 1 < Range.Length; j += 2 )
            {
                co_GameLength.AddItem(Range[j+1], , Range[j]);
                co_GameLength.Tag = i;
            }
        }
    }

	co_GameLength.SetIndex(class'KFGameType'.default.KFGameLength);
	GameLengthChange(co_GameLength);
}

function InternalOnChange(GUIComponent Sender)
{
	if (GUIMultiOptionList(Sender) != None)
	{
		if (Controller.bCurMenuInitialized)
			UpdateSetting(GUIMultiOptionList(Sender).Get());
	}

	else if ( GUIMenuOption(Sender) != None && Controller.bCurMenuInitialized )
		UpdateSetting( GUIMenuOption(Sender) );
}

function UpdateSetting(GUIMenuOption Sender)
{
    local int i;
    local int Index;

    if ( Sender == none )
    {
        return;
    }

    i = Sender.Tag;

    if ( i < 0 )
    {
        return;
    }

    if ( InfoRules[i].DisplayName != Sender.Caption )
    {
    	if ( Controller.bModAuthor )
		{
		   	log("Corrupt list index detected in component"@Sender.Name,'ModAuthor');
    	}

        return;
    }

    Index = GamePI.FindIndex(InfoRules[i].SettingName);

    if ( InfoRules[i].DisplayName != Sender.Caption || Index == -1 )
    {
    	if ( Controller.bModAuthor )
    	{
	    	log("Invalid setting requested from PlayInfo!",'ModAuthor');
	    }

    	return;
    }

    StoreSetting(Index, Sender.GetComponentValue());
}

protected function StoreSetting(int Index, string NewValue)
{
	GamePI.StoreSetting(Index, NewValue);
}


// Called when a new gametype is selected
function InitGameType()
{
    local int i;
    local array<CacheManager.GameRecord> Games;
    local bool bReloadMaps;

	// Get a list of all gametypes.
    class'CacheManager'.static.GetGameTypeList(Games);
	for (i = 0; i < Games.Length; i++)
    {
        if (Games[i].ClassName ~= Controller.LastGameType)
        {
        	bReloadMaps = CurrentGameType.MapPrefix != Games[i].MapPrefix;
            CurrentGameType = Games[i];
            break;
        }
    }

    if ( i == Games.Length )
    	return;

	// Enable/Disable extra options based on GameType
	if ( CurrentGameType.ClassName == "KFMod.KFGameType" )
	{
		co_GameLength.EnableMe();
		ch_Sandbox.EnableMe();
	}
	else
	{
		co_GameLength.DisableMe();
		ch_Sandbox.DisableMe();
	}

	// Update the gametype label's text
    SetGameTypeCaption();

    // Should the tutorial button be enabled?
    // CheckGameTutorial();

    // Load Maps for the new gametype, but only if it uses a different maplist
    if (bReloadMaps)
   		InitMaps();

    // Set the selected map
    i = li_Maps.FindIndexByValue(LastSelectedMap);
    if ( i == -1 )
    	i = 0;
    li_Maps.SetIndex(i);
    li_Maps.Expand(i);

	// Load the information (screenshot, desc., etc.) for the currently selected map
    // ReadMapInfo(li_Maps.GetParentCaption());
}

// Query the CacheManager for the maps that correspond to this gametype, then fill the main list
function InitMaps(optional string MapPrefix)
{
    local int i, j;
    local bool bTemp;
    local string Package, Item, Desc;
    local GUITreeNode StoredItem;
    local DecoText DT;

    // Make sure we have a map prefix
    if ( MapPrefix == "" )
    {
        MapPrefix = GetMapPrefix();
    }

    // Temporarily disable notification in all components
    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    if ( li_Maps.IsValid() )
        li_Maps.GetElementAtIndex(li_Maps.Index, StoredItem);

    // Get the list of maps for the current gametype
    class'CacheManager'.static.GetMapList( CacheMaps, MapPrefix );
    if ( MapHandler.GetAvailableMaps(MapHandler.GetGameIndex(CurrentGameType.ClassName), Maps) )
    {
        li_Maps.bNotify = False;
        li_Maps.Clear();

        for ( i = 0; i < Maps.Length; i++ )
        {
            DT = None;
            if ( class'CacheManager'.static.IsDefaultContent(Maps[i].MapName) )
            {
                if ( bOnlyShowCustom )
                    continue;
            }
            else if ( bOnlyShowOfficial )
                continue;

            j = FindCacheRecordIndex(Maps[i].MapName);
            if ( class'CacheManager'.static.Is2003Content(Maps[i].MapName) )
            {
                if ( CacheMaps[j].TextName != "" )
                {
                    if ( !Divide(CacheMaps[j].TextName, ".", Package, Item) )
                {
                        Package = "XMaps";
                        Item = CacheMaps[j].TextName;
                    }
                }

                DT = class'xUtil'.static.LoadDecoText(Package, Item);
            }

            if ( DT != None )
                Desc = JoinArray(DT.Rows, "|");
            else
                Desc = CacheMaps[j].Description;


            // KF Map Hack
            if ( CurrentGameType.MapPrefix ~= "KF" )
            {
				if (Maps[i].MapName != "KF-Intro" && Maps[i].MapName != "KF-Menu")
					li_Maps.AddItem( Maps[i].MapName, Maps[i].MapName, ,,Desc);
            }
            else
				li_Maps.AddItem( Maps[i].MapName, Maps[i].MapName, ,,Desc);
        }
    }

    if ( li_Maps.bSorted )
        li_Maps.SortList();

    if ( StoredItem.Caption != "" )
    {
        i = li_Maps.FindFullIndex(StoredItem.Caption, StoredItem.Value, StoredItem.ParentCaption);
        if ( i != -1 )
            li_Maps.SilentSetIndex(i);
    }

    li_Maps.bNotify = True;

    Controller.bCurMenuInitialized = bTemp;
}

function SandBoxChange(GUIComponent Sender)
{
    local int CountDownIndex, DifficultyIndex;

	if ( ch_Sandbox.IsChecked() )
    {
    	bDisableCombos = true;

        co_GameLength.SetIndex(3);

        sb_Options.DisableComponent(co_Difficulty);
        sb_Options.DisableComponent(co_GameLength);

        UT2K4MainPage(OwnerPage()).c_Tabs.TabStack[1].EnableMe();
    }
    else
    {
    	bDisableCombos = false;

        sb_Options.EnableComponent(co_Difficulty);
        sb_Options.EnableComponent(co_GameLength);

		co_GameLength.SetIndex(LastGameLengthIndex);

        CountDownIndex = GamePI.FindIndex("InitialCountDownValue");
        GamePI.StoreSetting(CountDownIndex, DefaultInitialCountDownValue);

        DifficultyIndex = GamePI.FindIndex("GameDifficulty");

		if ( float(GamePI.Settings[DifficultyIndex].Value) < 2.0000 )
		{
			co_Difficulty.SetIndex(0);
		}
		else if ( float(GamePI.Settings[DifficultyIndex].Value) < 4.0000 )
		{
			co_Difficulty.SetIndex(1);
		}
		else if ( float(GamePI.Settings[DifficultyIndex].Value) < 5.0000 )
		{
			co_Difficulty.SetIndex(2);
		}
		else if ( float(GamePI.Settings[DifficultyIndex].Value) < 7.0000 )
		{
			co_Difficulty.SetIndex(3);
		}
		else
		{
		 	co_Difficulty.SetIndex(4);
		}

		GameLengthChange(Sender);
		UT2K4MainPage(OwnerPage()).c_Tabs.TabStack[1].DisableMe();
    }
}

function GameLengthChange(GUIComponent Sender)
{
    if ( co_GameLength.GetIndex() != 3 )
    {
        LastGameLengthIndex = co_GameLength.GetIndex();
    }

    class'KFGameType'.default.KFGameLength = co_GameLength.GetIndex();
    class'KFGameType'.static.StaticSaveConfig();
    UpdateSetting(co_GameLength);

    if ( class'KFGameType'.default.KFGameLength == 3 )
    {
        ch_Sandbox.SetComponentValue(true);
        SandBoxChange(Sender);
    }
    else
    {
        if ( ch_Sandbox.IsChecked() )
        {
            ch_Sandbox.SetComponentValue(false);
            SandBoxChange(Sender);
            //co_GameLength.SetIndex(LastGameLengthIndex);
        }
    }
}

function GameDifficultyChange(GUIMenuOption Sender)
{
	local int NewIndex;


	NewIndex = co_Difficulty.GetIndex();

	if ( NewIndex == 0 )
	{
		class'KFGameType'.default.GameDifficulty = 1.0000;
	}
	else if ( NewIndex == 1 )
	{
		class'KFGameType'.default.GameDifficulty = 2.0000;
	}
	else if ( NewIndex == 3 )
	{
		class'KFGameType'.default.GameDifficulty = 4.0000;
	}
	else if ( NewIndex == 4 )
	{
		class'KFGameType'.default.GameDifficulty = 5.0000;
	}
	else
	{
		class'KFGameType'.default.GameDifficulty = 7.0000;
	}

	class'KFGameType'.static.StaticSaveConfig();
	UpdateSetting(Sender);
}

defaultproperties
{
     Begin Object Class=moComboBox Name=DifficultyCombo
         bReadOnly=True
         ComponentWidth=0.500000
         Caption="Difficulty"
         OnCreateComponent=DifficultyCombo.InternalOnCreateComponent
         Hint="Sets how skilled your opponents will be"
         WinTop=0.750547
         WinLeft=0.087169
         WinWidth=0.341797
         TabOrder=0
         OnChange=KFMapPage.GameDifficultyChange
     End Object
     co_Difficulty=moComboBox'KFGui.KFMapPage.DifficultyCombo'

     Begin Object Class=moComboBox Name=GameLengthCombo
         bReadOnly=True
         ComponentWidth=0.500000
         Caption="Game Length"
         OnCreateComponent=GameLengthCombo.InternalOnCreateComponent
         Hint="Sets how long the game will be"
         WinTop=0.750547
         WinLeft=0.087169
         WinWidth=0.341797
         TabOrder=1
         OnChange=KFMapPage.GameLengthChange
     End Object
     co_GameLength=moComboBox'KFGui.KFMapPage.GameLengthCombo'

     Begin Object Class=moCheckBox Name=SandboxCheck
         CaptionWidth=0.500000
         ComponentWidth=0.500000
         Caption="Enable Sandbox"
         OnCreateComponent=SandboxCheck.InternalOnCreateComponent
         Hint="Enable the advanced sandbox settings"
         WinTop=0.772865
         WinLeft=0.051758
         WinWidth=0.341797
         TabOrder=3
         OnChange=KFMapPage.SandBoxChange
     End Object
     ch_Sandbox=moCheckBox'KFGui.KFMapPage.SandboxCheck'

     DefaultInitialCountDownValue=60
     Begin Object Class=AltSectionBackground Name=ScrollSection
         bFillClient=True
         bNoCaption=True
         Caption="Map Desc"
         WinTop=0.525219
         WinLeft=0.546118
         WinWidth=0.409888
         WinHeight=0.437814
         OnPreDraw=ScrollSection.InternalPreDraw
     End Object
     asb_Scroll=AltSectionBackground'KFGui.KFMapPage.ScrollSection'

     Begin Object Class=moButton Name=MaplistButton
         ButtonCaption="Maplist Configuration"
         ComponentWidth=1.000000
         OnCreateComponent=MaplistButton.InternalOnCreateComponent
         Hint="Modify the maps that should be used in gameplay"
         WinTop=0.888587
         WinLeft=0.039258
         WinWidth=0.341797
         WinHeight=0.050000
         TabOrder=4
         OnChange=KFMapPage.MaplistConfigClick
     End Object
     b_Maplist=moButton'KFGui.KFMapPage.MaplistButton'

     b_Tutorial=None

     LastSelectedMap="KF-Doom2-Final-REWHITELISTED"
     ch_OfficialMapsOnly=None

}
