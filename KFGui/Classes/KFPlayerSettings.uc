class KFPlayerSettings extends UT2K4Tab_PlayerSettings;

var() int	   CashThrowAmount,CashThrowAmountD;
var automated moNumericEdit nu_CashThrowSum;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super(Settings_Tabs).Initcomponent(MyController, MyOwner);

	co_Hand.AddItem(HandNames[0]);
	co_Hand.AddItem(HandNames[1]);
	co_Hand.AddItem(HandNames[2]);
	co_Hand.AddItem(HandNames[3]);
	co_Hand.ReadOnly(true);

	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.bPlayCrouches = false;
	SpinnyDude.bPlayRandomAnims = false;

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;

	b_3DView.Caption = Show3DViewCaption;

	ed_Name.MyEditBox.bConvertSpaces = true;
	ed_Name.MyEditBox.MaxWidth=16;  // as per polge, check UT2K4Tab_PlayerSettings if you change this

	i_BG2.Managecomponent(ed_Name);
	i_BG2.Managecomponent(co_Hand);
	i_BG2.Managecomponent(ch_SmallWeaps);
	i_BG3.Managecomponent(lb_Scroll);

	nu_CashThrowSum.MyNumericEdit.Step = 10;
	i_BG2.Managecomponent(nu_CashThrowSum);
}

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu("KFGUI.KFModelSelect",
							  PlayerRec.DefaultName,
							  Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
		Controller.ActivePage.OnClose = ModelSelectClosed;

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
	if(PlayerMesh == None)
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
	if(BodySkin == None)
	{
		Log("Could not load body material: "$PlayerRec.BodySkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}


	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim( 'Idle_Rest');
}


event Opened(GUIComponent Sender)
{
	local rotator R;

	Super.Opened(Sender);

	if ( SpinnyDude != None )
	{
		R.Yaw = 32768;
		R.Pitch = 5024;
		SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
		SpinnyDude.bHidden = false;
	}
}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
	local rotator r;
	r = SpinnyDude.Rotation;
	SpinnyDude.SetRotation(r);
	return true;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;

	PC = PlayerOwner();
	if (GUIMenuOption(Sender) != None)
	{
		switch (GUIMenuOption(Sender))
		{
		case ed_Name:
			sName = Controller.SteamGetUserName();
			sNameD = sName;
			ed_Name.SetText(sName);
			break;

		case co_Hand:
			iHand = PC.Handedness + 1;
			iHandD = iHand;
			co_Hand.SetIndex(iHand);
			break;

		case nu_CashThrowSum:
			if ( KFPlayerReplicationInfo(PC.PlayerReplicationInfo)==None )
				CashThrowAmount = 50;
			else
				CashThrowAmount = KFPlayerReplicationInfo(PC.PlayerReplicationInfo).CashThrowAmount;
			nu_CashThrowSum.SetValue(CashThrowAmount);
			break;
		case ch_SmallWeaps:
			bWeaps = Class'KFPawn'.Default.bRealDeathType;
			bWeapsD = bWeaps;
			ch_SmallWeaps.Checked(bWeaps);
			break;

		default:
			log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
			GUIMenuOption(Sender).SetComponentValue(s,true);
		}
	}

	else if ( Sender == i_Portrait )
	{
		sChar = PC.GetUrlOption("Character");
		sCharD = sChar;
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();
	Super.InternalOnChange(Sender);
	if (GUIMenuOption(Sender) != None)
	{
		switch (GUIMenuOption(Sender))
		{
			case ed_Name:
				sName = ed_Name.GetText();
				break;

			case co_Hand:
				iHand = co_Hand.GetIndex();
				break;

			case nu_CashThrowSum:
				CashThrowAmount = nu_CashThrowSum.GetValue();
				break;
		}
	}
}
function UpdateVoiceOptions();

function ShowSpinnyDude()
{
	if ( bRenderDude )
	{
		UpdateSpinnyDude(); // Load current character
		b_3DView.Caption = ShowBioCaption; // Change button caption
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

function SaveSettings()
{
	local bool bSave;
	local PlayerController PC;

	Super.SaveSettings();
	PC = PlayerOwner();

	if (sNameD != sName)
	{
		PC.ReplaceText(sName, "\"", "");
		sNameD = sName;
		PC.ConsoleCommand("SetName"@sName);
	}

	if (iTeam == 2)
		iTeam = 255;

	if (iTeamD != iTeam)
	{
		iTeamD = iTeam;
		PC.UpdateUrl("Team", string(iTeam), True);
		PC.ChangeTeam(iTeam);
	}

	if (iTeam == 255)
		iTeam = 2;

	if (bWeapsD != bWeaps)
	{
		bWeapsD = bWeaps;
		Class'KFPawn'.Default.bRealDeathType = bWeaps;
		Class'KFPawn'.Static.StaticSaveConfig();
	}

	if (iHandD != iHand)
	{
		iHandD = iHand;
		PC.Handedness = iHand - 1;
		PC.SetHand(iHand - 1);
		bSave = False;
	}

	if (iFOVD != iFOV)
	{
		iFOVD = iFOV;
		PC.FOV( float(iFOV) );
		bSave = False;
	}

	if (sChar != sCharD)
	{
		sCharD = sChar;
		PC.ConsoleCommand("ChangeCharacter"@sChar);
		if ( PC.IsA('xPlayer') )
			bSave = False;
		else PC.UpdateURL("Character", sChar, True);

		if ( PlayerRec.Sex ~= "Female" )
			PC.UpdateURL("Sex", "F", True);
		else
			PC.UpdateURL("Sex", "M", True);
	}

	if (sVoice != sVoiceD)
	{
		sVoiceD = sVoice;
		PC.SetVoice(sVoice);
	}

	if (bSave)
		PC.SaveConfig();
}

function ResetClicked()
{
	local int i;
	local bool bTemp;
	local PlayerController PC;

	super(Settings_Tabs).ResetClicked();

	PC = PlayerOwner();
	PC.ConsoleCommand("ChangeCharacter Jakob");
	PC.ChangeTeam(255);

	PC.UpdateURL("Character", "Jakob", True);
	PC.UpdateURL("Sex", "M", True);
	PC.UpdateURL("Team", "255", True);

	class'Controller'.static.ResetConfig("Handedness");
	class'PlayerController'.static.ResetConfig("bSmallWeapons");
	class'PlayerController'.static.ResetConfig("DefaultFOV");

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	for (i = 0; i < Controls.Length; i++)
		Controls[i].LoadINI();

    bRenderDude = True;
    SetPlayerRec();

	Controller.bCurMenuInitialized = bTemp;
}

defaultproperties
{
     Begin Object Class=moNumericEdit Name=CashThrowBox
         MinValue=1
         MaxValue=1000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Cash Throw Amount"
         OnCreateComponent=CashThrowBox.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="50"
         Hint="This is the amount of cash you throw each time you press the Drop Cash key"
         WinTop=0.076042
         WinLeft=0.705430
         WinWidth=0.266797
         TabOrder=5
         OnLoadINI=KFPlayerSettings.InternalOnLoadINI
     End Object
     nu_CashThrowSum=moNumericEdit'KFGui.KFPlayerSettings.CashThrowBox'

     SpinnyDudeOffset=(X=30.000000,Z=-35.000000)
     Begin Object Class=moCheckBox Name=PlayerSmallWeap
         CaptionWidth=0.940000
         Caption="Real Death FX"
         OnCreateComponent=PlayerSmallWeap.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Makes your camera show from ur eyes when you DIE."
         WinTop=0.150261
         WinLeft=0.705430
         WinWidth=0.266797
         TabOrder=8
         OnLoadINI=KFPlayerSettings.InternalOnLoadINI
     End Object
     ch_SmallWeaps=moCheckBox'KFGui.KFPlayerSettings.PlayerSmallWeap'

     co_Team=None

     co_Voice=None

     nu_FOV=None

     co_SkinPreview=None

     nfov=60
}
