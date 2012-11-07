// ====================================================================
// Onslaught minimap tab
//
// Written by Matt Oelfke
// (C) 2003, Epic Games, Inc. All Rights Reserved
// ====================================================================

class UT2K4Tab_OnslaughtMap extends MidGamePanel;

// Commented out UT2k4Merge - Ramm
/*
var() float OnslaughtMapCenterX, OnslaughtMapCenterY, OnslaughtMapRadius;

var automated GUIFooter f_Legend;

var automated GUILabel l_HelpText, l_HintText, l_TeamText;
var automated GUIButton b_Designer;	//calls up the link designer
var automated moComboBox co_MenuOptions;

var automated GUIImage i_Background, i_HintImage, i_Team;

var() localized string MapPreferenceStrings[3];
var() localized string NodeTeleportHelpText,
                     SetDefaultText,
                     ChooseSpawnText,
					 ClearDefaultText,
					 SetDefaultHint,
					 ClearDefaultHint,
					 SpawnText,
					 TeleportText,
					 SpawnHint,
					 TeleportHint,
					 SelectedHint,
					 UnderAttackHint,
					 CoreHint,
					 NodeHint,
					 UnclaimedHint,
					 LockedHint;

var() localized string Titles[6];
var() localized string NewSelectedHint, NewTeleportHint, EnemyCoreHint;
var   localized string DefendMsg;

var color TColor[2];


var() material NodeImage;

var() color SelectionColor;
var() bool bNodeTeleporting; //this page is open because the player wants to node teleport

// Actor references - these must be cleared at level change
var ONSPlayerReplicationInfo PRI;
var ONSPowerCore SelectedCore;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int x;

	Super.InitComponent(MyController, MyOwner);

	for (x = 0; x < 3; x++)
		co_MenuOptions.AddItem(MapPreferenceStrings[x]);
}

event Opened( GUIComponent Sender )
{
	Super.Opened(Sender);
	bNodeTeleporting = false;
}

//called to inform tab that it should be in Node Teleport mode instead of Select Spawn Point mode
function NodeTeleporting()
{
	bNodeTeleporting = true;
}

function ShowPanel(bool bShow)
{
	local string colorname,t;
	Super.ShowPanel(bShow);

	if ( bShow )
	{
		if ( (PRI != None) && (PRI.Team != None) )
		{
    		colorname = PRI.Team.ColorNames[PRI.Team.TeamIndex];
			t = Repl(DefendMsg, "%t", colorname, false);
			l_TeamText.Caption = t;

			i_Team.Image = PRI.Level.GRI.TeamSymbols[PRI.Team.TeamIndex];
			i_Team.ImageColor = TColor[PRI.Team.TeamIndex];
		}
		if (PRI != None && (PRI.Level.NetMode == NM_Standalone || (PRI.bAdmin && PRI.Level.GRI != None && !PRI.Level.GRI.bMatchHasBegun)))
			b_Designer.Show();
		else
			b_Designer.Hide();
	}

}

function bool InternalOnPreDraw( Canvas C )
{
	local ONSPowerCore Core;
	local ONSHudOnslaught ONSHUD;

	ONSHUD = ONSHudOnslaught(PlayerOwner().myHud);
	Core = ONSHUD.LocatePowerCore(Controller.MouseX - OnslaughtMapCenterX, Controller.MouseY - OnslaughtMapCenterY, OnslaughtMapRadius);

	if ( Core == None || Core.CoreStage == 255 || Core.PowerLinks.Length == 0 )
	{
		l_HintText.Caption = "";
		l_HelpText.Caption = "";
		i_HintImage.Image = None;

		l_TeamText.SetVisibility(true);

	}

	else
	{
		l_TeamText.SetVisibility(false);

		if ( Core.bUnderAttack || (Core.CoreStage == 0 && Core.bSevered) )
			DrawAttackHint();
		else if ( PRI != None && Core == PRI.StartCore )
			DrawSpawnHint();
		else if (Core.bFinalCore)
		{
			if (Core.DefenderTeamIndex == PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
				DrawCoreHint(true);
			else
				DrawCoreHint(false);
		}
		else DrawNodeHint( ONSHUD, Core );
	}

	return false;
}

function DrawAttackHint()
{
	l_HintText.Caption = UnderAttackHint;
	SetHintImage(NodeImage,0,64,64,64);
	l_HelpText.Caption=Titles[0];
}

function DrawSpawnHint()
{
	l_HintText.Caption = SelectedHint;
	SetHintImage( NodeImage, 64, 64, 64, 64);
	l_HelpText.Caption=Titles[1];
}

function DrawCoreHint(bool HomeTeam)
{
	if (!HomeTeam)
	{
		l_HintText.Caption = EnemyCoreHint;
		SetHintImage( NodeImage, 65, 0, 62, 64 );
		return;
	}

	l_HintText.Caption = CoreHint;
	SetHintImage( NodeImage, 65, 0, 62, 64 );
	l_HelpText.Caption=Titles[2];

	if (bNodeTeleporting)
		L_HintText.Caption = l_HintText.Caption$NewTeleportHint;

	l_HintText.Caption = l_HintText.Caption$NewSelectedHint;
}

function DrawNodeHint( ONSHudOnslaught HUD, ONSPowerCore Core )
{
	if ( HUD == None || Core == None )
		return;

    if (Core.CoreStage == 4)
    {
        if (HUD.PowerCoreAttackable(Core))
        {
			l_HintText.Caption = UnclaimedHint;
			SetHintImage( NodeImage,0,0,31,32);
			l_HelpText.Caption=Titles[3];
        }
        else
        {
        	l_HintText.Caption = LockedHint;
        	SetHintImage( NodeImage,0,32,31,32);
        	l_HelpText.Caption=Titles[4];
        }
    }
    else if (HUD.PowerCoreAttackable(Core))
    {
    	l_HintText.Caption = NodeHint;
    	SetHintImage( NodeImage, 32,0,32,31);
    	l_HelpText.Caption=Titles[5];
    }
    else
    {
    	l_HintText.Caption = LockedHint;
    	SetHintImage( NodeImage,0,32,31,32);
    	l_HelpText.Caption=Titles[4];
    }

	if (PlayerOwner().PlayerReplicationInfo.Team != None && Core.DefenderTeamIndex == PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
	{
		if (bNodeTeleporting)
			L_HintText.Caption = l_HintText.Caption$NewTeleportHint;

		if (!HUD.PowerCoreAttackable(Core) )
			l_HintText.Caption = l_HintText.Caption$NewSelectedHint;
	}
}

function SetHintImage( Material NewImage, int X1, int Y1, int X2, int Y2 )
{
	i_HintImage.Image = NewImage;
	i_HintImage.X1 = X1;
	i_HintImage.X2 = X1 + X2;
	i_HintImage.Y1 = Y1;
	i_HintImage.Y2 = Y1 + Y2;
}

function bool PreDrawMap(Canvas C)
{
	local float L,T,W,H;
	OnslaughtMapRadius = fmin( i_Background.ActualHeight(),i_Background.ActualWidth() ) / 2;
	OnslaughtMapCenterX = i_Background.Bounds[0] + OnslaughtMapRadius;
	OnslaughtMapCenterY = i_Background.Bounds[1] + i_Background.ActualHeight() / 2;

	l_HelpText.bBoundToParent=false;
	l_HelpText.bScaleToParent=false;

	l_HintText.bScaleToParent=false;
	l_HintText.bBoundToParent=false;

	i_HintImage.bScaleToParent=false;
	i_HintImage.bBoundToParent=false;

	l_TeamText.bScaleToParent=false;
	l_TeamText.bBoundToParent=false;

	i_Team.bScaleToParent=false;
	i_Team.bBoundToParent=false;

	L = OnslaughtMapCenterX + OnslaughtMapRadius + (ActualWidth()*0.05);
	T = OnslaughtMapCenterY - OnslaughtMapRadius;

	W = ActualLeft() + ActualWidth() - L;
	H = ActualTop() + ActualHeight() - T;

	i_HintImage.WinLeft = L;
	i_HintImage.WinTop = T;

	l_HelpText.WinLeft = i_HintImage.ActualLeft() + i_HintImage.ActualWidth() + 8;
	l_HelpText.WinTop = t;
	l_HelpText.WinHeight = i_HintImage.ActualHeight();
	l_HelpTExt.WinWidth = W - i_HintImage.ActualWidth() - 8;

	t += i_HintImage.ActualHeight()+8;
	l_HintText.WinLeft = l;
	l_HintText.WinTop= t;
	l_HintText.WinWidth = w;
	l_HintText.WinHeight = H - i_HintImage.ActualHeight() - 8;

	L = OnslaughtMapCenterX + OnslaughtMapRadius;
	W = ActualLeft() + ActualWidth() - L;

	i_Team.WinLeft = L;
	i_Team.WinWidth = W;
	i_Team.WinHeight = W;
	i_Team.WinTop = i_Background.ActualTop() + i_Background.ActualHeight() - i_Team.ActualHeight();


	l_TeamText.WinLeft = L;
	l_TeamText.WinWidth = W;
	l_TeamText.WinTop = i_Team.ActualTop() - l_TeamText.ActualHeight();

	return false;
}

function bool DrawMap(Canvas C)
{
	local ONSPowerCore Core;
	local ONSHudOnslaught ONSHUD;
	local float HS;

	if ( PRI != None )
		Core = PRI.StartCore;


	ONSHUD = ONSHudOnslaught(PlayerOwner().myHud);
	HS = ONSHUD.HudScale;
	ONSHUD.HudScale=1.0;
	ONSHUD.DrawRadarMap(C, OnslaughtMapCenterX, OnslaughtMapCenterY, OnslaughtMapRadius, false);
	ONSHUD.HudScale=HS;

	if ( Core != None )
		ONSHUD.DrawSpawnIcon(C, Core.HUDLocation, Core.bFinalCore, ONSHUD.IconScale, ONSHUD.HUDScale);

	return true;
}

function InternalOnPostDraw(Canvas Canvas)
{
	PRI = ONSPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if (PRI != None)
	{
		bInit = False;
		co_MenuOptions.SetIndex(PRI.ShowMapOnDeath);
		OnRendered = None;
		ShowPanel(true);
	}
}

function SetSelectedCore()
{
	local ONSPowerCore Core;

	Core = ONSHudOnslaught(PlayerOwner().myHUD).LocatePowerCore(Controller.MouseX - OnslaughtMapCenterX, Controller.MouseY - OnslaughtMapCenterY, OnslaughtMapRadius);
	if ( ValidSpawnPoint(Core) )
		SelectedCore = Core;
	else SelectedCore = None;
}

function bool SelectClick( GUIComponent Sender )
{
	local PlayerController PC;

	if (bInit || PRI == None || PRI.bOnlySpectator)
		return true;

	PC = PlayerOwner();
	SetSelectedCore();
	if ( SelectedCore == None )
		return True;

	if ( SelectedCore == PRI.StartCore )
		PRI.SetStartCore( None, false );
	else PRI.SetStartCore( SelectedCore, false );
}

function bool SpawnClick(GUIComponent Sender)
{
	local PlayerController PC;

	if (bInit || PRI == None || PRI.bOnlySpectator)
		return true;

	PC = PlayerOwner();
	SetSelectedCore();

	if ( SelectedCore == None )
		return True;

	if ( bNodeTeleporting )
	{
		if ( SelectedCore != None )
		{
			Controller.CloseMenu(false);
			PRI.TeleportTo(SelectedCore);
		}
	}
	else
	{
		Controller.CloseMenu(false);
		PRI.SetStartCore( SelectedCore, true );
		PC.ServerRestartPlayer();
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (bInit || PRI == None)
		return true;

	PRI.RequestLinkDesigner();
	return true;
}

function Timer()
{
	local PlayerController PC;

	PC = PlayerOwner();
	PC.ServerRestartPlayer();
	PC.bFire = 0;
	PC.bAltFire = 0;
	Controller.CloseMenu(false);
}

function bool ValidSpawnPoint(ONSPowerCore Core)
{
	if ( Core == None )
		return false;

	if (Core.DefenderTeamIndex == PRI.Team.TeamIndex && Core.CoreStage == 0 && (!Core.bUnderAttack || Core.bFinalCore) && Core.PowerLinks.Length > 0)
		return true;

	return false;
}

function Closed(GUIComponent Sender, bool bCancelled)
{
	local ONSPlayerReplicationInfo.EMapPreference Pref;

	if (PRI != None)
	{
		Pref = EMapPreference(co_MenuOptions.GetIndex());
		if ( Pref != PRI.ShowMapOnDeath )
		{
			PRI.ShowMapOnDeath = Pref;
			PRI.SaveConfig();
		}
	}

	Super.Closed(Sender,bCancelled);
}

function Free()
{
	Super.Free();

	PRI = None;
	SelectedCore = None;
}

function LevelChanged()
{
	Super.LevelChanged();

	PRI = None;
	SelectedCore = None;
}

defaultproperties
{
	NodeImage=Material'NewHUDIcons'

	SelectionColor=(R=255,G=255,B=255,A=255)
	OnslaughtMapCenterX = 0.65
	OnslaughtMapCenterY = 0.40
	OnslaughtMapRadius = 0.30

	MapPreferenceStrings(0)="Never"
	MapPreferenceStrings(1)="When Body is Still"
	MapPreferenceStrings(2)="Immediately"

	ChooseSpawnText="Choose Your Spawn Point"
	NodeTeleportHelpText="Choose Node Teleport Destination"

	SetDefaultText="Set Default"
	ClearDefaultText="Clear Default"

	SetDefaultHint="Set the currently selected node as your preferred spawn location"
	ClearDefaultHint="Allow the game to choose the most appropriate spawn location"

	SpawnText="Spawn Here"
	TeleportText="Teleport Here"

	SpawnHint="Spawn at the currently selected node"
	TeleportHint="Teleport to the currently selected node"

    Begin Object Class=GUILabel Name=HelpText
        TextAlign=TXTA_Left
        TextColor=(B=255,G=255,R=255)
        Caption=""
//        FontScale=FNS_Small
        StyleName="TextLabel"
		WinWidth=0.274188
		WinLeft=0.719388
		WinTop=0.035141
        bBoundToParent=false
        bScaleToParent=false
    End Object
	l_HelpText=HelpText

	Begin Object Class=GUIImage Name=BackgroundImage
		Image=Material'2K4Menus.Controls.OutlineSquare'
		ImageStyle=ISTY_Stretched
		OnPreDraw=PreDrawMap
		OnDraw=DrawMap
		WinWidth=0.634989
		WinHeight=0.747156
		WinLeft=0.029188
		WinTop=0.070134
		bAcceptsInput=True
		OnClick=SpawnClick
		OnRightClick=SelectClick
	End Object
	i_Background=BackgroundImage

    Begin Object Class=GUIImage Name=IconHintImage
        ImageStyle=ISTY_Scaled
        Image=Material'NewHUDIcons'
		WinWidth=0.043667
		WinHeight=0.049502
		WinLeft=0.671639
		WinTop=0.033996
		RenderWeight=0.51
        bBoundToParent=false
        bScaleToParent=false
    End Object
    i_HintImage=IconHintImage

    Begin Object Class=GUILabel Name=HintLabel
    	StyleName="TextLabel"
    	FontScale=FNS_Small
		WinWidth=0.323888
		WinHeight=0.742797
		WinLeft=0.669020
		WinTop=0.117390
		RenderWeight=0.52
		bMultiline=true
        bBoundToParent=false
        bScaleToParent=false
    End Object
    l_HintText=HintLabel

	Begin Object Class=moComboBox Name=MapComboBox
		WinWidth=0.628008
		WinHeight=0.038462
		WinLeft=0.032347
		WinTop=0.866668
		CaptionWidth=0.3
		Caption="Show Map:"
		TabOrder=2
		bReadOnly=true
	End Object
	co_MenuOptions=MapComboBox

	Begin Object Class=GUIButton Name=LinkDesignButton
		WinWidth=0.187876
		WinHeight=0.047400
		WinLeft=0.760387
		WinTop=0.863674
		Caption="Link Designer"
		OnClick=InternalOnClick
		TabOrder=3
		bAutosize=true
		RenderWeight=0.52
	End Object
	b_Designer=LinkDesignButton

	Begin Object Class=GUIImage Name=iTeam
		WinWidth=0.338338
		WinHeight=0.405539
		WinLeft=0.619446
		WinTop=0.400000
		ImageStyle=ISTY_Scaled
		ImageColor=(R=0,G=128,B=255,A=90)
		TabOrder=10
	End Object
	i_Team=iTeam

    Begin Object Class=GUILabel Name=TeamLabel
    	StyleName="TextLabel"
    	Caption="Defend the Red Core"
    	FontScale=FNS_Small
		WinWidth=0.385550
		WinHeight=0.043963
		WinLeft=0.597081
		WinTop=0.391063
		RenderWeight=0.52
		bMultiline=true
		TextAlign=TXTA_Center
    End Object
    l_TeamText=TeamLabel



	 SelectedHint="Preferred spawn location"
	 UnderAttackHint="Node is currently under attack"
	 CoreHint="Main power core"
	 NodeHint="Node is currently vulnerable to enemy attack"
	 UnclaimedHint="Node is currently neutral and may be taken by either team"
	 LockedHint="Node is currently unlinked and may not be attacked by the enemy"

	Titles(0)="Core (Under Attack)"
	Titles(1)="Preferred Node"
	Titles(2)="Core"
	Titles(3)="Node (Unclaimed)"
	Titles(4)="Node (Locked)"
	Titles(5)="Node (Attackable)"

	NewSelectedHint="||Right-Click on this node to select it as the preferred spawn location."
	NewTeleportHint="||Left-Click on this node to teleport to it"
	EnemyCoreHint="Enemy Core||Connect the nodes until you can reach this core"

	OnPreDraw=InternalOnPreDraw
	OnRendered=InternalOnPostDraw

	DefendMsg="Defend the %t core";
	TColor(0)=(R=255,G=100,B=100,A=128)
	TColor(1)=(R=0,G=128,B=255,A=128)

}
*/

defaultproperties
{
}
