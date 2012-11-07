class KFHudSettings extends UT2K4Tab_HudSettings;

var 	automated 	moCheckBox 	ch_LightHud;
var() 				bool 		bLight;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super(Settings_Tabs).InitComponent(MyController, MyOwner);

	i_BG1.ManageComponent(ch_Visible);
	i_BG1.ManageComponent(ch_Weapons);
	i_BG1.ManageComponent(ch_LightHud);
	i_BG1.ManageComponent(ch_Personal);
	i_BG1.ManageComponent(ch_Score);
	// KFTODO: reintegrate these
	//i_BG1.ManageComponent(ch_Portraits);
	//i_BG1.ManageComponent(ch_VCPortraits);
	i_BG1.ManageComponent(ch_DeathMsgs);
	i_BG1.ManageComponent(nu_MsgCount);
	i_BG1.ManageComponent(nu_MsgScale);
	i_BG1.ManageComponent(nu_MsgOffset);

	sl_Opacity.MySlider.bDrawPercentSign = True;
	//sl_Scale.MySlider.bDrawPercentSign = True;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local HUD H;

	H = PlayerOwner().myHUD;
	
	switch (Sender)
	{
		case ch_DeathMsgs:
			bNoMsgs = class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages;
			ch_DeathMsgs.SetComponentValue(bNoMsgs,true);
			break;

		case ch_Visible:
			bVis = H.bHideHUD;
			ch_Visible.SetComponentValue(bVis,true);
			InitializeHUDColor();
			break;
			
		
		case ch_LightHud:
			if ( HUDKillingFloor(H) != none )
			{
				bLight = HUDKillingFloor(H).bLightHud;
				ch_LightHud.SetComponentValue(bLight,true);
				break;	
			}
			else
			{
				bLight = class'KFMod.HUDKillingFloor'.default.bLightHud;
				ch_LightHud.SetComponentValue(bLight,true);
				break;
			}

		case ch_Weapons:
			bWeapons = H.bShowWeaponInfo;
			ch_Weapons.SetComponentValue(bWeapons,true);
			break;

		case ch_Personal:
			bPersonal = H.bShowPersonalInfo;
			ch_Personal.SetComponentValue(bPersonal,true);
			break;

		case ch_Score:
			bScore = H.bShowPoints;
			ch_Score.SetComponentValue(bScore,true);
			break;

		case ch_WeaponBar:
			bWeaponBar = H.bShowWeaponBar;
			ch_WeaponBar.SetComponentValue(bWeaponBar,true);
			break;

            // KFTODO: Figure out how to reintegrate this!
//		case ch_Portraits:
//			bPortraits = H.bShowPortrait;
//			ch_Portraits.SetComponentValue(bPortraits,true);
//			break;

		case nu_MsgCount:
			iCount = H.ConsoleMessageCount;
			nu_MsgCount.SetComponentValue(iCount,true);
			break;

		case nu_MsgScale:
			iScale = 8 - H.ConsoleFontSize;
			nu_MsgScale.SetComponentValue(iScale,true);
			break;

		case nu_MsgOffset:
			iOffset = H.MessageFontOffset+4;
			nu_MsgOffset.SetComponentValue(iOffset,true);
			break;

		default:
			GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function SaveSettings()
{
	local PlayerController PC;
	local HUD H;
	local bool bSave;

	PC = PlayerOwner();
	H = PlayerOwner().myHUD;

	if ( H.bHideHud != bVis )
	{
		H.bHideHUD = bVis;
		bSave = True;
	}
	
	if ( HUDKillingFloor(H) !=  none )
	{	
		if ( HUDKillingFloor(H).bLightHud != bLight )
		{
			HUDKillingFloor(H).bLightHUD = bLight;
			bSave = True;
		}
	}
	else
	{
		if ( class'KFMod.HUDKillingFloor'.default.bLightHud != bLight )
    	{
			class'KFMod.HUDKillingFloor'.default.bLightHud = bLight;
			class'KFMod.HUDKillingFloor'.static.StaticSaveConfig();
		}	
	}

	if ( H.bShowWeaponInfo != bWeapons )
	{
		H.bShowWeaponInfo = bWeapons;
		bSave = True;
	}

	if ( H.bShowPersonalInfo != bPersonal )
	{
		H.bShowPersonalInfo = bPersonal;
		bSave = True;
	}

	if ( H.bShowPoints != bScore )
	{
		H.bShowPoints = bScore;
		bSave = True;
	}

	if ( H.bShowWeaponBar != bWeaponBar)
	{
		H.bShowWeaponBar = bWeaponBar;
		bSave = True;
	}

// if _RO_
/*
// end if _RO_
	if ( H.bShowPortrait != bPortraits )
	{
		H.bShowPortrait = bPortraits;
		bSave = True;
	}

	if ( H.bShowPortraitVC != bVCPortraits )
	{
		H.bShowPortraitVC = bVCPortraits;
		bSave = True;
	}
// if _RO_
*/
// end if _RO_

	if ( H.bNoEnemyNames == bNames )
	{
		H.bNoEnemyNames = !bNames;
		bSave = True;
	}

	if ( H.ConsoleMessageCount != iCount )
	{
		H.ConsoleMessageCount = iCount;
		bSave = True;
	}

	if ( H.ConsoleFontSize != Abs(iScale - 8) )
	{
		H.ConsoleFontSize = Abs(iScale - 8);
		bSave = True;
	}

	if ( H.MessageFontOffset != iOffset - 4 )
	{
		H.MessageFontOffset = iOffset - 4;
		bSave = True;
	}

	if ( H.HudScale != fScale / 100.0 )
	{
		H.HudScale = fScale / 100.0;
		bSave = True;
	}

	if ( H.HudOpacity != (fOpacity / 100.0) * 255.0 )
	{
		H.HudOpacity = (fOpacity / 100.0) * 255.0;
		bSave = True;
	}

	if ( HudBase(H) != None )
	{
		if ( SaveCustomHUDColor() || bSave )
			H.SaveConfig();
	}
	
	else
	{
		if ( bSave )
			H.SaveConfig();

		SaveCustomHUDColor();
	}
	
    if ( class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages != bNoMsgs )
    {
		class'XGame.xDeathMessage'.default.bNoConsoleDeathMessages = bNoMsgs;
		class'XGame.xDeathMessage'.static.StaticSaveConfig();
	}
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);
	
	switch (Sender)
	{
		case ch_LightHud:
			bLight = ch_LightHud.IsChecked();
			break;
	}
}

function InitializeHUDColor()
{
	fScale = PlayerOwner().myHUD.HudScale * 100;
	fOpacity = (PlayerOwner().myHUD.HudOpacity / 255) * 100;

	//sl_Scale.SetValue(fScale);
	sl_Opacity.SetValue(fOpacity);

	UpdatePreviewColor();
}

function UpdatePreviewColor()
{
	local float o, s;

	i_PreviewBG.ImageColor = cCustom;

	o = 255.0 * (fOpacity / 100.0);
	i_PreviewBG.ImageColor.A = o;
	i_Preview.ImageColor.A = o;

	s = 1.0;
	i_PreviewBG.WinWidth = DefaultBGPos.X2 * s;
	i_PreviewBG.WinHeight = DefaultBGPos.Y2 * s;

	i_Preview.WinWidth = DefaultHealthPos.X2 * s;
	i_Preview.WinHeight = DefaultHealthPos.Y2 * s;

	i_Scale.WinWidth =  i_PreviewBG.WinWidth;
	i_Scale.WinHeight = i_PreviewBG.WinHeight;

}

defaultproperties
{
     Begin Object Class=moCheckBox Name=LightHud
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Light HUD"
         OnCreateComponent=LightHud.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Show a light version of the HUD"
         WinTop=0.043906
         WinLeft=0.379297
         WinWidth=0.196875
         TabOrder=1
         OnChange=KFHudSettings.InternalOnChange
         OnLoadINI=KFHudSettings.InternalOnLoadINI
     End Object
     ch_LightHud=moCheckBox'KFGui.KFHudSettings.LightHud'

     Begin Object Class=GUIImage Name=PreviewBK
         Image=Texture'InterfaceArt_tex.Menu.traderlist_normal'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.211713
         WinLeft=0.749335
         WinWidth=0.400000
         WinHeight=0.250000
         RenderWeight=1.001000
     End Object
     i_Scale=GUIImage'KFGui.KFHudSettings.PreviewBK'

     Begin Object Class=GUIImage Name=PreviewBackground
         ImageStyle=ISTY_Stretched
         ImageAlign=IMGA_Center
         WinTop=0.211713
         WinLeft=0.749335
         WinWidth=0.190000
         WinHeight=0.160000
         RenderWeight=1.002000
     End Object
     i_PreviewBG=GUIImage'KFGui.KFHudSettings.PreviewBackground'

     Begin Object Class=GUIImage Name=Preview
         Image=Texture'KillingFloorHUD.Perks.Perk_Firebug'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.211559
         WinLeft=0.749828
         WinWidth=0.150000
         WinHeight=0.150000
         RenderWeight=1.003000
     End Object
     i_Preview=GUIImage'KFGui.KFHudSettings.Preview'

     sl_Scale=None

     sl_Red=None

     sl_Green=None

     sl_Blue=None

     ch_WeaponBar=None

     ch_EnemyNames=None

     ch_CustomColor=None

     co_CustomHUD=None

     b_CustomHUD=None

}
