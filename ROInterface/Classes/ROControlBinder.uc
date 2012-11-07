//-----------------------------------------------------------
//=============================================================================
// ROTab_ControlSettings
//=============================================================================
// Used for keybinding the RO functions
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 by John Gibson
//
//
//=========================================================
// Modify Listings
//
// 1.) new button binding added by Antarian 3/2/03 for "Bayonet Attach / MG Deploy"
// 2.) new button binding added by Antarin 8/30/03 for "Switch Fire Mode"
// 3.) Moved to ROControlBinder and updated for UT2004 Puma 5-15-2004
// 4.) new button binding added by Antarian 5/17/04 for "MG Ammo Resupply"
// 5.) new button binding added by Antarian 5/17/04 for "Save Artillery Coords"
//=============================================================================
//-----------------------------------------------------------
class ROControlBinder extends ControlBinder;

var()	Texture				mytexture;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    Super.InitComponent(InController, InOwner);

    class'ROInterfaceUtil'.static.SetROStyle(InController, Controls);

    sb_Main.HeaderTop=mytexture;
    sb_Main.HeaderBar=mytexture;
    sb_Main.HeaderBase=mytexture;

    /*myStyleName = "ROTitleBar";
    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = InController.GetStyle(myStyleName,t_WindowTitle.FontScale);

    myStyleName = "ROListSelection";
    SectionStyleName = myStyleName;
    SectionStyle = InController.GetStyle(myStyleName,li_Binds.FontScale);*/
}

function bool SystemMenuPreDraw(canvas Canvas)
{
    b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + (t_WindowTitle.ActualWidth()-35), t_WindowTitle.ActualTop()+10, 24, 24, true);
	return true;
}

defaultproperties
{
     BindingLabel(0)="Red Orchestra"
     BindingLabel(1)="Sprint"
     BindingLabel(2)="Reload"
     BindingLabel(3)="Iron Sights"
     BindingLabel(4)="Change Role"
     BindingLabel(5)="Show / Hide Hud"
     BindingLabel(6)="Prone"
     BindingLabel(7)="Bayonet Attach / MG Deploy"
     BindingLabel(8)="Change MG Barrel"
     BindingLabel(9)="Show Objectives"
     BindingLabel(10)="Change Scope Detail"
     BindingLabel(11)="Change Side"
     BindingLabel(12)="Use"
     BindingLabel(13)="Switch Fire Mode"
     BindingLabel(14)="ChangeWeapons"
     BindingLabel(15)="MG Ammo Resupply"
     BindingLabel(16)="Save Artillery Coordinates"
     BindingLabel(17)="Movement"
     BindingLabel(18)="Forward"
     BindingLabel(19)="Backward"
     BindingLabel(20)="Strafe Left"
     BindingLabel(21)="Strafe Right"
     BindingLabel(22)="Jump"
     BindingLabel(23)="Walk"
     BindingLabel(24)="ToggleCrouch"
     BindingLabel(25)="Crouch"
     BindingLabel(26)="Strafe Toggle"
     BindingLabel(27)="Lean Left"
     BindingLabel(28)="Lean Right"
     BindingLabel(29)="Looking"
     BindingLabel(30)="Turn Left"
     BindingLabel(31)="Turn Right"
     BindingLabel(32)="Look Up"
     BindingLabel(33)="Look Down"
     BindingLabel(34)="Center View"
     BindingLabel(35)="Toggle "
     BindingLabel(36)="Toggle Camera Mode"
     BindingLabel(37)="Weapons"
     BindingLabel(38)="Fire"
     BindingLabel(39)="Alt-Fire"
     BindingLabel(40)="Throw Weapon"
     BindingLabel(41)="Best Weapon"
     BindingLabel(42)="Next Weapon"
     BindingLabel(43)="Prev Weapon"
     BindingLabel(44)="Last Weapon"
     BindingLabel(45)="Communication"
     BindingLabel(46)="Say"
     BindingLabel(47)="Team Say"
     BindingLabel(48)="In Game Chat"
     BindingLabel(49)="Speech Menu"
     BindingLabel(50)="Activate Microphone"
     BindingLabel(51)="Speak in Public Channel"
     BindingLabel(52)="Speak in local Channel"
     BindingLabel(53)="Speak in Team Channel"
     BindingLabel(54)="Toggle Public Channel"
     BindingLabel(55)="Toggle local Channel"
     BindingLabel(56)="Toggle Team Channel"
     BindingLabel(57)="Hud"
     BindingLabel(58)="Grow Hud"
     BindingLabel(59)="Shrink Hud"
     BindingLabel(60)="ScoreBoard Toggle"
     BindingLabel(61)="ScoreBoard"
     BindingLabel(62)="Game"
     BindingLabel(63)="Use"
     BindingLabel(64)="Pause"
     BindingLabel(65)="Screenshot"
     BindingLabel(72)="Miscellaneous"
     BindingLabel(73)="Menu"
     BindingLabel(74)="Music Player"
     BindingLabel(75)="Voting Menu"
     BindingLabel(76)="Toggle Console"
     BindingLabel(77)="View Connection Status"
     BindingLabel(78)="Cancel Pending Connection"
     BindingLabel(79)="Vehicle Communication"
     BindingLabel(80)="Vehicle Say"
     Bindings(0)=(KeyLabel="Red Orchestra")
     Bindings(1)=(KeyLabel="Sprint",Alias="Button bSprint")
     Bindings(2)=(KeyLabel="Reload",Alias="ROManualReload")
     Bindings(3)=(KeyLabel="Iron Sights",Alias="ROIronSights")
     Bindings(4)=(KeyLabel="Change Role",Alias="PlayerMenu 2")
     Bindings(5)=(KeyLabel="Show / Hide Hud",Alias="ShowPlayInfo")
     Bindings(6)=(KeyLabel="Prone",Alias="Prone")
     Bindings(7)=(KeyLabel="Bayonet Attach / MG Deploy",Alias="Deploy")
     Bindings(8)=(KeyLabel="Change MG Barrel",Alias="ROMGOperation")
     Bindings(9)=(bIsSectionLabel=False,KeyLabel="Show Objectives",Alias="ShowObjectives")
     Bindings(10)=(KeyLabel="Change Scope Detail",Alias="SetScopeDetail")
     Bindings(11)=(KeyLabel="Change Side",Alias="PlayerMenu")
     Bindings(12)=(KeyLabel="Use",Alias="Use")
     Bindings(13)=(KeyLabel="Switch Fire Mode",Alias="SwitchFireMode")
     Bindings(14)=(KeyLabel="Change Weapons",Alias="PlayerMenu 3")
     Bindings(15)=(KeyLabel="MG Ammo Resupply",Alias="ThrowMGAmmo")
     Bindings(16)=(KeyLabel="Save Artillery Coordinates",Alias="SaveArtilleryPosition")
     Bindings(17)=(KeyLabel="Movement")
     Bindings(18)=(KeyLabel="Forward",Alias="MoveForward")
     Bindings(19)=(KeyLabel="Backward",Alias="MoveBackward")
     Bindings(20)=(KeyLabel="Strafe Left",Alias="StrafeLeft")
     Bindings(21)=(KeyLabel="Strafe Right",Alias="StrafeRight")
     Bindings(22)=(KeyLabel="Jump",Alias="Jump")
     Bindings(23)=(KeyLabel="Walk",Alias="Walking")
     Bindings(24)=(KeyLabel="ToggleCrouch",Alias="ToggleDuck")
     Bindings(25)=(KeyLabel="Crouch",Alias="Duck")
     Bindings(26)=(KeyLabel="Strafe Toggle",Alias="Strafe")
     Bindings(27)=(KeyLabel="Lean Left",Alias="LeanLeft")
     Bindings(28)=(KeyLabel="Lean Right",Alias="LeanRight")
     Bindings(29)=(bIsSectionLabel=True,KeyLabel="Looking")
     Bindings(30)=(KeyLabel="Turn Left",Alias="TurnLeft")
     Bindings(31)=(KeyLabel="Turn Right",Alias="TurnRight")
     Bindings(32)=(KeyLabel="Look Up",Alias="LookUp")
     Bindings(33)=(KeyLabel="Look Down",Alias="LookDown")
     Bindings(34)=(KeyLabel="Center View",Alias="CenterView")
     Bindings(35)=(KeyLabel="Toggle BehindView",Alias="ToggleBehindView")
     Bindings(36)=(KeyLabel="Toggle Camera Mode",Alias="ToggleFreeCam")
     Bindings(37)=(KeyLabel="Weapons")
     Bindings(38)=(KeyLabel="Fire",Alias="Fire")
     Bindings(39)=(KeyLabel="Alt-Fire",Alias="AltFire")
     Bindings(40)=(KeyLabel="Throw Weapon",Alias="ThrowWeapon")
     Bindings(41)=(KeyLabel="Best Weapon",Alias="SwitchToBestWeapon")
     Bindings(42)=(KeyLabel="Next Weapon",Alias="NextWeapon")
     Bindings(43)=(KeyLabel="Prev Weapon",Alias="PrevWeapon")
     Bindings(44)=(KeyLabel="Last Weapon",Alias="SwitchToLastWeapon")
     Bindings(45)=(bIsSectionLabel=True,KeyLabel="Communication")
     Bindings(46)=(KeyLabel="Say",Alias="Talk")
     Bindings(47)=(KeyLabel="Team Say",Alias="TeamTalk")
     Bindings(48)=(KeyLabel="In Game Chat",Alias="InGameChat")
     Bindings(49)=(bIsSectionLabel=False,KeyLabel="Speech Menu",Alias="SpeechMenuToggle")
     Bindings(50)=(KeyLabel="Activate Microphone",Alias="VoiceTalk")
     Bindings(51)=(KeyLabel="Speak in Public Channel",Alias="Speak Public")
     Bindings(52)=(KeyLabel="Speak in local Channel",Alias="Speak Local")
     Bindings(53)=(KeyLabel="Speak in Team Channel",Alias="Speak Team")
     Bindings(54)=(bIsSectionLabel=False,KeyLabel="Toggle Public Chatroom",Alias="TogglePublicChat")
     Bindings(55)=(KeyLabel="Toggle local Chatroom",Alias="ToggleLocalChat")
     Bindings(56)=(KeyLabel="Toggle Team Chatroom",Alias="ToggleTeamChat")
     Bindings(57)=(bIsSectionLabel=True,KeyLabel="Hud")
     Bindings(58)=(KeyLabel="Grow Hud",Alias="GrowHud")
     Bindings(59)=(KeyLabel="Shrink Hud",Alias="ShrinkHud")
     Bindings(60)=(bIsSectionLabel=False,KeyLabel="ScoreBoard",Alias="ShowScores")
     Bindings(61)=(KeyLabel="ScoreBoard (QuickView)",Alias="ScoreToggle")
     Bindings(62)=(bIsSectionLabel=True,KeyLabel="Game")
     Bindings(63)=(KeyLabel="Use",Alias="use")
     Bindings(64)=(KeyLabel="Pause",Alias="Pause")
     Bindings(65)=(KeyLabel="Screenshot",Alias="shot")
     Bindings(72)=(bIsSectionLabel=True,KeyLabel="Miscellaneous")
     Bindings(73)=(bIsSectionLabel=False,KeyLabel="Menu",Alias="ShowMenu")
     Bindings(74)=(KeyLabel="Music Player",Alias="MusicMenu")
     Bindings(75)=(KeyLabel="Voting Menu",Alias="ShowVoteMenu")
     Bindings(76)=(KeyLabel="Toggle Console",Alias="ConsoleToggle")
     Bindings(77)=(KeyLabel="View Connection Status",Alias="Stat Net")
     Bindings(78)=(KeyLabel="Cancel Pending Connection",Alias="Cancel")
     Bindings(79)=(bIsSectionLabel=True,KeyLabel="Vehicle Communication")
     Bindings(80)=(KeyLabel="Vehicle Say",Alias="VehicleTalk")
     Begin Object Class=GUIImage Name=BindBk
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         ImageStyle=ISTY_Stretched
         WinTop=0.057552
         WinLeft=0.031397
         WinWidth=0.937207
         WinHeight=0.808281
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_bk=GUIImage'ROInterface.ROControlBinder.BindBk'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     i_FrameBG=FloatingImage'ROInterface.ROControlBinder.FloatingFrameBackground'

}
