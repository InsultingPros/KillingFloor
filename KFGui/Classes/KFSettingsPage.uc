class KFSettingsPage extends UT2K4SettingsPage;

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
     t_Footer=UT2K4Settings_Footer'KFGui.KFSettingsPage.SettingFooter'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFSettingsPage.PageBackground'

     PanelClass(0)="KFGUI.KFGameSettings"
     PanelClass(1)="KFGUI.KFTab_DetailSettings"
     PanelClass(2)="KFGUI.KFAudioSettingsTab"
     PanelClass(3)="KFGUI.KFTab_Controls"
     PanelClass(4)="KFGUI.KFInputSettings"
     PanelClass(5)="KFGUI.KFHUDSettings"
     PanelClass(6)=
     PanelCaption(0)="Game"
     PanelCaption(1)="Display"
     PanelCaption(2)="Audio"
     PanelCaption(3)="Controls"
     PanelCaption(5)="Hud"
     PanelCaption(6)="none"
     PanelHint(0)="Configure your Killing Floor game..."
     PanelHint(1)="Select your resolution or change your display and detail settings..."
     PanelHint(2)="Adjust your audio experience..."
     PanelHint(3)="Configure your keyboard controls..."
     PanelHint(5)="Customize your HUD..."
     PanelHint(6)="none"
}
