//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4DemoPlayback extends PopupPageBase;

// if _RO_
#exec OBJ LOAD FILE=InterfaceArt_tex.utx
// end if _RO_

var automated StateButton b_FF, b_PlayPause, b_Stop;
var automated GUILabel lb_MapName, lb_Mod;

var GUIList l_ViewTargets;

var bool bIsClosing, bIsPaused;
var float OriginalGameSpeed;
var int GameSpeedModifier;
var float GameSpeedMods[4];
var float modfade;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController, MyOwner);
	i_FrameBG.Image = material'DemoHeaderBar';
// if _RO_
	i_FrameBG.WinTop = 0.0;
// end if _RO_

	OriginalGameSpeed = PlayerOwner().level.TimeDilation;
	lb_MapName.Caption = PlayerOwner().Level.Title;
	Animate(0,0,0.15);
}

event Free()
{
	l_ViewTargets.Clear();
	super.free();
}

function Arrival(GUIComponent Sender, EAnimationType Type)
{
	WinTop=0.0;
}

function bool StopClick(GUIComponent Sender)
{
	PlayerOwner().Level.TimeDilation = OriginalGameSpeed;
	PlayerOwner().ConsoleCommand("disconnect");
	return true;
}

function bool PlayPauseClick(GUIComponent Sender)
{
	if ( bIsPaused )	// We are paused
	{
		bIsPaused=false;
// if _RO_
		b_PlayPause.Images[0]=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry';
		b_PlayPause.Images[1]=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry';
		b_PlayPause.Images[2]=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry';
		b_PlayPause.Images[3]=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry';
		b_PlayPause.Images[4]=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry';
// else
//		b_PlayPause.Images[0]=material'PauseBlurry';
//		b_PlayPause.Images[1]=material'PauseWatched';
//		b_PlayPause.Images[2]=material'PauseWatched';
//		b_PlayPause.Images[3]=material'PausePressed';
//		b_PlayPause.Images[4]=material'PauseBlurry';
// end if _RO_
		PlayerOwner().Level.Pauser = None;

	}
	else
	{
		bIsPaused=true;
// if _RO_
		b_PlayPause.Images[0]=Texture'InterfaceArt_tex.Demo_controls.PlayBlurry';
		b_PlayPause.Images[1]=Texture'InterfaceArt_tex.Demo_controls.PlayBlurry';
		b_PlayPause.Images[2]=Texture'InterfaceArt_tex.Demo_controls.PlayBlurry';
		b_PlayPause.Images[3]=Texture'InterfaceArt_tex.Demo_controls.PlayBlurry';
		b_PlayPause.Images[4]=Texture'InterfaceArt_tex.Demo_controls.PlayBlurry';
// else
//		b_PlayPause.Images[0]=material'PlayBlurry';
//		b_PlayPause.Images[1]=material'PlayWatched';
//		b_PlayPause.Images[2]=material'PlayWatched';
//		b_PlayPause.Images[3]=material'PlayPressed';
//		b_PlayPause.Images[4]=material'PlayBlurry';
// end if _RO_
		PlayerOwner().Level.Pauser = PlayerOwner().PlayerReplicationInfo;
	}
	return true;
}
function bool FastForwardClick(GUIComponent Sender)
{
	if (GameSpeedModifier<3)
		GameSpeedModifier++;
	else
		GameSpeedModifier = 0;

	lb_Mod.Caption = "x"$int(GameSpeedMods[GameSpeedModifier]);
	ModFade=255;
	PlayerOwner().Level.TimeDilation = OriginalGameSpeed * GameSpeedMods[GameSpeedModifier];
	return true;
}

function bool ModDraw(canvas C)
{
	if (ModFade>0)
	{
		ModFade -= (255*Controller.RenderDelta);
		if (ModFade>=0)
		{
			lb_Mod.TextColor.A=int(ModFade);
			return false;
		}
	}
	lb_Mod.TextColor.A=0;
	return false;
}

defaultproperties
{
     Begin Object Class=StateButton Name=bFF
         Images(0)=Texture'InterfaceArt_tex.Demo_controls.NextTrackBlurry'
         Images(1)=Texture'InterfaceArt_tex.Demo_controls.NextTrackBlurry'
         Images(2)=Texture'InterfaceArt_tex.Demo_controls.NextTrackBlurry'
         Images(3)=Texture'InterfaceArt_tex.Demo_controls.NextTrackBlurry'
         Images(4)=Texture'InterfaceArt_tex.Demo_controls.NextTrackBlurry'
         WinTop=0.100000
         WinLeft=0.097500
         WinWidth=0.040000
         WinHeight=0.800000
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2K4DemoPlayback.FastForwardClick
         OnKeyEvent=bFF.InternalOnKeyEvent
     End Object
     b_FF=StateButton'GUI2K4.UT2K4DemoPlayback.bFF'

     Begin Object Class=StateButton Name=bPlayPause
         Images(0)=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry'
         Images(1)=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry'
         Images(2)=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry'
         Images(3)=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry'
         Images(4)=Texture'InterfaceArt_tex.Demo_controls.PauseBlurry'
         WinTop=0.100000
         WinLeft=0.055000
         WinWidth=0.040000
         WinHeight=0.800000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2K4DemoPlayback.PlayPauseClick
         OnKeyEvent=bPlayPause.InternalOnKeyEvent
     End Object
     b_PlayPause=StateButton'GUI2K4.UT2K4DemoPlayback.bPlayPause'

     Begin Object Class=StateButton Name=bStop
         Images(0)=Texture'InterfaceArt_tex.Demo_controls.StopBlurry'
         Images(1)=Texture'InterfaceArt_tex.Demo_controls.StopBlurry'
         Images(2)=Texture'InterfaceArt_tex.Demo_controls.StopBlurry'
         Images(3)=Texture'InterfaceArt_tex.Demo_controls.StopBlurry'
         Images(4)=Texture'InterfaceArt_tex.Demo_controls.StopBlurry'
         WinTop=0.100000
         WinLeft=0.013750
         WinWidth=0.040000
         WinHeight=0.800000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2K4DemoPlayback.StopClick
         OnKeyEvent=bStop.InternalOnKeyEvent
     End Object
     b_Stop=StateButton'GUI2K4.UT2K4DemoPlayback.bStop'

     Begin Object Class=GUILabel Name=lbMapName
         TextAlign=TXTA_Right
         FontScale=FNS_Large
         StyleName="DarkTextLabel"
         WinLeft=0.150000
         WinWidth=0.825000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_MapName=GUILabel'GUI2K4.UT2K4DemoPlayback.lbMapName'

     Begin Object Class=GUILabel Name=lbMod
         Caption="2X"
         TextColor=(B=106,G=41,R=14,A=0)
         TextFont="UT2LargeFont"
         WinLeft=0.150000
         WinWidth=0.825000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=UT2K4DemoPlayback.ModDraw
     End Object
     lb_Mod=GUILabel'GUI2K4.UT2K4DemoPlayback.lbMod'

     GameSpeedMods(0)=1.000000
     GameSpeedMods(1)=2.000000
     GameSpeedMods(2)=4.000000
     GameSpeedMods(3)=8.000000
     bAllowedAsLast=True
     WinTop=-0.065000
     WinHeight=0.065000
     OnArrival=UT2K4DemoPlayback.Arrival
}
