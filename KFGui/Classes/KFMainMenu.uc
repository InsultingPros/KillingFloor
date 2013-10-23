class KFMainMenu extends UT2K4GUIPage;

//var KFDataObject SPAmmo;
var             bool        		bOpenAlready;
var             bool        		bMovingOnTraining,
									bMovingOnResume,
									bMovingOnSP;

var automated   FloatingImage		KFBackground;
var automated   FloatingImage		KFBackgroundOverlay;
var automated   GUIImage    		KFLogoBit;
var automated   GUILabel    		KFVersionNum;   // Keep track of updates from now on ! :D
var automated   GUILabel    		KFWorkshopDownload;

var	transient	bool				bOwnsWeaponDLC;
var transient   int                 WeaponDLCID;
var             int                 WeaponBundle;
var             array<int>          WeaponDLCs;
var automated	GUIImage    		KFWeaponDLCImage;
var automated	GUIImage    		KFWeaponDLCOverlay;
var 			Texture				KFWeaponDLCOwnedTexture;
var 			Texture				KFWeaponDLCOverlayTexture;
var 			Texture				KFWeaponDLCHoverTexture;

var	transient	bool				bOwnsCharacterDLC;
var automated   GUIImage    		KFCharacterDLCImage;
var automated   GUIImage    		KFCharacterDLCOverlay;
var 			Texture				KFCharacterDLCOwnedTexture;
var 			Texture				KFCharacterDLCOverlayTexture;
var 			Texture				KFCharacterDLCHoverTexture;

#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FIlE=2K4Menus.utx
#exec OBJ LOAD FIlE=2K4MenuSounds.uax

#exec OBJ LOAD FIlE=2K4Menus.utx
#exec OBJ LOAD FIlE=PatchTex.utx
#exec OBJ LOAD FIlE=KF_DLC.utx

#exec OBJ LOAD FIlE=KillingFloorHUD_HALLOWEEN.utx
#exec OBJ LOAD FIlE=KillingFloorHUD_XMAS.utx
/*
    Variable Name Legend

    l_  GUILabel            lb_ GUIListBox
    i_  GUIImage            li_ GUIList
    b_  GUIButton           tp_ GUITabPanel
    t_  GUITitleBar         sp_ GUISplitter
    c_  GUITabControl
    p_  GUIPanel

    ch_ moCheckBox
    co_ moComboBox
    nu_ moNumericEdit
    ed_ moEditBox
    fl_ moFloatEdit
    sl_ moSlider
*/

var automated   BackgroundImage 	i_BkChar,
                                	i_Background;
var automated	GUIImage        	i_UT2Logo,
                                	i_PanHuge,
                                	i_PanBig,
                                	i_PanSmall,
                                	i_UT2Shader,
                                	i_TV;
var automated   GUIButton   		b_SinglePlayer,
									b_MultiPlayer, b_Host,
                            		b_InstantAction,
									b_ModsAndDemo,
									b_Profile,
									b_DLC,
									b_Workshop,
									b_Settings,
									b_Quit;

var 			bool    			bAllowClose;

var 			array<material> 	CharShots;

var 			float 				CharFade,
									DesiredCharFade,
									CharFadeTime;

var 			GUIButton 			Selected;
var() 			bool 				bNoInitDelay;

var() config 	string 				MenuSong;

var 			bool 				bNewNews;
var 			float 				FadeTime;
var 			bool				FadeOut;

var localized 	string 				NewNewsMsg,
									FireWallTitle,
									FireWallMsg,
									SteamMustBeRunningText,
									UnknownSteamErrorText,
									DownloadingText,
									DownloadedText;

var globalconfig bool AcceptedEULA;

function int GetDLCListTextureIndex()
{
    local int i;
    for(i = 0; i < class'KFDLCList'.default.WeaponAppIDs.Length;i++)
    {
        if( WeaponDLCID == class'KFDLCList'.default.WeaponAppIDs[i] )
        {
            return i;
        }
    }
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int eventNum;
	Super.InitComponent(MyController, MyOwner);

   	Background = none;
    i_BkChar.Image = CharShots[rand(CharShots.Length)];

    WeaponDLCID = DetermineWeaponDLC();
	bOwnsWeaponDLC = PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC( WeaponDLCID );
	bOwnsCharacterDLC = PlayerOwner().CharacterAvailable("Reggie");

	eventNum = 0;//KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).Stat46.Value;

    if( eventNum == 2 )
    {
        KFBackground.Image = MaterialSequence'KillingFloorHUD_HALLOWEEN.MainMenu.kf_menu_seq_HALLOWEEN';
        KFLogoBit.Image = FinalBlend'KillingFloorHUD_HALLOWEEN.KFLogoFB_halloween';
    }
    else if( eventNum == 3 )
    {
        KFBackground.Image = MaterialSequence'KillingFloorHUD_XMAS.MainMenu.kf_menu_seq_XMAS';
        KFLogoBit.Image = FinalBlend'KillingFloorHUD_XMAS.KFLogoFB_XMAS';
    }
}

function int DetermineWeaponDLC()
{
   local int i;
   local array<int> dlcsAvailable;
   if( WeaponDLCs.Length == 1 )
   {
       return WeaponDLCs[0];
   }
   for( i = 0; i < WeaponDLCs.Length; i++ )
   {
       if( !PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(WeaponDLCs[i]) )
       {
          dlcsAvailable.Insert(0, 1);
          dlcsAvailable[0] = WeaponDLCs[i] ;
       }
   }


   if ( dlcsAvailable.Length == 0 || ( WeaponDLCs.Length == dlcsAvailable.Length  && dlcsAvailable.Length != 1) )
   {
        return WeaponBundle;
   }
   else
   {
       return dlcsAvailable[ rand( dlcsAvailable.Length ) ];
   }
}

function InternalOnOpen()
{
	if ( bNoInitDelay )
	{
		Timer();
	}
	else
	{
		SetTimer(4.5, false);
	}

	Controller.PerformRestore();

	/*if ( !PlayerOwner().level.game.IsA('KFCinematicGame') )
	{
		bOpenAlready = True;
		PlayerOwner().ConsoleCommand("OPEN Entry?Game=KFMod.KFCinematicGame");
		PlayerOwner().ClientSetInitialMusic(MenuSong,MTRAN_Segue);
	}*/

	PlayerOwner().ClientSetInitialMusic(MenuSong,MTRAN_Segue);

	// if this is the first time launching the game, show the EULA.
	if (!AcceptedEULA)
	{
	   Controller.OpenMenu("KFGui.KFEULA");
	}

	// Begin Syncing Subscribed Steam Workshop Files(if necessary)
	PlayerOwner().SyncSteamWorkshop();
}

function bool MyOnDraw(Canvas Canvas)
{
    local GUIButton FButton;
    local int i,x2;
    local float XL,YL;
    local float DeltaTime;
    local int percentage;

	if ( PlayerOwner().SubscribedFileDownloadTitle != "" )
	{
		if ( PlayerOwner().SubscribedFileDownloadIndex != -1 )
		{
		    percentage = int(PlayerOwner().DownloadFileProgress * 100);
			KFWorkshopDownload.Caption = DownloadingText @ "|" @ PlayerOwner().SubscribedFileDownloadTitle @  "|" @percentage $ "%";
		}
		else
		{
			KFWorkshopDownload.Caption = PlayerOwner().SubscribedFileDownloadTitle @ "|" @ DownloadedText;
		}
	}


    if ( bAnimating || !Controller.bCurMenuInitialized )
    {
	    return false;
	}

    DeltaTime = Controller.RenderDelta;

    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != None )
        {
            FButton = GUIButton(Controls[i]);

			if ( FButton.Tag > 0 && FButton.MenuState != MSAT_Focused )
            {
                FButton.Tag -= 784 * DeltaTime;

				if ( FButton.Tag < 0 )
				{
                    FButton.Tag = 0;
                }
            }
            else if ( FButton.MenuState == MSAT_Focused )
            {
                FButton.Tag = 200;
            }

            if ( FButton.Tag > 0 )
            {
                fButton.Style.TextSize(Canvas, MSAT_Focused, FButton.Caption, XL, YL, FButton.FontScale);
                x2 = FButton.ActualLeft() + XL + 16;
                Canvas.Style = 5;
                Canvas.SetDrawColor(150, 25, 25, FButton.Tag);
                Canvas.SetPos(0, fButton.ActualTop());
                Canvas.DrawTilePartialStretched(material'Highlight', x2, FButton.ActualHeight());
            }
        }
    }

    return false;
}

event Timer()
{
	if ( !bMovingOnTraining && !bMovingOnResume && !bMovingOnSP )
	{
		bNoInitDelay = true;

		if ( !Controller.bQuietMenu )
		{
		    PlayerOwner().PlaySound(SlideInSound,SLOT_None);
		}
		i_TV.Animate(-0.000977, 0.332292, 0.35);
		i_UT2Logo.Animate(0.007226,0.016926,0.35);
		i_UT2Shader.Animate(0.249023,0.180988,0.35);
		i_TV.OnEndAnimation = MenuIn_OnArrival;
		i_UT2Logo.OnEndAnimation = MenuIn_OnArrival;
		i_UT2Shader.OnEndAnimation = MenuIn_OnArrival;
	}
	else
	{
		if ( bMovingOnResume )
		{
			bMovingOnResume = false;
			Controller.ConsoleCommand("OPEN KFS-RESUMEGAME?Game=KFmod.KFSPGameType");
		}

		if (bMovingOnTraining)
		{
			bMovingOnTraining = false;
			Controller.ConsoleCommand("OPEN KF-MANOR?Game=KFmod.KFGameType");
		}

		if (bMovingOnSP)
		{
			bMovingOnSP = false;
			Controller.ConsoleCommand("OPEN KF-G-BIOTICSLAB?Game=KFmod.KFGameType");
		}
	}
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);

	if ( bOwnsWeaponDLC )
	{
		KFWeaponDLCImage.Image = KFWeaponDLCOwnedTexture;
		KFWeaponDLCOverlay.SetVisibility(false);
	}
	else
	{
	    if( WeaponDLCID != WeaponBundle )
	    {
	        KFWeaponDLCImage.Image = class'KFDLCList'.default.WeaponUnownedTextures[GetDLCListTextureIndex()];
	    }

	    KFWeaponDLCOverlay.SetVisibility(true);
	}

	if ( bOwnsCharacterDLC )
	{
		KFCharacterDLCImage.Image = KFCharacterDLCOwnedTexture;
		KFCharacterDLCOverlay.SetVisibility(false);
	}
}

function MoveOn()
{
	local int i;
	local bool bShowPerkInfo;

    switch (Selected)
    {
        case b_SinglePlayer:
            return;

        case b_MultiPlayer:
           	if( !Controller.CheckSteam() )
        	{
            	Controller.OpenMenu(Controller.QuestionMenuClass);
		    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
		    	return;
        	}

            Profile("ServerBrowser");
            Controller.OpenMenu("KFGUI.KFServerBrowser");
            Profile("ServerBrowser");
            return;

        case b_Host:
        	if( !Controller.CheckSteam() )
        	{
            	Controller.OpenMenu(Controller.QuestionMenuClass);
		    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
		    	return;
        	}

            Profile("MPHost");
        	if ( PlayerOwner() != none )
        	{
	            PlayerOwner().OpenUPNPPorts();
	        }
            Controller.OpenMenu("KFGUI.KFGamePageMP");
            Profile("MPHost");
            return;

        case b_InstantAction:
             Profile("InstantAction");
			 Controller.OpenMenu("KFGUI.KFGamePageSP");
             Profile("InstantAction");

            return;

		case b_Profile:
        	if( !Controller.CheckSteam() )
        	{
            	Controller.OpenMenu(Controller.QuestionMenuClass);
		    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SteamMustBeRunningText, QBTN_Ok, QBTN_Ok);
		    	return;
        	}

        	if ( PlayerOwner() != none )
        	{
        		if ( PlayerOwner().SteamStatsAndAchievements == none )
        		{
        			PlayerOwner().SteamStatsAndAchievements = PlayerOwner().Spawn(PlayerOwner().default.SteamStatsAndAchievementsClass, PlayerOwner());
					if ( !PlayerOwner().SteamStatsAndAchievements.Initialize(PlayerOwner()) )
					{
		            	Controller.OpenMenu(Controller.QuestionMenuClass);
				    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(UnknownSteamErrorText, QBTN_Ok, QBTN_Ok);
						PlayerOwner().SteamStatsAndAchievements.Destroy();
						PlayerOwner().SteamStatsAndAchievements = none;
        			}
        			else
        			{
        				PlayerOwner().SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
        			}

       				return;
        		}
	    		else if ( !PlayerOwner().SteamStatsAndAchievements.bInitialized )
	    		{
	   				PlayerOwner().SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
	   				PlayerOwner().SteamStatsAndAchievements.GetStatsAndAchievements();
	   				return;
	    		}

	    		for ( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; i++ )
	    		{
	    			if ( KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).GetPerkProgress(i) < 0.0 )
	    			{
		            	Controller.OpenMenu(Controller.QuestionMenuClass);
				    	GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'KFMainMenu'.default.UnknownSteamErrorText, QBTN_Ok, QBTN_Ok);
        				PlayerOwner().SteamStatsAndAchievements.OnDataInitialized = OnSteamStatsAndAchievementsReady;
	    				PlayerOwner().SteamStatsAndAchievements.GetStatsAndAchievements();
				    	return;
	    			}
	    		}

	    		if ( class'KFPlayerController'.default.SelectedVeterancy == none )
	    		{
	    			bShowPerkInfo = true;
	    		}

	            Profile("Profile");
	            Controller.OpenMenu("KFGUI.KFProfileAndAchievements");
	            Profile("Profile");

				if ( bShowPerkInfo )
				{
					Controller.OpenMenu(Controller.QuestionMenuClass);
					GUIQuestionPage(Controller.TopPage()).SetupQuestion(class'LobbyMenu'.default.SelectPerkInformationString, QBTN_Ok, QBTN_Ok);
				}
	        }

			return;

		case b_DLC:
            Profile("DLC");
            Controller.OpenMenu("KFGUI.KFDLCPage");
            Profile("DLC");
			return;

		case b_Workshop:
			PlayerOwner().SteamStatsAndAchievements.ShowWorkshopContent();
			return;

        case b_ModsAndDemo:
             Profile("ModsandDemos");

            Controller.ViewportOwner.Console.ConsoleCommand("OPEN KF-Intro?Game=unrealgame.cinematicgame");
            Controller.CloseAll(True);

            SetTimer(0.5,false);
            Profile("ModsandDemos");
            return;

        case b_Settings:
            Profile("Settings");
            Controller.OpenMenu("KFGUI.KFSettingsPage");
            Profile("Settings");
            return;

        case b_Quit:
            Profile("Quit");
            Controller.OpenMenu(Controller.GetQuitPage());
            Profile("Quit");
            return;

        default:
            StopWatch(True);
            break;
    }
}

function MenuIn_OnArrival(GUIComponent Sender, EAnimationType Type)
{
    Sender.OnArrival = none;
    if ( bAnimating )
        return;

    i_UT2Shader.OnDraw = MyOnDraw;
    DesiredCharFade=255;
    CharFadeTime = 0.75;

    if (!Controller.bQuietMenu)
        PlayerOwner().PlaySound(FadeInSound);
}

function MainReopened()
{
    if ( !PlayerOwner().Level.IsPendingConnection() )
    {
        i_BkChar.Image = CharShots[rand(CharShots.Length)];
        Opened(none);
        Timer();
    }
}


function OnClose(optional Bool bCancelled)
{
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
    if(Key == 0x1B && state == 1)   // Escape pressed
        bAllowClose = true;

    return false;
}

function bool CanClose(optional bool bCancelled)
{
    if(bAllowClose)
        ButtonClick(b_Quit);

    bAllowClose = False;
    return PlayerOwner().Level.IsPendingConnection();
}

function PlayPopSound(GUIComponent Sender, EAnimationType Type)
{
    if (!Controller.bQuietMenu)
        PlayerOwner().PlaySound(PopInSound);
}

function MenuIn_Done(GUIComponent Sender, EAnimationType Type)
{
    Sender.OnArrival = none;
    PlayPopSound(Sender,Type);
}


function bool ButtonClick(GUIComponent Sender)
{
    Selected = GUIButton(Sender);
    if (Selected==None)
        return false;

    DesiredCharFade=0;
    CharFadeTime = 0.35;

    MoveOn();

    return true;
}

function MenuOut_Done(GUIComponent Sender, EAnimationType Type)
{
    Sender.OnArrival = none;
    if ( bAnimating )
        return;

    MoveOn();
}

event bool NotifyLevelChange()
{
    if ( bDebugging )
        log(Name@"NotifyLevelChange  PendingConnection:"$PlayerOwner().Level.IsPendingConnection());

    return PlayerOwner().Level.IsPendingConnection();
}


function bool CommunityDraw(canvas c)
{
    local float x,y,xl,yl,a;
    if (bNewNews)
    {

        a = 255.0 * (FadeTime/1.0);
        if (FadeOut)
            a = 255 - a;

        FadeTime += Controller.RenderDelta;
        if (FadeTime>=1.0)
        {
            FadeTime = 0;
            FadeOut = !FadeOut;
        }

        a = fclamp(a,1.0,254.0);
        x = b_ModsAndDemo.ActualLeft();
        y = b_Settings.ActualTop();
        C.Font = Controller.GetMenuFont("UT2MenuFont").GetFont(C.ClipX);
        C.Strlen("Qz,q",xl,yl);
        y -= yl - 5;
        C.Style=5;
        C.SetPos(x+1,y+1);
        C.SetDrawColor(0,0,0,A);
        C.DrawText(NewNewsMsg);

        C.SetPos(x,y);
        C.SetDrawColor(207,185,103,A);
        C.DrawText(NewNewsMsg);
    }

    return false;
}

function OnSteamStatsAndAchievementsReady()
{
    Profile("Profile");
    Controller.OpenMenu("KFGUI.KFProfileAndAchievements");
    Profile("Profile");
}

function bool DLCButtonDraw(Canvas Canvas)
{
    local int index;
    index = GetDLCListTextureIndex();
	if ( !bOwnsWeaponDLC && KFWeaponDLCOverlayTexture != none && KFWeaponDLCHoverTexture != none )
	{
		if ( KFWeaponDLCImage.IsInBounds() )
		{
			if ( KFWeaponDLCOverlay.Image != KFWeaponDLCHoverTexture )
			{
				KFWeaponDLCOverlay.Image = KFWeaponDLCHoverTexture;
			}
		}
		else if ( KFWeaponDLCOverlay.Image != KFWeaponDLCOverlayTexture )
		{
		    if( WeaponDLCID != WeaponBundle )
		    {
		        KFWeaponDLCOverlay.Image = class'KFDLCList'.default.WeaponUnownedTextures[index];
		    }
			else
            {
                KFWeaponDLCOverlay.Image = KFWeaponDLCOverlayTexture;
            }
		}
	}

	if ( !bOwnsCharacterDLC && KFCharacterDLCOverlayTexture != none && KFCharacterDLCHoverTexture != none )
	{
		if ( KFCharacterDLCImage.IsInBounds() )
		{
			if ( KFCharacterDLCOverlay.Image != KFCharacterDLCHoverTexture )
			{
				KFCharacterDLCOverlay.Image = KFCharacterDLCHoverTexture;
			}
		}
		else if ( KFCharacterDLCOverlay.Image != KFCharacterDLCOverlayTexture )
		{
			KFCharacterDLCOverlay.Image = KFCharacterDLCOverlayTexture;
		}
	}

	return false;
}

function bool WeaponDLCButtonClicked(GUIComponent Sender)
{
	if ( !bOwnsWeaponDLC )
	{
		PlayerOwner().SteamStatsAndAchievements.PurchaseWeaponDLC(WeaponDLCID);
		return true;
	}

	return false;
}

function bool CharacterDLCButtonClicked(GUIComponent Sender)
{
	if ( !bOwnsCharacterDLC )
	{
		PlayerOwner().PurchaseCharacter("Reggie");
		return true;
	}

	return false;
}

defaultproperties
{
     Begin Object Class=FloatingImage Name=FloatingBackground
         Image=MaterialSequence'KillingFloorHUD.MainMenu.kf_menu_seq'
         DropShadow=None
         ImageStyle=ISTY_Scaled
         WinTop=0.136089
         WinLeft=0.273078
         WinWidth=0.802660
         WinHeight=1.080918
         RenderWeight=0.000003
     End Object
     KFBackground=FloatingImage'KFGui.KFMainMenu.FloatingBackground'

     Begin Object Class=FloatingImage Name=FloatingBackgroundOverlay
         Image=FinalBlend'InterfaceArt2_tex.filmgrain.FilmgrainOverlayFB'
         DropShadow=None
         ImageStyle=ISTY_Scaled
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.900000
     End Object
     KFBackgroundOverlay=FloatingImage'KFGui.KFMainMenu.FloatingBackgroundOverlay'

     Begin Object Class=GUIImage Name=KFMenuLogo
         Image=FinalBlend'KillingFloorHUD.KFLogoFB'
         ImageStyle=ISTY_Scaled
         WinTop=0.012000
         WinLeft=0.008000
         WinWidth=0.620000
         WinHeight=0.300000
         RenderWeight=0.050000
     End Object
     KFLogoBit=GUIImage'KFGui.KFMainMenu.KFMenuLogo'

     Begin Object Class=GUILabel Name=WorkshopDownloadLabel
         TextAlign=TXTA_Right
         TextColor=(B=200,G=200,R=200)
         bMultiLine=True
         FontScale=FNS_Small
         WinTop=0.050000
         WinLeft=0.690000
         WinWidth=0.150000
         WinHeight=0.150000
         RenderWeight=0.950000
     End Object
     KFWorkshopDownload=GUILabel'KFGui.KFMainMenu.WorkshopDownloadLabel'

     WeaponBundle=258751
     WeaponDLCs(0)=258751
     Begin Object Class=GUIImage Name=WeaponDLCImage
         Image=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_CamoWeaponPack'
         ImageStyle=ISTY_Scaled
         WinTop=0.651389
         WinLeft=0.053125
         WinWidth=0.168750
         WinHeight=0.148611
         RenderWeight=0.950000
         bAcceptsInput=True
         bNeverFocus=True
         OnClickSound=CS_Click
         OnDraw=KFMainMenu.DLCButtonDraw
         OnClick=KFMainMenu.WeaponDLCButtonClicked
     End Object
     KFWeaponDLCImage=GUIImage'KFGui.KFMainMenu.WeaponDLCImage'

     Begin Object Class=GUIImage Name=WeaponDLCOverlay
         Image=Texture'KF_DLC.Characters.UI_KFDLC_Unselected_BuyNow'
         ImageStyle=ISTY_Scaled
         WinTop=0.651389
         WinLeft=0.053125
         WinWidth=0.168750
         WinHeight=0.148611
         RenderWeight=0.960000
         bAcceptsInput=True
         bNeverFocus=True
         OnClickSound=CS_Click
         OnClick=KFMainMenu.WeaponDLCButtonClicked
     End Object
     KFWeaponDLCOverlay=GUIImage'KFGui.KFMainMenu.WeaponDLCOverlay'

     KFWeaponDLCOwnedTexture=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_UsVSThemWeaponPack'
     KFWeaponDLCOverlayTexture=Texture'KF_DLC.Characters.UI_KFDLC_Unselected_BuyNow'
     KFWeaponDLCHoverTexture=Texture'KF_DLC.Characters.UI_KFDLC_MouseOver_BuyNow'
     Begin Object Class=GUIImage Name=CharacterDLCImage
         Image=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Reggie'
         ImageStyle=ISTY_Scaled
         WinTop=0.811111
         WinLeft=0.053125
         WinWidth=0.168750
         WinHeight=0.148611
         RenderWeight=0.950000
         bAcceptsInput=True
         bNeverFocus=True
         OnClickSound=CS_Click
         OnClick=KFMainMenu.CharacterDLCButtonClicked
     End Object
     KFCharacterDLCImage=GUIImage'KFGui.KFMainMenu.CharacterDLCImage'

     Begin Object Class=GUIImage Name=CharacterDLCOverlay
         Image=Texture'KF_DLC.Characters.UI_KFDLC_Unselected_BuyNow'
         ImageStyle=ISTY_Scaled
         WinTop=0.811111
         WinLeft=0.053125
         WinWidth=0.168750
         WinHeight=0.148611
         RenderWeight=0.960000
         bAcceptsInput=True
         bNeverFocus=True
         OnClickSound=CS_Click
         OnClick=KFMainMenu.CharacterDLCButtonClicked
     End Object
     KFCharacterDLCOverlay=GUIImage'KFGui.KFMainMenu.CharacterDLCOverlay'

     KFCharacterDLCOwnedTexture=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Reggie'
     KFCharacterDLCOverlayTexture=Texture'KF_DLC.Characters.UI_KFDLC_Unselected_BuyNow'
     KFCharacterDLCHoverTexture=Texture'KF_DLC.Characters.UI_KFDLC_MouseOver_BuyNow'
     Begin Object Class=BackgroundImage Name=ImgBkChar
         ImageColor=(A=160)
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1024
         Y2=768
         RenderWeight=0.040000
         Tag=0
     End Object
     i_bkChar=BackgroundImage'KFGui.KFMainMenu.ImgBkChar'

     Begin Object Class=BackgroundImage Name=PageBackground
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1024
         Y2=768
     End Object
     i_Background=BackgroundImage'KFGui.KFMainMenu.PageBackground'

     Begin Object Class=GUIImage Name=ImgUT2Logo
     End Object
     i_UT2Logo=GUIImage'KFGui.KFMainMenu.ImgUT2Logo'

     Begin Object Class=GUIImage Name=iPanHuge
     End Object
     i_PanHuge=GUIImage'KFGui.KFMainMenu.iPanHuge'

     Begin Object Class=GUIImage Name=iPanBig
     End Object
     i_PanBig=GUIImage'KFGui.KFMainMenu.iPanBig'

     Begin Object Class=GUIImage Name=iPanSmall
     End Object
     i_PanSmall=GUIImage'KFGui.KFMainMenu.iPanSmall'

     Begin Object Class=GUIImage Name=ImgUT2Shader
     End Object
     i_UT2Shader=GUIImage'KFGui.KFMainMenu.ImgUT2Shader'

     Begin Object Class=GUIImage Name=ImgTV
     End Object
     i_TV=GUIImage'KFGui.KFMainMenu.ImgTV'

     Begin Object Class=GUIButton Name=MultiplayerButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Multiplayer"
         StyleName="ListSelection"
         Hint="All hell breaks loose..."
         WinTop=0.290000
         WinLeft=0.050000
         WinWidth=0.200000
         WinHeight=0.035000
         TabOrder=1
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=MultiplayerButton.InternalOnKeyEvent
     End Object
     b_MultiPlayer=GUIButton'KFGui.KFMainMenu.MultiplayerButton'

     Begin Object Class=GUIButton Name=HostButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Host Game"
         StyleName="ListSelection"
         Hint="Start a server and invite others to join your game"
         WinTop=0.325000
         WinLeft=0.050000
         WinWidth=0.200000
         WinHeight=0.035000
         TabOrder=2
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=HostButton.InternalOnKeyEvent
     End Object
     b_Host=GUIButton'KFGui.KFMainMenu.HostButton'

     Begin Object Class=GUIButton Name=InstantActionButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Solo"
         StyleName="ListSelection"
         Hint="Play Killing Floor Solo Mode"
         WinTop=0.360000
         WinLeft=0.050000
         WinWidth=0.200000
         TabOrder=3
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=InstantActionButton.InternalOnKeyEvent
     End Object
     b_InstantAction=GUIButton'KFGui.KFMainMenu.InstantActionButton'

     Begin Object Class=GUIButton Name=ProfileButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Profile and Achievements"
         StyleName="ListSelection"
         Hint="Your profile and achievements"
         WinTop=0.420000
         WinLeft=0.050000
         WinWidth=0.220000
         TabOrder=4
         bFocusOnWatch=True
         OnDraw=KFMainMenu.CommunityDraw
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=ModsAndDemosButton.InternalOnKeyEvent
     End Object
     b_Profile=GUIButton'KFGui.KFMainMenu.ProfileButton'

     Begin Object Class=GUIButton Name=DLCButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="DLC Content"
         StyleName="ListSelection"
         Hint="Weapon and Character DLC Packs"
         WinTop=0.455000
         WinLeft=0.050000
         WinWidth=0.220000
         TabOrder=4
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=ModsAndDemosButton.InternalOnKeyEvent
     End Object
     b_DLC=GUIButton'KFGui.KFMainMenu.DLCButton'

     Begin Object Class=GUIButton Name=WorkshopButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Steam Workshop Content"
         StyleName="ListSelection"
         Hint="Custom Content in the Steam Workshop"
         WinTop=0.490000
         WinLeft=0.050000
         WinWidth=0.220000
         TabOrder=4
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=ModsAndDemosButton.InternalOnKeyEvent
     End Object
     b_Workshop=GUIButton'KFGui.KFMainMenu.WorkshopButton'

     Begin Object Class=GUIButton Name=SettingsButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Settings"
         StyleName="ListSelection"
         Hint="Change your controls and settings"
         WinTop=0.550000
         WinLeft=0.050000
         WinWidth=0.200000
         WinHeight=0.035000
         TabOrder=6
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'KFGui.KFMainMenu.SettingsButton'

     Begin Object Class=GUIButton Name=QuitButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Exit"
         StyleName="ListSelection"
         Hint="Leave the game"
         WinTop=0.585000
         WinLeft=0.050000
         WinWidth=0.200000
         WinHeight=0.035000
         TabOrder=7
         bFocusOnWatch=True
         OnClick=KFMainMenu.ButtonClick
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'KFGui.KFMainMenu.QuitButton'

     MenuSong="KFMenu"
     SteamMustBeRunningText="Steam must be running and you must have an active internet connection to access this"
     UnknownSteamErrorText="Unknown Steam error prevented access to this"
     PopInSound=Sound'PatchSounds.slide1-1'
     SlideInSound=Sound'PatchSounds.slide1-1'
     BeepSound=Sound'KFWeaponSound.bullethitmetal3'
     bRenderWorld=True
     bPersistent=True
     OnOpen=KFMainMenu.InternalOnOpen
     OnReOpen=KFMainMenu.MainReopened
     OnCanClose=KFMainMenu.CanClose
     WinTop=0.000000
     WinHeight=1.000000
     OnKeyEvent=KFMainMenu.MyKeyEvent
}
