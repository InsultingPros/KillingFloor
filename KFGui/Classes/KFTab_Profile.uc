class KFTab_Profile extends UT2K4TabPanel;

//================================================================================
// 3D View
//================================================================================
var automated GUISectionBackground	i_BG3DView;
var automated GUIImage				i_Portrait;
var automated GUIButton				b_3DView;
var automated GUIButton				b_Pick;
var automated GUIButton				b_DropTarget;

var() editinline editconst noexport KFSpinnyWeap	SpinnyDude; // MUST be set to null when you leave the window
var() vector										SpinnyDudeOffset;
var() bool											bRenderDude;
var localized string								ShowPortraitCaption;
var localized string								Show3DViewCaption;

var() string				sChar, sCharD;
var() int					nFOV;
var() xUtil.PlayerRecord	PlayerRec;

//================================================================================
// Perks
//================================================================================
var automated GUISectionBackground	i_BGPerks;
var	automated KFPerkSelectListBox	lb_PerkSelect;

var automated GUISectionBackground	i_BGPerkEffects;
var automated GUIScrollTextBox		lb_PerkEffects;

var automated GUISectionBackground	i_BGPerkNextLevel;
var	automated KFPerkProgressListBox	lb_PerkProgress;

var KFSteamStatsAndAchievements KFStatsAndAchievements;

//================================================================================
// Bio
//================================================================================
var automated GUISectionBackground	i_BGBio;
var automated GUIScrollTextBox		lb_Scroll;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.Initcomponent(MyController, MyOwner);

	// Spawn spinning character actor
	if ( SpinnyDude == None )
	{
		SpinnyDude = PlayerOwner().Spawn(class'KFGui.KFSpinnyWeap');
	}

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;

	b_3DView.Caption = Show3DViewCaption;

	lb_PerkSelect.List.OnChange = OnPerkSelected;

	i_BGBio.Managecomponent(lb_Scroll);

	OnDeActivate = SaveSettings;
}

event Opened(GUIComponent Sender)
{
	local rotator R;

	Super.Opened(Sender);

	if ( SpinnyDude != None )
	{
		R.Yaw = 32768;
		R.Pitch = 0;
		SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
		SpinnyDude.bHidden = false;
	}
}

function ShowPanel(bool bShow)
{
	if ( bShow )
	{
		if ( bInit )
		{
			bRenderDude = True;
			bInit = False;
		}

		if ( PlayerOwner() != none )
		{
			KFStatsAndAchievements = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements);
			if ( KFStatsAndAchievements != none )
			{
				// Initialize the List
				lb_PerkSelect.List.InitList(KFStatsAndAchievements);
				lb_PerkProgress.List.InitList();
			}
		}
	}

	lb_PerkSelect.SetPosition(i_BGPerks.WinLeft + 6.0 / float(Controller.ResX),
						  	  i_BGPerks.WinTop + 38.0 / float(Controller.ResY),
							  i_BGPerks.WinWidth - 10.0 / float(Controller.ResX),
							  i_BGPerks.WinHeight - 35.0 / float(Controller.ResY),
							  true);


	SetVisibility(bShow);
}

function SetPlayerRec()
{
	local int i;
	local array<xUtil.PlayerRecord> PList;

	class'xUtil'.static.GetPlayerList(PList);

	// Filter out to only characters without the 's' menu setting
	for ( i = 0; i < PList.Length; i++ )
	{
		if ( sChar ~= Plist[i].DefaultName )
		{
			PlayerRec = PList[i];
			break;
		}
	}

	UpdateScroll();
	ShowSpinnyDude();
}

function ShowSpinnyDude()
{
	if ( bRenderDude )
	{
		UpdateSpinnyDude(); // Load current character
		b_3DView.Caption = ShowPortraitCaption; // Change button caption
		b_DropTarget.MouseCursorIndex = 5;
	}
	else
	{
		// Put text back into box
		i_Portrait.Image = PlayerRec.Portrait;
		b_3DView.Caption = Show3DViewCaption;
		SpinnyDude.LinkMesh(None);
		b_DropTarget.MouseCursorIndex = 0;
	}
}

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu("KFGui.KFModelSelect", PlayerRec.DefaultName, Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
	{
		Controller.ActivePage.OnClose = ModelSelectClosed;
	}

	return true;
}

function ModelSelectClosed( optional bool bCancelled )
{
	local string str;

	if ( bCancelled )
		return;

	str = Controller.ActivePage.GetDataString();
	if ( str != "" )
	{
		sChar = str;
		SetPlayerRec();
	}
}

function bool OnSpinnyDudeCapturedMouseMove(float deltaX, float deltaY)
{
	local rotator r;
  	r = SpinnyDude.Rotation;
	r.Yaw -= (256 * DeltaX);
	SpinnyDude.SetRotation(r);
	return true;
}

function UpdateSpinnyDude()
{
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
	local string BodySkinName, HeadSkinName;
	local bool bBrightSkin;

	i_Portrait.Image = PlayerRec.Portrait;
	PlayerMesh = Mesh(DynamicLoadObject(PlayerRec.MeshName, class'Mesh'));
	if ( PlayerMesh == none )
	{
		Log("Could not load mesh: "$PlayerRec.MeshName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	// Get the body skin
	BodySkinName = PlayerRec.BodySkinName;
	bBrightSkin = class'DMMutator'.default.bBrightSkins && Left(BodySkinName,12) ~= "PlayerSkins.";

	// Get the head skin
	HeadSkinName = PlayerRec.FaceSkinName;

	BodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
	if ( BodySkin == none )
	{
		Log("Could not load body material: "$PlayerRec.BodySkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if ( HeadSkin == none )
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim('Profile_idle');
}

function bool Toggle3DView(GUIComponent Sender)
{
	bRenderDude = !bRenderDude;
	ShowSpinnyDude();

	return true;
}

function bool InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float oOrgX, oOrgY;
	local float oClipX, oClipY;

	if ( bRenderDude )
	{
		oOrgX = Canvas.OrgX;
		oOrgY = Canvas.OrgY;
		oClipX = Canvas.ClipX;
		oClipY = Canvas.ClipY;

		Canvas.OrgX = b_DropTarget.ActualLeft();
		Canvas.OrgY = b_DropTarget.ActualTop();
		Canvas.ClipX = b_DropTarget.ActualWidth();
		Canvas.ClipY = b_DropTarget.ActualHeight();

		canvas.GetCameraLocation(CamPos, CamRot);
		GetAxes(CamRot, X, Y, Z);

		SpinnyDude.SetLocation(CamPos + ((SpinnyDudeOffset.X + ((oClipX / oClipY) * 120.0)) * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
		canvas.DrawActorClipped(SpinnyDude, false,  b_DropTarget.ActualLeft(), b_DropTarget.ActualTop(), b_DropTarget.ActualWidth(), b_DropTarget.ActualHeight(), true, nFov);

		Canvas.OrgX = oOrgX;
		Canvas.OrgY = oOrgY;
		Canvas.ClipX = oClipX;
		Canvas.ClipY = oClipY;
	}

	return bRenderDude;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;

	PC = PlayerOwner();

	if ( Sender == i_Portrait )
	{
		sChar = PC.GetUrlOption("Character");
		sCharD = sChar;
		SetPlayerRec();
	}
}

function UpdateScroll()
{
	lb_Scroll.SetContent(Controller.LoadDecoText("KFGUI",PlayerRec.DefaultName));
}

function SaveSettings()
{
	local PlayerController PC;

	PC = PlayerOwner();

	if ( sChar != sCharD )
	{
		sCharD = sChar;
		PC.ConsoleCommand("ChangeCharacter"@sChar);

		if ( !PC.IsA('xPlayer') )
		{
			PC.UpdateURL("Character", sChar, True);
		}

		if ( PlayerRec.Sex ~= "Female" )
		{
			PC.UpdateURL("Sex", "F", True);
		}
		else
		{
			PC.UpdateURL("Sex", "M", True);
		}
	}

	class'KFPlayerController'.default.SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];

	if ( KFPlayerController(PC) != none )
	{
		KFPlayerController(PC).SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];
		KFPlayerController(PC).SendSelectedVeterancyToServer();
		PC.SaveConfig();
	}
	else
	{
		class'KFPlayerController'.static.StaticSaveConfig();
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	KFStatsAndAchievements = none;

	Super.Closed(Sender, bCancelled);

	if ( SpinnyDude != None )
		SpinnyDude.bHidden = true;
}

function Free()
{
	Super.Free();

	if ( SpinnyDude != None )
		SpinnyDude.Destroy();

	SpinnyDude = None;
}

function OnPerkSelected(GUIComponent Sender)
{
	if ( KFStatsAndAchievements.bUsedCheats )
	{
		lb_PerkEffects.SetContent(class'LobbyMenu'.default.PerksDisabledString);
	}
	else
	{
		lb_PerkEffects.SetContent(class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()].default.LevelEffects[KFStatsAndAchievements.PerkHighestLevelAvailable(lb_PerkSelect.GetIndex())]);

		lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, lb_PerkSelect.GetIndex());
	}
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BG3DView
         Caption="3D View"
         WinTop=0.017969
         WinLeft=-0.001276
         WinWidth=0.306758
         WinHeight=0.963631
         OnPreDraw=BG3DView.InternalPreDraw
     End Object
     i_BG3DView=GUISectionBackground'KFGui.KFTab_Profile.BG3DView'

     Begin Object Class=GUIImage Name=PlayerPortrait
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.094895
         WinLeft=0.010624
         WinWidth=0.284623
         WinHeight=0.798132
         RenderWeight=0.300000
         OnDraw=KFTab_Profile.InternalDraw
         OnLoadINI=KFTab_Profile.InternalOnLoadINI
     End Object
     i_Portrait=GUIImage'KFGui.KFTab_Profile.PlayerPortrait'

     Begin Object Class=GUIButton Name=Player3DView
         Caption="3D View"
         Hint="Toggle between 3D view and portrait of character."
         WinTop=0.901559
         WinLeft=0.008073
         WinWidth=0.096281
         WinHeight=0.050000
         TabOrder=1
         OnClick=KFTab_Profile.Toggle3DView
         OnKeyEvent=Player3DView.InternalOnKeyEvent
     End Object
     b_3DView=GUIButton'KFGui.KFTab_Profile.Player3DView'

     Begin Object Class=GUIButton Name=bPickModel
         Caption="Change Character"
         Hint="Select a new Character."
         WinTop=0.901559
         WinLeft=0.109674
         WinWidth=0.184930
         WinHeight=0.050000
         TabOrder=2
         OnClick=KFTab_Profile.PickModel
         OnKeyEvent=bPickModel.InternalOnKeyEvent
     End Object
     b_Pick=GUIButton'KFGui.KFTab_Profile.bPickModel'

     Begin Object Class=GUIButton Name=DropTarget
         StyleName="NoBackground"
         WinTop=0.074426
         WinLeft=0.000010
         WinWidth=0.305500
         WinHeight=0.838132
         MouseCursorIndex=5
         bTabStop=False
         bNeverFocus=True
         bDropTarget=True
         OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=KFTab_Profile.OnSpinnyDudeCapturedMouseMove
     End Object
     b_DropTarget=GUIButton'KFGui.KFTab_Profile.DropTarget'

     SpinnyDudeOffset=(X=120.000000)
     ShowPortraitCaption="Portrait"
     Show3DViewCaption="3D View"
     nfov=15
     Begin Object Class=GUISectionBackground Name=BGPerks
         bFillClient=True
         Caption="Select Perk"
         WinTop=0.017969
         WinLeft=0.313418
         WinWidth=0.338980
         WinHeight=0.714653
         OnPreDraw=BGPerks.InternalPreDraw
     End Object
     i_BGPerks=GUISectionBackground'KFGui.KFTab_Profile.BGPerks'

     Begin Object Class=KFPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.082969
         WinLeft=0.323418
         WinWidth=0.318980
         WinHeight=0.654653
     End Object
     lb_PerkSelect=KFPerkSelectListBox'KFGui.KFTab_Profile.PerkSelectList'

     Begin Object Class=GUISectionBackground Name=BGPerkEffects
         bFillClient=True
         Caption="Perk Effects"
         WinTop=0.017969
         WinLeft=0.660121
         WinWidth=0.339980
         WinHeight=0.352235
         OnPreDraw=BGPerkEffects.InternalPreDraw
     End Object
     i_BGPerkEffects=GUISectionBackground'KFGui.KFTab_Profile.BGPerkEffects'

     Begin Object Class=GUIScrollTextBox Name=PerkEffectsScroll
         CharDelay=0.002500
         EOLDelay=0.100000
         OnCreateComponent=PerkEffectsScroll.InternalOnCreateComponent
         WinTop=0.077969
         WinLeft=0.670121
         WinWidth=0.319980
         WinHeight=0.292235
         TabOrder=9
     End Object
     lb_PerkEffects=GUIScrollTextBox'KFGui.KFTab_Profile.PerkEffectsScroll'

     Begin Object Class=GUISectionBackground Name=BGPerksNextLevel
         bFillClient=True
         Caption="Next Level Requirements"
         WinTop=0.379668
         WinLeft=0.660121
         WinWidth=0.339980
         WinHeight=0.352235
         OnPreDraw=BGPerksNextLevel.InternalPreDraw
     End Object
     i_BGPerkNextLevel=GUISectionBackground'KFGui.KFTab_Profile.BGPerksNextLevel'

     Begin Object Class=KFPerkProgressListBox Name=PerkProgressList
         OnCreateComponent=PerkProgressList.InternalOnCreateComponent
         WinTop=0.439668
         WinLeft=0.670121
         WinWidth=0.319980
         WinHeight=0.292235
     End Object
     lb_PerkProgress=KFPerkProgressListBox'KFGui.KFTab_Profile.PerkProgressList'

     Begin Object Class=GUISectionBackground Name=BGBiography
         bFillClient=True
         Caption="Biography"
         LeftPadding=0.020000
         RightPadding=0.020000
         TopPadding=0.020000
         BottomPadding=0.020000
         WinTop=0.743131
         WinLeft=0.313418
         WinWidth=0.686687
         WinHeight=0.237964
         OnPreDraw=BGBiography.InternalPreDraw
     End Object
     i_BGBio=GUISectionBackground'KFGui.KFTab_Profile.BGBiography'

     Begin Object Class=GUIScrollTextBox Name=PlayerScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=PlayerScroll.InternalOnCreateComponent
         WinTop=0.321365
         WinLeft=0.291288
         WinWidth=0.686915
         WinHeight=0.260351
         TabOrder=9
     End Object
     lb_Scroll=GUIScrollTextBox'KFGui.KFTab_Profile.PlayerScroll'

     WinTop=0.150000
     WinHeight=0.720000
}
