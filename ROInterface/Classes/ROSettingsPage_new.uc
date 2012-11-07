//=============================================================================
// ROSettingsPage_new
//=============================================================================
// The container page for all the settings tabs.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROSettingsPage_new extends UT2K4SettingsPage;

function bool InternalOnCanClose(optional bool bCanceled)
{
    return true;
}

defaultproperties
{
     Begin Object Class=UT2K4Settings_Footer Name=SettingFooter
         Spacer=0.010000
         RenderWeight=0.300000
         TabOrder=4
         OnPreDraw=SettingFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4Settings_Footer'ROInterface.ROSettingsPage_new.SettingFooter'

     PanelClass(0)="ROInterface.ROTab_GameSettings"
     PanelClass(1)="ROInterface.ROTab_DetailSettings"
     PanelClass(2)="ROInterface.ROTab_AudioSettings"
     PanelClass(3)="ROInterface.ROTab_Controls"
     PanelClass(4)="ROInterface.ROTab_Input"
     PanelClass(5)="ROInterface.ROTab_Hud"
     PanelClass(6)="none"
     PanelCaption(0)="Game"
     PanelCaption(1)="Display"
     PanelCaption(2)="Audio"
     PanelCaption(3)="Controls"
     PanelCaption(5)="Hud"
     PanelCaption(6)="none"
     PanelHint(0)="Configure your Red Orchestra game..."
     PanelHint(1)="Select your resolution or change your display and detail settings..."
     PanelHint(2)="Adjust your audio experience..."
     PanelHint(3)="Configure your keyboard controls..."
     PanelHint(5)="Customize your HUD..."
     PanelHint(6)="none"
     Background=Texture'menuBackground.MainBackGround'
}
