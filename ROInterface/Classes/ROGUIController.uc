// ====================================================================
//  Class:  Engine.GUIController
//
//  The GUIController is a simple FILO menu stack.  You have 3 things
//  you can do.  You can Open a menu which adds the menu to the top of the
//  stack.  You can Replace a menu which replaces the current menu with the
//  new menu.  And you can close a menu, which returns you to the last menu
//  on the stack.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class ROGUIController extends UT2K4GUIController;

var                     Array<string>       RODefaultStyleNames;      // Holds the name of all styles to use

event InitializeController()
{
    Super.InitializeController();

    RegisterStyle(class'ROInterface.ROSTY2_ImageButton');
    RegisterStyle(class'ROInterface.ROSTY2SelectButton');
    RegisterStyle(class'ROInterface.ROSTY2SelectTab');
    RegisterStyle(class'ROInterface.ROSTY_CaptionLabel');

    // RO Menu styles
	/*RegisterStyle(class'ROInterface.ROSTY_SquareMenuButton');
	RegisterStyle(class'ROInterface.ROSTY_Header');
	RegisterStyle(class'ROInterface.ROSTY_Footer');
	RegisterStyle(class'ROInterface.ROSTY_TextLabel');
	RegisterStyle(class'ROInterface.ROSTY_TabButton');
	RegisterStyle(class'ROInterface.ROSTY2ComboListBox');
	RegisterStyle(class'ROInterface.ROSTY_ListBox');
	RegisterStyle(class'ROInterface.ROSTY2RoundScaledButton');
	RegisterStyle(class'ROInterface.ROSTY2ScrollButtons');
	RegisterStyle(class'ROInterface.ROSTY2ListSectionHeader');
	RegisterStyle(class'ROInterface.ROSTY2EditBox');
	RegisterStyle(class'ROInterface.ROSTY2CheckBox');
	RegisterStyle(class'ROInterface.ROSTY2SliderKnob');
	RegisterStyle(class'ROInterface.ROSTY2SliderBar');
	RegisterStyle(class'ROInterface.ROSTY2Header');
	RegisterStyle(class'ROInterface.ROSTY_TitleBar');
	RegisterStyle(class'ROInterface.ROSTY2SquareButton');
	RegisterStyle(class'ROInterface.ROSTY2Spinner');
	RegisterStyle(class'ROInterface.ROSTY2ScrollZone');
	RegisterStyle(class'ROInterface.ROSTY2SectionHeaderBar');
	RegisterStyle(class'ROInterface.ROSTY2SectionHeader2Bar');
	RegisterStyle(class'ROInterface.ROSTY2SectionHeaderTop');
	RegisterStyle(class'ROInterface.ROSTY2SectionHeader2Top');
	RegisterStyle(class'ROInterface.ROSTY2ItemOutline');
	RegisterStyle(class'ROInterface.ROSTY_ListSelection');
	RegisterStyle(class'ROInterface.ROSTY2FooterButton');
	RegisterStyle(class'ROInterface.ROSTY2TextButton');
	RegisterStyle(class'ROInterface.ROSTY2TextButtonEffect');
	RegisterStyle(class'ROInterface.ROSTY_RoundScaledButton');*/


    // Hack to force the last Game Type to ROTeamGame
    // Puma 5-25-2004
	LastGameType="ROEngine.ROTeamGame";
	log("ROGUIController initialized ");
}

// this function removed all Mod defined styles
function PurgeObjectReferences()
{
}

// Should override this function if you have less options in your custom start menu
static simulated event Validate()
{
	if ( default.MainMenuOptions.Length < 5 )
		ResetConfig();
}

static simulated function string GetServerBrowserPage()
{
	Validate();
	return default.MainMenuOptions[0];
}

static simulated function string GetMultiplayerPage()
{
	Validate();
	return default.MainMenuOptions[1];
}

static simulated function string GetInstantActionPage()
{
	Validate();
	return default.MainMenuOptions[2];
}

static simulated function string GetSettingsPage()
{
	Validate();
	return default.MainMenuOptions[3];
}

static simulated function string GetQuitPage()
{
	Validate();
	return default.MainMenuOptions[4];
}




/*defaultproperties {

    FONT_NUM=3
    STYLE_NUM=32

	Begin Object Class=ROLargeFont Name=ROGUILargeFont
		bScaled=True
		Name="ROGUILargeFont"
		NormalXRes=640
        FallBackRes=512
	End Object
	FontStack(0)=ROLargeFont'ROGUILargeFont'

	Begin Object Class=ROHeaderFont Name=ROGUIHeaderFont
		bScaled=True
		Name="ROGUIHeaderFont"
		NormalXRes=640
        FallBackRes=512
	End Object
	FontStack(1)=ROHeaderFont'ROGUIHeaderFont'

	Begin Object Class=ROSmallFont Name=ROGUISmallFont
		bScaled=True
		Name="ROGUISmallFont"
		NormalXRes=640
        FallBackRes=512
	End Object
	FontStack(2)=ROSmallFont'ROGUISmallFont'

	DefaultStyleNames(0)="ROInterface.ROSTY_RoundButton"
	DefaultStyleNames(1)="ROInterface.ROSTY_RoundScaledButton"
	DefaultStyleNames(2)="ROInterface.ROSTY_SquareButton"
	DefaultStyleNames(3)="ROInterface.ROSTY_ListBox"
	DefaultStyleNames(4)="ROInterface.ROSTY_ScrollZone"
	DefaultStyleNames(5)="ROInterface.ROSTY_TextButton"
	DefaultStyleNames(6)="xinterface.STY_Page"
	DefaultStyleNames(7)="ROInterface.ROSTY_Header"
	DefaultStyleNames(8)="ROInterface.ROSTY_Footer"
	DefaultStyleNames(9)="ROInterface.ROSTY_TabButton"
	DefaultStyleNames(10)="ROInterface.ROSTY_CharButton"
	DefaultStyleNames(11)="xinterface.STY_ArrowLeft"
	DefaultStyleNames(12)="xinterface.STY_ArrowRight"
	DefaultStyleNames(13)="ROInterface.ROSTY_ServerBrowserGrid"
	DefaultStyleNames(14)="xinterface.STY_NoBackground"
	DefaultStyleNames(15)="ROInterface.ROSTY_ServerBrowserGridHeader"
	DefaultStyleNames(16)="xinterface.STY_SliderCaption"
	DefaultStyleNames(17)="xinterface.STY_LadderButton"
	DefaultStyleNames(18)="xinterface.STY_LadderButtonHi"
	DefaultStyleNames(19)="XInterface.STY_LadderButtonActive"
	DefaultStyleNames(20)="xinterface.STY_BindBox"
	DefaultStyleNames(21)="ROInterface.ROSTY_SquareBar"
	DefaultStyleNames(22)="ROInterface.ROSTY_MidGameButton"
	DefaultStyleNames(23)="ROInterface.ROSTY_TextLabel"
	DefaultStyleNames(24)="ROInterface.ROSTY_ComboListBox"
	DefaultStyleNames(25)="ROInterface.ROSTY_SquareMenuButton"
	DefaultStyleNames(26)="xinterface.STY_IRCText"
	DefaultStyleNames(27)="xinterface.STY_IRCEntry"
    DefaultStyleNames(28)="xinterface.STY_MedHeader"
	DefaultStyleNames(29)="ROInterface.ROSTY_HeaderText"
	DefaultStyleNames(30)="ROInterface.ROSTY_TextBox"
	DefaultStyleNames(31)="ROInterface.ROSTY_TitleBar"

	MouseOverSound=sound'ROMiscsounds_old.Menu.over'
	ClickSound=sound'ROMiscsounds_old.Menu.Enter'
	EditSound=sound'ROMiscsounds_old.Menu.Move'
	UpSound=sound'ROMiscsounds_old.Menu.moveup'
	DownSound=sound'ROMiscsounds_old.Menu.movedown'
}   */

defaultproperties
{
     FontStack(0)=fntUT2k4Menu'ROInterface.ROGUIController.GUIMenuFont'
     FontStack(1)=fntUT2k4Default'ROInterface.ROGUIController.GUIDefaultFont'
     FontStack(2)=fntUT2k4Large'ROInterface.ROGUIController.GUILargeFont'
     FontStack(3)=fntUT2k4Header'ROInterface.ROGUIController.GUIHeaderFont'
     FontStack(4)=fntUT2k4Small'ROInterface.ROGUIController.GUISmallFont'
     FontStack(5)=fntUT2k4MidGame'ROInterface.ROGUIController.GUIMidGameFont'
     FontStack(6)=fntUT2k4SmallHeader'ROInterface.ROGUIController.GUISmallHeaderFont'
     FontStack(7)=fntUT2k4ServerList'ROInterface.ROGUIController.GUIServerListFont'
     FontStack(8)=fntUT2k4IRC'ROInterface.ROGUIController.GUIIRCFont'
     FontStack(9)=fntROMainMenu'ROInterface.ROGUIController.GUIMainMenuFont'
     FontStack(10)=fntUT2K4Medium'ROInterface.ROGUIController.GUIMediumMenuFont'
     MouseCursors(0)=Texture'InterfaceArt_tex.Cursors.Pointer'
     MouseCursors(1)=Texture'InterfaceArt_tex.Cursors.ResizeAll'
     MouseCursors(2)=Texture'InterfaceArt_tex.Cursors.ResizeSWNE'
     MouseCursors(3)=Texture'InterfaceArt_tex.Cursors.Resize'
     MouseCursors(4)=Texture'InterfaceArt_tex.Cursors.ResizeNWSE'
     MouseCursors(5)=Texture'InterfaceArt_tex.Cursors.ResizeHorz'
     MouseCursors(6)=Texture'InterfaceArt_tex.Cursors.Pointer'
     ImageList(0)=Texture'InterfaceArt_tex.Menu.checkBoxBall_b'
     ImageList(1)=Texture'InterfaceArt_tex.Menu.AltComboTickBlurry'
     ImageList(2)=Texture'InterfaceArt_tex.Menu.LeftMark'
     ImageList(3)=Texture'InterfaceArt_tex.Menu.RightMark'
     ImageList(4)=Texture'InterfaceArt_tex.Menu.RightMark'
     ImageList(5)=Texture'InterfaceArt_tex.Menu.RightMark'
     ImageList(6)=Texture'InterfaceArt_tex.Menu.UpMark'
     ImageList(7)=Texture'InterfaceArt_tex.Menu.DownMark'
     DefaultStyleNames(1)="ROInterface.ROSTY_RoundScaledButton"
     DefaultStyleNames(2)="ROInterface.ROSTY2SquareButton"
     DefaultStyleNames(3)="ROInterface.ROSTY_ListBox"
     DefaultStyleNames(4)="ROInterface.ROSTY2ScrollZone"
     DefaultStyleNames(5)="ROInterface.ROSTY2TextButton"
     DefaultStyleNames(7)="ROInterface.ROSTY2Header"
     DefaultStyleNames(8)="ROInterface.ROSTY_Footer"
     DefaultStyleNames(9)="ROInterface.ROSTY_TabButton"
     DefaultStyleNames(13)="ROInterface.ROSTY_ServerBrowserGrid"
     DefaultStyleNames(15)="ROInterface.ROSTY_ServerBrowserGridHeader"
     DefaultStyleNames(21)="ROInterface.ROSTY_SquareBar"
     DefaultStyleNames(22)="ROInterface.ROSTY_MidGameButton"
     DefaultStyleNames(23)="ROInterface.ROSTY_TextLabel"
     DefaultStyleNames(24)="ROInterface.ROSTY2ComboListBox"
     DefaultStyleNames(26)="ROInterface.ROSTY2IRCText"
     DefaultStyleNames(27)="ROInterface.ROSTY2IRCEntry"
     DefaultStyleNames(29)="ROInterface.ROSTY2ContextMenu"
     DefaultStyleNames(30)="ROInterface.ROSTY2ServerListContextMenu"
     DefaultStyleNames(31)="ROInterface.ROSTY_ListSelection"
     DefaultStyleNames(32)="ROInterface.ROSTY2TabBackground"
     DefaultStyleNames(33)="ROInterface.ROSTY_BrowserListSel"
     DefaultStyleNames(34)="ROInterface.ROSTY2EditBox"
     DefaultStyleNames(35)="ROInterface.ROSTY2CheckBox"
     DefaultStyleNames(37)="ROInterface.ROSTY2SliderKnob"
     DefaultStyleNames(39)="ROInterface.ROSTY2ListSectionHeader"
     DefaultStyleNames(40)="ROInterface.ROSTY2ItemOutline"
     DefaultStyleNames(42)="ROInterface.ROSTY2MouseOverLabel"
     DefaultStyleNames(43)="ROInterface.ROSTY2SliderBar"
     DefaultStyleNames(45)="ROInterface.ROSTY2TextButtonEffect"
     DefaultStyleNames(48)="ROInterface.ROSTY2FooterButton"
     DefaultStyleNames(50)="ROInterface.ROSTY2ComboButton"
     DefaultStyleNames(51)="ROInterface.ROSTY2VertUpButton"
     DefaultStyleNames(52)="ROInterface.ROSTY2VertDownButton"
     DefaultStyleNames(53)="ROInterface.ROSTY2_VertGrip"
     DefaultStyleNames(54)="ROInterface.ROSTY2Spinner"
     DefaultStyleNames(55)="ROInterface.ROSTY2SectionHeaderTop"
     DefaultStyleNames(56)="ROInterface.ROSTY2SectionHeaderBar"
     DefaultStyleNames(57)="ROInterface.ROSTY2CloseButton"
     FilterMenu="ROInterface.ROUT2K4_FilterListPage"
     MapVotingMenu="ROInterface.ROMapVotingPage"
     MainMenuOptions(0)="ROInterface.ROUT2K4ServerBrowser"
     MainMenuOptions(1)="ROInterface.ROUT2K4GamePageMP"
     MainMenuOptions(2)="ROInterface.ROUT2K4GamePageSP"
     MainMenuOptions(3)="ROInterface.ROSettingsPage_new"
     MainMenuOptions(4)="ROInterface.ROUT2K4QuitPage"
}
