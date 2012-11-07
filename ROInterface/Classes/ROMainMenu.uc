//=====================================================
// ROMainMenu
// Last change: 05.1.2003
//
// Contains the main menu for RO
// Copyright 2003 by Red Orchestra
// $Id: ROMainMenu.uc,v 1.16 2004/11/09 22:46:59 puma Exp $:
//=====================================================

class ROMainMenu extends UT2K4GUIPage;

//var automated   FloatingImage i_background, i_background2;
var automated   FloatingImage i_background;

var automated   GUISectionBackground sb_MainMenu;
var automated 	GUIButton	b_MultiPlayer, b_Practice, b_Settings, b_Help, b_Host, b_Quit;

var automated   GUISectionBackground sb_HelpMenu;
var automated   GUIButton   b_Credits, b_Manual, b_Demos, b_Website, b_Back;


var bool	    AllowClose;
var localized string      ManualURL;
var string      WebsiteURL;

var localized string SteamMustBeRunningText;
var localized string SinglePlayerDisabledText;

//var string MenuLevelName;

var() config string MenuSong;

var globalconfig bool AcceptedEULA;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int xl,yl,y;


	//MyController.RegisterStyle(class'ROSTY_RoundScaledButton');

	// G15 Support
	Super.InitComponent(MyController, MyOwner);

	Controller.LCDCls();
	Controller.LCDDrawTile(Controller.LCDLogo,0,0,50,43,0,0,50,43);

	y = 0;
	Controller.LCDStrLen("Red Orchestra",Controller.LCDMedFont,xl,yl);
	Controller.LCDDrawText("Red Orchestra",(100-(XL/2)),y,Controller.LCDMedFont);
	y += 14;
	Controller.LCDStrLen("Ostfront",Controller.LCDSmallFont,xl,yl);
	Controller.LCDDrawText("Ostfront",(100-(XL/2)),y,Controller.LCDSmallFont);

	y += 14;
	Controller.LCDStrLen("41-45",Controller.LCDLargeFont,xl,yl);
	Controller.LCDDrawText("41-45",(100-(XL/2)),y,Controller.LCDLargeFont);

	Controller.LCDRepaint();
	// end G15 support

	sb_MainMenu.ManageComponent(b_MultiPlayer);
	sb_MainMenu.ManageComponent(b_Practice);
	sb_MainMenu.ManageComponent(b_Settings);
	sb_MainMenu.ManageComponent(b_Help);
	sb_MainMenu.ManageComponent(b_Host);
	sb_MainMenu.ManageComponent(b_Quit);

	sb_HelpMenu.ManageComponent(b_Credits);
	sb_HelpMenu.ManageComponent(b_Manual);
	sb_HelpMenu.ManageComponent(b_Demos);
	sb_HelpMenu.ManageComponent(b_Website);
	sb_HelpMenu.ManageComponent(b_Back);

	/*if (PlayerOwner().Level.IsDemoBuild())
	{
		Controls[3].SetFocus(none);
		Controls[2].MenuStateChange(MSAT_Disabled);
	}*/
}

function InternalOnOpen()
{
    log("MainMenu: starting music "$MenuSong);
    PlayerOwner().ClientSetInitialMusic(MenuSong,MTRAN_Segue);


	// if this is the first time launching the game, show the EULA.
	if (!AcceptedEULA)
	{
	   Controller.OpenMenu("ROInterface.ROEULA");
	}
}


function OnClose(optional Bool bCanceled) {
}

// menu ids:
// 0 - main menu
// 1 - help menu
function ShowSubMenu(int menu_id)
{
    switch (menu_id)
    {
        case 0:
            sb_MainMenu.SetVisibility(true);
            sb_HelpMenu.SetVisibility(false);
            break;

        case 1:
            sb_MainMenu.SetVisibility(false);
            sb_HelpMenu.SetVisibility(true);
            break;
    }
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
	if(Key == 0x1B && State == 1)	// Escape pressed
	{
		AllowClose = true;
		return true;
	}
	else
		return false;
}

function bool CanClose(optional Bool bCanceled)
{
	if (AllowClose)
		Controller.OpenMenu(Controller.GetQuitPage());

	return false;
}


function bool ButtonClick(GUIComponent Sender)
{
    local GUIButton selected;
    if (GUIButton(Sender) != None)
		selected = GUIButton(Sender);

	switch (sender)
	{
        case b_Practice:
        	if ( class'LevelInfo'.static.IsDemoBuild() )
        	{
	    		Controller.OpenMenu(Controller.QuestionMenuClass);
				GUIQuestionPage(Controller.TopPage()).SetupQuestion(SinglePlayerDisabledText, QBTN_Ok, QBTN_Ok);
        	}
        	else
        	{
	            Profile("InstantAction");
	    		Controller.OpenMenu(Controller.GetInstantActionPage());
	    		Profile("InstantAction");
    		}
            break;

        case b_MultiPlayer:
        	if( !Controller.CheckSteam() )
        	{
            	Controller.OpenMenu(Controller.QuestionMenuClass);
		    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
        	}
        	else
        	{
	            Profile("ServerBrowser");
				Controller.OpenMenu(Controller.GetServerBrowserPage());
				Profile("ServerBrowser");
        	}
			break;

		case b_Host:
        	if( !Controller.CheckSteam() )
        	{
            	Controller.OpenMenu(Controller.QuestionMenuClass);
		    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
        	}
        	else
        	{
		        Profile("MPHost");
				Controller.OpenMenu(Controller.GetMultiplayerPage());
				Profile("MPHost");
        	}
 	        break;

	    case b_Settings:
            Profile("Settings");
     	    Controller.OpenMenu(Controller.GetSettingsPage());
    		Profile("Settings");
    		break;

    	case b_Credits:
    	    Controller.OpenMenu("ROInterface.ROCreditsPage");
    	    break;

        case b_Quit:
            Profile("Quit");
    		Controller.OpenMenu(Controller.GetQuitPage());
    		Profile("Quit");
    		break;

        case b_Manual:
            Profile("Manual");
            PlayerOwner().ConsoleCommand("start "@ManualURL);
    		Profile("Manual");
    		break;

    	case b_Website:
    	    Profile("Website");
            PlayerOwner().ConsoleCommand("start "@WebsiteURL);
    		Profile("Website");
    		break;

    	case b_Demos:
    	    Controller.OpenMenu("ROInterface.RODemosMenu");
    	    break;

    	case b_Help:
    	    ShowSubMenu(1);
    	    break;

    	case b_Back:
    	    ShowSubMenu(0);
    	    break;

	}

    /*
	if ( Sender == b_ModsAndDemo )
	{
			Profile("ModsandDemos");
			Controller.OpenMenu(Controller.GetModPage());
     		profile("ModsandDemos");
	}
	*/

	return true;
}

event Opened(GUIComponent Sender)
{

	if ( bDebugging )
		log(Name$".Opened()   Sender:"$Sender,'Debug');

    if ( Sender != None && PlayerOwner().Level.IsPendingConnection() )
    	PlayerOwner().ConsoleCommand("CANCEL");

    ShowSubMenu(0);

    //log("Current level.outer = " $ string(PlayerOwner().level.outer));

    /*if (PlayerOwner().Level.game == none ||
        !PlayerOwner().Level.game.isa('ROMainMenuGame'))
    {
        log("Loading main menu level...");
        LoadMenuLevel();
        Super.Opened(Sender);
        Controller.bCurMenuInitialized = true; // hax!
        Controller.CloseAll(false, true); // Close all menus so that the level isn`t disconnected
        return;
    }*/

    //log("Current level.outer = " $ string(PlayerOwner().level.outer));

    Super.Opened(Sender);
}

function LoadMenuLevel()
{
    //log("LoadMenuLevel called.");
    //PlayerOwner().ClientTravel(MenuLevelName $ "?game=ROInterface.ROMainMenuGame", TRAVEL_Absolute, False);
    //PlayerOwner().ConsoleCommand("switchlevel " $ MenuLevelName);
    //PlayerOwner().Level.ServerTravel(MenuLevelName $ "?game=ROInterface.ROMainMenuGame", false);
    //Console(Controller.Master.Console).DelayedConsoleCommand("start" @ MenuLevelName $ "?game=ROInterface.ROMainMenuGame");
}

event bool NotifyLevelChange()
{
	if ( bDebugging )
		log(Name@"NotifyLevelChange  PendingConnection:"$PlayerOwner().Level.IsPendingConnection());

	return PlayerOwner().Level.IsPendingConnection();
}

defaultproperties
{
     Begin Object Class=FloatingImage Name=FloatingBackground
         Image=Texture'menuBackground.MainBackGround'
         DropShadow=None
         ImageStyle=ISTY_Scaled
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.000003
     End Object
     i_Background=FloatingImage'ROInterface.ROMainMenu.FloatingBackground'

     Begin Object Class=ROGUIContainerNoSkinAlt Name=sbSection1
         WinTop=0.694000
         WinLeft=0.021875
         WinWidth=0.485000
         WinHeight=0.281354
         OnPreDraw=sbSection1.InternalPreDraw
     End Object
     sb_MainMenu=ROGUIContainerNoSkinAlt'ROInterface.ROMainMenu.sbSection1'

     Begin Object Class=GUIButton Name=ServerButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Multiplayer"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Play a multiplayer match"
         TabOrder=1
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=ServerButton.InternalOnKeyEvent
     End Object
     b_MultiPlayer=GUIButton'ROInterface.ROMainMenu.ServerButton'

     Begin Object Class=GUIButton Name=InstantActionButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Practice"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Play a practice match"
         TabOrder=2
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
     End Object
     b_Practice=GUIButton'ROInterface.ROMainMenu.InstantActionButton'

     Begin Object Class=GUIButton Name=SettingsButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Configuration"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Configuration settings"
         TabOrder=3
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'ROInterface.ROMainMenu.SettingsButton'

     Begin Object Class=GUIButton Name=HelpButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Help & Game Management"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Help and Game Management utilities"
         TabOrder=4
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=HelpButton.InternalOnKeyEvent
     End Object
     b_Help=GUIButton'ROInterface.ROMainMenu.HelpButton'

     Begin Object Class=GUIButton Name=HostButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Host Game"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Host Your Own Server"
         TabOrder=5
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=HostButton.InternalOnKeyEvent
     End Object
     b_Host=GUIButton'ROInterface.ROMainMenu.HostButton'

     Begin Object Class=GUIButton Name=QuitButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Exit"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Exit the game"
         TabOrder=6
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'ROInterface.ROMainMenu.QuitButton'

     Begin Object Class=ROGUIContainerNoSkinAlt Name=sbSection2
         WinTop=0.694000
         WinLeft=0.021875
         WinWidth=0.485000
         WinHeight=0.240728
         OnPreDraw=sbSection2.InternalPreDraw
     End Object
     sb_HelpMenu=ROGUIContainerNoSkinAlt'ROInterface.ROMainMenu.sbSection2'

     Begin Object Class=GUIButton Name=CreditsButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Credits"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="View the Credits"
         TabOrder=11
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=CreditsButton.InternalOnKeyEvent
     End Object
     b_Credits=GUIButton'ROInterface.ROMainMenu.CreditsButton'

     Begin Object Class=GUIButton Name=ManualButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Manual"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Read the Manual"
         TabOrder=12
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=ManualButton.InternalOnKeyEvent
     End Object
     b_Manual=GUIButton'ROInterface.ROMainMenu.ManualButton'

     Begin Object Class=GUIButton Name=DemosButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Demo Management"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Manage recorded demos"
         TabOrder=12
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=DemosButton.InternalOnKeyEvent
     End Object
     b_Demos=GUIButton'ROInterface.ROMainMenu.DemosButton'

     Begin Object Class=GUIButton Name=WebsiteButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Visit Website"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Visit the official Red Orchestra website"
         TabOrder=12
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=WebsiteButton.InternalOnKeyEvent
     End Object
     b_Website=GUIButton'ROInterface.ROMainMenu.WebsiteButton'

     Begin Object Class=GUIButton Name=BackButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Back"
         bAutoShrink=False
         bUseCaptionHeight=True
         FontScale=FNS_Large
         StyleName="TextButton"
         Hint="Return to Main Menu"
         TabOrder=12
         bFocusOnWatch=True
         OnClick=ROMainMenu.ButtonClick
         OnKeyEvent=BackButton.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'ROInterface.ROMainMenu.BackButton'

     ManualURL="http://www.redorchestragame.com/downloads/manuals/Game_Manual.pdf"
     WebsiteURL="http://www.redorchestragame.com/"
     SteamMustBeRunningText="Steam must be running and you must have an active internet connection to play multiplayer"
     SinglePlayerDisabledText="Practice mode is only available in the full version."
     MenuSong="RO_Eastern_Front"
     BackgroundColor=(B=0,R=0)
     InactiveFadeColor=(B=0,G=0,R=255)
     OnOpen=ROMainMenu.InternalOnOpen
     WinTop=0.000000
     WinHeight=1.000000
}
