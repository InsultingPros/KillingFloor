//==============================================================================
//	Written by Ron Prestenback
//  This menu indicates that a non-recoverable network error has occurred, and the player will
//  be kicked back to the main menu when this menu is closed.
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4NetworkStatusMsg extends LockedFloatingWindow;

var automated GUIScrollTextBox stbNetworkMessage;
var localized 	string 	StatusMessages[16];
var localized 	string 	StatusTitle[16];
var localized   string  UnknownError;
var 			string	StatusCodes[16];
var 			bool	bExit;
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();

	b_Cancel.SetVisibility(false);
    b_OK.OnClick = InternalOnClick;

	sb_Main.ManageComponent(stbNetworkMessage);
}

event bool NotifyLevelChange()
{
	return false;
}

event HandleParameters(string Param1, string Param2)
{
	local int i;
	local string s;

	for (i=0;i<ArrayCount(StatusCodes);i++)
    	if (StatusCodes[i] ~= Param1)
        {
        	s = StatusMessages[i];
       		ReplaceText(s, "%data%", Param2);
        	t_WindowTitle.SetCaption(StatusTitle[i]);
        	break;
        }



	if ( i == ArrayCount(StatusCodes) )
	{
		if (Param1=="")
		{
			s = UnknownError;
			if ( Param1 != "" )
				s $= "||" $ Param1;

			if ( Param2 != "" )
				s $= "||" $ Param2;
		}
		else
			s = Param1 $ "||" $ Param2;
	}
	stbNetworkMessage.SetContent(s);
}
function bool FloatingPreDraw( Canvas C )
{
	if (bExit)
	{
		Controller.CloseMenu(False);
		return true;
	}
	return super.FloatingPreDraw(c);
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=Scroller
         bNoTeletype=True
         OnCreateComponent=Scroller.InternalOnCreateComponent
         WinTop=0.133333
         WinLeft=0.033108
         WinWidth=0.925338
         WinHeight=0.790203
     End Object
     stbNetworkMessage=GUIScrollTextBox'GUI2K4.UT2K4NetworkStatusMsg.Scroller'

     StatusMessages(0)="The Master server has determined your CD-Key is either invalid or already in use.  If this problem persists, please contact Steam Technicial support."
     StatusMessages(1)="A communication link to the Killing Floor master server could not be established.  Please check your connection to the internet and try again."
     StatusMessages(2)="Apparently, your communication link to the Killing Floor master server has been interrupted.  Please check your connection to the internet and try again."
     StatusMessages(3)="Must Upgrade"
     StatusMessages(4)="Client is in Developer Mode!||Your client is currently operating in developer mode and it's access to the master server has been restricted.  Please restart the game and avoid using SET commands that may cause problems.  If the problem persists, please contact Steam Technicial support."
     StatusMessages(5)="Modified Client!||Your copy of Killing Floor has in some way been modified.  Because of this, its access to the master server has been restricted.  If this problem persists, please reinstall the game or the latest patch.||This error has been logged at the master server."
     StatusMessages(6)="Your CD-KEY has been banned by the master server.  this ban will remain in place until %data%"
     StatusMessages(7)="The server you are trying to connect to is currently full.  Please try this server again later, or you may wish to try connecting as a spectator if the server allows it"
     StatusMessages(8)="The admin of this server has banned you playing here.  If you feel you do not deserve this ban, the admin's contact email is [%data%]"
     StatusMessages(9)="This copy of Killing Floor is not compatible with the server you are connecting to."
     StatusMessages(10)="There was a fatal problem during login that has caused you to be disconnected from the server.||Reason: %data%"
     StatusMessages(11)="You have been forcibly removed from the game.||Reason: %data%"
     StatusMessages(12)="An admin of this server has banned you for the remainder of the current game.||If you feel you do not deserve this ban, the admin's email is:|[%data%]."
     StatusMessages(13)="You've been permanently banned from playing on this server.||If you feel you do not deserve this ban, the admin's contact email is:|[%data%]."
     StatusMessages(14)="An unknown Steam error is preventing you from connecting to this server.||If the problem persists please contact Valve for support."
     StatusMessages(15)="You have been banned from this game by VAC."
     StatusTitle(0)="Invalid CD-Key"
     StatusTitle(1)="Connection Failed"
     StatusTitle(2)="Connection Timed Out"
     StatusTitle(3)="Must Upgrade"
     StatusTitle(4)="Developer Mode"
     StatusTitle(5)="Modified Client"
     StatusTitle(6)="You have been Banned"
     StatusTitle(7)="The Server is Full"
     StatusTitle(8)="You have been banned"
     StatusTitle(9)="Incompatible Version"
     StatusTitle(10)="Problem during Login"
     StatusTitle(11)="Kicked"
     StatusTitle(12)="Session Ban"
     StatusTitle(13)="Permanent Ban"
     StatusTitle(14)="Steam Error"
     StatusTitle(15)="Steam VAC Ban"
     UnknownError="Unknown Network Error"
     StatusCodes(0)="RI_AuthenticationFailed"
     StatusCodes(1)="RI_ConnectionFailed"
     StatusCodes(2)="RI_ConnectionTimeOut"
     StatusCodes(3)="RI_MustUpgrade"
     StatusCodes(4)="RI_DevClient"
     StatusCodes(5)="RI_BadClient"
     StatusCodes(6)="RI_BannedClient"
     StatusCodes(7)="FC_ServerFull"
     StatusCodes(8)="FC_LocalBan"
     StatusCodes(9)="FC_Challege"
     StatusCodes(10)="FC_Login"
     StatusCodes(11)="AC_Kicked"
     StatusCodes(12)="AC_SessionBan"
     StatusCodes(13)="AC_Ban"
     StatusCodes(14)="ST_Unknown"
     StatusCodes(15)="ST_VACBan"
     WindowName="Network Connection Lost"
}
