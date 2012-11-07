class KFProfileAndAchievements extends UT2K4MainPage;

var() editconst noexport float	SavedPitch;
var() UT2K4TabPanel				ActivePanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local rotator PlayerRot;
	local int i;

    Super.InitComponent(MyController, MyOwner);

    // Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
    PlayerRot = PlayerOwner().Rotation;
    SavedPitch = PlayerRot.Pitch;
    PlayerRot.Pitch = 0;
    PlayerRot.Roll = 0;
    PlayerOwner().SetRotation(PlayerRot);

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		c_Tabs.AddTab(PanelCaption[i], PanelClass[i],, PanelHint[i]);
	}
}

function DrawSteamName(Canvas Canvas)
{
	local string UserName;
	local float TextWidth, TextHeight;

	UserName = Controller.SteamGetUserName();

	Canvas.DrawColor = class'HUD'.default.WhiteColor;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);

	Canvas.StrLen(UserName, TextWidth, TextHeight);

	Canvas.SetPos(((c_Tabs.WinLeft + c_Tabs.WinWidth) * Canvas.ClipX) - TextWidth - (5.0 * (Canvas.ClipX / 1024.0)), ((c_Tabs.WinTop + (c_Tabs.WinHeight / 2.0)) * Canvas.ClipY) - (TextHeight / 2.0));

	Canvas.DrawText(UserName);
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);

	if ( c_Tabs.ActiveTab == None )
	{
		ActivePanel = None;
	}
	else
	{
		ActivePanel = UT2K4TabPanel(c_Tabs.ActiveTab.MyPanel);
	}
}

function InternalOnClose(optional bool bCanceled)
{
    local rotator NewRot;

    // Reset player
    NewRot = PlayerOwner().Rotation;
    NewRot.Pitch = SavedPitch;
    PlayerOwner().SetRotation(NewRot);

    Super.OnClose(bCanceled);
}

function BackButtonClicked()
{
	c_Tabs.ActiveTab.OnDeActivate();
	Controller.CloseMenu(False);
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=Header
         Caption="Profile And Achievements"
         WinHeight=25.000000
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'KFGui.KFProfileAndAchievements.Header'

     Begin Object Class=KFProfileAndAchievements_Footer Name=Footer
         OnSaveButtonClicked=KFProfileAndAchievements.BackButtonClicked
         RenderWeight=0.300000
         TabOrder=4
         OnPreDraw=Footer.InternalOnPreDraw
     End Object
     t_Footer=KFProfileAndAchievements_Footer'KFGui.KFProfileAndAchievements.Footer'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFProfileAndAchievements.PageBackground'

     PanelClass(0)="KFGui.KFTab_Profile"
     PanelClass(1)="KFGui.KFTab_Achievements"
     PanelCaption(0)="Profile"
     PanelCaption(1)="Achievements"
     PanelHint(0)="Select your Avatar and Perk..."
     PanelHint(1)="View Achievement Progress..."
     BackgroundColor=(B=0,G=0,R=0)
     OnClose=KFProfileAndAchievements.InternalOnClose
     OnRendered=KFProfileAndAchievements.DrawSteamName
}
