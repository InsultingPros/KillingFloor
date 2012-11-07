//=============================================================================
// ROTab_Hud
//=============================================================================
// The hud config tab
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROTab_Hud extends UT2K4Tab_HudSettings;

var automated moCheckBox	ch_ShowCompass, ch_ShowMapUpdatedText, ch_ShowMapFirstSpawn, ch_UseNativeRoleNames;
var automated moComboBox    co_Hints;

var bool bShowCompass, bShowMapUpdatedText, bShowMapOnFirstSpawn, bShowMapOnFirstSpawnD, bUseNativeRoleNames, bUseNativeRoleNamesD;
var int HintLevel, HintLevelD; // 0 = all hints, 1 = new hints, 2 = no hints

var localized array<string>        Hints;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

	super(Settings_Tabs).InitComponent(MyController, MyOwner);

    RemoveComponent(co_CustomHUD);
	RemoveComponent(ch_Score);
	RemoveComponent(ch_EnemyNames);
	RemoveComponent(sl_Red);
	RemoveComponent(sl_Blue);
	RemoveComponent(sl_Green);
	RemoveComponent(i_Preview);
	RemoveComponent(i_PreviewBG);
	RemoveComponent(i_Scale);
	RemoveComponent(ch_CustomColor);
	RemoveComponent(ch_WeaponBar);
	RemoveComponent(ch_DeathMsgs);
	RemoveComponent(b_CustomHUD);
	//RemoveComponent(ch_Portraits);
	//RemoveComponent(ch_VCPortraits);

	i_BG2.ManageComponent(ch_Visible);
    i_BG2.ManageComponent(sl_Opacity);
    i_BG2.ManageComponent(sl_Scale);

    i_BG1.ManageComponent(co_Hints);
    i_BG1.ManageComponent(ch_Weapons);
    i_BG1.ManageComponent(ch_Personal);
    //i_BG1.ManageComponent(ch_Portraits);
    //i_BG1.ManageComponent(ch_VCPortraits);
    i_BG2.ManageComponent(nu_MsgCount);
    i_BG2.ManageComponent(nu_MsgScale);
    i_BG2.ManageComponent(nu_MsgOffset);

    i_BG1.ManageComponent(ch_ShowCompass);
    i_BG1.ManageComponent(ch_ShowMapUpdatedText);
    i_BG1.ManageComponent(ch_ShowMapFirstSpawn);
    i_BG1.ManageComponent(ch_UseNativeRoleNames);

    sl_Opacity.MySlider.bDrawPercentSign = True;
    sl_Scale.MySlider.bDrawPercentSign = True;

	for (i = 0; i < Hints.Length; i++)
	    co_Hints.AddItem(Hints[i]);
	co_Hints.ReadOnly(true);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local ROHud H;

	H = ROHud(PlayerOwner().myHUD);
	switch (Sender)
	{
        case ch_UseNativeRoleNames:
    	    if (ROPlayer(PlayerOwner()) != none)
    	    {
				bUseNativeRoleNames = ROPlayer(PlayerOwner()).bUseNativeRoleNames;
    	    }
    	    else
    	    {
				bUseNativeRoleNames = class'ROPlayer'.default.bUseNativeRoleNames;
    	    }
            bUseNativeRoleNamesD=bUseNativeRoleNames;
            ch_UseNativeRoleNames.SetComponentValue(bUseNativeRoleNames,true);
            break;

        case ch_ShowMapFirstSpawn:
    	    if (ROPlayer(PlayerOwner()) != none)
    	    {
				bShowMapOnFirstSpawn = ROPlayer(PlayerOwner()).bShowMapOnFirstSpawn;
    	    }
    	    else
    	    {
				bShowMapOnFirstSpawn = class'ROPlayer'.default.bShowMapOnFirstSpawn;
    	    }
            bShowMapOnFirstSpawnD=bShowMapOnFirstSpawn;
            ch_ShowMapFirstSpawn.SetComponentValue(bShowMapOnFirstSpawn,true);
            break;

        case ch_ShowCompass:
            if (H != none)
                bShowCompass = H.bShowCompass;
            ch_ShowCompass.SetComponentValue(bShowCompass,true);
            break;

    	case ch_ShowMapUpdatedText:
    		if (H != none)
                bShowMapUpdatedText = H.bShowMapUpdatedText;
    		ch_ShowMapUpdatedText.SetComponentValue(bShowMapUpdatedText,true);
    		break;

        case sl_Opacity:
            fOpacity = (PlayerOwner().myHUD.HudOpacity / 255) * 100;
	        sl_Opacity.SetValue(fOpacity);
            break;

    	case sl_Scale:
    		fScale = PlayerOwner().myHUD.HudScale * 100;
    		sl_Scale.SetValue(fScale);
    		break;

    	case co_Hints:
    	    if (ROPlayer(PlayerOwner()) != none)
    	    {
    	        if (ROPlayer(PlayerOwner()).bShowHints)
    	            HintLevel = 1;
    	        else
    	            HintLevel = 2;
    	    }
    	    else
    	    {
    	        if (class'ROPlayer'.default.bShowHints)
    	            HintLevel = 1;
    	        else
    	            HintLevel = 2;
    	    }
    	    HintLevelD = HintLevel;
    	    co_Hints.SilentSetIndex(HintLevel);
    	    break;

    	default:
    	    super.InternalOnLoadINI(sender, s);
	}
}

function SaveSettings()
{
	local PlayerController PC;
	local ROHud H;
	local bool bSave;

	Super.SaveSettings();

	PC = PlayerOwner();
	H = ROHud(PC.myHUD);

	if ( bUseNativeRoleNamesD != bUseNativeRoleNames )
	{
        if (ROPlayer(PC) != none)
        {
            ROPlayer(PC).bUseNativeRoleNames = bUseNativeRoleNames;
            ROPlayer(PC).SaveConfig();
        }
        else
        {
            class'ROPlayer'.default.bUseNativeRoleNames = bUseNativeRoleNames;
            class'ROPlayer'.static.StaticSaveConfig();
        }
	}

	if ( bShowMapOnFirstSpawnD != bShowMapOnFirstSpawn )
	{
        if (ROPlayer(PC) != none)
        {
            ROPlayer(PC).bShowMapOnFirstSpawn = bShowMapOnFirstSpawn;
            ROPlayer(PC).SaveConfig();
        }
        else
        {
            class'ROPlayer'.default.bShowMapOnFirstSpawn = bShowMapOnFirstSpawn;
            class'ROPlayer'.static.StaticSaveConfig();
        }
	}

	if (H == none)
	   return;

	if ( H.bShowCompass != bShowCompass )
	{
		H.bShowCompass = bShowCompass;
		bSave = True;
	}

	if ( H.bShowMapUpdatedText != bShowMapUpdatedText )
	{
		H.bShowMapUpdatedText = bShowMapUpdatedText;
		bSave = True;
	}

	if ( HintLevelD != HintLevel )
	{
	    if (HintLevel == 0)
	    {
	        if (ROPlayer(PC) != none)
	        {
	            ROPlayer(PC).bShowHints = true;
                ROPlayer(PC).UpdateHintManagement(true);
                if (ROPlayer(PC).HintManager != none)
	                ROPlayer(PC).HintManager.NonStaticReset();
                ROPlayer(PC).SaveConfig();
	        }
	        else
	        {
	            class'ROHintManager'.static.StaticReset();
	            class'ROPlayer'.default.bShowHints = true;
	            class'ROPlayer'.static.StaticSaveConfig();
	        }
	    }
	    else
	    {
	        if (ROPlayer(PC) != none)
	        {
	            ROPlayer(PC).bShowHints = (HintLevel == 1);
	            ROPlayer(PC).UpdateHintManagement(HintLevel == 1);
	            ROPlayer(PC).SaveConfig();
	        }
	        else
	        {
	            class'ROPlayer'.default.bShowHints = (HintLevel == 1);
	            class'ROPlayer'.static.StaticSaveConfig();
	        }
	    }
	}

	if ( bSave )
    	H.SaveConfig();
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);

	switch (Sender)
	{
    	case ch_UseNativeRoleNames:
    		bUseNativeRoleNames = ch_UseNativeRoleNames.IsChecked();
    		break;

    	case ch_ShowMapFirstSpawn:
    		bShowMapOnFirstSpawn = ch_ShowMapFirstSpawn.IsChecked();
    		break;

    	case ch_ShowCompass:
    		bShowCompass = ch_ShowCompass.IsChecked();
    		break;

    	case ch_ShowMapUpdatedText:
    		bShowMapUpdatedText = ch_ShowMapUpdatedText.IsChecked();
    		break;

    	case co_Hints:
    	    HintLevel = co_Hints.GetIndex();
    	    break;
    }
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=ShowCompass
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Compass"
         OnCreateComponent=ShowCompass.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display direction compass on the HUD."
         WinTop=0.481406
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=23
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     ch_ShowCompass=moCheckBox'ROInterface.ROTab_Hud.ShowCompass'

     Begin Object Class=moCheckBox Name=ShowMapUpdateText
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show 'Map Updated' Text"
         OnCreateComponent=ShowMapUpdateText.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Show the 'Map Updated' text hint on the HUD."
         WinTop=0.481406
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=26
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     ch_ShowMapUpdatedText=moCheckBox'ROInterface.ROTab_Hud.ShowMapUpdateText'

     Begin Object Class=moCheckBox Name=ShowMapFirstSpawn
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Show Map On Initial Spawn"
         OnCreateComponent=ShowMapFirstSpawn.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Display the overhead map for the first spawn each level."
         WinTop=0.481406
         WinLeft=0.555313
         WinWidth=0.373749
         TabOrder=24
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     ch_ShowMapFirstSpawn=moCheckBox'ROInterface.ROTab_Hud.ShowMapFirstSpawn'

     Begin Object Class=moCheckBox Name=UseNativeRoleNames
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Use Native Role Names"
         OnCreateComponent=UseNativeRoleNames.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Use non-translated role names in the menus and HUD."
         WinTop=0.822959
         WinLeft=0.555313
         WinWidth=0.373749
         WinHeight=0.034156
         TabOrder=25
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     ch_UseNativeRoleNames=moCheckBox'ROInterface.ROTab_Hud.UseNativeRoleNames'

     Begin Object Class=moComboBox Name=HintsCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Hint Level"
         OnCreateComponent=HintsCombo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Selects whether hints should be shown or not."
         WinTop=0.335021
         WinLeft=0.547773
         WinWidth=0.401953
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     co_Hints=moComboBox'ROInterface.ROTab_Hud.HintsCombo'

     Hints(0)="All Hints (Reset)"
     Hints(1)="New Hints Only"
     Hints(2)="No Hints"
     Begin Object Class=GUISectionBackground Name=GameBK
         Caption="Options"
         WinTop=0.180360
         WinLeft=0.521367
         WinWidth=0.448633
         WinHeight=0.499740
         RenderWeight=0.001000
         OnPreDraw=GameBK.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'ROInterface.ROTab_Hud.GameBK'

     Begin Object Class=GUISectionBackground Name=GameBK1
         Caption="Style"
         WinTop=0.179222
         WinLeft=0.030000
         WinWidth=0.448633
         WinHeight=0.502806
         RenderWeight=0.001000
         OnPreDraw=GameBK1.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROTab_Hud.GameBK1'

     Begin Object Class=moSlider Name=myHudScale
         MaxValue=100.000000
         MinValue=50.000000
         Caption="HUD Scaling"
         OnCreateComponent=myHudScale.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.5"
         Hint="Adjust the size of the items on the HUD"
         WinTop=0.070522
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=22
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     sl_Scale=moSlider'ROInterface.ROTab_Hud.myHudScale'

     Begin Object Class=moSlider Name=myGameHudOpacity
         MaxValue=100.000000
         MinValue=51.000000
         Caption="HUD Opacity"
         OnCreateComponent=myGameHudOpacity.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.5"
         Hint="Adjust the transparency of the HUD"
         WinTop=0.070522
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=21
         OnChange=ROTab_Hud.InternalOnChange
         OnLoadINI=ROTab_Hud.InternalOnLoadINI
     End Object
     sl_Opacity=moSlider'ROInterface.ROTab_Hud.myGameHudOpacity'

}
