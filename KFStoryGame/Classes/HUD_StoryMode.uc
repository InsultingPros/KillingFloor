/*
	--------------------------------------------------------------
	HUD_StoryMode
	--------------------------------------------------------------

	Custom HUD type for use in KF 'Story' maps.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class HUD_StoryMode extends HUDKillingFloorSP
dependson(KFStoryGameInfo) ;

/* Same sort of icon as the Trader arrow -  shows you roughly where your next objective is located */
var						KFShopDirectionPointer		    ObjectiveArrow;

var     				KF_StoryGRI				  	    SGRI;

/* The amount of time that has passed since the last HUD Tick.  Used for controlling interpolation */
var                     float                           RenderDelta;

var                     float                           LastHUDRenderTime;

var                     float                           LastIconUpdateTime;

/* Current game objective according to the game replication info */
var						KF_StoryObjective				CurrentObj;

/* The HUD's currently rendered objective.  Tends to lag behind the 'CurrentObj' var because it fades in/ out*/
var						KF_StoryObjective				RenderObj;

var						int								ObjRenderIdx;

/* Objectives which haven't yet been displayed on the player's HUD but are qued & awaiting fade in/ out effects*/
var array				<KF_StoryObjective>				HUDObjs;

/* Cached list of all the objectives in the map */
var array               <KF_StoryObjective>             AllObjs;

/* Opacity of the currently rendered objective on the HUD */
var						float							RenderObjOpacity;

var						bool							bFadingIn;

var						bool							bFadingOut;

var                     float                           PendingFadeOutStartTime;

var                     bool                            bPendingFadeOut;

var						bool							bSkipTransitions;

var						float				            ObjFadeOutTime,ObjFadeInTime;

/* The amount of delay after an objective completes before it actually fades out */
var						float				            ObjFadeOutDelay;

/* Skip the usual fading between objectives and just display the current one */
var						bool				            bInstantObjTransitions;

var						float				            LastNewRenderObjTime;

var						bool				            bFadingOutObj;

var						bool				            bShowObjectives;

var                     bool                            bCollapseConditions;


struct SConditionHint
{
    var      name                                       ConditionName;
	var		 string										DataString,WorldHint;
	var      int                                        bComplete;
	var      float                                      ProgressPct;
	var      color                                      ProgressBar_Clr;
	var      color                                      World_Clr;
	var      byte                                       ConditionType,HintStyle,DisplayStyle;  // 1 == success , 0 == failure
	var      Actor                                      ConditionLoc;
	var      Material                                   WorldTex;
	var      Material                                   Material_ProgressBarFill,Material_ProgressBarBG;
	var      int                                        FontScale;
	var      bool                                       bHideWorld;
	var      bool                                       bIgnoreWorldHidden;
	var      float                                      LastProgressUpdateTime ;
	var      float                                      LastProgressVal;
	var      float                                      WidestDataX;
	var      float                                      ProgBarheight;
	var      float                                      HintWidth;
	var      float                                      HintHeight;
	var      name                                       ObjOwner;
	var      bool                                       bShowCheckBox;
	var      float                                      World_Texture_Scale;
	var 	 name										PendingLocActorTag ;   	// we want to cache an actor, but have no reference to it yet .
};


var array<SConditionHint>                               ConditionHints;

var                     float                           lastConditionupdateTime;

/* === Dialogue Rendering =================================================================================*/

struct SDialogueRenderInfo
{
     var    string                                      Speaker;
     var    string                                      Message;
     var    float                                       Duration;
     var    Material                                    Portrait;
     var    float                                       FirstDisplayedTime;
     var    float                                       Opacity;
     var    bool                                        bWrapped;
     var    bool                                        bFirstDisplay;
     var    KFStoryGameInfo.SVect2D                     ScreenPos;
     var    KFStoryGameInfo.EDialogueAlignment          ScreenAlignment;
     var    LobbyMenuAd                                 BinkPortrait;
     var    Material                                    BackGroundMat;
     var    KFStoryGameInfo.EDialogueScaleStyle         ScreenScaleStyle;
};

var array<SDialogueRenderInfo>                          Dialogues;

var array<KF_DialogueSpot>                              DialogueSpots;

var int                                                 CurrentDlgIndex;

var  	                                                SpriteWidget        DialogueBackground;
var  	                                                TextWidget          DialogueTitleWidget;
var  	                                                TextWidget          DialogueTextWidget;
var                                                     RelativeCoordsInfo  DialogueCoords;

var  array<string>                                      WrappedDialogue;

var                     LobbyMenuAd                     Intro_BinkMovie;

var                     bool                            bPlayingIntroMovie;

var                     bool                            bPlayedIntroMovie;

var                     KF_HUDStyleManager              HUDStyleManager;

var						int								StoryIconOffsetX;
var						int								StoryIconOffsetY;

/* @todo - there's a bug in this code where bNoKFColorCorrection is ignored, needs fixing
for now just gonna empty out this func
simulated function DrawModOverlay( Canvas C ){}  */

/* 	toggles displaying properties of player's current viewtarget

	Cut out the StandAlone only condition so I can see what up in net-play
*/

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    CacheDialogueActors();
    CacheObjectives();
}

simulated function CacheObjectives()
{
    local KF_StoryObjective Obj;

    foreach AllActors(class 'KF_StoryObjective', Obj)
    {
        AllObjs[AllObjs.length] = Obj;
    }
}

simulated function CacheDialogueActors()
{
    local KF_DialogueSpot   NewDlgSpot;

    foreach AllActors(class 'KF_DialogueSpot', NewDlgSpot)
    {
        DialogueSpots[DialogueSpots.length] = NewDlgSpot;
    }
}

simulated function KF_DialogueSpot FindDialogueActor(name DlgName)
{
    local int i;

    for(i = 0 ; i < DialogueSpots.length ; i ++)
    {
        if(DialogueSpots[i].name == DlgName)
        {
            return DialogueSpots[i];
        }
    }
}

exec function ShowDebug()
{
	bShowDebugInfo = !bShowDebugInfo;
}

exec simulated function ToggleObjectiveHUD()
{
	bShowObjectives = !bShowObjectives ;
}

simulated function DrawSpectatingHud(Canvas C)
{
	Super.DrawSpectatingHUD(C);
    DrawStoryHUDInfo(C);
}


simulated function DrawHudPassA (Canvas C)
{
    DrawStoryHUDInfo(C);
    Super.DrawHUDPassA(C);
}

simulated function DrawStoryHUDInfo(Canvas C)
{
	if(bHideHUD ||
    PlayerOwner != none &&
    PlayerOwner.Player != none &&
	GUIController(PlayerOwner.Player.GUIController) != none &&
	GUIController(PlayerOwner.Player.GUIController).ActivePage != none)  // we've got another menu open, dont show this stuff...
	{
        return;
    }

    RenderStoryItems(C);
    DrawObjectiveInfo(C);

    if(!bShowScoreBoard)
    {
        DrawDialogue(C);
    }
}

/* Specific function to use Canvas.DrawActor()
 Clear Z-Buffer once, prior to rendering all actors */
function CanvasDrawActors( Canvas C, bool bClearedZBuffer )
{
    PostRenderStoryInventory(C);
    Super.CanvasDrawActors(C,bClearedZBuffer);
}

function PostRenderStoryInventory(Canvas C)
{
	local Inventory CurInv;
	local KF_StoryInventoryItem StoryInv;

    if(PawnOwner == none)
    {
        return;
    }

	for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
        StoryInv = KF_StoryInventoryItem(CurInv);
        if(StoryInv != none )
        {
            StoryInv.RenderOverlays(C);
        }
	}
}

/* Draws overlays for Pickup-able or currently carried items in story missions */
simulated function RenderStoryItems(Canvas C)
{
	local Inventory CurInv;
	local KF_StoryInventoryItem StoryInv;
	local float PosX,PosY;
	local float IconSizeX,IconSizeY;
	local Material InvIcon;
    local float ScaleX,ScaleY;
    local int i;
    local KF_StoryPRI PRI;
    local float Opacity;
	local float IconSize;
	local float XCentre,YCentre;
	local vector ScreenPos;
	local Material RenderMat;
	local vector CameraLocation;
	local rotator CameraRotation;
	local float Dist;
	local vector RenderLocation;
	local vector CurrentPawnPos,NextPawnPos;
	local float AbsoluteDist;
	local vector MovementDir;
	local float DistMax;
	local float InterpSpeed,InterpDist;
    local KF_StoryInventoryPickup Pickup;

    /* Render icons over players heads while they are carrying Story Items*/
    if(PlayerOwner != none && PlayerOwner.GameReplicationinfo != none)
    {
        for(i = 0 ; i < PlayerOwner.GameReplicationInfo.PRIArray.length ; i ++)
        {
            PRI = KF_StoryPRI(PlayerOwner.GameReplicationInfo.PRIArray[i]);
            if(PRI == none ||
            PRI == PlayerOwner.PlayerReplicationInfo ||
            PRI.GetFloatingIconMat() == none)
            {
                continue;
            }
            else
            {
                /* Looks like we've got a relevant pawn.  That makes things nice and easy.. */
                if(PRI.GetOwnerPawn() != none &&
                !PRI.GetOwnerPawn().bDeleteMe &&
                !PRI.GetOwnerPawn().bPendingDelete)
                {
                    RenderLocation = PRI.GetOwnerPawn().GetHoverIconPosition() ;
                }
                else   // he's not relevant -  do some interpolation mumbo jumbo and pray it doesn't look horrible ..
                {
                    CurrentPawnPos  =   PRI.GetCurrentPawnLoc();

                    if(CurrentPawnPos == vect(0,0,0) ||
                    PRI.GetLastPawnLoc() == vect(0,0,0))
                    {
                        continue;
                    }

                    /* Client prediction - Attempt to figure out where the next update will place the Icon*/

                    MovementDir = Normal(CurrentPawnPos - PRI.GetLastPawnLoc());
                    AbsoluteDist = VSize(CurrentPawnPos - PRI.GetLastPawnLoc());
                    NextPawnPos  = CurrentPawnPos + (MovementDir * AbsoluteDist);

                    DistMax = 500.f;
                    InterpDist = VSize(NextPawnPos - PRI.GetInterpolatedPawnLoc());
                    InterpSpeed = InterpDist;

//                    log("InterpDist : "@InterpDist@" === InterpSpeed : "@InterpSpeed);

                    /* Huge move -  re-position immediately */
                    if(InterpDist > DistMax)
                    {
                        PRI.SetInterpolatedPawnLoc(NextPawnPos);
                    }

                    PRI.SetInterpolatedPawnLoc(VInterpTo(PRI.GetInterpolatedPawnLoc(),NextPawnPos,RenderDelta,InterpSpeed));

                    RenderLocation = PRI.GetInterpolatedPawnLoc();
                }

                if(RenderLocation == Vect(0,0,0))
                {
                    continue;
                }

                C.GetCameraLocation(CameraLocation, CameraRotation);

            	/* fading jazz from PlayerBeacon code */

            	Dist = vsize(CameraLocation-RenderLocation);
            	Dist -= class 'HUDKillingFloor'.default.HealthBarFullVisDist;
            	Dist = FClamp(Dist, 0, class 'HUDKillingFloor'.default.HealthBarCutoffDist-class 'HUDKillingFloor'.default.HealthBarFullVisDist);
            	Dist = Dist / (class 'HUDKillingFloor'.default.HealthBarCutoffDist- class 'HUDKillingFloor'.default.HealthBarFullVisDist);
            	Opacity = Max(byte((1.f - Dist) * 255.f),100.f);

                RenderMat = PRI.GetFloatingIconMat();
            	IconSize = 48.f;

                ScreenPos = C.WorldToScreen(RenderLocation);

                XCentre = ScreenPos.X;
                YCentre = ScreenPos.Y;

                /* Dont render stuff behind the camera */
            	if ( (Normal(RenderLocation - CameraLocation) dot vector(CameraRotation)) < 0 )
            	{
                    continue;
                }

                C.DrawColor.R = 255;
                C.DrawColor.G = 255;
                C.DrawColor.B = 255;
                C.DrawColor.A = Opacity;

                C.SetPos(XCentre - (0.5 * IconSize) - StoryIconOffsetX, YCentre - (0.5 * IconSize) - StoryIconOffsetY);
                C.DrawTileScaled(RenderMat, IconSize/ RenderMat.MaterialVSize() ,IconSize/ RenderMat.MaterialVSize() );
            }
        }
	}


    if( PawnOwner == none )
	{
		return;
	}

    /* Draw Projected World Icons */

    foreach DynamicActors(class 'KF_StoryInventoryPickup', Pickup)
    {
        Pickup.RenderOverlays(C);
    }


    PosX = C.ClipX * 0.3  ;
    PosY = C.ClipY * 0.9  ;

	IconSizeX = C.ClipX / 32.f;
	IconSizeY = IconSizeX;

    /* Draw little HUD Icons on the owning player's HUD */
	for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
        StoryInv = KF_StoryInventoryItem(CurInv);
        if(StoryInv != none )
        {
            if(StoryInv.CarriedMaterial != none)
            {
                InvIcon = StoryInv.CarriedMaterial ;

                ScaleX = IconSizeX/ InvIcon.MaterialVSize() ;
                ScaleY = IconSizeY / InvIcon.MaterialVSize() ;

                C.SetPos(PosX- IconSizeX/2,PosY+ IconSizeY/2);
                C.DrawColor = WhiteColor;
                C.DrawColor.A = KFHUDAlpha;

                C.DrawTileScaled(InvIcon,ScaleX,ScaleY);

                PosX += (IconSizeX*ScaleX) * 1.1;
            }
        }
	}
}


/** Interpolate vector from Current to Target with constant step */
simulated function Vector VInterpTo(Vector Current, Vector Target, FLOAT DeltaTime, FLOAT InterpSpeed)
{
	local Vector Delta;
	local FLOAT DeltaM;
	local FLOAT MaxStep ;
	local Vector DeltaN;

    Delta  = Target - Current;
	DeltaM = VSize(Delta);

	MaxStep = InterpSpeed * DeltaTime;

	if( DeltaM > MaxStep )
	{
		if( MaxStep > 0.f )
		{
			DeltaN = Delta / DeltaM;
			return Current + DeltaN * MaxStep;
		}
		else
		{
			return Current;
		}
	}

	return Target;
}

simulated function DrawHUD(Canvas Canvas)
{
    RenderDelta = Level.TimeSeconds - LastHUDRenderTime;
    LastHUDRenderTime = Level.TimeSeconds;

    if(PlayerOwner != none)
    {
        if(!bHideHUD)
        {
            Super.DrawHUD(Canvas);
            DrawStoryDebugInfo(Canvas);
        }
    }
}

simulated function RenderIntroMovie(Canvas C)
{
    if(PlayerOwner.GameReplicationInfo.bMatchHasBegun)
    {
    	if ( Intro_BinkMovie == none)
        {
            Intro_BinkMovie = new class'LobbyMenuAd';
            if (Intro_BinkMovie.MenuMovie == None)
            {
                Intro_BinkMovie.MenuMovie = new class'Movie';
                Intro_BinkMovie.MenuMovie.Callbacks = Intro_BinkMovie;
            }
        }
        else
        {
            if(Intro_BinkMovie.MenuMovie != none)
            {
                if(!bPlayedIntroMovie)
                {
                    bPlayedIntroMovie = true;
    			    Intro_BinkMovie.MenuMovie.Open("../Movies/Dummy_UI_Vid"$".bik");
                    Intro_BinkMovie.MenuMovie.Play(true);
                }

                bPlayingIntroMovie = Intro_BinkMovie.MenuMovie.IsPlaying() ;
                if(bPlayingIntroMovie)
                {
                    C.SetPos(0,0);
                    C.DrawColor = WhiteColor;
                    C.DrawTileScaled(Intro_BinkMovie.MenuMovie, C.SizeX/Intro_BinkMovie.MenuMovie.GetWidth(),C.SizeY/Intro_BinkMovie.MenuMovie.GetHeight());
                }
            }
        }
    }
}


simulated function DrawStoryDebugInfo(Canvas Canvas)
{
    local float XPos,YPos;
    local float XL,YL;
    local int i;
    local KFStoryGameInfo StoryGI;
    local string NewObjName;
    local KF_StoryObjective Obj;
    local string ObjName;

    if(KFPlayerController_Story(PlayerOwner) != none &&
	KFPlayerController_Story(PlayerOwner).bShowObjectiveDebug)
	{
        Canvas.Font = GetConsoleFont(Canvas);
        Canvas.Style = ERenderStyle.STY_Alpha;
        Canvas.DrawColor = ConsoleColor;

        Canvas.SetPos(XPos,YPos);
        Canvas.DrawText("==================== OBJECTIVES ===========================");

        StoryGI = KFStoryGameInfo(Level.Game);
        if(StoryGI == none)
        {
            return;
        }

        YPos = Canvas.ClipY * 0.5;

        for(i = 0 ; i < StoryGi.Allobjectives.length ; i ++)
        {
            Obj = StoryGI.AllObjectives[i];
            if(Obj.bCompleted)
            {
                Canvas.DrawColor = GreenColor;
            }
            else if (Obj.bFailed)
            {
                Canvas.DrawColor = RedColor;
            }
            else
            {
                Canvas.DrawColor = WhiteColor;
            }

            Canvas.Font = GetConsoleFont(Canvas);

            ObjName = ""$Obj.ObjectiveName ;
            if(Obj == StoryGI.CurrentObjective)
            {
                ObjName = "((("$Obj.ObjectiveName$")))" ;
            }

            NewObjName = "["$i+1$"]"@ObjName@"-->";
            Canvas.StrLen(NewObjName,XL,YL);
            XPos += XL ;

            Canvas.SetPos(XPos,YPos);
            Canvas.DrawText(NewObjName);
        }
    }
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if(PlayerOwner != none && !bHideHUD)
	{
		UpdateObjFadeVals(deltaTime);
	}

	/*
	copied from parent class ..
	This seems like an unnnecessarily redundant way to cache the GRI ...
	*/

	if ( SGRI == None &&
    PlayerOwner.GameReplicationInfo != none)
	{
		SGRI = KF_StoryGRI(PlayerOwner.GameReplicationInfo);
		if(SGRI != none)
		{
            HUDStyleManager = SGRI.GetHUDStyleManager();
        }
    }

}

simulated function UpdateObjFadeVals(float DeltaTime)
{
	if(RenderObj == none)
	{
	   return;
	}

	/* Switch to the next Objective .. fade the current one out, first */
	if(RenderObj != CurrentObj &&
	RenderObjOpacity == 1.f &&
	!bFadingIn && !bPendingFadeout)
	{
	    PendingFadeOutStartTime = Level.TimeSeconds;
	    bPendingFadeOut = true;
	}

	if(bPendingFadeOut && Level.TimeSeconds - PendingFadeOutStartTime >= ObjFadeOutDelay)
	{
        bPendingFadeOut = false;
        bFadingOut = true;
	}

	/* We're rendering the right objective, it just needs to fade in */
	if(RenderObjOpacity < 1.f &&
	!bFadingOut && CurrentObj != none)
	{
		bFadingIn = true;
	}

	if(bFadingIn)
	{
		RenderObjOpacity = FClamp(RenderObjOpacity + (DeltaTime / ObjFadeInTime),0.f,1.f) ;
		if(RenderObjOpacity == 1.f || bSkipTransitions)
		{
			ObjFadeInComplete();
		}
	}
	if(bFadingOut)
	{
		RenderObjOpacity = FClamp(RenderObjOpacity - (DeltaTime / ObjFadeOutTime),0.f,1.f) ;
		if(RenderObjOpacity < 0.1 || bSkipTransitions)
		{
			ObjFadeOutComplete();
		}
	}
}

simulated function ObjFadeOutComplete()
{
	local int CurrentObjIdx,LastRenderidx;

	LastRenderidx = ObjRenderIdx;

	bFadingOut = false;
	RenderObjOpacity = 0.f;
    RemoveHUDObjective(HUDObjs[LastRenderidx]);

	if(CurrentObj != none &&
    FindHUDObjective(CurrentObj.name,CurrentObjIdx) != none)
	{
		ObjRenderIdx = CurrentObjIdx;
	}
}

simulated function ObjFadeInComplete()
{
//	log("+++++++++++++++++++ Fade In complete for  : "@RenderObj.ObjectiveName);
	bFadingIn = false;
	RenderObjOpacity = 1.f;
	LastNewRenderObjTime = Level.TimeSeconds;
}

/* Returns 0 if it's a failure condition, or 1 if it's a success condition */
simulated function bool FindConditionTypeFor(SConditionHint TestCondition, out byte ConditionType)
{
    local KF_StoryObjective OwningObj;

    OwningObj = FindObjectiveByName(TestCondition.ObjOwner);

    if(OwningObj != none)
    {
        ConditionType = OwningObj.GetNamedConditionType(TestCondition.ConditionName);
    }

    return ConditionType < 2;
}


simulated function ResolveObjectiveInfo()
{
	local KF_StoryObjective	NewObj;
	local int NewIndex;

    if(SGRI == none)
    {
        return;
    }

	NewObj = SGRI.GetCurrentObjective() ;
	if(CurrentObj != NewObj)
	{
		if(NewObj != none &&
        FindHUDObjective(NewObj.name,NewIndex) == none &&
        (SGRI.GetDebugTargetObjective() == none || SGRI.GetDebugTargetObjective() ==
        NewObj))
		{
			AddHUDObjective(NewObj);
			log("Add Hud Objective : "@NewObj, 'Story_Debug');
		}

		CurrentObj = NewObj;
	}


	if(HUDObjs.length > 0)
	{
		RenderObj = HUDObjs[Min(ObjRenderIdx,HUDObjs.length-1)] ;
//		log("======== Current RenderObj :::: "@RenderObj.ObjectiveName@" ========== "@RenderObjOpacity@"======== Target RenderObj :::: "@CurrentObj.ObjectiveName);
	}
}

simulated function KF_StoryObjective  FindObjectiveByName(name TestObj, optional out int i)
{
	for(i = 0 ; i < AllObjs.length ; i ++)
	{
		if(AllObjs[i].name == TestObj)
		{
			return AllObjs[i];
		}
	}
}

simulated function KF_StoryObjective  FindHUDObjective(name TestObj, optional out int i)
{
	for(i = 0 ; i < HUDObjs.length ; i ++)
	{
		if(HUDObjs[i].name == TestObj)
		{
			return HUDObjs[i];
		}
	}
}

simulated function AddHUDObjective(KF_StoryObjective NewObj)
{
    if(NewObj != none && NewObj.bShowOnHUD)
    {
//        log("** ADD HUD OBJ :: "@NewObj.ObjectiveName);

        /* Apply any pending style preset before adding it to the HUD */
        ApplyObjectiveStylePresets(NewObj);

 	    HUDObjs.insert(HUDObjs.length,1);
     	HUDObjs[HUDObjs.length - 1] = NewObj;
    }
}

simulated function ApplyObjectiveStylePresets(KF_StoryObjective NewObj)
{
    if(HUDStylemanager != none && HUDStylemanager.StylePreset.Objectives.bOverride)
    {
        NewObj.HUD_Background                = HUDStylemanager.StylePreset.Objectives.BackGround;
        NewObj.HUD_Header.Header_Color       = HUDStylemanager.StylePreset.Objectives.Header.Header_Color;
        NewObj.HUD_Header.Header_Scale       = HUDStylemanager.StylePreset.Objectives.Header.Header_Scale;
        NewObj.HUD_ScreenPosition            = HUDStyleManager.StylePreset.Objectives.Position;
    }
}

simulated function RemoveHUDObjective(KF_StoryObjective RemoveObj)
{
	local int RemovalIndex;
	local KF_StoryObjective ObjToRemove;
    local int i;

    log("Remove HUD Obj : "@RemoveObj, 'Story_Debug');

	if(RemoveObj !=none)
	{
//        log("** REMOVE HUD OBJ :: "@RemoveObj.ObjectiveName);

        ObjToRemove = FindHUDObjective(RemoveObj.name,RemovalIndex);
        HUDObjs.Remove(RemovalIndex,1);

        /* Remove any associated condition info as well */
        for(i = 0 ; i < ConditionHints.length ; i ++)
        {
            if(ConditionHints[i].ObjOwner == RemoveObj.Name)
            {
                RemoveConditionHint(ConditionHints[i].ConditionName);
            }
        }
    }
}


simulated function DrawObjWorldIcons(Canvas C)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist;
	local color OldDrawColor;
	local string HintString;
	local float XL,YL;
	local int i;
	local float IconX,IconY;
	local float LargestX,LargestY;
	local float OpacityModifier;
	local float DistX,DistY;
	local string DistString;
	local float FarthestDistSq,DistSq;
	local float FarthestDist;
	local float DistanceScale;
	local int FontScale;
	local float IconSize;

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu

	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' )
	{
		return;
	}

	OldDrawColor = C.DrawColor;
    C.Style = ERenderStyle.STY_Alpha;
	C.GetCameraLocation(CameraLocation, CameraRotation);
	CamDir  = vector(CameraRotation);

	/* Establish distance scaling values for the icons before drawing */

    for(i = 0 ; i < ConditionHints.length ; i ++)
    {
        if(!ShouldRenderCondition(ConditionHints[i],"World"))
        {
            continue;
        }

        DistSq = VSizeSquared(ConditionHints[i].ConditionLoc.Location - PlayerOwner.CalcViewLocation) ;
        if(DistSq > FarthestDistSq)
        {
            FarthestDistSq = DistSq;
        }
    }
    i=0;

    FarthestDist = Sqrt(FarthestDistSq) ;

	for(i = 0 ; i < ConditionHints.length ; i ++)
	{
	   if(!ShouldRenderCondition(ConditionHints[i],"World"))
	   {
	       continue;
	   }

        TargetLocation = Conditionhints[i].ConditionLoc.Location;
	    Dist = VSize(TargetLocation - CameraLocation);

     	/* Check Distance Threshold / behind camera cut off   */
	    if ( (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	    {
            continue;
        }

        /* Target is located behind camera
	    HBScreenPos = C.WorldToScreen(TargetLocation);

	    if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	    {
		    HBScreenPos = C.WorldToScreen(TargetLocation);

		    if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.ClipX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.ClipY)
		    {
                return;

            }
        }     */


	    C.DrawColor = WhiteColor;
        HBScreenPos = C.WorldToScreen(TargetLocation);
        DistanceScale = 1.f;//FClamp(1.f - (Square(Dist) / FarthestDistSq) , 0.4f,1.f);
        if(DistanceScale <= 0.9)
        {
            FontScale = 1;
        }
        else if(DistanceScale <= 0.75)
        {
            FontScale = 0;
        }
        else if(DistanceScale <= 0.5)
        {
            FontScale = -1;
        }
    	C.Font = LoadFont(ResolveFontResolution(C,FontScale));


	    HintString = ConditionHints[i].WorldHint;
	    if ( HintString != "" )
	    {
		   //  HintString = HintString @ "(" @ (Round(VSize(TargetLocation  - C.ViewPort.Actor.Pawn.Location)/50.0)) @ "m )";
		     C.StrLen(HintString, XL, YL);
        }

        OpacityModifier = FClamp(1.f - ((VSize(ConditionHints[i].ConditionLoc.Location - PlayerOwner.CalcViewLocation) - 1500.f) / 1500.f),0.6f,1.f) ;
        C.DrawColor = ConditionHints[i].World_Clr;
        C.DrawColor.A = KFHUDAlpha * OpacityModifier;

        if(ConditionHints[i].WorldTex != none)
        {
            IconX = ConditionHints[i].WorldTex.MaterialUSize() * DistanceScale * ConditionHints[i].World_Texture_Scale * (C.SizeX/1920.f);
            IconY = IconX ;
            IconSize =  (IconX / ConditionHints[i].WorldTex.MaterialUSize()) ;
        }

        LargestX = FMax(XL,IconX);
        LargestY = FMax(YL,IconY);

        /* Clamp icons to the edges of the screeen */

//        HBScreenPos.X = FClamp(HBScreenPos.X,LargestX,C.ClipX - LargestX);
//        HBScreenPos.Y = FClamp(HBScreenPos.Y,LargestY,C.ClipY - LargestY);

        if(ConditionHints[i].WorldTex != none)
        {
            C.SetPos(HBScreenPos.X - (0.5*IconX), HBScreenPos.Y - (IconY) - 16.f);
            C.DrawTileScaled(ConditionHints[i].WorldTex, IconSize ,(IconY/ ConditionHints[i].WorldTex.MaterialVSize()));
        }

        if ( HintString != "" )
	    {
		    if ( XL > 0.125 * C.ClipY )
		    {
			 //    C.Font = GetFontSizeIndex(C, -2 );

                C.StrLen(HintString, XL, YL);
		    }

            C.SetPos(HBScreenPos.X - 0.5*XL , HBScreenPos.Y - YL/2 );
	       	C.DrawTextClipped(HintString);
        }


        DistString = int(Dist / 50)$"m" ;
        C.StrLen(DistString,DistX,DistY);
		C.SetPos(HBScreenPos.X - (0.5* IconSize) - DistX/2 , HBScreenPos.Y + YL/2);
		C.DrawTextClipped(DistString);
	 }

}


simulated function DrawObjectiveInfo(Canvas C)
{
	if(!bShowObjectives )
	{
	   return;
	}

	ResolveObjectiveInfo();

	if(RenderObj != none)
	{
	   DrawObjWorldIcons(C);
	   DrawObjectiveHints(C, RenderObj,RenderObjOpacity);
    }
}


simulated function bool  FindExistingCondition(name ConditionName, out Int Index)
{
    local int i;

    for(i = 0 ; i < ConditionHints.length ; i ++)
    {
      if(ConditionHints[i].ConditionName == ConditionName)
      {
          Index = i;
          return true;
      }
    }

    return false;
}

function  KF_ObjectiveCondition  FindConditionByName(name ConditionName)
{
    local KF_ObjectiveCondition Condition;

    foreach AllObjects(class 'KF_ObjectiveCondition' , Condition)
    {
        if(Condition.name == ConditionName)
        {
            return Condition;
        }
    }
}

simulated function UpdateConditionHint(
name UpdatedCondition,
name NewOwner,
float NewProgressPct,
Actor NewLocActor,
string NewDataString,
bool NewComplete,
name PendingLocActorTag)
{
    local int Index;
    local KF_ObjectiveCondition ConditionObject;

    ConditionObject = FindConditionByName(UpdatedCondition);
    if(ConditionObject == none)
    {
        log("Warning - Could not find Object Reference for condition of name : "@UpdatedCondition,'Story_Debug');
        return;
    }

    if(FindExistingCondition(UpdatedCondition,Index))
    {
        if(NewProgressPct != ConditionHints[Index].ProgressPct)
        {
            ConditionHints[Index].LastProgressUpdateTime = Level.TimeSeconds;
            ConditionHints[Index].LastProgressVal        = ConditionHints[Index].ProgressPct;
        }

        ConditionHints[index].ObjOwner     = NewOwner;
        ConditionHints[Index].DataString   = NewDataString;
        ConditionHints[Index].ProgressPct  = NewProgressPct;
        ConditionHints[Index].bComplete    = int (NewComplete);
        ConditionHints[Index].ConditionLoc = NewLocActor ;
        ConditionHints[Index].PendingLocActorTag = PendingLocActorTag;
    }
    else
    {
        AddNewConditionHint(ConditionObject,
        NewOwner,
        NewProgressPct,
        NewLocActor,
        NewDataString,
        NewComplete,
		PendingLocActorTag);
    }
}


simulated function AddNewConditionHint(
KF_ObjectiveCondition NewCondition,
name NewOwner,
float NewProgressPct,
Actor NewLocActor,
string NewDataString,
bool bComplete,
name PendingLocActorTag)
{
    ConditionHints.length                                               = ConditionHints.length + 1;
    ConditionHints[ConditionHints.length - 1].ConditionName             = NewCondition.name;
    ConditionHints[ConditionHints.length - 1].ObjOwner                  = NewOwner;
    ConditionHints[ConditionHints.length - 1].ConditionLoc              = NewLocActor;
    ConditionHints[ConditionHints.length - 1].World_Texture_Scale       = NewCondition.HUD_World.World_Texture_Scale;
    ConditionHints[ConditionHints.length - 1].DataString                = NewDataString;
    ConditionHints[ConditionHints.length - 1].WorldHint                 = NewCondition.HUD_World.World_Hint;
    ConditionHints[ConditionHints.length - 1].bHideWorld                = NewCondition.HUD_World.bHide;
    ConditionHints[ConditionHints.length - 1].HintStyle                 = NewCondition.HUD_Screen.Screen_ProgressStyle;
    ConditionHints[ConditionHints.length - 1].DisplayStyle              = NewCondition.HUD_Screen.Screen_CountStyle;
    ConditionHints[ConditionHints.length - 1].bShowCheckBox             = NewCondition.HUD_Screen.bShowCheckBox;
    ConditionHints[ConditionHints.length - 1].bIgnoreWorldHidden        = NewCondition.HUD_World.bIgnoreWorldLocHidden;
    ConditionHints[ConditionHints.length - 1].bComplete                 = int(bComplete);
    ConditionHints[ConditionHints.length - 1].PendingLocActorTag 		= PendingLocActorTag;

    FindConditionTypeFor(ConditionHints[ConditionHints.length -1],ConditionHints[ConditionHints.length -1].ConditionType);

    /* Style Settings */
    if(!ApplyConditionStylePresets(Conditionhints.length - 1))
    {
        Conditionhints[Conditionhints.length - 1].World_Clr                 = NewCondition.HUD_World.World_Clr;
        Conditionhints[Conditionhints.length - 1].ProgressBar_Clr           = NewCondition.HUD_Screen.Screen_Clr;
        ConditionHints[ConditionHints.length - 1].WorldTex                  = NewCondition.HUD_World.World_Texture;
        ConditionHints[ConditionHints.length - 1].Material_ProgressBarBG    = NewCondition.HUD_Screen.Screen_ProgressBarBG;
        ConditionHints[ConditionHints.length - 1].Material_ProgressBarFill  = NewCondition.HUD_Screen.Screen_ProgressBarFill;
        ConditionHints[ConditionHints.length - 1].FontScale                 = NewCondition.HUD_Screen.FontScale;
    }
}


simulated function bool ApplyConditionStylePresets(int Index)
{
    if(HUDStylemanager == none ||
    !HUDStylemanager.StylePreset.Objectives.bOverride)
    {
        return false;
    }

    ConditionHints[Index].World_Clr                 = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_World.World_Clr;
    Conditionhints[Index].ProgressBar_Clr           = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_Screen.Screen_Clr;
    ConditionHints[Index].WorldTex                  = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_World.World_Texture;
    ConditionHints[Index].Material_ProgressBarBG    = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_Screen.Screen_ProgressBarBG;
    ConditionHints[Index].Material_ProgressBarFill  = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_Screen.Screen_ProgressBarFill;
    ConditionHints[Index].FontScale                 = HUDStyleManager.StylePreset.Objectives.Conditions.Style_ObjCondition_Screen.FontScale;

    return true;
}



simulated function RemoveConditionHint(name HintToRemove)
{
    local int Index;

    if(FindExistingCondition(HintToRemove,Index))
    {
        ConditionHints.Remove(Index,1);
    }
}

simulated function float ResolveFontResolution(Canvas C, optional int FontScale)
{
    local float FontSize;
    local float SizeModifier;

    Sizemodifier = 1.f;
    if(FontScale != 1)
    {
        switch(FontScale)
        {
            case -1:  SizeModifier = 3.f;  break;     // tiny
            case 0 :  SizeModifier = 2.f;  break;     // small
            case 2 :  SizeModifier = -1.f; break;     // large
            case 3 :  SizeModifier = -2.f; break;     // very large.
        }
    }

    if ( C.ClipX <= 640 )
	 FontSize = 7;
	else if ( C.ClipX <= 800 )
	 FontSize = 6;
	else if ( C.ClipX <= 1024 )
	 FontSize = 5;
	else if ( C.ClipX <= 1280 )
	 FontSize = 4;
	else
	 FontSize = 3;

	FontSize += SizeModifier;
    return FontSize;
}

exec simulated function SetObjX(float X)
{
    if(CurrentObj != none)
    {
        CurrentObj.HUD_ScreenPosition.Horizontal = X ;
    }
}

exec simulated function SetObjY(float Y)
{
    if(CurrentObj != none)
    {
        CurrentObj.HUD_ScreenPosition.Vertical = Y ;
    }
}

/* Determines which elements of the ConditionHints array should be rendered at any given time
primarily used to ensure that hidden conditions, or those belonging to an objective other than the
one on the HUD are not drawn. */

simulated function bool     ShouldRenderCondition(SConditionHint  TestCondition, string Type)
{
    switch(Type)
    {
        case "World" :

        if(TestCondition.bHideWorld ||
           TestCondition.bComplete == 1 ||
           (TestCondition.WorldHint == "" && TestCondition.WorldTex == none) ||
           TestCondition.Conditionloc == none ||
           TestCondition.ConditionLoc.Location == Vect(0,0,0) ||
           (TestCondition.ConditionLoc.bHidden && !TestCondition.bIgnoreWorldHidden) ||
           (KF_BreakerBoxNPC(TestCondition.ConditionLoc) != none &&
           !KF_BreakerBoxNPC(TestCondition.ConditionLoc).bActive) )
        {
            return false;
        }
        break;

        case "Screen" :

        if(TestCondition.HintStyle == 0)
        {
            return false;
        }
        break;
    }

    return TestCondition.ObjOwner == RenderObj.name;
}


/* Renders Objective Hints on the Players HUD telling him what his objective is and where to find it */

simulated final function DrawObjectiveHints(Canvas C, KF_StoryObjective CurrentObj, float FadeValue)
{
	local float     SuccessWidth, SuccessHeight;
	local string	ObjectiveHint;
	local float     PosX,PosY;
	local float     BGWidth,BGHeight;
	local float     ScalingValue;
	local int       i;
	local float     WidestX;
    local float     HeaderX,HeaderY;
    local float     DataX,DataY;
    local int       FontSize;
    local int       DataFontSize;
    local float     BarWidth;
    local float     WidestDataX;
    local int       NumScreenConditions;
    local float     HighlightWidth;
    local float     HighlightFadeVal;
    local float     SecondaryBarWidth;
    local float     HighlightFadeTime;
    local float     OpacityModifier;
    local float     WidestStringX;
    local float     BarHeightMultiplier;
    local string    HintString;
    local Material  BGTex;
    local float     HeaderScale;
    local Material  CheckboxMat;
    local float     CheckboxScale;
    local float     CheckBoxSize;
    local float     OldXPos;
    local float     BarBGWidth,StrikeThroughWidth;

    BarHeightMultiplier = 1.25f;
    HeaderScale = 0.5;
    CheckBoxScale = 1.5;

    if ( PlayerOwner != none && KFGRI != none && FadeValue > 0 && !bShowScoreboard)
    {
        if ( CurrentObj != none && ConditionHints.length > 0 )
	   	{
			/* Coordinates to start drawing at */

            PosX = C.SizeX * CurrentObj.HUD_ScreenPosition.Horizontal;  //(C.SizeX / 64.f) ;
			PosY = C.SizeY * CurrentObj.HUD_ScreenPosition.Vertical;  //0  ;

		    /*================ SIZING PASS ====================================================================
		    ==================================================================================================*/

            ScalingValue = CurrentObj.HUD_Background.Background_Scale ;
            FontSize = ResolveFontResolution(C,CurrentObj.HUD_Header.Header_Scale);
    	    DataFontSize = FontSize;

		    /* Size up the Objective Header text */

            /* Header uses a massive font, gotta scale things */

		    C.FontScaleX      = HeaderScale;
		    C.FontScaleY      = HeaderScale;
		    C.Font            = GetWaitingFontSizeIndex(C,CurrentObj.HUD_Header.Header_Scale);//LoadFont(FontSize);
		    C.StrLen(CurrentObj.HUD_Header.Header_Text,HeaderX,HeaderY);
		    WidestX           = FMax(WidestX,HeaderX);
		    WidestStringX     = WidestX;

            HeaderY *= BarHeightMultiplier;

            C.FontScaleX = 1.f;
		    C.FontScaleY = 1.f;

		    /* Now Size up the conditions */

            for(i = 0 ; i < ConditionHints.Length ; i ++)
            {
                if(!ShouldRenderCondition(ConditionHints[i],"Screen"))
	            {
	                ConditionHints[i].ProgBarheight = 0 ;
	                continue;
	            }

                /* Check that there's actually something to display */
                if(ConditionHints[i].HintStyle > 0 && ConditionHints[i].DataString != "")
                {
	               NumScreenConditions ++ ;
                }

                FontSize      = ResolveFontResolution(C,ConditionHints[i].FontScale);
			    DataFontSize  = FontSize;
			    C.Font        = LoadFont(FontSize);

                ObjectiveHint    = ConditionHints[i].DataString ;
		        C.StrLen(ObjectiveHint, SuccessWidth, SuccessHeight);

		        SuccessWidth  *= ScalingValue;
		        SuccessHeight *= ScalingValue;

                CheckBoxSize = (FMax(SuccessHeight,DataY)* BarHeightMultiplier) * CheckboxScale;
                if(Conditionhints[i].bShowCheckBox)
                {
                    SuccessWidth += CheckBoxSize;
                }

		        ConditionHints[i].HintWidth = SuccessWidth;
                ConditionHints[i].HintHeight = SuccessHeight;

		        WidestX       = FMax(WidestX,SuccessWidth);
		        WidestStringX = WidestX;

                // retrieve scaling for data string

			    C.StrLen(ConditionHints[i].DataString,DataX,DataY);
			    DataX *= ScalingValue;
			    DataY *= ScalingValue;

                /* Since the Data string size affects the background scale we never want it to shrink */

 			    if(DataX > ConditionHints[i].WidestDataX)
			    {
                    ConditionHints[i].WidestDataX = DataX;
			    }
			    WidestDataX = FMax(DataX,WidestDataX);
                ConditionHints[i].ProgBarHeight = FMax(SuccessHeight,DataY)* BarHeightMultiplier ;

            }

		    WidestX += C.ClipX / 64.f;

            if(NumScreenConditions == 0 && CurrentObj.HUD_Header.Header_Text == "")
            {
                return;
            }

            if(CurrentObj.HUD_Background.Background_AspectRatio < 2)
            {
                BGHeight += HeaderY;
            }

            for(i = 0 ; i < ConditionHints.length ; i ++)
            {
                if(CurrentObj.HUD_Background.Background_AspectRatio < 2)
                {
                    BGHeight += ConditionHints[i].ProgBarheight ;
                }
            }

            BGHeight += CurrentObj.HUD_Background.Background_Padding ;
            if(CurrentObj.HUD_Background.Background_AspectRatio < 2)
            {
                BGWidth  =  WidestX + (CurrentObj.HUD_Background.Background_Padding );
            }
            else
            {
                BGWidth += CurrentObj.HUD_Background.Background_Padding ;
            }

            if(CurrentObj.HUD_BackGround.Background_Texture != none)
            {
		        if(CurrentObj.HUD_Background.Background_AspectRatio == Aspect_FromTexture)
                {
                    BGWidth  =  CurrentObj.HUD_Background.Background_Texture.MaterialUSize() ;
                    BGHeight =  CurrentObj.HUD_Background.Background_Texture.MaterialVSize() ;
                }
            }

            BGHeight *= ScalingValue  ;
            BGWidth *= ScalingValue  ;

            // clamp - make sure it's not travelling off screen
            PosX = FClamp(PosX-BGWidth/2,0,C.SizeX - BGWidth);
            PosY = FClamp(PosY,0,C.SizeY - BGHeight);

            /*================ DRAWING PASS ====================================================================
            ==================================================================================================*/

            /* Draw Background first */

            OpacityModifier = 1.f;

            C.Style = ERenderStyle.STY_Alpha;
            C.DrawColor = WhiteColor;
            C.DrawColor.A = (KFHUDAlpha * FadeValue) * OpacityModifier ;

            if(!bCollapseConditions)
            {
                BGTex = CurrentObj.HUD_Background.Background_Texture;
            }
            else
            {
                BGTex = CurrentObj.HUD_Background.Background_Texture_Collapsed ;
            }

            if(BGTex != none)
            {
                C.SetPos(PosX ,PosY);
                if(CurrentObj.HUD_Background.Background_AspectRatio > 0)
                {
                    C.DrawTileScaled(BGTex, BGWidth/BGTex.MaterialUSize() ,BGHeight / BGTex.MaterialVSize());
                }
                else
                {
                    C.DrawTileStretched(BGTex, BGWidth ,BGHeight);
                }
            }

            if(bCollapseConditions)
            {
                return;
            }

            /* Try to center justify everything */

            PosX = FClamp(PosX+CurrentObj.HUD_Background.BackGround_Offset.Horizontal,0,C.SizeX - BGWidth);
            PosY += CurrentObj.HUD_BackGround.BackGround_Offset.Vertical ;

            /* Now draw objective header title */

            C.FontScaleX = HeaderScale;
		    C.FontScaleY = HeaderScale;
            C.Font = GetWaitingFontSizeIndex(C,CurrentObj.HUD_Header.Header_Scale);//
            C.DrawColor = CurrentObj.HUD_Header.Header_Color;
            C.DrawColor.A = (KFHUDAlpha * FadeValue) * OpacityModifier ;
            C.SetPos(PosX - (HeaderX * 0.5) + (0.5*BGWidth),PosY );
            C.DrawText(CurrentObj.HUD_Header.Header_Text,true);
            C.FontScaleX = 1.f;
		    C.FontScaleY = 1.f;


            /* Shift everything down so it fits under the header */
            PosY += HeaderY * 1.1;

            /* Next draw the conditions - starting with the backplates and ending with the strings */

            for(i = 0 ; i < ConditionHints.length ; i ++)
            {
                if(!ShouldRenderCondition(ConditionHints[i],"Screen"))
                {
                    continue;
                }

                OpacityModifier = 1.f ;

                /* Shift it to the right abit if we're rendering a Checkbox */
                OldXPos = PosX;
                if(Conditionhints[i].bShowCheckBox)
                {
                    PosX += Conditionhints[i].ProgBarheight * CheckboxScale;
                }

                FontSize           = ResolveFontResolution(C,ConditionHints[i].FontScale);
                C.Font             = LoadFont(FontSize);

                /* Draw progreess bar & backdrop */

                C.StrLen(ConditionHints[i].DataString,SuccessWidth,SuccessHeight);
		        SuccessWidth  *= ScalingValue;
		        SuccessHeight *= ScalingValue;

                if((ConditionHints[i].HintStyle == 1 ||
                ConditionHints[i].HintStyle >= 3) &&
                ConditionHints[i].Material_ProgressBarBG != none)
                {
                    C.DrawColor = ConditionHints[i].ProgressBar_Clr ;
                    StrikeThroughWidth = WidestX;
                    BarBGWidth = WidestX;

                    if(Conditionhints[i].bShowCheckBox)
                    {
                        CheckBoxSize = ConditionHints[i].ProgBarheight * CheckboxScale;
                        BarBGWidth -= CheckboxSize;
                        StrikeThroughWidth -= CheckBoxSize;
                    }

                    if(ConditionHints[i].bComplete == 1 && ConditionHints[i].bShowCheckBox )
			        {
                        OpacityModifier = 0.5f ;
				        C.DrawColor.A = (KFHUDAlpha * FadeValue) * OpacityModifier  ;
				        C.SetPos(PosX + (BGWidth-WidestX)/2 , PosY);
				        C.DrawTileStretched(Texture'KFStoryGame_Tex.HUD.Objective_Strikethrough', StrikeThroughWidth,ConditionHints[i].ProgbarHeight );
                    }

		            C.DrawColor.A = ((ConditionHints[i].ProgressBar_Clr.A * FadeValue) * (KFHUDAlpha/255.f)) * OpacityModifier ;
				    C.SetPos(PosX + (BGWidth-WidestX)/2, PosY );
		            C.DrawTileStretched(ConditionHints[i].Material_ProgressBarBG, BarBGWidth,ConditionHints[i].ProgBarheight );
		        }

                /* Progess Bar Fill Material */

                if((ConditionHints[i].HintStyle == 1 ||
                ConditionHints[i].HintStyle >= 3) &&
                ConditionHints[i].Material_ProgressBarFill != none)
                {
                    if(ConditionHints[i].DisplayStyle == 0)
                    {
                        BarWidth = WidestX * ConditionHints[i].ProgressPct ;
		            }
                    else
		            {
                        BarWidth = WidestX * (1.f-ConditionHints[i].ProgressPct) ;
                    }

                    if(Conditionhints[i].bShowCheckBox)
                    {
                        CheckBoxSize = ConditionHints[i].ProgBarheight * CheckboxScale;
                        BarWidth = FMax(BarWidth - CheckBoxSize,0.f);
                    }

                    C.DrawColor.A = ((ConditionHints[i].ProgressBar_Clr.A * FadeValue) * (KFHUDAlpha/255.f)) * OpacityModifier ;
                    C.SetPos(PosX + (BGWidth-WidestX)/2, PosY );
		            C.DrawTileStretched(ConditionHints[i].Material_ProgressBarFill, BarWidth,ConditionHints[i].ProgBarheight);

    		        /* Fill Highlight */

                    if(ConditionHints[i].DisplayStyle == 1)
                    {
                        SecondaryBarWidth = FMax(1.f-(WidestX * (ConditionHints[i].ProgressPct - ConditionHints[i].LastProgressVal)),0.f) ;
                        HighlightFadeTime = FClamp((ConditionHints[i].ProgressPct - ConditionHints[i].LastProgressVal) * 3.f,0.5f,2.f);
                        HighlightFadeVal = FClamp( 1.f - ((Level.TimeSeconds - ConditionHints[i].LastProgressUpdateTime ) / HighlightFadeTime), 0.f,1.f);

		                C.DrawColor.A    = (255 * (KFHudAlpha/255.f) * FadeValue * HighlightFadeVal) * OpacityModifier ;

                        C.SetPos(PosX + BarWidth - (SecondaryBarWidth), PosY);
		                C.DrawTileStretched(ConditionHints[i].Material_ProgressBarFill, SecondaryBarWidth,ConditionHints[i].ProgBarHeight);


                        C.DrawColor      = WhiteColor;
		                C.DrawColor.A    = (255 * (KFHudAlpha/255.f) * FadeValue * HighlightFadeVal) * OpacityModifier ;
                        HighlightWidth   = BarWidth * 0.1;
                        C.SetPos(PosX - (HighlightWidth) + (BGWidth-WidestX)/2 + BarWidth , PosY);
		                C.DrawTileStretched(Texture 'KFStoryGame_Tex.HUD.ProgressBar_Higlight', HighlightWidth,ConditionHints[i].ProgBarheight);

                        C.DrawColor      = ConditionHints[i].ProgressBar_Clr ;
		                C.DrawColor.A    = ((ConditionHints[i].ProgressBar_Clr.A * FadeValue) * (KFHUDAlpha/255.f)) * OpacityModifier ;
                    }
                }

                /* Finally, Draw the condition Hint strings & DataStrings.. */

                if(ConditionHints[i].HintStyle > 1 )
                {
                    /* Make sure the hint string isn't so large it overlaps the data string

                    while( ConditionHints[i].DataString != "" &&
                    PosX + (WidestX * 0.05) + ConditionHints[i].HintWidth >= (ClampedX-(DataX/2)) &&
                    FontSize < arraycount(FontArrayFonts)-1)
                    {
                        FontSize ++ ;
                        C.Font = LoadFont(FontSize);
                        C.StrLen(ConditionHints[i].DataString,SuccessWidth,SuccessHeight);
                        SuccessWidth  *= ScalingValue;
                        SuccessHeight *= ScalingValue;
                        ConditionHints[i].HintWidth = SuccessWidth;
                    }   */

                    if(ConditionHints[i].DataString != "")
                    {
                        C.Font = LoadFont(FontSize);
                        HintString = ConditionHints[i].DataString;
                        C.DrawColor = ConditionHints[i].ProgressBar_Clr;
                        C.DrawColor.A = ((ConditionHints[i].ProgressBar_Clr.A * FadeValue) * (KFHUDAlpha/255.f)) * OpacityModifier ;
			            C.SetPos(PosX + BGWidth/2 - (ConditionHints[i].HintWidth/2), PosY + ConditionHints[i].HintHeight/4 );
			            C.DrawText(HintString,true);
                    }

                    if(ConditionHints[i].bShowCheckBox)
                    {
                        C.SetPos(PosX + (BGWidth-WidestX)/2 - (ConditionHints[i].ProgBarheight * 1.1) , PosY );
                        C.DrawColor.A = ((ConditionHints[i].ProgressBar_Clr.A * FadeValue) * (KFHUDAlpha/255.f)) ;

                        /* Show a Tick next to success conditions that were completed , or failure conditions that were *not* completed
                        at the time the objective was successfully finished */

                        C.DrawTileScaled( Texture 'KFStoryGame_Tex.HUD.ObjInComplete_Ico', ConditionHints[i].ProgBarheight/64.f,ConditionHints[i].ProgBarHeight/64.f);

                        CheckBoxMat = GetCheckBoxMaterialFor(ConditionHints[i]);
                        if(CheckBoxMat != none)
                        {
                            C.SetPos(PosX + (BGWidth-WidestX)/2 - (ConditionHints[i].ProgBarheight * 1.1) , PosY - ((ConditionHints[i].ProgBarHeight*CheckBoxScale)/4) );
                            C.DrawTileScaled(CheckBoxMat, (ConditionHints[i].ProgBarheight*1.5)/64.f,(ConditionHints[i].ProgBarHeight*CheckboxScale)/64.f);
                        }
                    }
                }

                if(ConditionHints[i].HintStyle <= 3)
                {
                    PosY += ConditionHints[i].ProgBarheight * 1.25;
                }

                PosX = OldXPos;
            }
	    }
    }
}

simulated function Material  GetCheckBoxMaterialFor(SConditionHint  Testcondition)
{
    /* Failure conditions */
    if(TestCondition.ConditionType == 0)
    {
        if(Testcondition.bComplete == 1)
        {
            return Texture 'KFStoryGame_Tex.HUD.ObjFailed' ;
        }
        else
        {
            if(RenderObj.bCompleted)
            {
                return Texture 'KFStoryGame_Tex.HUD.ObjComplete_Ico';
            }
        }
    }
    else     // Success , optional
    {
        if(Testcondition.bComplete == 1)
        {
            return Texture 'KFStoryGame_Tex.HUD.ObjComplete_Ico' ;
        }
        else
        {
            if(RenderObj.bCompleted)
            {
                return Texture 'KFStoryGame_Tex.HUD.ObjFailed' ;
            }
        }
    }

    return none;
}

/* Dialogue rendering ====================================================================================
=========================================================================================================*/

simulated function ApplyDialogueStylePresets(KF_DialogueSpot NewDlg, int DlgIndex)
{
    if(HUDStylemanager != none && HUDStylemanager.StylePreset.Dialogue.bOverride)
    {
        NewDlg.Dialogues[DlgIndex].Display.Screen_BGMaterial    =  HUDStyleManager.StylePreset.Dialogue.Dialogue_Box.Screen_BGMaterial;
        NewDlg.Dialogues[DlgIndex].Display.Screen_Position      =  HUDStyleManager.StylePreset.Dialogue.Dialogue_Box.Screen_Position;
        NewDlg.Dialogues[DlgIndex].Display.Screen_Scaling       =  HUDStyleManager.StylePreset.Dialogue.Dialogue_Box.Screen_Scaling;
    }
}

/* adds a new dialogue entry to the cue -  Dialogue is rendered in order of addition */
simulated function AddDialogue(name DialogueActorName, int DlgIndex, float DisplayDuration)
{
    local int Index,ExistingIndex;
    local KF_DialogueSpot NewDlg;

    NewDlg = FindDialogueActor(DialogueActorName);
    if(NewDlg == none)
    {
        log("Warning - could not find Dialogue Actor of name : "@DialogueActorName@" Aborting HUD Render. ");
        return;
    }

    if(!FindExistingDialogue(NewDlg.Dialogues[DlgIndex].Display.Dialogue_text,ExistingIndex))
    {
        Index = Dialogues.length ;
        Dialogues.length = Index + 1;
        CurrentDlgIndex = Index;

        ApplyDialogueStylePresets(NewDlg,DlgIndex);

        Dialogues[Index].Message    = NewDlg.Dialogues[DlgIndex].Display.Dialogue_Text;
        Dialogues[Index].Speaker    = NewDlg.Dialogues[DlgIndex].Display.Dialogue_Header;
        Dialogues[Index].Portrait   = NewDlg.Dialogues[DlgIndex].Display.Portrait_Material;
        Dialogues[Index].Opacity    = KFHUDAlpha;
        Dialogues[Index].Duration   = DisplayDuration;
        Dialogues[Index].ScreenPos  = NewDlg.Dialogues[DlgIndex].Display.Screen_Position;
        Dialogues[Index].ScreenAlignment = NewDlg.Dialogues[DlgIndex].Display.ScreenAlignment;
        Dialogues[Index].ScreenScaleStyle = NewDlg.Dialogues[DlgIndex].Display.Screen_Scaling;
        Dialogues[Index].BackGroundMat = NewDlg.Dialogues[DlgIndex].Display.Screen_BGMaterial;

        Dialogues[Index].BinkPortrait                       = new class'LobbyMenuAd';
        Dialogues[Index].BinkPortrait.MenuMovie             = new class'Movie';
        Dialogues[Index].BinkPortrait.MenuMovie.Callbacks   = Dialogues[Index].BinkPortrait;
      	Dialogues[Index].BinkPortrait.MenuMovie.Open("../Movies/"$NewDlg.Dialogues[DlgIndex].Display.Portrait_BinkMovie$".bik");
        Dialogues[Index].BinkPortrait.MenuMovie.Play(true);
    }
    else
    {
        CurrentDlgIndex = ExistingIndex;
        Dialogues[ExistingIndex].Duration = DisplayDuration;
    }
}


/* Main drawing pump for Story mode Dialogue system */
simulated function DrawDialogue(Canvas C)
{
    local float HeaderX,HeaderY;
    local float BackgroundOffset;
    local int i;
    local AbsoluteCoordsInfo coords;
    local float DisplayTimeRemaining;
    local float XL,YL;
    local float OpacityVal;
    local float BGSizeX,BGSizeY;
    local float PortraitSizeX,PortraitSizeY;
    local float PortraitAspect;
    local Material DlgPortrait;
    local Material DlgBackGroundMaterial;

    if(CurrentDlgIndex >= Dialogues.length)
    {
        return;
    }

    DisplayTimeRemaining = Dialogues[CurrentDlgIndex].Duration - (Level.TimeSeconds - Dialogues[CurrentDlgIndex].FirstDisplayedTime) ;

    if(DisplayTimeRemaining <= 0)
    {
        Dialogues[CurrentDlgIndex].Opacity = Max(Dialogues[CurrentDlgIndex].Opacity - 2,0);
        if(Dialogues[CurrentDlgIndex].Opacity == 0)
        {
            // remove me from the cue and move on to the next!
            Dialogues.Remove(CurrentDlgIndex,1);
        }
    }

    if(CurrentDlgIndex >= Dialogues.length)
    {
        return;
    }

    OpacityVal = Dialogues[CurrentDlgIndex].Opacity ;
    if(OpacityVal > 0)
    {
        if(!Dialogues[CurrentDlgIndex].bFirstDisplay)
        {
            Dialogues[CurrentDlgIndex].bFirstDisplay = true;
            Dialogues[CurrentDlgIndex].FirstDisplayedTime = Level.TimeSeconds;
        }

        if(!Dialogues[CurrentDlgIndex].bWrapped)
        {
            CalculateDialogueWrappingData(C);
        }

        C.Font = GetFontSizeIndex(C,-2);
        C.StrLen(Dialogues[CurrentDlgIndex].Speaker,HeaderX,HeaderY);
		C.SetPos(0, 0);

		// Set proper rendering style
		C.Style = ERenderStyle.STY_Alpha;

		// Calculate background offset in relation to text
		backgroundOffset = DialogueBackground.PosY * C.ClipY;

		// Calculate absolute drawing coordinates (mostly for text widget)

		DialogueCoords.X = Dialogues[CurrentDlgIndex].ScreenPos.Horizontal;
		DialogueCoords.Y = Dialogues[CurrentDlgIndex].ScreenPos.Vertical;


		coords.PosX = DialogueCoords.X * C.ClipX;
		coords.PosY = DialogueCoords.Y * C.ClipY;
		coords.height = DialogueCoords.YL * C.ClipY;

		BGSizeY = coords.height + backgroundOffset * 2;

        DlgPortrait = Dialogues[CurrentDlgIndex].Portrait;
		if(DlgPortrait != none)
		{
		    PortraitAspect = float(DlgPortrait.MaterialUSize()) /  float(DlgPortrait.MaterialVsize())   ;
            // make sure the protrait is scaled to the background widget
            PortraitSizeY = FMin(DlgPortrait.MaterialVsize(),BGSizeY);
            PortraitSizeX = PortraitSizeY * 0.6;//PortraitSizeY * PortraitAspect;
		}

		coords.width = (DialogueCoords.XL * C.ClipX)  ;

		// Draw the background
        C.DrawColor = WhiteColor;
        C.DrawColor.A = OpacityVal * (255.f/KFHUDAlpha) ;

		BGSizeX = (coords.width + backgroundOffset * 2) ;

        coords.PosX -= PortraitSizeX/2;
        coords.PosY -= BGSizeY/2;

		/* Clamp drawing positions so the dialogue never goes offscreen */

		coords.PosX = FClamp(coords.PosX,FMax(coords.PosX,PortraitSizeX),C.ClipX - BGSizeX);
		coords.PosY = FClamp(coords.PosY,0,C.ClipY - BGSizeY);

		C.SetPos(coords.PosX , coords.PosY );

        DlgBackGroundMaterial = Dialogues[CurrentDlgIndex].BackGroundMat;
        if(DlgBackGroundMaterial == none)
        {
            DlgBackGroundMaterial = Texture'KillingFloorHUD.HUD.Hud_Box_128x64';
        }

        if(Dialogues[CurrentDlgIndex].ScreenScaleStyle == Stretched)
        {
            C.DrawTileStretched(DlgBackGroundMaterial, BGSizeX,BGSizeY);
        }
        else
        {
            C.DrawTileScaled(DlgBackGroundMaterial, BGSizeX/DlgBackGroundMaterial.MaterialUSize(),BGSizeY/DlgBackGroundMaterial.MaterialVSize());
        }

		// Draw title
		C.Font = GetFontSizeIndex(C,-2);
		DialogueTitleWidget.text = Dialogues[CurrentDlgIndex].Speaker ;
		DialogueTitleWidget.Tints[0].A = OpacityVal;
		DialogueTitleWidget.Tints[1].A = OpacityVal;
		DrawTextWidgetClipped(C, DialogueTitleWidget, coords, XL, YL);

		// Draw each line individually
		DialogueTextWidget.OffsetY = (YL * 1.5) + DialogueTitleWidget.OffsetY ;
//		C.Font = getSmallMenuFont(C);
		YL = 0;
		for (i = 0; i < WrappedDialogue.Length; i++)
		{
			DialogueTextWidget.text = WrappedDialogue[i];
		    DialogueTextWidget.Tints[0].A = OpacityVal;
		    DialogueTextWidget.Tints[1].A = OpacityVal;

			if (WrappedDialogue[i] != "")
				DrawTextWidgetClipped(C, DialogueTextWidget, coords, XL, YL);
			else
				YL /= 2;
			DialogueTextWidget.OffsetY += YL;
		}

	    //Draw Portraits . (Bink if available, or else just regular material)

        if(Dialogues[CurrentDlgIndex].BinkPortrait != none &&
        Dialogues[CurrentDlgIndex].BinkPortrait.MenuMovie != none &&
        Dialogues[CurrentDlgIndex].BinkPortrait.MenuMovie.IsPlaying())
        {
		    C.Style = ERenderStyle.STY_Normal;
            C.DrawColor = WhiteColor;
            C.DrawColor.A = OpacityVal * (255.f/KFHUDAlpha) ;
            C.SetPos(coords.PosX - PortraitSizeX, coords.PosY );
            C.DrawTileScaled(Dialogues[CurrentDlgIndex].BinkPortrait.MenuMovie, PortraitSizeX/Dialogues[CurrentDlgIndex].BinkPortrait.MenuMovie.GetWidth(),PortraitSizeY/Dialogues[CurrentDlgIndex].BinkPortrait.MenuMovie.GetHeight());
        }
        else
        {
            DlgPortrait = Dialogues[CurrentDlgIndex].Portrait;
            if(DlgPortrait != none)
            {
		        C.Style = ERenderStyle.STY_Alpha;
                C.DrawColor = WhiteColor;
                C.DrawColor.A = OpacityVal * (255.f/KFHUDAlpha) ;
                C.SetPos(coords.PosX - PortraitSizeX, coords.PosY );
                C.DrawTileScaled(DlgPortrait,PortraitSizeX / DlgPortrait.MaterialUSize(), PortraitSizeY / DlgPortrait.MaterialVSize());
            }
        }
    }
}


simulated function bool FindExistingDialogue(string text, optional out int Index)
{
    local int i;

    for(i = 0 ; i < Dialogues.length ; i ++)
    {
        if(Dialogues[i].Message == text)
        {
            Index = i;
            return true;
        }
    }

    return false;
}

// This function is used to calculate how the Dialogue data should
// be wrapped.
function CalculateDialogueWrappingData(Canvas Canvas)
{
	local float XL, YL, XL2, YL2;
	local float minWidth, wrapWidth, totalYL;
	local int i, count;

	// First calculate minimum message width (e.g. the width of the
	// title string)
	Canvas.Font = GetFontSizeIndex(Canvas,-2);
	Canvas.SetPos(0, 0);
	Canvas.TextSize(Dialogues[CurrentDlgIndex].Speaker, minWidth, totalYL);
	if (minWidth < 10.0)
		minWidth = 10.0;
	totalYL += totalYL / 2;

	// Calculate max width of text string (or perhaps we should just use full screen width?)
	Canvas.Font = getSmallMenuFont(Canvas);
	Canvas.TextSize(Dialogues[CurrentDlgIndex].Message, XL, YL);

	// Starting with full string width, progressively reduce width until the ratio of the height
	// to the width is smaller than HintDesiredAspectRatio
	wrapWidth = XL;
	for (count = 0; count < 25; count++) // max 25 iterations
	{
		// Wrap text
		WrappedDialogue.Length = 0;
		Canvas.WrapStringToArray(Dialogues[CurrentDlgIndex].Message, WrappedDialogue, wrapWidth, "|");

		// Calculate current width & height
		XL = 0; YL = 0;
		XL2 = 0; YL2 = 0;
		for (i = 0; i < WrappedDialogue.Length; i++)
		{
			if (WrappedDialogue[i] != "")
				Canvas.TextSize(WrappedDialogue[i], XL, YL);
			else
				YL /= 2;
			if (XL > XL2)
				XL2 = XL;
			YL2 += YL;
		}

		// Check if current width is too small
		if (XL2 < minWidth)
		{
			wrapWidth = minWidth;
			break;
		}

		// Calculate ratio
		if (YL2 < 1)
			YL = 1;
		else
			YL = XL2 / YL2;

		// Check if we should accept this wrap width
		if (YL < HintDesiredAspectRatio)
		{
			wrapWidth = XL2;
			break;
		}

		// Else, reduce currentWidth and try again.
		wrapWidth *= 0.80;
	}

	// Wrap text to array
	WrappedDialogue.Length = 0;
	Canvas.SetPos(0, 0);
	Canvas.WrapStringToArray(Dialogues[CurrentDlgIndex].Message, WrappedDialogue, wrapWidth, "|");

	// Calculate total width and height
	wrapWidth = minWidth;
	XL = 0; YL = 0;
	for (i = 0; i < WrappedDialogue.Length; i++)
	{
		Canvas.SetPos(0, 0);
		if (WrappedDialogue[i] != "")
			Canvas.TextSize(WrappedDialogue[i], XL, YL);
		else
			YL /= 2;
		if (XL > wrapWidth)
			wrapWidth = XL;
		totalYL += YL;
		//log("Wrapped line #" $ i $ ": '" $ WrappedDialogue[i] $"'");
	}

	// for safety
	if (wrapWidth < 10)
		wrapWidth = 10;
	if (totalYL < 10)
		totalYL = 10;

	// Calculate target relative coordinates
	DialogueCoords.XL = wrapWidth / Canvas.ClipX;
	DialogueCoords.YL = totalYL / Canvas.ClipY;
	DialogueCoords.X = default.DialogueCoords.X + DialogueCoords.XL * default.DialogueCoords.XL;
	DialogueCoords.Y = default.DialogueCoords.Y + DialogueCoords.YL * default.DialogueCoords.YL;

	Dialogues[CurrentDlgIndex].bWrapped = true;
}



/* Modified to allow story HUDs to render different end game screens */

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	local float Scalar;
	local Material VictoryMaterial,DefeatMaterial;

	C.DrawColor.A = 255;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	Scalar = FClamp(C.ClipY, 320, 1024);
	C.CurX = C.ClipX / 2 - Scalar / 2;
	C.CurY = C.ClipY / 2 - Scalar / 2;
	C.Style = ERenderStyle.STY_Alpha;

	Victorymaterial = SGRI.GetVictorySplashMaterial();
	DefeatMaterial  = SGRI.GetDefeatSplashMaterial();

	if ( bVictory )
	{
		MyColorMod.Material = VictoryMaterial;
	}
	else
	{
		MyColorMod.Material = DefeatMaterial;
	}

	if ( EndGameHUDTime >= 1 )
	{
		MyColorMod.Color.A = 255;
	}
	else
	{
		MyColorMod.Color.A = EndGameHUDTime * 255.f;
	}

	C.DrawTile(MyColorMod, Scalar, Scalar, 0, 0, 1024, 1024);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	local Class<LocalMessage> LocalMessageClass;

	if(MsgType == 'Msg_CashReward')
	{
	    LocalMessageClass = class'Msg_CashReward';
	    AddTextMessage(Msg, LocalMessageClass, PRI);
	}
	else
	{
        Super.Message(PRI,Msg,MsgType);
	}
}

defaultproperties
{
     ObjFadeOutTime=0.500000
     ObjFadeInTime=0.500000
     ObjFadeOutDelay=1.000000
     bShowObjectives=True
     DialogueBackground=(WidgetTexture=Texture'KF_InterfaceArt_tex.Menu.Med_border_SlightTransparent',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosY=0.020000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     DialogueTitleWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,OffsetX=15,OffsetY=15,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DialogueTextWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,OffsetX=15,OffsetY=45,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DialogueCoords=(X=0.500000,Y=0.600000,XL=-1.000000)
     StoryIconOffsetX=20
     StoryIconOffsetY=50
}
