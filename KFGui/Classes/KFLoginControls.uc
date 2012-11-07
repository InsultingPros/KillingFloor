class KFLoginControls extends MidGamePanel;

var automated   GUISectionBackground    sb_Red,sb_FFA;
var automated   GUIImage                i_JoinRed;
var automated   GUIListBox              lb_Red, lb_FFA;
var automated   GUIButton               b_Team, b_Settings, b_Browser, b_Quit, b_Favs,
                                        b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec;
var             GUIList                 li_Red, li_FFA;

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

    li_Red  = lb_Red.List;
    li_FFA  = lb_FFA.List;

    s = GetSizingCaption();
    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != None && Controls[i] != b_Team)
        {
            GUIButton(Controls[i]).bAutoSize = True;
            GUIButton(Controls[i]).SizingCaption = s;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
        }
    }

    PlayerStyle = MyController.GetStyle(PlayerStyleName, fs);

    //sb_Red.Managecomponent(lb_Red);
    //sb_FFA.ManageComponent(lb_FFA);
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

    if ( bShow )
    {
        InitGRI();
    }
}

function string GetSizingCaption()
{
    local int i;
    local string s;

    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != none && Controls[i] != b_Team )
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

    InitLists();
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

function InitializePlayerLists()
{
    local int i;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    if ( bTeamGame )
    {
        li_Red.bNotify = False;
        li_Red.Clear();
        li_Red.bNotify = True;

        for ( i = 0; i < GRI.PRIArray.Length; i++ )
        {
            if ( GRI.PRIArray[i] == None || GRI.PRIArray[i].Team == None || GRI.PRIArray[i].bOnlySpectator || (GRI.PRIArray[i].bIsSpectator && !GRI.PRIArray[i].bWaitingPlayer) )
            {
                continue;
            }

            if ( GRI.PRIArray[i].Team.TeamIndex == 0 )
            {
                li_Red.Add(GRI.PRIArray[i].PlayerName, none, "" $ GRI.PRIArray[i].PlayerID);
            }
        }
    }

    else if ( bFFAGame )
    {
        li_FFA.bNotify = False;
        li_FFA.Clear();
        li_FFA.bNotify = True;

        for ( i = 0; i < GRI.PRIArray.Length; i++ )
        {
            if ( GRI.PRIArray[i] == None || GRI.PRIArray[i].bOnlySpectator || (GRI.PRIArray[i].bIsSpectator && !GRI.PRIArray[i].bWaitingPlayer) )
            {
                continue;
            }

            li_FFA.Add(GRI.PRIArray[i].PlayerName, none, "" $ GRI.PRIArray[i].PlayerID);
        }
    }
}

function SetupGroups()
{
    local int i;
    local PlayerController PC;

    PC = PlayerOwner();

    if ( bTeamGame )
    {
        RemoveComponent(lb_FFA, True);
        RemoveComponent(sb_FFA, true);

        if ( PC.GameReplicationInfo != None && PC.GameReplicationInfo.bNoTeamChanges )
        {
            RemoveComponent(b_Team,true);
        }

        lb_FFA = None;
    }
    else if ( bFFAGame )
    {
        RemoveComponent(i_JoinRed, true);
        RemoveComponent(lb_Red, true);
        RemoveComponent(sb_Red, true);
        RemoveComponent(b_Team, true);
    }
    else
    {
        for ( i = 0; i < Controls.Length; i++ )
        {
            RemoveComponent(Controls[i], True);
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

function ValidatePlayer(string PlayerID, GUIList List, int Index)
{
    local int i;
    local GameReplicationInfo G;

    G = GetGRI();

    for ( i = 0; i < G.PRIArray.Length; i++)
    {
        if ( G.PRIArray[i] != None && G.PRIArray[i].PlayerID ~= int(PlayerID) )
        {
            return;                                                         // Still in the list
        }
    }

    List.Remove(Index, 1);
}

function AddPlayer(GameReplicationInfo GRI, int Index, GUIList List)
{
    local int i;

    for ( i = 0; i < List.ItemCount; i++)
    {
        if ( int(List.GetExtraAtIndex(i)) ~= GRI.PriArray[index].PlayerID )
        {
            return;
        }
    }

    List.Add(GRI.PriArray[Index].PlayerName, none, ""$GRI.PriArray[Index].PlayerID);
}

protected function UpdatePlayerLists()
{
    local int i;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    if ( bTeamGame )
    {
        i = 0;

        while ( i < li_Red.ItemCount )
        {
            ValidatePlayer(li_Red.GetExtraAtIndex(i), li_Red,i);
            i++;
        }

        for ( i = 0; i < GRI.PRIArray.Length; i++ )
        {
            if ( GRI.PRIArray[i] == None || GRI.PRIArray[i].Team == None ||
                 GRI.PRIArray[i].bOnlySpectator ||
                 (GRI.PRIArray[i].bIsSpectator && !GRI.PRIArray[i].bWaitingPlayer) )
            {
                continue;
            }

            if ( GRI.PRIArray[i].Team.TeamIndex == 0 )
            {
                AddPlayer(GRI, i, li_Red);
            }
        }
    }

    else if ( bFFAGame )
    {
        i = 0;

        while ( i < li_FFA.ItemCount )
        {
            ValidatePlayer(li_FFA.GetExtraAtIndex(i), li_FFA,i);
            i++;
        }

        for ( i = 0; i < GRI.PRIArray.Length; i++ )
        {
            if ( GRI.PRIArray[i] == None || GRI.PRIArray[i].bOnlySpectator || (GRI.PRIArray[i].bIsSpectator && !GRI.PRIArray[i].bWaitingPlayer) )
            {
                continue;
            }

            AddPlayer(GRI, i, li_FFA);
        }
    }
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
        if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
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
        if ( !Components[i].bVisible || GUIButton(Components[i]) == none || Components[i]==b_Team )
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
                if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
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

// When a list item is selected, clear the indexes of the other lists
function ListChange( GUIComponent Sender )
{
    local GUIList List;

    List = GUIList(Sender);
    if ( List == None )
    {
        return;
    }

    if ( List != li_Red )
    {
        li_Red.SilentSetIndex(-1);
    }

    if ( List != li_FFA )
    {
        li_FFA.SilentSetIndex(-1);
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

simulated function DrawPlayerItem(KFPlayerReplicationInfo PRI, Canvas Canvas, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local eMenuState m;
    local string s;
    local float xl,yl;
    local eFontScale F;

    if ( PRI == none )
    {
        return;
    }

    if ( bTeamGame )
    {
        F = FNS_Medium;
    }
    else
    {
        F = FNS_Large;
    }

    if ( PRI != None )
    {
        Y += H * 0.1;
        H -= H * 0.2;

        if ( bSelected )
        {
            Canvas.SetPos(X, Y);
            Canvas.SetDrawColor(100, 0, 0, 255);     // FIXME: Add a var
            Canvas.DrawTile(Controller.DefaultPens[0], W, H, 0, 0, 2, 2);
            m = MSAT_Focused;
        }
        else
        {
            m = MSAT_Blurry;
        }

        PlayerStyle.TextSize(Canvas, m, PRI.PlayerName, XL, YL, FNS_Medium);
        PlayerStyle.DrawText(Canvas, m, X, Y, W, YL, TXTA_Left, PRI.PlayerName, FNS_Medium );

        if ( PRI.PlayerHealth > 0 )
        {
         Canvas.SetDrawColor(255, 60, 60, 255);
         PlayerStyle.TextSize(Canvas, m, "Health: " $ PRI.PlayerHealth $ "%", XL, YL, FNS_Medium);
         PlayerStyle.DrawText(Canvas, m, X + W - XL, Y, XL, YL, TXTA_Right, "Health: " $ PRI.PlayerHealth $ "%", FNS_Medium);
        }
        else
        {
         Canvas.SetDrawColor(150, 0, 0, 255);
         PlayerStyle.TextSize(Canvas, m, "Health: DEAD", XL, YL, FNS_Medium);
         PlayerStyle.DrawText( Canvas, m, X + W - XL, Y, XL, YL, TXTA_Right, "Health: DEAD", FNS_Medium);
        }

        if ( Canvas.ClipX > 640 && bNetGame )
        {
            Y += YL;

            s = "Ping:" $ PRI.Ping $ " P/L:" $ PRI.PacketLoss;

            PlayerStyle.TextSize(Canvas, m, s, XL, YL, FNS_Medium);
            PlayerStyle.DrawText( Canvas, m, X, Y, W, YL, TXTA_Left, S, FNS_Small);
        }
    }
}

function OnDrawRedPlayer(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    PRI = GRI.FindPlayerByID(int(li_Red.GetExtraAtIndex(i)));

    if ( PRI!=None )
    {
        DrawPlayerItem(KFPlayerReplicationInfo(PRI), Canvas, X, Y, W, H, bSelected, bPending);
    }
}

function OnDrawFFAPlayer(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    PRI = GRI.FindPlayerByID(int(li_FFA.GetExtraAtIndex(i)));

    if ( PRI != none )
    {
        DrawPlayerItem(KFPlayerReplicationInfo(PRI), Canvas, X, Y, W, H, bSelected, bPending);
    }
}

function bool RightClick(GUIComponent Sender)
{
    if ( GUIListBase(Controller.ActiveControl) == None )
    {
        return False;
    }

    return True;
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

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);

    li_Red.SilentSetIndex(-1);
    li_FFA.SilentSetIndex(-1);
}

function bool TeamChange(GUIComponent Sender)
{
    PlayerOwner().ConsoleCommand("switchteam");
    Controller.CloseMenu(false);

    return true;
}

function bool RedDraw(Canvas C)
{
    i_JoinRed.WinHeight=i_JoinRed.WinWidth;

    return false;
}

//////////////////////////////////////////
function bool ButtonClicked(GUIComponent Sender)
{
    local PlayerController PC;
    local GUIController C;

    C = Controller;

    PC = PlayerOwner();

    if ( Sender == i_JoinRed )
    {
        //Join Red team
        if ( PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == none ||
             PC.PlayerReplicationInfo.Team.TeamIndex != 0 )
        {
            PC.ChangeTeam(0);
        }

        Controller.CloseMenu(false);
    }
    else if ( Sender == b_Settings )
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

	return true;
}

function InitLists()
{
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    SetupGroups();
    InitializePlayerLists();
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

		if ( bTeamGame )
		{
			if ( PlayerOwner().PlayerReplicationInfo.Team != none )
			{
				sb_Red.HeaderBase = texture'KF_InterfaceArt_tex.Menu.thin_border_SlightTransparent';
			}
		}

	    sb_Red.SetPosition((ActualWidth() / 2.0) - ((sb_Red.WinWidth * ActualWidth()) / 2.0), sb_Red.WinTop, sb_Red.WinWidth, sb_Red.WinHeight);

		SetButtonPositions(C);
		UpdatePlayerLists();

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

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=SBRed
         bFillClient=True
         Caption="Fireteam"
         LeftPadding=0.010000
         RightPadding=0.010000
         WinTop=0.083066
         WinLeft=0.200000
         WinWidth=0.570135
         WinHeight=0.644078
         OnPreDraw=SBRed.InternalPreDraw
     End Object
     sb_Red=AltSectionBackground'KFGui.KFLoginControls.SBRed'

     Begin Object Class=AltSectionBackground Name=SBFFA
         bFillClient=True
         Caption="Players"
         LeftPadding=0.010000
         RightPadding=0.010000
         WinTop=0.024639
         WinLeft=0.037154
         WinWidth=0.919753
         WinHeight=0.701886
         OnPreDraw=SBFFA.InternalPreDraw
     End Object
     sb_FFA=AltSectionBackground'KFGui.KFLoginControls.SBFFA'

     Begin Object Class=GUIListBox Name=RedTeamListBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=RedTeamListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.250000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.400000
         TabOrder=11
     End Object
     lb_Red=GUIListBox'KFGui.KFLoginControls.RedTeamListBox'

     Begin Object Class=GUIListBox Name=FFAPlayerListBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=FFAPlayerListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.150000
         WinLeft=0.325000
         WinWidth=0.350000
         WinHeight=0.500000
         TabOrder=13
     End Object
     lb_FFA=GUIListBox'KFGui.KFLoginControls.FFAPlayerListBox'

     Begin Object Class=GUIButton Name=SettingsButton
         Caption="Settings"
         WinTop=0.766752
         WinLeft=0.112345
         WinWidth=0.200000
         WinHeight=0.100000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'KFGui.KFLoginControls.SettingsButton'

     Begin Object Class=GUIButton Name=BrowserButton
         Caption="Server Browser"
         bAutoSize=True
         WinTop=0.675000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=BrowserButton.InternalOnKeyEvent
     End Object
     b_Browser=GUIButton'KFGui.KFLoginControls.BrowserButton'

     Begin Object Class=GUIButton Name=QuitGameButton
         Caption="Exit Game"
         bAutoSize=True
         WinTop=0.750000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=11
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=QuitGameButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'KFGui.KFLoginControls.QuitGameButton'

     Begin Object Class=GUIButton Name=FavoritesButton
         Caption="Add to Favs"
         bAutoSize=True
         Hint="Add this server to your Favorites"
         WinTop=0.750000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=FavoritesButton.InternalOnKeyEvent
     End Object
     b_Favs=GUIButton'KFGui.KFLoginControls.FavoritesButton'

     Begin Object Class=GUIButton Name=LeaveMatchButton
         bAutoSize=True
         WinTop=0.750000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=10
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=LeaveMatchButton.InternalOnKeyEvent
     End Object
     b_Leave=GUIButton'KFGui.KFLoginControls.LeaveMatchButton'

     Begin Object Class=GUIButton Name=MapVotingButton
         Caption="Map Voting"
         bAutoSize=True
         WinTop=0.825000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=5
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=MapVotingButton.InternalOnKeyEvent
     End Object
     b_MapVote=GUIButton'KFGui.KFLoginControls.MapVotingButton'

     Begin Object Class=GUIButton Name=KickVotingButton
         Caption="Kick Voting"
         bAutoSize=True
         WinTop=0.825000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=6
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=KickVotingButton.InternalOnKeyEvent
     End Object
     b_KickVote=GUIButton'KFGui.KFLoginControls.KickVotingButton'

     Begin Object Class=GUIButton Name=MatchSetupButton
         Caption="Match Setup"
         bAutoSize=True
         WinTop=0.825000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=7
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=MatchSetupButton.InternalOnKeyEvent
     End Object
     b_MatchSetup=GUIButton'KFGui.KFLoginControls.MatchSetupButton'

     Begin Object Class=GUIButton Name=SpectateButton
         Caption="Spectate"
         bAutoSize=True
         WinTop=0.825000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=9
         OnClick=KFLoginControls.ButtonClicked
         OnKeyEvent=SpectateButton.InternalOnKeyEvent
     End Object
     b_Spec=GUIButton'KFGui.KFLoginControls.SpectateButton'

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
     BuddyText="Add To Buddy List"
     RedTeam="Fireteam:"
     PlayerStyleName="TextLabel"
     PropagateVisibility=False
     Begin Object Class=GUIContextMenu Name=PlayerListContextMenu
         OnOpen=KFLoginControls.ContextMenuOpened
         OnSelect=KFLoginControls.ContextClick
     End Object
     ContextMenu=GUIContextMenu'KFGui.KFLoginControls.PlayerListContextMenu'

     OnPreDraw=KFLoginControls.InternalOnPreDraw
     OnRightClick=KFLoginControls.RightClick
}
