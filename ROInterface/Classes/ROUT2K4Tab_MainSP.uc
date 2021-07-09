//-----------------------------------------------------------
// Modified by emh, 12/02/2005
//-----------------------------------------------------------
class ROUT2K4Tab_MainSP extends UT2K4Tab_MainSP;

var automated GUISectionBackground  sb_options2;

var automated moComboBox            co_Difficulty;

var array<float>                    difficulties;

var bool                            bHideDifficultyControl;

delegate OnChangeDifficulty(int index);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super(UT2K4GameTabBase).InitComponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

	if ( lb_Maps != None )
		li_Maps = lb_Maps.List;

	if ( li_Maps != None )
	{
	    li_Maps.OnDblClick = MapListDblClick;
	    li_Maps.bSorted = True;
	    lb_Maps.NotifyContextSelect = HandleContextSelect;
	}

	lb_Maps.bBoundToParent=false;
	lb_Maps.bScaleToParent=false;

	sb_Selection.ManageComponent(lb_Maps);

	asb_Scroll.ManageComponent(lb_MapDesc);

    InitMapHandler();
    InitGameType();
    //log("ROUT2K4Tab_MainSP::InitComponent()");

    InitDifficulty();
}

function ShowPanel(bool bShow)	// Show Panel should be subclassed if any special processing is needed
{
	super.ShowPanel(bShow);

    if (bHideDifficultyControl)
    {
	   co_Difficulty.SetVisibility(false);
	   sb_options2.SetVisibility(false);
	}
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
        //log("Games[i].ClassName="$ Games[i].ClassName);
        //log("Controller.LastGameType="$Controller.LastGameType);

        // HACK
        // Puma 5-3-2004
        if (Games[i].ClassName == "ROEngine.ROTeamGame")
        {
            //log("ROUT2K4Tab_MainSP: ROTeamGame found");
            CurrentGameType = Games[i];
            bReloadMaps = true;
            break;
        }
    }

	log("Current game type = "$CurrentGameType.ClassName);

    if ( i == Games.Length )
    	return;

    //log("ROUT2K4Tab_MainSP: Init ROGame");

	// Update the gametype label's text
    SetGameTypeCaption();

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
//    ReadMapInfo(li_Maps.GetParentCaption());
}

function CheckGameTutorial()
{
}
// Called when user clicks on a new map in the main maplist
function MapListChange(GUIComponent Sender)
{
	local MaplistRecord.MapItem Item;

    if (!Controller.bCurMenuInitialized)
        return;

	if ( Sender == lb_Maps )
	{
		if ( li_Maps.IsValid() )
		{
		   // Puma 05-03-2004
		   // changed to the Anchor's Primary and Secondary
			EnableComponent(p_Anchor.b_Primary);
			EnableComponent(p_Anchor.b_Secondary);
		}

		class'MaplistRecord'.static.CreateMapItem(li_Maps.GetValue(), Item);

		LastSelectedMap = Item.FullURL;
		SaveConfig();
		ReadMapInfo(Item.MapName);
	}
}

function MaplistConfigClick( GUIComponent Sender )
{
	local MaplistEditor MaplistPage;

    // Hack to ignore whats in RedOrchestraUser.ini Puma 5-25-2004
    MaplistEditorMenu="ROInterface.ROMaplistEditor";

	// open maplist config page
	if ( Controller.OpenMenu(MaplistEditorMenu) )
	{
		MaplistPage = MaplistEditor(Controller.ActivePage);
		if ( MaplistPage != None )
		{
			MaplistPage.MainPanel = self;
			MaplistPage.bOnlyShowOfficial = bOnlyShowOfficial;
			MaplistPage.bOnlyShowCustom = bOnlyShowCustom;
			MaplistPage.Initialize(MapHandler);
		}
	}
}

function InitDifficulty()
{
    local string props;
    local array<string> splits;
    local int i, count;

    // We use the property from ROTeamGame to fill the combo
    props = class'ROEngine.ROTeamGame'.static.GetPropsExtra(0);
    count = Split(props, ";", splits);

    // Don't do anything if we don't have an even number of elements (e.g. each element is paired)
    if (count <= 0 || count % 2 != 0)
        return;

    // Add properties to combo + save difficulties to array
    for (i = 0; i < count / 2; i++)
    {
        difficulties[i] = float(splits[i*2]);
        co_Difficulty.AddItem(splits[(i*2)+1],, splits[i*1]);
    }

    UpdateCurrentGameDifficulty();
}

function UpdateCurrentGameDifficulty()
{
    local float currentDifficulty;
    local int i;

    // Get current difficulty and set current in array
    currentDifficulty = class'ROEngine.ROTeamGame'.default.GameDifficulty;
    for (i = 0; i < difficulties.length; i++)
        if (currentDifficulty == difficulties[i])
        {
            co_Difficulty.SilentSetIndex(i);
            return; // all done!
        }

    warn("Unable to set current GameDifficulty in difficulty combobox (difficulty not found)");
}

function OnNewDifficultySelect(GUIComponent Sender)
{
    if (Sender == co_Difficulty)
    {
        // Change difficulty
        class'ROEngine.ROTeamGame'.default.GameDifficulty = difficulties[co_Difficulty.GetIndex()];

        // Save difficulty
        class'ROEngine.ROTeamGame'.static.StaticSaveConfig();

        // Tell rules tab to reload its settings
        OnChangeDifficulty(co_Difficulty.GetIndex());
    }
}

function SilentSetDifficulty(int index)
{
    co_Difficulty.SilentSetIndex(index);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=OptionsContainer
         bFillClient=True
         Caption="Options"
         WinTop=0.634726
         WinLeft=0.016993
         WinWidth=0.482149
         WinHeight=0.325816
         OnPreDraw=OptionsContainer.InternalPreDraw
     End Object
     sb_options2=GUISectionBackground'ROInterface.ROUT2K4Tab_MainSP.OptionsContainer'

     Begin Object Class=moComboBox Name=DifficultyCombo
         bReadOnly=True
         Caption="Difficulty"
         OnCreateComponent=DifficultyCombo.InternalOnCreateComponent
         Hint="Sets how skilled your opponents will be"
         WinTop=0.750547
         WinLeft=0.087169
         WinWidth=0.341797
         WinHeight=0.034236
         TabOrder=0
         OnChange=ROUT2K4Tab_MainSP.OnNewDifficultySelect
     End Object
     co_Difficulty=moComboBox'ROInterface.ROUT2K4Tab_MainSP.DifficultyCombo'

     Begin Object Class=GUISectionBackground Name=SelectionGroup
         bFillClient=True
         Caption="Map Selection"
         WinTop=0.018125
         WinLeft=0.016993
         WinWidth=0.482149
         WinHeight=0.600000
         OnPreDraw=SelectionGroup.InternalPreDraw
     End Object
     sb_Selection=GUISectionBackground'ROInterface.ROUT2K4Tab_MainSP.SelectionGroup'

     Begin Object Class=GUISectionBackground Name=PreviewGroup
         bFillClient=True
         Caption="Preview"
         WinTop=0.018125
         WinLeft=0.515743
         WinWidth=0.470899
         WinHeight=0.942417
         OnPreDraw=PreviewGroup.InternalPreDraw
     End Object
     sb_Preview=GUISectionBackground'ROInterface.ROUT2K4Tab_MainSP.PreviewGroup'

     sb_Options=None

     Begin Object Class=GUISectionBackground Name=ScrollSection
         bFillClient=True
         Caption="Map Desc"
         WinTop=0.525219
         WinLeft=0.546118
         WinWidth=0.409888
         WinHeight=0.412304
         OnPreDraw=ScrollSection.InternalPreDraw
     End Object
     asb_Scroll=GUISectionBackground'ROInterface.ROUT2K4Tab_MainSP.ScrollSection'

     Begin Object Class=GUIScrollTextBox Name=MapDescription
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=MapDescription.InternalOnCreateComponent
         WinTop=0.628421
         WinLeft=0.561065
         WinWidth=0.379993
         WinHeight=0.268410
         bTabStop=False
         bNeverFocus=True
     End Object
     lb_MapDesc=GUIScrollTextBox'ROInterface.ROUT2K4Tab_MainSP.MapDescription'

     Begin Object Class=moButton Name=MaplistButton
         ButtonCaption="Maplist Configuration"
         ComponentWidth=1.000000
         OnCreateComponent=MaplistButton.InternalOnCreateComponent
         Hint="Modify the maps that should be used in gameplay"
         WinTop=0.828648
         WinLeft=0.095426
         WinWidth=0.334961
         WinHeight=0.040000
         TabOrder=2
         OnChange=ROUT2K4Tab_MainSP.MaplistConfigClick
     End Object
     b_Maplist=moButton'ROInterface.ROUT2K4Tab_MainSP.MaplistButton'

     b_Tutorial=None

     ch_OfficialMapsOnly=None

     MaplistEditorMenu="ROInterface.ROMaplistEditor"
}
