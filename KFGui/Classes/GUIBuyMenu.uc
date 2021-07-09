//=============================================================================
// The Trader menu with a tab for the store and the perks
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================


class GUIBuyMenu extends UT2k4MainPage;

//The "Header"
var 	automated 			GUIImage				HeaderBG_Left;
var 	automated 			GUIImage				HeaderBG_Center;
var 	automated 			GUIImage				HeaderBG_Right;

var 	automated			GUILabel				CurrentPerkLabel;
var		automated			GUILabel				TimeLeftLabel;
var 	automated			GUILabel				WaveLabel;

var 	automated			GUILabel				HeaderBG_Left_Label;

var		automated			KFQuickPerkSelect		QuickPerkSelect;

var     automated           KFBuyMenuFilter         BuyMenuFilter;

var 	automated			GUIButton				StoreTabButton;
var 	automated			GUIButton				PerkTabButton;

//The "Footer"
var 	automated 			GUIImage				WeightBG;
var 	automated 			GUIImage				WeightIcon;
var 	automated 			GUIImage				WeightIconBG;
var		automated			KFWeightBar				WeightBar;

//const               BUYLIST_CATS                =7;
var() 	editconst noexport 	float 					SavedPitch;
var							color					RedColor;
var							color					GreenGreyColor;

var() 						UT2K4TabPanel			ActivePanel;

var		localized			string					CurrentPerk;
var		localized			string					NoActivePerk;
var		localized			string					TraderClose;
var		localized			string					WaveString;
var		localized			string					LvAbbrString;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	local int i;

	super.InitComponent(MyC, MyO);

	c_Tabs.BackgroundImage = none;
	c_Tabs.BackgroundStyle = none;

	InitTabs();

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		c_Tabs.TabStack[i].bVisible = false;
	}

	UpdateWeightBar();
}

function InitTabs()
{
	local int i;

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		c_Tabs.AddTab(PanelCaption[i], PanelClass[i],, PanelHint[i]);
	}
}

function UpdateWeightBar()
{
	if ( KFHumanPawn(PlayerOwner().Pawn) != none )
	{
		WeightBar.MaxBoxes = KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight;
		WeightBar.CurBoxes = KFHumanPawn(PlayerOwner().Pawn).CurrentWeight;
	}
}

event Opened(GUIComponent Sender)
{
	local rotator PlayerRot;

	super.Opened(Sender);

	c_Tabs.ActivateTabByName(PanelCaption[0], true);

	// Tell the controller that he is on a shopping spree
    if ( KFPlayerController(PlayerOwner()) != none )
	{
        KFPlayerController(PlayerOwner()).bShopping = true;
    }

    if ( KFWeapon(KFHumanPawn(PlayerOwner().Pawn).Weapon).bAimingRifle )
	{
		KFWeapon(KFHumanPawn(PlayerOwner().Pawn).Weapon).IronSightZoomOut();
	}

	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Yaw = PlayerRot.Yaw % 65536;
	PlayerRot.Pitch = 0;
	PlayerRot.Roll = 0;
	PlayerOwner().SetRotation(PlayerRot);
	SetTimer(0.05f, true);
}

function Timer()
{
	UpdateHeader();
	UpdateWeightBar();
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

function UpdateHeader()
{
	local int TimeLeftMin, TimeLeftSec;
	local string TimeString;

	if ( KFPlayerController(PlayerOwner()) == none || PlayerOwner().PlayerReplicationInfo == none ||
		 PlayerOwner().GameReplicationInfo == none )
	{
		return;
	}

	// Current Perk
	if ( KFPlayerController(PlayerOwner()).SelectedVeterancy != none )
    {
		CurrentPerkLabel.Caption = CurrentPerk$":" @ KFPlayerController(PlayerOwner()).SelectedVeterancy.default.VeterancyName @ LvAbbrString$KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkillLevel;
	}
    else
	{
		CurrentPerkLabel.Caption = CurrentPerk$":" @ NoActivePerk;
	}

	// Trader time left
	TimeLeftMin = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).TimeToNextWave / 60;
	TimeLeftSec = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).TimeToNextWave % 60;

	if ( TimeLeftMin < 1 )
	{
		TimeString = "00:";
	}
	else
	{
		TimeString = "0" $ TimeLeftMin $ ":";
	}

	if ( TimeLeftSec >= 10 )
	{
		TimeString = TimeString $ TimeLeftSec;
	}
	else
	{
		TimeString = TimeString $ "0" $ TimeLeftSec;
	}

	TimeLeftLabel.Caption = TraderClose @ TimeString;

	if ( KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).TimeToNextWave < 10 )
	{
		TimeLeftLabel.TextColor = RedColor;
	}
	else
	{
		TimeLeftLabel.TextColor = GreenGreyColor;
	}

	// Wave Counter
	WaveLabel.Caption = WaveString$":" @ (KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).WaveNumber + 1)$"/"$KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).FinalWave;
}

function KFBuyMenuClosed(optional bool bCanceled)
{
	local rotator NewRot;

	// Reset player
	NewRot = PlayerOwner().Rotation;
	NewRot.Pitch = SavedPitch;
	PlayerOwner().SetRotation(NewRot);

	Super.OnClose(bCanceled);

	if ( KFPlayerController(PlayerOwner()) != none )
	{
        KFPlayerController(PlayerOwner()).bShopping = false;
    }
}

function CloseSale(bool savePurchases)
{
	Controller.CloseMenu(!savePurchases);
}

function bool ButtonClicked(GUIComponent Sender)
{
	if ( Sender == PerkTabButton )
    {
		HandleParameters(PanelCaption[1], "OhHi!");
	}

	if ( Sender == StoreTabButton )
    {
		HandleParameters(PanelCaption[0], "OhHi!");
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=HBGLeft
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         Hint="Perk Quick Select"
         WinTop=0.001000
         WinLeft=0.001000
         WinWidth=0.332300
         WinHeight=0.100000
     End Object
     HeaderBG_Left=GUIImage'KFGui.GUIBuyMenu.HBGLeft'

     Begin Object Class=GUIImage Name=HBGCenter
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         Hint="Trading Time Left"
         WinTop=0.001000
         WinLeft=0.334000
         WinWidth=0.331023
         WinHeight=0.100000
     End Object
     HeaderBG_Center=GUIImage'KFGui.GUIBuyMenu.HBGCenter'

     Begin Object Class=GUIImage Name=HBGRight
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         Hint="Current Perk"
         WinTop=0.001000
         WinLeft=0.666000
         WinWidth=0.332000
         WinHeight=0.100000
     End Object
     HeaderBG_Right=GUIImage'KFGui.GUIBuyMenu.HBGRight'

     Begin Object Class=GUILabel Name=Perk
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         WinTop=0.010000
         WinLeft=0.665000
         WinWidth=0.329761
         WinHeight=0.050000
     End Object
     CurrentPerkLabel=GUILabel'KFGui.GUIBuyMenu.Perk'

     Begin Object Class=GUILabel Name=Time
         Caption="Trader closes in 00:31"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2LargeFont"
         WinTop=0.020952
         WinLeft=0.335000
         WinWidth=0.330000
         WinHeight=0.035000
     End Object
     TimeLeftLabel=GUILabel'KFGui.GUIBuyMenu.Time'

     Begin Object Class=GUILabel Name=Wave
         Caption="Wave: 7/10"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         WinTop=0.052857
         WinLeft=0.336529
         WinWidth=0.327071
         WinHeight=0.035000
     End Object
     WaveLabel=GUILabel'KFGui.GUIBuyMenu.Wave'

     Begin Object Class=GUILabel Name=HBGLL
         Caption="Quick Perk Select"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2ServerListFont"
         WinTop=0.007238
         WinLeft=0.024937
         WinWidth=0.329761
         WinHeight=0.019524
     End Object
     HeaderBG_Left_Label=GUILabel'KFGui.GUIBuyMenu.HBGLL'

     Begin Object Class=KFQuickPerkSelect Name=QS
         WinTop=0.011906
         WinLeft=0.008008
         WinWidth=0.316601
         WinHeight=0.082460
         OnDraw=QS.MyOnDraw
     End Object
     QuickPerkSelect=KFQuickPerkSelect'KFGui.GUIBuyMenu.QS'

     Begin Object Class=KFBuyMenuFilter Name=filter
         WinTop=0.051000
         WinLeft=0.670000
         WinWidth=0.305000
         WinHeight=0.082460
         OnDraw=filter.MyOnDraw
     End Object
     BuyMenuFilter=KFBuyMenuFilter'KFGui.GUIBuyMenu.filter'

     Begin Object Class=GUIButton Name=StoreTabB
         Caption="Store"
         FontScale=FNS_Small
         WinTop=0.072762
         WinLeft=0.202801
         WinWidth=0.050000
         WinHeight=0.022000
         OnClick=GUIBuyMenu.ButtonClicked
         OnKeyEvent=StoreTabB.InternalOnKeyEvent
     End Object
     StoreTabButton=GUIButton'KFGui.GUIBuyMenu.StoreTabB'

     Begin Object Class=GUIButton Name=PerkTabB
         Caption="Perk"
         FontScale=FNS_Small
         WinTop=0.072762
         WinLeft=0.127234
         WinWidth=0.050000
         WinHeight=0.022000
         OnClick=GUIBuyMenu.ButtonClicked
         OnKeyEvent=PerkTabB.InternalOnKeyEvent
     End Object
     PerkTabButton=GUIButton'KFGui.GUIBuyMenu.PerkTabB'

     Begin Object Class=GUIImage Name=Weight
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         WinTop=0.934206
         WinLeft=0.001000
         WinWidth=0.663086
         WinHeight=0.065828
     End Object
     WeightBG=GUIImage'KFGui.GUIBuyMenu.Weight'

     Begin Object Class=GUIImage Name=WeightIco
         Image=Texture'KillingFloorHUD.HUD.Hud_Weight'
         ImageStyle=ISTY_Scaled
         WinTop=0.946166
         WinLeft=0.009961
         WinWidth=0.033672
         WinHeight=0.048992
         RenderWeight=0.460000
     End Object
     WeightIcon=GUIImage'KFGui.GUIBuyMenu.WeightIco'

     Begin Object Class=GUIImage Name=WeightIcoBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.942416
         WinLeft=0.006055
         WinWidth=0.041484
         WinHeight=0.054461
         RenderWeight=0.450000
     End Object
     WeightIconBG=GUIImage'KFGui.GUIBuyMenu.WeightIcoBG'

     Begin Object Class=KFWeightBar Name=WeightB
         WinTop=0.945302
         WinLeft=0.055266
         WinWidth=0.443888
         WinHeight=0.053896
         OnDraw=WeightB.MyOnDraw
     End Object
     WeightBar=KFWeightBar'KFGui.GUIBuyMenu.WeightB'

     RedColor=(R=255,A=255)
     GreenGreyColor=(B=158,G=176,R=175,A=255)
     CurrentPerk="Current Perk"
     NoActivePerk="No Active Perk!"
     TraderClose="Trader Closes in"
     WaveString="Wave"
     LvAbbrString="Lv"
     Begin Object Class=GUITabControl Name=PageTabs
         bDockPanels=True
         TabHeight=0.025000
         BackgroundStyleName="TabBackground"
         WinTop=0.078000
         WinLeft=0.005000
         WinWidth=0.990000
         WinHeight=0.025000
         RenderWeight=0.490000
         TabOrder=0
         bAcceptsInput=True
         OnActivate=PageTabs.InternalOnActivate
         OnChange=GUIBuyMenu.InternalOnChange
     End Object
     c_Tabs=GUITabControl'KFGui.GUIBuyMenu.PageTabs'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'Engine.WhiteSquareTexture'
         ImageColor=(B=20,G=20,R=20)
         ImageStyle=ISTY_Tiled
         RenderWeight=0.001000
     End Object
     i_Background=BackgroundImage'KFGui.GUIBuyMenu.PageBackground'

     PanelClass(0)="KFGUI.KFTab_BuyMenu"
     PanelClass(1)="KFGUI.KFTab_Perks"
     PanelCaption(0)="Store"
     PanelCaption(1)="Perks"
     PanelHint(0)="Trade equipment and ammunition"
     PanelHint(1)="Select your current Perk"
     bAllowedAsLast=True
     OnClose=GUIBuyMenu.KFBuyMenuClosed
     WhiteColor=(B=255,G=255,R=255)
}
