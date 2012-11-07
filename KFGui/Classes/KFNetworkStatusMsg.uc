class KFNetworkStatusMsg extends UT2k4NetWorkStatusMsg;

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
     stbNetworkMessage=GUIScrollTextBox'KFGui.KFNetworkStatusMsg.Scroller'

     StatusMessages(0)="The Master server has determined your CD-Key is either invalid or already in use.  If this problem persists, please contact Atari Technicial support."
     StatusMessages(1)="A communication link to the Unreal Tournament 2004 master server could not be established.  Please check your connection to the internet and try again."
     StatusMessages(2)="Apparently, your communication link to the Unreal Tournament 2004 master server has been interrupted.  Please check your connection to the internet and try again."
     StatusMessages(3)="Sorry, This Killing Floor server does not accept late joiners."
     StatusMessages(4)="Client is in Developer Mode!||Your client is currently operating in developer mode and it's access to the master server has been restricted.  Please restart the game and avoid using SET commands that may cause problems.  If the problem persists, please contact Atari Technical Support."
     StatusMessages(5)="Modified Client!||Your copy of Unreal Tournament 2004 has in some way been modified.  Because of this, its access to the master server has been restricted.  If this problem persists, please reinstall the game or the latest patch.||This error has been logged at the master server."
     StatusTitle(3)="No Late Joiners"
     StatusCodes(3)="FC_NoLateJoiners"
}
