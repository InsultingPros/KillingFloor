//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LobbyFooter extends ButtonFooter;

var automated GUIButton b_Ready, b_Cancel, b_Options, b_Perks;
//var automated GUIButton spacer1,spacer2;

var	localized string	ReadyString;
var	localized string	UnreadyString;

function bool InternalOnPreDraw(Canvas C)
{
	if ( PlayerOwner().PlayerReplicationInfo != none && PlayerOwner().PlayerReplicationInfo.bReadyToPlay )
	{
		b_Ready.Caption = UnreadyString;
	}
	else
	{
		b_Ready.Caption = ReadyString;
	}

	return super.InternalOnPreDraw(C);
}

function PositionButtons (Canvas C)
{
	local int i;
	local GUIButton b;
	local float x;

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None)
		{
			if ( x == 0 )
				x = ButtonLeft;
			else x += GetSpacer();
			b.WinLeft = b.RelativeLeft( x, True );
			x += b.ActualWidth();
		}
	}
}

function bool ButtonsSized(Canvas C)
{
	local int i;
	local GUIButton b;
	local bool bResult;
	local string str;
	local float T, AH, AT;

	if ( !bPositioned )
		return false;

	bResult = true;
	str = GetLongestCaption(C);

	AH = ActualHeight();
	AT = ActualTop();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( bAutoSize && bFixedWidth )
			{
			    if(b.Caption == "")
			        b.SizingCaption = Left(str,Len(str)/2);
				else
					b.SizingCaption = str;
			}
			else b.SizingCaption = "";

			bResult = bResult && b.bPositioned;
			if ( bFullHeight )
				b.WinHeight = b.RelativeHeight(AH,true);
			else b.WinHeight = b.RelativeHeight(ActualHeight(ButtonHeight),true);

			switch ( Justification )
			{
			case TXTA_Left:
				T = ClientBounds[1];
				break;

			case TXTA_Center:
				T = (AT + AH / 2) - (b.ActualHeight() / 2);
				break;

			case TXTA_Right:
				T = ClientBounds[3] - b.ActualHeight();
				break;
			}

			//b.WinTop = AT + ((AH - ActualHeight(ButtonHeight)) / 2);
			b.WinTop = b.RelativeTop(T, true ) + ((WinHeight - ButtonHeight) / 2);
		}
	}

	return bResult;
}

function float GetButtonLeft()
{
	local int i;
	local GUIButton b;
	local float TotalWidth, AW, AL;
	local float FooterMargin;

	AL = ActualLeft();
	AW = ActualWidth();
	FooterMargin = GetMargin();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( TotalWidth > 0 )
				TotalWidth += GetSpacer();

			TotalWidth += b.ActualWidth();
		}
	}

	if ( Alignment == TXTA_Center )
		return (AL + AW) / 2 - FooterMargin / 2 - TotalWidth / 2;

	if ( Alignment == TXTA_Right )
		return (AL + AW - FooterMargin / 2) - TotalWidth;

	return AL + (FooterMargin / 2);
}

// Finds the longest caption of all the buttons
function string GetLongestCaption(Canvas C)
{
	local int i;
	local float XL, YL, LongestW;
	local string str;
	local GUIButton b;

	if ( C == None )
		return "";

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( b.Style != None )
				b.Style.TextSize(C, b.MenuState, b.Caption, XL, YL, b.FontScale);
			else C.StrLen( b.Caption, XL, YL );

			if ( LongestW == 0 || XL > LongestW )
			{
				str = b.Caption;
				LongestW = XL;
			}
		}
	}

	return str;
}

function bool OnFooterClick(GUIComponent Sender)
{
	local GUIController C;
	local PlayerController PC;
	local int i;

	PC = PlayerOwner();
	C = Controller;
	if(Sender == b_Cancel)
	{
		//Kill Window and exit game/disconnect from server
		LobbyMenu(PageOwner).bAllowClose = true;
		C.ViewportOwner.Console.ConsoleCommand("DISCONNECT");
		KFGUIController(C).ReturnToMainMenu();
	}
	else if(Sender == b_Ready)
	{
		if ( PC.PlayerReplicationInfo.Team != none )
		{
			if ( PC.Level.NetMode == NM_Standalone || !PC.PlayerReplicationInfo.bReadyToPlay )
			{
				if ( KFPlayerController(PC) != none )
				{
					KFPlayerController(PC).SendSelectedVeterancyToServer(true);
				}

				//Set Ready
				PC.ServerRestartPlayer();
				PC.PlayerReplicationInfo.bReadyToPlay = True;
				if ( PC.Level.GRI.bMatchHasBegun )
					PC.ClientCloseMenu(true, false);

				b_Ready.Caption = UnreadyString;
			}
			else
			{
				if ( KFPlayerController(PC) != none )
				{
					KFPlayerController(PC).ServerUnreadyPlayer();
					PC.PlayerReplicationInfo.bReadyToPlay = False;
					b_Ready.Caption = ReadyString;
				}
			}
		}
	}
	else if (Sender == b_Options)
	{
		PC.ClientOpenMenu("KFGUI.KFSettingsPage", false);
	}
	else if ( Sender == b_Perks )
	{
		if( !Controller.CheckSteam() )
		{
			Controller.OpenMenu(Controller.QuestionMenuClass);
			GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'KFMainMenu'.default.SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
			return false;
		}

		if ( PC != none )
		{
			if ( PC.SteamStatsAndAchievements == none )
			{
				if ( PC.Level.NetMode != NM_Client )
				{
					PC.SteamStatsAndAchievements = PC.Spawn(PC.default.SteamStatsAndAchievementsClass, PC);
					if ( !PC.SteamStatsAndAchievements.Initialize(PC) )
					{
						Controller.OpenMenu(Controller.QuestionMenuClass);
						GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'KFMainMenu'.default.UnknownSteamErrorText, QBTN_Ok, QBTN_Ok);
						PC.SteamStatsAndAchievements.Destroy();
						PC.SteamStatsAndAchievements = none;
					}
					else
					{
						PC.SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
					}
				}
				else
				{
					Controller.OpenMenu(Controller.QuestionMenuClass);
					GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'KFMainMenu'.default.UnknownSteamErrorText, QBTN_Ok, QBTN_Ok);
				}

				return false;
			}
			else if ( !PC.SteamStatsAndAchievements.bInitialized )
			{
				PC.SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
				PC.SteamStatsAndAchievements.GetStatsAndAchievements();
				return false;
			}

			for ( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; i++ )
			{
				if ( KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).GetPerkProgress(i) < 0.0 )
				{
					Controller.OpenMenu(Controller.QuestionMenuClass);
					GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'KFMainMenu'.default.UnknownSteamErrorText, QBTN_Ok, QBTN_Ok);
					PC.SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
					PC.SteamStatsAndAchievements.GetStatsAndAchievements();
					return false;
				}
			}

			PC.ClientOpenMenu("KFGUI.KFProfilePage", false);
		}
	}

	return false;
}

function OnSteamStatsAndAchievementsReady()
{
	PlayerOwner().ClientOpenMenu("KFGUI.KFProfilePage", false);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=ReadyButton
         Caption="Ready"
         Hint="Click to indicate you are ready to play"
         WinTop=0.966146
         WinLeft=0.280000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=4
         bBoundToParent=True
         ToolTip=None

         OnClick=LobbyFooter.OnFooterClick
         OnKeyEvent=ReadyButton.InternalOnKeyEvent
     End Object
     b_Ready=GUIButton'KFGui.LobbyFooter.ReadyButton'

     Begin Object Class=GUIButton Name=Cancel
         Caption="Disconnect"
         Hint="Disconnect From This Server"
         WinTop=0.966146
         WinLeft=0.350000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=5
         bBoundToParent=True
         ToolTip=None

         OnClick=LobbyFooter.OnFooterClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'KFGui.LobbyFooter.Cancel'

     Begin Object Class=GUIButton Name=Options
         Caption="Options"
         Hint="Change game settings."
         WinTop=0.966146
         WinLeft=-0.500000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=3
         bBoundToParent=True
         ToolTip=None

         OnClick=LobbyFooter.OnFooterClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Options=GUIButton'KFGui.LobbyFooter.Options'

     Begin Object Class=GUIButton Name=Perks
         Caption="Select Perk"
         Hint="Select Your Character and Perk"
         WinTop=0.966146
         WinLeft=-0.500000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=2
         bBoundToParent=True
         ToolTip=None

         OnClick=LobbyFooter.OnFooterClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Perks=GUIButton'KFGui.LobbyFooter.Perks'

     ReadyString="Ready"
     UnreadyString="Unready"
     OnPreDraw=LobbyFooter.InternalOnPreDraw
}
