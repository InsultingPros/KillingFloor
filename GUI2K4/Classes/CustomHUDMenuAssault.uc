//==============================================================================
//	Created on: 09/22/2003
//	Custom HUD settings menu for UT2K4Assault.ASGameInfo
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CustomHUDMenuAssault extends UT2K4CustomHUDMenu;

// Commented out UT2k4Merge - Ramm
/*

var class<HUD_Assault> HUDClass;

var automated moCheckbox       		ch_Reticles, ch_InfoPods, ch_bShow3DArrow, ch_bDrawAllObjectives, ch_bObjectiveReminder, ch_bShowWillowWhisp;
var automated moSlider         		sl_ReticleSize;
var automated moNumericEdit   		nu_PulseTime;
var automated GUISectionBackground  sb_Main, sb_Misc;

var bool    bReticle, bInfoPods, bShow3DArrow, bDrawAllObjectives, bObjectiveReminder, bShowWillowWhisp;
var float   fReticle;
var int     iPulseTime;

var localized string MainCaption;

function bool InitializeGameClass( string GameClassName )
{
	sb_Main.ManageComponent(ch_Reticles);
	sb_Main.ManageComponent(sl_ReticleSize);

	sb_Misc.ManageComponent(ch_InfoPods);
	sb_Misc.ManageComponent(ch_bDrawAllObjectives);
	sb_Misc.ManageComponent(ch_bShow3DArrow);
	sb_Misc.Managecomponent(ch_bObjectiveReminder);
	sb_Misc.ManageComponent(nu_PulseTime);
	sb_Misc.ManageComponent(ch_bShowWillowWhisp);

	if ( GameClassName != "" )
		GameClass = class<GameInfo>(DynamicLoadObject( GameClassName, class'Class' ));

	if ( GameClass == None )
	{
		Warn(Name@"could not load specified gametype:"@GameClassName);
		return False;
	}

	if ( GameClass.default.HUDType != "" )
	{
		HUDClass = class<HUD_Assault>(DynamicLoadObject(GameClass.default.HUDType, class'Class'));
		if ( HUDClass == None )
		{
			Warn(Name@"could not load specified HUD type:"@GameClass.default.HUDType);
			return False;
		}
	}

	return True;
}

function LoadSettings()
{
	local HUD_Assault ASHUD;

	ASHUD = HUD_Assault(PlayerOwner().myHUD);
	if ( ASHUD == None )
	{
		bReticle = HUDClass.default.bOnHUDObjectiveNotification;
		ch_Reticles.SetComponentValue( bReticle, True );

		bInfoPods = HUDClass.default.bShowInfoPods;
		ch_InfoPods.SetComponentValue( bInfoPods, True );

		fReticle = HUDClass.default.ObjectiveScale;
		sl_ReticleSize.SetComponentValue( fReticle, True );

		iPulseTime = HUDClass.default.ObjectiveProgressPulseTime;
		nu_PulseTime.SetComponentValue( iPulseTime, True );

		bShow3DArrow = HUDClass.default.bShow3DArrow;
		ch_bShow3DArrow.SetComponentValue( bShow3DArrow, True );

		bObjectiveReminder = HUDClass.default.bObjectiveReminder;
		ch_bObjectiveReminder.SetComponentValue( bObjectiveReminder, True );

		bDrawAllObjectives = HUDClass.default.bDrawAllObjectives;
		ch_bDrawAllObjectives.SetComponentValue( bDrawAllObjectives, True );

		bShowWillowWhisp = HUDClass.default.bShowWillowWhisp;
		ch_bShowWillowWhisp.SetComponentValue( bShowWillowWhisp, True );

	}
	else
	{
		bReticle = ASHUD.bOnHUDObjectiveNotification;
		ch_Reticles.SetComponentValue( bReticle, True );

		bInfoPods = ASHUD.bShowInfoPods;
		ch_InfoPods.SetComponentValue( bInfoPods, True );

		fReticle = ASHUD.ObjectiveScale;
		sl_ReticleSize.SetComponentValue( fReticle, True );

		iPulseTime = ASHUD.ObjectiveProgressPulseTime;
		nu_PulseTime.SetComponentValue( iPulseTime, True );

		bShow3DArrow = ASHUD.bShow3DArrow;
		ch_bShow3DArrow.SetComponentValue( bShow3DArrow, True );

		bObjectiveReminder = ASHUD.bObjectiveReminder;
		ch_bObjectiveReminder.SetComponentValue( bObjectiveReminder, True );

		bDrawAllObjectives = ASHUD.bDrawAllObjectives;
		ch_bDrawAllObjectives.SetComponentValue( bDrawAllObjectives, True );

		bShowWillowWhisp = ASHUD.bShowWillowWhisp;
		ch_bShowWillowWhisp.SetComponentValue( bShowWillowWhisp, True );
	}
}

function InternalOnChange(GUIComponent Sender)
{
	switch ( Sender )
	{
	case ch_Reticles:
		bReticle = ch_Reticles.IsChecked();
		break;

	case ch_InfoPods:
		bInfoPods = ch_InfoPods.IsChecked();
		break;

	case sl_ReticleSize:
		fReticle = sl_ReticleSize.GetValue();
		break;

	case nu_PulseTime:
		iPulseTime = nu_PulseTime.GetValue();
		break;

	case ch_bShow3DArrow:
		bShow3DArrow = ch_bShow3DArrow.IsChecked();
		break;

	case ch_bObjectiveReminder:
		bObjectiveReminder = ch_bObjectiveReminder.IsChecked();
		break;

	case ch_bDrawAllObjectives:
		bDrawAllObjectives = ch_bDrawAllObjectives.IsChecked();
		break;

	case ch_bShowWillowWhisp:
		bShowWillowWhisp = ch_bShowWillowWhisp.IsChecked();
		break;
	}

	Super.InternalOnChange( Sender );
}

function SaveSettings()
{
	local bool bSave;
	local HUD_Assault ASHUD;

	Super.SaveSettings();

	ASHUD = HUD_Assault(PlayerOwner().myHUD);
	if ( ASHUD == None )
	{
		if ( HUDClass.default.bOnHUDObjectiveNotification != bReticle )
		{
			HUDClass.default.bOnHUDObjectiveNotification = bReticle;
			bSave = True;
		}

		if ( HUDClass.default.bShowInfoPods != bInfoPods )
		{
			HUDClass.default.bShowInfoPods = bInfoPods;
			bSave = True;
		}

		if ( HUDClass.default.ObjectiveScale != fReticle )
		{
			HUDClass.default.ObjectiveScale = fReticle;
			bSave = True;
		}

		if ( HUDClass.default.ObjectiveProgressPulseTime != iPulseTime )
		{
			HUDClass.default.ObjectiveProgressPulseTime = iPulseTime;
			bSave = True;
		}

		if ( HUDClass.default.bShow3DArrow != bShow3DArrow )
		{
			HUDClass.default.bShow3DArrow = bShow3DArrow;
			bSave = True;
		}

		if ( HUDClass.default.bObjectiveReminder != bObjectiveReminder )
		{
			HUDClass.default.bObjectiveReminder = bObjectiveReminder;
			bSave = True;
		}

		if ( HUDClass.default.bDrawAllObjectives != bDrawAllObjectives )
		{
			HUDClass.default.bDrawAllObjectives = bDrawAllObjectives;
			bSave = True;
		}

		if ( HUDClass.default.bShowWillowWhisp != bShowWillowWhisp )
		{
			HUDClass.default.bShowWillowWhisp = bShowWillowWhisp;
			bSave = True;
		}

		if ( bSave )
			HUDClass.static.StaticSaveConfig();
	}

	else
	{
		if ( ASHUD.bOnHUDObjectiveNotification != bReticle )
		{
			ASHUD.bOnHUDObjectiveNotification = bReticle;
			bSave = True;
		}

		if ( ASHUD.bShowInfoPods != bInfoPods )
		{
			ASHUD.bShowInfoPods = bInfoPods;
			bSave = True;
		}

		if ( ASHUD.ObjectiveScale != fReticle )
		{
			ASHUD.ObjectiveScale = fReticle;
			bSave = True;
		}

		if ( ASHUD.ObjectiveProgressPulseTime != iPulseTime )
		{
			ASHUD.ObjectiveProgressPulseTime = iPulseTime;
			bSave = True;
		}

		if ( ASHUD.bShow3DArrow != bShow3DArrow )
		{
			ASHUD.bShow3DArrow = bShow3DArrow;
			bSave = True;
		}

		if ( ASHUD.bObjectiveReminder != bObjectiveReminder )
		{
			ASHUD.bObjectiveReminder = bObjectiveReminder;
			bSave = True;
		}

		if ( ASHUD.bDrawAllObjectives != bDrawAllObjectives )
		{
			ASHUD.bDrawAllObjectives = bDrawAllObjectives;
			bSave = True;
		}

		if ( ASHUD.bShowWillowWhisp != bShowWillowWhisp )
		{
			ASHUD.bShowWillowWhisp = bShowWillowWhisp;
			bSave = True;
		}

		if ( bSave )
			ASHUD.SaveConfig();
	}
}

function RestoreDefaults()
{
	if ( HudClass != None )
	{
		HudClass.static.ResetConfig("bOnHUDObjectiveNotification");
		HudClass.static.ResetConfig("bShowInfoPods");
		HudClass.static.ResetConfig("ObjectiveScale");
		HudClass.static.ResetConfig("ObjectiveProgressPulseTime");
		HudClass.static.ResetConfig("bShow3DArrow");
		HudClass.static.ResetConfig("bObjectiveReminder");
		HudClass.static.ResetConfig("bDrawAllObjectives");
		HudClass.static.ResetConfig("bShowWillowWhisp");
		Super.RestoreDefaults();
	}
}

DefaultProperties
{
	WinWidth=0.690941
	WinHeight=0.824065
	WinLeft=0.140625
	WinTop=0.072917

	Begin Object class=GUISectionBackground name=ObjectiveBackground
		WinWidth=0.631835
		WinHeight=0.229493
		WinLeft=0.171485
		WinTop=0.122136
		Caption="Objectives"
    End Object
    sb_Main=ObjectiveBackground

	Begin Object class=GUISectionBackground Name=MiscBackground
		Caption="Misc."
		WinWidth=0.630273
		WinHeight=0.402735
		WinLeft=0.171485
		WinTop=0.372135
	End Object
	sb_Misc=MiscBackground

	Begin Object class=moCheckBox Name=Reticles
		WinWidth=0.450000
		WinLeft=0.024219
		WinTop=0.2
		Caption="Objective Reticles"
		Hint="Draw Objective tracking indicators."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=0
	End Object
	ch_Reticles=Reticles

	Begin Object class=moSlider Name=ReticleSize
		WinWidth=0.450000
		WinLeft=0.024219
		WinTop=0.4
		Caption="Objective Indicators Scale"
		Hint="Size scale of on HUD Objective Indicators."
		MinValue=0
		MaxValue=4
		bIntSlider=False
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Right
		TabOrder=1
	End Object
	sl_ReticleSize=ReticleSize

	Begin Object class=moCheckBox Name=InfoPods
		WinWidth=0.450000
		WinLeft=0.517383
		WinTop=0.15
		Caption="Display Info Pods"
		Hint="Show Info Pods."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=2
	End Object
	ch_InfoPods=InfoPods

	Begin Object class=moNumericEdit Name=PulseTime
		WinWidth=0.450000
		WinLeft=0.517383
		WinTop=0.3
		Caption="Objective Update Time"
		Hint="Number of seconds current Objective will be highlighted."
		MinValue=0
		MaxValue=99
		OnChange=InternalOnChange
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Right
		CaptionWidth=0.7
		bAutoSizeCaption=True
		ComponentWidth=0.3
		TabOrder=3
	End Object
	nu_PulseTime=PulseTime

	Begin Object class=moCheckBox Name=Show3DArrow
		WinWidth=0.450000
		WinLeft=0.024219
		WinTop=0.45
		Caption="Show 3D Arrow"
		Hint="Draw 3D Objective tracking arrow."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=4
	End Object
	ch_bShow3DArrow=Show3DArrow

	Begin Object class=moCheckBox Name=DrawAllObjectives
		WinWidth=0.450000
		WinLeft=0.024219
		WinTop=0.6
		Caption="Show Full Indicators"
		Hint="Draw Indicators when Objective is behind player."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=5
	End Object
	ch_bDrawAllObjectives=DrawAllObjectives

	Begin Object class=moCheckBox Name=ObjectiveReminder
		WinWidth=0.450000
		WinHeight=0.072727
		WinTop=0.75
		Caption="Objective Reminder Announcer"
		Hint="Remind objective goals at respawn."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=6
	End Object
	ch_bObjectiveReminder=ObjectiveReminder

	Begin Object class=moCheckBox Name=ShowWillowWhisp
		WinWidth=0.450000
		WinLeft=0.024219
		WinTop=0.6
		Caption="Enable Willow Whisp"
		Hint="Enable particle trail, showing path to objective."
		OnChange=InternalOnChange
		CaptionWidth=0.1
		bAutoSizeCaption=True
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Center
		TabOrder=7
	End Object
	ch_bShowWillowWhisp=ShowWillowWhisp

	Begin Object class=GUIButton name=ResetButton
		WinWidth=0.139474
		WinHeight=0.052944
		WinLeft=0.288892
		WinTop=0.792153
		Caption="Defaults"
		Hint="Restore all settings to their default value."
		OnClick=InternalOnClick
		TabOrder=7
	End Object
	b_Reset=ResetButton

	Begin Object class=GUIButton Name=CancelButton
		WinWidth=0.139474
		WinHeight=0.052944
		WinLeft=0.496436
		WinTop=0.792153
		Caption="Cancel"
		Hint="Click to close this menu, discarding changes."
		OnClick=InternalOnClick
		TabOrder=8
	End Object
	b_Cancel=CancelButton
	WindowName="Assault HUD Configuration"

	Begin Object class=GUIButton Name=OKButton
		WinWidth=0.139474
		WinHeight=0.052944
		WinLeft=0.640437
		WinTop=0.792153
		Caption="OK"
		Hint="Click to close this menu, saving changes."
		OnClick=InternalOnClick
		TabOrder=9
	End Object
	b_OK=OKButton

}
*/

defaultproperties
{
}
