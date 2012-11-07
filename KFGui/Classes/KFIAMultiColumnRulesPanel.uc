class KFIAMultiColumnRulesPanel extends IAMultiColumnRulesPanel;

var GUIController localController;

var automated GUISectionBackground sb_background;

delegate OnDifficultyChanged(int index, int tag);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    localController = MyController;

    Super.InitComponent(MyController, MyOwner);

    RemoveComponent(b_Symbols);

    //sb_background.ManageComponent(ch_Advanced);
    //ch_Advanced.Checked(true);
    sb_background.ManageComponent(lb_Rules);
    //ch_Advanced.SetVisibility(false);
}

function UpdateSymbolButton()
{
	b_Symbols=None;
}

function InternalOnChange(GUIComponent Sender)
{
    local moComboBox combo;

    if (GUIMultiOptionList(Sender) != None)
	{
		if (Controller.bCurMenuInitialized)
		{
		    combo = moComboBox(GUIMultiOptionList(Sender).Get());
		    if (combo != none)
		        OnDifficultyChanged(combo.getIndex(), combo.tag);
		}
    }

    Super.InternalOnChange(Sender);
}

function LoadRules()
{
    local int i;

    // Now settings in PlayInfo have been sorted by Group
    // We can now simply check if this setting's group is different from the last,
    // and if so, create a header for it.
    for (i = 0; i < InfoRules.Length; i++)
    {
        if ( InfoRules[i].DisplayName == "Monsters Config" )
        {
            continue;
        }

        if ( i == 0 || InfoRules[i].Grouping != InfoRules[i - 1].Grouping )
        {
            AddGroupHeader(i,li_Rules.Elements.Length == 0);
        }

        // Now add the setting to the GUIMultiOptionList
        AddRule(InfoRules[i], i);
    }
    super(UT2K4PlayInfoPanel).LoadRules();

    if ( GamePI != None )
    {
    	i = GamePI.FindIndex("BotMode");
    	if ( i != -1 )
    		UpdateBotSetting(i);
    }

	//UpdateAdvancedCheckbox();
	UpdateSymbolButton();
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainer Name=myBackgroundGroup
         bNoCaption=True
         WinHeight=1.000000
         OnPreDraw=myBackgroundGroup.InternalPreDraw
     End Object
     sb_Background=ROGUIProportionalContainer'KFGui.KFIAMultiColumnRulesPanel.myBackgroundGroup'

     i_bk=None

}
