// ====================================================================
// ====================================================================

class KFConfirmSPPage extends UT2K4QuitPage;

var bool bMovingOnSP;

event Timer()
{
  Log("Timer is firing!"); 
   if (bMovingOnSP)
    {
     Log("Moving on is True!");
     bMovingOnSP = false;
     Controller.ConsoleCommand("OPEN KFS-Intro?Game=KFmod.KFSPGameType");
    }
}


event Opened(GUIComponent Sender)
{
    Timer();

    if ( bCaptureInput )
        FadeIn();

    Super.Opened(Sender);
}


function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender==Controls[1])
    {
        if(PlayerOwner().Level.IsDemoBuild())
            Controller.ReplaceMenu("XInterface.UT2DemoQuitPage");
        else{
            Controller.ConsoleCommand( "DISCONNECT" );
            bMovingOnSP = true;
            SetTimer(0.5,false);
            }
    }
    else
        Controller.CloseMenu(false);

    return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=QuitBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=QuitBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'KFGui.KFConfirmSPpage.QuitBackground'

     Begin Object Class=GUIButton Name=YesButton
         Caption="YES"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=KFConfirmSPpage.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'KFGui.KFConfirmSPpage.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="NO"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=KFConfirmSPpage.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'KFGui.KFConfirmSPpage.NoButton'

     Begin Object Class=GUILabel Name=QuitDesc
         Caption="Are you sure you wish to start a new Single Player game?"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'KFGui.KFConfirmSPpage.QuitDesc'

     WinTop=0.375000
     WinHeight=0.250000
}
