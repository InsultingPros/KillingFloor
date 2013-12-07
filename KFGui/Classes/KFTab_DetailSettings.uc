class KFTab_DetailSettings extends UT2K4Tab_DetailSettings;

var automated moComboBox	    co_GlobalDetails;
var automated moComboBox	    co_ScopeDetail;

var automated moCheckbox        ch_HDR;
var automated moCheckbox        ch_Advanced;
var automated moCheckbox        ch_MotionBlur;
var automated moCheckbox        ch_VSync;
var automated moCheckbox        ch_TripBuff;
var automated moCheckbox        ch_WideScreen;

var() noexport transient int    iGlobalDetails, iScopeDetail,
                                iGlobalDetailsD, iScopeDetailD;

var() noexport transient bool   bMotionBlur, bMotionBlurD,
                                bHDR, bHDRD,
                                bVSync, bVSyncD,
                                bTripBuff, bTripBuffD,
								bWideScreen, bWideScreenD;

const                           MAX_DETAIL_OPTIONS = 7;
var() localized string          DetailOptions[MAX_DETAIL_OPTIONS];
var() localized string          ScopeLevels[3];

var bool                        bShowPerfWarning;   // Used to disable performance warnings

function bool InternalOnPreDraw(canvas Canvas)
{
    local bool result;

    result = super.OnPreDraw(canvas);

    if (iGlobalDetails == -1) // We need to pick default settings
    {
        iGlobalDetails = 3;
        co_GlobalDetails.SilentSetIndex(3);
        UpdateGlobalDetails();
    }
	else
	    UpdateGlobalDetailsVisibility();

	return result;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	RemoveComponent(sl_DistanceLOD);
}

function SetupPositions()
{
    sb_Section1.ManageComponent(co_RenderDevice);
    sb_Section1.ManageComponent(co_Resolution);
    sb_Section1.ManageComponent(co_ColorDepth);
    sb_Section1.ManageComponent(ch_Fullscreen);
	sb_Section1.ManageComponent(ch_WideScreen);
	sb_Section1.ManageComponent(ch_VSync);
	sb_Section1.ManageComponent(ch_TripBuff);
    sb_Section1.ManageComponent(sl_Gamma);
    sb_Section1.ManageComponent(sl_Brightness);
    sb_Section1.ManageComponent(sl_Contrast);
    sb_Section1.ManageComponent(co_GlobalDetails);
    sb_Section1.ManageComponent(ch_Advanced);

    sb_Section2.Managecomponent(co_Texture);
    sb_Section2.ManageComponent(co_Char);
    sb_Section2.ManageComponent(co_World);
    sb_Section2.ManageComponent(co_Physics);
    sb_Section2.ManageComponent(co_Decal);
    sb_Section2.ManageComponent(co_Shadows);
    sb_Section2.ManageComponent(co_MeshLOD);
    sb_Section2.ManageComponent(co_MultiSamples);
    sb_Section2.ManageComponent(co_Anisotropy);
    sb_Section2.ManageComponent(ch_ForceFSAAScreenshotSupport);
    sb_Section2.ManageComponent(ch_Decals);
    sb_Section2.ManageComponent(ch_DynLight);
    sb_Section2.ManageComponent(ch_Coronas);
    sb_Section2.ManageComponent(ch_Textures);
    sb_Section2.ManageComponent(ch_Projectors);
    sb_Section2.ManageComponent(ch_DecoLayers);
    sb_Section2.ManageComponent(ch_Trilinear);
    sb_Section2.ManageComponent(ch_Weather);
    sb_Section2.ManageComponent(co_ScopeDetail);
    sb_Section2.ManageComponent(ch_MotionBlur);
    sb_Section2.Managecomponent(ch_HDR);

    sb_Section3.ManageComponent(i_GammaBar);
}

function InitializeCombos()
{
	local int i;
	local array<GUIListElem> Options;

	for (i = 0; i < Components.Length; i++)
	{
		if (moComboBox(Components[i]) != None)
		{
			MyGetComboOptions( moComboBox(Components[i]), Options );
			moComboBox(Components[i]).MyComboBox.List.Elements = Options;
			moComboBox(Components[i]).MyComboBox.List.ItemCount = Options.Length;
			moComboBox(Components[i]).ReadOnly(True);
		}
	}
}

function MyGetComboOptions(moComboBox Combo, out array<GUIListElem> Ar)
{
	local int i;
	//local string tempStr;

	Ar.Remove(0, Ar.Length);
	if (Combo == None)
		return;

	switch (Combo)
	{
	    case co_GlobalDetails:
            for (i = 0; i < ArrayCount(DetailOptions); i++)
			{
				Ar.Length = Ar.Length + 1;
				Ar[i].Item = DetailOptions[i];
			}
			break;

		case co_ScopeDetail:
			for (i = 0; i < ArrayCount(ScopeLevels); i++)
			{
				Ar.Length = Ar.Length + 1;
				Ar[i].Item = ScopeLevels[i];
			}
			break;
	}

	if (Ar.length == 0)
	    GetComboOptions(Combo, Ar);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local bool a, b;
    local PlayerController PC;
    local string tempStr;

    PC = PlayerOwner();
    switch (Sender)
    {
        case co_GlobalDetails:
    		iGlobalDetails = class'ROPlayer'.default.GlobalDetailLevel;
    		iGlobalDetailsD = iGlobalDetails;
    		co_GlobalDetails.SilentSetIndex(iGlobalDetails);
            ch_Advanced.SetComponentValue(iGlobalDetailsD == MAX_DETAIL_OPTIONS, true);
    		break;

        case co_ScopeDetail:
            switch (class'KFWeapon'.default.KFScopeDetail)
            {
                case KF_ModelScope:
                    iScopeDetail = 0;
                    break;

                case KF_TextureScope:
                    iScopeDetail = 1;
                    break;

                case KF_ModelScopeHigh:
                    iScopeDetail = 2;
                    break;

                default:
                    iScopeDetail = -1;
            }

            iScopeDetailD = iScopeDetail;
            if (iScopeDetail < 0)
                co_ScopeDetail.SilentSetIndex(0);
            else
                co_ScopeDetail.SilentSetIndex(iScopeDetail);
            break;

    	case ch_MotionBlur:
    		bMotionBlur =  bool(PC.ConsoleCommand("get KFMod.KFHumanPawn bUseBlurEffect"));
    		bMotionBlurD = bMotionBlur;
    		ch_MotionBlur.SetComponentValue(bMotionBlur,true);
    		break;

    	case ch_HDR:
    	    bHDR = bool(PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
    	    bHDRD = bHDR;
    	    ch_HDR.SetComponentValue(bHDR,true);
    	    break;

    	case ch_Advanced:
    	    break; // value is set by co_GlobalDetails

    	case co_Shadows:
        tempStr = GetNativeClassName("Engine.Engine.RenderDevice");

        // No render-to-texture on anything but Direct3D (or OpenGL!).
        if ((tempStr == "D3DDrv.D3DRenderDevice") ||
            (tempStr == "D3D9Drv.D3D9RenderDevice") ||
            (tempStr == "OpenGLDrv.OpenGLRenderDevice"))
        {
            a = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bPlayerShadows"));
            b = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bBlobShadow"));

            if ( b )
                iShadow = 1;
            else if (a)
                iShadow = 2;
            else
                iShadow = 0;
        }
        else
        {
            b = bool(PC.ConsoleCommand("get UnrealGame.UnrealPawn bBlobShadow"));
            if ( b )
                iShadow = 1;
            else
                iShadow = 0;
        }

        iShadowD = iShadow;
        co_Shadows.SilentSetIndex(iShadow);
        break;

     	case ch_VSync:
	     	bVSync = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice UseVSync"));
	     	bVSyncD = bVSync;
	     	ch_VSync.SetComponentValue(bVSync, true);
	        break;

    	case ch_TripBuff:
	     	bTripBuff = bool(PC.ConsoleCommand("get ini:Engine.Engine.RenderDevice UseTripleBuffering"));
	     	bTripBuffD = bTripBuff;
	     	ch_TripBuff.SetComponentValue(bTripBuff, true);
	        break;

	    case ch_WideScreen:
	     	bWideScreen = bool(PC.ConsoleCommand("get kfmod.KFPlayerController bUseTrueWideScreenFOV"));
	     	bWideScreenD = bWideScreen;
	     	ch_WideScreen.SetComponentValue(bWideScreen, true);
	        break;

    default:
    		super.InternalOnLoadINI(sender, s);
    }

	// Post-super checks
	switch (Sender)
	{
	    case co_RenderDevice:
            DisableHDRControlIfNeeded();

            // Disable control if card doesn't support hdr
            if (PlayerOwner() != none)
                if (!PlayerOwner().PostFX_IsBloomCapable())
                    ch_HDR.DisableMe();

            break;
	}
}

function InternalOnChange(GUIComponent Sender)
{
    local bool bGoingUp;
    local int i;

    Super.InternalOnChange(Sender);

    if ( bIgnoreChange )
        return;

    switch (Sender)
    {
		// These changes are saved together on SaveSettings
        case co_GlobalDetails:
            i = co_GlobalDetails.GetIndex();
			bGoingUp = i > iGlobalDetails && i != iGlobalDetailsD && (i != MAX_DETAIL_OPTIONS - 1);
			iGlobalDetails = i;
			//ch_Advanced.SetComponentValue(i == MAX_DETAIL_OPTIONS, true);
			UpdateGlobalDetails();
			break;

		case co_ScopeDetail:
			i = co_ScopeDetail.GetIndex();
			bGoingUp = i > iScopeDetail && i != iScopeDetailD;
			iScopeDetail = i;
			break;

		case ch_MotionBlur:
			bMotionBlur = ch_MotionBlur.IsChecked();
			bGoingUp = bMotionBlur && bMotionBlur != bMotionBlurD;
			break;

    	case ch_HDR:
    	    bHDR = ch_HDR.IsChecked();
    	    bGoingUp = bHDR && bHDR != bHDRD;
    	    break;

		case ch_Advanced:
		    if (ch_Advanced.IsChecked())
		    {
		        iGlobalDetails = MAX_DETAIL_OPTIONS - 1;
    		    co_GlobalDetails.SilentSetIndex(iGlobalDetails);
    		}
            UpdateGlobalDetailsVisibility();
            break;

		case ch_VSync:
    	    bVSync = ch_VSync.IsChecked();
    	    break;

   		case ch_TripBuff:
    	    bTripBuff = ch_TripBuff.IsChecked();
    	    break;

    	case ch_WideScreen:
    	    bWideScreen = ch_WideScreen.IsChecked();
    	    break;
    }

    if (bGoingUp)
        ShowPerformanceWarning();
}

function ShowPerformanceWarning(optional float Seconds)
{
	if (bShowPerfWarning)
	    super.ShowPerformanceWarning(Seconds);
}

function UpdateGlobalDetails()
{
    local PlayerController PC;
	PC = PlayerOwner();

    UpdateGlobalDetailsVisibility();

    if ( iGlobalDetails == MAX_DETAIL_OPTIONS - 1 )
        return; // do not change settings if we picked custom

    bShowPerfWarning = false;

    switch (iGlobalDetails)
    {
        case 0: // Lowest
            co_Texture.SetIndex(0);         // Range = 0 - 8
            co_Char.SetIndex(0);            // Range = 0 - 8
            co_World.SetIndex(0);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(1);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(0);         // Range = 0 - 2
            co_Decal.setindex(0);           // Range = 0 - 2
            co_Shadows.setindex(0);         // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(0);         // Range = 0 - 3
            co_MultiSamples.setindex(0);
            co_Anisotropy.setindex(0);
            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(false, false);
            ch_DynLight.SetComponentValue(false, false);
            ch_Coronas.SetComponentValue(false, false);
            ch_Textures.SetComponentValue(false, false);
            ch_Projectors.SetComponentValue(false, false);
            ch_DecoLayers.SetComponentValue(false, false);
            ch_Trilinear.SetComponentValue(false, false);
            ch_Weather.SetComponentValue(false, false);
            ch_DecoLayers.SetComponentValue(false, false);
            ch_MotionBlur.SetComponentValue(false, false);
            ch_HDR.SetComponentValue(false, false);
            break;

        case 1: // Low
            co_Texture.SetIndex(3);         // Range = 0 - 8
            co_Char.SetIndex(3);            // Range = 0 - 8
            co_World.SetIndex(0);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(1);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(0);         // Range = 0 - 2
            co_Decal.setindex(1);           // Range = 0 - 2
            co_Shadows.setindex(1);         // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(1);         // Range = 0 - 3
            co_MultiSamples.setindex(0);

            if (AnisotropyModes.Length>1)
                 co_Anisotropy.SetIndex(1);
            else
                 co_Anisotropy.setindex(0);

            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(true, false);
            ch_DynLight.SetComponentValue(false, false);
            ch_Coronas.SetComponentValue(true, false);
            ch_Textures.SetComponentValue(false, false);
            ch_Projectors.SetComponentValue(true, false);
            ch_DecoLayers.SetComponentValue(true, false);
            ch_Trilinear.SetComponentValue(false, false);
            ch_Weather.SetComponentValue(true, false);
            ch_MotionBlur.SetComponentValue(true, false);
            ch_HDR.SetComponentValue(false, false);
            break;

        case 2: // Medium
            co_Texture.SetIndex(5);         // Range = 0 - 8
            co_Char.SetIndex(5);            // Range = 0 - 8
            co_World.SetIndex(1);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(1);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(1);         // Range = 0 - 2
            co_Decal.setindex(1);           // Range = 0 - 2
            co_Shadows.setindex(1);         // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(2);         // Range = 0 - 3
            co_MultiSamples.setindex(0);

            if (AnisotropyModes.Length>2)
                 co_Anisotropy.setindex(2);
            else if (AnisotropyModes.Length>1)
                 co_Anisotropy.SetIndex(1);
            else
                 co_Anisotropy.setindex(0);

            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(true, false);
            ch_DynLight.SetComponentValue(true, false);
            ch_Coronas.SetComponentValue(true, false);
            ch_Textures.SetComponentValue(true, false);
            ch_Projectors.SetComponentValue(true, false);
            ch_DecoLayers.SetComponentValue(true, false);
            ch_Trilinear.SetComponentValue(false, false);
            ch_Weather.SetComponentValue(true, false);
            ch_MotionBlur.SetComponentValue(true, false);
            ch_HDR.SetComponentValue(false, false);
            break;

        case 3: // High
            co_Texture.SetIndex(6);         // Range = 0 - 8
            co_Char.SetIndex(6);            // Range = 0 - 8
            co_World.SetIndex(2);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(0);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(1);         // Range = 0 - 2
            co_Decal.setindex(2);           // Range = 0 - 2
            co_Shadows.setindex(1);         // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(2);         // Range = 0 - 3
            co_MultiSamples.setindex(0);

            if (MultiSampleModes.Length>1)
                 co_MultiSamples.setindex(1);
            else
                 co_MultiSamples.setindex(0);

            if(AnisotropyModes.Length>3)
                 co_Anisotropy.setindex(3);
            else if (AnisotropyModes.Length>2)
                 co_Anisotropy.setindex(2);
            else if (AnisotropyModes.Length>1)
                 co_Anisotropy.SetIndex(1);
            else
                 co_Anisotropy.setindex(0);

            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(true, false);
            ch_DynLight.SetComponentValue(true, false);
            ch_Coronas.SetComponentValue(true, false);
            ch_Textures.SetComponentValue(true, false);
            ch_Projectors.SetComponentValue(true, false);
            ch_DecoLayers.SetComponentValue(true, false);
            ch_Trilinear.SetComponentValue(false, false);
            ch_Weather.SetComponentValue(true, false);
            ch_MotionBlur.SetComponentValue(true, false);
            ch_HDR.SetComponentValue(true, false);
            break;

        case 4: // Higher
            co_Texture.SetIndex(7);         // Range = 0 - 8
            co_Char.SetIndex(7);            // Range = 0 - 8
            co_World.SetIndex(2);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(2);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(1);         // Range = 0 - 2
            co_Decal.setindex(2);           // Range = 0 - 2
            co_Shadows.setindex(min(co_Shadows.ItemCount() - 1, 3));  // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(2);         // Range = 0 - 3

            if(MultiSampleModes.Length>2)
                 co_MultiSamples.setindex(2);
            else if (MultiSampleModes.Length>1)
                 co_MultiSamples.setindex(1);
            else
                 co_MultiSamples.setindex(0);

            if(AnisotropyModes.Length>3)
                 co_Anisotropy.setindex(3);
            else if (AnisotropyModes.Length>2)
                 co_Anisotropy.SetIndex(2);
            else if (AnisotropyModes.Length>1)
                 co_Anisotropy.SetIndex(1);
            else
                 co_Anisotropy.setindex(0);

            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(true, false);
            ch_DynLight.SetComponentValue(true, false);
            ch_Coronas.SetComponentValue(true, false);
            ch_Textures.SetComponentValue(true, false);
            ch_Projectors.SetComponentValue(true, false);
            ch_DecoLayers.SetComponentValue(true, false);
            ch_Trilinear.SetComponentValue(false, false);
            ch_Weather.SetComponentValue(true, false);
            ch_MotionBlur.SetComponentValue(true, false);
            ch_HDR.SetComponentValue(true, false);
            break;

        case 5: // Highest
            co_Texture.SetIndex(8);         // Range = 0 - 8
            co_Char.SetIndex(8);            // Range = 0 - 8
            co_World.SetIndex(2);           // Range = 0 - 2
            co_ScopeDetail.SetIndex(2);     // Range = 0 - 2 , 1 being lowest
            co_Physics.setindex(2);         // Range = 0 - 2
            co_Decal.setindex(2);           // Range = 0 - 2
            co_Shadows.setindex(min(co_Shadows.ItemCount() - 1, 3));  // Range = 0 - 2 (0 - 1 sometimes -- check that!)
            co_MeshLOD.setindex(3);         // Range = 0 - 3

            if(
                  (
                      (true==bool(PC.ConsoleCommand("ISNVIDIAGPU")))
                       && (false==bool(PC.ConsoleCommand("SUPPORTEDMULTISAMPLE 4"))
                   )
                   || (false==bool(PC.ConsoleCommand("ISNVIDIAGPU"))))
                   && (MultiSampleModes.Length>3)
               )
                 co_MultiSamples.setindex(3);
            else if(MultiSampleModes.Length>2)
                 co_MultiSamples.setindex(2);
            else if (MultiSampleModes.Length>1)
                 co_MultiSamples.setindex(1);
            else
                 co_MultiSamples.setindex(0);

            co_Anisotropy.setindex(AnisotropyModes.Length-1);
            ch_ForceFSAAScreenshotSupport.SetComponentValue(false,false);
            ch_Decals.SetComponentValue(true, false);
            ch_DynLight.SetComponentValue(true, false);
            ch_Coronas.SetComponentValue(true, false);
            ch_Textures.SetComponentValue(true, false);
            ch_Projectors.SetComponentValue(true, false);
            ch_DecoLayers.SetComponentValue(true, false);
            ch_Trilinear.SetComponentValue(true, false);
            ch_Weather.SetComponentValue(true, false);
            ch_MotionBlur.SetComponentValue(true, false);
            ch_HDR.SetComponentValue(true, false);
            break;
    }

    bShowPerfWarning = true;

}

function UpdateGlobalDetailsVisibility()
{
    if (iGlobalDetails == MAX_DETAIL_OPTIONS - 1 || ch_Advanced.IsChecked()) // custom
    {
        //sb_Section2.SetVisibility(true);
        /*sb_Section1.WinLeft = SavedContainer1Pos;
        sb_Section2.WinLeft = SavedContainer2Pos;
        sb_Section3.WinLeft = SavedContainer3Pos;*/
        sb_Section2.EnableMe();
        DisableHDRControlIfNeeded();

        // wtf m8 _RO_
        if ((co_RenderDevice.GetExtra() != "D3D9Drv.D3D9RenderDevice") &&
            (co_RenderDevice.GetExtra() != "OpenGLDrv.OpenGLRenderDevice"))
        {
           co_MultiSamples.DisableMe();
           ch_ForceFSAAScreenshotSupport.DisableMe();
        }
        // _RO_

        //ch_Advanced.SetComponentValue(true ,true);
    }
    else
    {
        //sb_Section2.SetVisibility(false);
        /*sb_Section1.WinLeft = Container1PosAlt;
        sb_Section2.WinLeft = 1.0;
        sb_Section3.WinLeft = Container3PosAlt;*/
        sb_Section2.DisableMe();
        //ch_Advanced.SetComponentValue(false ,true);
    }
}

function DisableHDRControlIfNeeded()
{
    // Bloom only available when using direct3d 9.0
    if ((co_RenderDevice.GetExtra() != "D3D9Drv.D3D9RenderDevice") &&
        (co_RenderDevice.GetExtra() != "OpenGLDrv.OpenGLRenderDevice"))
    {
        ch_HDR.DisableMe();
    }
}

function SaveSettings()
{
	local PlayerController PC;
	local bool bSavePlayerConfig;
	local Inventory inv;
	local KFWeapon KFWeap;
	local int i;

	Super.SaveSettings();

	PC = PlayerOwner();

	if ( bVSync != bVSyncD )
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice UseVSync" @ bVSync);
		bVSyncD = bVSync;
	}

	if ( bTripBuff != bTripBuffD )
	{
		PC.ConsoleCommand("set ini:Engine.Engine.RenderDevice UseTripleBuffering" @ bTripBuff);
		bTripBuffD = bTripBuff;
	}

	if ( bWideScreen != bWideScreenD )
	{
		PC.ConsoleCommand("set kfmod.KFPlayerController bUseTrueWideScreenFOV" @ bWideScreen);
		bWideScreenD = bWideScreen;
	}

	if (bMotionBlur != bMotionBlurD)
	{
		class'KFMod.KFHumanPawn'.default.bUseBlurEffect = bMotionBlur;
		//bSavePlayerConfig = true;
		class'KFMod.KFHumanPawn'.static.StaticSaveConfig();

		if (KFHumanPawn(PC.Pawn) != none)
		{
			KFHumanPawn(PC.Pawn).bUseBlurEffect = bMotionBlur;
			KFHumanPawn(PC.Pawn).SaveConfig();
		}

		bMotionBlurD = bMotionBlur;
	}

	if (bHDR != bHDRD)
	{
		PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager Bloom"@bHDR);

		if (PC != none)
		{
			PC.PostFX_SetActive(0, bHDR);
		}

		bHDRD = bHDR;
	}

	if (iScopeDetail != iScopeDetailD)
	{
        class'KFMod.KFWeapon'.default.KFScopeDetail = KFScopeDetailSettings(iScopeDetail);
        class'KFMod.KFWeapon'.static.StaticSaveConfig();


        // Initialize the FOV of all the weapons the player is carrying
    	if( PC.Pawn != none )
        {
        	for ( Inv=PC.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
        	{
        		i++;
                KFWeap = KFWeapon(Inv);
        		if ( KFWeap != None && KFWeap.bHasScope )
        		{
                    KFWeap.KFScopeDetail = class'KFMod.KFWeapon'.default.KFScopeDetail;
                    KFWeap.AdjustIngameScope();
        		}

        		// Little hack to catch possible runaway loops. Gotta love those linked listed in UE2.5 - Ramm
        		if( i > 10000 )
        		  break;
        	}
    	}

        iScopeDetailD = iScopeDetail;
	}
// KFTODO: Implement this in the KF player class
	if (iGlobalDetails != iGlobalDetailsD)
	{
        class'ROEngine.ROPlayer'.default.GlobalDetailLevel = iGlobalDetails;
        bSavePlayerConfig = true;

        iGlobalDetailsD = iGlobalDetails;
	}

	if ( iShadow != iShadowD )
	{
		if ( PC.Pawn != None && UnrealPawn(PC.Pawn) != None )
		{
            UnrealPawn(PC.Pawn).bBlobShadow = iShadow == 1;
			UnrealPawn(PC.Pawn).bPlayerShadows = iShadow > 0;
		}

		class'UnrealPawn'.default.bBlobShadow = iShadow == 1;
		class'UnrealPawn'.default.bPlayerShadows = iShadow > 0;
		iShadowD = iShadow;

		if (PC.Pawn != None && UnrealPawn(PC.Pawn) != None)
			UnrealPawn(PC.Pawn).SaveConfig();
		else
            class'UnrealPawn'.static.StaticSaveConfig();

   		UpdateShadows(iShadow == 1, iShadow > 0);
	}

	if ( class'Vehicle'.default.bVehicleShadows != (iShadow > 0) )
	{
		class'Vehicle'.default.bVehicleShadows = iShadow > 0;
		class'Vehicle'.static.StaticSaveConfig();
		UpdateVehicleShadows(iShadow > 0);
	}

	if (bSavePlayerConfig)
	   class'ROEngine.ROPlayer'.static.StaticSaveConfig();
}

simulated function UpdateShadows(bool bBlobShadow, bool bPlayerShadows)
{
    local PlayerController PC;
    local UnrealPawn pawn;

    PC = PlayerOwner();

    if (PC == none || PC.Level.NetMode == NM_DedicatedServer)
        return;

    foreach PC.DynamicActors(class'UnrealPawn', pawn)
    {
        pawn.bBlobShadow = bBlobShadow;
        pawn.bPlayerShadows = bPlayerShadows;
        if( KFPawn(Pawn) != none )
        {
            KFPawn(Pawn).UpdateShadow();
        }
        else if( KFMonster(Pawn) != none )
        {
            KFMonster(Pawn).UpdateShadow();
        }
    }
}

simulated function UpdateVehicleShadows(bool bVehicleShadows)
{
    local PlayerController PC;
    local Vehicle vehicle;

    PC = PlayerOwner();

    if (PC == none || PC.Level.NetMode == NM_DedicatedServer)
        return;

    foreach PC.DynamicActors(class'Vehicle', vehicle)
    {
        vehicle.bVehicleShadows = bVehicleShadows;
        vehicle.UpdateShadow();
    }
}

function ResetClicked()
{
	class'ROEngine.ROPlayer'.static.ResetConfig("GlobalDetailLevel");
	class'KFMod.KFWeapon'.static.ResetConfig("KFScopeDetail");
	class'KFMod.KFHumanPawn'.static.ResetConfig("bUseBlurEffect");

	Super.ResetClicked();
}

defaultproperties
{
     Begin Object Class=moComboBox Name=GlobalDetails
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Game details"
         OnCreateComponent=GlobalDetails.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Higher"
         Hint="Changes the quality of the graphics in the game"
         WinTop=0.063021
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=2
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     co_GlobalDetails=moComboBox'KFGui.KFTab_DetailSettings.GlobalDetails'

     Begin Object Class=moComboBox Name=ScopeDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Scope Detail"
         OnCreateComponent=ScopeDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Model (Low)"
         Hint="Changes how weapon scope views should be rendered"
         WinTop=0.063021
         WinLeft=0.550000
         WinWidth=0.400000
         TabOrder=9
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     co_ScopeDetail=moComboBox'KFGui.KFTab_DetailSettings.ScopeDetail'

     Begin Object Class=moCheckBox Name=HDRCheckbox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="HDR Bloom"
         OnCreateComponent=HDRCheckbox.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables the Bloom effect"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=13
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_HDR=moCheckBox'KFGui.KFTab_DetailSettings.HDRCheckbox'

     Begin Object Class=moCheckBox Name=Advanced
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Show Advanced Options"
         OnCreateComponent=Advanced.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables you to configure display options more precisely"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=2
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_Advanced=moCheckBox'KFGui.KFTab_DetailSettings.Advanced'

     Begin Object Class=moCheckBox Name=MotionBlur
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Motion Blur"
         OnCreateComponent=MotionBlur.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables motion blur effects"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=13
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_MotionBlur=moCheckBox'KFGui.KFTab_DetailSettings.MotionBlur'

     Begin Object Class=moCheckBox Name=VSyncbox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Vertical Sync"
         OnCreateComponent=VSyncbox.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Syncs the frame rate to your monitor's refresh rate"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=4
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_VSync=moCheckBox'KFGui.KFTab_DetailSettings.VSyncbox'

     Begin Object Class=moCheckBox Name=TripBuffbox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Triple Buffering"
         OnCreateComponent=TripBuffbox.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="May help framerate/smoothness if VSync is turned on"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=4
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_TripBuff=moCheckBox'KFGui.KFTab_DetailSettings.TripBuffbox'

     Begin Object Class=moCheckBox Name=WideScreenbox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Widescreen"
         OnCreateComponent=WideScreenbox.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables widescreen support"
         WinTop=0.479308
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=4
         OnChange=KFTab_DetailSettings.InternalOnChange
         OnLoadINI=KFTab_DetailSettings.InternalOnLoadINI
     End Object
     ch_WideScreen=moCheckBox'KFGui.KFTab_DetailSettings.WideScreenbox'

     DetailOptions(0)="Lowest"
     DetailOptions(1)="Low"
     DetailOptions(2)="Medium"
     DetailOptions(3)="High"
     DetailOptions(4)="Higher"
     DetailOptions(5)="Highest"
     DetailOptions(6)="Custom"
     ScopeLevels(0)="Model (Low)"
     ScopeLevels(1)="Textured"
     ScopeLevels(2)="Model (High)"
     RenderModeText(0)="Direct 3D 9.0"
     RenderModeText(1)="Direct 3D"
     RenderModeText(2)="OpenGL"
     RenderMode(0)="D3D9Drv.D3D9RenderDevice"
     RenderMode(1)="D3DDrv.D3DRenderDevice"
     RenderMode(2)="OpenGLDrv.OpenGLRenderDevice"
     Begin Object Class=GUISectionBackground Name=sbSection1
         Caption="Resolution"
         WinTop=0.012761
         WinLeft=0.000948
         WinWidth=0.485000
         WinHeight=0.540729
         RenderWeight=0.010000
         OnPreDraw=sbSection1.InternalPreDraw
     End Object
     sb_Section1=GUISectionBackground'KFGui.KFTab_DetailSettings.sbSection1'

     Begin Object Class=GUISectionBackground Name=sbSection3
         bFillClient=True
         Caption="Gamma Test"
         WinTop=0.576061
         WinLeft=0.000948
         WinWidth=0.485000
         WinHeight=0.411928
         RenderWeight=0.010000
         OnPreDraw=sbSection3.InternalPreDraw
     End Object
     sb_Section3=GUISectionBackground'KFGui.KFTab_DetailSettings.sbSection3'

     Begin Object Class=GUIImage Name=GammaBar
         Image=Texture'2K4Menus.Controls.Gamma'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         OnChange=KFTab_DetailSettings.InternalOnChange
     End Object
     i_GammaBar=GUIImage'KFGui.KFTab_DetailSettings.GammaBar'

     OnPreDraw=KFTab_DetailSettings.InternalOnPreDraw
}
