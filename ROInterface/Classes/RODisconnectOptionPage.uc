//==============================================================================
//	Created on: 08/18/2003
//	Description
//
//	Written by Ron Prestenback
//  Edited by Mathieu Mallet
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class RODisconnectOptionPage extends BlackoutWindow;

var Automated GUIButton b_MainMenu, b_ServerBrowser,
						b_Reconnect, b_Quit;
var automated GUILabel l_Status;

var() bool bReconnectAllowed;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	PlayerOwner().ClearProgressMessages();
	SetSizingCaption();
}

function SetSizingCaption()
{
	local string s;
	local GUIButton b;
	local int i;

	for ( i = 0; i < Components.Length; i++ )
	{
		b = GUIButton(Components[i]);
		if ( b == None )
			continue;

		if ( s == "" || Len(b.Caption) > len(s) )
			s = b.Caption;
	}

	for ( i = 0; i< Components.Length; i++ )
	{
		b = GUIButton(Components[i]);
		if ( b == None )
			continue;

		b.SizingCaption = s;
	}
}

event HandleParameters(string Param1, string Param2)
{
	// If we received any type of failure message, cancel any pending connections
	// as these aren't always cancelled, even when there has been a failure
	if ( Param1 != "" || Param2 != "" )
		Controller.ViewportOwner.Console.DelayedConsoleCommand("CANCEL");

	if ( InStr(Locs(Param1), "?failed") != -1 )
		bReconnectAllowed = false;

	if ( Param1 != "" )
		l_Status.Caption = Param1;

	if ( l_Status.Caption != "" )
		l_Status.Caption $= "|";

	if ( Param2 == "noreconnect" )
		bReconnectAllowed = False;
	else if ( !(Param1 ~= Param2) )
		l_Status.Caption $= Param2;

	UpdateButtons();
}

function UpdateButtons()
{
	if ( bReconnectAllowed && !PlayerOwner().Level.IsPendingConnection() )
		b_Reconnect.EnableMe();

	else b_Reconnect.DisableMe();
}

event Opened(GUIComponent Sender)
{
	// Make sure we remove any other menus like this from the stack
	if ( Controller != None )
		Controller.ConsolidateMenus();

	Super.Opened(Sender);
}

function bool InternalOnClick(GUIComponent Sender)
{
	local GUIController C;

	if ( GUIButton(Sender) == None )
		return false;

	C = Controller;
	switch (GUIButton(Sender).Caption)
	{
		case b_MainMenu.Caption:
			UT2K4GUIController(C).ReturnToMainMenu();
			return true;

		case b_ServerBrowser.Caption:
			// If we still have a pending connection, do not close this menu when opening the server browser
			// or the player will be stuck in the menus if the connection succeeds, since the server browser
			// isn't allowed as last (closing the server browser would then cause the main menu to appear)
			if ( PlayerOwner().Level.IsPendingConnection() )
				C.OpenMenu( C.GetServerBrowserPage() );
			else
			{
				// Clear the controller's restore menu array or things will get very messy
				C.CloseAll(true,true);

				C.RestoreMenus.Length = 0;
				C.OpenMenu( C.GetServerBrowserPage() );
//				Controller.ReplaceMenu( Controller.GetServerBrowserPage() );
			}
			return true;

		case b_Quit.Caption:
			C.OpenMenu(C.GetQuitPage());
			return true;

		case b_Reconnect.Caption:
			C.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");
			C.CloseMenu(false);
			return True;
//			Controller.CloseAll(false,true);
	}

	return false;
}

function UpdateStatus(string NewStatus)
{
	l_Status.Caption = NewStatus;
}

function bool InternalOnPreDraw(Canvas C)
{
	local int i;
	local float X, width;

	for ( i = 0; i < Components.Length; i++ )
		if ( GUIButton(Components[i]) != None )
			width += Components[i].ActualWidth();

	width += 30;
	X = ((ActualLeft() + ActualWidth()) / 2) - (width / 2);

	for ( i = 0; i < Components.Length; i++ )
	{
		if ( GUIButton(Components[i]) != None )
		{
			Components[i].WinLeft = RelativeLeft(X);
			X += Components[i].ActualWidth() + 10;
		}
	}

	return false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( Key == 0x0D && State == 3 )	// Enter
		return InternalOnClick( GUIButton(FocusedControl) );

	return false;
}

event bool NotifyLevelChange()
{
	return false;
}

function bool CanClose( bool bCancelled )
{
	// Only allow this menu to be closed (using escape) if we are currently connected
	// to a server, or we still have a pending connection, unless we were in some other menu
	if ( bCancelled && Controller.KeyPressed(IK_Escape) && !PlayerOwner().Level.IsPendingConnection() && PlayerOwner().Level.IsEntry() )
		return Controller.Count() > 1;

	return true;
}

function bool AllowOpen(string MenuClass)
{
	if (MenuClass~= "ROInterface.RODisconnectOptionPage")
		return false;
	else
		return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=MainMenuButton
         Caption="Main Menu"
         bAutoSize=True
         WinTop=0.548235
         WinLeft=0.157811
         WinWidth=0.132806
         TabOrder=1
         OnClick=RODisconnectOptionPage.InternalOnClick
         OnKeyEvent=MainMenuButton.InternalOnKeyEvent
     End Object
     b_MainMenu=GUIButton'ROInterface.RODisconnectOptionPage.MainMenuButton'

     Begin Object Class=GUIButton Name=ServerBrowserButton
         Caption="Server Browser"
         bAutoSize=True
         WinTop=0.548235
         WinLeft=0.398437
         WinWidth=0.223632
         TabOrder=2
         OnClick=RODisconnectOptionPage.InternalOnClick
         OnKeyEvent=ServerBrowserButton.InternalOnKeyEvent
     End Object
     b_ServerBrowser=GUIButton'ROInterface.RODisconnectOptionPage.ServerBrowserButton'

     Begin Object Class=GUIButton Name=ReconnectButton
         Caption="Reconnect"
         bAutoSize=True
         WinTop=0.548235
         WinLeft=0.345702
         WinWidth=0.132806
         TabOrder=0
         OnClick=RODisconnectOptionPage.InternalOnClick
         OnKeyEvent=ReconnectButton.InternalOnKeyEvent
     End Object
     b_Reconnect=GUIButton'ROInterface.RODisconnectOptionPage.ReconnectButton'

     Begin Object Class=GUIButton Name=QuitButton
         Caption="Exit Killing Floor"
         bAutoSize=True
         WinTop=0.548235
         WinLeft=0.627929
         WinWidth=0.223632
         TabOrder=3
         OnClick=RODisconnectOptionPage.InternalOnClick
         OnKeyEvent=QuitButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'ROInterface.RODisconnectOptionPage.QuitButton'

     Begin Object Class=GUILabel Name=cNetStatLabel
         Caption="Select an option"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         bMultiLine=True
         FontScale=FNS_Large
         WinTop=0.314687
         WinHeight=0.099922
         bBoundToParent=True
     End Object
     l_Status=GUILabel'ROInterface.RODisconnectOptionPage.cNetStatLabel'

     bReconnectAllowed=True
     bAllowedAsLast=True
     OpenSound=Sound'ROMenuSounds.Generic.msfxEdit'
     OnCanClose=RODisconnectOptionPage.CanClose
     OnPreDraw=RODisconnectOptionPage.InternalOnPreDraw
     OnKeyEvent=RODisconnectOptionPage.InternalOnKeyEvent
}
