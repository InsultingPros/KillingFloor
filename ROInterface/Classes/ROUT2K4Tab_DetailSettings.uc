//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_DetailSettings extends UT2K4Tab_DetailSettings;

var() localized string	ScopeLevels[3];

var automated moComboBox	co_Scope;

var automated moCheckBox	ch_Blur;
var() noexport transient bool bBlur,bBlurD;

var GUIList ro_list;
var GUIListBox ro_listBox;
var GUIComboBox ro_comboBox;
var GUIController localController;

var() noexport transient int iScope, iScopeD;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    localController = MyController;
	Super.InitComponent(MyController, MyOwner);
	InitializeScopeCombo();
}

function InitializeCombos()
{
    super.InitializeCombos();

    class'ROInterfaceUtil'.static.SetROStyle(localController, Controls);
}

// Overrides UT2K4Tab_DetailSettings to take out Unrealpawn functionality
function ResetClicked()
{
	local int i;

	super(Settings_Tabs).ResetClicked();

	class'LevelInfo'.static.ResetConfig("MeshLODDetailLevel");
	class'LevelInfo'.static.ResetConfig("PhysicsDetailLevel");
	class'LevelInfo'.static.ResetConfig("DecalStayScale");

	class'ROPawn'.static.ResetConfig("bPlayerShadows");
	class'ROPawn'.static.ResetConfig("bBlobShadow");

	ResetViewport();
	ResetRenderDevice();

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

// Overrides UT2K4Tab_DetailSettings to take out Unrealpawn functionality
function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local bool a, b;
	local int i;
	local PlayerController PC;
	local string tempStr;

	PC = PlayerOwner();
	switch (Sender)
	{
	case co_Texture:
		s = GetGUIString(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetailWorld"));
		iTexture = co_Texture.FindIndex(s);
		iTextureD = iTexture;
		co_Texture.SilentSetIndex(iTexture);
		break;

	case co_Char:
		s = GetGUIString(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetailPlayerSkin"));
		iChar = co_Char.FindIndex(s);
		iCharD = iChar;
		co_Char.SilentSetIndex(iChar);
		break;

	case co_World:
		a = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice HighDetailActors"));
		b = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice SuperHighDetailActors"));

		if(b)
			iWorld = 5;
		else if(a)
			iWorld = 4;
		else
			iWorld = 3;

		iWorldD = iWorld;
		i = co_World.FindIndex(DetailLevels[iWorld]);
		if ( i != -1 )
			co_World.SilentSetIndex(i);

		break;

	case co_MeshLOD:
		switch ( class'LevelInfo'.default.MeshLODDetailLevel )
		{
		case MDL_Low:    iMeshLOD = 3; break;
		case MDL_Medium: iMeshLOD = 4; break;
		case MDL_High:   iMeshLOD = 5; break;
		case MDL_Ultra:  iMeshLOD = 8; break;
		}

		iMeshLODD = iMeshLOD;

		i = co_MeshLOD.FindIndex(DetailLevels[iMeshLOD]);
		if ( i != -1 )
			co_MeshLOD.SilentSetIndex(i);
		break;


	case co_Physics:
		if(class'LevelInfo'.default.PhysicsDetailLevel == PDL_Low)
		{
			iPhys = 3;
			i = co_Physics.FindIndex(DetailLevels[3]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}
		else if(class'LevelInfo'.default.PhysicsDetailLevel == PDL_Medium)
		{
			iPhys = 4;
			i = co_Physics.FindIndex(DetailLevels[4]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}
		else
		{
			iPhys = 5;
			i = co_Physics.FindIndex(DetailLevels[5]);
			if ( i != -1 )
				co_Physics.SilentSetIndex(i);
		}

		iPhysD = iPhys;
		break;

	case co_Decal:
		iDecal = class'LevelInfo'.default.DecalStayScale;
		iDecalD = iDecal;
		co_Decal.SilentSetIndex(iDecal);
		break;

	case co_Resolution:
		// Resolution
		// GameResolution is set if menu requires 640x480 but current resolution is smaller than that
		if(Controller.GameResolution != "")
			sRes = Controller.GameResolution;
		else sRes = Controller.GetCurrentRes();
		sResD = sRes;
		i = AddNewResolution(sRes);

		if ( i >= 0 && i < co_Resolution.ItemCount() )
			co_Resolution.SilentSetIndex(i);
		break;

	case co_ColorDepth:
		if (bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice Use16bit")))
			iColDepth = 0;
		else iColDepth = 1;
		iColDepthD = iColDepth;
		co_ColorDepth.SilentSetIndex(iColDepth);

		if (! bool(PC.ConsoleCommand("ISFULLSCREEN")) )
			co_ColorDepth.DisableMe();
		else
			co_ColorDepth.EnableMe();

		break;

	case co_RenderDevice:
		sRenDev = GetNativeClassName("Engine.Engine.RenderDevice");
		sRenDevD = sRenDev;
		co_RenderDevice.SetComponentValue(sRenDev,true);
		break;

	case co_Shadows:
		tempStr = GetNativeClassName("Engine.Engine.RenderDevice");

		// No render-to-texture on anything but Direct3D.
		if ((tempStr == "D3DDrv.D3DRenderDevice") ||
		    (tempStr == "D3D9Drv.D3D9RenderDevice"))
		{
			a = bool(PC.ConsoleCommand("get ROEngine.ROPawn bPlayerShadows"));
			b = bool(PC.ConsoleCommand("get ROEngine.ROPawn bBlobShadow"));

			if ( b )
				iShadow = 1;
			else if (a)
				iShadow = 2;
			else
				iShadow = 0;
		}
        else
		{
			b = bool(PC.ConsoleCommand("get ROEngine.ROPawn bBlobShadow"));
			if ( b )
				iShadow = 1;
			else
				iShadow = 0;
		}

		iShadowD = iShadow;
		co_Shadows.SilentSetIndex(iShadow);
		break;

	case ch_DynLight:
		bDynLight = !bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoDynamicLights"));
		bDynLightD = bDynLight;
		ch_DynLight.SetComponentValue(bDynLight,true);
		break;

	case ch_FullScreen:
		bFullScreen = bool(PC.ConsoleCommand("ISFULLSCREEN"));
		bFullScreenD = bFullScreen;
		moCheckBox(Sender).SetComponentValue(bFullScreen,true);
		break;

	case ch_Trilinear:
		bTrilin = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice UseTrilinear"));
		bTrilinD = bTrilin;
		ch_Trilinear.SetComponentValue(bTrilin,true);
		break;

	case ch_Projectors:
		bProj = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Projectors"));
		bProjD = bProj;
		ch_Projectors.SetComponentValue(bProj,true);
		break;

	case ch_DecoLayers:
		bFol = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager DecoLayers"));
		bFolD = bFol;
		ch_DecoLayers.SetComponentValue(bFol,true);
		break;

	case ch_Textures:
		bTexture = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice DetailTextures"));
		bTextureD = bTexture;
		ch_Textures.SetComponentValue(bTexture,true);
		break;

	case ch_Coronas:
		bCorona = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Coronas"));
		bCoronaD = bCorona;
		ch_Coronas.SetComponentValue(bCorona,true);
		break;

	case ch_Decals:
		bDecal = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Decals"));
		bDecalD = bDecal;
		ch_Decals.SetComponentValue(bDecal,true);

		UpdateDecalStay();
		break;

	case sl_Gamma:
		fGamma = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Gamma"));
		sl_Gamma.SetComponentValue(fGamma,true);
		break;

	case sl_Brightness:
		fBright = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
		sl_Brightness.SetComponentValue(fBright,true);
		break;

	case sl_Contrast:
		fContrast = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Contrast"));
		sl_Contrast.SetComponentValue(fContrast,true);
		break;

	case ch_Weather:
		bWeather = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager WeatherEffects"));
		bWeatherD = bWeather;
		ch_Weather.SetComponentValue(bWeather,true);
		break;

	case sl_DistanceLOD:
		fDistance = float(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager DrawDistanceLOD"));
		fDistanceD = fDistance;
		sl_DistanceLOD.SetComponentValue(fDistance,true);
		break;

	default:
		log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}


function ROInternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;

	PC = PlayerOwner();
	switch (Sender)
	{

	// WeaponTODO: add this back in
//	case co_Scope:
//		switch (class'ROWeapon'.default.ScopeDetail)
//		{
//			case RO_ModelScope:
//				iScope = 0;
//				break;
//			case RO_TextureScope:
//				iScope = 1;
//				break;
//			case RO_ModelScopeHigh:
//				iScope = 2;
//				break;
//			default:
//			    iScope = -1;
//		}
//		iScopeD = iScope;
//		if(iScope < 0)
//		{
//		    co_Scope.SilentSetIndex(0);
//		}
//		else
//		{
//		    co_Scope.SilentSetIndex(iScope);
//        }
//		break;

	case ch_Blur:
		bBlur =  bool(PC.ConsoleCommand("get ROEngine.ROPlayer bUseBlurEffect"));
		bBlurD = bBlur;
		ch_Blur.SetComponentValue(bBlur,true);
		break;

	default:
		//log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function ROInternalOnChange(GUIComponent Sender)
{
	switch (Sender)
	{
		// These changes are saved all together during SaveSettings()
		case co_Scope:
			iScope = co_Scope.GetIndex();
			break;

		case ch_Blur:
			bBlur = ch_Blur.IsChecked();
			break;
    }
}

function SaveSettings()
{
	local string t, v, Str;
	local PlayerController PC;
	local bool bUnreal, bLevel;

	super(Settings_Tabs).SaveSettings();

// from UT2K4Tab_DetailSettings

	PC = PlayerOwner();

	if ( sRenDev != sRenDevD )
	{
		if ( Controller.SetRenderDevice(sRenDev) )
			sRenDevD = sRenDev;
	}

	if (iTexture != iTextureD)
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		Str = DetailLevels[iTexture];
		v = GetConfigString(Str);
		PC.ConsoleCommand(t$"Terrain"@v);
		PC.ConsoleCommand(t$"World"@v);
		PC.ConsoleCommand(t$"Rendermap"@v);
		PC.ConsoleCommand(t$"Lightmap"@v);
		PC.ConsoleCommand("flush");
		iTextureD = iTexture;
	}

	if (iChar != iCharD)
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		Str = DetailLevels[iChar];
		v = GetConfigString(Str);

		PC.ConsoleCommand(t$"WeaponSkin"@v);
		PC.ConsoleCommand(t$"PlayerSkin"@v);
		PC.ConsoleCommand("flush");

		iCharD = iChar;
	}

	if (iWorld != iWorldD)
	{
		Str = DetailLevels[iWorld];
		v = GetConfigString(Str);

		switch (iWorld)
		{
			case 3:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors False");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
				PC.Level.DetailChange(DM_Low);
				break;

			case 4:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
				PC.Level.DetailChange(DM_High);
				break;

			case 5:
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
				PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors True");
				PC.Level.DetailChange(DM_SuperHigh);
				break;
		}

		iWorldD = iWorld;
	}

	if ( iMeshLOD != iMeshLODD )
	{
		switch (iMeshLOD)
		{
		case 3:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Low;
			PC.Level.MeshLODDetailLevel = MDL_Low;
			break;
		case 4:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Medium;
			PC.Level.MeshLODDetailLevel = MDL_Medium;
			break;

		case 5:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_High;
			PC.Level.MeshLODDetailLevel = MDL_High;
			break;
		case 8:
			class'LevelInfo'.default.MeshLODDetailLevel = MDL_Ultra;
			PC.Level.MeshLODDetailLevel = MDL_Ultra;
			break;
		}

		iMeshLODD = iMeshLOD;
		bLevel = True;
	}

	if (iPhys != iPhysD)
	{
		switch (iPhys)
		{
			case 3:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_Low;
				PC.Level.PhysicsDetailLevel = PDL_Low;
				break;

			case 4:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_Medium;
				PC.Level.PhysicsDetailLevel = PDL_Medium;
				break;

			case 5:
				class'LevelInfo'.default.PhysicsDetailLevel = PDL_High;
				PC.Level.PhysicsDetailLevel = PDL_High;
				break;
		}

		iPhysD = iPhys;
		bLevel = True;
	}

	if ( iShadow != iShadowD )
	{
		if ( PC.Pawn != None && ROPawn(PC.Pawn) != None )
		{
			ROPawn(PC.Pawn).bBlobShadow = iShadow == 1;
			ROPawn(PC.Pawn).bPlayerShadows = iShadow > 0;
		}

		class'ROPawn'.default.bBlobShadow = iShadow == 1;
		class'ROPawn'.default.bPlayerShadows = iShadow > 0;
		iShadowD = iShadow;
		bUnreal = True;
	}

	if ( class'Vehicle'.default.bVehicleShadows != (iShadow > 0) )
	{
		class'Vehicle'.default.bVehicleShadows = iShadow > 0;
		class'Vehicle'.static.StaticSaveConfig();
	}

	if (bDynLight != bDynLightD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager NoDynamicLights"@!bDynLight);
		bDynLightD = bDynLight;
	}

	if (iDecal != iDecalD)
	{
		if (PC.Level != None)
			PC.Level.DecalStayScale = iDecal;

		class'LevelInfo'.default.DecalStayScale = iDecal;

		iDecalD = iDecal;
		bLevel = True;
	}

	if (bTrilin != bTrilinD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice UseTrilinear"@bTrilin);
		bTrilinD = bTrilin;
	}

	if (bFol != bFolD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager DecoLayers"@bFol);
		bFolD = bFol;
	}


	if (bProj != bProjD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Projectors"@bProj);
		bProjD = bProj;
	}

	if (bTexture != bTextureD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice DetailTextures"@bTexture);
		bTextureD = bTexture;
	}

	if (bCorona != bCoronaD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Coronas"@bCorona);
		bCoronaD = bCorona;
	}

	if (bDecal != bDecalD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Decals"@bDecal);
		bDecalD = bDecal;
	}

	if (bWeather != bWeatherD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager WeatherEffects"@bWeather);
		bWeatherD = bWeather;
	}

	if ( fDistance != fDistanceD )
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager DrawDistanceLOD" @ fDistance);
		PC.Level.UpdateDistanceFogLOD(fDistance);
		fDistanceD = fDistance;
	}

	if (bUnreal)
	{
		if (PC.Pawn != None && ROPawn(PC.Pawn) != None)
			ROPawn(PC.Pawn).SaveConfig();

		else class'ROPawn'.static.StaticSaveConfig();
	}

	if (bLevel)
	{
		if (PC.Level != None)
			PC.Level.SaveConfig();
		else class'LevelInfo'.static.StaticSaveConfig();
	}

// end from UT2K4Tab_DetailSettings


	PC = PlayerOwner();

	// WeaponTODO: Add this back in
//	class'ROEngine.ROWeapon'.default.ScopeDetail = ScopeDetailSettings(iScope);
//	class'ROEngine.ROWeapon'.static.StaticSaveConfig();
//
//	// adjust the in game scope
//	if(ROSniperWeapon(PC.Pawn.Weapon) != None)
//	{
//	    ROSniperWeapon(PC.Pawn.Weapon).ScopeDetail = class'ROEngine.ROWeapon'.default.ScopeDetail;
//	    ROSniperWeapon(PC.Pawn.Weapon).AdjustIngameScope();
//    }

	if (bBlur != bBlurD)
	{
		class'ROEngine.ROPlayer'.default.bUseBlurEffect = bBlur;
		class'ROEngine.ROPlayer'.static.StaticSaveConfig();

		if( ROPlayer(PC) != none )
		{
			ROPlayer(PC).bUseBlurEffect = bBlur;
		}

		bBlurD = bBlur;
	}
}

function SetupPositions()
{
    sb_Section1.ManageComponent(co_RenderDevice);
	sb_Section1.ManageComponent(co_Resolution);
    sb_Section1.ManageComponent(co_ColorDepth);
    sb_Section1.ManageComponent(ch_Fullscreen);
    sb_Section1.ManageComponent(sl_Gamma);
    sb_Section1.ManageComponent(sl_Brightness);
    sb_Section1.ManageComponent(sl_Contrast);

    sb_Section2.Managecomponent(co_Scope);
    sb_Section2.Managecomponent(co_Texture);
    sb_Section2.ManageComponent(co_Char);
    sb_Section2.ManageComponent(co_World);
    sb_Section2.ManageComponent(co_Physics);
	sb_Section2.ManageComponent(co_Decal);
    sb_Section2.ManageComponent(co_Shadows);
    sb_Section2.ManageComponent(co_MeshLOD);
    sb_Section2.Managecomponent(ch_Blur);
    sb_Section2.ManageComponent(ch_Decals);
    sb_Section2.ManageComponent(ch_DynLight);
    sb_Section2.ManageComponent(ch_Coronas);
    sb_Section2.ManageComponent(ch_Textures);
    sb_Section2.ManageComponent(ch_Projectors);
    sb_Section2.ManageComponent(ch_DecoLayers);
    sb_Section2.ManageComponent(ch_Trilinear);
    sb_Section2.ManageComponent(ch_Weather);
    sb_Section2.ManageComponent(sl_DistanceLOD);

	sb_Section3.ManageComponent(i_GammaBar);
}

function InitializeScopeCombo()
{
	local array<GUIListElem> Options;

	Options.Length = 3;
	Options[0].Item = ScopeLevels[0];
	Options[1].Item = ScopeLevels[1];
	Options[2].Item = ScopeLevels[2];
	co_Scope.MyComboBox.List.Elements = Options;
	co_Scope.MyComboBox.List.ItemCount = Options.Length;
	co_Scope.ReadOnly(True);
}

defaultproperties
{
     ScopeLevels(0)="Model"
     ScopeLevels(1)="Texture"
     ScopeLevels(2)="ModelHigh"
     Begin Object Class=moComboBox Name=ScopeDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Scope Detail"
         OnCreateComponent=ScopeDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes how scopes are displayed."
         WinTop=0.980000
         WinLeft=0.550000
         WinWidth=0.600000
         TabOrder=7
         OnChange=ROUT2K4Tab_DetailSettings.ROInternalOnChange
         OnLoadINI=ROUT2K4Tab_DetailSettings.ROInternalOnLoadINI
     End Object
     co_Scope=moComboBox'ROInterface.ROUT2K4Tab_DetailSettings.ScopeDetail'

     Begin Object Class=moCheckBox Name=MotionBlur
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Motion Blur"
         OnCreateComponent=MotionBlur.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables Motion Blur."
         WinTop=0.624136
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=14
         OnChange=ROUT2K4Tab_DetailSettings.ROInternalOnChange
         OnLoadINI=ROUT2K4Tab_DetailSettings.ROInternalOnLoadINI
     End Object
     ch_Blur=moCheckBox'ROInterface.ROUT2K4Tab_DetailSettings.MotionBlur'

     Begin Object Class=GUISectionBackground Name=sbSection1
         Caption="Resolution"
         WinTop=0.012761
         WinLeft=0.000948
         WinWidth=0.491849
         WinHeight=0.440729
         RenderWeight=0.010000
         OnPreDraw=sbSection1.InternalPreDraw
     End Object
     sb_Section1=GUISectionBackground'ROInterface.ROUT2K4Tab_DetailSettings.sbSection1'

     Begin Object Class=GUISectionBackground Name=sbSection2
         Caption="Options"
         WinTop=0.012761
         WinLeft=0.495826
         WinWidth=0.452751
         WinHeight=0.875228
         RenderWeight=0.010000
         OnPreDraw=sbSection2.InternalPreDraw
     End Object
     sb_Section2=GUISectionBackground'ROInterface.ROUT2K4Tab_DetailSettings.sbSection2'

     Begin Object Class=GUISectionBackground Name=sbSection3
         bFillClient=True
         Caption="Gamma Test"
         WinTop=0.476061
         WinLeft=0.011132
         WinWidth=0.462891
         WinHeight=0.411261
         RenderWeight=0.010000
         OnPreDraw=sbSection3.InternalPreDraw
     End Object
     sb_Section3=GUISectionBackground'ROInterface.ROUT2K4Tab_DetailSettings.sbSection3'

     Begin Object Class=GUIImage Name=GammaBar
         Image=Texture'InterfaceArt_tex.Menu.ROGammaSet'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.450001
         WinLeft=0.013477
         WinWidth=0.456250
         WinHeight=0.532117
         OnChange=UT2K4Tab_DetailSettings.InternalOnChange
     End Object
     i_GammaBar=GUIImage'ROInterface.ROUT2K4Tab_DetailSettings.GammaBar'

     Begin Object Class=UT2K4GameFooter Name=SPFooter
         PrimaryCaption="PLAY"
         PrimaryHint="Start A Match With These Settings"
         SecondaryCaption="SPECTATE"
         SecondaryHint="Spectate A Match With These Settings"
         Justification=TXTA_Left
         TextIndent=5
         FontScale=FNS_Small
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=SPFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4GameFooter'GUI2K4.UT2K4GamePageSP.SPFooter'

}
