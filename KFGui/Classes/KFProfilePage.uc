class KFProfilePage extends UT2K4GUIPage;

var automated KFTab_Profile						ProfilePanel;
var	automated KFProfileAndAchievements_Footer	t_Footer;
var editconst noexport float					SavedPitch;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local rotator PlayerRot;

	Super.InitComponent(MyController, MyOwner);

	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Pitch = 0;
	PlayerRot.Roll = 0;
	PlayerOwner().SetRotation(PlayerRot);

	t_Footer.OnSaveButtonClicked = SaveButtonClicked;

	ProfilePanel.InitComponent(MyController, self);
	ProfilePanel.Opened(self);
	ProfilePanel.ShowPanel(true);
}

function InternalOnClose(optional Bool bCanceled)
{
    local rotator NewRot;

    // Reset player
    NewRot = PlayerOwner().Rotation;
    NewRot.Pitch = SavedPitch;
    PlayerOwner().SetRotation(NewRot);

    Super.OnClose(bCanceled);
}

function SaveButtonClicked()
{
	ProfilePanel.SaveSettings();
	Controller.CloseMenu(False);
}

defaultproperties
{
     Begin Object Class=KFTab_Profile Name=Panel
         WinTop=0.010000
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.960000
     End Object
     ProfilePanel=KFTab_Profile'KFGui.KFProfilePage.Panel'

     Begin Object Class=KFProfileAndAchievements_Footer Name=Footer
         RenderWeight=0.300000
         TabOrder=4
         OnPreDraw=Footer.InternalOnPreDraw
     End Object
     t_Footer=KFProfileAndAchievements_Footer'KFGui.KFProfilePage.Footer'

     bRenderWorld=True
     bAllowedAsLast=True
     BackgroundColor=(B=0,G=20,R=0,A=20)
     InactiveFadeColor=(G=0,R=0,A=64)
     BackgroundRStyle=MSTY_Alpha
     OnClose=KFProfilePage.InternalOnClose
     WinTop=0.000000
     WinHeight=1.000000
}
