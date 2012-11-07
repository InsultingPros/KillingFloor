class KFTab_MidGameHelp extends UT2K4Tab_MidGameHelp;

//copied stuff
var automated   GUIButton               b_Team, b_Settings, b_Browser, b_Quit, b_Favs,
                                        b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec;

var() noexport  bool                    bTeamGame, bFFAGame, bNetGame;

var localized   string                  LeaveMPButtonText, LeaveSPButtonText, SpectateButtonText, JoinGameButtonText;
var localized   array<string>           ContextItems, DefaultItems;
var localized   string                  KickPlayer, BanPlayer;

var localized   string                  BuddyText;
var localized   string                  RedTeam, BlueTeam;
var             string                  PlayerStyleName;
var             GUIStyles               PlayerStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string s;
    local int i;
    local eFontScale FS;

	Super.InitComponent(MyController, MyOwner);

	s = GetSizingCaption();

	for ( i = 0; i < Controls.Length; i++ )
    {
    	if ( GUIButton(Controls[i]) != None && Controls[i] != b_Team /*&& Controls[i] != PrevHintButton && Controls[i] != NextHintButton*/ )
        {
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).SizingCaption = s;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
        }
    }

    PlayerStyle = MyController.GetStyle(PlayerStyleName, fs);

	sb_GameDesc.ManageComponent(GameDescriptionBox);
	sb_Hints.ManageComponent(HintsBox);

	PrevHintButton.bBoundToParent=false;  PrevHintButton.bScaleToParent=false;
	NextHintButton.bBoundToParent=false;  NextHintButton.bScaleToParent=false;
	HintCountLabel.bBoundToParent=false;  HintCountLabel.bScaleToParent=false;
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if ( bShow )
	{
		InitGRI();

		if ( !bReceivedGameClass )
		{
			SetTimer(1.0, true);
			Timer();
		}
	}
}

function string GetSizingCaption()
{
    local int i;
    local string s;

    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != none && Controls[i] != b_Team && Controls[i] != PrevHintButton && Controls[i] != NextHintButton)
        {
			if ( s == "" || Len(GUIButton(Controls[i]).Caption) > Len(s) )
            {
                s = GUIButton(Controls[i]).Caption;
            }
        }
    }

    return s;
}

function GameReplicationInfo GetGRI()
{
    return PlayerOwner().GameReplicationInfo;
}

function InitGRI()
{
    local PlayerController PC;
    local GameReplicationInfo GRI;

    GRI = GetGRI();
    PC = PlayerOwner();

    if ( PC == none || PC.PlayerReplicationInfo == none || GRI == none )
    {
        return;
    }

    bInit = False;

    if ( !bTeamGame && !bFFAGame )
    {
        if ( GRI.bTeamGame )
        {
            bTeamGame = True;
        }
        else if ( !(GRI.GameClass ~= "Engine.GameInfo") )
        {
            bFFAGame = True;
        }
    }

    bNetGame = PC.Level.NetMode != NM_StandAlone;

    if ( bNetGame )
    {
        b_Leave.Caption = LeaveMPButtonText;
    }
    else
    {
        b_Leave.Caption = LeaveSPButtonText;
    }

    if ( PC.PlayerReplicationInfo.bOnlySpectator )
    {
        b_Spec.Caption = JoinGameButtonText;
    }
    else
    {
        b_Spec.Caption = SpectateButtonText;
    }

    SetupGroups();
	//InitLists();
}

function float ItemHeight(Canvas C)
{
    local float XL, YL, H;
    local eFontScale f;

    if ( bTeamGame )
    {
        f=FNS_Medium;
    }
    else
    {
        f=FNS_Large;
    }

    PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);

    if ( C.ClipX > 640 && bNetGame )
    {
        PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, YL, FNS_Small);
    }

    H += YL;
    H += (H * 0.2);

    return h;
}

function SetupGroups()
{
    local int i;
    local PlayerController PC;

    PC = PlayerOwner();

    if ( bTeamGame )
    {
        //RemoveComponent(lb_FFA, True);
        //RemoveComponent(sb_FFA, true);

        if ( PC.GameReplicationInfo != None && PC.GameReplicationInfo.bNoTeamChanges )
        {
            RemoveComponent(b_Team,true);
        }

        //lb_FFA = None;
    }
    else if ( bFFAGame )
    {
        //RemoveComponent(i_JoinRed, true);
        //RemoveComponent(lb_Red, true);
        //RemoveComponent(sb_Red, true);
        RemoveComponent(b_Team, true);
    }
    else
    {
        for ( i = 0; i < Controls.Length; i++ )
        {
            if ( Controls[i] == b_Team ||
			 	 Controls[i] == b_Settings ||
				 Controls[i] == b_Browser ||
				 Controls[i] == b_Quit ||
				 Controls[i] == b_Favs ||
				 Controls[i] == b_Leave ||
				 Controls[i] == b_MapVote ||
				 Controls[i] == b_KickVote ||
				 Controls[i] == b_MatchSetup ||
				 Controls[i] == b_Spec )
			{
				RemoveComponent(Controls[i], True);
			}
        }
    }

    if ( PC.Level.NetMode != NM_Client )
    {
        RemoveComponent(b_Favs);
        RemoveComponent(b_Browser);
    }
    else if ( CurrentServerIsInFavorites() )
    {
        DisableComponent(b_Favs);
    }

    if ( PC.Level.NetMode == NM_StandAlone )
    {
        RemoveComponent(b_MapVote, True);
        RemoveComponent(b_MatchSetup, True);
        RemoveComponent(b_KickVote, True);
    }
    else if ( PC.VoteReplicationInfo != None )
    {
        if ( !PC.VoteReplicationInfo.MapVoteEnabled() )
        {
            RemoveComponent(b_MapVote,True);
        }

        if ( !PC.VoteReplicationInfo.KickVoteEnabled() )
        {
            RemoveComponent(b_KickVote);
        }

        if ( !PC.VoteReplicationInfo.MatchSetupEnabled() )
        {
            RemoveComponent(b_MatchSetup);
        }
    }
    else
    {
        RemoveComponent(b_MapVote);
        RemoveComponent(b_KickVote);
        RemoveComponent(b_MatchSetup);
    }

    RemapComponents();
}

function SetButtonPositions(Canvas C)
{
    local int i, j, ButtonsPerRow, ButtonsLeftInRow, NumButtons;
    local float Width, Height, Center, X, Y, YL, ButtonSpacing;

    Width = b_Settings.ActualWidth();
    Height = b_Settings.ActualHeight();
    Center = ActualLeft() + (ActualWidth() / 2.0);

    ButtonSpacing = Width * 0.05;
    YL = Height * 1.2;
    Y = b_Settings.ActualTop();

    ButtonsPerRow = ActualWidth() / (Width + ButtonSpacing);
    ButtonsLeftInRow = ButtonsPerRow;

    for ( i = 0; i < Components.Length; i++)
	{
		if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team && Components[i] != PrevHintButton && Components[i] != NextHintButton )
	    {
			NumButtons++;
	    }
    }

    if ( NumButtons < ButtonsPerRow )
    {
    	X = Center - (((Width * float(NumButtons)) + (ButtonSpacing * float(NumButtons - 1))) * 0.5);
    }
    else if ( ButtonsPerRow > 1 )
    {
        X = Center - (((Width * float(ButtonsPerRow)) + (ButtonSpacing * float(ButtonsPerRow - 1))) * 0.5);
    }
    else
    {
        X = Center - Width / 2.0;
    }

    for ( i = 0; i < Components.Length; i++)
	{
		if ( !Components[i].bVisible || GUIButton(Components[i]) == none || Components[i]==b_Team || Components[i] == PrevHintButton || Components[i] == NextHintButton )
        {
            continue;
        }

        Components[i].SetPosition( X, Y, Width, Height, true );

        if ( --ButtonsLeftInRow > 0 )
        {
            X += Width + ButtonSpacing;
        }
        else
        {
            Y += YL;

            for ( j = i + 1; j < Components.Length && ButtonsLeftInRow < ButtonsPerRow; j++)
            {
                if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team && Controls[i] != PrevHintButton && Controls[i] != NextHintButton )
                {
                    ButtonsLeftInRow++;
                }
            }

            if ( ButtonsLeftInRow > 1 )
            {
                X = Center - (((Width * float(ButtonsLeftInRow)) + (ButtonSpacing * float(ButtonsLeftInRow - 1))) * 0.5);
            }
            else
            {
                X = Center - Width / 2.0;
            }
        }
    }
}

// See if we already have this server in our favorites
function bool CurrentServerIsInFavorites()
{
    local ExtendedConsole.ServerFavorite Fav;
    local string address,portString;

    // Get current network address
    if ( PlayerOwner() == None )
    {
        return true;
    }

    address = PlayerOwner().GetServerNetworkAddress();

    if( address == "" )
    {
        return true; // slightly hacky - dont want to add "none"!
    }

    // Parse text to find IP and possibly port number
    if ( Divide(address, ":", Fav.IP, portstring) )
    {
        Fav.Port = int(portString);
    }
    else
    {
        Fav.IP = address;
    }

    return class'ExtendedConsole'.static.InFavorites(Fav);
}

function bool ButtonClicked(GUIComponent Sender)
{
    local PlayerController PC;
    local GUIController C;

    C = Controller;

    PC = PlayerOwner();

    /*if ( Sender == i_JoinRed )
    {
        //Join Red team
        if ( PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == none ||
             PC.PlayerReplicationInfo.Team.TeamIndex != 0 )
        {
            PC.ChangeTeam(0);
        }

        Controller.CloseMenu(false);
    }
    */
	if ( Sender == b_Settings )
    {
        //Settings
        Controller.OpenMenu(Controller.GetSettingsPage());
    }
    else if ( Sender == b_Browser )
    {
        //Server browser
        Controller.OpenMenu("KFGUI.KFServerBrowser");
    }
    else if ( Sender == b_Leave )
    {
		//Forfeit/Disconnect
		PC.ConsoleCommand("DISCONNECT");
        KFGUIController(C).ReturnToMainMenu();
    }
    else if ( Sender == b_Favs )
    {
        //Add this server to favorites
        PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
        b_Favs.MenuStateChange(MSAT_Disabled);
    }
    else if ( Sender == b_Quit )
    {
        //Quit game
        Controller.OpenMenu(Controller.GetQuitPage());
    }
    else if ( Sender == b_MapVote )
    {
        //Map voting
        Controller.OpenMenu(Controller.MapVotingMenu);
    }
    else if ( Sender == b_KickVote )
    {
        //Kick voting
        Controller.OpenMenu(Controller.KickVotingMenu);
    }
    else if ( Sender == b_MatchSetup )
    {
        //Match setup
        Controller.OpenMenu(Controller.MatchSetupMenu);
    }
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();

		//Spectate/rejoin
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
		{
			PC.BecomeActivePlayer();
		}
		else
        {
            PC.BecomeSpectator();
        }
	}
	else if (Sender == PrevHintButton)
	{
		CurrentHintIndex--;
		if (CurrentHintIndex < 0)
			CurrentHintIndex = AllGameHints.length - 1;
	}
	else if (Sender == NextHintButton)
	{
		CurrentHintIndex++;
		if (CurrentHintIndex >= AllGameHints.length)
			CurrentHintIndex = 0;
	}

	HintsBox.SetContent(AllGameHints[CurrentHintIndex]);
	HintCountLabel.Caption = string(CurrentHintIndex + 1) @ "/" @ string(AllGameHints.length);

	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;

	GRI = GetGRI();

    if ( GRI != none )
	{
		if ( bInit )
		{
			InitGRI();
		}

		/*
		if ( bTeamGame )
		{
			if ( PlayerOwner().PlayerReplicationInfo.Team != none )
			{
				sb_Red.HeaderBase = texture'InterfaceArt_tex.Menu.RODisplay';
			}
		}

	    sb_Red.SetPosition((ActualWidth() / 2.0) - ((sb_Red.WinWidth * ActualWidth()) / 2.0), sb_Red.WinTop, sb_Red.WinWidth, sb_Red.WinHeight);
		*/

		SetButtonPositions(C);
		//UpdatePlayerLists();

		if ( (PlayerOwner().myHUD == None || !PlayerOwner().myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded') )
		{
        	EnableComponent(b_Spec);
        }
		else
        {
            DisableComponent(b_Spec);
        }
	}

	return false;
}

function bool ContextMenuOpened(GUIContextMenu Menu)
{
    local GUIList List;
    local PlayerReplicationInfo PRI;
    local byte Restriction;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return false;
    }

    List = GUIList(Controller.ActiveControl);

    if ( List == None )
    {
        log(Name @ "ContextMenuOpened active control was not a list - active:" $ Controller.ActiveControl.Name);
        return False;
    }

    if ( !List.IsValid() )
    {
        return False;
    }

    PRI = GRI.FindPlayerByID(int(List.GetExtra()));

    if ( PRI == None || PRI.bBot || PlayerIDIsMine(PRI.PlayerID) )
    {
        return False;
    }

    Restriction = PlayerOwner().ChatManager.GetPlayerRestriction(PRI.PlayerID);

    if ( bool(Restriction & 1) )
    {
        Menu.ContextItems[0] = ContextItems[0];
    }
    else
    {
        Menu.ContextItems[0] = DefaultItems[0];
    }

    if ( bool(Restriction & 2) )
    {
        Menu.ContextItems[1] = ContextItems[1];
    }
    else
    {
        Menu.ContextItems[1] = DefaultItems[1];
    }

    if ( bool(Restriction & 4) )
    {
        Menu.ContextItems[2] = ContextItems[2];
    }
    else
    {
        Menu.ContextItems[2] = DefaultItems[2];
    }

    if ( bool(Restriction & 8) )
    {
        Menu.ContextItems[3] = ContextItems[3];
    }
    else
    {
        Menu.ContextItems[3] = DefaultItems[3];
    }

    Menu.ContextItems[4] = "-";
    Menu.ContextItems[5] = BuddyText;

    if ( PlayerOwner().PlayerReplicationInfo.bAdmin )
    {
        Menu.ContextItems[6] = "-";
        Menu.ContextItems[7] = KickPlayer $ "["$List.Get() $ "]";
        Menu.ContextItems[8] = BanPlayer $ "["$List.Get() $ "]";
    }
    else if ( Menu.ContextItems.Length > 6 )
    {
        Menu.ContextItems.Remove(6,Menu.ContextItems.Length - 6);
    }

    return True;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
    local bool bUndo;
    local byte Type;
    local GUIList List;
    local PlayerController PC;
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    PC = PlayerOwner();
    bUndo = Menu.ContextItems[ClickIndex] == ContextItems[ClickIndex];
    List = GUIList(Controller.ActiveControl);

    if ( List == None )
    {
        return;
    }

    PRI = GRI.FindPlayerById(int(List.GetExtra()));

    if ( PRI == None )
    {
        return;
    }

    if ( ClickIndex > 5 ) // Admin stuff
    {
        switch ( ClickIndex )
        {
            case 6:
            case 7: PC.AdminCommand("admin kick"@List.GetExtra()); break;
            case 8: PC.AdminCommand("admin kickban"@List.GetExtra()); break;
        }

        return;
    }

    if ( ClickIndex > 3 )
    {
        Controller.AddBuddy(List.Get());

        return;
    }

    Type = 1 << ClickIndex;

    if ( bUndo )
    {
        if ( PC.ChatManager.ClearRestrictionID(PRI.PlayerID, Type) )
        {
            PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
            ModifiedChatRestriction(Self, PRI.PlayerID);
        }
    }
    else
    {
        if ( PC.ChatManager.AddRestrictionID(PRI.PlayerID, Type) )
        {
            PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
            ModifiedChatRestriction(Self, PRI.PlayerID);
        }
    }
}

function Timer()
{
	local PlayerController PC;
	local int i;

	PC = PlayerOwner();
	if (PC != None && PC.GameReplicationInfo != None && PC.GameReplicationInfo.GameClass != "")
	{
		GameClass = class<GameInfo>(DynamicLoadObject(PC.GameReplicationInfo.GameClass, class'Class'));
		if (GameClass != None)
		{
			//get game description and hints from game class
			GameDescriptionBox.SetContent(GameClass.default.Description);
			AllGameHints = GameClass.static.GetAllLoadHints();
			if (AllGameHints.length > 0)
			{
				for (i = 0; i < AllGameHints.length; i++)
				{
					AllGameHints[i] = GameClass.static.ParseLoadingHint(AllGameHints[i], PC, HintsBox.Style.FontColors[HintsBox.MenuState]);
					if (AllGameHints[i] == "")
					{
						AllGameHints.Remove(i, 1);
						i--;
					}
				}
				HintsBox.SetContent(AllGameHints[CurrentHintIndex]);
				HintCountLabel.Caption = string(CurrentHintIndex + 1) @ "/" @ string(AllGameHints.length);
				EnableComponent(PrevHintButton);
				EnableComponent(NextHintButton);
			}

			KillTimer();
			bReceivedGameClass = true;
		}
	}
}
/*
function bool ButtonClicked(GUIComponent Sender)
{
	if (Sender == PrevHintButton)
	{
		CurrentHintIndex--;
		if (CurrentHintIndex < 0)
			CurrentHintIndex = AllGameHints.length - 1;
	}
	else if (Sender == NextHintButton)
	{
		CurrentHintIndex++;
		if (CurrentHintIndex >= AllGameHints.length)
			CurrentHintIndex = 0;
	}

	HintsBox.SetContent(AllGameHints[CurrentHintIndex]);
	HintCountLabel.Caption = string(CurrentHintIndex + 1) @ "/" @ string(AllGameHints.length);

	return true;
}
*/
function bool FixUp(Canvas C)
{
	local float t,h,l,w,xl;

	h = 18;
	t = sb_Hints.ActualTop() + sb_Hints.ActualHeight() -  50;

	PrevHintButton.WinLeft = sb_Hints.ActualLeft() + 40;
	PrevHintButton.WinTop = t;
	PrevHintButton.WinHeight=h;

	NextHintButton.WinLeft = sb_Hints.ActualLeft() + sb_Hints.ActualWidth() - 40 - NextHintButton.ActualWidth();
	NextHintButton.WinTop = t;
	NextHintButton.WinHeight=h;

	l = PrevHintButton.ActualLeft() + PrevHintButton.ActualWidth();
	w = NextHintButton.ActualLeft() - L;

	XL = HintCountLabel.ActualWidth();
	l = l + (w/2) - (xl/2);
	HintCountLabel.WinLeft=l;
	HintCountLabel.WinTop=t;
	HintCountLabel.WinWidth = xl;
	HintCountLabel.WinHeight=h;

	InternalOnPreDraw(C);

	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=SettingsButton
         Caption="Settings"
         WinTop=0.878657
         WinLeft=0.194420
         WinWidth=0.147268
         WinHeight=0.048769
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'KFGui.KFTab_MidGameHelp.SettingsButton'

     Begin Object Class=GUIButton Name=BrowserButton
         Caption="Server Browser"
         bAutoSize=True
         WinTop=0.850000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=BrowserButton.InternalOnKeyEvent
     End Object
     b_Browser=GUIButton'KFGui.KFTab_MidGameHelp.BrowserButton'

     Begin Object Class=GUIButton Name=QuitGameButton
         Caption="Exit Game"
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=11
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=QuitGameButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'KFGui.KFTab_MidGameHelp.QuitGameButton'

     Begin Object Class=GUIButton Name=FavoritesButton
         Caption="Add to Favs"
         bAutoSize=True
         Hint="Add this server to your Favorites"
         WinTop=0.870000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=FavoritesButton.InternalOnKeyEvent
     End Object
     b_Favs=GUIButton'KFGui.KFTab_MidGameHelp.FavoritesButton'

     Begin Object Class=GUIButton Name=LeaveMatchButton
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=10
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=LeaveMatchButton.InternalOnKeyEvent
     End Object
     b_Leave=GUIButton'KFGui.KFTab_MidGameHelp.LeaveMatchButton'

     Begin Object Class=GUIButton Name=MapVotingButton
         Caption="Map Voting"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=5
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=MapVotingButton.InternalOnKeyEvent
     End Object
     b_MapVote=GUIButton'KFGui.KFTab_MidGameHelp.MapVotingButton'

     Begin Object Class=GUIButton Name=KickVotingButton
         Caption="Kick Voting"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=6
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=KickVotingButton.InternalOnKeyEvent
     End Object
     b_KickVote=GUIButton'KFGui.KFTab_MidGameHelp.KickVotingButton'

     Begin Object Class=GUIButton Name=MatchSetupButton
         Caption="Match Setup"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=7
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=MatchSetupButton.InternalOnKeyEvent
     End Object
     b_MatchSetup=GUIButton'KFGui.KFTab_MidGameHelp.MatchSetupButton'

     Begin Object Class=GUIButton Name=SpectateButton
         Caption="Spectate"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=9
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=SpectateButton.InternalOnKeyEvent
     End Object
     b_Spec=GUIButton'KFGui.KFTab_MidGameHelp.SpectateButton'

     LeaveMPButtonText="Disconnect"
     LeaveSPButtonText="Forfeit"
     SpectateButtonText="Spectate"
     JoinGameButtonText="Join"
     ContextItems(0)="Unignore text"
     ContextItems(1)="Unignore speech"
     ContextItems(2)="Unignore voice chat"
     ContextItems(3)="Unban from voice chat"
     DefaultItems(0)="Ignore text"
     DefaultItems(1)="Ignore speech"
     DefaultItems(2)="Ignore voice chat"
     DefaultItems(3)="Ban from voice chat"
     KickPlayer="Kick "
     BanPlayer="Ban "
     PlayerStyleName="TextLabel"
     Begin Object Class=AltSectionBackground Name=sbGameDesc
         bFillClient=True
         Caption="Game Description"
         WinTop=0.020438
         WinLeft=0.023625
         WinWidth=0.944875
         WinHeight=0.455783
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbGameDesc.InternalPreDraw
     End Object
     sb_GameDesc=AltSectionBackground'KFGui.KFTab_MidGameHelp.sbGameDesc'

     Begin Object Class=AltSectionBackground Name=sbHints
         bFillClient=True
         Caption="Helpful Hints"
         WinTop=0.482921
         WinLeft=0.023625
         WinWidth=0.944875
         WinHeight=0.390000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbHints.InternalPreDraw
     End Object
     sb_Hints=AltSectionBackground'KFGui.KFTab_MidGameHelp.sbHints'

     Begin Object Class=GUIScrollTextBox Name=InfoText
         bNoTeletype=True
         CharDelay=0.000050
         EOLDelay=0.000001
         TextAlign=TXTA_Center
         Separator="#"
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.203750
         WinHeight=0.316016
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     GameDescriptionBox=GUIScrollTextBox'KFGui.KFTab_MidGameHelp.InfoText'

     Begin Object Class=GUIScrollTextBox Name=HintText
         bNoTeletype=True
         CharDelay=0.000010
         EOLDelay=0.000001
         TextAlign=TXTA_Center
         OnCreateComponent=HintText.InternalOnCreateComponent
         WinTop=0.653750
         WinHeight=0.266016
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     HintsBox=GUIScrollTextBox'KFGui.KFTab_MidGameHelp.HintText'

     Begin Object Class=GUILabel Name=HintCount
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.900000
         WinLeft=0.300000
         WinWidth=0.400000
         WinHeight=32.000000
     End Object
     HintCountLabel=GUILabel'KFGui.KFTab_MidGameHelp.HintCount'

     Begin Object Class=GUIButton Name=PrevHint
         Caption="Previous Hint"
         bAutoSize=True
         WinTop=0.750000
         WinLeft=0.131500
         WinWidth=0.226801
         WinHeight=0.042125
         RenderWeight=2.000000
         TabOrder=0
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=PrevHint.InternalOnKeyEvent
     End Object
     PrevHintButton=GUIButton'KFGui.KFTab_MidGameHelp.PrevHint'

     Begin Object Class=GUIButton Name=NextHint
         Caption="Next Hint"
         bAutoSize=True
         WinTop=0.750000
         WinLeft=0.698425
         WinWidth=0.159469
         WinHeight=0.042125
         RenderWeight=2.000000
         TabOrder=1
         OnClick=KFTab_MidGameHelp.ButtonClicked
         OnKeyEvent=NextHint.InternalOnKeyEvent
     End Object
     NextHintButton=GUIButton'KFGui.KFTab_MidGameHelp.NextHint'

     OnPreDraw=KFTab_MidGameHelp.FixUp
}
