class KFGUIController extends UT2K4GUIController;

#exec OBJ LOAD FILE=KFInterfaceContent.utx
#exec OBJ LOAD FILE=2K4MenuSounds.uax
#exec OBJ LOAD FILE=2K4Menus.utx


simulated event ResolutionChanged()
{
    if( ViewportOwner.Actor != none && KFPlayerController(ViewportOwner.Actor) != none )
    {
        KFPlayerController(ViewportOwner.Actor).InitFOV();
    }
}

event InitializeController()
{
	Super.InitializeController();
	
	// Enter the mp_lobby zone to get a new movie
	class'PlayerController'.static.Advertising_EnterZone("mp_lobby");
}

function PurgeComponentClasses()
{
	if ( RegisteredClasses.Length > 0 )
		RegisteredClasses.Remove(0, RegisteredClasses.Length);

	Super.PurgeComponentClasses();
}

function ReturnToMainMenu()
{ 
    // Closing all the menus also force an Advertising_ExitZone
    CloseAll(true);

    // Re-enter the mp_lobby zone to get a new movie
    if( ViewportOwner.Actor != none )
    {
    	ViewportOwner.Actor.Advertising_EnterZone("mp_lobby");    	
    }

    if ( MenuStack.Length == 0 )
        OpenMenu(GetMainMenuClass());
}

static simulated function string GetServerBrowserPage()
{
	return "KFGUI.KFServerBrowser";
}

defaultproperties
{
     STYLE_NUM=63
     MouseCursors(0)=Texture'InterfaceArt_tex.Cursors.Pointer'
     MouseCursors(1)=Texture'InterfaceArt_tex.Cursors.ResizeAll'
     MouseCursors(2)=Texture'InterfaceArt_tex.Cursors.ResizeSWNE'
     MouseCursors(3)=Texture'InterfaceArt_tex.Cursors.Resize'
     MouseCursors(4)=Texture'InterfaceArt_tex.Cursors.ResizeNWSE'
     MouseCursors(5)=Texture'InterfaceArt_tex.Cursors.ResizeHorz'
     MouseCursors(6)=Texture'InterfaceArt_tex.Cursors.Pointer'
     ImageList(0)=Texture'InterfaceArt_tex.Menu.checkBoxBall_b'
     ImageList(1)=Texture'InterfaceArt_tex.Menu.AltComboTickBlurry'
     ImageList(2)=Texture'KF_InterfaceArt_tex.Menu.LeftMark'
     ImageList(3)=Texture'KF_InterfaceArt_tex.Menu.RightMark'
     ImageList(4)=Texture'KF_InterfaceArt_tex.Menu.RightMark'
     ImageList(5)=Texture'KF_InterfaceArt_tex.Menu.RightMark'
     ImageList(6)=Texture'KF_InterfaceArt_tex.Menu.UpMark'
     ImageList(7)=Texture'KF_InterfaceArt_tex.Menu.DownMark'
     DefaultStyleNames(0)="KFGUI.KF_RoundButton"
     DefaultStyleNames(1)="ROInterface.ROSTY_RoundScaledButton"
     DefaultStyleNames(2)="KFGUI.KF_SquareButton"
     DefaultStyleNames(3)="KFGUI.KF_ListBox"
     DefaultStyleNames(4)="ROInterface.ROSTY2ScrollZone"
     DefaultStyleNames(5)="KFGUI.KF_TextButton"
     DefaultStyleNames(7)="KFGUI.KF_Header"
     DefaultStyleNames(8)="ROInterface.ROSTY_Footer"
     DefaultStyleNames(9)="KFGUI.KF_TabButton"
     DefaultStyleNames(13)="KFGUI.KF_ServerBrowserGrid"
     DefaultStyleNames(15)="ROInterface.ROSTY_ServerBrowserGridHeader"
     DefaultStyleNames(21)="ROInterface.ROSTY_SquareBar"
     DefaultStyleNames(22)="ROInterface.ROSTY_MidGameButton"
     DefaultStyleNames(23)="KFGUI.KF_TextLabel"
     DefaultStyleNames(24)="ROInterface.ROSTY2ComboListBox"
     DefaultStyleNames(26)="ROInterface.ROSTY2IRCText"
     DefaultStyleNames(27)="ROInterface.ROSTY2IRCEntry"
     DefaultStyleNames(29)="KFGUI.KF_ContextMenu"
     DefaultStyleNames(30)="KFGUI.KF_ServerListContextMenu"
     DefaultStyleNames(31)="KFGUI.KF_ListSelection"
     DefaultStyleNames(32)="ROInterface.ROSTY2TabBackground"
     DefaultStyleNames(33)="KFGUI.KF_BrowserListSel"
     DefaultStyleNames(34)="KFGUI.KF_EditBox"
     DefaultStyleNames(35)="ROInterface.ROSTY2CheckBox"
     DefaultStyleNames(37)="ROInterface.ROSTY2SliderKnob"
     DefaultStyleNames(39)="KFGUI.KF_ListSectionHeader"
     DefaultStyleNames(40)="ROInterface.ROSTY2ItemOutline"
     DefaultStyleNames(41)="KFGUI.KF_ListHighlight"
     DefaultStyleNames(42)="ROInterface.ROSTY2MouseOverLabel"
     DefaultStyleNames(43)="ROInterface.ROSTY2SliderBar"
     DefaultStyleNames(45)="ROInterface.ROSTY2TextButtonEffect"
     DefaultStyleNames(48)="KFGUI.KF_FooterButton"
     DefaultStyleNames(50)="ROInterface.ROSTY2ComboButton"
     DefaultStyleNames(51)="ROInterface.ROSTY2VertUpButton"
     DefaultStyleNames(52)="ROInterface.ROSTY2VertDownButton"
     DefaultStyleNames(53)="ROInterface.ROSTY2_VertGrip"
     DefaultStyleNames(54)="ROInterface.ROSTY2Spinner"
     DefaultStyleNames(55)="ROInterface.ROSTY2SectionHeaderTop"
     DefaultStyleNames(56)="ROInterface.ROSTY2SectionHeaderBar"
     DefaultStyleNames(57)="ROInterface.ROSTY2CloseButton"
     DefaultStyleNames(59)="GUI2K4.STY2AltComboButton"
     DefaultStyleNames(60)="KFGUI.KF_ItemBoxInfo"
     DefaultStyleNames(61)="KFGUI.GUIVetToolTipMOStyle"
     DefaultStyleNames(62)="KFGUI.KFSTY2NoBackground"
     FilterMenu="KFGUI.KFUT2K4_FilterListPage"
     MapVotingMenu="KFGUI.KFMapVotingPage"
     MainMenuOptions(2)="KFGUI.KFGamePageMP"
     MainMenuOptions(3)="KFGUI.KFGamePageSP"
     MainMenuOptions(5)="KFGUI.KFSettingsPage"
     MainMenuOptions(6)="KFGUI.KFQuitPage"
     NetworkMsgMenu="KFGUI.KFNetworkStatusMsg"
}
