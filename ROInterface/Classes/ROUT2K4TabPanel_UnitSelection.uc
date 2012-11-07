//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
class ROUT2K4TabPanel_UnitSelection extends UT2K4TabPanel;

const AUTO = 2;

var automated moCheckBox ch_Axis, ch_Allies, ch_Auto;
var automated GUIButton b_selectUnitButton;
var automated GUIScrollTextBox	sc_UnitDescription;
var automated GUISectionBackground i_UnitDescBG, i_UnitBG, i_CurrentUnitBG;
var automated GUILabel l_AxisName, l_AlliedName, l_AxisCount, l_AlliedCount;

var	localized	string		AutoInfoText;

var  ROGameReplicationInfo GRI;

var moCheckBox ch_currentSelection;

var	localized string Briefing[2];

//delgate called after valid team has been selected
delegate OnSelect(int teamIndex);
//------------------------------------------------------------------------------
//   Initialize components and set auto selection checkbox to default
//------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
     super.InitComponent(MyController,MyOwner);

     class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);
     loadBriefing();
     //default to auto and initilize current selection
     ch_Auto.Checked(True);
     updateAutoUnitInfoText();
     ch_currentSelection=ch_Auto;
     setCurrentUnitOption();

}
//------------------------------------------------------------------------------
// If player is already assigned to a side then set that checkbox.
// If side is current unassigned then set to auto.
//------------------------------------------------------------------------------
function setCurrentUnitOption()
{
   local ROPlayer lPlayer;
   local ROPlayerReplicationInfo lInfo;

   lPlayer = ROPlayer(PlayerOwner());

   if(lPlayer != none)
   {
	 if (GRI == None)
		GRI = ROGameReplicationInfo(lPlayer.GameReplicationInfo);

     lInfo = ROPlayerReplicationInfo( lPlayer.PlayerReplicationInfo );
     if(lInfo != none)
     {
        if(lInfo.Team != none)
        {
            switch(lInfo.Team.TeamIndex)
            {
               case 0 :  setAxisChecked();updateAxisUnitInfoText();  break;
               case 1 :  setAlliesChecked();updateAlliesUnitInfoText(); break;
               case 2 :  setAutoChecked();updateAutoUnitInfoText();  break;
            }
        }
     }
   }
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	//log("ROUT2K4TabPanel_UnitSelection::ShowPanel("$bShow$")");

	if (bShow)
	{
        loadBriefing();
		setCurrentUnitOption();
		SetTimer(0.1, true);
	}
	else
	{
		SetTimer(0.0, false);
	}
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Timer()
{
    local int teamIndex;

	if (GRI == None)
	{
		GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);
        loadBriefing();
		setCurrentUnitOption();
        switch(ch_currentSelection)
        {
            case ch_Axis   : PlayerOwner().ChangeTeam(AXIS_TEAM_INDEX); teamIndex = AXIS_TEAM_INDEX; break;
            case ch_Allies : PlayerOwner().ChangeTeam(ALLIES_TEAM_INDEX); teamIndex = ALLIES_TEAM_INDEX; break;
            case ch_Auto   :  teamIndex = autoSelectTeam(); break;
        }
    }
    UpdateTeamCounts();

//    if(isValidTeam())
//       OnSelect(teamIndex);
}
//------------------------------------------------------------------------------
// When a checkbox is selected then deselect the previously selected
// checkbox. This is no allow the checkboxes to behave like radio buttons
// where only one can be selected.
//	Don't we want unit selection to be radio buttons? - ant
//------------------------------------------------------------------------------
function InternalOnChange(GUIComponent Sender)
{
   local moCheckBox selected;
   //log("ROUT2K4TabPanel_UnitSelection::InternalOnChange");
   selected = moCheckBox(Sender);

   if(selected != none)
   {
      if(selected == ch_currentSelection)
      {
        // selected.MyCheckBox.bChecked = true;
         return;
      }
      if(selected.IsChecked())
      {
          switch(selected)
          {
             case ch_Axis   : setAxisChecked();updateAxisUnitInfoText(); break;
             case ch_Allies : setAlliesChecked();updateAlliesUnitInfoText(); break;
             case ch_Auto   : setAutoChecked(); updateAutoUnitInfoText(); break;
          }
      }
   }
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function bool InternalOnClick( GUIComponent Sender )
{
    local int teamIndex;
    switch(ch_currentSelection)
    {
         case ch_Axis   : PlayerOwner().ChangeTeam(AXIS_TEAM_INDEX); teamIndex = AXIS_TEAM_INDEX; break;
         case ch_Allies : PlayerOwner().ChangeTeam(ALLIES_TEAM_INDEX); teamIndex = ALLIES_TEAM_INDEX; break;
         case ch_Auto   :  teamIndex = autoSelectTeam(); break;
    }
    if(isValidTeam())
       OnSelect(teamIndex);

    return true;
}
//------------------------------------------------------------------------------
// @return true if player is on a valid team
//------------------------------------------------------------------------------
function bool isValidTeam()
{
   return (PlayerOwner().PlayerReplicationInfo != None &&
   PlayerOwner().PlayerReplicationInfo.Team != none
	&& PlayerOwner().PlayerReplicationInfo.Team.TeamIndex < NEUTRAL_TEAM_INDEX);
}
//------------------------------------------------------------------------------
// Very simple algo, simply add the player to the team with the
// least units.
//------------------------------------------------------------------------------
function int autoSelectTeam()
{
    local int axisCount, alliedCount;
    axisCount   = getTeamCount(AXIS_TEAM_INDEX);
    alliedCount = getTeamCount(ALLIES_TEAM_INDEX);
    if(axisCount < alliedCount)
    {
        PlayerOwner().ChangeTeam(AXIS_TEAM_INDEX);
        return AXIS_TEAM_INDEX;
    }
    else
    {
        PlayerOwner().ChangeTeam(ALLIES_TEAM_INDEX);
        return ALLIES_TEAM_INDEX;
    }
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function int getTeamCount(int index)
{
   local int i, count;
   if(GRI == none)
      return 0;
   // Find the number of players on each team
	for (i = 0; i < GRI.PRIArray.Length; i++)
	{
		if (ROPlayerReplicationInfo(GRI.PRIArray[i]) != None &&
            GRI.PRIArray[i].Team != None &&
            GRI.PRIArray[i].Team.TeamIndex == index)
			count++;
	}
	return count;

}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateAxisUnitInfoText()
{
   sc_UnitDescription.SetContent(GRI.UnitName[AXIS_TEAM_INDEX]$"||"$Briefing[AXIS_TEAM_INDEX]);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateAlliesUnitInfoText()
{
   sc_UnitDescription.SetContent(GRI.UnitName[ALLIES_TEAM_INDEX]$"||"$Briefing[ALLIES_TEAM_INDEX]);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateAutoUnitInfoText()
{
   sc_UnitDescription.SetContent(AutoInfoText);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function setAxisChecked()
{
     ch_currentSelection.Checked(false);
     ch_currentSelection = ch_Axis;
     ch_currentSelection.Checked(true);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function setAlliesChecked()
{
    ch_currentSelection.Checked(false);
    ch_currentSelection = ch_Allies;
    ch_currentSelection.Checked(true);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function setAutoChecked()
{
    ch_currentSelection.Checked(false);
    ch_currentSelection = ch_Auto;
    ch_currentSelection.Checked(true);
}
//-----------------------------------------------------------------------------
// UpdateTeamCounts - Updates the number of players on each team
//-----------------------------------------------------------------------------
function UpdateTeamCounts()
{
    l_AxisCount.Caption = ""$getTeamCount(AXIS_TEAM_INDEX);
    l_AlliedCount.Caption = ""$getTeamCount(ALLIES_TEAM_INDEX);
}
//------------------------------------------------------------------------------
function loadBriefing()
{
//    local int Loc,i;
    local int Loc;
    local string PackageName;
    local string MapName;


    if (PlayerOwner().Level.DecoTextName != "")
	{
		Loc = InStr(PlayerOwner().Level.DecoTextName, ".");

		if (Loc == -1)
		{
			PackageName = "ROMaps";
			MapName = PlayerOwner().Level.DecoTextName;
		}
		else
		{
			PackageName = Left(PlayerOwner().Level.DecoTextName, Loc);
			MapName = Mid(PlayerOwner().Level.DecoTextName, Loc + 1);
		}

		Briefing[ALLIES_TEAM_INDEX] = Controller.LoadDecoText(PackageName, MapName $ "Allies");
		Briefing[AXIS_TEAM_INDEX] = Controller.LoadDecoText(PackageName, MapName $ "Axis");
	}
	else
	{
		Briefing[ALLIES_TEAM_INDEX] = Controller.LoadDecoText("ROMaps", "Default");
		Briefing[AXIS_TEAM_INDEX] = Briefing[ALLIES_TEAM_INDEX];
	}
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=AxisCheckbox
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Join Axis"
         OnCreateComponent=AxisCheckbox.InternalOnCreateComponent
         Hint="Join the Axis forces."
         WinTop=0.500000
         WinLeft=0.054219
         WinWidth=0.540000
         TabOrder=0
         OnChange=ROUT2K4TabPanel_UnitSelection.InternalOnChange
     End Object
     ch_Axis=moCheckBox'ROInterface.ROUT2K4TabPanel_UnitSelection.AxisCheckbox'

     Begin Object Class=moCheckBox Name=AlliesCheckbox
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Join Allies"
         OnCreateComponent=AxisCheckbox.InternalOnCreateComponent
         Hint="Join the Allied forces."
         WinTop=0.550000
         WinLeft=0.054219
         WinWidth=0.540000
         TabOrder=1
         OnChange=ROUT2K4TabPanel_UnitSelection.InternalOnChange
     End Object
     ch_Allies=moCheckBox'ROInterface.ROUT2K4TabPanel_UnitSelection.AlliesCheckbox'

     Begin Object Class=moCheckBox Name=AutoCheckbox
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         Caption="Auto Selection"
         OnCreateComponent=AxisCheckbox.InternalOnCreateComponent
         Hint="Automatically select force."
         WinTop=0.600000
         WinLeft=0.054219
         WinWidth=0.540000
         TabOrder=2
         OnChange=ROUT2K4TabPanel_UnitSelection.InternalOnChange
     End Object
     ch_Auto=moCheckBox'ROInterface.ROUT2K4TabPanel_UnitSelection.AutoCheckbox'

     Begin Object Class=GUIButton Name=SelectButton
         Caption="Select"
         Hint="Select Force To Join."
         WinTop=0.900000
         WinLeft=0.796436
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=3
         OnClick=ROUT2K4TabPanel_UnitSelection.InternalOnClick
         OnKeyEvent=SelectButton.InternalOnKeyEvent
     End Object
     b_selectUnitButton=GUIButton'ROInterface.ROUT2K4TabPanel_UnitSelection.SelectButton'

     Begin Object Class=GUIScrollTextBox Name=UnitDescriptionScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=UnitDescriptionScroll.InternalOnCreateComponent
         WinTop=0.130000
         WinLeft=0.042190
         WinWidth=0.570000
         WinHeight=0.160000
         TabOrder=9
     End Object
     sc_UnitDescription=GUIScrollTextBox'ROInterface.ROUT2K4TabPanel_UnitSelection.UnitDescriptionScroll'

     Begin Object Class=AltSectionBackground Name=PlayerSetupBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.RODisplay'
         Caption="Unit Description"
         WinTop=0.055000
         WinLeft=0.024219
         WinWidth=0.600000
         WinHeight=0.300000
         OnPreDraw=PlayerSetupBG.InternalPreDraw
     End Object
     i_UnitDescBG=AltSectionBackground'ROInterface.ROUT2K4TabPanel_UnitSelection.PlayerSetupBG'

     Begin Object Class=AltSectionBackground Name=UnitSetupBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.RODisplay'
         Caption="Unit Selection"
         WinTop=0.400000
         WinLeft=0.024219
         WinWidth=0.600000
         WinHeight=0.330000
         OnPreDraw=PlayerSetupBG.InternalPreDraw
     End Object
     i_UnitBG=AltSectionBackground'ROInterface.ROUT2K4TabPanel_UnitSelection.UnitSetupBG'

     Begin Object Class=AltSectionBackground Name=CurrentUnitSetupBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.RODisplay'
         Caption="Current Units"
         WinTop=0.055000
         WinLeft=0.644219
         WinWidth=0.300000
         WinHeight=0.300000
         OnPreDraw=PlayerSetupBG.InternalPreDraw
     End Object
     i_CurrentUnitBG=AltSectionBackground'ROInterface.ROUT2K4TabPanel_UnitSelection.CurrentUnitSetupBG'

     Begin Object Class=GUILabel Name=AxisName
         Caption="Axis"
         StyleName="ROTextLabel"
         WinTop=0.140000
         WinLeft=0.684219
         WinWidth=0.854492
         WinHeight=0.050000
     End Object
     l_AxisName=GUILabel'ROInterface.ROUT2K4TabPanel_UnitSelection.AxisName'

     Begin Object Class=GUILabel Name=AlliedName
         Caption="Allies"
         StyleName="ROTextLabel"
         WinTop=0.200000
         WinLeft=0.684219
         WinWidth=0.854492
         WinHeight=0.050000
     End Object
     l_AlliedName=GUILabel'ROInterface.ROUT2K4TabPanel_UnitSelection.AlliedName'

     Begin Object Class=GUILabel Name=axisCount
         Caption="10"
         TextAlign=TXTA_Center
         StyleName="ROTextLabel"
         WinTop=0.140000
         WinLeft=0.462190
         WinWidth=0.854492
         WinHeight=0.050000
     End Object
     l_AxisCount=GUILabel'ROInterface.ROUT2K4TabPanel_UnitSelection.axisCount'

     Begin Object Class=GUILabel Name=alliedCount
         Caption="10"
         TextAlign=TXTA_Center
         StyleName="ROTextLabel"
         WinTop=0.200000
         WinLeft=0.462190
         WinWidth=0.854492
         WinHeight=0.050000
     End Object
     l_AlliedCount=GUILabel'ROInterface.ROUT2K4TabPanel_UnitSelection.alliedCount'

     AutoInfoText="* Selecting this option will automatically join the unit that needs you most."
     Briefing(0)="Axis briefing"
     Briefing(1)="Allied briefing"
     PanelCaption="Unit"
}
