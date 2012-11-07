//=====================================================
// ROSettingsPage
// Last change: 07.1.2003
//
// Contains the settings page(s) for RO
// Copyright 2003 by Red Orchestra
//=====================================================

class ROSettingsPage extends GUIPage;

var localized string	VideoTabLabel,
						VideoTabHint,
						DetailsTabLabel,
						DetailsTabHint,
						AudioTabLabel,
						AudioTabHint,
						PlayerTabLabel,
						PlayerTabHint,
						NetworkTabLabel,
						NetworkTabHint,
						ControlsTabLabel,
						ControlsTabHint,
						IForceTabLabel,
						IForceTabHint,
						WeaponsTabLabel,
						WeaponsTabHint,
						GameTabLabel,
						GameTabHint,
                        HudTabLabel,
                        HudTabHint,
						SpeechBinderTabLabel,
						SpeechBinderTabHint;

//var Tab_WeaponPref 		pWeaponPref;
var Tab_PlayerSettings  pPlayer;
var Tab_NetworkSettings	pNetwork;

var float				SavedPitch;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local GUITabControl TabC;
	local rotator PlayerRot;
	local int i;


	Super.Initcomponent(MyController, MyOwner);

	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Pitch = 0;
	PlayerOwner().SetRotation(PlayerRot);

	TabC = GUITabControl(Controls[1]);
	GUITitleBar(Controls[0]).DockedTabs = TabC;

	TabC.AddTab(VideoTabLabel,"ROInterface.ROUT2K4Tab_DetailSettings",,VideoTabHint,true);
	TabC.AddTab(AudioTabLabel,"ROInterface.ROUT2K4Tab_AudioSettings",,AudioTabHint);
	pPlayer = Tab_PlayerSettings(TabC.AddTab(PlayerTabLabel,"ROInterface.ROUT2K4Tab_PlayerSettings",,PlayerTabHint));
	TabC.AddTab(IForceTabLabel,"ROInterface.ROUT2K4Tab_IForceSettings",,IForceTabHint);
    TabC.AddTab(HudTabLabel,"ROInterface.ROUT2K4Tab_HudSettings",,HudTabHint);
	TabC.AddTab(GameTabLabel,"ROInterface.ROUT2K4Tab_GameSettings",,GameTabHint);

    TabC.bFillSpace = True;

	// Change the Style of the Tabs; DRR 05-11-2004
	for ( i = 0; i < TabC.TabStack.Length; i++ )
	{
		if ( TabC.TabStack[i] != None )
		{
	        //TabC.TabStack[i].Style=None;   // needed to reset style
			TabC.TabStack[i].FontScale=FNS_Medium;
			TabC.TabStack[i].bAutoSize=True;
			TabC.TabStack[i].bAutoShrink=False;
			//TabC.TabStack[i].StyleName="ROTabButton";
			//TabC.TabStack[i].Initcomponent(MyController, TabC);
        }
	}

}

function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	GUITitleBar(Controls[0]).Caption = GUITitleBar(default.Controls[0]).Caption@"|"@GUITabButton(Sender).Caption;
}

event ChangeHint(string NewHint)
{
	GUITitleBar(Controls[2]).Caption = NewHint;
}


function InternalOnReOpen()
{
	local GUITabControl TabC;
	TabC = GUITabControl(Controls[1]);

	if ( (TabC.ActiveTab!=None) && (TabC.ActiveTab.MyPanel!=None) )
		TabC.ActiveTab.MyPanel.Refresh();
}

function bool ButtonClicked(GUIComponent Sender)
{
	if(InternalOnCanClose(false))
    {
    	GUITabControl(Controls[1]).ActiveTab.OnDeActivate();
		Controller.CloseMenu(true);
    }

	return true;
}

function bool InternalOnCanClose(optional bool bCanceled)
{

// May want to re-add this check at some point Puma 5-14-2004
//	if(!pNetwork.ValidStatConfig())
//	{
//		GUITabControl(Controls[1]).ActivateTabByName(NetworkTabLabel,true);
//		return false;
//	}
//	else
		return true;
}

function bool NotifyLevelChange()
{
	LevelChanged(); // I added this from the 2K4 code, it might break something - Antarian 3/20/04

	Controller.CloseMenu(true);
	return true;
}

function InternalOnClose(optional Bool bCanceled)
{
	local rotator NewRot;

	// Destroy spinning player model actor
	if(pPlayer.SpinnyDude != None)
	{
		pPlayer.SpinnyDude.Destroy();
		pPlayer.SpinnyDude = None;
	}

	// Reset player
	NewRot = PlayerOwner().Rotation;
	NewRot.Pitch = SavedPitch;
	PlayerOwner().SetRotation(NewRot);

	// Save config.
	pNetwork.ApplyStatConfig();
	pPlayer.InternalApply(none);
	//pWeaponPref.WeapApply(none);

	Super.OnClose(bCanceled);
}

defaultproperties
{
     VideoTabLabel="Video"
     VideoTabHint="Select your resolution and change your brightness..."
     DetailsTabLabel="Details"
     DetailsTabHint="Adjust the detail settings for better graphics or faster framerate..."
     AudioTabLabel="Audio"
     AudioTabHint="Adjust your audio experience..."
     PlayerTabLabel="Player"
     PlayerTabHint="Configure your Red Orchestra Avatar..."
     NetworkTabLabel="Network"
     NetworkTabHint="Configure Red Orchestra for Online and Lan play..."
     ControlsTabLabel="Controls"
     ControlsTabHint="Configure your controls..."
     IForceTabLabel="Input"
     IForceTabHint="Configure misc. input options..."
     WeaponsTabLabel="Weapons"
     WeaponsTabHint="Adjust your weapon priorities and settings..."
     GameTabLabel="Game"
     GameTabHint="Adjust various game releated settings..."
     HudTabLabel="Hud"
     HudTabHint="Customize your hud..."
     SpeechBinderTabLabel="Speech"
     SpeechBinderTabHint="Bind messages to keys..."
     Background=Texture'menuBackground.MainBackGround'
     OnReOpen=ROSettingsPage.InternalOnReOpen
     OnClose=ROSettingsPage.InternalOnClose
     OnCanClose=ROSettingsPage.InternalOnCanClose
     Begin Object Class=GUITitleBar Name=SettingHeader
         Effect=Texture'InterfaceArt_tex.Menu.changeme_texture'
         Caption="Configuration"
         StyleName="ROHeader"
         WinTop=0.020000
         WinHeight=0.500000
     End Object
     Controls(0)=GUITitleBar'ROInterface.ROSettingsPage.SettingHeader'

     Begin Object Class=GUITabControl Name=SettingTabs
         bDockPanels=True
         TabHeight=0.060000
         WinTop=0.067000
         WinLeft=0.020000
         WinHeight=58.000000
         bAcceptsInput=True
         OnActivate=SettingTabs.InternalOnActivate
         OnChange=ROSettingsPage.TabChange
     End Object
     Controls(1)=GUITabControl'ROInterface.ROSettingsPage.SettingTabs'

     Begin Object Class=GUITitleBar Name=SettingFooter
         bUseTextHeight=False
         StyleName="ROFooter"
         WinTop=0.930000
         WinLeft=0.120000
         WinWidth=0.880000
         WinHeight=0.055000
     End Object
     Controls(2)=GUITitleBar'ROInterface.ROSettingsPage.SettingFooter'

     Begin Object Class=GUIButton Name=BackButton
         Caption="Back"
         StyleName="ROSquareMenuButton"
         Hint="Return to Previous Menu"
         WinTop=0.930000
         WinWidth=0.120000
         WinHeight=0.055000
         OnClick=ROSettingsPage.ButtonClicked
         OnKeyEvent=BackButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'ROInterface.ROSettingsPage.BackButton'

     Begin Object Class=GUIImage Name=LogoSymbol
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         WinTop=0.800782
         WinLeft=0.830079
         WinWidth=0.260000
         WinHeight=0.130000
         bVisible=False
     End Object
     Controls(4)=GUIImage'ROInterface.ROSettingsPage.LogoSymbol'

     WinHeight=1.000000
}
