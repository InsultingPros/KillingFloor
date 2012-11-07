//=============================================================================
// ROSteamLoginPage
//=============================================================================
// Menu that pops up when attempting to connect to a server with an expired
// Steam login. This page allows the user to log back in without exiting
// to Steam.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive - John Gibson
//=============================================================================
class ROSteamLoginPage extends UT2K4GetDataMenu;

var string	RetryURL;
var localized string IncorrectPassword;
var localized string SteamUserName;
var automated GUILabel  l_Text3, l_Text4;

var float WaitTime;
var int WaitCounter;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();

	ed_Data.MyEditBox.bMaskText=true;
	ed_Data.MyEditBox.bConvertSpaces = true;

	l_Text4.Caption = Controller.SteamGetUserName();
}

function HandleParameters(string URL, string FailCode)
{
	RetryURL = URL;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK  ) // Retry
		RetryPassword();

	else if ( Sender == b_Cancel ) // Fail
		Controller.ReplaceMenu(Controller.GetServerBrowserPage());

	return true;
}

function RetryPassword()
{
	local string 			EntryString;
	local ExtendedConsole	MyConsole;

	EntryString = ed_Data.GetText();
	MyConsole = ExtendedConsole(PlayerOwner().Player.Console);

	if( Controller.SteamRefreshLogin(EntryString) )
	{
		SetTimer( 0.25, true);

		ed_Data.DisableMe();
		b_OK.DisableMe();
		//b_Cancel.DisableMe();
		l_Text3.DisableMe();
		l_Text4.DisableMe();
		return;

		//Controller.ReplaceMenu(Controller.GetServerBrowserPage());
		//return;
		// Put this back in when Valve fixes the AuthValidation Stall problem
		//PlayerOwner().ClientTravel( RetryURL,TRAVEL_Absolute,false);
	}
	else
	{
		l_Text.Caption = IncorrectPassword;
		return;
	}

	Controller.CloseAll(false,True);
}

event Timer()
{
	super.Timer();

	if( WaitTime <= 5.0 )
	{
		WaitTime += 0.25;

		if( WaitCounter == 1 )
		{
			l_Text.Caption = "Refreshing Login  .    ";
			WaitCounter++;
		}
		else if ( WaitCounter == 2 )
		{
			l_Text.Caption = "Refreshing Login   .   ";
			WaitCounter++;
		}
		else if ( WaitCounter == 3 )
		{
			l_Text.Caption = "Refreshing Login    .  ";
			WaitCounter++;
		}
 		else if ( WaitCounter == 4 )
		{
			l_Text.Caption = "Refreshing Login     . ";
			WaitCounter++;
		}
		else if ( WaitCounter == 5 )
		{
			l_Text.Caption = "Refreshing Login      .";
			WaitCounter=0;
		}
		else
		{
			l_Text.Caption = "Refreshing Login .     ";
			WaitCounter++;
		}

		SetTimer( 0.25, true);
	}
	else
	{
		Controller.ReplaceMenu(Controller.GetServerBrowserPage());
	}

}

defaultproperties
{
     IncorrectPassword="Incorrect password specified.  Please try again."
     Begin Object Class=GUILabel Name=UserNameTagLabel
         Caption="Steam UserName:"
         StyleName="TextLabel"
         WinTop=0.440366
         WinLeft=0.209375
         WinWidth=0.562500
         WinHeight=0.030000
     End Object
     l_Text3=GUILabel'ROInterface.ROSteamLoginPage.UserNameTagLabel'

     Begin Object Class=GUILabel Name=SteamUserNameLabel
         StyleName="TextLabel"
         WinTop=0.438283
         WinLeft=0.435938
         WinWidth=0.562500
         WinHeight=0.030000
     End Object
     l_Text4=GUILabel'ROInterface.ROSteamLoginPage.SteamUserNameLabel'

     Begin Object Class=GUIButton Name=GetPassFail
         Caption="CANCEL"
         StyleName="SelectButton"
         WinTop=0.547122
         WinLeft=0.586523
         WinWidth=0.147500
         WinHeight=0.045000
         TabOrder=2
         bBoundToParent=True
         OnClick=ROSteamLoginPage.InternalOnClick
         OnKeyEvent=GetPassFail.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'ROInterface.ROSteamLoginPage.GetPassFail'

     Begin Object Class=moEditBox Name=GetPassPW
         CaptionWidth=0.400000
         Caption="Steam Password"
         OnCreateComponent=GetPassPW.InternalOnCreateComponent
         WinTop=0.485366
         WinLeft=0.209375
         WinWidth=0.562500
         TabOrder=0
     End Object
     ed_Data=moEditBox'ROInterface.ROSteamLoginPage.GetPassPW'

     Begin Object Class=GUIButton Name=GetPassRetry
         Caption="SUBMIT"
         StyleName="SelectButton"
         WinTop=0.730455
         WinLeft=0.320899
         WinWidth=0.147500
         WinHeight=0.045000
         TabOrder=1
         bBoundToParent=True
         OnClick=ROSteamLoginPage.InternalOnClick
         OnKeyEvent=GetPassRetry.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'ROInterface.ROSteamLoginPage.GetPassRetry'

     Begin Object Class=GUILabel Name=GetPassLabel
         Caption="Steam Login Expired or Invalid, Enter Password To Login"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.195980
         WinLeft=0.024805
         WinWidth=0.940430
         WinHeight=0.054688
         bBoundToParent=True
     End Object
     l_Text=GUILabel'ROInterface.ROSteamLoginPage.GetPassLabel'

     bAllowedAsLast=True
     OpenSound=Sound'ROMenuSounds.Generic.msfxEdit'
}
