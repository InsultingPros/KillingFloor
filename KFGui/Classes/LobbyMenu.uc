//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LobbyMenu extends UT2k4MainPage;

var automated   moCheckBox              ReadyBox[6];
var automated   KFPlayerReadyBar	    PlayerBox[6];
var automated   GUIImage			    PlayerPerk[6];
var automated   GUILabel			    PlayerVetLabel[6];
var automated   KFLobbyChat             t_ChatBox;
//var automated   KFLobbyTitleLabel       l_TitleBar;
var automated   KFMapStoryLabel         l_StoryBox;
var automated   AltSectionBackground    StoryBoxBG;
var automated   KFBotComboBox           BotSlot1;
var automated   KFAddBotButton          AddBotButton;
var automated   KFRemoveBotButton       RemoveBotButton;
var automated   KFRemoveAllBotButton    TotallyRemoveBotsButton;
var automated   GUISectionBackground    BotsBG;

var automated   AltSectionBackground    GameInfoBG;
var automated 	GUILabel				CurrentMapLabel;
var automated 	GUILabel				DifficultyLabel;
var	automated	GUIImage				WaveBG;
var	automated	GUILabel				WaveLabel;

// Localized Strings
var localized	string					CurrentMapString;
var localized	string					DifficultyString;
var	localized	string					LvAbbrString;

var automated   GUILabel                label_TimeOutCounter;
var automated   GUILabel                PerkClickLabel;

var             bool                    bStoryBoxFilled;
var             bool                    bAllowClose;

//Perks/Profile
var() string				sChar, sCharD;
var() int					nFOV;
var() xUtil.PlayerRecord	PlayerRec;

var automated 	GUISectionBackground	i_BGPerks;
var automated 	GUISectionBackground	i_BGPerk;

var automated 	GUISectionBackground	i_BGPerkEffects;
var automated 	GUIScrollTextBox		lb_PerkEffects;

var automated 	GUIImage				i_Portrait;
var automated 	GUISectionBackground	PlayerPortraitBG;

var				float					IconBorder;			// Percent of Height to leave blank inside Icon Background
var				float					ItemBorder;			// Percent of Height to leave blank inside Item Background
var				float					ItemSpacing;		// Number of Pixels between Items
var				float					ProgressBarHeight;	// Percent of Height to make Progress Bar's Height
var				float					TextTopOffset;		// Percent of Height to off Progress String from top of Progress Bar(typically negative)
var				float					IconToInfoSpacing;	// Percent of Width to offset Info from right side of Icon

var				texture					ItemBackground;
var				texture					ProgressBarBackground;
var				texture					ProgressBarForeground;
var				texture					PerkBackground;
var				texture					InfoBackground;

//var bool bAdminUse;  // If you're not an admin, gtfo!

var             int                     ActivateTimeoutTime;    // When was the lobby timeout turned on?
var             bool                    bTimeoutTimeLogged;     // Was it already logged once?
var             bool                    bTimedOut;              // Have we timed out out successfully?

var	localized	string					WaitingForServerStatus;
var	localized	string					WaitingForOtherPlayers;
var	localized	string					AutoCommence;

var	localized	string					BeginnerString;
var	localized	string					NormalString;
var	localized	string					HardString;
var	localized	string					SuicidalString;
var	localized	string					HellOnEarthString;

var				bool					bShouldUpdateVeterancy;
var() localized	string					SelectPerkInformationString;
var() localized	string					PerksDisabledString;
var				class<KFVeterancyTypes>	CurrentVeterancy;
var				int						CurrentVeterancyLevel;
var				float					VideoTimer;
var				bool					VideoOpened;
var				bool					VideoPlayed;

var automated	GUISectionBackground	ADBackground;
var				LobbyMenuAd				LobbyMenuAd;

const MAX_MOVIES = 4;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	local int i;

	Super.InitComponent(MyC, MyO);

	LobbyMenuAd = new class'LobbyMenuAd';
	LobbyMenuAd.MenuMovie = new class'Movie';
	LobbyMenuAd.MenuMovie.Callbacks = LobbyMenuAd;

	for ( i = 0; i < 6; i++ )
	{
		PlayerPerk[i].WinWidth = PlayerPerk[i].ActualHeight();
		PlayerPerk[i].WinLeft += ((PlayerBox[i].ActualHeight() - PlayerPerk[i].ActualHeight()) / 2) / MyC.ResX;
	}

	i_Portrait.WinTop = PlayerPortraitBG.ActualTop() + 30;
	i_Portrait.WinHeight = PlayerPortraitBG.ActualHeight() - 36;

	t_ChatBox.FocusInstead = PerkClickLabel;

}

function CheckBotButtonAccess()
{

	if ( KFGameReplicationInfo(PlayerOwner().GameReplicationInfo) == none )
	{
		return;
	}

	  // log(PlayerOwner().GameReplicationInfo.GameClass);

	  // Dont show Invasion bots, on Story mode.
	  // Check the GRI, on dedicated servers
	  // Level.Game seems to work on listens.

	if ( true || PlayerOwner().GameReplicationInfo.GameClass == "KFMod.KFSPGameType" ||
		 PlayerOwner().Level.NetMode == NM_ListenServer && KFSPGameType(PlayerOwner().Level.Game) != none )
	{
		BotSlot1.Hide();
		AddBotButton.Hide();
		RemoveBotButton.Hide();
		TotallyRemoveBotsButton.Hide();
		BotsBG.Hide();
	}
	/*
	else
	{
		BotSlot1.Show();
		AddBotButton.Show();
		RemoveBotButton.Show();
		TotallyRemoveBotsButton.Show();
		BotsBG.Show();
	}

	if ( !PlayerOwner().PlayerReplicationInfo.bAdmin && PlayerOwner().Level.NetMode != NM_StandAlone )
	{
		BotSlot1.DisableMe();
		AddBotButton.DisableMe();
		RemoveBotButton.DisableMe();
		TotallyRemoveBotsButton.DisableMe();
		BotsBG.DisableMe();
	}
	if ( PlayerOwner().PlayerReplicationInfo.bAdmin  || PlayerOwner().Level.NetMode == NM_ListenServer )
	{
		if ( KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).bNoBots )
		{
			BotSlot1.DisableMe();
			AddBotButton.DisableMe();
			RemoveBotButton.DisableMe();
			TotallyRemoveBotsButton.DisableMe();
			BotsBG.DisableMe();
		}
		else
		{
			BotSlot1.EnableMe();
			AddBotButton.EnableMe();
			RemoveBotButton.EnableMe();
			BotsBG.EnableMe();
			TotallyRemoveBotsButton.EnableMe();
		}

		if ( PlayerOwner().GameReplicationInfo.PRIArray.length + KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).PendingBots < 6 )
		{
			AddBotButton.EnableMe();
		}
		else
		{
			AddBotButton.DisableMe();
		}

		if ( KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).PendingBots > 0 )
		{
			RemoveBotButton.EnableMe();
			TotallyRemoveBotsButton.EnableMe();
		}
		else
		{
			RemoveBotButton.DisableMe();
			TotallyRemoveBotsButton.DisableMe();
		}
	}*/
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int i;
	local bool bVoiceChatKey;
	local array<string> BindKeyNames, LocalizedBindKeyNames;

	Controller.GetAssignedKeys( "VoiceTalk", BindKeyNames, LocalizedBindKeyNames );

	for ( i = 0; i < BindKeyNames.Length; i++ )
	{
		if ( Mid( GetEnum(enum'EInputKey', Key), 3 ) ~= BindKeyNames[i] )
		{
			bVoiceChatKey = true;
			break;
		}
	}

	if ( bVoiceChatKey )
	{
		if ( state == 1 || state == 2 )
		{
			if ( PlayerOwner() != none )
			{
				PlayerOwner().bVoiceTalk = 1;
			}
		}
		else
		{
			if ( PlayerOwner() != none )
			{
				PlayerOwner().bVoiceTalk = 0;
				return false;
			}
		}

		return true;
	}

	return false;
}

function UpdateBotSlots();

function ClearChatBox()
{
	t_ChatBox.lb_Chat.SetContent("");
}

function TimedOut()
{
	bTimedOut = true;
	PlayerOwner().ServerRestartPlayer();
	bAllowClose = true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local int i, j, z;
	local string StoryString;
	local String SkillString;
	local KFGameReplicationInfo KFGRI;
	local PlayerController PC;
	local PlayerReplicationInfo InList[6];
	local bool bWasThere, bShowProfilePage;

	PC = PlayerOwner();

	if ( PC == none || PC.Level == none ) // Error?
	{
		return false;
	}

	i_Portrait.WinTop = PlayerPortraitBG.ActualTop() + 30;
	i_Portrait.WinHeight = PlayerPortraitBG.ActualHeight() - 36;

	if ( PC.PlayerReplicationInfo != none && (!PC.PlayerReplicationInfo.bWaitingPlayer || PC.PlayerReplicationInfo.bOnlySpectator) )
	{
		PC.ClientCloseMenu(True,False);
		return false;
	}

	t_Footer.InternalOnPreDraw(C);

	WaveLabel.WinWidth = WaveLabel.ActualHeight();

   	KFGRI = KFGameReplicationInfo(PC.GameReplicationInfo);

	if ( KFGRI != none )
	{
		WaveLabel.Caption = string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
	}
	else
	{
		WaveLabel.Caption = "?/?";
	}

	if ( KFPlayerController(PC) != none && bShouldUpdateVeterancy )
	{
		if ( KFPlayerController(PC).SelectedVeterancy == none )
		{
			bShowProfilePage = true;

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

   				bShowProfilePage = false;
			}
    		else if ( !PC.SteamStatsAndAchievements.bInitialized )
    		{
   				PC.SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
   				PC.SteamStatsAndAchievements.GetStatsAndAchievements();
   				bShowProfilePage = false;
    		}

			if ( KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements) != none )
			{
	    		for ( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; i++ )
	    		{
	    			if ( KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).GetPerkProgress(i) < 0.0 )
	    			{
	    				PC.SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
	    				PC.SteamStatsAndAchievements.GetStatsAndAchievements();
				    	bShowProfilePage = false;
	    			}
	    		}
	    	}

			if ( bShowProfilePage )
			{
				OnSteamStatsAndAchievementsReady();
			}

			bShouldUpdateVeterancy = false;
		}
		else if ( PC.SteamStatsAndAchievements != none && PC.SteamStatsAndAchievements.bInitialized )
		{
			KFPlayerController(PC).SendSelectedVeterancyToServer();
			bShouldUpdateVeterancy = false;
		}
	}

/*	if ( KFGRI == none ) // May not have been received yet on client.
	{
		l_TitleBar.Caption = WaitingForServerStatus;
		Return False;
	}
*/
	// First fill in non-ready players.


	if ( KFGRI != none )
	{
		for ( i = 0; i < KFGRI.PRIArray.Length; i++ )
		{
			if ( KFGRI.PRIArray[i] == none || KFGRI.PRIArray[i].bOnlySpectator || KFGRI.PRIArray[i].bReadyToPlay )
			{
				continue;
			}

			PlayerPerk[j].Image = none;
			ReadyBox[j].Checked(False);
			ReadyBox[j].SetCaption(Left(KFGRI.PRIArray[i].PlayerName, 20));

			if ( KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill != none )
			{
				PlayerVetLabel[j].Caption = LvAbbrString @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkillLevel @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.VeterancyName;
				PlayerPerk[j].Image = KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;
			}

			//PlayerBox[j].ImageColor = PlayerBox[j].Default.ImageColor;
			InList[j] = KFGRI.PRIArray[i];
			j++;
			if( j >= 6 )
			{
				GoTo'DoneIt';
			}
		}

		// Then comes rest.
		for ( i = 0; i < KFGRI.PRIArray.Length; i++ )
		{
			if ( KFGRI.PRIArray[i] == none || KFGRI.PRIArray[i].bOnlySpectator )
			{
				Continue;
			}

			bWasThere = False;

			for ( z = 0; z < j; z++ )
			{
				if ( InList[z] == KFGRI.PRIArray[i] )
				{
					bWasThere = True;
					Break;
				}
			}

			if ( bWasThere )
			{
				Continue;
			}

			PlayerPerk[j].Image = none;
			ReadyBox[j].Checked(KFGRI.PRIArray[i].bReadyToPlay);
			ReadyBox[j].SetCaption(Left(KFGRI.PRIArray[i].PlayerName, 20));

			if ( KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill != none )
			{
				PlayerVetLabel[j].Caption = LvAbbrString @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkillLevel @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.VeterancyName;
				PlayerPerk[j].Image = KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;
			}

			if ( KFGRI.PRIArray[i].bReadyToPlay )
			{
				//PlayerBox[j].ImageColor.R = 200;
				//PlayerBox[j].ImageColor.G = 75;
				//PlayerBox[j].ImageColor.B = 75;
				//PlayerBox[j].ImageColor.A = 200;

				if ( !bTimeoutTimeLogged )
				{
					ActivateTimeoutTime = PC.Level.TimeSeconds;
					bTimeoutTimeLogged = true;
				}
			}
			else
			{
				//PlayerBox[j].ImageColor = PlayerBox[j].Default.ImageColor;
			}

			j++;

			if ( j >= 6 )
			{
				Break;
			}
		}
	}

	while( j < 6 )
	{
		PlayerPerk[j].Image = none;
		ReadyBox[j].Checked(False);
		ReadyBox[j].SetCaption("");
		PlayerVetLabel[j].Caption = "";
		//PlayerBox[j].ImageColor = PlayerBox[j].Default.ImageColor;
		j++;
	}

DoneIt:
	StoryString = PC.Level.Description;

	if ( !bStoryBoxFilled )
	{
		l_StoryBox.LoadStoryText();
		bStoryBoxFilled = true;
	}

	CheckBotButtonAccess();

	// Hate to do it like this, but there's no real easy way to get the SkillLevel strings from the Scoreboard, since it's only ever
	// called as a class. Spawning a fresh one /w DynamicLoadObject doesn't work too great (online).
	if ( KFGRI != none )
	{
		if ( KFGRI.BaseDifficulty == 1 )
		{
			SkillString = BeginnerString;
		}
		else if ( KFGRI.BaseDifficulty == 2 )
		{
			SkillString = NormalString;
		}
		else if ( KFGRI.BaseDifficulty == 4 )
		{
			SkillString = HardString;
		}
		else if ( KFGRI.BaseDifficulty == 5 )
		{
			SkillString = SuicidalString;
		}
		else if ( KFGRI.BaseDifficulty == 7 )
		{
			SkillString = HellOnEarthString;
		}
	}

//	l_TitleBar.Caption = (SkillString@KFGRI.GameName$" on "$PC.Level.Title);

	CurrentMapLabel.Caption = CurrentMapString @ PC.Level.Title;
	DifficultyLabel.Caption = DifficultyString @ SkillString;

	return false;
}

function bool StopClose(optional bool bCancelled)
{
	bStoryBoxFilled = false;

	CheckBotButtonAccess();
	UpdateBotSlots();
	ClearChatBox();

	// this is for the OnCanClose delegate
	// can't close now unless done by call to CloseAll,
	// or the bool has been set to true by LobbyFooter
	return false;
}

event Opened(GUIComponent Sender)                   // Called when the Menu Owner is opened
{
	if ( LobbyMenuAd == none)
	{
		LobbyMenuAd = new class'LobbyMenuAd';

		if (LobbyMenuAd.MenuMovie == None)
		{
			LobbyMenuAd.MenuMovie = new class'Movie';
			LobbyMenuAd.MenuMovie.Callbacks = LobbyMenuAd;
		}
	}

	bShouldUpdateVeterancy = true;
	SetTimer(1,true);
	VideoTimer = 0.0;
	VideoPlayed = false;
	VideoOpened = false;
}

/*
functon InternalReOpen()
{
	VideoTimer = 0.0;
	VideoPlayed = false;
}
*/

function InternalOnClosed(bool bCancelled)
{
	if ( PlayerOwner() != none)
	{
		PlayerOwner().Advertising_ExitZone();
	}

	if (LobbyMenuAd != None)
	{
		LobbyMenuAd.DestroyMovie();
		LobbyMenuAd = none;
	}
}

event Timer()
{
	local KFGameReplicationInfo KF;

	if ( PlayerOwner().PlayerReplicationInfo.bOnlySpectator )
	{
		label_TimeOutCounter.caption = "You are a spectator.";
		Return;
	}

	KF = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);

	if ( KF==None )
	{
		label_TimeOutCounter.caption = WaitingForServerStatus;
	}
	else if ( KF.LobbyTimeout <= 0 )
	{
		label_TimeOutCounter.caption = WaitingForOtherPlayers;
	}
	else
	{
		label_TimeOutCounter.caption = AutoCommence$":" @ KF.LobbyTimeout;
	}
}

function DrawPerk(Canvas Canvas)
{
	local float X, Y, Width, Height;
	local int CurIndex, LevelIndex;
	local float TempX, TempY;
	local float TempWidth, TempHeight;
	local float IconSize, ProgressBarWidth, PerkProgress;
	local string PerkName, PerkLevelString;
	local bool focused;

	DrawPortrait();

	focused = Controller.ActivePage == self;

	if (focused)
	{
		VideoTimer += Controller.RenderDelta;
	}
	else
	{
		if (LobbyMenuAd == None || !LobbyMenuAd.MenuMovie.IsPlaying())
		{
			VideoTimer = 0.0;
		}

		VideoPlayed = false;
	}

	if (focused && LobbyMenuAd != None)
	{
		Canvas.SetPos(0.066797 * Canvas.ClipX + 5, 0.325208 * Canvas.ClipY + 30);
		X = Canvas.ClipX / 1024; // X & Y scale

		AdBackground.WinWidth = 320 * X + 10;
		AdBackground.WinHeight = 240 * X + 37;

//		if ( !VideoOpened && (LobbyMenuAd.GetState() == ADASSET_STATE_DOWNLOADED))
//		{
//			// Open the video
//			VideoOpened = true;
//
//			LobbyMenuAd.MenuMovie.Open(LobbyMenuAd.DownloadPath);
//		}
		/*else*/ if ( !VideoOpened /*&& (LobbyMenuAd.GetState() == ADASSET_STATE_ERROR)*/)
		{
			// Open the video
			VideoOpened = true;
			LobbyMenuAd.MenuMovie.Open("../Movies/Movie"$(rand(MAX_MOVIES) + 1)$".bik");
		}

		// Hold on the first frame for 3 seconds so it doesn't
		// Overwhelm the player
		if ( !VideoPlayed && VideoTimer > 3.0 )
		{
			// Start video
			VideoPlayed = true;
			LobbyMenuAd.MenuMovie.Play(false);
		}

		Canvas.DrawTile(LobbyMenuAd.MenuMovie, 320 * X, 240 * X,
				0, 0, 320, 240);
	}

	if ( KFPlayerController(PlayerOwner()) == none || KFPlayerController(PlayerOwner()).SelectedVeterancy == none ||
		 KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements) == none )
	{
		return;
	}
	else

	CurIndex = KFPlayerController(PlayerOwner()).SelectedVeterancy.default.PerkIndex;
	LevelIndex = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).PerkHighestLevelAvailable(CurIndex);
	PerkName =  KFPlayerController(PlayerOwner()).SelectedVeterancy.default.VeterancyName;
	PerkLevelString = LvAbbrString @ LevelIndex;
	PerkProgress = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).GetPerkProgress(CurIndex);

	//Get the position size etc in pixels
	X = i_BGPerk.ActualLeft() + 5;
	Y = i_BGPerk.ActualTop() + 30;

	Width = i_BGPerk.ActualWidth() - 10;
	Height = i_BGPerk.ActualHeight() - 37;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	//Canvas.DrawTileStretched(ItemBackground, Width, Height);

	IconSize = Height - ItemSpacing;

	// Draw Item Background
	Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
	Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
	Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 14);

	IconSize -= IconBorder * 2.0 * Height;

	// Draw Icon
	Canvas.SetPos(TempX + IconBorder * Height, TempY + IconBorder * Height);
	Canvas.DrawTile(class'KFGameType'.default.LoadedSkills[CurIndex].default.OnHUDIcon, IconSize, IconSize, 0, 0, 256, 256);

	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += TextTopOffset * Height + ItemBorder * Height;

	ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);

	// Select Text Color
	Canvas.SetDrawColor(0, 0, 0, 255);

	// Draw the Perk's Level name
	Canvas.StrLen(PerkName, TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(PerkName);

	// Draw the Perk's Level
	if ( PerkLevelString != "" )
	{
		Canvas.StrLen(PerkLevelString, TempWidth, TempHeight);
		Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
		Canvas.DrawText(PerkLevelString);
	}

	TempY += TempHeight + (0.04 * Height);

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height);
	Canvas.SetPos(TempX + 3.0, TempY + 3.0);
	Canvas.DrawTileStretched(ProgressBarForeground, (ProgressBarWidth - 6.0) * PerkProgress, (ProgressBarHeight * Height) - 6.0);

	if ( PlayerOwner().SteamStatsAndAchievements.bUsedCheats )
	{
		if ( CurrentVeterancyLevel != 255 )
		{
			lb_PerkEffects.SetContent(PerksDisabledString);
			CurrentVeterancyLevel = 255;
		}
	}
	else if ( CurrentVeterancy != KFPlayerController(PlayerOwner()).SelectedVeterancy || CurrentVeterancyLevel != LevelIndex )
	{
		lb_PerkEffects.SetContent(KFPlayerController(PlayerOwner()).SelectedVeterancy.default.LevelEffects[LevelIndex]);
		CurrentVeterancy = KFPlayerController(PlayerOwner()).SelectedVeterancy;
		CurrentVeterancyLevel = LevelIndex;
	}
}

function DrawPortrait()
{
	sChar = PlayerOwner().GetUrlOption("Character");
	sCharD = sChar;
	SetPlayerRec();
}

function SetPlayerRec()
{
	local int i;
	local array<xUtil.PlayerRecord> PList;

	class'xUtil'.static.GetPlayerList(PList);

	// Filter out to only characters without the 's' menu setting
	for ( i = 0; i < PList.Length; i++ )
	{
		if ( sChar ~= Plist[i].DefaultName )
		{
			PlayerRec = PList[i];
			break;
		}
	}

	i_Portrait.Image = PlayerRec.Portrait;
}

function bool ShowPerkMenu(GUIComponent Sender)
{
	if ( PlayerOwner() != none)
	{
		PlayerOwner().ClientOpenMenu("KFGUI.KFProfilePage", false);
	}

	return true;
}

function OnSteamStatsAndAchievementsReady()
{
	Controller.OpenMenu("KFGUI.KFProfilePage");

	Controller.OpenMenu(Controller.QuestionMenuClass);
	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SelectPerkInformationString, QBTN_Ok, QBTN_Ok);
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=ReadyBox0
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME1"
         LabelStyleName=
         LabelColor=(B=10,G=10,R=10,A=210)
         OnCreateComponent=ReadyBox0.InternalOnCreateComponent
         WinTop=0.047500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.045000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(0)=moCheckBox'KFGui.LobbyMenu.ReadyBox0'

     Begin Object Class=moCheckBox Name=ReadyBox1
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME2"
         LabelColor=(B=0)
         OnCreateComponent=ReadyBox1.InternalOnCreateComponent
         WinTop=0.092500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.045000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(1)=moCheckBox'KFGui.LobbyMenu.ReadyBox1'

     Begin Object Class=moCheckBox Name=ReadyBox2
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME3"
         LabelColor=(B=0)
         OnCreateComponent=ReadyBox2.InternalOnCreateComponent
         WinTop=0.137500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.048000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(2)=moCheckBox'KFGui.LobbyMenu.ReadyBox2'

     Begin Object Class=moCheckBox Name=ReadyBox3
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME4"
         LabelColor=(B=0)
         OnCreateComponent=ReadyBox3.InternalOnCreateComponent
         WinTop=0.182500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.045000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(3)=moCheckBox'KFGui.LobbyMenu.ReadyBox3'

     Begin Object Class=moCheckBox Name=ReadyBox4
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME5"
         LabelColor=(B=0)
         OnCreateComponent=ReadyBox4.InternalOnCreateComponent
         WinTop=0.227500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.045000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(4)=moCheckBox'KFGui.LobbyMenu.ReadyBox4'

     Begin Object Class=moCheckBox Name=ReadyBox5
         bValueReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.820000
         Caption="NAME6"
         LabelColor=(B=0)
         OnCreateComponent=ReadyBox5.InternalOnCreateComponent
         WinTop=0.272500
         WinLeft=0.075000
         WinWidth=0.400000
         WinHeight=0.045000
         RenderWeight=0.550000
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     ReadyBox(5)=moCheckBox'KFGui.LobbyMenu.ReadyBox5'

     Begin Object Class=KFPlayerReadyBar Name=Player1BackDrop
         WinTop=0.040000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(0)=KFPlayerReadyBar'KFGui.LobbyMenu.Player1BackDrop'

     Begin Object Class=KFPlayerReadyBar Name=Player2BackDrop
         WinTop=0.085000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(1)=KFPlayerReadyBar'KFGui.LobbyMenu.Player2BackDrop'

     Begin Object Class=KFPlayerReadyBar Name=Player3BackDrop
         WinTop=0.130000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(2)=KFPlayerReadyBar'KFGui.LobbyMenu.Player3BackDrop'

     Begin Object Class=KFPlayerReadyBar Name=Player4BackDrop
         WinTop=0.175000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(3)=KFPlayerReadyBar'KFGui.LobbyMenu.Player4BackDrop'

     Begin Object Class=KFPlayerReadyBar Name=Player5BackDrop
         WinTop=0.220000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(4)=KFPlayerReadyBar'KFGui.LobbyMenu.Player5BackDrop'

     Begin Object Class=KFPlayerReadyBar Name=Player6BackDrop
         WinTop=0.265000
         WinLeft=0.040000
         WinWidth=0.350000
         WinHeight=0.045000
         RenderWeight=0.350000
     End Object
     PlayerBox(5)=KFPlayerReadyBar'KFGui.LobbyMenu.Player6BackDrop'

     Begin Object Class=GUIImage Name=Player1P
         ImageStyle=ISTY_Justified
         WinTop=0.043000
         WinLeft=0.040000
         WinWidth=0.039000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(0)=GUIImage'KFGui.LobbyMenu.Player1P'

     Begin Object Class=GUIImage Name=Player2P
         ImageStyle=ISTY_Justified
         WinTop=0.088000
         WinLeft=0.040000
         WinWidth=0.045000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(1)=GUIImage'KFGui.LobbyMenu.Player2P'

     Begin Object Class=GUIImage Name=Player3P
         ImageStyle=ISTY_Justified
         WinTop=0.133000
         WinLeft=0.040000
         WinWidth=0.045000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(2)=GUIImage'KFGui.LobbyMenu.Player3P'

     Begin Object Class=GUIImage Name=Player4P
         ImageStyle=ISTY_Justified
         WinTop=0.178000
         WinLeft=0.040000
         WinWidth=0.045000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(3)=GUIImage'KFGui.LobbyMenu.Player4P'

     Begin Object Class=GUIImage Name=Player5P
         ImageStyle=ISTY_Justified
         WinTop=0.223000
         WinLeft=0.040000
         WinWidth=0.045000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(4)=GUIImage'KFGui.LobbyMenu.Player5P'

     Begin Object Class=GUIImage Name=Player6P
         ImageStyle=ISTY_Justified
         WinTop=0.268000
         WinLeft=0.040000
         WinWidth=0.045000
         WinHeight=0.039000
         RenderWeight=0.560000
     End Object
     PlayerPerk(5)=GUIImage'KFGui.LobbyMenu.Player6P'

     Begin Object Class=GUILabel Name=Player1Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.040000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.500000
     End Object
     PlayerVetLabel(0)=GUILabel'KFGui.LobbyMenu.Player1Veterancy'

     Begin Object Class=GUILabel Name=Player2Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.085000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.500000
     End Object
     PlayerVetLabel(1)=GUILabel'KFGui.LobbyMenu.Player2Veterancy'

     Begin Object Class=GUILabel Name=Player3Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.130000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.550000
     End Object
     PlayerVetLabel(2)=GUILabel'KFGui.LobbyMenu.Player3Veterancy'

     Begin Object Class=GUILabel Name=Player4Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.175000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.550000
     End Object
     PlayerVetLabel(3)=GUILabel'KFGui.LobbyMenu.Player4Veterancy'

     Begin Object Class=GUILabel Name=Player5Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.220000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.550000
     End Object
     PlayerVetLabel(4)=GUILabel'KFGui.LobbyMenu.Player5Veterancy'

     Begin Object Class=GUILabel Name=Player6Veterancy
         TextAlign=TXTA_Right
         TextColor=(B=19,G=19,R=19)
         TextFont="UT2SmallFont"
         WinTop=0.265000
         WinLeft=0.229070
         WinWidth=0.151172
         WinHeight=0.045000
         RenderWeight=0.550000
     End Object
     PlayerVetLabel(5)=GUILabel'KFGui.LobbyMenu.Player6Veterancy'

     Begin Object Class=KFLobbyChat Name=ChatBox
         OnCreateComponent=ChatBox.InternalOnCreateComponent
         WinTop=0.807600
         WinLeft=0.016090
         WinWidth=0.971410
         WinHeight=0.100000
         RenderWeight=0.010000
         TabOrder=1
         OnPreDraw=ChatBox.FloatingPreDraw
         OnRendered=ChatBox.FloatingRendered
         OnHover=ChatBox.FloatingHover
         OnMousePressed=ChatBox.FloatingMousePressed
         OnMouseRelease=ChatBox.FloatingMouseRelease
     End Object
     t_ChatBox=KFLobbyChat'KFGui.LobbyMenu.ChatBox'

     Begin Object Class=KFMapStoryLabel Name=LobbyMapStoryBox
         OnCreateComponent=LobbyMapStoryBox.InternalOnCreateComponent
         ToolTip=None

     End Object
     l_StoryBox=KFMapStoryLabel'KFGui.LobbyMenu.LobbyMapStoryBox'

     Begin Object Class=AltSectionBackground Name=StoryBoxBackground
         bNoCaption=True
         WinTop=0.109808
         WinLeft=0.489062
         WinWidth=0.487374
         WinHeight=0.309092
         OnPreDraw=StoryBoxBackground.InternalPreDraw
     End Object
     StoryBoxBG=AltSectionBackground'KFGui.LobbyMenu.StoryBoxBackground'

     Begin Object Class=KFBotComboBox Name=BotComboBox1
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="              Bot Control"
         OnCreateComponent=BotComboBox1.InternalOnCreateComponent
         Hint="Select Bot to Add"
         WinTop=0.550000
         WinLeft=0.400000
         WinWidth=0.550000
         TabOrder=10
         OnChange=LobbyMenu.InternalOnChange
     End Object
     BotSlot1=KFBotComboBox'KFGui.LobbyMenu.BotComboBox1'

     Begin Object Class=KFAddBotButton Name=AddBotGUIButton
         OnCreateComponent=AddBotGUIButton.InternalOnCreateComponent
         WinTop=0.650000
         WinLeft=0.450000
         WinWidth=0.450000
         OnChange=LobbyMenu.InternalOnChange
     End Object
     AddBotButton=KFAddBotButton'KFGui.LobbyMenu.AddBotGUIButton'

     Begin Object Class=KFRemoveBotButton Name=RemoveBotGUIButton
         OnCreateComponent=RemoveBotGUIButton.InternalOnCreateComponent
         WinTop=0.700000
         WinLeft=0.320000
         WinWidth=0.590000
         OnChange=LobbyMenu.InternalOnChange
     End Object
     RemoveBotButton=KFRemoveBotButton'KFGui.LobbyMenu.RemoveBotGUIButton'

     Begin Object Class=KFRemoveAllBotButton Name=RemoveAllBotsGUIButton
         OnCreateComponent=RemoveAllBotsGUIButton.InternalOnCreateComponent
         WinTop=0.750000
         WinLeft=0.320000
         WinWidth=0.590000
         OnChange=LobbyMenu.InternalOnChange
     End Object
     TotallyRemoveBotsButton=KFRemoveAllBotButton'KFGui.LobbyMenu.RemoveAllBotsGUIButton'

     Begin Object Class=AltSectionBackground Name=BotAreaBackground
         bNoCaption=True
         WinTop=0.500000
         WinLeft=0.450000
         WinWidth=0.520000
         WinHeight=0.380000
         OnPreDraw=BotAreaBackground.InternalPreDraw
     End Object
     BotsBG=AltSectionBackground'KFGui.LobbyMenu.BotAreaBackground'

     Begin Object Class=AltSectionBackground Name=GameInfoB
         WinTop=0.037851
         WinLeft=0.489062
         WinWidth=0.487374
         WinHeight=0.075000
         OnPreDraw=GameInfoB.InternalPreDraw
     End Object
     GameInfoBG=AltSectionBackground'KFGui.LobbyMenu.GameInfoB'

     Begin Object Class=GUILabel Name=CurrentMapL
         Caption="LAlalala Map"
         TextColor=(B=158,G=176,R=175)
         WinTop=0.042179
         WinLeft=0.496524
         WinWidth=0.360000
         WinHeight=0.035714
         RenderWeight=0.900000
     End Object
     CurrentMapLabel=GUILabel'KFGui.LobbyMenu.CurrentMapL'

     Begin Object Class=GUILabel Name=DifficultyL
         Caption="Difficulty"
         TextColor=(B=158,G=176,R=175)
         WinTop=0.072381
         WinLeft=0.496524
         WinWidth=0.360000
         WinHeight=0.035714
         RenderWeight=0.900000
     End Object
     DifficultyLabel=GUILabel'KFGui.LobbyMenu.DifficultyL'

     Begin Object Class=GUIImage Name=WaveB
         Image=Texture'KillingFloorHUD.HUD.Hud_Bio_Circle'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         WinTop=0.043810
         WinLeft=0.923238
         WinWidth=0.051642
         WinHeight=0.061783
         RenderWeight=0.800000
     End Object
     WaveBG=GUIImage'KFGui.LobbyMenu.WaveB'

     Begin Object Class=GUILabel Name=WaveL
         Caption="1/4"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinTop=0.043810
         WinLeft=0.923238
         WinWidth=0.051642
         WinHeight=0.061783
         RenderWeight=0.900000
     End Object
     WaveLabel=GUILabel'KFGui.LobbyMenu.WaveL'

     CurrentMapString="Current Map:"
     DifficultyString="Difficulty Level:"
     LvAbbrString="Lv"
     Begin Object Class=GUILabel Name=TimeOutCounter
         Caption="Game will auto-commence in: "
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         WinTop=0.000010
         WinLeft=0.059552
         WinWidth=0.346719
         WinHeight=0.045704
         TabOrder=6
     End Object
     label_TimeOutCounter=GUILabel'KFGui.LobbyMenu.TimeOutCounter'

     Begin Object Class=GUILabel Name=PerkClickArea
         WinTop=0.432395
         WinLeft=0.488851
         WinWidth=0.444405
         WinHeight=0.437312
         bAcceptsInput=True
         OnClickSound=CS_Click
         OnClick=LobbyMenu.ShowPerkMenu
     End Object
     PerkClickLabel=GUILabel'KFGui.LobbyMenu.PerkClickArea'

     Begin Object Class=GUISectionBackground Name=BGPerk
         bFillClient=True
         Caption="Current Perk"
         WinTop=0.432291
         WinLeft=0.650976
         WinWidth=0.325157
         WinHeight=0.138086
         OnPreDraw=BGPerk.InternalPreDraw
     End Object
     i_BGPerk=GUISectionBackground'KFGui.LobbyMenu.BGPerk'

     Begin Object Class=GUISectionBackground Name=BGPerkEffects
         bFillClient=True
         Caption="Perk Effects"
         WinTop=0.568448
         WinLeft=0.650976
         WinWidth=0.325157
         WinHeight=0.307442
         OnPreDraw=BGPerkEffects.InternalPreDraw
     End Object
     i_BGPerkEffects=GUISectionBackground'KFGui.LobbyMenu.BGPerkEffects'

     Begin Object Class=GUIScrollTextBox Name=PerkEffectsScroll
         CharDelay=0.002500
         EOLDelay=0.100000
         OnCreateComponent=PerkEffectsScroll.InternalOnCreateComponent
         WinTop=0.626094
         WinLeft=0.659687
         WinWidth=0.309454
         WinHeight=0.244961
         TabOrder=9
         ToolTip=None

     End Object
     lb_PerkEffects=GUIScrollTextBox'KFGui.LobbyMenu.PerkEffectsScroll'

     Begin Object Class=GUIImage Name=PlayerPortrait
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.472396
         WinLeft=0.492522
         WinWidth=0.156368
         WinHeight=0.397022
         RenderWeight=0.300000
     End Object
     i_Portrait=GUIImage'KFGui.LobbyMenu.PlayerPortrait'

     Begin Object Class=GUISectionBackground Name=PlayerPortraitB
         WinTop=0.432291
         WinLeft=0.489062
         WinWidth=0.163305
         WinHeight=0.443451
         OnPreDraw=PlayerPortraitB.InternalPreDraw
     End Object
     PlayerPortraitBG=GUISectionBackground'KFGui.LobbyMenu.PlayerPortraitB'

     IconBorder=0.050000
     ItemBorder=0.110000
     ProgressBarHeight=0.300000
     TextTopOffset=0.050000
     IconToInfoSpacing=0.050000
     ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
     ProgressBarForeground=Texture'InterfaceArt_tex.Menu.progress_bar'
     PerkBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
     InfoBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
     WaitingForServerStatus="Awaiting server status..."
     WaitingForOtherPlayers="Waiting for players to be ready..."
     AutoCommence="Game will auto-commence in"
     BeginnerString="Beginner"
     NormalString="Normal"
     HardString="Hard"
     SuicidalString="Suicidal"
     HellOnEarthString="Hell on Earth"
     SelectPerkInformationString="Perks enhance certain abilities of your character.|There are 6 Perks to choose from in the center of the screen.|Each has different Effects shown in the upper right.|Perks improve as you complete the Level Requirements shown on the right."
     PerksDisabledString="Perk Progress has been disabled because the Game Length is set to Custom, Sandbox Mode is on, or you have previously used Cheats."
     Begin Object Class=GUISectionBackground Name=ADBG
         WinTop=0.325208
         WinLeft=0.066797
         WinWidth=0.322595
         WinHeight=0.374505
         RenderWeight=0.300000
         OnPreDraw=ADBG.InternalPreDraw
     End Object
     ADBackground=GUISectionBackground'KFGui.LobbyMenu.ADBG'

     c_Tabs=GUITabControl'KFGui.GUILibraryMenu.PageTabs'

     Begin Object Class=GUIHeader Name=ServerBrowserHeader
         bVisible=False
     End Object
     t_Header=GUIHeader'KFGui.LobbyMenu.ServerBrowserHeader'

     Begin Object Class=LobbyFooter Name=BuyFooter
         RenderWeight=0.300000
         TabOrder=8
         bBoundToParent=False
         bScaleToParent=False
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=LobbyFooter'KFGui.LobbyMenu.BuyFooter'

     i_Background=None

     i_bkChar=None

     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=LobbyMenu.InternalOnClosed
     OnCanClose=LobbyMenu.StopClose
     WinHeight=0.500000
     OnPreDraw=LobbyMenu.InternalOnPreDraw
     OnRendered=LobbyMenu.DrawPerk
     OnKeyEvent=LobbyMenu.InternalOnKeyEvent
}
