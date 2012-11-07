// ====================================================================
// Onslaught PowerLink Designer - page for creating custom powercore link setups
//
// Written by Matt Oelfke
// (C) 2003, Epic Games, Inc. All Rights Reserved
// ====================================================================

class UT2K4OnslaughtPowerLinkDesigner extends LargeWindow;

// Commented out UT2k4Merge - Ramm
/*

var automated GUIImage          i_Map;
var automated moComboBox        co_SetupName;
var automated GUIButton         b_DeleteSetup, b_SaveSetup, b_lClose, b_Clear, b_Export;

var float OnslaughtMapCenterX, OnslaughtMapCenterY, OnslaughtMapRadius;
var ONSPlayerReplicationInfo PRI;
var ONSPowerCore SelectedCore;
var string SetupName; //name of setup we're currently editing

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	//fill setup name combobox
	PRI = ONSPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if (PRI != None)
	{
		PRI.UpdateGUIMapLists = UpdateGUIMapLists;
		PRI.ProcessSetupName = AddSetupName;
		PRI.RemoveSetupName = RemoveSetupName;
		PRI.SetCurrentSetup = SetCurrentSetup;
		PRI.ServerSendSetupNames();
	}

	co_SetupName.MyComboBox.List.OnClick = InternalListClick;
	b_Export.ToolTip.ExpirationSeconds = 10.0;
}

function bool ShouldAnimate(GUIComponent C, optional bool bSetup)
{
	return false;
}

function AddSetupName(string SetupName)
{
	if (SetupName == "")
	{
		if (co_SetupName.ItemCount() == 0)
			co_SetupName.AddItem("Custom");
	}
	else
	{
		co_SetupName.AddItem(SetupName);
		co_SetupName.OnChange(co_SetupName);
	}

	EnableComponent(b_SaveSetup);
	EnableComponent(co_SetupName);
}

function RemoveSetupName(string SetupName)
{
	co_SetupName.RemoveItem(co_SetupName.FindIndex(SetupName, true));
}

function UpdateGUIMapLists()
{
	local UT2K4GamePageBase Page;

	Page = UT2K4GamePageBase(Controller.FindPersistentMenuByClass(class'UT2K4GamePageBase'));
	if ( Page != None && Page.p_Main != None )
		Page.p_Main.InitMaps();
}

function SetCurrentSetup(string SetupName)
{
	co_SetupName.Find(SetupName, true);
}

function SetDefaultPosition()
{
	Super.SetDefaultPosition();

	ResolutionChanged(0, 0);
}

function ResolutionChanged( int NewResX, int NewResY )
{
	OnslaughtMapCenterX = ActualLeft() + default.OnslaughtMapCenterX * ActualWidth();
	OnslaughtMapCenterY = ActualTop() + default.OnslaughtMapCenterY * ActualHeight();
	OnslaughtMapRadius = default.OnslaughtMapRadius * ActualWidth();

	Super.ResolutionChanged(NewResX,NewResY);
}

function bool DrawMap(Canvas Canvas)
{
	local ONSHUDOnslaught ONSHUD;

	ONSHUD = ONSHudOnslaught(PlayerOwner().myHUD);
	if ( ONSHUD == None )
		return True;

	ONSHUD.DrawRadarMap(Canvas, OnslaughtMapCenterX, OnslaughtMapCenterY, OnslaughtMapRadius, true);
	if ( SelectedCore != None )
		ONSHUD.DrawSpawnIcon(Canvas, SelectedCore.HUDLocation, false, ONSHUD.IconScale, ONSHUD.HUDScale);

	Canvas.SetPos(OnslaughtMapCenterX - OnslaughtMapRadius, OnslaughtMapCenterY - OnslaughtMapRadius);
	Canvas.DrawBox( Canvas, OnslaughtMapRadius * 2, OnslaughtMapRadius * 2);

	return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (PRI == None)
		return true;

	if ( Sender == b_SaveSetup )
	{
		if ( co_SetupName.GetText() != "" )
			PRI.ServerSavePowerLinkSetup(co_SetupName.GetText());
	}
	else if (Sender == b_DeleteSetup)
	{
		PRI.ServerDeletePowerLinkSetup(co_SetupName.GetText());
	}
	else if (Sender == b_lClose)
		Controller.CloseMenu(false);
	else if (Sender == b_Clear)
		PRI.ServerClearPowerLinks();
	else if (Sender == b_Export)
		PlayerOwner().ConsoleCommand("CopyLinkSetup");

	return true;
}

function InternalOnChange(GUIComponent Sender)
{
	if (Sender == co_SetupName)
	{
		if (co_SetupName.FindIndex(co_SetupName.GetText(), true) != -1)
			EnableComponent(b_DeleteSetup);
		else
			DisableComponent(b_DeleteSetup);
	}
}

function bool InternalListClick(GUIComponent Sender)
{
	co_SetupName.MyComboBox.InternalListClick(Sender);
	if (!co_SetupName.MyComboBox.List.bVisible && ONSPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo) != None)
	{
		ONSPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ServerSetPowerLinkSetup(co_SetupName.GetText());
		ONSHudOnslaught(PlayerOwner().myHUD).RequestPowerLinks();
	}

	return true;
}

function InternalOnMouseReleased( GUIComponent Sender )
{
	local ONSPowerCore Core;
	local ONSHudOnslaught ONSHUD;

	if ( Sender == Self )
	{
		ONSHUD = ONSHudOnslaught(PlayerOwner().myHUD);
		Core = ONSHUD.LocatePowerCore(Controller.MouseX - OnslaughtMapCenterX, Controller.MouseY - OnslaughtMapCenterY, OnslaughtMapRadius);
		if (Core != None)
		{
			if (SelectedCore == None)
				SelectedCore = Core;
			else
			{
				if ( ONSHUD.HasLink(Core, SelectedCore) )
					PRI.ServerRemovePowerLink(SelectedCore, Core);
				else
					PRI.ServerReceivePowerLink(SelectedCore, Core);

				SelectedCore = None;
			}
		}
	}
}

function Free()
{
	if (PRI != None)
	{
		PRI.UpdateGUIMapLists = None;
		PRI.ProcessSetupName = None;
		PRI.SetCurrentSetup = None;
	}

	PRI = None;
	SelectedCore = None;
	super.Free();
}

defaultproperties
{
	OnslaughtMapCenterX=0.5
	OnslaughtMapCenterY=0.475
	OnslaughtMapRadius=0.30

	Begin Object Class=GUIToolTip Name=MapToolTip
		ExpirationSeconds=5.0
	End Object
	ToolTip=MapToolTip
	Hint="Click on any PowerCore or PowerNode to select it, then click on another PowerCore or PowerNode to create a link between the two."

	Begin Object Class=GUIImage Name=LinkDesignerMap
		Image=Material'MenuWhite'
		ImageRenderStyle=MSTY_Normal
		OnDraw=DrawMap
		Hint="Click on any PowerCore or PowerNode to select it, then click on another PowerCore or PowerNode to create a link between the two."
	End Object
	i_Map=LinkDesignerMap

	Begin Object Class=moComboBox Name=SetupNameBox
		WinWidth=0.400000
		WinHeight=0.030000
		WinLeft=0.300000
		WinTop=0.094531
		CaptionWidth=0.25
		Caption="Name"
		Hint="The name of this Link Setup. Type a name and click Save to create a new link setup."
		OnChange=InternalOnChange
		MenuState=MSAT_Disabled
	End Object
	co_SetupName=SetupNameBox

	Begin Object Class=GUIButton Name=DeleteSetupButton
		WinTop=0.155
		WinLeft=0.3
		WinWidth=0.15
		WinHeight=0.05
		Caption="Delete"
		Hint="Delete the currently selected Link Setup."
		OnClick=InternalOnClick
		MenuState=MSAT_Disabled
	End Object
	b_DeleteSetup=DeleteSetupButton

	Begin Object Class=GUIButton Name=SaveSetupButton
		WinTop=0.155
		WinLeft=0.55
		WinWidth=0.15
		WinHeight=0.05
		Caption="Save"
		Hint="Save the current Link Setup."
		OnClick=InternalOnClick
		MenuState=MSAT_Disabled
	End Object
	b_SaveSetup=SaveSetupButton

	Begin Object Class=GUIButton Name=CloseButton
		WinWidth=0.150000
		WinHeight=0.050000
		WinLeft=0.425000
		WinTop=0.861979
		Caption="Close"
		OnClick=InternalOnClick
	End Object
	b_lClose=CloseButton

	Begin Object Class=GUIButton Name=ClearButton
		WinWidth=0.200000
		WinHeight=0.050000
		WinLeft=0.400000
		WinTop=0.731979
		Caption="Clear Links"
		Hint="Clear all links on the map."
		OnClick=InternalOnClick
	End Object
	b_Clear=ClearButton

	Begin Object Class=GUIButton Name=ExportButton
		WinWidth=0.200000
		WinHeight=0.050000
		WinLeft=0.400000
		WinTop=0.791979
		Caption="Export to UnrealEd"
		Hint="LEVEL DESIGNERS ONLY: Export the current Link Setup to the clipboard. You can then open the map in UnrealEd and use Paste to create an Official Link Setup actor, making this Link Setup an Official Link Setup for your map."
		OnClick=InternalOnClick
	End Object
	b_Export=ExportButton

	OnMouseRelease=InternalOnMouseReleased

	WinLeft=0.2
	WinWidth=0.6
	WinTop=0.05
	WinHeight=0.9

	bAllowedAsLast=true
	bRenderWorld=true
}  */

defaultproperties
{
}
