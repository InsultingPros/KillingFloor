//=============================================================================
// ROGUITeamSelection
//=============================================================================
// The Team Selection menu.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROGUITeamSelection extends UT2K4GUIPage;

// Controls
var automated GUILabel                      l_TeamCount[2];
var automated GUIScrollTextBox              l_TeamBriefing[2];

var automated GUIButton                     b_TeamSelect[2];
var automated GUIButton                     b_Spectate, b_AutoSelect;

var automated BackgroundImage               bg_Background;


// Variables
var             ROGameReplicationInfo       GRI;
var	localized   string                      Briefing[2];
var localized   string                      TeamJoinText[2];
var localized   string                      TeamJoinHint[2];
var localized   string                      UnitsText;
var             int                         selectedTeam;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);

    //class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);
    loadBriefing();

    // Set initial values
    l_TeamBriefing[0].SetContent(GRI.UnitName[AXIS_TEAM_INDEX]$"||"$Briefing[AXIS_TEAM_INDEX]);
    l_TeamBriefing[1].SetContent(GRI.UnitName[ALLIES_TEAM_INDEX]$"||"$Briefing[ALLIES_TEAM_INDEX]);

    for (i = 0; i < 2; i++)
    {
        b_TeamSelect[i].Caption = TeamJoinText[i];
        b_TeamSelect[i].SetHint(TeamJoinHint[i]);
    }

    Timer();
	SetTimer(0.1, true);
}

/*function loadBriefing()
{
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
}*/

function loadBriefing()
{
    local ROLevelInfo levelinfo;

    // Find levelinfO
   	foreach PlayerOwner().AllActors(class'ROLevelInfo', levelinfo)
	    break;

	if (levelinfo != none)
	{
	    Briefing[ALLIES_TEAM_INDEX] = levelinfo.AlliesUnitDescription;
        Briefing[AXIS_TEAM_INDEX] = levelinfo.AxisUnitDescription;
	}
}

// Used to update team counts
function Timer()
{
    UpdateTeamCounts();
}

function UpdateTeamCounts()
{
    l_TeamCount[AXIS_TEAM_INDEX].Caption = ""$getTeamCount(AXIS_TEAM_INDEX) $ UnitsText;
    l_TeamCount[ALLIES_TEAM_INDEX].Caption = ""$getTeamCount(ALLIES_TEAM_INDEX) $ UnitsText;
}

function int getTeamCount(int index)
{
    return getTeamCountStatic(GRI, PlayerOwner(), index);
}

function SetButtonsState(bool bDisabled)
{
    if (bDisabled)
    {
        b_AutoSelect.MenuStateChange(MSAT_Disabled);
        b_Spectate.MenuStateChange(MSAT_Disabled);
        b_TeamSelect[0].MenuStateChange(MSAT_Disabled);
        b_TeamSelect[1].MenuStateChange(MSAT_Disabled);
    }
    else
    {
        b_AutoSelect.MenuStateChange(MSAT_Blurry);
        b_Spectate.MenuStateChange(MSAT_Blurry);
        b_TeamSelect[0].MenuStateChange(MSAT_Blurry);
        b_TeamSelect[1].MenuStateChange(MSAT_Blurry);
    }
}

function static int getTeamCountStatic(ROGameReplicationInfo GRI, PlayerController controller, int index)
{
    local int i, count;

    if (GRI == none)
        return 0;

    // Find the number of players on each team
    for (i = 0; i < GRI.PRIArray.Length; i++)
    {
		if (ROPlayerReplicationInfo(GRI.PRIArray[i]) != None &&
				ROPlayerReplicationInfo(GRI.PRIArray[i]).RoleInfo != none &&
                GRI.PRIArray[i].Team != none &&
                GRI.PRIArray[i].Team.TeamIndex == index)
        {
            //if (controller != none && GRI.PRIArray[i] != controller.PlayerReplicationInfo) // Don't count self
                //if (!GRI.PRIArray[i].bBot) // Don't count bots
                    count++;
        }
    }

    return count;
}

function InternalOnClose(optional bool bCancelled)
{
    if (!bCancelled)
        SetTimer(0.0, false);
}

function bool InternalOnClick( GUIComponent Sender )
{
//    local int team1, team2;

    switch (Sender)
    {
        case b_AutoSelect:
            /*team1 = getTeamCount(AXIS_TEAM_INDEX);
            team2 = getTeamCount(ALLIES_TEAM_INDEX);
            if (team1 < team2)
                SelectTeam(AXIS_TEAM_INDEX);
            else if (team1 > team2)
                SelectTeam(ALLIES_TEAM_INDEX);
            else
                SelectTeam(Rand(2));*/
            SelectTeam(-2);
            break;

        case b_Spectate:
            SelectTeam(-1);
            break;

        case b_TeamSelect[AXIS_TEAM_INDEX]:
            SelectTeam(AXIS_TEAM_INDEX);
            break;

        case b_TeamSelect[ALLIES_TEAM_INDEX]:
            SelectTeam(ALLIES_TEAM_INDEX);
            break;
    }
    return true;
}

/*
 team = 0 -- select axis
 team = 1 -- select allies
 team = -1 -- select spectator
 team = -2 -- auto select
*/
function SelectTeam(int team)
{
    selectedTeam = team;
    /*if (team != -1)
    {
        if (PlayerOwner().PlayerReplicationInfo != none &&
            PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
        {
            PlayerOwner().BecomeActivePlayer();
        }
        PlayerOwner().ChangeTeam(team);
        //Controller.OpenMenu("ROInterface.ROGUIRoleSelection");
    }
    else
        PlayerOwner().BecomeSpectator();
    */

    if (ROPlayer(PlayerOwner()) == none)
    {
        warn("Unable to cast PlayerOwner() to ROPlayer! Unable to change teams.");
        return;
    }

    SetButtonsState(true);

    if (team == -1)
        ROPlayer(PlayerOwner()).ServerChangePlayerInfo(254, 255, 0, 0);
    else if (team == -2)
        ROPlayer(PlayerOwner()).ServerChangePlayerInfo(250, 255, 0, 0);
    else
        ROPlayer(PlayerOwner()).ServerChangePlayerInfo(team, 255, 0, 0);
}

function SelectTeamSuccessfull()
{
    if (selectedTeam != -1)
    {
        // hax! player team hasn't been replicated by the time this has been
        // called -- so we force the role select menu to show a specific team
        if (ROPlayer(PlayerOwner()) != none)
            ROPlayer(PlayerOwner()).ForcedTeamSelectOnRoleSelectPage = selectedTeam;

        Controller.OpenMenu("ROInterface.ROGUIRoleSelection");
    }
    else
        class'ROGUIRoleSelection'.static.CheckNeedForFadeFromBlackEffect(PlayerOwner());

    Controller.RemoveMenu(self);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (key == 0x1B)
    {
        Controller.CloseMenu();
        return true;
    }

    return false;
}

function InternalOnMessage(coerce string Msg, float MsgLife)
{
    local int result;
    local string error_msg;

    if (msg == "notify_gui_role_selection_page")
    {
        // Received success/failure message from server.

        result = int(MsgLife);

        switch (result)
        {
            case 0: // Team change successfull!
                SelectTeamSuccessfull();
                return;

            case 97: // Succesfully picked axis team
                selectedTeam = AXIS_TEAM_INDEX;
                SelectTeamSuccessfull();
                return;

            case 98: // Successfully picked allies team
                selectedTeam = ALLIES_TEAM_INDEX;
                SelectTeamSuccessfull();
                return;

            default: // Couldn't change teams: get error msg
                error_msg = class'ROGUIRoleSelection'.static.getErrorMessageForId(result);
        }

        SetButtonsState(false);

        if (Controller != none)
        {
            Controller.OpenMenu(Controller.QuestionMenuClass);
            GUIQuestionPage(Controller.TopPage()).SetupQuestion(error_msg, QBTN_Ok, QBTN_Ok);
        }
    }
}

defaultproperties
{
     Begin Object Class=GUILabel Name=TeamsCount
         Caption="? units"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.415000
         WinLeft=0.096250
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     l_TeamCount(0)=GUILabel'ROInterface.ROGUITeamSelection.TeamsCount'

     Begin Object Class=GUILabel Name=TeamsCount2
         Caption="? units"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.871667
         WinLeft=0.096250
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     l_TeamCount(1)=GUILabel'ROInterface.ROGUITeamSelection.TeamsCount2'

     Begin Object Class=GUIScrollTextBox Name=TeamsBriefing
         bNoTeletype=True
         OnCreateComponent=TeamsBriefing.InternalOnCreateComponent
         StyleName="TextLabel"
         WinTop=0.078333
         WinLeft=0.503750
         WinWidth=0.446250
         WinHeight=0.342498
     End Object
     l_TeamBriefing(0)=GUIScrollTextBox'ROInterface.ROGUITeamSelection.TeamsBriefing'

     Begin Object Class=GUIScrollTextBox Name=TeamsBriefing2
         bNoTeletype=True
         OnCreateComponent=TeamsBriefing2.InternalOnCreateComponent
         StyleName="TextLabel"
         WinTop=0.530000
         WinLeft=0.503750
         WinWidth=0.446250
         WinHeight=0.342498
     End Object
     l_TeamBriefing(1)=GUIScrollTextBox'ROInterface.ROGUITeamSelection.TeamsBriefing2'

     Begin Object Class=GUIButton Name=JoinTeamButton
         StyleName="SelectButton"
         WinTop=0.370000
         WinLeft=0.118750
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=1
         OnClick=ROGUITeamSelection.InternalOnClick
         OnKeyEvent=ROGUITeamSelection.InternalOnKeyEvent
     End Object
     b_TeamSelect(0)=GUIButton'ROInterface.ROGUITeamSelection.JoinTeamButton'

     Begin Object Class=GUIButton Name=JoinTeamButton2
         StyleName="SelectButton"
         WinTop=0.823333
         WinLeft=0.118750
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=2
         OnClick=ROGUITeamSelection.InternalOnClick
         OnKeyEvent=ROGUITeamSelection.InternalOnKeyEvent
     End Object
     b_TeamSelect(1)=GUIButton'ROInterface.ROGUITeamSelection.JoinTeamButton2'

     Begin Object Class=GUIButton Name=Spectate
         Caption="Spectate"
         StyleName="SelectTab"
         Hint="Join the game as a spectator"
         WinTop=0.920000
         WinLeft=0.550000
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=4
         OnClick=ROGUITeamSelection.InternalOnClick
         OnKeyEvent=ROGUITeamSelection.InternalOnKeyEvent
     End Object
     b_Spectate=GUIButton'ROInterface.ROGUITeamSelection.Spectate'

     Begin Object Class=GUIButton Name=AutoSelect
         Caption="Auto-select"
         StyleName="SelectTab"
         Hint="Join the team with the fewest players"
         WinTop=0.920000
         WinLeft=0.250000
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=3
         OnClick=ROGUITeamSelection.InternalOnClick
         OnKeyEvent=ROGUITeamSelection.InternalOnKeyEvent
     End Object
     b_AutoSelect=GUIButton'ROInterface.ROGUITeamSelection.AutoSelect'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'InterfaceArt_tex.SelectMenus.Teamselect'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1023
         Y2=1023
     End Object
     bg_Background=BackgroundImage'ROInterface.ROGUITeamSelection.PageBackground'

     Briefing(0)="Axis briefing"
     Briefing(1)="Allied briefing"
     TeamJoinText(0)="JOIN AXIS"
     TeamJoinText(1)="JOIN ALLIES"
     TeamJoinHint(0)="Join Axis forces"
     TeamJoinHint(1)="Join Allies forces"
     UnitsText=" units"
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=ROGUITeamSelection.InternalOnClose
     OnMessage=ROGUITeamSelection.InternalOnMessage
     OnKeyEvent=ROGUITeamSelection.InternalOnKeyEvent
}
