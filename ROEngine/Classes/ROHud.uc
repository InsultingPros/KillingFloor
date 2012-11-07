//=============================================================================
// ROHud
//=============================================================================
// New HUD for Red Orchestra
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROHud extends HudBase;

//=============================================================================
// Execs
//=============================================================================

//#exec OBJ LOAD FILE=ROInterfaceArt.utx
//#exec OBJ LOAD FILE=..\textures\InterfaceArt2_tex.utx

//=============================================================================
// Variables
//=============================================================================

var	rotator				NorthDirection;

// Config
var globalconfig bool           bShowCompass;
var globalconfig bool           bShowMapUpdatedText;

// Text
var		localized	string		ReinforcementText;
var		localized	string		TimeRemainingText;
var		localized	string		IPText;
var		localized	string		TimeText;
var		localized	string		ViewingText;
var		localized	string		NoReinforcementsText;
var		localized	string		TeamMessagePrefix;
var		localized	string		ObjectivesText;
var		localized	string		PlayersNeededText;
var		localized	string		SpectateInstructionText1;
var		localized	string		SpectateInstructionText2;
var		localized	string		SpectateInstructionText3;
var		localized	string		SpectateInstructionText4;
var		localized	string		NeedAmmoText;
var     localized   string      CanResupplyText;
var     localized   string      OpenMapText;
var     localized   string      SituationMapInstructionsText;
var                 string      SpacingText;

var     localized   string      MapCoordTextX[9], MapCoordTextY[9];

var     localized   string      LegendAxisObjectiveText;
var     localized   string      LegendAlliesObjectiveText;
var     localized   string      LegendNeutralObjectiveText;
var     localized   string      LegendArtilleryRadioText;
var     localized   string      LegendResupplyAreaText;
var     localized   string      LegendRallyPointText;
var     localized   string      LegendSavedArtilleryText;
var     localized   string      LegendOrderTargetText;
var     localized   string      LegendArtyStrikeText;
var     localized   string      LegendHelpRequestText;
var     localized   string      LegendDestroyableItemText;
var     localized   string      LegendDestroyedItemText;
var     localized   string      LegendMGResupplyText;
var     localized   string      LegendVehResupplyAreaText;
var     localized   string      LegendATGunText;


// Fonts
var		localized	string		SmallFontArrayNames[9];
var		Font					SmallFontArrayFonts[9];
var		localized	string		MenuFontArrayNames[5];
var		Font					MenuFontArrayFonts[5];
var     localized   string      CriticalMsgFontArrayNames[9];
var     Font                    CriticalMsgFontArrayFonts[9];

var		color					SideColors[2];

// General
var		DigitSet				Digits;					// Digit set for RO
var(ROHud) SpriteWidget         HealthFigure;			// Create widgets for all the HUD elements
var(ROHud) SpriteWidget         HealthFigureBackground;
var(ROHud) SpriteWidget         HealthFigureStamina;
var(ROHud) SpriteWidget         StanceIcon;
var(ROHud) NumericWidget        AmmoCount;
var(ROHud) SpriteWidget         AmmoIcon;
var(ROHud) SpriteWidget         AutoFireIcon;
var(ROHud) SpriteWidget         SemiFireIcon;
var(ROHud) SpriteWidget         MGDeployIcon;
var(ROHud) SpriteWidget         ResupplyZoneNormalPlayerIcon,
                                ResupplyZoneNormalVehicleIcon,
                                ResupplyZoneResupplyingPlayerIcon,
                                ResupplyZoneResupplyingVehicleIcon;
var(ROHud) SpriteWidget         WeaponCanRestIcon;
var(ROHud) SpriteWidget         WeaponRestingIcon;
var(ROHud) SpriteWidget         CompassBase;
var(ROHud) SpriteWidget         CompassNeedle;
var(ROHud) SpriteWidget         CompassIcons;

var     color                   WeaponReloadingColor;

var		Material				NationHealthFigures[2];	// FIXME: Need to move this over to RORoleInfo in some fashion.  It's hard-coded now. :/ - Erik
var		Material				NationHealthFiguresBackground[2];
var		Material				NationHealthFiguresStamina[2];
var		Material				NationHealthFiguresStaminaCritical[2];
//var		Material				NationClockBases[2];
//var		Material				NationClockHands[2];
var     Material                StanceStanding, StanceCrouch, StanceProne;
var     Material                PlayerArrowTexture;

var		bool					bShowObjectives;
/*var		Material				HeaderImage;
var		Material				NationIcons[2];
var		Material				NeutralIcon;
var		Material				ArtilleryIcon;    // The icon for a saved artillery strike location
var		Material				RallyPointIcon;    // The icon for a saved artillery strike location
var		Material				RadioIcon;        // The icon for a radio/phone station
var     Material                ResupplyIcon;
var     Material                HelpRequestIcon;
var     Material                MGResupplyRequestIcon;*/



var		Pawn					NamedPlayer;
var		float					NameTime;

// Debugging
var     bool                    bShowDebugInfoOnMap;
var     bool                    bShowRelevancyDebugOnMap;
var     bool                    bShowRelevancyDebugOverlay;

enum ENetDebugMode
{
	ND_PawnsOnly,		// Show debug info for pawns only (vehicles, players, etc)
	ND_VehiclesOnly,	// Show debug info for vehicles only
	ND_PlayersOnly,		// Show debug info for infantry players only
	ND_All,			    // Show Debug Info for all actors
	ND_AllWithText,     // Show Debug Info for all actors and their name
};

var ENetDebugMode	NetDebugMode;			// net debugging mode


struct TextWidget
{
	// Font must be set before calling DrawTextWidgetClipped()

	// String must left blank in default properties (for localization)
	var localized string text;

	var ERenderStyle RenderStyle;

	var EDrawPivot DrawPivot;
	var float PosX, PosY;
	var float WrapWidth, WrapHeight;
	var int OffsetX, OffsetY;

	var bool bDrawShadow;

	var color Tints[2];
};

// for drawing widgets on specific areas of the hud
struct AbsoluteCoordsInfo
{
	var float PosX, PosY;
	var float width, height;
};
struct RelativeCoordsInfo
{
	var float X, Y;   // 0-1 values
	var float XL, YL; // 0-1 values
};

// Death messages
struct Obituary
{
	var	string				KillerName;
	var	string				VictimName;
	var	Color				KillerColor;
	var	Color				VictimColor;
	var	class<DamageType>	DamageType;
	var	float				EndOfLife;
};

var		Obituary				Obituaries[4];
var		float					ObituaryLifeSpan;
var		int						ObituaryCount;

var		float					FadeTime;
var		color					FadeColor;
var     float                   WhiteFlashTime;

// for situation map icon
var(ROHud) SpriteWidget         MapUpdatedIcon;
var(ROHud) TextWidget           MapUpdatedText;
var     Material                MapIconsFlash, MapIconsFastFlash;
var     Material                MapIconsAltFlash, MapIconsAltFastFlash; // These are out of phase


// for situation map stuff
var     bool                        bShowMapUpdatedIcon;
var     float                       MapUpdatedIconTime;
var     float                       MaxMapUpdatedIconDisplayTime;
var     float                       MapLastRallyPointAssignTime;
var     sound                       AssignOKSound, AssignFailedSound;
var     bool                        bAnimateMapIn, bAnimateMapOut;
var     float                       AnimateMapCurrentPosition;
var     float                       AnimateMapSpeed;
var(ROHud)     bool                 bShowAllItemsInMapLegend;
var(ROHud)     SpriteWidget         MapBackground;
//var(ROHud)     SpriteWidget         MapLevelBounds; // Used to calculate where to draw level image
var(ROHud)     RelativeCoordsInfo   MapLegendImageCoords;
var(ROHud)     SpriteWidget         MapLevelImage; // Used to draw level image
var(ROHud)     TextWidget           MapTexts; // Used to render text on the level image
var(ROHud)     SpriteWidget         MapPlayerIcon; // Used to render player arrow on the level image
var(ROHud)     TextWidget           MapCoordTextXWidget, MapCoordTextYWidget;
var     int                         LegendItemsIndex;   // Holds current index of legend element (to figure where to draw)
var     float                       CurrentTime; // Contains remaining time for this round

// Used to render icons on the level image
var(ROHud)     SpriteWidget         MapIconTeam[2];
var(ROHud)     SpriteWidget         MapIconDispute[2];
var(ROHud)     SpriteWidget         MapIconNeutral;
var(ROHud)     SpriteWidget         MapIconRadio;
var(ROHud)     SpriteWidget         MapIconRally[2];
var(ROHud)     SpriteWidget         MapIconResupply;
var(ROHud)     SpriteWidget         MapIconVehicleResupply;
var(ROHud)     SpriteWidget         MapIconHelpRequest;
var(ROHud)     SpriteWidget         MapIconMGResupplyRequest[2];
var(ROHud)     SpriteWidget         MapIconAttackDefendRequest;
var(ROHud)     SpriteWidget         MapIconArtyStrike;
var(ROHud)     SpriteWidget         MapIconDestroyableItem;
var(ROHud)     SpriteWidget         MapIconDestroyedItem;
var(ROHud)     SpriteWidget         MapIconATGun;

var(ROHud)     TextWidget           MapTimerTitle;
var(ROHud)     TextWidget           MapTimerTexts[4];

var(ROHud)     RelativeCoordsInfo   MapLegendCoords;
var(ROHud)     SpriteWidget         MapLegend;
var(ROHud)     SpriteWidget         MapLegendIcons;
var(ROHud)     TextWidget           MapLegendTitle;
var(ROHud)     TextWidget           MapLegendTexts;

var(ROHud)     RelativeCoordsInfo   MapObjectivesCoords;
//var(ROHud)     SpriteWidget         MapObjectives;
var(ROHud)     TextWidget           MapObjectivesTitle;
var(ROHud)     TextWidget           MapRequiredObjectivesTitle;
var(ROHud)     TextWidget           MapSecondaryObjectivesTitle;
var(ROHud)     TextWidget           MapObjectivesTexts;

//var(ROHud)	   SpriteWidget			ClockBase;
//var(ROHud)	   SpriteWidget			ClockHand;


// Used for figuring where the player clicked on the situation map
var            AbsoluteCoordsInfo   MapLevelImageCoordinates;

// Player portraits
//var Material Portrait;
var             float               PortraitTime;
var             float               PortraitX;
var(ROHud)      SpriteWidget        PortraitIcon;
var(ROHud)      TextWidget          PortraitText[2];

var(ROHud) float MapScale;

// debugging
var bool bDebugDriverCollision;
var bool bDebugPlayerCollision;
var bool bDebugDrawHudBounds;

// Voice meter
var     	TexRotator          NeedleRotator; 			// The texture for the VU Meter needle
var			Texture			    VoiceMeterBackground;   // Background texture for the voice meter
var()   	float               VoiceMeterX;    		// Voice meter X position
var()   	float               VoiceMeterY;    		// Voice meter Y position
var()       float               VoiceMeterSize;         // Size of the voice meter icon

// for local messages
struct HudLocalizedMessageExtra
{
	// The following block of variables are cached on first render:
	var array<string> lines;
	var float y_offset;    // tells the renderer how much space to put between ROCriticalMessages
	var int background_type;
};
var() transient HudLocalizedMessageExtra LocalMessagesExtra[8];

// For compass
var         float           compassCurrentRotation;    // 0-65535
var         float           compassStabilizationConstant;
var         float           compassIconsOpacity; // 0-1 value
var         float           compassIconsFadeSpeed; // higher == icons dissapears faster
var         float           compassIconsRefreshSpeed;  // higher == icons reappear faster
var         float           compassIconsPositionRadius; // 0-1 value
//var         float           compassIconsUUDistance; // distance in UU at which icons start movign toward center of compass
var         vector          compassIconsTargets[8];
var         byte            compassIconsTargetsActive[8];
var         IntBox          compassIconsTargetsWidgetCoords[8];
//var         color           compassIconsTargetsColor[8];
/*var         color           compassIconsColorsAxis,
							compassIconsColorsAllies,
							compassIconsColorsNeutral,
							compassIconsColorsHelpRequests,
							compassIconsColorsMGResupply,
							compassIconsColorsRally;*/
//var         TexRotator      compassIconsRotators[8];

var         Material        locationHitAxisImages[15];
var         Material        locationHitAlliesImages[15];
var         float           locationHitAlphas[15];
var         bool            bDrawHits;  // Set to true when at least one of the location hit images needs
										// to be drawn

// General hud
var         float           hudLastRenderTime;

// For mouse interface
var         bool            bCapturingMouse;
var         vector          MouseCurrentPos;
var         int             LastHUDSizeX, LastHUDSizeY;
var         bool            bHaveAtLeastOneValidMouseUpdate;
var(ROHud)  SpriteWidget    MouseInterfaceIcon;

// For vehicle icon
var(ROHud)  RelativeCoordsInfo  VehicleIconCoords;
var(ROHud)  SpriteWidget        VehicleIcon, VehicleIconAlt;
var(ROHud)  SpriteWidget        VehicleThreads[2];
var(ROHud)  SpriteWidget        VehicleEngine;
var(ROHud)  SpriteWidget        VehicleOccupants;
var(ROHud)  TextWidget          VehicleOccupantsText;
var         color               VehicleNormalColor,
								VehicleDamagedColor,
								VehicleCriticalColor;
var         color               VehiclePositionIsPlayerColor,
								VehiclePositionIsOccupiedColor,
								VehiclePositionIsVacantColor;
var         Material            VehicleEngineDamagedTexture,
								VehicleEngineCriticalTexture;
var(ROHud)  SpriteWidget        VehicleAmmoIcon;
var(ROHud)  SpriteWidget        VehicleAmmoReloadIcon;
var(ROHud)  NumericWidget       VehicleAmmoAmount;
var(ROHud)  TextWidget          VehicleAmmoTypeText;
var         float               VehicleOccupantsTextOffset; // This offset is used when ammo is drawn
var(ROHud)  SpriteWidget        VehicleAltAmmoIcon;
var(ROHud)  NumericWidget       VehicleAltAmmoAmount;
var         float               VehicleAltAmmoOccupantsTextOffset; // Vertical offset
var(ROHud)  SpriteWidget        VehicleMGAmmoIcon;
var(ROHud)  NumericWidget       VehicleMGAmmoAmount;

var         Material            VehicleRPMTextures[2],
                                VehicleRPMNeedlesTextures[2],
                                VehicleSpeedTextures[2],
                                VehicleSpeedNeedlesTextures[2];
var(ROHud)  SpriteWidget        VehicleSpeedIndicator;
var(ROHud)  SpriteWidget        VehicleRPMIndicator;
var(ROHud)  SpriteWidget        VehicleThrottleIndicatorTop, VehicleThrottleIndicatorBottom,
                                VehicleThrottleIndicatorBackground,
                                VehicleThrottleIndicatorForeground,
                                VehicleThrottleIndicatorLever;
var         float               VehicleRPMZeroPosition[2], VehicleRPMScale[2];
var         float               VehicleSpeedZeroPosition[2], VehicleSpeedScale[2];
var         float               VehicleThrottleTopZeroPosition, VehicleThrottleTopMaxPosition;
var         float               VehicleThrottleBottomZeroPosition, VehicleThrottleBottomMaxPosition;
var         float               VehicleGaugesOccupantsTextOffset;
var         float               VehicleGaugesNoThrottleOccupantsTextOffset;

var         float               VehicleLastSpeedRotation, // Speed displayed on speed needle last time
                                VehicleLastRPMRotation; // RPM displayed on RPM needle last time
var         float               VehicleNeedlesRotationSpeed;
var         float               VehicleNeedlesLastRenderTime;

// for capture bar
var(ROHud)  SpriteWidget        CaptureBarBackground;
var(ROHud)  SpriteWidget        CaptureBarOutline;
var(ROHud)  SpriteWidget        CaptureBarAttacker;
var(ROHud)  SpriteWidget        CaptureBarDefender;
var(ROHud)  SpriteWidget        CaptureBarAttackerRatio;
var(ROHud)  SpriteWidget        CaptureBarDefenderRatio;
var(ROHud)  SpriteWidget        CaptureBarIcons[2];
var         Material            CaptureBarTeamIcons[2];
var         color               CaptureBarTeamColors[2];
var         bool                bDrawingCaptureBar;

// for hints
var         bool                bDrawHint;
var         bool                bFirstHintRender; // Used to only calculate hint sizing constants once
var(ROHud)  float               HintFadeTime; // How long it takes to fade in/out
var         float               HintRemainingTime;
var(ROHud)  float               HintLifetime;
var(ROHud)  float               HintDesiredAspectRatio; // Aspect ratio used to wrap hint data
var         string              HintTitle, HintText; // This is localized in ROHintManager
var         array<string>       HintWrappedText;
var(ROHud)  SpriteWidget        HintBackground;
var(ROHud)  TextWidget          HintTitleWidget;
var(ROHud)  TextWidget          HintTextWidget;
var(ROHud)  RelativeCoordsInfo  HintCoords; // default properties of this are used when rendering, XL and YL are used to pivot around the X and Y pos

// for fading to & from black
var         bool                bFadeToBlack;
var         float               FadeToBlackTime;
var         float               FadeToBlackStartTime;
var         bool                bFadeToBlackInvert;

var			bool				bUsingVOIP; // Player is using VOIP
//=============================================================================
// Functions
//=============================================================================

exec function ShowDebug()
{
	if( Level.NetMode != NM_Standalone && !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

    bShowDebugInfo = !bShowDebugInfo;
}

simulated function SetNetDebugMode(int NewMode)
{
    if( ENetDebugMode(NewMode) != NetDebugMode)
        NetDebugMode = ENetDebugMode(NewMode);
}

//-----------------------------------------------------------------------------
// UpdatePrecacheMaterials
//-----------------------------------------------------------------------------

simulated function UpdatePrecacheMaterials()
{
/*	Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rupperleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Lupperarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rupperarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Llowerleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rlowerleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Llowerarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rlowerarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Lhand');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rhand');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Lfoot');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.rus_hit_Rfoot');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_head');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_torso');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Pelvis');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Lupperleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rupperleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Lupperarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rupperarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Llowerleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rlowerleg');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Llowerarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rlowerarm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Lhand');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rhand');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Lfoot');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Player_hits.ger_hit_Rfoot');

    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.HUD.MGDeploy');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.HUD.Compass2_main');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.HUD.TexRotator0');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.OverheadMap.overheadmap_background');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.HUD.VUMeter');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Cursors.Pointer');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.HUD.Needle_rot');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Menu.SectionHeader_captionbar');

    Level.AddPrecacheMaterial(FinalBlend'InterfaceArt_tex.OverheadMap.arrowhead_final');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.OverheadMap.overheadmap_Icons');
    Level.AddPrecacheMaterial(Material'InterfaceArt2_tex.overheadmaps.overheadmap_IconsB');

    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.numbers');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.situation_map_icon');

    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.ger_player');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.ger_player_background');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.ger_player_Stamina');
    Level.AddPrecacheMaterial(FinalBlend'InterfaceArt_tex.HUD.ger_player_Stamina_critical');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.rus_player');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.rus_player_background');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.rus_player_Stamina');
    Level.AddPrecacheMaterial(FinalBlend'InterfaceArt_tex.HUD.rus_player_Stamina_critical');

    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.stance_stand');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.stance_crouch');
    Level.AddPrecacheMaterial(Material'InterfaceArt_tex.HUD.stance_prone');


    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.throttle_background2');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.throttle_background2_bottom');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.throttle_background');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.throttle_main');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.throttle_lever');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.Ger_RPM');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.Rus_RPM');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.Ger_Speedometer');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.Tank_Hud.Rus_Speedometer');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.Tank_Hud.Ger_needle_rot');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.Tank_Hud.Rus_needle_rot');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.Tank_Hud.Ger_needle_rpm_rot');
    Level.AddPrecacheMaterial(TexRotator'InterfaceArt_tex.Tank_Hud.Rus_needle_rpm_rot');

    // Damage icons
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.artkill');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.satchel');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.Strike');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.Generic');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.b792mm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.buttsmack');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.knife');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.b762mm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.rusgrenade');
    Level.AddPrecacheMaterial(Texture'InterfaceArt2_tex.deathicons.sniperkill');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.b9mm');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.germgrenade');
    Level.AddPrecacheMaterial(Texture'InterfaceArt2_tex.deathicons.faustkill');
    Level.AddPrecacheMaterial(Texture'InterfaceArt_tex.deathicons.mine');
*/}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    // hax! modify existing compass texture to use new texture instead of old one
//    TexRotator'InterfaceArt_tex.HUD.TexRotator0'.Material = Texture'InterfaceArt_tex.HUD.Compass2_background';
 //   TexRotator'InterfaceArt_tex.HUD.TexRotator0'.UOffset = 128;
   // TexRotator'InterfaceArt_tex.HUD.TexRotator0'.VOffset = 128;
}

// FIXME: Ummm.... PostNETBeginPlay?  On the HUD?  Why is this here?  There is no replication
// that takes place with the HUD, so it's likely not even called. - Erik
simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if( (Level.NetMode != NM_DedicatedServer) && (ROPlayer(PlayerOwner) != none) )
	{
		ROPlayer(PlayerOwner).GetNorthDirection();
	}
}

//function DrawDamageIndicators(Canvas C);


function DrawDamageIndicators(Canvas C)
{
	if ( DamageTime[0] > 0 )
	{
		C.SetPos(0,0);
		C.DrawColor = DamageFlash[0];
		C.DrawColor.A = DamageTime[0];
//		if ( Emphasized[0] == 1 )
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', C.ClipX, 0.15*C.ClipY, 0, 64, 32, -14);
//		else
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', C.ClipX, 0.05*C.ClipY, 0, 64, 32, -14);
	}
	else
		Emphasized[0] = 0;

	if ( DamageTime[1] > 0 )
	{
		C.DrawColor = DamageFlash[1];
		C.DrawColor.A = DamageTime[1];
		if ( Emphasized[1] == 1 )
		{
			C.SetPos(0,0.85*C.ClipY);
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', C.ClipX, 0.15*C.ClipY, 0, 50, 32, 14);
		}
		else
		{
			C.SetPos(0,0.9*C.ClipY);
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', C.ClipX, 0.1*C.ClipY, 0, 50, 32, 14);
		}
	}
	else
		Emphasized[1] = 0;

	if ( DamageTime[2] > 0 )
	{
		C.SetPos(0,0);
		C.DrawColor = DamageFlash[2];
		C.DrawColor.A = DamageTime[2];
//		if ( Emphasized[2] == 1 )
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', 0.15*C.ClipX, C.ClipY, 16, 0, 14, 32);
//		else
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', 0.05*C.ClipX, C.ClipY, 16, 0, 14, 32);
	}
	else
		Emphasized[2] = 0;

	if ( DamageTime[3] > 0 )
	{
		C.DrawColor = DamageFlash[3];
		C.DrawColor.A = DamageTime[3];
		if ( Emphasized[3] == 1 )
		{
			C.SetPos(0.85*C.ClipX,0);
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', 0.15*C.ClipX, C.ClipY, 30, 0, -14, 32);
		}
		else
		{
			C.SetPos(0.95*C.ClipX,0);
//			C.DrawTile( Texture'InterfaceArt_tex.HUD.damage_indicators', 0.05*C.ClipX, C.ClipY, 30, 0, -14, 32);
		}
	}
	else
		Emphasized[3] = 0;
}

/*
we want to do a few things here:
1.) check to see if a player is on our side, if not then return out
2.) trace to see if they are visible, otherwise return out
3.) make sure they're within X units or return out

TODO - Change the font on the names to use a RO font
TODO - Figure out something new for DrawPlayerNames
*/
function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL,YL;
	local PlayerReplicationInfo PRI;
	local int PlayerDist;
//	local Actor Hit;

	log("Are we even getting here?");

	PRI = P.PlayerReplicationInfo;

	if( (PRI == none) || (PRI.Team == none) )
		return;

	if( (PlayerOwner == none) || (PlayerOwner.PlayerReplicationInfo == none)
		|| (PlayerOwner.PlayerReplicationInfo.Team == none )
		|| (PlayerOwner.Pawn == none) )
	{
		return;
	}

	if( (PlayerOwner.PlayerReplicationInfo.Team.TeamIndex != PRI.Team.TeamIndex) )
		return;

	PlayerDist = VSize(P.Location - PlayerOwner.Pawn.Location);

	if( PlayerDist > 1600 )
	{
		return;
	}

	if( !FastTrace( P.Location, PlayerOwner.Pawn.Location ) )
	{
		    log("Fasttrace from "$P$" to "$PlayerOwner.Pawn$" Failed ");
	    return;
	}

	if ( PRI.Team != None )
		C.DrawColor = GetTeamColor(PRI.Team.TeamIndex);
	else
		C.DrawColor = GetTeamColor(0);
		//C.DrawColor = class'PlayerController'.Default.TeamBeaconTeamColors[0];

	C.Font = GetConsoleFont(C);
	//C.TextSize(PRI.PlayerName, strX, strY);
	C.StrLen(PRI.PlayerName, XL, YL);
	C.SetPos(ScreenLocX - 0.5*XL , ScreenLocY - YL);
	C.DrawText(PRI.PlayerName,true);

	C.SetPos(ScreenLocX, ScreenLocY);
}

//-----------------------------------------------------------------------------
// StartFadeEffect - Used to initiate a screen fade to black upon player death
//-----------------------------------------------------------------------------

function StartFadeEffect()
{
	FadeColor.R = 255;
	FadeColor.G = 255;
	FadeColor.B = 255;
	FadeColor.A = 0;
	FadeTime = Level.TimeSeconds + 5.0 + WhiteFlashTime * 2;
}

//-----------------------------------------------------------------------------
// ForceFadeEffect - Used to force a screen blacked out effect
//-----------------------------------------------------------------------------

function ForceFadeEffect()
{
	FadeColor.R = 0;
	FadeColor.G = 0;
	FadeColor.B = 0;
	FadeColor.A = 255;
	FadeTime = 0;
}


//-----------------------------------------------------------------------------
// StopFadeEffect - Kills off the fade effect
//-----------------------------------------------------------------------------

function StopFadeEffect()
{
	FadeTime = -1;
}

//-----------------------------------------------------------------------------
// DrawFadeEffect - Called to draw the fade effect to the screen
//-----------------------------------------------------------------------------

simulated function DrawFadeEffect(Canvas C)
{
	if (FadeTime < 0)
		return;

	if (FadeTime - Level.TimeSeconds - 5 - WhiteFlashTime > 0)
	{
   	    FadeColor.R = 255;
	    FadeColor.G = 255;
	    FadeColor.B = 255;
	    FadeColor.A = 64 * (1 - (FMax(FadeTime - Level.TimeSeconds - 5 - WhiteFlashTime, 0.0) / WhiteFlashTime));
	    C.DrawColor = FadeColor;
	}
	else if (FadeTime - Level.TimeSeconds - 5 > 0)
	{
   	    FadeColor.R = 255;
	    FadeColor.G = 255;
	    FadeColor.B = 255;
		FadeColor.A = 64 * (FMax(FadeTime - Level.TimeSeconds - 5, 0.0) / WhiteFlashTime);
	    C.DrawColor = FadeColor;
	}
	else
	{
   	    FadeColor.R = 0;
	    FadeColor.G = 0;
	    FadeColor.B = 0;
	    FadeColor.A = 255 * (1 - FMax(FadeTime - Level.TimeSeconds, 0.0) * 0.2);
	    C.DrawColor = FadeColor;
	}
	C.SetPos(0, 0);
	C.DrawTileStretched(Material'Engine.WhiteSquareTexture', C.ClipX, C.ClipY);
	C.DrawColor = WhiteColor;
}

function ShowMapUpdatedIcon()
{
	if (!bShowObjectives && !bAnimateMapIn && ! bAnimateMapOut)
	{
		MapUpdatedIconTime = Level.TimeSeconds;
		bShowMapUpdatedIcon = true;
	}
}

//-----------------------------------------------------------------------------
// AddDeathMessage - Adds a death message to the HUD
//-----------------------------------------------------------------------------

function AddDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> DamageType)
{
	local int i;

	if (Victim == None)
		return;

	if (ObituaryCount == ArrayCount(Obituaries))
	{
		for (i = 1; i < ArrayCount(Obituaries); i++)
			Obituaries[i - 1] = Obituaries[i];

		ObituaryCount--;
		Obituaries[ObituaryCount].KillerName = "";
	}

	if (Killer != None && Killer != Victim)
	{
		Obituaries[ObituaryCount].KillerName = Killer.PlayerName;
		Obituaries[ObituaryCount].KillerColor = GetTeamColor(Killer.Team.TeamIndex);
	}

	Obituaries[ObituaryCount].VictimName = Victim.PlayerName;
	Obituaries[ObituaryCount].VictimColor = GetTeamColor(Victim.Team.TeamIndex);
	Obituaries[ObituaryCount].DamageType = DamageType;
	Obituaries[ObituaryCount].EndOfLife = Level.TimeSeconds + ObituaryLifeSpan;

    // Making the player's name show up in white in the kill list
    if ( PlayerOwner != none && Killer != none)
	{
	     if ( PlayerOwner.PlayerReplicationInfo != none )
	      {
              // When the player kills someone
              if ( PlayerOwner.PlayerReplicationInfo.PlayerName == Killer.PlayerName )
	          {
                   Obituaries[ObituaryCount].KillerColor = WhiteColor;
              }
          }
	}

	ObituaryCount++;
}

//-----------------------------------------------------------------------------
// GetDamageIcon
//-----------------------------------------------------------------------------

function Material GetDamageIcon(class<DamageType> DamType)
{
	if (class<ROWeaponDamageType>(DamType) != None)
		return class<ROWeaponDamageType>(DamType).default.HUDIcon;
	else if (class<ROVehicleDamageType>(DamType) != None)
		return class<ROVehicleDamageType>(DamType).default.HUDIcon;
//	else if (class<ROSuicided>(DamType) != None)
//		return Texture'InterfaceArt_tex.deathicons.mine';

//	return Texture'InterfaceArt_tex.deathicons.mine';
}

//-----------------------------------------------------------------------------
// DisplayMessages - Added death messages
//-----------------------------------------------------------------------------

function DisplayMessages(Canvas C)
{
	local int i;
	local float X, Y, XL, YL, Scale;

	Super.DisplayMessages(C);

	while (Obituaries[0].VictimName != "" && Obituaries[0].EndOfLife < Level.TimeSeconds)
	{
		for (i = 1; i < ObituaryCount; i++)
			Obituaries[i - 1] = Obituaries[i];

		ObituaryCount--;
		Obituaries[ObituaryCount].VictimName = "";
		Obituaries[ObituaryCount].KillerName = "";
	}

	Scale = C.ClipX / 1600.0;

	C.Font = GetConsoleFont(C);

	Y = 8 * Scale;

	// Offset death msgs if we're displaying a hint
	if (bDrawHint)
		Y += 2 * Y + (HintCoords.Y + HintCoords.YL) * C.ClipY;

	for (i = 0; i < ObituaryCount; i++)
	{
		C.TextSize(Obituaries[i].VictimName, XL, YL);

		X = C.ClipX - 8 * Scale - XL;

		C.SetPos(X, Y + 20 * Scale - YL * 0.5);
		C.DrawColor = Obituaries[i].VictimColor;
		C.DrawTextClipped(Obituaries[i].VictimName);

		X -= 48 * Scale;

		C.SetPos(X, Y);
		C.DrawColor = WhiteColor;
		C.DrawTileScaled(GetDamageIcon(Obituaries[i].DamageType), Scale * 1.25, Scale * 1.25);

		if (Obituaries[i].KillerName != "")
		{
			C.TextSize(Obituaries[i].KillerName, XL, YL);
			X -= 8 * Scale + XL;

			C.SetPos(X, Y + 20 * Scale - YL * 0.5);
			C.DrawColor = Obituaries[i].KillerColor;
			C.DrawTextClipped(Obituaries[i].KillerName);
		}

		Y += 44 * Scale;
	}
}

//-----------------------------------------------------------------------------
// GetTeamColor - Returns the appropriate team color
//-----------------------------------------------------------------------------

static function color GetTeamColor(byte Team)
{
	return default.SideColors[Team];
}

//-----------------------------------------------------------------------------
// ShowObjectives - Enables or disables the objectives display
//-----------------------------------------------------------------------------

exec function ShowObjectives()
{
	bShowObjectives = !bShowObjectives;
	bShowMapUpdatedIcon = false;

	if (bShowObjectives)
	{
	    // Open fake menu to capture mouse clicks
	    //PlayerOwner.ClientOpenMenu("ROInterface.ROSituationMapMenu");
	    MouseInterfaceStartCapturing();
	    bAnimateMapIn = true; bAnimateMapOut = false;

	    // Check for hints
	    if (ROPlayer(PlayerOwner) != none)
	        ROPlayer(PlayerOwner).CheckForHint(14);
	}
	else
	    HideObjectives();
}

simulated function HideObjectives()
{
	bAnimateMapIn = false; bAnimateMapOut = true;
	MouseInterfaceStopCapturing();
	bShowObjectives = false;
}

simulated function ShowHint(string title, string text)
{
	bFirstHintRender = true;
	HintWrappedText.Length = 0;
	HintRemainingTime = HintLifetime + HintFadeTime * 2;
	HintTitle = title;

	// Parse keybinds
	if (PlayerOwner != none)
		HintText = class'ROTeamGame'.static.ParseLoadingHintNoColor(text, PlayerOwner);
	else
		HintText = text;
	bDrawHint = true;
}

// not used
/*simulated function DrawObjectiveLocationIcons(Canvas C)
{
	local ROGameReplicationInfo GRI;
	local int 		i;
	local vector  	ScreenPos,
				  	TargetLocation;

	if ( PlayerOwner.Player.GUIController.bActive )
		return;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	// this is test code for objective stuff
	if( GRI != none )
	{
		for( i = 0; i < 4; i++ )
		{
			if( GRI.Objectives[i] != none )
			{
				TargetLocation = GRI.Objectives[i].Location;

				ScreenPos = C.WorldToScreen(TargetLocation);

				if (ScreenPos.X >= 0 || ScreenPos.X <= C.ClipX || ScreenPos.Y >= 0 || ScreenPos.Y <= C.ClipY)
				{
					C.SetPos(ScreenPos.X, ScreenPos.Y);
					C.DrawTileStretched(Material'ROInterfaceArt.ObjectiveIcon', 16, 16);
				}
			}
		}

	}
}*/

simulated function UpdateHud()
{
	local ROGameReplicationInfo GRI;
	local class<Ammunition> AmmoClass;
	local Weapon W;
	//local float Time;
	local byte Nation;
	local ROPawn P;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if (PawnOwnerPRI != None)
	{
	    if (PawnOwner != none)
		{
			// Set pawn color
			// Took this out for now. Since one or two shots kills you, and
			// the colors look kinda funny on the hud, This probably isn't
			// needed. Add it back in if we decide otherwise - Ramm
			//if (PawnOwner.Health > 50)
				HealthFigure.Tints[0] = WhiteColor;
			//else if (PawnOwner.Health > 25)
			//	HealthFigure.Tints[0] = GoldColor;
			//else
			//	HealthFigure.Tints[0] = RedColor;

			P = ROPawn(PawnOwner);
			if (P != none)
			{
			    // Set stamina info
		        HealthFigureStamina.scale = 1 - P.Stamina / P.default.Stamina;
		        HealthFigureStamina.Tints[0].G = 255 - HealthFigureStamina.scale * 255;
		        HealthFigureStamina.Tints[1].G = 255 - HealthFigureStamina.scale * 255;
		        HealthFigureStamina.Tints[0].B = 255 - HealthFigureStamina.scale * 255;
		        HealthFigureStamina.Tints[1].B = 255 - HealthFigureStamina.scale * 255;

		        // Set stance info
		        if (P.bIsCrouched)
					StanceIcon.WidgetTexture = StanceCrouch;
				else if (P.bIsCrawling)
					StanceIcon.WidgetTexture = StanceProne;
				else
					StanceIcon.WidgetTexture = StanceStanding;
			}
		}

		if (PawnOwnerPRI.Team != None && GRI != None)
		{
			Nation = GRI.NationIndex[PawnOwnerPRI.Team.TeamIndex];
			HealthFigure.WidgetTexture = NationHealthFigures[Nation];
			HealthFigureBackground.WidgetTexture = NationHealthFiguresBackground[Nation];
			if (HealthFigureStamina.scale > 0.9)
			{
			    HealthFigureStamina.WidgetTexture = NationHealthFiguresStaminaCritical[Nation];
			    HealthFigureStamina.Tints[0].G = 255; HealthFigureStamina.Tints[1].G = 255;
		        HealthFigureStamina.Tints[0].B = 255; HealthFigureStamina.Tints[1].B = 255;
			}
			else
				HealthFigureStamina.WidgetTexture = NationHealthFiguresStamina[Nation];
			//ClockBase.WidgetTexture = NationClockBases[Nation];
			//ClockHand.WidgetTexture = NationClockHands[Nation];
		}
	}

	AmmoIcon.WidgetTexture = none; // This is so we don't show icon on binocs or when we have no weapon

	if (PawnOwner == None)
		return;

	W = PawnOwner.Weapon;
	if( W == none )
		return;

	AmmoClass = W.GetAmmoClass(0);

	if( AmmoClass == none )
		return;

	AmmoIcon.WidgetTexture = AmmoClass.default.IconMaterial;
	AmmoCount.Value = W.GetHudAmmoCount();

/*	if (ROWeapon(W) != none && ROWeapon(W).bShowMagazineIcon )
	{
		AmmoIcon.WidgetTexture = AmmoClass.default.IconMaterial;
		AmmoCount.Value = ROWeapon(W).GetROHudDisplayMagazines();
	}
	else if (ROWeapon(W) != none && ROWeapon(W).bShowMagazineCount)
	{
		AmmoIcon.WidgetTexture = AmmoClass.default.IconMaterial;
		AmmoCount.Value = W.AmmoAmount(0);
	}*/

}

//-----------------------------------------------------------------------------
// DrawHudPassA - Draw local messages
//-----------------------------------------------------------------------------

simulated function DrawHudPassA(Canvas C)
{
	DisplayLocalMessages(C);

	if( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			PlayerOwner.ActiveRoom.GetTitle() == "Team")
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}
	}
	else
	{
		if( bUsingVOIP )
		{
			bUsingVOIP = false;
		}
	}

	if( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
		DisplayVoiceGain(C);
}

//-----------------------------------------------------------------------------
// DisplayVoiceGain - Draw the voice meter and needle
//-----------------------------------------------------------------------------
function DisplayVoiceGain(Canvas C)
{
	local float VoiceGain;
	local float PosY, PosX, XL, YL;
	local string ActiveName;
	local float IconSize, scale, YOffset;
	local color SavedColor;

	scale = C.SizeY / 1200.0 * HudScale;

	SavedColor = C.DrawColor;
	C.DrawColor = WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

	VoiceGain = (1 - 3 * Min( Level.TimeSeconds - LastVoiceGainTime, 0.3333 )) * LastVoiceGain;

	YOffset = 12 * scale;
	IconSize = VoiceMeterSize * Scale;

	PosY = VoiceMeterY * C.ClipY - IconSize - YOffset;
	PosX = VoiceMeterX * C.ClipX;
	C.SetPos( PosX, PosY );

	C.DrawTile( VoiceMeterBackground, IconSize, IconSize, 0, 0, VoiceMeterBackground.USize, VoiceMeterBackground.VSize );

	NeedleRotator.Rotation.Yaw = -1 * ((20000 * VoiceGain) + 55000);

	C.SetPos( PosX, PosY );
	C.DrawTileScaled(NeedleRotator, scale * VoiceMeterSize / 128.0, scale * VoiceMeterSize / 128.0);

	// Display name of currently active channel
	if ( PlayerOwner != None && PlayerOwner.ActiveRoom != None )
		ActiveName = PlayerOwner.ActiveRoom.GetTitle();

	// Remove for release
	if(ActiveName == "")
		ActiveName = "No Channel Selected!";

	if ( ActiveName != "" )
	{
	    C.SetPos(0, 0);
		ActiveName = "(" @ ActiveName @ ")";
		C.Font = GetFontSizeIndex(C,-2);
		C.StrLen(ActiveName,XL,YL);

		if ( XL > 0.125 * C.ClipY )
		{
			C.Font = GetFontSizeIndex(C,-4);
			C.StrLen(ActiveName,XL,YL);
		}

		C.SetPos( PosX + ((IconSize/2) - (XL/2)), PosY - YL);
		C.DrawColor = C.MakeColor(160,160,160);
		if ( PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None )
		{
			if ( PlayerOwner.PlayerReplicationInfo.Team != None )
			{
				if ( PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == 0 )
					C.DrawColor = RedColor;
				else
					C.DrawColor = TurqColor;
			}
		}

		C.DrawText( ActiveName );
	}

	C.DrawColor = SavedColor;
}


//-----------------------------------------------------------------------------
// DrawHudPassC - Draw all the widgets here
//-----------------------------------------------------------------------------

simulated function DrawHudPassC(Canvas C)
{
	local VoiceChatRoom VCR;
	//local float PortraitWidth,PortraitHeight, Abbrev, SmallH, NameWidth;
	//local string PortraitString;

	local ROPawn ROP;
	local ROGameReplicationInfo GRI;
	//local int i;
	//local float X, Y, XL, YL, alpha;
	local float Y, XL, YL, alpha;
	local string S;
	local color myColor;
	local AbsoluteCoordsInfo coords;
	local ROWeapon myweapon;

	// Set coordinates to use whole screen
	coords.width = C.ClipX; coords.height = C.ClipY;


	ROP = ROPawn(PawnOwner);
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	// Don't draw the healthfigure when in a vehicle
	if (bShowPersonalInfo && ROP != None)
	{
		DrawSpriteWidget(C, HealthFigureBackground);
		DrawSpriteWidget(C, HealthFigureStamina);
		DrawSpriteWidget(C, HealthFigure);

		DrawSpriteWidget(C, StanceIcon);

		DrawLocationHits(C, ROP);
	}

	// Show MG deploy icon if the weapon can be deployed
	if (PawnOwner != None && PawnOwner.bCanBipodDeploy)
		DrawSpriteWidget(C, MGDeployIcon);

	// Draw the icon for weapon resting
	if (PawnOwner != None)
	{
		if (PawnOwner.bRestingWeapon)
		{
			DrawSpriteWidget(C, WeaponRestingIcon);
		}
		else if (PawnOwner.bCanRestWeapon)
		{
			DrawSpriteWidget(C, WeaponCanRestIcon);
		}
	}

	// Resupply icon
	if (PawnOwner != None && PawnOwner.bTouchingResupply)
	{
	    if (Vehicle(PawnOwner) != none)
		{
	        if (Level.TimeSeconds - PawnOwner.LastResupplyTime <=  1.5)
    			DrawSpriteWidget(C, ResupplyZoneResupplyingVehicleIcon);
    		else
    			DrawSpriteWidget(C, ResupplyZoneNormalVehicleIcon);
		}
		else
		{
    		if (Level.TimeSeconds - PawnOwner.LastResupplyTime <=  1.5)
    			DrawSpriteWidget(C, ResupplyZoneResupplyingPlayerIcon);
    		else
    			DrawSpriteWidget(C, ResupplyZoneNormalPlayerIcon);
		}
	}

	// Show weapon info
	if (bShowWeaponInfo && PawnOwner.Weapon != none && AmmoIcon.WidgetTexture != none )
	{
	    myweapon = ROWeapon(PawnOwner.Weapon);

	    if ( myweapon != none )
	    {
	        if ( myweapon.bWaitingToBolt || myweapon.AmmoAmount(0) <= 0 )
	        {
	            AmmoIcon.Tints[TeamIndex] = WeaponReloadingColor;
	            AmmoCount.Tints[TeamIndex] = WeaponReloadingColor;
	            AutoFireIcon.Tints[TeamIndex] = WeaponReloadingColor;
	            SemiFireIcon.Tints[TeamIndex] = WeaponReloadingColor;
	        }
	        else
	        {
	            AmmoIcon.Tints[TeamIndex] = default.AmmoIcon.Tints[TeamIndex];
	            AmmoCount.Tints[TeamIndex] = default.AmmoCount.Tints[TeamIndex];
	            AutoFireIcon.Tints[TeamIndex] = default.AutoFireIcon.Tints[TeamIndex];
	            SemiFireIcon.Tints[TeamIndex] = default.SemiFireIcon.Tints[TeamIndex];
	        }
		   	DrawSpriteWidget(C, AmmoIcon);
			DrawNumericWidget(C, AmmoCount, Digits);

			if( myweapon.bHasSelectFire )
			{
				if( myweapon.UsingAutoFire() )
				{
					DrawSpriteWidget(C, AutoFireIcon);
				}
				else
				{
					DrawSpriteWidget(C, SemiFireIcon);
				}
	        }
		}
	}

	DrawCaptureBar(C);

	// Draw Compass
	if (bShowCompass)
		DrawCompass(C);

   	// Draw the 'map updated' icon
	if (bShowMapUpdatedIcon)
	{
		alpha = (Level.TimeSeconds - MapUpdatedIconTime) % 2;
		if (alpha < 0.5)
			alpha = 1 - alpha / 0.5;
		else if (alpha < 1)
			alpha = (alpha - 0.5) / 0.5;
		else
			alpha = 1;
		myColor.R = 255;
		myColor.G = 255;
		myColor.B = 255;
		myColor.A = alpha * 255;

		if (myColor.A != 0)
		{
			// Set different position if not showing compass
			if (!bShowCompass)
			{
			    MapUpdatedText.PosX = 0.95;
			    MapUpdatedIcon.PosX = 0.95;
			}
			else
			{
			    MapUpdatedText.PosX = default.MapUpdatedText.PosX;
			    MapUpdatedIcon.PosX = default.MapUpdatedIcon.PosX;
			}

			XL = 0; YL = 0; Y = 0;

			if (bShowMapUpdatedText)
			{
				// Check width & height of text label
				S = class'ROTeamGame'.static.ParseLoadingHintNoColor(OpenMapText, PlayerController(Owner));
				C.Font = getSmallMenuFont(C);
				//C.TextSize(S, XL, YL);

				// Draw text
				MapUpdatedText.text = S;
				MapUpdatedText.Tints[0] = myColor; MapUpdatedText.Tints[1] = myColor;
				MapUpdatedText.OffsetY = default.MapUpdatedText.OffsetY * MapUpdatedIcon.TextureScale;
			    DrawTextWidgetClipped(C, MapUpdatedText, coords, XL, YL, Y);

		   	    // Offset icon by text height
			    MapUpdatedIcon.OffsetY = MapUpdatedText.OffsetY - YL - Y / 2;
			}
			else
			{
			    // Offset icon by text height
			    MapUpdatedIcon.OffsetY = default.MapUpdatedText.OffsetY * MapUpdatedIcon.TextureScale;
			}


		    // Draw icon
	  		MapUpdatedIcon.Tints[0] = myColor; MapUpdatedIcon.Tints[1] = myColor;
		    DrawSpriteWidgetClipped(C, MapUpdatedIcon, coords, true, XL, YL, true, true, true);

		    // Check if we should stop showing the icon
			if (Level.TimeSeconds - MapUpdatedIconTime > MaxMapUpdatedIconDisplayTime)
			    bShowMapUpdatedIcon = false;
	    }
	}

	//if (!bNoEnemyNames)
		DrawPlayerNames(C);

    if((Level.NetMode == NM_Standalone || GRI.bAllowNetDebug) && bShowRelevancyDebugOverlay)
	   DrawNetworkActors(C);

	// Comment Out for Release
	//if( Level.NetMode == NM_StandAlone )
	//	DrawCrosshair(C);

	// portrait
	if ( (bShowPortrait || (bShowPortraitVC && Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0)) )
	{
	    // Start by updating current portrait PRI
	    if ( (Level.TimeSeconds - LastPlayerIDTalkingTime < 0.1) && (PlayerOwner.GameReplicationInfo != None) )
		{
			if ( (PortraitPRI == None) || (PortraitPRI.PlayerID != LastPlayerIDTalking) )
			{
			    if (PortraitPRI == none)
			        PortraitX = 1;
				PortraitPRI = PlayerOwner.GameReplicationInfo.FindPlayerByID(LastPlayerIDTalking);
				if ( PortraitPRI != None )
				    PortraitTime = Level.TimeSeconds + 3;
			}
			else
				PortraitTime = Level.TimeSeconds + 0.2;
		}
		else
			LastPlayerIDTalking = 0;

		// Update portrait alpha value (fade in & fade out)
		if ( PortraitTime - Level.TimeSeconds > 0 )
			PortraitX = FMax(0, PortraitX - 3 * (Level.TimeSeconds - hudLastRenderTime));
		else if ( PortraitPRI != None )
		{
			PortraitX = FMin(1, PortraitX + 3 * (Level.TimeSeconds - hudLastRenderTime));
			if ( PortraitX == 1 )
			{
				//Portrait = None;
				PortraitPRI = None;
			}
		}

	    // Draw portrait if needed
	    if (PortraitPRI != none)
	    {
		    if (PortraitPRI.Team != none)
			{
				if (PortraitPRI.Team.TeamIndex == 0)
				{
					PortraitIcon.WidgetTexture = CaptureBarTeamIcons[0];
					PortraitText[0].Tints[TeamIndex] = SideColors[0];
				}
				else if (PortraitPRI.Team.TeamIndex == 1)
				{
					PortraitIcon.WidgetTexture = CaptureBarTeamIcons[1];
					PortraitText[0].Tints[TeamIndex] = SideColors[1];
				}
				else
				{
					PortraitIcon.WidgetTexture = CaptureBarTeamIcons[0];
					PortraitText[0].Tints[TeamIndex] = default.PortraitText[0].Tints[TeamIndex];
				}
			}

			// PortraitX goes from 0 to 1 -- we'll use that as alpha
			PortraitIcon.Tints[TeamIndex].A = 255 * (1 - PortraitX);
			PortraitText[0].Tints[TeamIndex].A = PortraitIcon.Tints[TeamIndex].A;

			XL = 0;
			DrawSpriteWidgetClipped(C, PortraitIcon, coords, true, XL, YL, false, true);

			// Draw first line of text
			PortraitText[0].OffsetX = PortraitIcon.OffsetX * PortraitIcon.TextureScale + XL * 1.1;
			PortraitText[0].text = PortraitPRI.PlayerName;
			C.Font = GetFontSizeIndex(C,-2);
			DrawTextWidgetClipped(C, PortraitText[0], coords);

			// Draw second line of text
			VCR = PlayerOwner.VoiceReplicationInfo.GetChannelAt(PortraitPRI.ActiveChannel);
			if (VCR != none)
				PortraitText[1].text = "(" @ VCR.GetTitle() @ ")";
			else
				PortraitText[1].text = "( ? )";
			PortraitText[1].OffsetX = PortraitText[0].OffsetX;
			PortraitText[1].Tints[TeamIndex] = PortraitText[0].Tints[TeamIndex];
			DrawTextWidgetClipped(C, PortraitText[1], coords);

		}

		/*
		PortraitWidth = 0.125 * C.ClipY;
		PortraitHeight = 1.5 * PortraitWidth;
		C.DrawColor = WhiteColor;

		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Portrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);

		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.Font = GetFontSizeIndex(C,-2);
		PortraitString = PortraitPRI.PlayerName;
		C.StrLen(PortraitString,XL,YL);
		if ( XL > PortraitWidth )
		{
			C.Font = GetFontSizeIndex(C,-4);
			C.StrLen(PortraitString,XL,YL);
			if ( XL > PortraitWidth )
			{
				Abbrev = float(len(PortraitString)) * PortraitWidth/XL;
				PortraitString = left(PortraitString,Abbrev);
				C.StrLen(PortraitString,XL,YL);
			}
		}

		// Merge - Don't think we need this
//		C.DrawColor = C.static.MakeColor(160,160,160);
//		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
//		C.DrawTile( Material'XGameShaders.ModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

		C.DrawColor = WhiteColor;
		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		//C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxA1', 1.05 * PortraitWidth, 1.05*PortraitHeight);
		C.DrawTileStretched(Texture'InterfaceArt_tex.Menu.RODisplay', 1.05 * PortraitWidth, 1.05*PortraitHeight);

		C.DrawColor = WhiteColor;

		X = C.ClipY/256-PortraitWidth*PortraitX;
		Y = 0.5*(C.ClipY+PortraitHeight) + 0.06*PortraitHeight;
		C.SetPos( X + 0.5 * (PortraitWidth - XL), Y );

		if ( PortraitPRI != None )
		{
			if ( PortraitPRI.Team != None )
			{
				if ( PortraitPRI.Team.TeamIndex == 0 )
					C.DrawColor = RedColor;
				else
					C.DrawColor = TurqColor;
			}

			C.DrawText(PortraitString,true);

			if ( Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0
				&& PortraitPRI.ActiveChannel != -1
				&& PlayerOwner.VoiceReplicationInfo != None )
			{
				VCR = PlayerOwner.VoiceReplicationInfo.GetChannelAt(PortraitPRI.ActiveChannel);
				if ( VCR != None )
				{
					PortraitString = "(" @ VCR.GetTitle() @ ")";
					C.StrLen( PortraitString, XL, YL );
					if ( PortraitX == 0 )
						C.SetPos( Max(0, X + 0.5 * (PortraitWidth - XL)), Y + YL );
					else C.SetPos( X + 0.5 * (PortraitWidth - XL), Y + YL );
					C.DrawText( PortraitString );
				}
			}
		}*/
	}
	if( bShowWeaponInfo && (PawnOwner != None) && (PawnOwner.Weapon != None) )
		PawnOwner.Weapon.NewDrawWeaponInfo(C, 0.86 * C.ClipY);

	// Slow, for debugging only
	if( bDebugDriverCollision && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		DrawVehiclePointSphere();
	}

	// Slow, for debugging only
	if( bDebugPlayerCollision && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		DrawPointSphere();
	}

}

simulated function DrawPointSphere()
{
	local coords CO;
	local ROPawn P;
	local vector HeadLoc;
	local int i;

	foreach DynamicActors(class'ROPawn', P)
	{
		if (P != none /*&& P != PawnOwner*/)
		{
			for(i=0; i<P.Hitpoints.Length; i++)
			{
				if( P.Hitpoints[i].PointBone != '' )
				{
					CO = P.GetBoneCoords(P.Hitpoints[i].PointBone);
					HeadLoc = CO.Origin;// + (P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale * CO.XAxis);
					HeadLoc = HeadLoc + (P.Hitpoints[i].PointOffset >> P.GetBoneRotation(P.Hitpoints[i].PointBone)/*P.Rotation*/);
					//P.DrawDebugSphere(HeadLoc, P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale, 10, 0, 255, 0);
					if( i == MAINCOLLISIONINDEX )
					{
						DrawDebugCylinder(HeadLoc,CO.XAxis,CO.YAxis,CO.ZAxis,P.Hitpoints[i].PointRadius * P.Hitpoints[i].PointScale,P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale,10,0, 255, 0);
					}
					else
					{
						DrawDebugCylinder(HeadLoc,CO.ZAxis,CO.YAxis,CO.XAxis,P.Hitpoints[i].PointRadius * P.Hitpoints[i].PointScale,P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale,10,0, 255, 0);
					}
				}
			}
		}
	}
}


simulated function DrawVehiclePointSphere()
{

	local coords CO;
	local ROVehicle P;
	local ROVehicleWeapon V;
	local vector HeadLoc;
	local int i;

	foreach DynamicActors(class'ROVehicle', P)
	{
		if (P != None)
		{
			for(i=0; i<P.VehHitpoints.Length; i++)
			{
				if( P.VehHitpoints[i].PointBone != '' )
				{
					CO = P.GetBoneCoords(P.VehHitpoints[i].PointBone);
					HeadLoc = CO.Origin + (P.VehHitpoints[i].PointHeight * P.VehHitpoints[i].PointScale * CO.XAxis);
					HeadLoc = HeadLoc + (P.VehHitpoints[i].PointOffset >> P.Rotation);
					P.DrawDebugSphere(HeadLoc, P.VehHitpoints[i].PointRadius * P.VehHitpoints[i].PointScale, 10, 0, 255, 0);
				}
			}
		}
	}


	foreach DynamicActors(class'ROVehicleWeapon', V)
	{
		if (V != None)
		{
			for(i=0; i<V.VehHitpoints.Length; i++)
			{
				if( V.VehHitpoints[i].PointBone != '' )
				{
					CO = V.GetBoneCoords(V.VehHitpoints[i].PointBone);
					HeadLoc = CO.Origin + (V.VehHitpoints[i].PointHeight * V.VehHitpoints[i].PointScale * CO.XAxis);
					HeadLoc = HeadLoc + (V.VehHitpoints[i].PointOffset >> Rotator(CO.Xaxis));
					V.DrawDebugSphere(HeadLoc, V.VehHitpoints[i].PointRadius * V.VehHitpoints[i].PointScale, 10, 0, 255, 0);
				}
			}
		}
	}
}


// Draw a debugging cylinder
function DrawDebugCylinder(vector Base,vector X, vector Y,vector Z, FLOAT Radius,float HalfHeight,int NumSides, byte R, byte G, byte B)
{
	local float AngleDelta;
	local vector LastVertex, Vertex;
	local int SideIndex;
	//Color = Color.RenderColor();

	AngleDelta = 2.0f * PI / NumSides;
	LastVertex = Base + X * Radius;

	for(SideIndex = 0;SideIndex < NumSides;SideIndex++)
	{
		Vertex = Base + (X * Cos(AngleDelta * (SideIndex + 1)) + Y * Sin(AngleDelta * (SideIndex + 1))) * Radius;

		DrawDebugLine(LastVertex - Z * HalfHeight,Vertex - Z * HalfHeight,R,G,B);
		DrawDebugLine(LastVertex + Z * HalfHeight,Vertex + Z * HalfHeight,R,G,B);
		DrawDebugLine(LastVertex - Z * HalfHeight,LastVertex + Z * HalfHeight,R,G,B);

		LastVertex = Vertex;
	}
}

//-----------------------------------------------------------------------------
// DrawPlayerNames - Draws identify info for friendlies
//-----------------------------------------------------------------------------

function DrawPlayerNames(Canvas C)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewPos;
	local Vector ScreenPos, Loc, X, Y, Z, Dir;
	local float strX, strY;
	local string display;
	local float distance;

	if (PawnOwner == none || PawnOwner.Controller == None)
		return;

	ViewPos = PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	HitActor = trace(HitLocation,HitNormal,ViewPos+/*512*/1600*vector(PawnOwner.Controller.Rotation),ViewPos,true);

	if ( (Pawn(HitActor) != None) && (Pawn(HitActor).PlayerReplicationInfo != None)
		&& ( (PawnOwner.PlayerReplicationInfo.Team == None) || (PawnOwner.PlayerReplicationInfo.Team == Pawn(HitActor).PlayerReplicationInfo.Team)) )
	{
		if ( (NamedPlayer != HitActor) || (Level.TimeSeconds - NameTime > 0.5) )
		{
			//PlayerOwner.ReceiveLocalizedMessage(class'ROPlayerNameMessage',0,Pawn(HitActor).PlayerReplicationInfo);
			NameTime = Level.TimeSeconds;
		}

		NamedPlayer = Pawn(HitActor);
	}

	if (NamedPlayer != None && NamedPlayer.PlayerReplicationInfo != None && Level.TimeSeconds - NameTime < 1.0)
	{
		GetAxes(PlayerOwner.Rotation, X, Y, Z);
		Dir = Normal(NamedPlayer.Location - PawnOwner.Location);

		if (Dir dot X > 0.0)
		{
			C.DrawColor = GetTeamColor(NamedPlayer.PlayerReplicationInfo.Team.TeamIndex);
			C.Font = GetConsoleFont(C);

			if( ROPawn(PawnOwner)!= none && !NamedPlayer.IsA('Vehicle') && !ROPawn(PawnOwner).bUsedCarriedMGAmmo
				&& ROPawn(NamedPlayer).bWeaponCanBeResupplied && ROPawn(NamedPlayer).bWeaponNeedsResupply)
			{
				// Draw player name
				Loc = NamedPlayer.Location;
				Loc.Z += NamedPlayer.CollisionHeight + 8;
				ScreenPos = C.WorldToScreen(Loc);
				C.TextSize(NamedPlayer.PlayerReplicationInfo.PlayerName, strX, strY);
			    C.SetPos(ScreenPos.X - strX * 0.5, ScreenPos.Y - strY * 2.0);
				display = NamedPlayer.PlayerReplicationInfo.PlayerName;
				C.DrawTextClipped(display);

				distance = VSizeSquared(Loc - PawnOwner.Location);

				if( distance < 14400.0 ) // 2 Meters
				{
					ROPawn(PawnOwner).bCanResupply = true;
					display = class'ROTeamGame'.static.ParseLoadingHintNoColor(CanResupplyText, PlayerController(Owner));
				}
				else
				{
					if( ROPawn(PawnOwner).bCanResupply )
						ROPawn(PawnOwner).bCanResupply = false;
					display = NeedAmmoText;
				}

				// Draw text under player's name (need ammo or press x to resupply)
				C.DrawColor = WhiteColor;
			    C.SetPos(ScreenPos.X - strX * 0.5, ScreenPos.Y - strY * 1.0);
				C.DrawTextClipped(display);
			}
			else
			{
				if( ROPawn(PawnOwner)!= none && ROPawn(PawnOwner).bCanResupply )
					ROPawn(PawnOwner).bCanResupply = false;

				C.TextSize(NamedPlayer.PlayerReplicationInfo.PlayerName, strX, strY);
				Loc = NamedPlayer.Location;
				Loc.Z += NamedPlayer.CollisionHeight + 8;
				ScreenPos = C.WorldToScreen(Loc);
			    C.SetPos(ScreenPos.X - strX * 0.5, ScreenPos.Y - strY * 0.5);

				display = NamedPlayer.PlayerReplicationInfo.PlayerName;
				C.DrawTextClipped(display);
			}
		}
	}
}

// Draw actors on the hud to help debugging network relevancy in network games
function DrawNetworkActors(Canvas C)
{
	local Vector ScreenPos, X, Y, Z, Dir;
	local float strX, strY;
	local string display;
	local Actor TestActor;
	local int Pos;

	if (PawnOwner == none || PawnOwner.Controller == none )
		return;

    if( Level.NetMode != NM_Standalone && !ROGameReplicationInfo(PlayerOwner.GameReplicationInfo).bAllowNetDebug)
        return;

	foreach DynamicActors(class'Actor', TestActor)
	{
		if (TestActor != none && TestActor.IsA('Pawn'))
		{
		    GetAxes(PlayerOwner.Rotation, X, Y, Z);
            Dir = Normal(TestActor.Location - PawnOwner.Location);

    		if (Dir dot X > 0.0)
    		{
    			C.DrawColor = WhiteColor;
    			C.Font = GetConsoleFont(C);
    			display = ""$TestActor;

                // Remove the package name, if it exists
            	Pos = InStr(display, ".");
            	if ( Pos != -1 )
            		display = Mid(display, Pos + 1);

				C.TextSize(display, strX, strY);
				//Loc = NamedPlayer.Location;
				//Loc.Z += NamedPlayer.CollisionHeight + 8;
				ScreenPos = C.WorldToScreen(TestActor.Location);
			    C.SetPos(ScreenPos.X - strX * 0.5, ScreenPos.Y - strY * 0.5);

				//display = NamedPlayer.PlayerReplicationInfo.PlayerName;
				C.DrawTextClipped(display);
    		}
		}
	}
}


//-----------------------------------------------------------------------------
// DrawObjectives - Renders the objectives on the HUD similar to the scoreboard
//-----------------------------------------------------------------------------

simulated function DrawObjectives(Canvas C)
{
	local ROGameReplicationInfo GRI;
	local int i, OwnerTeam, objCount, SecondaryObjCount;
	local AbsoluteCoordsInfo MapCoords, subCoords;
	local bool bShowRally, bShowArtillery, bShowResupply, bShowArtyCoords,
		bShowNeutralObj, bShowMGResupplyRequest, bShowHelpRequest, bShowAttackDefendRequest,
        bShowArtyStrike, bShowDestroyableItems, bShowDestroyedItems, bShowVehicleResupply,
		bHasSecondaryObjectives;
	local float myMapScale, XL, YL, YL_one, time;
	local vector temp, MapCenter;
	local SpriteWidget  widget;
	local Actor A;
	local ROPlayer player;
	local Controller P;
	// PSYONIX: DEBUG
	local Vehicle V;
	local float pawnRotation;
	local ROVehicleWeaponPawn myVehicleWeaponPawn;
	local float X, Y, strX, strY;
	local string S;
	// Net debug
	local Actor NetActor;
	local Pawn NetPawn;
	local ROPawn ROP;
	local int Pos;
	// AT Gun
	local bool bShowATGun;

	// Get GRI
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if (GRI == none)
		return;

    // Update time
	if (GRI != None)
	{
		if (!GRI.bMatchHasBegun)
			CurrentTime = FMax(0.0, GRI.RoundStartTime + GRI.PreStartTime - GRI.ElapsedTime);
		else
			CurrentTime = FMax(0.0, GRI.RoundStartTime + GRI.RoundDuration - GRI.ElapsedTime);
	}

	// Get player
	player = ROPlayer(PlayerOwner);

	// Get player team -- if none, we won't draw team-specific information on the map
	if (PlayerOwner != none )
		OwnerTeam = PlayerOwner.GetTeamNum();
	else
		OwnerTeam = 255;

	// Set map coords based on resolution
	// We want to keep a 4:3 aspect ratio for the map
	MapCoords.height = C.ClipY * 0.9;
	MapCoords.PosY = C.ClipY * 0.05;
	MapCoords.width = MapCoords.height * 4 / 3;
	MapCoords.PosX = (C.ClipX - MapCoords.width) / 2;

	// Calculate map offset (for animation)
	if (bAnimateMapIn)
	{
		AnimateMapCurrentPosition -= (Level.TimeSeconds - hudLastRenderTime) / AnimateMapSpeed;
		if (AnimateMapCurrentPosition <= 0)
		{
			AnimateMapCurrentPosition = 0;
			bAnimateMapIn = false;
		}
	}
	else if (bAnimateMapOut)
	{
		AnimateMapCurrentPosition += (Level.TimeSeconds - hudLastRenderTime) / AnimateMapSpeed;
		if (AnimateMapCurrentPosition >= default.AnimateMapCurrentPosition)
		{
			AnimateMapCurrentPosition = default.AnimateMapCurrentPosition;
			bAnimateMapOut = false;
		}
	}
	MapCoords.PosX += C.ClipX * AnimateMapCurrentPosition;

	// Draw map background
	DrawSpriteWidgetClipped(C, MapBackground, MapCoords, true);

	// Calculate absolute coordinates of level map
	GetAbsoluteCoordinatesAlt(MapCoords, MapLegendImageCoords, subCoords);
	//subCoords.PosX = MapCoords.PosX + MapCoords.width * MapLevelBounds.PosX;
	//subCoords.PosY = MapCoords.PosY + MapCoords.height * MapLevelBounds.PosY;
	//subCoords.height = MapCoords.height * MapLevelBounds.TextureScale;
	//subCoords.width = subCoords.height; // We want to show a square map, so force coords to be square

	// Save coordinates for use in menu page
	MapLevelImageCoordinates = subCoords;

	// Draw coordinates text on sides of the map
	for (i = 0; i < 9; i++)
	{
		MapCoordTextXWidget.PosX = (float(i) + 0.5) / 9;
		MapCoordTextXWidget.text = MapCoordTextX[i];
		DrawTextWidgetClipped(C, MapCoordTextXWidget, subCoords);

		MapCoordTextYWidget.PosY = MapCoordTextXWidget.PosX;
		MapCoordTextYWidget.text = MapCoordTextY[i];
		DrawTextWidgetClipped(C, MapCoordTextYWidget, subCoords);
	}

	// Draw level map
	MapLevelImage.WidgetTexture = GRI.MapImage;
	DrawSpriteWidgetClipped(C, MapLevelImage, subCoords, true);

	// Calculate level map constants
	temp = GRI.SouthWestBounds - GRI.NorthEastBounds;
	MapCenter =  temp/2 + GRI.NorthEastBounds;
	myMapScale = abs(temp.x);
	if (myMapScale ~= 0)
		myMapScale = 1; // just so we never get divisions by 0

	// Set the font to be used to draw objective text
	C.Font = GetSmallMenuFont(C);

	// Draw resupply areas
    for (i = 0; i < ArrayCount(GRI.ResupplyAreas); i++)
	{
		if (!GRI.ResupplyAreas[i].bActive ||
            (GRI.ResupplyAreas[i].Team != OwnerTeam && GRI.ResupplyAreas[i].Team != NEUTRAL_TEAM_INDEX))
        {
			continue;
		}

        if (GRI.ResupplyAreas[i].ResupplyType == 1)
        {
            // Tank resupply icon
    		bShowVehicleResupply = true;
    		DrawIconOnMap(C, subCoords, MapIconVehicleResupply, myMapScale, GRI.ResupplyAreas[i].ResupplyVolumeLocation, MapCenter);
        }
        else
        {
            // Player resupply icon
    		bShowResupply = true;
    		DrawIconOnMap(C, subCoords, MapIconResupply, myMapScale, GRI.ResupplyAreas[i].ResupplyVolumeLocation, MapCenter);
		}
	}

	// Draw AT-Guns
    for (i = 0; i < ArrayCount(GRI.ATCannons); i++)
	{
		if ( GRI.ATCannons[i].ATCannonLocation != vect(0,0,0) && GRI.ATCannons[i].Team == PlayerOwner.GetTeamNum())
        {
            if( GRI.ATCannons[i].ATCannonLocation.Z > 0 )  // ATCannon is active is the Z location is greater than 0
            {
                bShowATGun = true;

                // AT-Gun icon
                MapIconATGun.Tints[0] = WhiteColor;
                MapIconATGun.Tints[1] = WhiteColor;
                DrawIconOnMap(C, subCoords, MapIconATGun, myMapScale, GRI.ATCannons[i].ATCannonLocation, MapCenter);
            }
//            else
//            {
//    			MapIconATGun.Tints[0] = GrayColor;
//                MapIconATGun.Tints[1] = GrayColor;
//    			MapIconATGun.Tints[0].A = 125;
//                MapIconATGun.Tints[1].A = 125;
//            }
        }
	}

	if (Level.NetMode == NM_Standalone && bShowDebugInfoOnMap)
	{
		// PSYONIX: DEBUG - Show all vehicles on map who have no driver
		foreach DynamicActors(Class'Vehicle',V)
		{
				widget = MapIconRally[V.GetTeamNum()];
				widget.TextureScale = 0.04f;
				if (V.health <= 0)
					widget.RenderStyle = STY_Translucent;
				else
					widget.RenderStyle = STY_Normal;
				// Empty Vehicle
				if (Bot(V.Controller) == none && (ROWheeledVehicle(V) != none && V.NumPassengers() == 0) )
					DrawDebugIconOnMap(C, subCoords, widget, myMapScale, V.Location, MapCenter, "");
				// VehicleWeapon
//				else if (Bot(V.Controller) != none && VehicleWeaponPawn(V) != none)
//					DrawDebugIconOnMap(C, subCoords, widget, myMapScale, V.Location + Vect(0,25,0), MapCenter, Left(Bot(V.Controller).Squad.GetOrders(),1)$" P");
				// Vehicle
				else if ( VehicleWeaponPawn(V) == none && V.Controller != None )
					DrawDebugIconOnMap(C, subCoords, widget, myMapScale, V.Location, MapCenter, Left(Bot(V.Controller).Squad.GetOrders(),1)$" "$V.NumPassengers());
		}
		// PSYONIX: DEBUG - Show all players on map and indicate orders
		for (P = Level.ControllerList; P != None; P = P.NextController)
		{
			if (Bot(P) != None && P.Pawn != None && ROVehicle(P.Pawn) == None)
			{
				widget = MapIconTeam[P.GetTeamNum()];
				widget.TextureScale = 0.025f;

				DrawDebugIconOnMap(C, subCoords, widget, myMapScale, P.Pawn.Location, MapCenter, Left(Bot(P).Squad.GetOrders(),1));
			}
		}
	}

	if ((Level.NetMode == NM_Standalone || GRI.bAllowNetDebug) && bShowRelevancyDebugOnMap)
	{
        if( NetDebugMode == ND_All )
        {
    		foreach DynamicActors(Class'Actor',NetActor)
    		{

                if(!NetActor.bStatic && !NetActor.bNoDelete)
                {
            		widget = MapIconNeutral;
    				widget.TextureScale = 0.04f;
    				widget.RenderStyle = STY_Normal;
    				DrawDebugIconOnMap(C, subCoords, widget, myMapScale, NetActor.Location, MapCenter, "");
				}
    		}
        }
        else if( NetDebugMode == ND_VehiclesOnly )
        {
    		// PSYONIX: DEBUG - Show all vehicles on map who have no driver
    		foreach DynamicActors(Class'Vehicle',V)
    		{
				widget = MapIconRally[V.GetTeamNum()];
				widget.TextureScale = 0.04f;
				widget.RenderStyle = STY_Normal;
				if (ROWheeledVehicle(V) != none)
					DrawDebugIconOnMap(C, subCoords, widget, myMapScale, V.Location, MapCenter, "");
    		}
        }
        else if( NetDebugMode == ND_PlayersOnly )
        {
    		foreach DynamicActors(Class'ROPawn',ROP)
    		{
				widget = MapIconTeam[ROP.GetTeamNum()];
				widget.TextureScale = 0.04f;
				widget.RenderStyle = STY_Normal;
				DrawDebugIconOnMap(C, subCoords, widget, myMapScale, ROP.Location, MapCenter, "");
    		}
        }
        else if( NetDebugMode == ND_PawnsOnly )
        {
    		foreach DynamicActors(Class'Pawn',NetPawn)
    		{
				if( Vehicle(NetPawn) != none)
				{
    				widget = MapIconRally[V.GetTeamNum()];
				}
				else if( ROPawn(NetPawn) != none )
				{
				    widget = MapIconTeam[NetPawn.GetTeamNum()];
				}
				else
				{
				    widget = MapIconNeutral;
				}

				widget.TextureScale = 0.04f;
				widget.RenderStyle = STY_Normal;
				DrawDebugIconOnMap(C, subCoords, widget, myMapScale, NetPawn.Location, MapCenter, "");
    		}
        }
        if( NetDebugMode == ND_AllWithText )
        {
    		foreach DynamicActors(Class'Actor',NetActor)
    		{

                if(!NetActor.bStatic && !NetActor.bNoDelete)
                {
            		widget = MapIconNeutral;
    				widget.TextureScale = 0.04f;
    				widget.RenderStyle = STY_Normal;

        			S = ""$NetActor;

                    // Remove the package name, if it exists
                	Pos = InStr(S, ".");
                	if ( Pos != -1 )
                		S = Mid(S, Pos + 1);

    				DrawDebugIconOnMap(C, subCoords, widget, myMapScale, NetActor.Location, MapCenter, S);
				}
    		}
        }
	}

	if (player != none)
	{
		// Draw the marked arty strike
		temp = player.SavedArtilleryCoords;
		if (temp != vect(0,0,0))
		{
		    bShowArtyCoords = true;
		    widget = MapIconArtyStrike;
		    widget.Tints[0].A = 125; widget.Tints[1].A = 125;
			DrawIconOnMap(C, subCoords, widget, myMapScale, temp, MapCenter);
		}

		// Draw the destroyable/destroyed targets
	    if (player.Destroyables.length != 0)
	    {
			for (i = 0; i < player.Destroyables.length; i++)
			{
				//if (player.Destroyables[i].GetStateName() == 'Broken')
				if (player.Destroyables[i].bHidden || player.Destroyables[i].bDamaged)
				{
					DrawIconOnMap(C, subCoords, MapIconDestroyedItem, myMapScale,
						player.Destroyables[i].Location, MapCenter);
					bShowDestroyedItems = true;
				}
				else
				{
					DrawIconOnMap(C, subCoords, MapIconDestroyableItem, myMapScale,
						player.Destroyables[i].Location, MapCenter);
					bShowDestroyableItems = true;
				}
			}
	    }
	}

	if ( OwnerTeam != 255 )
	{
	    // Draw the in-progress arty strikes
	    if (OwnerTeam == AXIS_TEAM_INDEX || OwnerTeam == ALLIES_TEAM_INDEX)
	       if (GRI.ArtyStrikeLocation[OwnerTeam] != vect(0,0,0))
	       {
	           DrawIconOnMap(C, subCoords, MapIconArtyStrike, myMapScale, GRI.ArtyStrikeLocation[OwnerTeam], MapCenter);
	           bShowArtyStrike = true;
	       }

		// Draw the rally points
	 	for (i = 0; i < ArrayCount(GRI.AxisRallyPoints); i++)
		{
			if ( OwnerTeam == AXIS_TEAM_INDEX )
				temp = GRI.AxisRallyPoints[i].RallyPointLocation;
			else if ( OwnerTeam == ALLIES_TEAM_INDEX )
				temp = GRI.AlliedRallyPoints[i].RallyPointLocation;

			// Draw the marked rally point
			if (temp != vect(0,0,0))
			{
			    bShowRally = true;
			    DrawIconOnMap(C, subCoords, MapIconRally[OwnerTeam], myMapScale, temp, MapCenter);
		    }
		}

		// Draw Artillery Radio Icons
		if ( OwnerTeam == AXIS_TEAM_INDEX )
		{
		    for ( i = 0; i < ArrayCount(GRI.AxisRadios); i++)
			{
				if(GRI.AxisRadios[i] == none)
					continue;

			    bShowArtillery = true;
		        DrawIconOnMap(C, subCoords, MapIconRadio, myMapScale, GRI.AxisRadios[i].Location, MapCenter);
			}
		}
		else if ( OwnerTeam == ALLIES_TEAM_INDEX )
		{
			for ( i = 0; i < ArrayCount(GRI.AlliedRadios); i++)
			{
				if(GRI.AlliedRadios[i] == none)
					continue;

			    bShowArtillery = true;
		        DrawIconOnMap(C, subCoords, MapIconRadio, myMapScale, GRI.AlliedRadios[i].Location, MapCenter);
			}
		}

		// Draw help requests
		if ( OwnerTeam == AXIS_TEAM_INDEX )
		{
		    for ( i = 0; i < ArrayCount(GRI.AxisHelpRequests); i++)
			{
				if (GRI.AxisHelpRequests[i].requestType == 255)
					continue;

				switch (GRI.AxisHelpRequests[i].requestType)
				{
					case 0: // help request at objective
						bShowHelpRequest = true;
						widget = MapIconHelpRequest;
						widget.Tints[0].A = 125; widget.Tints[1].A = 125;
						DrawIconOnMap(C, subCoords, widget, myMapScale,
							GRI.Objectives[GRI.AxisHelpRequests[i].objectiveID].Location, MapCenter);
						break;

					case 1: // attack request
					case 2: // defend request
						bShowAttackDefendRequest = true;
						DrawIconOnMap(C, subCoords, MapIconAttackDefendRequest, myMapScale,
							GRI.Objectives[GRI.AxisHelpRequests[i].objectiveID].Location, MapCenter);
						break;

					case 3: // mg resupply requests
						bShowMGResupplyRequest = true;
						DrawIconOnMap(C, subCoords, MapIconMGResupplyRequest[AXIS_TEAM_INDEX], myMapScale, GRI.AxisHelpRequestsLocs[i], MapCenter);
						break;

					case 4: // help request at coords
						bShowHelpRequest = true;
						DrawIconOnMap(C, subCoords, MapIconHelpRequest, myMapScale, GRI.AxisHelpRequestsLocs[i], MapCenter);
						break;

					default:
						log("Unknown requestType found in AxisHelpRequests[i]: " $ GRI.AxisHelpRequests[i].requestType);
				}
			}
		}
		else if ( OwnerTeam == ALLIES_TEAM_INDEX )
		{
		    for ( i = 0; i < ArrayCount(GRI.AlliedHelpRequests); i++)
			{
				if(GRI.AlliedHelpRequests[i].requestType == 255)
					continue;

				switch (GRI.AlliedHelpRequests[i].requestType)
				{
					case 0: // help request at objective
						bShowHelpRequest = true;
						widget = MapIconHelpRequest;
						widget.Tints[0].A = 125; widget.Tints[1].A = 125;
						DrawIconOnMap(C, subCoords, widget, myMapScale,
							GRI.Objectives[GRI.AlliedHelpRequests[i].objectiveID].Location, MapCenter);
						break;

					case 1: // attack request
					case 2: // defend request
						bShowAttackDefendRequest = true;
						DrawIconOnMap(C, subCoords, MapIconAttackDefendRequest, myMapScale,
							GRI.Objectives[GRI.AlliedHelpRequests[i].objectiveID].Location, MapCenter);
						break;

					case 3: // mg resupply requests
						bShowMGResupplyRequest = true;
						DrawIconOnMap(C, subCoords, MapIconMGResupplyRequest[ALLIES_TEAM_INDEX], myMapScale, GRI.AlliedHelpRequestsLocs[i], MapCenter);
						break;

					case 4: // help request at coords
						bShowHelpRequest = true;
						DrawIconOnMap(C, subCoords, MapIconHelpRequest, myMapScale, GRI.AlliedHelpRequestsLocs[i], MapCenter);
						break;

					default:
						log("Unknown requestType found in AlliedHelpRequests[i]: " $ GRI.AlliedHelpRequests[i].requestType);
				}
			}
		}
	}

	// Draw objectives
  	for (i = 0; i < ArrayCount(GRI.Objectives); i++)
	{
		if (GRI.Objectives[i] == None)
			continue;

		// Setup icon info
		if (GRI.Objectives[i].ObjState == OBJ_Axis)
			widget = MapIconTeam[AXIS_TEAM_INDEX];
		else if (GRI.Objectives[i].ObjState == OBJ_Allies)
			widget = MapIconTeam[ALLIES_TEAM_INDEX];
		else
		{
		    bShowNeutralObj = true;
			widget = MapIconNeutral;
		}
		if (!GRI.Objectives[i].bActive)
		{
			widget.Tints[0] = GrayColor; widget.Tints[1] = GrayColor;
			widget.Tints[0].A = 125; widget.Tints[1].A = 125;
		}
		else
		{
			widget.Tints[0] = WhiteColor; widget.Tints[1] = WhiteColor;
		}

		// Draw flashing icon if objective is disputed
		if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
		{
			if (GRI.Objectives[i].CompressedCapProgress == 1 || GRI.Objectives[i].CompressedCapProgress == 2)
                DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 2, GRI.Objectives[i].ObjName, GRI, i);
			else if (GRI.Objectives[i].CompressedCapProgress == 3 || GRI.Objectives[i].CompressedCapProgress == 4)
                DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 3, GRI.Objectives[i].ObjName, GRI, i);
			else
                DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 1, GRI.Objectives[i].ObjName, GRI, i);
		}
		else
            DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 1, GRI.Objectives[i].ObjName, GRI, i);


		// If the objective isn't completely captured, overlay a flashing icon from other team
		if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
		{
			if (GRI.Objectives[i].CurrentCapTeam == ALLIES_TEAM_INDEX)
				widget = MapIconDispute[ALLIES_TEAM_INDEX];
			else
				widget = MapIconDispute[AXIS_TEAM_INDEX];
			if (GRI.Objectives[i].CompressedCapProgress == 1 || GRI.Objectives[i].CompressedCapProgress == 2)
				DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 4);
			else if (GRI.Objectives[i].CompressedCapProgress == 3 || GRI.Objectives[i].CompressedCapProgress == 4)
				DrawIconOnMap(C, subCoords, widget, myMapScale, GRI.Objectives[i].Location, MapCenter, 5);
		}
	}

	// Get player actor
	if (PawnOwner != None)
		A = PawnOwner;
	else if (PlayerOwner.IsInState('Spectating'))
		A = PlayerOwner;
	else if (PlayerOwner.Pawn != None)
		A = PlayerOwner.Pawn;

	// Fix for frelled rotation on weapon pawns
	myVehicleWeaponPawn = ROVehicleWeaponPawn(A);
	if (myVehicleWeaponPawn != none)
	{
	   player = ROPlayer(myVehicleWeaponPawn.Controller);
	   if (player != none && myVehicleWeaponPawn.VehicleBase != none)
	       pawnRotation = -player.CalcViewRotation.Yaw;
	   else if (myVehicleWeaponPawn.VehicleBase != none)
	       pawnRotation = -myVehicleWeaponPawn.VehicleBase.Rotation.Yaw;
	   else
	       pawnRotation = -A.Rotation.Yaw;
	}
	else if (A != none)
	   pawnRotation = -A.Rotation.Yaw;

	// Draw player icon
	if (A != none)
	{
		// Set proper icon rotation
		if ( GRI.OverheadOffset == 90 )
		 	TexRotator(FinalBlend(MapPlayerIcon.WidgetTexture).Material).Rotation.Yaw = pawnRotation - 32768;
		else if( GRI.OverheadOffset == 180 )
		 	TexRotator(FinalBlend(MapPlayerIcon.WidgetTexture).Material).Rotation.Yaw = pawnRotation - 49152;
		else if( GRI.OverheadOffset == 270 )
		 	TexRotator(FinalBlend(MapPlayerIcon.WidgetTexture).Material).Rotation.Yaw = pawnRotation;
		else
		 	TexRotator(FinalBlend(MapPlayerIcon.WidgetTexture).Material).Rotation.Yaw = pawnRotation - 16384;

		// Draw the player icon
		DrawIconOnMap(C, subCoords, MapPlayerIcon, myMapScale, A.Location, MapCenter);
	}

	// Overhead map debugging
	if (Level.NetMode == NM_Standalone && ROTeamGame(Level.Game).LevelInfo.bDebugOverhead)
	{
		DrawIconOnMap(C, subCoords, MapIconTeam[ALLIES_TEAM_INDEX], myMapScale, GRI.NorthEastBounds, MapCenter);
		DrawIconOnMap(C, subCoords, MapIconTeam[AXIS_TEAM_INDEX], myMapScale, GRI.SouthWestBounds, MapCenter);
	}

	// Draw timer
	DrawTextWidgetClipped(C, MapTimerTitle, MapCoords, XL, YL, YL_one);

	// Calculate seconds & minutes
	time = CurrentTime;
	MapTimerTexts[3].text = string(int(time % 10));
	time /= 10;
	MapTimerTexts[2].text = string(int(time % 6));
	time /= 6;
	MapTimerTexts[1].text = string(int(time % 10));
	time /= 10;
	MapTimerTexts[0].text = string(int(time));

	// Draw timer values
	C.Font = GetFontSizeIndex(C, -2);
	for (i = 0; i < 4; i++)
	   DrawTextWidgetClipped(C, MapTimerTexts[i], MapCoords, XL, YL, YL_one);
	C.Font = GetSmallMenuFont(C);

	// Calc legend coords
	GetAbsoluteCoordinatesAlt(MapCoords, MapLegendCoords, subCoords);

	// Draw legend background
	//DrawSpriteWidgetClipped(C, MapLegend, subCoords, true);

	// Draw legend title
	DrawTextWidgetClipped(C, MapLegendTitle, subCoords, XL, YL, YL_one);

	// Set initial icon + text values
	//MapLegendIcons.OffsetY = 0;
	//MapLegendTexts.OffsetY = 0;

	// Draw legend elements
	LegendItemsIndex = 2; // no item at position #0 and #1 (reserved for title)
	DrawLegendElement(C, subCoords, MapIconTeam[AXIS_TEAM_INDEX], LegendAxisObjectiveText);
	DrawLegendElement(C, subCoords, MapIconTeam[ALLIES_TEAM_INDEX], LegendAlliesObjectiveText);
	if (bShowNeutralObj || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconNeutral, LegendNeutralObjectiveText);
	if (bShowArtillery || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconRadio, LegendArtilleryRadioText);
	if (bShowResupply || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconResupply, LegendResupplyAreaText);
    if (bShowVehicleResupply)
        DrawLegendElement(C, subCoords, MapIconVehicleResupply, LegendResupplyAreaText);
	if (bShowRally || bShowAllItemsInMapLegend)
		if (OwnerTeam != 255)
			DrawLegendElement(C, subCoords, MapIconRally[OwnerTeam], LegendRallyPointText);
	if (bShowArtyCoords || bShowAllItemsInMapLegend)
	{
		widget = MapIconArtyStrike;
		widget.Tints[TeamIndex].A = 64;
		DrawLegendElement(C, subCoords, widget, LegendSavedArtilleryText);
		widget.Tints[TeamIndex].A = 255;
	}
	if (bShowArtyStrike || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconArtyStrike, LegendArtyStrikeText);
	if (bShowMGResupplyRequest || bShowAllItemsInMapLegend)
		if (OwnerTeam != 255)
			DrawLegendElement(C, subCoords, MapIconMGResupplyRequest[OwnerTeam], LegendMGResupplyText);
	if (bShowHelpRequest || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconHelpRequest, LegendHelpRequestText);
	if (bShowAttackDefendRequest || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconAttackDefendRequest, LegendOrderTargetText);
	if (bShowDestroyableItems || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconDestroyableItem, LegendDestroyableItemText);
	if (bShowDestroyedItems || bShowAllItemsInMapLegend)
		DrawLegendElement(C, subCoords, MapIconDestroyedItem, LegendDestroyedItemText);
	if (bShowATGun)
		DrawLegendElement(C, subCoords, MapIconATGun, LegendATGunText);

	// Calc objective text box coords
	GetAbsoluteCoordinatesAlt(MapCoords, MapObjectivesCoords, subCoords);

	// See if there are any secondary objectives
	for (i = 0; i < ArrayCount(GRI.Objectives); i++)
	{
		if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive )
			continue;

		if( !GRI.Objectives[i].bRequired )
		{
			bHasSecondaryObjectives=true;
			break;
		}
	}

	// Draw objective text box header
	if( bHasSecondaryObjectives )
	{
		DrawTextWidgetClipped(C, MapRequiredObjectivesTitle, subCoords, XL, YL, YL_one);
	}
	else
	{
		DrawTextWidgetClipped(C, MapObjectivesTitle, subCoords, XL, YL, YL_one);
	}
	MapObjectivesTexts.OffsetY = 0;

	// Draw objective texts
	objCount = 1;
	C.Font = GetSmallMenuFont(C);
	for (i = 0; i < ArrayCount(GRI.Objectives); i++)
	{
		if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive || !GRI.Objectives[i].bRequired)
			continue;

		if (GRI.Objectives[i].ObjState != OwnerTeam)
			MapObjectivesTexts.text = objCount $ ". " $ GRI.Objectives[i].AttackerDescription;
		else
			MapObjectivesTexts.text = objCount $ ". " $ GRI.Objectives[i].DefenderDescription;

		DrawTextWidgetClipped(C, MapObjectivesTexts, subCoords, XL, YL, YL_one);
		MapObjectivesTexts.OffsetY += YL + YL_one * 0.5;
		objCount++;
	}

	if( bHasSecondaryObjectives )
	{
		MapObjectivesTexts.OffsetY += YL + YL_one * 0.5;
		MapObjectivesTexts.OffsetY += YL + YL_one * 0.5;
		MapSecondaryObjectivesTitle.OffsetY = MapObjectivesTexts.OffsetY;
		DrawTextWidgetClipped(C, MapSecondaryObjectivesTitle, subCoords, XL, YL, YL_one);

		for (i = 0; i < ArrayCount(GRI.Objectives); i++)
		{
			if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive|| GRI.Objectives[i].bRequired)
				continue;

			if (GRI.Objectives[i].ObjState != OwnerTeam)
				MapObjectivesTexts.text = (SecondaryObjCount + 1) $ ". " $ GRI.Objectives[i].AttackerDescription;
			else
				MapObjectivesTexts.text = (SecondaryObjCount + 1) $ ". " $ GRI.Objectives[i].DefenderDescription;

			DrawTextWidgetClipped(C, MapObjectivesTexts, subCoords, XL, YL, YL_one);
			MapObjectivesTexts.OffsetY += YL + YL_one * 0.5;
			SecondaryObjCount++;
		}
	}

	// Draw 'objectives missing' if no objectives found -- for debug only
	if (objCount == 1)
	{
		MapObjectivesTexts.text = "(OBJECTIVES MISSING)";
		DrawTextWidgetClipped(C, MapObjectivesTexts, subCoords, XL, YL, YL_one);
	}

	// Draw timer
	//DrawSpriteWidgetClipped(C, ClockBase, MapCoords, true, XL, YL, false, true);
	//DrawSpriteWidgetClipped(C, ClockHand, MapCoords, true, XL, YL, false, true);

	// Draw the instruction header
	S = class'ROTeamGame'.static.ParseLoadingHintNoColor(SituationMapInstructionsText, PlayerController(Owner));
	C.DrawColor = WhiteColor;
	C.Font = GetLargeMenuFont(C);

	X = C.ClipX * 0.5;
	Y = C.ClipY * 0.01;

	C.TextSize(S, strX, strY);
	C.SetPos(X - strX / 2, Y);
	C.DrawTextClipped(S);
}

// Draw debugging info on the overhead map
function DrawDebugIconOnMap(Canvas C, AbsoluteCoordsInfo levelCoords, SpriteWidget icon, float myMapScale, vector location, vector MapCenter, optional string title)
{
    local vector HUDLocation;
    local float XL, YL;
    local SpriteWidget myIcon;

    // Calculate proper position
    HUDLocation = location - MapCenter;
    HUDLocation.Z = 0;
    HUDLocation = GetAdjustedHudLocation(HUDLocation);

    myIcon = icon;

    myIcon.PosX = HUDLocation.X / myMapScale + 0.5;
    myIcon.PosY = HUDLocation.Y / myMapScale + 0.5;

    // Bound the values between 0 and 1
    myIcon.PosX = fmax(0.0, fmin(1.0, myIcon.PosX));
    myIcon.PosY = fmax(0.0, fmin(1.0, myIcon.PosY));

    // Draw icon!
    DrawSpriteWidgetClipped(C, myIcon, levelCoords, true, XL, YL, true);

    if (title != "")
    {
        // Setup text info
        MapTexts.text = title;
        MapTexts.PosX = myIcon.PosX;
        MapTexts.PosY = myIcon.PosY;
        MapTexts.OffsetY = YL * 0.6;

        // Draw text
        DrawTextWidgetClipped(C, MapTexts, levelCoords);
    }
}

simulated function DrawRoute()
{
    local Controller C;
    local Bot B, M;
    local vector End;

	Super.DrawRoute();

	// PSYONIX: draw the squads
	C = Pawn(PlayerOwner.ViewTarget).Controller;
    if ( C == None )
        return;
    B = Bot(C);

    if ( B == None )
        return;

    if (B.Squad.SquadLeader.Pawn == None)
    	return;

    End = B.Squad.SquadLeader.Pawn.Location;

    for (M=B.Squad.SquadMembers; M!=None; M=M.NextSquadMember)
    {
    	if (M.Pawn != None && M != M.Squad.SquadLeader)
			Draw3DLine(M.Pawn.Location + (M.Pawn.BaseEyeHeight * vect(0,0,1)),End,Class'Canvas'.Static.MakeColor(70,131,244));
	}
}

// valid flash modes:
// 0 - just draw using assigned texture
// 1 - draw using normal map icon texture
// 2 - draw using flashing map icon texture
// 3 - draw using fast-flashing map icon texture
// 4 - draw using flashing map icon texture (out of phase)
// 5 - draw using fast-flashing map icon texture (out of phase)
function DrawIconOnMap(Canvas C, AbsoluteCoordsInfo levelCoords, SpriteWidget icon, float myMapScale, vector location, vector MapCenter, optional int flashMode, optional string title, optional ROGameReplicationInfo GRI, optional int objective_index)
{
	local vector HUDLocation;
    local float XL, YL, YL_one;
	local SpriteWidget myIcon;
    local FloatBox label_coords;

	// Calculate proper position
	HUDLocation = location - MapCenter;
	HUDLocation.Z = 0;
	HUDLocation = GetAdjustedHudLocation(HUDLocation);

	myIcon = icon;

	myIcon.PosX = HUDLocation.X / myMapScale + 0.5;
	myIcon.PosY = HUDLocation.Y / myMapScale + 0.5;

	// Bound the values between 0 and 1
	myIcon.PosX = fmax(0.0, fmin(1.0, myIcon.PosX));
	myIcon.PosY = fmax(0.0, fmin(1.0, myIcon.PosY));

	// Set flashing texture if needed

	if (flashMode != 0)
	{
		if (flashMode == 2)
			myIcon.WidgetTexture = MapIconsFlash;
		else if (flashMode == 3)
			myIcon.WidgetTexture = MapIconsFastFlash;
		else if (flashMode == 4)
			myIcon.WidgetTexture = MapIconsAltFlash;
		else if (flashMode == 5)
			myIcon.WidgetTexture = MapIconsAltFastFlash;

		//else if (flashMode == 1)
		//  myIcon.WidgetTexture = icon.WidgetTexture; // not needed
	}

	// Draw icon!
	DrawSpriteWidgetClipped(C, myIcon, levelCoords, true, XL, YL, true);

    if (title != "" && !GRI.Objectives[objective_index].bDoNotDisplayTitleOnSituationMap)
	{
		// Setup text info
		MapTexts.text = title;
		MapTexts.PosX = myIcon.PosX;
		MapTexts.PosY = myIcon.PosY;
		MapTexts.Tints[TeamIndex].A = myIcon.Tints[TeamIndex].A;
        MapTexts.OffsetY = YL * 0.3;

        // Fake render to get desired label pos
        DrawTextWidgetClipped(C, MapTexts, levelCoords, XL, YL, YL_one, true);

        // Update objective floatbox info with desired coords
        label_coords.X1 = levelCoords.width * MapTexts.PosX - XL/2;
        label_coords.Y1 = levelCoords.height * MapTexts.PosY;
        label_coords.X2 = label_coords.X1 + XL;
        label_coords.Y2 = label_coords.Y1 + YL;

        // Iterate through objectives list and check if we should offset label
        UpdateMapIconLabelCoords(label_coords, GRI, objective_index);

        // Update Y offset
        MapTexts.OffsetY += GRI.Objectives[objective_index].LabelCoords.Y1 - label_coords.Y1;

		// Draw text
		DrawTextWidgetClipped(C, MapTexts, levelCoords);
	}
}

simulated function UpdateMapIconLabelCoords(FloatBox label_coords, ROGameReplicationInfo GRI, int current_obj)
{
    local int i, count;
    local float new_y;

    // Do not update label coords if it's disabled in the objective
    if (GRI.Objectives[current_obj].bDoNotUseLabelShiftingOnSituationMap)
    {
        GRI.Objectives[current_obj].LabelCoords = label_coords;
        return;
    }

    if (current_obj == 0)
    {
        // Set label position to be same as tested position
        GRI.Objectives[0].LabelCoords = label_coords;

        return;
    }

    for (i = 0; i < current_obj; i++)
    {
        // Check if there's overlap in the X axis
        if (!(label_coords.X2 <= GRI.Objectives[i].LabelCoords.X1 ||
              label_coords.X1 >= GRI.Objectives[i].LabelCoords.X2))
        {
            // There's overlap! Check if there's overlap in the Y axis
            if (!(label_coords.Y2 <= GRI.Objectives[i].LabelCoords.Y1 ||
                  label_coords.Y1 >= GRI.Objectives[i].LabelCoords.Y2))
            {
                // There's overlap on both axis: the label overlaps.
                // Update the position of the label
                new_y = GRI.Objectives[i].LabelCoords.Y2 - (label_coords.Y2 - label_coords.Y1) * 0.00;
                label_coords.Y2 = new_y + label_coords.Y2 - label_coords.Y1;
                label_coords.Y1 = new_y;

                //if (i != 0)
                    i = -1; // This is to force rechecking of all possible overlaps
                            // to ensure that no other label overlaps with this

                // Safety
                count++;
                if (count > current_obj * 5)
                    break;
            }
        }

    }

    // Set new label position
    GRI.Objectives[current_obj].LabelCoords = label_coords;
}

simulated function DrawLegendElement(Canvas C, AbsoluteCoordsInfo coords, SpriteWidget icon, string text)
{
	local float X, Y, XL, YL, YL2;

	// We'll have four columns of 4 items
	MapLegendIcons.PosX = (float(LegendItemsIndex / 4) + 0.05) / 4;
	MapLegendIcons.PosY = (LegendItemsIndex % 4 + 0.5) / 4;

	MapLegendIcons.WidgetTexture = icon.WidgetTexture;
	MapLegendIcons.Tints[TeamIndex] = icon.Tints[TeamIndex];
	MapLegendIcons.TextureCoords = icon.TextureCoords;
	DrawSpriteWidgetClipped(C, MapLegendIcons, coords, true, XL, YL, true, true);

	// Same data for text
	MapLegendTexts.text = text;
	MapLegendTexts.PosX = MapLegendIcons.PosX;
	MapLegendTexts.PosY = MapLegendIcons.PosY;
	MapLegendTexts.offsetX = XL * 1.05;

	DrawTextWidgetClipped(C, MapLegendTexts, coords, X, Y, YL2);
	//MapLegendIcons.OffsetY += max(YL, Y) + YL2 * 0.5;
	//MapLegendTexts.OffsetY = MapLegendIcons.OffsetY;

	LegendItemsIndex++;
}

// returns true if click was out of level image bounds, meaning
// that menu should close
simulated function bool HandleLevelMapClick(float X, float Y)
{
	local float mapX, mapY, myMapScale;
	local vector temp, MapCenter, real;
	local ROGameReplicationInfo GRI;
	local ROLevelInfo levelinfo;
	local float minTimeBetweenRallyAssign;

	// Calculate 0-1 value
	mapX = (X - MapLevelImageCoordinates.PosX) / MapLevelImageCoordinates.width;
	mapY = (Y - MapLevelImageCoordinates.PosY) / MapLevelImageCoordinates.height;

	if (mapX < 0 || mapX > 1 || mapY < 0 || mapY > 1)
		return true;

	// Get GRI
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if (GRI == none)
		return false;

	// Calculate map image constants
	temp = GRI.SouthWestBounds - GRI.NorthEastBounds;
	MapCenter =  temp/2 + GRI.NorthEastBounds;
	myMapScale = abs(temp.x);

	// Modify MapX and MapY to compensate for map rotation
	real.X = MapX - 0.5;
	real.Y = MapY - 0.5;
	real = GetAdjustedHudLocation(real, true);
	MapX = real.X + 0.5;
	MapY = real.Y + 0.5;

	// Do inverse transform to find out coordinates to put rally point at
	real = MapCenter;
	real.X += (mapX - 0.5) * myMapScale;
	real.Y += (mapY - 0.5) * myMapScale;

	// Find levelinfo & assign minimum time between rally set
   	foreach AllActors(class'ROLevelInfo', levelinfo)
	   break;
	minTimeBetweenRallyAssign = 0.5;
	if (levelinfo != none)
	    minTimeBetweenRallyAssign = levelinfo.RallyPointInterval;

	// Check if we're allowed to set a rally point
	if (MapLastRallyPointAssignTime + minTimeBetweenRallyAssign * 1.05 < Level.TimeSeconds)
	{
		MapLastRallyPointAssignTime = Level.TimeSeconds;
		ROPlayer(PlayerOwner).ServerSaveRallyPointFromHud(real);
		PlayAssignSound(true);
	}
	else
		PlayAssignSound(false);

	return false;
}

function PlayAssignSound(bool bSuccessfull)
{
	if (PlayerOwner != none && PlayerOwner.ViewTarget != None )
	{
		if (bSuccessfull)
		    PlayerOwner.ViewTarget.PlaySound(AssignOKSound, SLOT_None,,,,,false);
		else
		    PlayerOwner.ViewTarget.PlaySound(AssignFailedSound, SLOT_None,,,,,false);
	}
}

/*simulated function OldDrawObjectives(Canvas C)
{
	local float X, Y, XL, YL, MapX, MapY, Scale;
	local ROGameReplicationInfo GRI;
	local int i, OwnerTeam;
	local string S;   // Ramm map stuff
	local vector HUDLocation, MapCenter;
		local float	CenterPosX, CenterPosY, Radarwidth, RadarHeight;
   	local float PlayerIconSize;
	local FinalBlend PlayerIcon;
	local Actor A;
	local vector Temp, MyArtyCoords, RallyPointCoords;
	local Material OverheadMap;
	local float	SavedOpacity;
	local Color OldDrawColor;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if (GRI == None)
		return;

	// Avoid multiple checks for this
	if( PlayerOwner != none )
	{
		OwnerTeam = PlayerOwner.GetTeamNum();
	}

	// store old opacity and set to 1.0 for map overlay rendering
	SavedOpacity = C.ColorModulate.W;
	C.ColorModulate.W = 1.0;

	scale = C.SizeX / 1600.0;

	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(0,0,0,128);
	C.SetPos(0,0);
	C.DrawRect(Material'Engine.WhiteSquareTexture', C.ClipX, C.ClipY);

	C.SetPos(0, 0.025 * C.ClipY);
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(HeaderImage, C.ClipX, 0.05 * C.ClipY, 0, 0, 2048, 64);

	C.SetDrawColor(0,0,0,255);
	C.Font = GetLargeMenuFont(C);
	C.DrawTextJustified(ObjectivesText, 1, 0, 0, C.ClipX, 0.10 * C.ClipY);

	C.Font = GetSmallMenuFont(C);
	C.DrawColor = WhiteColor;

	MapX = 0.45 * C.ClipX;
	MapY = 0.15 * C.ClipY;

	// Ramm map code

	Temp = GRI.SouthWestBounds - GRI.NorthEastBounds;
	MapScale = (GRI.MapImage.MaterialUSize() * Scale)/abs(Temp.X);
	MapCenter =  Temp/2 + GRI.NorthEastBounds;

	MapScale *= 1.5;

	RadarWidth = 0.5 * GRI.MapImage.MaterialUSize() * scale * 1.5;
	RadarHeight = 0.5 * GRI.MapImage.MaterialVSize() * scale * 1.5;
	CenterPosX = MapX + RadarWidth;
	CenterPosY = MapY + RadarHeight;

	// Draw the overhead map
	C.SetPos(MapX, MapY);
	if (GRI.MapImage != None)
	{
		OverheadMap = GRI.MapImage;
		C.DrawTileScaled(OverheadMap, scale * 1.5 , scale * 1.5 );
	}

	X = 0.05 * C.ClipX;
	Y = 0.15 * C.ClipY;

	// Draw resupply zones
	for (i = 0; i < ArrayCount(GRI.ResupplyAreas); i++)
	{
		if (!GRI.ResupplyAreas[i].bActive)
			continue;

		OldDrawColor = C.DrawColor;

		C.DrawColor.r=0; C.DrawColor.g=0; C.DrawColor.b=0; C.DrawColor.a=200;

		//TODO: REPLACE THIS CRAP WITH TEAM AMMO ICONS   (justinh)
		// Questionable whether we should allow players to see where the other teams ammo supply is
		if (GRI.ResupplyAreas[i].Team == AXIS_TEAM_INDEX)
			C.DrawColor.b=200;
		else if (GRI.ResupplyAreas[i].Team == ALLIES_TEAM_INDEX)
			C.DrawColor.r=200;
		else
		{
			C.DrawColor.r=200;
			C.DrawColor.g=200;
			C.DrawColor.b=200;
		}

		HUDLocation = GRI.ResupplyAreas[i].ResupplyVolumeLocation - MapCenter;
		HUDLocation.Z = 0;
		HUDLocation = GetAdjustedHudLocation(HUDLocation);

	   	C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
				  CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

		C.DrawTileScaled(Texture'ROInterfaceArt.HUD.hud_mg42', Scale/4, Scale/4);

		C.DrawColor = OldDrawColor;
	}

	// Draw the objectives
	for (i = 0; i < ArrayCount(GRI.Objectives); i++)
	{
		if (GRI.Objectives[i] == None)
			continue;

		//S = "OBJ" $ (i + 1) $ ": ObjState ="@GRI.Objectives[i].ObjState@"bActive ="@GRI.Objectives[i].bObjActive@"CurNum[AXIS_TEAM_INDEX] ="@GRI.Objectives[i].CurNum[AXIS_TEAM_INDEX]@"CurNum[ALLIES_TEAM_INDEX] ="@GRI.Objectives[i].CurNum[ALLIES_TEAM_INDEX]@"CapturePercentage ="@GRI.Objectives[i].CapturePercentage@"DisputedCapturePercentage ="@GRI.Objectives[i].DisputedCapturePercentage;;

		if (GRI.Objectives[i].bActive) //bObjActive
		{
			S = "OBJ" $ (i + 1) $ ": ";

			if (GRI.Objectives[i].ObjState != PlayerOwner.PlayerReplicationInfo.Team.TeamIndex)
				S = S $ GRI.Objectives[i].AttackerDescription;
			else
			S = S $ GRI.Objectives[i].DefenderDescription;

			C.SetPos(X, Y);
			C.StrLen(S, XL, YL);
			//C.DrawTextClipped(S);
			C.DrawTextJustified(S, 2, X, Y, 0.4 * C.ClipX, Y + YL);

		/*if (!GRI.Objectives[i].bActive)   //bObjActive
		{
			if (GRI.Objectives[i].ObjState != PlayerOwner.PlayerReplicationInfo.Team.TeamIndex)
			{
				C.DrawColor = RedColor;
				C.DrawText("  " $ ObjFailedText);
			}
			else
			{
				C.DrawColor = GreenColor;
				C.DrawText("  " $ ObjCompleteText);
			}
		}*/

			Y += YL * 2;
		}

		HUDLocation = GRI.Objectives[i].Location - MapCenter;
		HUDLocation.Z = 0;

		HUDLocation = GetAdjustedHudLocation(HUDLocation);

		C.StrLen(GRI.Objectives[i].ObjName, XL, YL);
	    C.SetPos((CenterPosX + HUDLocation.X * MapScale) - XL / 2, (CenterPosY + HUDLocation.Y * MapScale) - YL - 16 * Scale);

		/*if (GRI.Objectives[i].ObjState == OBJ_German)
			C.DrawColor = GermanColor;
		else if (GRI.Objectives[i].ObjState == OBJ_Russian)
			C.DrawColor = RussianColor;
		else*/


		if (!GRI.Objectives[i].bActive) //bObjActive
		{
			C.DrawColor = GrayColor;
			C.DrawColor.A = 125;
		}
		else
		{
			C.DrawColor = WhiteColor;
		}
		C.DrawTextClipped(GRI.Objectives[i].ObjName);


	   	C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
				  CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

		if (GRI.Objectives[i].ObjState == OBJ_Axis)
			C.DrawTileScaled(NationIcons[GRI.NationIndex[AXIS_TEAM_INDEX]], Scale, Scale);
		else if (GRI.Objectives[i].ObjState == OBJ_Allies)
			C.DrawTileScaled(NationIcons[GRI.NationIndex[ALLIES_TEAM_INDEX]], Scale, Scale);
		else
			C.DrawTileScaled(NeutralIcon, Scale, Scale);

		C.DrawColor = WhiteColor;
	}

	// Draw the legend - Raw but functional - Ramm
		X = 0.45 * C.ClipX;
	Y = 0.81 * C.ClipY;

  	C.SetPos(X,Y);
		C.DrawTileScaled(ArtilleryIcon, Scale, Scale);

	X = 0.48 * C.ClipX;
	Y = 0.81 * C.ClipY;
	C.SetPos(X , Y );
	C.DrawTextClipped("Artillery Coordinates");

		X = 0.45 * C.ClipX;
	Y = 0.86 * C.ClipY;
  	C.SetPos(X,Y);
		C.DrawTileScaled(RadioIcon, Scale, Scale);

	X = 0.48 * C.ClipX;
	Y = 0.86 * C.ClipY;
	C.SetPos(X , Y );
	C.DrawTextClipped("Artillery Radios");

		X = 0.45 * C.ClipX;
	Y = 0.91 * C.ClipY;
  	C.SetPos(X,Y);
		C.DrawTileScaled(RallyPointIcon, Scale, Scale);

	X = 0.48 * C.ClipX;
	Y = 0.91 * C.ClipY;
	C.SetPos(X , Y );
	C.DrawTextClipped("Rally Points");


		MyArtyCoords = ROPlayer(PlayerOwner).SavedArtilleryCoords;

	// Draw the marked arty strike
	if (MyArtyCoords != vect(0,0,0))
	{

		HUDLocation = MyArtyCoords - MapCenter;
		HUDLocation.Z = 0;

		HUDLocation = GetAdjustedHudLocation(HUDLocation);

		C.DrawColor = WhiteColor;

	   	C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
				  CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

	    	C.DrawTileScaled(ArtilleryIcon, Scale, Scale);
	}

	// The coordinates for the rally point

	if ( OwnerTeam != 255 )
	{
	 	for (i = 0; i < ArrayCount(GRI.AxisRallyPoints); i++)
		{
			if ( OwnerTeam == AXIS_TEAM_INDEX )
			{
				RallyPointCoords = GRI.AxisRallyPoints[i].RallyPointLocation;
			}
			else if ( OwnerTeam == ALLIES_TEAM_INDEX )
			{
				RallyPointCoords = GRI.AlliedRallyPoints[i].RallyPointLocation;
			}

			// Draw the marked rally point
			if (RallyPointCoords != vect(0,0,0))
			{

				HUDLocation = RallyPointCoords - MapCenter;
				HUDLocation.Z = 0;

		          HUDLocation = GetAdjustedHudLocation(HUDLocation);

				// Don't let rally point be drawn off the map
				if (abs(HUDLocation.X * MapScale) < (RadarWidth) && abs(HUDLocation.Y  * MapScale) < (RadarHeight))
				{
					C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
					        CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

					C.DrawColor = WhiteColor;
					C.DrawTileScaled(RallyPointIcon, Scale, Scale);
			    }
			}
		}

		// Draw Artillery Radio Icons
		if ( OwnerTeam == AXIS_TEAM_INDEX )
		{
			for ( i = 0; i < ArrayCount(GRI.AxisRadios); i++)
			{
				if(GRI.AxisRadios[i] == none)
					continue;

				HUDLocation = GRI.AxisRadios[i].Location - MapCenter;
				HUDLocation.Z = 0;

				HUDLocation = GetAdjustedHudLocation(HUDLocation);

				C.DrawColor = WhiteColor;

				C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
				CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

				C.DrawTileScaled(RadioIcon, Scale, Scale);
			}
		}
		else if ( OwnerTeam == ALLIES_TEAM_INDEX )
		{
			for ( i = 0; i < ArrayCount(GRI.AlliedRadios); i++)
			{
				if(GRI.AlliedRadios[i] == none)
					continue;

				HUDLocation = GRI.AlliedRadios[i].Location - MapCenter;
				HUDLocation.Z = 0;

				HUDLocation = GetAdjustedHudLocation(HUDLocation);

				C.DrawColor = WhiteColor;

				C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
				CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );

				C.DrawTileScaled(RadioIcon, Scale, Scale);
			}
		}
	}


	// Draw PlayerIcon
	// I'm not sure relying on a state is necessary or appropriate in this instance - Erik
	// Well Epic sure thought it was appropriate when they used it for thier onslaught overheads - Ramm
	// See ONSHUDOnslaught.uc for more details.
	// Move this down here so the player location is rendered on top of everything
	if (PawnOwner != None)
			A = PawnOwner;
		else if (PlayerOwner.IsInState('Spectating'))
			A = PlayerOwner;
		else if (PlayerOwner.Pawn != None)
			A = PlayerOwner.Pawn;

	 PlayerIconSize = 32* Scale;

	if (A != None)
	{
// MergeTODO: Add this back in
		PlayerIcon = PlayerArrowTexture;
	   	HUDLocation = A.Location - MapCenter;
	   	HUDLocation.Z = 0;

		HUDLocation = GetAdjustedHudLocation(HUDLocation);

		//modding
		if ( GRI.OverheadOffset == 90 )
		{
		 	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 32768;
		}
		else if( GRI.OverheadOffset == 180 )
		{
		 	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 49152;
		}
		else if( GRI.OverheadOffset == 270 )
		{
		 	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw;
		}
		else
		{
		 	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
		}

		// Uncomment this if you don't want the player drawn off the map - Ramm
		//if (abs(HUDLocation.X * MapScale) < (RadarWidth) && abs(HUDLocation.Y  * MapScale) < (RadarHeight))
		//{
		C.SetPos( CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5,
		               CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 );

		  C.DrawColor = C.MakeColor(255,0,0);
		  C.DrawTile(PlayerIcon/*PlayerIcon*/, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
		  C.DrawColor = WhiteColor;
		//}
		//else
		//{
		//log("We are drawing off the map");
		//}
	}

		// Overhead map debugging
	if (Level.NetMode == NM_Standalone && ROTeamGame(Level.Game).LevelInfo.bDebugOverhead)
	{
		// Corner debugging
		HUDLocation = GRI.NorthEastBounds - MapCenter;
		HUDLocation.Z = 0;

		HUDLocation = GetAdjustedHudLocation(HUDLocation);

		C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
		         CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );
		C.DrawTileScaled(NationIcons[GRI.NationIndex[ALLIES_TEAM_INDEX]], Scale, Scale);

		HUDLocation = GRI.SouthWestBounds - MapCenter;
		HUDLocation.Z = 0;

		HUDLocation = GetAdjustedHudLocation(HUDLocation);

		C.SetPos( CenterPosX + HUDLocation.X * MapScale - 16 * 0.5,
		   CenterPosY + HUDLocation.Y * MapScale - 16 * 0.5 );
		C.DrawTileScaled(NationIcons[GRI.NationIndex[AXIS_TEAM_INDEX]], Scale, Scale);
	}
	// reset hud opacity back to original value
	C.ColorModulate.W = SavedOpacity;
}*/

// This function will adjust a hud map location based on the rotation offset of the overhead map
simulated function vector GetAdjustedHudLocation(vector HudLoc, optional bool bInvert)
{
	local float SwapX, SwapY;
	local ROGameReplicationInfo GRI;
	local int OverheadOffset;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	OverheadOffset = GRI.OverheadOffset;

	if (bInvert)
	{
	    if (OverheadOffset == 90)
	       OverheadOffset = 270;
	    else if (OverheadOffset == 270)
	       OverheadOffset = 90;
	}

	//modding
	if (OverheadOffset  == 90 )
	{
		SwapX = HudLoc.Y * -1;
		SwapY = HudLoc.X ;
		HudLoc.X = SwapX;
		HudLoc.Y = SwapY;
	}
	else if( OverheadOffset == 180 )
	{
		SwapX = HudLoc.X * -1;
		SwapY = HudLoc.Y * -1;
		HudLoc.X = SwapX;
		HudLoc.Y = SwapY;
	}
	else if( OverheadOffset == 270 )
	{
		SwapX = HudLoc.Y;
		SwapY = HudLoc.X * -1;
		HudLoc.X = SwapX;
		HudLoc.Y = SwapY;
	}

	return HudLoc;
}

simulated function DrawCompass(Canvas C)
{
	local float XL, YL, playerRot, compensation;
	local actor A;
	local AbsoluteCoordsInfo GlobalCoors;
	local ROGameReplicationInfo GRI;
	local int OverheadOffset;
	local float pawnRotation;
	local ROPlayer player;
	local ROVehicleWeaponPawn myVehicleWeaponPawn;

	// Setup constants
	GlobalCoors.width = C.ClipX;
	GlobalCoors.height = C.ClipY;
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	OverheadOffset = GRI.OverheadOffset;

	// Get player actor
	if (PawnOwner != None)
		A = PawnOwner;
	else if (PlayerOwner.IsInState('Spectating'))
		A = PlayerOwner;
	else if (PlayerOwner.Pawn != None)
		A = PlayerOwner.Pawn;

	// Fix for frelled rotation on weapon pawns
	myVehicleWeaponPawn = ROVehicleWeaponPawn(A);
	if (myVehicleWeaponPawn != none)
	{
	   player = ROPlayer(myVehicleWeaponPawn.Controller);
	   if (player != none && myVehicleWeaponPawn.VehicleBase != none)
	       pawnRotation = player.CalcViewRotation.Yaw;
	   else if (myVehicleWeaponPawn.VehicleBase != none)
	       pawnRotation = myVehicleWeaponPawn.VehicleBase.Rotation.Yaw;
	   else
	       pawnRotation = A.Rotation.Yaw;
	}
	else if (A != none)
	   pawnRotation = A.Rotation.Yaw;

	// Compensate for map rotation
	compensation = float(OverheadOffset) / 90 * 16384 + 16384;

	// Figure which direction we're pointing
	if (A != none)
	   playerRot = pawnRotation + compensation;
	else // shouldn't ever happen but better safe than log-spammy
	   playerRot = compassCurrentRotation;

	// Pre-bind compass rotation to a -32000 to 32000 range relative to playerRot
	while (compassCurrentRotation - playerRot > 32768)
		compassCurrentRotation -= 65536;
	while (compassCurrentRotation - playerRot < -32768)
		compassCurrentRotation += 65536;

	// Update compass rotation
	compassCurrentRotation = compassCurrentRotation + compassStabilizationConstant * (playerRot - compassCurrentRotation) * (Level.TimeSeconds - hudLastRenderTime);

	// Update needle rotation
	TexRotator(CompassNeedle.WidgetTexture).Rotation.Yaw = compassCurrentRotation;

	// Draw compass base (fake, only to get sizes)
	DrawSpriteWidgetClipped(C, CompassBase, GlobalCoors, true, XL, YL, true, true, true);

	// Calculate needle screen offset
	CompassNeedle.OffsetX = (GlobalCoors.Width * -0.005) + default.CompassNeedle.OffsetX +//default.CompassNeedle.OffsetX * CompassBase.TextureScale +
		CompassBase.OffsetX - XL / HudScale / 2;
	CompassNeedle.OffsetY = default.CompassNeedle.OffsetY +//default.CompassNeedle.OffsetY * CompassBase.TextureScale +
		CompassBase.OffsetY - YL / HudScale  / 2;
	//CompassXL = abs(CompassNeedle.OffsetX - XL / 2);
	//CompassYL = abs(CompassNeedle.OffsetY - YL / 2);

	// Draw the compass needle
	DrawSpriteWidgetClipped(C, CompassNeedle, GlobalCoors, true, XL, YL, true, true, true);

	// Draw compass base
	DrawSpriteWidgetClipped(C, CompassBase, GlobalCoors, true, XL, YL, true, true, true);

	// Draw icons
	if (CompassIconsOpacity > 0 || bShowObjectives)
		DrawCompassIcons(C, CompassNeedle.OffsetX, CompassNeedle.OffsetY,
						XL / HudScale / 2 * compassIconsPositionRadius, -(A.Rotation.Yaw + 16384), A, GlobalCoors);
}

// Draw the required icons on the compass
simulated function DrawCompassIcons(Canvas C, float CenterX, float CenterY, float Radius,
									float rotationCompensation, actor viewer, AbsoluteCoordsInfo GlobalCoords)
{
	local vector target, current;
	local int i, team, id, count, temp_team;
	local ROGameReplicationInfo GRI;
	local float angle, XL, YL;
	local rotator rotAngle;

	// Decrement opacity if needed, increment if needed
	if (bShowObjectives)
		compassIconsOpacity = fmin(1.0, compassIconsOpacity + compassIconsRefreshSpeed * (Level.TimeSeconds - hudLastRenderTime));
	else
		compassIconsOpacity -= compassIconsFadeSpeed * (Level.TimeSeconds - hudLastRenderTime);

	// Get user's team & position
	if (Pawn(viewer) != none)
	{
		if (Pawn(viewer).Controller != none)
			team = Pawn(viewer).Controller.PlayerReplicationInfo.Team.TeamIndex;
		else
			team = 255;
	}
	else
	{
		if (Controller(viewer) != none)
			team = Controller(viewer).PlayerReplicationInfo.Team.TeamIndex;
		else
			team = 255;
	}
	current = viewer.location;

	// Get GRI
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if (GRI == none)
		return;

	// Update waypoints array if needed
	if (bShowObjectives)
	{
		temp_team = max(0, min(1, team));

		count = 0;
		// Clear old array
		for (i = 0; i < arraycount(compassIconsTargetsActive); i++)
			compassIconsTargetsActive[i] = 0;

		if (team == AXIS_TEAM_INDEX || team == ALLIES_TEAM_INDEX)
		{
			// Add under-attack objectives (territory objs only)
			/*for (i = 0; i < ArrayCount(GRI.Objectives); i++)
			{
				if (GRI.Objectives[i] == none || GRI.Objectives[i].CompressedCapProgress == 0
					|| GRI.Objectives[i].CurrentCapTeam == NEUTRAL_TEAM_INDEX)
				{
				    continue;
				}

				// if array is full, stop adding waypoints
				if (count >= arraycount(compassIconsTargetsActive))
				    break;
				compassIconsTargetsActive[count] = 1;

				if (GRI.Objectives[i].ObjState == OBJ_Axis)
				    compassIconsTargetsColor[count] = compassIconsColorsAxis;
				else if (GRI.Objectives[i].ObjState == OBJ_Allies)
					compassIconsTargetsColor[count] = compassIconsColorsAllies;
				else
				    compassIconsTargetsColor[count] = compassIconsColorsNeutral;

				compassIconsTargets[count] = GRI.Objectives[i].location;

				count++;
			}*/

			// Add all rally points
			for (i = 0; i < ArrayCount(GRI.AxisRallyPoints); i++)
			{
				// if array is full, stop adding waypoints
				if (count >= arraycount(compassIconsTargetsActive))
				    break;
				//compassIconsTargetsColor[count] = compassIconsColorsRally;

				if (team == AXIS_TEAM_INDEX)
					target = GRI.AxisRallyPoints[i].RallyPointLocation;
				else
					target = GRI.AlliedRallyPoints[i].RallyPointLocation;
				compassIconsTargetsWidgetCoords[count] = MapIconRally[temp_team].TextureCoords;

				if (target != vect(0,0,0))
				{
					compassIconsTargets[count] =  target;
		   			compassIconsTargetsActive[count] = 1;
					count++;
				}

			}

			// Add all help requests
			for (i = 0; i < ArrayCount(GRI.AxisHelpRequests); i++)
			{
				// if array is full, stop adding waypoints
				if (count >= arraycount(compassIconsTargetsActive))
				    break;

				if (team == AXIS_TEAM_INDEX)
				{
					target = GRI.AxisHelpRequestsLocs[i];
					id = GRI.AxisHelpRequests[i].requestType;
				}
				else
				{
					target = GRI.AlliedHelpRequestsLocs[i];
					id = GRI.AlliedHelpRequests[i].requestType;
				}

				if (id != 255)
				{
					if (id == 3) // MG resupply
						compassIconsTargetsWidgetCoords[count] = MapIconMGResupplyRequest[temp_team].TextureCoords;
						//compassIconsTargetsColor[count] = compassIconsColorsMGResupply;
					else if (id == 0 || id == 4) // Help request at coords or at obj
						compassIconsTargetsWidgetCoords[count] = MapIconHelpRequest.TextureCoords;
						//compassIconsTargetsColor[count] = compassIconsColorsHelpRequests;
					else if (id == 1 || id == 2) // Attack/defend obj
						compassIconsTargetsWidgetCoords[count] = MapIconAttackDefendRequest.TextureCoords;
						//compassIconsTargetsColor[count] = compassIconsColorsHelpRequests;
					else
						continue;

					compassIconsTargets[count] =  target;
		   			compassIconsTargetsActive[count] = 1;
					count++;
				}
			}

		}
	}

	// Go through waypoint array and draw the icons
	for (i = 0; i < ArrayCount(compassIconsTargetsActive); i++)
	{
		if (compassIconsTargetsActive[i] == 1)
		{
			// Update widget color & texture
			//CompassIcons.Tints[TeamIndex] = compassIconsTargetsColor[i];
			//CompassIcons.Tints[TeamIndex].A = float(compassIconsTargetsColor[i].A) * compassIconsOpacity;
			//CompassIcons.WidgetTexture = compassIconsRotators[i];
			CompassIcons.TextureCoords = compassIconsTargetsWidgetCoords[i];
			CompassIcons.Tints[TeamIndex].A = float(default.CompassIcons.Tints[TeamIndex].A) * compassIconsOpacity;

			// Calculate rotation
			rotAngle = rotator(compassIconsTargets[i] - current);
			angle = (rotAngle.Yaw + rotationCompensation) * PI / 32768;

			// Update texrotator rotation
			//compassIconsRotators[i].Rotation.yaw = -rotAngle.Yaw - rotationCompensation - 8192;

			// Update widget offset
			CompassIcons.OffsetX = CenterX + Radius * cos(angle);
			CompassIcons.OffsetY = CenterY + Radius * sin(angle);

			// Draw waypoint image
			DrawSpriteWidgetClipped(C, CompassIcons, GlobalCoords, true, XL, YL, true, true, true);
		}
	}

}

// Draw a single icon on the compass
simulated function DrawCompassIcon(Canvas C, AbsoluteCoordsInfo G, float radius, float rotComp, vector diff, float X, float Y)
{
	local float angle, XL, YL;
	local rotator rotAngle;

	rotAngle = rotator(diff);
	//angle = (rotAngle.Yaw + rotComp - 16384) * PI / 32768; // non-rotating icons
	angle = (rotAngle.Yaw + rotComp) * PI / 32768; // icons rotating with player

	diff.Z = 0;
	XL = radius; //* fmin(1, VSize(diff)/compassIconsUUDistance);

	CompassIcons.OffsetX = X + XL * cos(angle);
	CompassIcons.OffsetY = Y + XL * sin(angle);
	DrawSpriteWidgetClipped(C, CompassIcons, G, true, XL, YL, true, true, true);
}

simulated function DrawLocationHits(Canvas C, ROPawn P)
{
	local int i;
	local bool bNewDrawHits;
	local SpriteWidget widget;

	for (i = 0; i < arraycount(P.DamageList); i++)
	{
		if (P.DamageList[i] > 0)
		{
			// Draw hit
			widget = HealthFigure;
			if (TeamIndex == AXIS_TEAM_INDEX)
				widget.WidgetTexture = locationHitAxisImages[i];
			else if (TeamIndex == AXIS_TEAM_INDEX)
				widget.WidgetTexture = locationHitAlliesImages[i];
			else
				continue;

			DrawSpriteWidget(C, widget);

			if (locationHitAlphas[i] > 0)
				bNewDrawHits = true;
		}
	}

	bDrawHits = bNewDrawHits;
}

simulated function DrawCaptureBar(Canvas Canvas)
{
	local ROGameReplicationInfo GRI;
	local ROPawn p;
	local ROVehicle veh;
	local ROVehicleWeaponPawn pveh;
	local int team;
	local byte CurrentCapArea, CurrentCapProgress, CurrentCapAxisCappers, CurrentCapAlliesCappers;
	local float axis_progress, allies_progress;
	local float attackers_progress, attackers_ratio, defenders_progress, defenders_ratio;
	local float XL, YL, Y_pos;
	local string s;

	bDrawingCaptureBar = false;

	// Don't draw if we have no associated pawn!
	if (PawnOwner == none)
		return;

	// Get capture info from associated pawn
	p = ROPawn(PawnOwner);
	if (p != none)
	{
		CurrentCapArea = p.CurrentCapArea;
		CurrentCapProgress = p.CurrentCapProgress;
		CurrentCapAxisCappers = p.CurrentCapAxisCappers;
		CurrentCapAlliesCappers = p.CurrentCapAlliesCappers;
	}
	else
	{
		// Not a ROPawn, check if current pawn is a vehicle
		veh = ROVehicle(PawnOwner);
		if (veh != none)
		{
			CurrentCapArea = veh.CurrentCapArea;
			CurrentCapProgress = veh.CurrentCapProgress;
			CurrentCapAxisCappers = veh.CurrentCapAxisCappers;
			CurrentCapAlliesCappers = veh.CurrentCapAlliesCappers;
		}
		else
		{
			// Not a ROVehicle, check if current pawn is a ROVehicleWeaponPawn
			pveh = ROVehicleWeaponPawn(PawnOwner);
			if (pveh != none)
			{
				CurrentCapArea = pveh.CurrentCapArea;
				CurrentCapProgress = pveh.CurrentCapProgress;
				CurrentCapAxisCappers = pveh.CurrentCapAxisCappers;
				CurrentCapAlliesCappers = pveh.CurrentCapAlliesCappers;
			}
			else
			{
				// Unsupported pawn type, return.
				return;
			}
		}
	}

	// Don't render if we're not in a capture zone
	if (CurrentCapArea == 255)
		return;

	// Get GRI
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if (GRI == none)
		return; // Can't draw without a gri!

	// Get current team
	if (PawnOwner.PlayerReplicationInfo != none && PawnOwner.PlayerReplicationInfo.Team != none)
		team = PawnOwner.PlayerReplicationInfo.Team.TeamIndex;
	else
		team = 0;

	// Get current cap progress on a 0-1 scale for each team
	if (CurrentCapProgress == 0)
	{
		if (GRI.Objectives[CurrentCapArea].ObjState == NEUTRAL_TEAM_INDEX)
		{
			allies_progress = 0;
			axis_progress = 0;
		}
		else if (GRI.Objectives[CurrentCapArea].ObjState == AXIS_TEAM_INDEX)
		{
			allies_progress = 0;
			axis_progress = 1;
		}
		else
		{
			allies_progress = 1;
			axis_progress = 0;
		}
	}
	else if (CurrentCapProgress > 100)
	{
		allies_progress = float(CurrentCapProgress - 100) / 100.0;
		if (GRI.Objectives[CurrentCapArea].ObjState != NEUTRAL_TEAM_INDEX)
			axis_progress = 1 - allies_progress;
	}
	else
	{
		axis_progress = float(CurrentCapProgress) / 100.0;
		if (GRI.Objectives[CurrentCapArea].ObjState != NEUTRAL_TEAM_INDEX)
			allies_progress = 1 - axis_progress;
	}

	// Assign those progress to defender or attacker, depending on current team
	if (team == AXIS_TEAM_INDEX)
	{
		attackers_progress = axis_progress;
		defenders_progress = allies_progress;
		CaptureBarAttacker.Tints[TeamIndex] = CaptureBarTeamColors[AXIS_TEAM_INDEX];
		CaptureBarAttackerRatio.Tints[TeamIndex] = CaptureBarTeamColors[AXIS_TEAM_INDEX];
		CaptureBarDefender.Tints[TeamIndex] = CaptureBarTeamColors[ALLIES_TEAM_INDEX];
		CaptureBarDefenderRatio.Tints[TeamIndex] = CaptureBarTeamColors[ALLIES_TEAM_INDEX];
		CaptureBarIcons[0].WidgetTexture = CaptureBarTeamIcons[AXIS_TEAM_INDEX];
		CaptureBarIcons[1].WidgetTexture = CaptureBarTeamIcons[ALLIES_TEAM_INDEX];

		// Figure ratios
		if (CurrentCapAlliesCappers == 0)
			attackers_ratio = 1;
		else if (CurrentCapAxisCappers == 0)
			attackers_ratio = 0;
		else
			attackers_ratio = float(CurrentCapAxisCappers) / (CurrentCapAxisCappers + CurrentCapAlliesCappers);
		defenders_ratio = 1 - attackers_ratio;
	}
	else
	{
		attackers_progress = allies_progress;
		defenders_progress = axis_progress;
		CaptureBarAttacker.Tints[TeamIndex] = CaptureBarTeamColors[ALLIES_TEAM_INDEX];
		CaptureBarAttackerRatio.Tints[TeamIndex] = CaptureBarTeamColors[ALLIES_TEAM_INDEX];
		CaptureBarDefender.Tints[TeamIndex] = CaptureBarTeamColors[AXIS_TEAM_INDEX];
		CaptureBarDefenderRatio.Tints[TeamIndex] = CaptureBarTeamColors[AXIS_TEAM_INDEX];
		CaptureBarIcons[0].WidgetTexture = CaptureBarTeamIcons[ALLIES_TEAM_INDEX];
		CaptureBarIcons[1].WidgetTexture = CaptureBarTeamIcons[AXIS_TEAM_INDEX];

		// Figure ratios
		if (CurrentCapAxisCappers == 0)
			attackers_ratio = 1;
		else if (CurrentCapAlliesCappers == 0)
			attackers_ratio = 0;
		else
			attackers_ratio = float(CurrentCapAlliesCappers) / (CurrentCapAxisCappers + CurrentCapAlliesCappers);
		defenders_ratio = 1 - attackers_ratio;
	}

	// test0r
	//Canvas.Font = GetConsoleFont(Canvas);
	//Canvas.SetPos(Canvas.ClipX * 0.1, Canvas.clipy * 0.2);
	//Canvas.DrawText("attackers_ratio = " $ attackers_ratio $ ", defenders_ratio = " $ defenders_ratio);
	//Canvas.SetPos(Canvas.ClipX * 0.1, Canvas.clipy * 0.25);
	//Canvas.DrawText("CurrentCapAlliesCappers = " $ CurrentCapAlliesCappers $ ", CurrentCapAxisCappers = " $ CurrentCapAxisCappers);

	// Draw capture bar at 50% faded if we're at a stalemate
	if (CurrentCapAxisCappers == CurrentCapAlliesCappers)
	{
		CaptureBarAttacker.Tints[TeamIndex].A /= 2;
		CaptureBarDefender.Tints[TeamIndex].A /= 2;
	}

	// Convert attacker/defender progress to widget scale
	// (bar goes from 53 to 203, total width of texture is 256)
	CaptureBarAttacker.Scale = 150.0 / 256.0 * attackers_progress + 53.0 / 256.0;
	CaptureBarDefender.Scale = 150.0 / 256.0 * defenders_progress + 53.0 / 256.0;

	// Convert attacker/defender ratios to widget scale
	// (bar goes from 63 to 193, total width of texture is 256)
	CaptureBarAttackerRatio.Scale = 130.0 / 256.0 * attackers_ratio + 63.0 / 256.0;
	CaptureBarDefenderRatio.Scale = 130.0 / 256.0 * defenders_ratio + 63.0 / 256.0;

	// Check which icon to show on right side
	if (attackers_progress ~= 1.0)
		CaptureBarIcons[1].WidgetTexture = CaptureBarIcons[0].WidgetTexture;

	// Draw everything.
	DrawSpriteWidget(Canvas, CaptureBarBackground);
	DrawSpriteWidget(Canvas, CaptureBarAttacker);
	DrawSpriteWidget(Canvas, CaptureBarDefender);
	DrawSpriteWidget(Canvas, CaptureBarAttackerRatio);
	DrawSpriteWidget(Canvas, CaptureBarDefenderRatio);
	DrawSpriteWidget(Canvas, CaptureBarOutline);

	// Draw the left icon
	DrawSpriteWidget(Canvas, CaptureBarIcons[0]);

	// Only draw right icon if objective is capped already
	if ( !(defenders_progress ~= 0.0) || (attackers_progress ~= 1.0) )
		DrawSpriteWidget(Canvas, CaptureBarIcons[1]);

	// Draw the objective name
	Y_pos = Canvas.ClipY * CaptureBarBackground.PosY
		- (CaptureBarBackground.TextureCoords.Y2 + 1 + 4)
			* CaptureBarBackground.TextureScale * HudScale * ResScaleY;
	s = GRI.Objectives[CurrentCapArea].ObjName;
	Canvas.Font = GetConsoleFont(Canvas);
	Canvas.TextSize(s, XL, YL);
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX * CaptureBarBackground.PosX - XL / 2.0, Y_pos - YL);
	Canvas.DrawText(s);

	// Add signal so that vehicle passenger list knows to shift text up
	bDrawingCaptureBar = true;
}

// This function draws a hint on the hud. The hint to be drawn
// is set by calling ShowHint().
function DrawHint(Canvas Canvas)
{
	local float alpha; // 0 - 1
	local float XL, YL;
	local AbsoluteCoordsInfo coords;
	local color DrawColor;
	local float backgroundOffset;
	local int i;

	// Calculate wrapping width & draw coords if needed
	if (bFirstHintRender)
	{
		CalculateHintWrappingData(Canvas);
		bFirstHintRender = false;
	}

	// Calculate alpha value
	if (HintRemainingTime > HintLifetime + HintFadeTime) // Fade in
	{
		alpha = 1 - (HintRemainingTime - HintLifetime - HintFadeTime) / HintFadeTime;
	}
	else if (HintRemainingTime < HintFadeTime) // Fade out
	{
		alpha = HintRemainingTime / HintFadeTime;
	}
	else
		alpha = 1.0;

	// Decrement remaining time if needed
	if (PlayerOwner.Player != none &&
		GUIController(PlayerOwner.Player.GUIController) != none &&
		GUIController(PlayerOwner.Player.GUIController).ActivePage != none) // don't decrement if menu is open
	{
	}
	else
		HintRemainingTime -= Level.TimeSeconds - hudLastRenderTime;

	// Calculate rendering color
	DrawColor = HintBackground.Tints[TeamIndex];
	DrawColor.A = float(DrawColor.A) * alpha;

	// Don't draw if alpha is 0 (0 == 255 for some reason)
	if (DrawColor.A != 0)
	{
		// Set proper rendering style
		Canvas.Style = ERenderStyle.STY_Alpha;

		// Calculate background offset in relation to text
		backgroundOffset = HintBackground.PosY * Canvas.ClipY;

		// Calculate absolute drawing coordinates (mostly for text widget)
		coords.PosX = HintCoords.X * Canvas.ClipX;
		coords.PosY = HintCoords.Y * Canvas.ClipY;
		coords.width = HintCoords.XL * Canvas.ClipX;
		coords.height = HintCoords.YL * Canvas.ClipY;

		// Draw the background
		Canvas.DrawColor = DrawColor;
		Canvas.SetPos(coords.PosX - backgroundOffset, coords.PosY - backgroundOffset);
		Canvas.DrawTileStretched(HintBackground.WidgetTexture, coords.width + backgroundOffset * 2,
			coords.height + backgroundOffset * 2);

		// Draw title
		Canvas.Font = GetFontSizeIndex(Canvas,-2);
		HintTitleWidget.text = HintTitle;
		HintTitleWidget.Tints[TeamIndex].A = float(default.HintTitleWidget.Tints[TeamIndex].A) * alpha;
		DrawTextWidgetClipped(Canvas, HintTitleWidget, coords, XL, YL);

		// Draw each line individually
		HintTextWidget.OffsetY = YL * 1.5;
		Canvas.Font = getSmallMenuFont(Canvas);
		HintTextWidget.Tints[TeamIndex].A = float(default.HintTextWidget.Tints[TeamIndex].A) * alpha;
		YL = 0;
		for (i = 0; i < HintWrappedText.Length; i++)
		{
			HintTextWidget.text = HintWrappedText[i];
			if (HintWrappedText[i] != "")
				DrawTextWidgetClipped(Canvas, HintTextWidget, coords, XL, YL);
			else
				YL /= 2;
			HintTextWidget.OffsetY += YL;
		}
	}

	// Stop rendering hint if needed (and notify hint manager)
	if (HintRemainingTime <= 0)
	{
		bDrawHint = false;
		if (ROPlayer(PlayerOwner) != none)
			ROPlayer(PlayerOwner).NotifyHintRenderingDone();
	}
}

// This function is used to calculate how the hint data should
// be wrapped.
function CalculateHintWrappingData(Canvas Canvas)
{
	local float XL, YL, XL2, YL2;
	local float minWidth, wrapWidth, totalYL;
	local int i, count;

	// First calculate minimum message width (e.g. the width of the
	// title string)
	Canvas.Font = GetFontSizeIndex(Canvas,-2);
	Canvas.SetPos(0, 0);
	Canvas.TextSize(HintTitle, minWidth, totalYL);
	if (minWidth < 10.0)
		minWidth = 10.0;
	totalYL += totalYL / 2;

	// Calculate max width of text string (or perhaps we should just use full screen width?)
	Canvas.Font = getSmallMenuFont(Canvas);
	Canvas.TextSize(HintText, XL, YL);

	// Starting with full string width, progressively reduce width until the ratio of the height
	// to the width is smaller than HintDesiredAspectRatio
	wrapWidth = XL;
	for (count = 0; count < 25; count++) // max 25 iterations
	{
		// Wrap text
		HintWrappedText.Length = 0;
		Canvas.WrapStringToArray(HintText, HintWrappedText, wrapWidth, "|");

		// Calculate current width & height
		XL = 0; YL = 0;
		XL2 = 0; YL2 = 0;
		for (i = 0; i < HintWrappedText.Length; i++)
		{
			if (HintWrappedText[i] != "")
				Canvas.TextSize(HintWrappedText[i], XL, YL);
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
	HintWrappedText.Length = 0;
	Canvas.SetPos(0, 0);
	Canvas.WrapStringToArray(HintText, HintWrappedText, wrapWidth, "|");

	// Calculate total width and height
	wrapWidth = minWidth;
	XL = 0; YL = 0;
	for (i = 0; i < HintWrappedText.Length; i++)
	{
		Canvas.SetPos(0, 0);
		if (HintWrappedText[i] != "")
			Canvas.TextSize(HintWrappedText[i], XL, YL);
		else
			YL /= 2;
		if (XL > wrapWidth)
			wrapWidth = XL;
		totalYL += YL;
		//log("Wrapped line #" $ i $ ": '" $ HintWrappedText[i] $"'");
	}

	// for safety
	if (wrapWidth < 10)
		wrapWidth = 10;
	if (totalYL < 10)
		totalYL = 10;

	// Calculate target relative coordinates
	HintCoords.XL = wrapWidth / Canvas.ClipX;
	HintCoords.YL = totalYL / Canvas.ClipY;
	HintCoords.X = default.HintCoords.X + HintCoords.XL * default.HintCoords.XL;
	HintCoords.Y = default.HintCoords.Y + HintCoords.YL * default.HintCoords.YL;
}

simulated function DrawPaused(Canvas Canvas)
{
	local float XL, YL;

	Canvas.Font = GetFontSizeIndex(Canvas, 5);
	Canvas.TextSize(LevelActionPaused, XL, YL);
	Canvas.SetPos(Canvas.SizeX * 0.5 - XL / 2, Canvas.SizeY * 0.4 - YL / 2);
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawText(LevelActionPaused);
}

//-----------------------------------------------------------------------------
// PostRender - Added objectives rendering
//-----------------------------------------------------------------------------

simulated event PostRender( canvas Canvas )
{
	local float XPos, YPos;
	local plane OldModulate,OM;
	local color OldColor;
	local int i;

	BuildMOTD();

	OldModulate = Canvas.ColorModulate;
	OldColor = Canvas.DrawColor;

	Canvas.ColorModulate.X = 1;
	Canvas.ColorModulate.Y = 1;
	Canvas.ColorModulate.Z = 1;
	Canvas.ColorModulate.W = HudOpacity/255;

	LinkActors();

	ResScaleX = Canvas.SizeX / 640.0;
	ResScaleY = Canvas.SizeY / 480.0;

	CheckCountDown(PlayerOwner.GameReplicationInfo);

	if (bFadeToBlack)
	    DrawFadeToBlack(Canvas);

	if ( PawnOwner != None && PawnOwner.bSpecialHUD )
		PawnOwner.DrawHud(Canvas);

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetConsoleFont(Canvas);
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor = ConsoleColor;

		PlayerOwner.ViewTarget.DisplayDebug(Canvas, XPos, YPos);
		if (PlayerOwner.ViewTarget != PlayerOwner && (Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).Controller == None))
		{
			YPos += XPos * 2;
			Canvas.SetPos(4, YPos);
			Canvas.DrawText("----- VIEWER INFO -----");
			YPos += XPos;
			Canvas.SetPos(4, YPos);
			PlayerOwner.DisplayDebug(Canvas, XPos, YPos);
		}
	}
	else if( !bHideHud )
	{
	   /* if ( bShowLocalStats )
		{
			if ( LocalStatsScreen == None )
				GetLocalStatsScreen();
			if ( LocalStatsScreen != None )
			{
				OM = Canvas.ColorModulate;
				Canvas.ColorModulate = OldModulate;
				LocalStatsScreen.DrawScoreboard(Canvas);
				DisplayMessages(Canvas);
				Canvas.ColorModulate = OM;
			}
		}
		else*/
		if (bShowScoreBoard)
		{
	        DrawFadeEffect(Canvas);
			if (ScoreBoard != None)
			{
				OM = Canvas.ColorModulate;
				Canvas.ColorModulate = OldModulate;
				ScoreBoard.DrawScoreboard(Canvas);
				if ( Scoreboard.bDisplayMessages )
					DisplayMessages(Canvas);
				Canvas.ColorModulate = OM;
			}
		}
		else
		{
			if ( (PlayerOwner == None) || (PawnOwner == None) || (PawnOwnerPRI == None) || PlayerOwner.IsSpectating() )
				DrawSpectatingHud(Canvas);
			else if( !PawnOwner.bHideRegularHUD )
				DrawHud(Canvas);

			for (i = 0; i < Overlays.length; i++)
				Overlays[i].Render(Canvas);

			if (!DrawLevelAction (Canvas))
			{
				if (PlayerOwner!=None)
				{
					if (PlayerOwner.ProgressTimeOut > Level.TimeSeconds)
					{
	                    DisplayProgressMessages (Canvas);
					}
					else if (MOTDState==1)
						MOTDState=2;
				}
		   }

			if (bShowBadConnectionAlert)
				DisplayBadConnectionAlert (Canvas);
			DisplayMessages(Canvas);

		}

        if( bShowVoteMenu && VoteMenu!=None )
            VoteMenu.RenderOverlays(Canvas);
    }
    else if ( PawnOwner != None )
        DrawInstructionGfx(Canvas);


	// Draw fade effects even if the hud is hidden so poeple can't just turn off thier hud
	if( bHideHud )
	{
    	Canvas.Style = ERenderStyle.STY_Alpha;
    	DrawFadeEffect(Canvas);
	}

	// Render situation map on top of everything (so that
	// it can anim in/out without looking like ass)
	if (bShowObjectives || bAnimateMapIn || bAnimateMapOut)
	{
		DrawObjectives(Canvas);
	}

	PlayerOwner.RenderOverlays(Canvas);

	if (PlayerOwner.bViewingMatineeCinematic)
	DrawCinematicHUD(Canvas);

	if (bDrawHint && !bHideHud)
	    DrawHint(Canvas);

	if (Level.Pauser != none)
	    DrawPaused(Canvas);

	if ((PlayerConsole != None) && PlayerConsole.bTyping)
		DrawTypingPrompt(Canvas, PlayerConsole.TypedStr, PlayerConsole.TypedStrPos);

	if (bCapturingMouse)
		MouseInterfaceDrawCursor(Canvas);

	Canvas.ColorModulate=OldModulate;
	Canvas.DrawColor = OldColor;

	hudLastRenderTime = Level.TimeSeconds;

	if (GUIController(PlayerOwner.Player.GUIController).bLCDAvailable() )
	{
		if (Level.TimeSeconds  - LastLCDUpdateTime > LCDUpdateFreq)
		{
			LastLCDUpdateTime = Level.TimeSeconds;
			DrawLCDUpdate(Canvas);
		}
	}
}

//-----------------------------------------------------------------------------
// CanvasDrawActors - Always set opacity to 1.0 before calling Weapon's PostRender
//-----------------------------------------------------------------------------

function CanvasDrawActors( Canvas C, bool bClearedZBuffer )
{
	local float SavedOpacity;

   // log("PawnOwner = "$PawnOwner$" PawnOwner.Weapon = "$PawnOwner.Weapon);

	if ( !PlayerOwner.bBehindView && PawnOwner.Weapon != None )
	{
		if ( !bClearedZBuffer)
			C.DrawActor(None, false, true); // Clear the z-buffer here

		SavedOpacity = C.ColorModulate.W;
		C.ColorModulate.W = 1.0;
		PawnOwner.Weapon.RenderOverlays( C );
		C.ColorModulate.W = SavedOpacity;
	}
}

//==================================================================
// DisplayProgressMessages(UT) - Had to overload this to function to
//	change the position of the ProgressMessages so they wouldn't be
//	in the middle of the iron sights
//==================================================================

simulated function DisplayProgressMessages (Canvas C)
{
	local int i, LineCount;
	local GameReplicationInfo GRI;
	local float FontDX, FontDY;
	local float X, Y;
	local int Alpha;
	local float TimeLeft;

	TimeLeft = PlayerOwner.ProgressTimeOut - Level.TimeSeconds;

	if( TimeLeft >= ProgressFadeTime )
		Alpha = 255;
	else
		Alpha = (255 * TimeLeft) / ProgressFadeTime;

	GRI = PlayerOwner.GameReplicationInfo;

	LineCount = 0;

	for (i = 0; i < ArrayCount (PlayerOwner.ProgressMessage); i++)
	{
		if (PlayerOwner.ProgressMessage[i] == "")
			continue;

		LineCount++;
	}

	if (bBuiltMOTD && MOTDState<2)
	{
		if (MOTD[0] != "") LineCount++;
		if (MOTD[1] != "") LineCount++;
		if (MOTD[2] != "") LineCount++;
		if (MOTD[3] != "") LineCount++;
	}


	C.Font = LoadProgressFont();

	C.Style = ERenderStyle.STY_Alpha;

	C.TextSize ("A", FontDX, FontDY);

	X = (0.5 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	// changed the Y scale to move the message up
	Y = (0.42 * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);

	Y -= FontDY * (float (LineCount) / 2.0);

	for (i = 0; i < ArrayCount (PlayerOwner.ProgressMessage); i++)
	{
		if (PlayerOwner.ProgressMessage[i] == "")
			continue;

		C.DrawColor = PlayerOwner.ProgressColor[i];
		C.DrawColor.A = Alpha;

		C.TextSize (PlayerOwner.ProgressMessage[i], FontDX, FontDY);
		C.SetPos (X - (FontDX / 2.0), Y);
		C.DrawText (PlayerOwner.ProgressMessage[i]);

		Y += FontDY;
	}

	if( (GRI != None) && (Level.NetMode != NM_StandAlone) && (MOTDState<2) )
	{
		MOTDState=1;
		C.DrawColor = MOTDColor;
		C.DrawColor.A = Alpha;

		for (i=0;i<4;i++)
		{
			C.TextSize (MOTD[i], FontDX, FontDY);
			C.SetPos (X - (FontDX / 2.0), Y);
			C.DrawText (MOTD[i]);
			Y += FontDY;
		}

	}
}


//-----------------------------------------------------------------------------
// DisplayLocalMessage - Adds a fix for non-fade local messages staying on screen
//-----------------------------------------------------------------------------

simulated function DisplayLocalMessages( Canvas C )
{
	local float PosX, PosY, DY, DX;
	local int i, j;
	local float FadeValue;
	local Plane OldCM;

	OldCM=C.ColorModulate;
	C.Reset();
	C.ColorModulate = OldCM;

	// Pass 1: Layout anything that needs it and cull dead stuff.

	for( i = 0; i < ArrayCount(LocalMessages); i++ )
	{
		if( LocalMessages[i].Message == none )
			break;

		LocalMessages[i].Drawn = false;

		if( LocalMessages[i].StringFont == none )
		{
			LayoutMessage( LocalMessages[i], C );
			ExtraLayoutMessage( LocalMessages[i], LocalMessagesExtra[i], C );
		}

		if( LocalMessages[i].StringFont == none )
		{
			log( "LayoutMessage("$LocalMessages[i].Message$") failed!", 'Error' );

			for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
			{
				LocalMessages[j] = LocalMessages[j+1];
				LocalMessagesExtra[j] = LocalMessagesExtra[j+1];
			}
			ClearMessage( LocalMessages[j] );
			i--;
			continue;
		}

		if( LocalMessages[i].Message.default.bFadeMessage )
		{
			FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);

			if( FadeValue <= 0.0 )
			{
				for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
				{
					LocalMessages[j] = LocalMessages[j+1];
					LocalMessagesExtra[j] = LocalMessagesExtra[j+1];
				}
				ClearMessage( LocalMessages[j] );
				i--;
				continue;
			}
		}
		// Fix non-fade messages from staying on screen - butto 7/13/03
		else if (Level.TimeSeconds > LocalMessages[i].EndOfLife)
		{
			for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
			{
				LocalMessages[j] = LocalMessages[j+1];
				LocalMessagesExtra[j] = LocalMessagesExtra[j+1];
			}
			ClearMessage( LocalMessages[j] );
			i--;
			continue;
		}
	}

	// Pass 2: Go through the list and draw each stack:

	for( i = 0; i < ArrayCount(LocalMessages); i++ )
	{
		if( LocalMessages[i].Message == none )
			break;

		if( LocalMessages[i].Drawn )
			continue;

		if( class'Object'.static.ClassIsChildOf(LocalMessages[i].Message, class'ROCriticalMessage'))
		    continue;

		PosX = LocalMessages[i].PosX;
		PosY = LocalMessages[i].PosY;

		if( LocalMessages[i].StackMode == SM_None )
		{
			DrawMessage( C, i, PosX, PosY, DX, DY );
			continue;
		}

		for( j = i; j < ArrayCount(LocalMessages); j++ )
		{
			if( LocalMessages[j].Drawn )
				continue;

			if( LocalMessages[i].PosX != LocalMessages[j].PosX )
				continue;

			if( LocalMessages[i].PosY != LocalMessages[j].PosY )
				continue;

			if( LocalMessages[i].DrawPivot != LocalMessages[j].DrawPivot )
				continue;

			if( LocalMessages[i].StackMode != LocalMessages[j].StackMode )
				continue;

			DrawMessage( C, j, PosX, PosY, DX, DY );

			switch( LocalMessages[j].StackMode )
			{
				case SM_Up:
					PosY -= DY;
					break;

				case SM_Down:
					PosY += DY;
					break;
			}
		}
	}

	// Part 3: go through list in reverse to display ROCriticalMessages in proper order
	for (i = ArrayCount(LocalMessages) - 1; i >= 0; i--)
	{
		if( LocalMessages[i].Drawn )
			continue;

		if( LocalMessages[i].Message == none )
			continue;

		PosX = LocalMessages[i].PosX;
		PosY = LocalMessages[i].PosY;

		if( LocalMessages[i].StackMode == SM_None )
		{
			DrawMessage( C, i, PosX, PosY, DX, DY );
			continue;
		}

		for( j = i; j >= 0 ; j-- )
		{
			if( LocalMessages[j].Drawn )
				continue;

			if( LocalMessages[i].PosX != LocalMessages[j].PosX )
				continue;

			if( LocalMessages[i].PosY != LocalMessages[j].PosY )
				continue;

			if( LocalMessages[i].DrawPivot != LocalMessages[j].DrawPivot )
				continue;

			if( LocalMessages[i].StackMode != LocalMessages[j].StackMode )
				continue;

			DrawMessage( C, j, PosX, PosY, DX, DY );

			switch( LocalMessages[j].StackMode )
			{
				case SM_Up:
					PosY -= DY;
					break;

				case SM_Down:
					// hackish for critical messages
					if (class'Object'.static.ClassIsChildOf(LocalMessages[j].Message, class'ROCriticalMessage'))
					{
					    PosY += LocalMessagesExtra[j].y_offset;
					}
					else
					    PosY += DY;

					break;
			}
		}
	}
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	local int i, count;
	local PlayerReplicationInfo HUDPRI;

	if( Message == none )
		return;

	if( bIsCinematic && !ClassIsChildOf(Message,class'ActionMessage') )
		return;

	if( CriticalString == "" )
	{
		if ( (PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None) )
			HUDPRI = PawnOwner.PlayerReplicationInfo;
		else
			HUDPRI = PlayerOwner.PlayerReplicationInfo;
		if ( HUDPRI == RelatedPRI_1 )
			CriticalString = Message.static.GetRelatedString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		else
			CriticalString = Message.static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	}

	if( bMessageBeep && Message.default.bBeep )
		PlayerOwner.PlayBeepSound();

	if( !Message.default.bIsSpecial )
	{
		if ( PlayerOwner.bDemoOwner )
		{
			for( i=0; i<ConsoleMessageCount; i++ )
				if ( i >= ArrayCount(TextMessages) || TextMessages[i].Text == "" )
					break;

			if ( i > 0 && TextMessages[i-1].Text == CriticalString )
				return;
		}
	    AddTextMessage( CriticalString, Message,RelatedPRI_1 );
		return;
	}

	if (class'Object'.static.ClassIsChildOf(Message, class'ROCriticalMessage') &&
		class'ROCriticalMessage'.default.maxMessagesOnScreen > 0)
	{
		// Check if we have too many critical messages in stack
		count = 0;
		for (i = 0; i < ArrayCount(LocalMessages); i++)
			if (class'Object'.static.ClassIsChildOf(LocalMessages[i].Message, class'ROCriticalMessage'))
				count++;

		if (count >= class'ROCriticalMessage'.default.maxMessagesOnScreen)
		{
			// We have too many critical message -- delete oldest one
			for (i = 0; i < ArrayCount(LocalMessages); i++)
				if (class'Object'.static.ClassIsChildOf(LocalMessages[i].Message, class'ROCriticalMessage'))
					break;
			for (i = i; i < ArrayCount(LocalMessages) - 1; i++)
	        {
		        LocalMessages[i] = LocalMessages[i+1];
		        LocalMessagesExtra[i] = LocalMessagesExtra[i+1];
		    }
	        ClearMessage(LocalMessages[i+1]);
		}
	}

	i = ArrayCount(LocalMessages);
	if( Message.default.bIsUnique )
	{
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
		    if( LocalMessages[i].Message == None )
				continue;

		    if( LocalMessages[i].Message == Message )
				break;
		}
	}
	else if ( Message.default.bIsPartiallyUnique || PlayerOwner.bDemoOwner )
	{
		for( i = 0; i < ArrayCount(LocalMessages); i++ )
		{
		    if( LocalMessages[i].Message == none )
				continue;

		    if( ( LocalMessages[i].Message == Message ) && ( LocalMessages[i].Switch == Switch ) )
				break;
		}
	}

	if( i == ArrayCount(LocalMessages) )
	{
	    for( i = 0; i < ArrayCount(LocalMessages); i++ )
	    {
		    if( LocalMessages[i].Message == none )
				break;
	    }
	}

	if( i == ArrayCount(LocalMessages) )
	{
	    for( i = 0; i < ArrayCount(LocalMessages) - 1; i++ )
	    {
		    LocalMessages[i] = LocalMessages[i+1];
		    LocalMessagesExtra[i] = LocalMessagesExtra[i+1];
		}
	}

	ClearMessage( LocalMessages[i] );

	LocalMessages[i].Message = Message;
	LocalMessages[i].Switch = Switch;
	LocalMessages[i].RelatedPRI = RelatedPRI_1;
	LocalMessages[i].RelatedPRI2 = RelatedPRI_2;
	LocalMessages[i].OptionalObject = OptionalObject;

	// Hackish for ROCriticalMessages
	if (class'Object'.static.ClassIsChildOf(Message, class'ROCriticalMessage') &&
		class<ROCriticalMessage>(Message).default.bQuickFade)
	{
		 LocalMessages[i].LifeTime = Message.static.GetLifetime(Switch) +
			class<ROCriticalMessage>(Message).default.quickFadeTime;
	     LocalMessages[i].EndOfLife = LocalMessages[i].LifeTime + Level.TimeSeconds;

	     // Mild hax: used to show hints when an obj is captured
	     // This was simpliest way of doing it without having server call another
	     // server-to-client function
	     if (class'Object'.static.ClassIsChildOf(Message, class'ROObjectiveMsg') &&
	         (switch == 0 || switch == 1) )
	     {
	         if (ROPlayer(PlayerOwner) != none)
	             ROPlayer(PlayerOwner).CheckForHint(17);
	     }

	}
	else
	{
	     LocalMessages[i].EndOfLife = Message.static.GetLifetime(Switch) + Level.TimeSeconds;
	     LocalMessages[i].LifeTime = Message.static.GetLifetime(Switch);
	}
	LocalMessages[i].StringMessage = CriticalString;
}

simulated function LayoutMessage( out HudLocalizedMessage Message, Canvas C )
{
	local int FontSize;

	FontSize = Message.Message.static.GetFontSize( Message.Switch, Message.RelatedPRI, Message.RelatedPRI2, PlayerOwner.PlayerReplicationInfo );
	FontSize += MessageFontOffset;

	if (class'Object'.static.ClassIsChildOf(Message.Message, class'ROCriticalMessage'))
	    Message.StringFont = GetCriticalMsgFontSizeIndex(C,FontSize);
    else
        Message.StringFont = GetFontSizeIndex(C,FontSize);

	Message.DrawColor = Message.Message.static.GetColor( Message.Switch, Message.RelatedPRI, Message.RelatedPRI2 );
	Message.Message.static.GetPos( Message.Switch, Message.DrawPivot, Message.StackMode, Message.PosX, Message.PosY );
	C.Font = Message.StringFont;
	C.TextSize( Message.StringMessage, Message.DX, Message.DY );
}

simulated function ExtraLayoutMessage( out HudLocalizedMessage Message, out HudLocalizedMessageExtra MessageExtra, Canvas C)
{
	local array<string> lines;
	local float tempXL, tempYL, initialXL, XL, YL;
	local int i, initialNumLines, j;

	//log("Setting layout for string: " $ MEssage.StringMessage);

	// Hackish for ROCriticalMessages
	if (class'Object'.static.ClassIsChildOf(Message.Message, class'ROCriticalMessage'))
	{
		// Set a random background type
		MessageExtra.background_type = rand(4);

		// Figure what width to use to break the string at
		initialXL = Message.DX;
		tempXL = min(initialXL, C.SizeX * class'ROCriticalMessage'.default.maxMessageWidth);
		if (tempXL < Message.DY * 8) // only wrap if we have enough text
		{
			MessageExtra.lines.length = 1;
			MessageExtra.lines[0] = Message.StringMessage;
		}
		else
		{
			lines.Length = 0;
			C.WrapStringToArray(Message.StringMessage, lines, tempXL);
			initialNumLines = lines.length;

			for (i = 0; i < 20; i++)
			{
				tempXL *= 0.8;
				lines.Length = 0;
				C.WrapStringToArray(Message.StringMessage, lines, tempXL);
				//log("Testing with width of " $ tempXL);
				//log("Number of resulting lines: " $ lines.Length);
				if (lines.Length > initialNumLines)
				{
					// If we're getting more than initialNumLines lines, it means we
					// should use the previously calculated width
					lines.Length = 0;
					C.WrapStringToArray(Message.StringMessage, lines, Message.DX);
					//log("Wrapping using previous width gives us: " $ lines.Length $ " lines.");

					// Save strings to message array + calculate resulting XL/YL
					MessageExtra.lines.Length = lines.Length;
					C.Font = Message.StringFont;
					XL = 0;
					YL = 0;
					for (j = 0; j < lines.Length; j++)
					{
						//log("Line #" $ j $ " = " $ lines[j]);
						MessageExtra.lines[j] = lines[j];
						C.TextSize(lines[j], tempXL, tempYL);
						XL = max(tempXL, XL);
						YL += tempYL;
					}

					Message.DX = XL;
					Message.DY = YL;

					break;
				}
				Message.DX = tempXL; // store temporarily
			}
		}
	}
}

function Font GetCriticalMsgFontSizeIndex(Canvas C, int FontSize)
{
    if ( C.ClipX >= 512 )
		FontSize++;
	if ( C.ClipX >= 640 )
		FontSize++;
	if ( C.ClipX >= 800 )
		FontSize++;
	if ( C.ClipX >= 1024 )
		FontSize++;
	if ( C.ClipX >= 1280 )
		FontSize++;
	if ( C.ClipX >= 1600 )
		FontSize++;

	return LoadCriticalMsgFont(Clamp( 8-FontSize, 0, 8));
}

simulated function Font LoadCriticalMsgFont(int i)
{
	if ( CriticalMsgFontArrayFonts[i] == none )
	{
		CriticalMsgFontArrayFonts[i] = Font(DynamicLoadObject(CriticalMsgFontArrayNames[i], class'Font'));
		if( CriticalMsgFontArrayFonts[i] == none )
			Log("Warning: "$Self$" Couldn't dynamically load font "$CriticalMsgFontArrayNames[i]);
	}
	return CriticalMsgFontArrayFonts[i];
}

simulated function DrawMessage( Canvas C, int i, float PosX, float PosY, out float DX, out float DY )
{
	local float FadeValue;
	local float ScreenX, ScreenY;

	if ( !LocalMessages[i].Message.default.bFadeMessage )
		C.DrawColor = LocalMessages[i].DrawColor;
	else if (class'Object'.static.ClassIsChildOf(LocalMessages[i].Message, class'ROCriticalMessage') &&
		class<ROCriticalMessage>(LocalMessages[i].Message).default.bQuickFade)
	{
	    FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds) /
			class<ROCriticalMessage>(LocalMessages[i].Message).default.quickFadeTime;
		if (FadeValue > 1)
			FadeValue = 1;
		C.DrawColor = LocalMessages[i].DrawColor;
		C.DrawColor.A = LocalMessages[i].DrawColor.A * FadeValue;
	}
	else
	{
		FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
		C.DrawColor = LocalMessages[i].DrawColor;
		C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue/LocalMessages[i].LifeTime);
	}

	C.Font = LocalMessages[i].StringFont;
	GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
	C.SetPos( ScreenX, ScreenY );
	DX = LocalMessages[i].DX / C.ClipX;
	DY = LocalMessages[i].DY / C.ClipY;

	if ( class'Object'.static.ClassIsChildOf(LocalMessages[i].Message, class'ROCriticalMessage') )
	{
	    class<ROCriticalMessage>(LocalMessages[i].Message).static.RenderComplexMessageExtra(
			C, LocalMessages[i].DX, LocalMessages[i].DY, LocalMessagesExtra[i].y_offset,
			LocalMessages[i].Switch, LocalMessages[i].RelatedPRI,
			LocalMessages[i].RelatedPRI2, LocalMessages[i].OptionalObject,
			LocalMessagesExtra[i].lines, LocalMessagesExtra[i].background_type );
	}
	else if ( LocalMessages[i].Message.default.bComplexString )
	{
		LocalMessages[i].Message.static.RenderComplexMessage( C, LocalMessages[i].DX, LocalMessages[i].DY,
			LocalMessages[i].StringMessage, LocalMessages[i].Switch, LocalMessages[i].RelatedPRI,
			LocalMessages[i].RelatedPRI2, LocalMessages[i].OptionalObject );
	}
	else
	{
		C.DrawTextClipped( LocalMessages[i].StringMessage, false );
	}

	LocalMessages[i].Drawn = true;
}

//-----------------------------------------------------------------------------
// DrawSpectatingHud - Display messages and timer
//-----------------------------------------------------------------------------

simulated function DrawSpectatingHud(Canvas C)
{
	local ROGameReplicationInfo GRI;
	local float Time, strX, strY, X, Y, Scale;
	local string S;
	local ROPlayer Playa;
	local float SmallH, NameWidth;
	local float XL;

	// Draw fade effects
	C.Style = ERenderStyle.STY_Alpha;
	DrawFadeEffect(C);

	Scale = C.ClipX / 1600.0;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if (GRI != None)
	{
		// Update round timer
		if (!GRI.bMatchHasBegun)
			CurrentTime = GRI.RoundStartTime + GRI.PreStartTime - GRI.ElapsedTime;
		else
			CurrentTime = GRI.RoundStartTime + GRI.RoundDuration - GRI.ElapsedTime;

		S = default.TimeRemainingText $ GetTimeString(CurrentTime);

		X = 8 * Scale;
		Y = 8 * Scale;

		C.DrawColor = WhiteColor;
		C.Font = GetConsoleFont(C);
		C.TextSize(S, strX, strY);
		C.SetPos(X, Y);
		C.DrawTextClipped(S);

		if (GRI.bMatchHasBegun && ROPlayer(PlayerOwner) != None && ROPlayer(PlayerOwner).CanRestartPlayer()
			&& PlayerOwner.PlayerReplicationInfo.Team != none && GRI.bReinforcementsComing[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] == 1)
		{
			Time = GRI.LastReinforcementTime[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] + GRI.ReinforcementInterval[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] - GRI.ElapsedTime;
			S = default.ReinforcementText $ GetTimeString(Time);

			Y += 4 * Scale + strY;
			//C.TextSize(S, strX, strY);
			C.SetPos(X, Y);
			C.DrawTextClipped(S);
		}
	}

	if (PlayerOwner.ViewTarget != PlayerOwner.Pawn && PawnOwner != None && PawnOwner.PlayerReplicationInfo != None)
	{
		S = ViewingText $ PawnOwner.PlayerReplicationInfo.PlayerName;
		C.DrawColor = WhiteColor;
		C.Font = GetConsoleFont(C);
		C.TextSize(S, strX, strY);
		C.SetPos(C.ClipX / 2 - strX / 2, C.ClipY - 8 * scale - strY);
		C.DrawTextClipped(S);
	}

	Playa = ROPlayer(PlayerOwner);

	// Rough spectate hud stuff. TODO: Refine this so its not so plane
	if( Playa != none )
	{
		S = Playa.GetSpecModeDescription();
		C.DrawColor = WhiteColor;
		C.Font = GetLargeMenuFont(C);

		X = C.ClipX * 0.5;
		Y = C.ClipY * 0.1;

		C.TextSize(S, strX, strY);
		C.SetPos(X - strX / 2, Y  - strY);
		C.DrawTextClipped(S);

		// Draw line 1
		S = SpectateInstructionText1;
		C.Font = GetConsoleFont(C);

		X = C.ClipX * 0.5;
		Y = C.ClipY * 0.90;

		C.TextSize(S, strX, strY);
		C.SetPos(X - strX / 2, Y  - strY);
		C.DrawTextClipped(S);

		// Draw line 2
		S = SpectateInstructionText2;
		X = C.ClipX * 0.5;
		Y += strY + (3 * scale);

		C.TextSize(S, strX, strY);
		C.SetPos(X - strX / 2, Y  - strY);
		C.DrawTextClipped(S);

		// Draw line 3
		S = SpectateInstructionText3;
		X = C.ClipX * 0.5;
		Y += strY + (3 * scale);

		C.TextSize(S, strX, strY);
		C.SetPos(X - strX / 2, Y  - strY);
		C.DrawTextClipped(S);

		// Draw line 4
		S = SpectateInstructionText4;
		X = C.ClipX * 0.5;
		Y += strY + (3 * scale);

		C.TextSize(S, strX, strY);
		C.SetPos(X - strX / 2, Y  - strY);
		C.DrawTextClipped(S);
	}

    // Draw the players name large if thier are viewing someone else in first person
    if ( (PawnOwner != None) && (PawnOwner != PlayerOwner.Pawn)
		&& (PawnOwner.PlayerReplicationInfo != None) && !PlayerOwner.bBehindView)
	{
		// draw viewed player name
	    C.Font = GetMediumFontFor(C);
		C.SetDrawColor(255,255,0,255);
		C.StrLen(PawnOwner.PlayerReplicationInfo.PlayerName,NameWidth,SmallH);
		NameWidth = FMax(NameWidth, 0.15 * C.ClipX);
		if ( C.ClipX >= 640 )
		{
			C.Font = GetConsoleFont(C);
			C.StrLen("W",XL,SmallH);
			C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68);
			C.DrawText(NowViewing,false);
		}

		C.Font = GetMediumFontFor(C);
		C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68 + SmallH);
		C.DrawText(PawnOwner.PlayerReplicationInfo.PlayerName,false);
	}

	// Draw hints
	if (bDrawHint)
		DrawHint(C);

	DisplayLocalMessages(C);
}

//-----------------------------------------------------------------------------
// GetTimeString
//-----------------------------------------------------------------------------

static function string GetTimeString(float Time)
{
	local string S;

	Time = FMax(0.0, Time);

	S = int(Time / 60) $ ":";

	Time = Time % 60;

	if (Time < 10)
		S = S $ "0" $ int(Time);
	else
		S = S $ int(Time);

	return S;
}

//-----------------------------------------------------------------------------
// DrawTimer - Draws the clock
//-----------------------------------------------------------------------------

simulated function DrawTimer(Canvas C)
{
	//DrawSpriteWidget(C, ClockBase);
	//DrawSpriteWidget(C, ClockHand);
}

//-----------------------------------------------------------------------------
// GetConsoleFont - Use the small font array
//-----------------------------------------------------------------------------

static function font GetConsoleFont(Canvas C)
{
	local int FontSize;

	FontSize = Default.ConsoleFontSize;
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	return LoadSmallFontStatic(Min(8,FontSize));
}

//-----------------------------------------------------------------------------
// GetLargeMenuFont - Gets a large menu font
//-----------------------------------------------------------------------------

static function font GetLargeMenuFont(Canvas C)
{
	local int FontSize;

	//FontSize = Default.ConsoleFontSize;
//	if ( C.ClipX < 640 )
//		FontSize = 0;
	if ( C.ClipX < 800 )
		FontSize = 5;
	else if ( C.ClipX < 1024 )
		FontSize = 4;
	else if ( C.ClipX < 1280 )
		FontSize = 3;
	else if ( C.ClipX < 1600 )
		FontSize = 2;
	else
		FontSize = 1;

	return LoadFontStatic(Min(8,FontSize));
}

//-----------------------------------------------------------------------------
// GetSmallMenuFont - Gets a large menu font
//-----------------------------------------------------------------------------

static function font GetSmallMenuFont(Canvas C)
{
	local int FontSize;

	//FontSize = Default.ConsoleFontSize;
//	if ( C.ClipX < 640 )
//		FontSize = 0;
	if ( C.ClipX < 800 )
		FontSize = 4;
	else if ( C.ClipX < 1024 )
		FontSize = 3;
	else if ( C.ClipX < 1280 )
		FontSize = 2;
	else if ( C.ClipX < 1600 )
		FontSize = 1;
	else
		FontSize = 0;

	return LoadMenuFontStatic(FontSize);
}

static function font GetSmallerMenuFont(Canvas C)
{
	local int FontSize;

	//FontSize = Default.ConsoleFontSize;
//	if ( C.ClipX < 640 )
//		FontSize = 0;
	if ( C.ClipX < 800 )
//		FontSize = 5;
		FontSize = 4;
	else if ( C.ClipX < 1024 )
		FontSize = 4;
	else if ( C.ClipX < 1280 )
		FontSize = 3;
	else if ( C.ClipX < 1600 )
		FontSize = 2;
	else
		FontSize = 1;

	return LoadMenuFontStatic(FontSize);
}

//-----------------------------------------------------------------------------
// LoadSmallFontStatic - Loads from the new small font array
//-----------------------------------------------------------------------------

static function Font LoadSmallFontStatic(int i)
{
	if( default.SmallFontArrayFonts[i] == None )
	{
		default.SmallFontArrayFonts[i] = Font(DynamicLoadObject(default.SmallFontArrayNames[i], class'Font'));
		if( default.SmallFontArrayFonts[i] == none )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.SmallFontArrayNames[i]);
	}

	return default.SmallFontArrayFonts[i];
}

//-----------------------------------------------------------------------------
// LoadMenuFontStatic - Loads from the new small font array
//-----------------------------------------------------------------------------

static function Font LoadMenuFontStatic(int i)
{
	if( default.MenuFontArrayFonts[i] == None )
	{
		default.MenuFontArrayFonts[i] = Font(DynamicLoadObject(default.MenuFontArrayNames[i], class'Font'));
		if( default.MenuFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.MenuFontArrayNames[i]);
	}

	return default.MenuFontArrayFonts[i];
}

//-----------------------------------------------------------------------------
// Message - Changed message classes
//-----------------------------------------------------------------------------

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local Class<LocalMessage> MessageClassType;

	switch( MsgType )
	{
		case 'Say':
			Msg = PRI.PlayerName$": "$Msg;
			MessageClassType = class'ROSayMessage';
			break;
		case 'TeamSay':
			/*if (PRI.GetLocationName() == "")
				Msg = TeamMessagePrefix$PRI.PlayerName$": "$Msg;
			else
				Msg = TeamMessagePrefix$PRI.PlayerName$" ("$PRI.GetLocationName()$"): "$Msg;*/
			MessageClassType = class'ROTeamSayMessage';
			Msg = MessageClassType.static.AssembleString(self,, PRI, Msg);
			break;
		case 'SayDead':
			//Msg = PRI.PlayerName$": "$Msg;
			MessageClassType = class'ROSayDeadMessage';
			Msg = MessageClassType.static.AssembleString(self,, PRI, Msg);
			break;
		case 'TeamSayDead':
			/*if (PRI.GetLocationName() == "")
				Msg = TeamMessagePrefix$PRI.PlayerName$": "$Msg;
			else
				Msg = TeamMessagePrefix$PRI.PlayerName$" ("$PRI.GetLocationName()$"): "$Msg;*/
			MessageClassType = class'ROTeamSayDeadMessage';
			Msg = MessageClassType.static.AssembleString(self,, PRI, Msg);
			break;
		case 'VehicleSay':
			MessageClassType = class'ROVehicleSayMessage';
			Msg = MessageClassType.static.AssembleString(self,, PRI, Msg);
			break;
		case 'CriticalEvent':
			MessageClassType = class'CriticalEventPlus';
			LocalizedMessage( MessageClassType, 0, None, None, None, Msg );
			return;
		case 'DeathMessage':
			return;
			//MessageClassType = class'RODeathMessage';
			//break;
		default:
			MessageClassType = class'ROStringMessage';
			break;
	}

	AddTextMessage(Msg,MessageClassType,PRI);
}

//====================================================================
// DrawWeaponName(UT) - Antarian 10/11/03 - Overloaded to fix the RO weapon
//	names from showing up with ut colors, font and font size
//====================================================================
simulated function DrawWeaponName(Canvas C)
{
	local string CurWeaponName;
	local float XL,YL, Fade;

	if (bHideWeaponName)
		return;

// THINK ABOUT A FUTURE OPTION TO LET PEOPLE DISABLE MESSAGES
// OR MAKE THE MESSAGE SIZE SMALLER
	if (WeaponDrawTimer>Level.TimeSeconds)
	{
		C.DrawColor = WhiteColor;
		C.Font = GetMediumFontFor(C);
		C.TextSize(CurWeaponName, XL, YL);

		Fade = WeaponDrawTimer - Level.TimeSeconds;

		if (Fade<=1)
			C.DrawColor.A = 255 * Fade;


		C.Strlen(LastWeaponName,XL,YL);
		C.SetPos( (C.ClipX/2) - (XL/2), C.ClipY*0.8-YL);
		C.DrawText(LastWeaponName);
	}

	if (  PawnOwner==None || PawnOwner.PendingWeapon==None )
		return;

	CurWeaponName = PawnOwner.PendingWeapon.GetHumanReadableName();
	if (CurWeaponName!=LastWeaponName)
	{
		WeaponDrawTimer = Level.TimeSeconds+1.5;
		WeaponDrawColor = PawnOwner.PendingWeapon.HudColor;
	}

   	LastWeaponName = CurWeaponName;
}

// show full screen red flash
// this Overrides the HudBase definition, where the hit indicators are shown
function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	if ( Damage > 1 )
	{
		PlayerOwner.ClientFlash(DamageType.Default.FlashScale,DamageType.Default.FlashFog);
	}
}


// Comment Out for Release
simulated function DrawCrosshair (Canvas C)
{
	/*local float NormalScale;
	local int i, CurrentCrosshair;
	local float OldScale,OldW, CurrentCrosshairScale;
	local color CurrentCrosshairColor;
	local SpriteWidget CHtexture;

	if (!bCrosshairShow || !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	if ( (PawnOwner != None) && (PawnOwner.Weapon != None) && (PawnOwner.Weapon.CustomCrosshair >= 0) )
	{
		CurrentCrosshairColor = PawnOwner.Weapon.CustomCrosshairColor;
		CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
		CurrentCrosshairScale = PawnOwner.Weapon.CustomCrosshairScale;
		if ( PawnOwner.Weapon.CustomCrosshairTextureName != "" )
		{
			if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
			{
				PawnOwner.Weapon.CustomCrosshairTexture = Texture(DynamicLoadObject(PawnOwner.Weapon.CustomCrosshairTextureName,class'Texture'));
				if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
				{
					log(PawnOwner.Weapon$" custom crosshair texture not found!");
					PawnOwner.Weapon.CustomCrosshairTextureName = "";
				}
			}
			CHTexture = Crosshairs[0];
			CHTexture.WidgetTexture = PawnOwner.Weapon.CustomCrosshairTexture;
		}
	}
	else
	{
		CurrentCrosshair = CrosshairStyle;
		CurrentCrosshairColor = CrosshairColor;
		CurrentCrosshairScale = CrosshairScale;
	}

	CurrentCrosshair = Clamp(CurrentCrosshair, 0, Crosshairs.Length - 1);

	NormalScale = Crosshairs[CurrentCrosshair].TextureScale;
	if ( CHTexture.WidgetTexture == None )
		CHTexture = Crosshairs[CurrentCrosshair];
	CHTexture.TextureScale *= CurrentCrosshairScale;

	for( i = 0; i < ArrayCount(CHTexture.Tints); i++ )
		CHTexture.Tints[i] = CurrentCrossHairColor;

	OldScale = HudScale;
	HudScale=1;
	OldW = C.ColorModulate.W;
	C.ColorModulate.W = 1;
	DrawSpriteWidget (C, CHTexture);
	C.ColorModulate.W = OldW;
	HudScale=OldScale;
	CHTexture.TextureScale = NormalScale;*/

	//DrawEnemyName(C);
}

// FIXME: We need to look at something a lot better than using UT2004 portraits.  Really kills the atmosphere.
/*simulated function Tick(float deltaTime)
{
	//local Material NewPortrait;

	Super.Tick(deltaTime);

	// Setup the player portrait to display an incoming voice chat message
	if ( (Level.TimeSeconds - LastPlayerIDTalkingTime < 0.1) && (PlayerOwner.GameReplicationInfo != None) )
	{
		if ( (PortraitPRI == None) || (PortraitPRI.PlayerID != LastPlayerIDTalking) )
		{
		    if (PortraitPRI == none)
		        PortraitX = 1;
			PortraitPRI = PlayerOwner.GameReplicationInfo.FindPlayerByID(LastPlayerIDTalking);
			if ( PortraitPRI != None )
			{
			    PortraitTime = Level.TimeSeconds + 3;
				//NewPortrait = PortraitPRI.GetPortrait();
				//if ( NewPortrait != None )
				//{
				//	if ( Portrait == None )
				//		PortraitX = 1;
				//	Portrait = NewPortrait;
				//	PortraitTime = Level.TimeSeconds + 3;
				//}
			}
		}
		else
			PortraitTime = Level.TimeSeconds + 0.2;
	}
	else
		LastPlayerIDTalking = 0;

	if ( PortraitTime - Level.TimeSeconds > 0 )
		PortraitX = FMax(0,PortraitX-3*deltaTime);
	else if ( PortraitPRI != None )
	{
		PortraitX = FMin(1,PortraitX+3*deltaTime);
		if ( PortraitX == 1 )
		{
			//Portrait = None;
			PortraitPRI = None;
		}
	}
}*/

function DisplayPortrait(PlayerReplicationInfo PRI)
{
	//local Material NewPortrait;

	if ( LastPlayerIDTalking > 0 )
		return;

	if (PRI == none)
		return;

	//NewPortrait = PRI.GetPortrait();
	//if ( NewPortrait == None )
	//	return;
	//if ( Portrait == None )
	//	PortraitX = 1;
	if (PortraitPRI == none)
	    PortraitX = 1;
	//Portrait = NewPortrait;
	PortraitTime = Level.TimeSeconds + 3;
	PortraitPRI = PRI;
}

// Test0r! find a random player and display a portrait for him
/*
exec function testPortrait()
{
	local controller c;
	for (c = level.ControllerList; c != none; c = c.nextController)
	{
		if (c.PlayerReplicationInfo != none && c != PlayerOwner)
		{
			DisplayPortrait(c.PlayerReplicationInfo);
			break;
		}
	}
}*/

// test0r! sends a local message for 'weapon shot out of hands'
/*exec function testMessage()
{
	ROPlayer(PawnOwner.Controller).ReceiveLocalizedMessage(class'ROWeaponLostMessage');
	//ROPlayer(PawnOwner.Controller).ReceiveLocalizedMessage(LocalMessage(DynamicLoadObject("ROWeaponLostMessage", class'LocalMessage')));

	ROPlayer(PawnOwner.Controller).ReceiveLocalizedMessage(class'ROTestCriticalMessage', Rand(4));
}*/

/*
// test0r! this function dumps the content of the helprequests, rally points, etc arrays
exec function testReplication()
{
	local ROGameReplicationInfo GRI;
	local int i;
	local string s;
	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	log("Dumping content of rally points arrays...");
	for (i = 0; i < arraycount(GRI.AlliedRallyPoints); i++)
	{
		if (GRI.AlliedRallyPoints[i].RallyPointLocation != vect(0,0,0))
		{
			s = "AlliedRallyPoints[" $ i $ "].RallyPointLocation = " $ GRI.AlliedRallyPoints[i].RallyPointLocation;
			log(s); Message(PlayerOwner.PlayerReplicationInfo, s, 'TEAM');
		}
		if (GRI.AxisRallyPoints[i].RallyPointLocation != vect(0,0,0))
		{
			s = "AxisRallyPoints[" $ i $ "].RallyPointLocation = " $ GRI.AxisRallyPoints[i].RallyPointLocation;
			log(s); Message(PlayerOwner.PlayerReplicationInfo, s, 'TEAM');
		}
	}

	log("Dumping content of help requests arrays...");
	for (i = 0; i < arraycount(GRI.AlliedHelpRequests); i++)
	{
		if (GRI.AlliedHelpRequests[i].requestType != 255)
		{
			s = "AlliedHelpRequests[" $ i $ "].requestType = " $ GRI.AlliedHelpRequests[i].requestType;
			s = s $ ", .objectiveID = " $ GRI.AlliedHelpRequests[i].objectiveID;
			s = s $ ", .reqLoc = " $ GRI.AlliedHelpRequestsLocs[i];
			log(s); Message(PlayerOwner.PlayerReplicationInfo, s, 'TEAM');
		}
		if (GRI.AxisHelpRequests[i].requestType != 255)
		{
			s = "AxisHelpRequests[" $ i $ "].requestType = " $ GRI.AxisHelpRequests[i].requestType;
			s = s $ ", .objectiveID = " $ GRI.AxisHelpRequests[i].objectiveID;
			s = s $ ", .reqLoc = " $ GRI.AxisHelpRequestsLocs[i];
			log(s); Message(PlayerOwner.PlayerReplicationInfo, s, 'TEAM');
		}
	}
}*/

// Test0r! Tests a body hit, number = body part id (-1 == all)
/*exec function testHits(byte num)
{
	if( ROPawn(PawnOwner) != none )
	{
		ROPawn(PawnOwner).ClientUpdateDamageList(num);
	}
}

// Test0r! test menu.
exec function testMenu(optional string menu)
{
	if (menu == "")
		PlayerOwner.ClientOpenMenu("ROInterface.ROTestMenu");
	else
		PlayerOwner.ClientOpenMenu(menu);
}*/

// Functions used to draw widgets inside a certain region
function DrawSpriteWidgetClipped(Canvas C, SpriteWidget widget, AbsoluteCoordsInfo coords, optional bool bUseTexScaleAsScreenScale, optional out float XL, optional out float YL, optional bool bUseAbsoluteOffsets, optional bool bKeepAspectRatio, optional bool bUseHUDScaling, optional bool bGetSizesOnly)
{
	local float ScreenX, ScreenY, ScreenXL, ScreenYL;
	local float TexX,TexY, TexXL, TexYL;
	local float ScaleModifier;

	// Figure where we want to draw
	ScreenX = coords.width * widget.PosX;
	ScreenY = coords.height * widget.PosY;

	if (bUseHUDScaling)
		ScaleModifier = HudScale;
	else
		ScaleModifier = 1.0;

	// Figure offset
	if (bUseAbsoluteOffsets)
	{
		ScreenX += widget.OffsetX * ScaleModifier;
		ScreenY += widget.OffsetY * ScaleModifier;
	}
	else
	{
		ScreenX += widget.OffsetX * widget.TextureScale * ScaleModifier;
		ScreenY += widget.OffsetY * widget.TextureScale * ScaleModifier;
	}

	// Figure texture source coords
	TexX = widget.TextureCoords.X1;
	TexY = widget.TextureCoords.Y1;
	TexXL = widget.TextureCoords.X2 - widget.TextureCoords.X1 + 1;
	TexYL = widget.TextureCoords.Y2 - widget.TextureCoords.Y1 + 1;

	// Figure screen width & height
	if (bUseTexScaleAsScreenScale)
	{
		ScreenYL = coords.height * widget.TextureScale;
		if (bKeepAspectRatio)
			ScreenXL = ScreenYL * TexXL / TexYL;
		else
			ScreenXL = coords.width * widget.TextureScale;
	}
	else
	{
		ScreenYL = abs(TexYL) * widget.TextureScale;
		if (bKeepAspectRatio)
			ScreenXL = ScreenYL * TexXL / TexYL;
		else
			ScreenXL = abs(TexXL) * widget.TextureScale;
	}
	ScreenXL *= ScaleModifier;
	ScreenYL *= ScaleModifier;
	XL = ScreenXL; YL = ScreenYL;

	// Offset depending on pivot type
	CalcPivotCoords(widget.DrawPivot, ScreenX, ScreenY, ScreenXL, ScreenYL);

	// Offset by wanted coordinates
	ScreenX += coords.PosX;
	ScreenY += coords.PosY;

    // Set scale
    switch (widget.ScaleMode)
    {
        case SM_None:
            break;

        case SM_Up:
            ScreenY += (1.0 - widget.Scale) * ScreenYL;
            ScreenYL *= widget.Scale;
            TexY += (1.0 - widget.Scale) * TexYL;
            TexYL *= widget.Scale;
            break;

        case SM_Down:
            ScreenYL *= widget.Scale;
            TexYL *= widget.Scale;
            break;

        case SM_Left:
            ScreenX += (1.0 - widget.Scale) * ScreenXL;
            ScreenXL *= widget.Scale;
            TexX += (1.0 - widget.Scale) * TexXL;
            TexXL *= widget.Scale;
            break;

        case SM_Right:
            ScreenXL *= widget.Scale;
            TexXL *= widget.Scale;
            break;
    }

	if (!bGetSizesOnly)
	{
    	// Set canvas info
    	C.CurX = ScreenX;
    	C.CurY = ScreenY;
    	C.DrawColor = widget.Tints[TeamIndex];
    	C.Style = widget.RenderStyle;

    	// Render!
        C.DrawTile(widget.WidgetTexture, ScreenXL, ScreenYL, TexX, TexY, TexXL, TexYL);
    }
}

function CalcPivotCoords(EDrawPivot DrawPivot, out float ScreenX, out float ScreenY, float ScreenXL, float ScreenYL)
{
	switch (DrawPivot)
	{
		case DP_UpperLeft:
			break;

		case DP_UpperMiddle:
			ScreenX -= ScreenXL * 0.5;
			break;

		case DP_UpperRight:
			ScreenX -= ScreenXL;
			break;

		case DP_MiddleRight:
			ScreenX -= ScreenXL;
			ScreenY -= ScreenYL * 0.5;
			break;

		case DP_LowerRight:
			ScreenX -= ScreenXL;
			ScreenY -= ScreenYL;
			break;

		case DP_LowerMiddle:
			ScreenX -= ScreenXL * 0.5;
			ScreenY -= ScreenYL;
			break;

		case DP_LowerLeft:
			ScreenY -= ScreenYL;
			break;

		case DP_MiddleLeft:
			ScreenY -= ScreenYL * 0.5;
			break;

		case DP_MiddleMiddle:
			ScreenX -= ScreenXL * 0.5;
			ScreenY -= ScreenYL * 0.5;
			break;

		default:
			break;
	}
}

function DrawTextWidgetClipped(Canvas C, TextWidget widget, AbsoluteCoordsInfo coords, optional out float XL, optional out float YL, optional out float YL_oneline, optional bool bNoRender)
{
	local float ScreenX, ScreenY, ScreenXL, ScreenYL;
	local float oldClipX, oldClipY, oldOrgX, oldOrgY, myXL, myYL;

	// Calculate where we want to write
	ScreenX = coords.width * widget.PosX;
	ScreenY = coords.height * widget.PosY;

	// Save old canvas settings
	oldClipX = C.ClipX; oldClipY = C.ClipY;
	oldOrgX = C.OrgX; oldOrgY = C.OrgY;

	// Check if we should wrap
	if (widget.WrapWidth ~= 0)
	{
		// Calculate text size
		C.TextSize(widget.text, ScreenXL, ScreenYL);
		YL_oneline = ScreenYL;
		XL = ScreenXL; YL = ScreenYL;
	}
	else
	{
		// Calculate text size
		ScreenXL = coords.width * widget.WrapWidth;
		C.ClipX = ScreenXL;
		C.TextSize(widget.text, myXL, YL_oneline); // only used to fill YL_oneline variable
		C.StrLen(widget.text, myXL, myYL);
		XL = myXL; YL = myYL;
		ScreenYL = myYL;
	}

	// Calculate offsets
	ScreenX += widget.OffsetX + coords.PosX;
	ScreenY += widget.OffsetY + coords.PosY;

	CalcPivotCoords(widget.DrawPivot, ScreenX, ScreenY, ScreenXL, ScreenYL);

	//log("ScreenX = " $ ScreenX $ ", ScreenY = " $ ScreenY $ ", ScreenXL = " $ ScreenXL $ ", ScreenYL = " $ ScreenYL);
	//log("C.OrgX = " $ C.OrgX $ ", C.OrgY = " $ C.OrgY);

	// Draw bounding box if needed
	if (bDebugDrawHudBounds)
	{
		C.SetPos(ScreenX + C.OrgX, ScreenY + C.OrgY);
		C.DrawColor = RedColor;
//		c.DrawTileStretched(Material'InterfaceArt_tex.HUD.white_border_alpha', ScreenXL, ScreenYL);
		C.DrawColor = widget.Tints[TeamIndex];
	}


	// Draw the text
	C.DrawColor = widget.Tints[TeamIndex];
	C.Style = widget.RenderStyle;
	C.SetOrigin(ScreenX + C.OrgX, ScreenY + C.OrgY);
	C.SetClip(ScreenXL, ScreenYL);
	C.SetPos(0,0);

    if (widget.bDrawShadow && !bNoRender)
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		C.SetOrigin(C.OrgX + 1, C.OrgY + 1);
		C.SetPos(0,0);
		C.DrawText(widget.text);
		C.SetOrigin(C.OrgX - 1, C.OrgY - 1);
		C.SetPos(0,0);
		C.DrawColor = widget.Tints[TeamIndex];
	}

    if (!bNoRender)
	C.DrawText(widget.text);

	// Restore old canvas settings
	C.SetOrigin(oldOrgX, oldOrgY);
	C.SetClip(oldClipX, oldClipY);
}

// Transform from one set of absolute coordinate into another
// X, Y, XL and YL are in the 0-1 range.
function GetAbsoluteCoordinates(AbsoluteCoordsInfo reference, float X, float Y, float XL, float YL, out AbsoluteCoordsInfo coords)
{
	coords.PosX = reference.PosX + X * reference.width;
	coords.PosY = reference.PosY + Y * reference.height;
	coords.width = reference.width * XL;
	coords.height = reference.height * YL;
}

// Transform from one set of absolute coordinate into another
// using a set of relative coordinates
function GetAbsoluteCoordinatesAlt(AbsoluteCoordsInfo reference, RelativeCoordsInfo relative, out AbsoluteCoordsInfo coords)
{
	coords.PosX = reference.PosX + relative.X * reference.width;
	coords.PosY = reference.PosY + relative.Y * reference.height;
	coords.width = reference.width * relative.XL;
	coords.height = reference.height * relative.YL;
}

function MouseInterfaceStartCapturing()
{
	bCapturingMouse = true;
	bHaveAtLeastOneValidMouseUpdate = false;
	ROPlayer(PlayerOwner).bHudCapturesMouseInputs = true;
}

function MouseInterfaceStopCapturing()
{
	ROPlayer(PlayerOwner).bHudCapturesMouseInputs = false;
	bCapturingMouse = false;
	MouseInterfaceUnlockPlayerRotation();
}

function MouseInterfaceUpdatePosition(vector newPos)
{
	local float PosX, PosY;

	MouseCurrentPos = newPos;
	bHaveAtLeastOneValidMouseUpdate = true;

	if (bShowObjectives)
	{
		PosX = MouseCurrentPos.X + LastHUDSizeX * 0.5;
		PosY = MouseCurrentPos.Y + LastHUDSizeY * 0.5;

		if (PosX > MapLevelImageCoordinates.PosX &&
			PosY > MapLevelImageCoordinates.PosY &&
			PosX < MapLevelImageCoordinates.width + MapLevelImageCoordinates.PosX &&
			PosY < MapLevelImageCoordinates.height + MapLevelImageCoordinates.PosY)
		{
			MouseInterfaceLockPlayerRotation();
		}
		else
			MouseInterfaceUnlockPlayerRotation();
	}
	else
		MouseInterfaceUnlockPlayerRotation();
}

function MouseInterfaceClick()
{
	if (bShowObjectives)
	{
		if (HandleLevelMapClick(MouseCurrentPos.X + LastHUDSizeX * 0.5, MouseCurrentPos.Y + LastHUDSizeY * 0.5))
			HideObjectives();
	}
	else // Safeguard
		MouseInterfaceStopCapturing();
}

function MouseInterfaceDrawCursor(Canvas C)
{
	local float PosX, PosY;
	local vector newMousePos;

	if (!bHaveAtLeastOneValidMouseUpdate)
		return;

	newMousePos = MouseCurrentPos;

	PosX = newMousePos.X + C.SizeX * 0.5;
	PosY = newMousePos.Y + C.SizeY * 0.5;

	if (PosX < 0)
	{
		newMousePos.X -= PosX;
		PosX = 0;
	}
	else if (PosX >= C.ClipX)
	{
		newMousePos.X -= (PosX - C.SizeX);
		PosX = C.SizeX - 1;
	}

	if (PosY < 0)
	{
		newMousePos.Y -= PosY;
		PosY = 0;
	}
	else if (PosY >= C.ClipY)
	{
		newMousePos.Y -= (PosY - C.SizeY);
		PosY = C.SizeY - 1;
	}

	if (newMousePos != MousecurrentPos)
		ROPlayer(PlayerOwner).MouseInterfaceSetMousePos(newMousePos);

	//log("newMousePos.X = " $ newMousePos.X);
	//log("newMousePos.Y = " $ newMousePos.Y);

	MouseInterfaceIcon.PosX = PosX / C.ClipX;
	MouseInterfaceIcon.PosY = PosY / C.ClipY;

	LastHUDSizeX = C.ClipX;
	LastHUDSizeY = C.ClipY;

	//log("Drawing to " $ MouseInterfaceIcon.PosX $ "," $ MouseInterfaceIcon.PosY);

	DrawSpriteWidget(C, MouseInterfaceIcon);
}

function MouseInterfaceLockPlayerRotation()
{
	if (ROPlayer(PlayerOwner) != none)
		ROPlayer(PlayerOwner).MouseInterfaceSetRotationLock(true);
}

function MouseInterfaceUnlockPlayerRotation()
{
	if (ROPlayer(PlayerOwner) != none)
		ROPlayer(PlayerOwner).MouseInterfaceSetRotationLock(false);
}

function DrawVehicleIcon(Canvas Canvas, ROVehicle vehicle, optional ROVehicleWeaponPawn passenger)
{
    local AbsoluteCoordsInfo coords, coords2;
    local rotator myRot;
    local ROTreadCraft threadCraft;
    local SpriteWidget widget;
    local color vehicleColor;
    local float f;
    local int i, current, pending;
    local ROVehicleWeaponPawn wpawn;
    local float XL, YL, Y_one;
    local array<string> lines;
    local PlayerReplicationInfo PRI;
    local ROTankCannon cannon;
    local ROVehicleWeapon weapon;
    local float myScale;
    local float modifiedVehicleOccupantsTextYOffset; // Used to offset text vertically when drawing coaxial ammo info
    local ROWheeledVehicle wheeled_vehicle;

    if (bHideHud)
        return;

    // Debug: draw tank name
    //canvas.setpos(0, canvas.clipY * 0.75);
    //canvas.DrawText(vehicle.class);

    //////////////////////////////////////
    // Draw vehicle icon
    //////////////////////////////////////

    // Figure what the scale is
    myScale = HudScale; // * ResScaleY;

    // Figure where to draw
    coords.PosX = Canvas.ClipX * VehicleIconCoords.X;
    coords.height = Canvas.ClipY * VehicleIconCoords.YL * myScale;
    coords.PosY = Canvas.ClipY * VehicleIconCoords.Y - coords.height;
    coords.width = coords.height;

    // Compute whole-screen coords
    coords2.PosX = 0; coords2.PosY = 0;
    coords2.width = Canvas.ClipX; coords2.height = canvas.ClipY;

    // Set initial passenger PosX (shifted if we're drawing ammo info,
    // else it's draw closer to the tank icon)
    VehicleOccupantsText.PosX = default.VehicleOccupantsText.PosX;

    // The IS2 is so frelling huge that it needs to use larger textures
    if (vehicle.bVehicleHudUsesLargeTexture)
        widget = VehicleIconAlt;
    else
        widget = VehicleIcon;

    // Figure what color to draw in
    f = vehicle.Health / vehicle.HealthMax;
    if (f > 0.75)
        vehicleColor = VehicleNormalColor;
    else if (f > 0.35)
        vehicleColor = VehicleDamagedColor;
    else
        vehicleColor = VehicleCriticalColor;
    widget.Tints[0] = vehicleColor;
    widget.Tints[1] = vehicleColor;

    // Draw vehicle icon
    widget.WidgetTexture = vehicle.VehicleHudImage;
    DrawSpriteWidgetClipped(Canvas, widget, coords, true);

    // Draw engine (if needed)
    f = vehicle.EngineHealth / vehicle.Default.EngineHealth;
    if (f < 0.95)
    {
        if (f < 0.35)
            VehicleEngine.WidgetTexture = VehicleEngineCriticalTexture;
        else
            VehicleEngine.WidgetTexture = VehicleEngineDamagedTexture;

        VehicleEngine.PosX = vehicle.VehicleHudEngineX;
        VehicleEngine.PosY = vehicle.VehicleHudEngineY;
        DrawSpriteWidgetClipped(Canvas, VehicleEngine, coords, true);
    }

    // Draw treaded vehicle specific stuff
    threadCraft = ROTreadCraft(vehicle);
    if (threadCraft != none)
    {
        // Update turret references
        if (threadCraft.CannonTurret == none)
            threadCraft.UpdateTurretReferences();

        // Draw threads (if needed)
        if (threadCraft.bLeftTrackDamaged)
        {
            VehicleThreads[0].TextureScale = threadCraft.VehicleHudThreadsScale;
            VehicleThreads[0].PosX = threadCraft.VehicleHudThreadsPosX[0];
            VehicleThreads[0].PosY = threadCraft.VehicleHudThreadsPosY;
            DrawSpriteWidgetClipped(Canvas, VehicleThreads[0], coords, true, XL, YL, false, true);
        }
        if (threadCraft.bRightTrackDamaged)
        {
            VehicleThreads[1].TextureScale = threadCraft.VehicleHudThreadsScale;
            VehicleThreads[1].PosX = threadCraft.VehicleHudThreadsPosX[1];
            VehicleThreads[1].PosY = threadCraft.VehicleHudThreadsPosY;
            DrawSpriteWidgetClipped(Canvas, VehicleThreads[1], coords, true, XL, YL, false, true);
        }

        // Update & draw look turret (if needed)
        if (passenger != none && passenger.IsA('ROTankCannonPawn'))
        {
            threadCraft.VehicleHudTurretLook.Rotation.Yaw =
                vehicle.Rotation.Yaw - passenger.CustomAim.Yaw;
            widget.WidgetTexture = threadCraft.VehicleHudTurretLook;
            widget.Tints[0].A /= 2;
            widget.Tints[1].A /= 2;
            DrawSpriteWidgetClipped(Canvas, widget, coords, true);
            widget.Tints[0] = vehicleColor;
            widget.Tints[1] = vehicleColor;

            // Draw ammo count since we're a gunner
            if (bShowWeaponInfo)
            {
                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleOccupantsTextOffset;

                // Draw icon
                VehicleAmmoIcon.WidgetTexture = passenger.AmmoShellTexture;
                DrawSpriteWidget(Canvas, VehicleAmmoIcon);

                // Draw reload state icon (if needed)
                VehicleAmmoReloadIcon.WidgetTexture = passenger.AmmoShellReloadTexture;
                VehicleAmmoReloadIcon.Scale = passenger.getAmmoReloadState();
                DrawSpriteWidget(Canvas, VehicleAmmoReloadIcon);

                // Draw ammo count

                if( Passenger != none && passenger.Gun != none )
                {
                	VehicleAmmoAmount.Value = passenger.Gun.PrimaryAmmoCount();//999;
                }
                DrawNumericWidget(Canvas, VehicleAmmoAmount, Digits);

                // Draw ammo type
                cannon = ROTankCannon(passenger.Gun);
                if (cannon != none && cannon.bMultipleRoundTypes)
                {
                    // Get ammo types
                    current = cannon.GetRoundsDescription(lines);
                    pending = cannon.GetPendingRoundIndex();

                    VehicleAmmoTypeText.OffsetY = default.VehicleAmmoTypeText.OffsetY * myScale;
                    if (myScale < 0.85)
                        Canvas.Font = GetConsoleFont(Canvas);
                    else
                        Canvas.Font = GetSmallMenuFont(Canvas);

                    i = (current + 1) % lines.length;
                    while (true)
                    {
                        if (i == pending)
                        	VehicleAmmoTypeText.text = lines[i]$"<-";
                        else
                        	VehicleAmmoTypeText.text = lines[i];

                        if (i == current)
                            VehicleAmmoTypeText.Tints[TeamIndex].A = 255;
                        else
                            VehicleAmmoTypeText.Tints[TeamIndex].A = 128;



                        DrawTextWidgetClipped(Canvas, VehicleAmmoTypeText, coords2, XL, YL, Y_one);
                        VehicleAmmoTypeText.OffsetY -= YL;

                        i = (i + 1) % lines.length;
                        if (i == (current + 1) % lines.length)
                            break;
                    }
                }
                if (cannon != none)
                {
                    // Draw coaxial gun ammo info if needed
                    if (cannon.AltFireProjectileClass != none)
                    {
                        // Draw coaxial gun ammo icon
                        VehicleAltAmmoIcon.WidgetTexture = cannon.hudAltAmmoIcon;
                        DrawSpriteWidget(Canvas, VehicleAltAmmoIcon);

                        // Draw coaxial gun ammo ammount
                        VehicleAltAmmoAmount.Value = cannon.getNumMags();//999;
                        DrawNumericWidget(Canvas, VehicleAltAmmoAmount, Digits);

                        // Shift occupants list position to accomodate coaxial gun ammo info
                        modifiedVehicleOccupantsTextYOffset = VehicleAltAmmoOccupantsTextOffset * myScale;
                    }
                }
            }
        }

        // Update & draw turret
        if (threadCraft.CannonTurret != none)
        {
            myRot = rotator(vector(threadCraft.CannonTurret.CurrentAim) >> threadCraft.CannonTurret.Rotation);
            threadCraft.VehicleHudTurret.Rotation.Yaw = vehicle.Rotation.Yaw - myRot.Yaw;
            widget.WidgetTexture = threadCraft.VehicleHudTurret;
            DrawSpriteWidgetClipped(Canvas, widget, coords, true);
        }
    }

    // Draw MG ammo info (if needed)
    if (bShowWeaponInfo && passenger != none && passenger.bIsMountedTankMG)
    {
        weapon = ROVehicleWeapon(passenger.Gun);
        if (weapon != none)
        {
            // Offset vehicle passenger names
            VehicleOccupantsText.PosX = VehicleOccupantsTextOffset;

            // Draw ammo icon
            VehicleMGAmmoIcon.WidgetTexture = weapon.hudAltAmmoIcon;
            DrawSpriteWidget(Canvas, VehicleMGAmmoIcon);

            // Draw ammo count
            VehicleMGAmmoAmount.Value = weapon.getNumMags();
            DrawNumericWidget(Canvas, VehicleMGAmmoAmount, Digits);
        }
    }

    // Draw rpm/speed/throttle gauges if we're the driver
    if (passenger == none)
    {
        wheeled_vehicle = ROWheeledVehicle(vehicle);
        if (wheeled_vehicle != none)
        {
            // Get team index
            if (vehicle.Controller != none && vehicle.Controller.PlayerReplicationInfo != none &&
                vehicle.Controller.PlayerReplicationInfo.Team != none)
            {
                if (vehicle.Controller.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
                    i = AXIS_TEAM_INDEX;
                else
                    i = ALLIES_TEAM_INDEX;
            }
            else
                i = AXIS_TEAM_INDEX;

            // Update textures for backgrounds
            VehicleSpeedIndicator.WidgetTexture = VehicleSpeedTextures[i];
            VehicleRPMIndicator.WidgetTexture = VehicleRPMTextures[i];

            // Draw backgrounds
            DrawSpriteWidgetClipped(Canvas, VehicleSpeedIndicator, coords, true, XL, YL, false, true);
            DrawSpriteWidgetClipped(Canvas, VehicleRPMIndicator, coords, true, XL, YL, false, true);

            // Get speed value & update rotator
            f = (((VSize(wheeled_vehicle.Velocity) * 3600)/60.35)/1000);
            //f = 100;
            f *= VehicleSpeedScale[i];
            f += VehicleSpeedZeroPosition[i];

            // Check if we should reset needles rotation
            if (VehicleNeedlesLastRenderTime < Level.TimeSeconds - 0.5)
               f = VehicleLastSpeedRotation;

            // Calculate modified rotation (to limit rotation speed)
            if (f < VehicleLastSpeedRotation)
                VehicleLastSpeedRotation = max(f, VehicleLastSpeedRotation -
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            else
                VehicleLastSpeedRotation = min(f, VehicleLastSpeedRotation +
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            TexRotator(VehicleSpeedNeedlesTextures[i]).Rotation.Yaw = VehicleLastSpeedRotation;

            // Get RPM value & update rotator
            f = wheeled_vehicle.EngineRPM / 100;
            //f = 35;
            f *= VehicleRPMScale[i];
            f += VehicleRPMZeroPosition[i];

            // Check if we should reset needles rotation
            if (VehicleNeedlesLastRenderTime < Level.TimeSeconds - 0.5)
               f = VehicleLastSpeedRotation;

            // Calculate modified rotation (to limit rotation speed)
            if (f < VehicleLastRPMRotation)
                VehicleLastRPMRotation = max(f, VehicleLastRPMRotation -
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            else
                VehicleLastRPMRotation = min(f, VehicleLastRPMRotation +
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            TexRotator(VehicleRPMNeedlesTextures[i]).Rotation.Yaw = VehicleLastRPMRotation;

            // Save last updated time
            VehicleNeedlesLastRenderTime = Level.TimeSeconds;

            // Update textures for needles
            VehicleSpeedIndicator.WidgetTexture = VehicleSpeedNeedlesTextures[i];
            VehicleRPMIndicator.WidgetTexture = VehicleRPMNeedlesTextures[i];

            // Draw needles
            DrawSpriteWidgetClipped(Canvas, VehicleSpeedIndicator, coords, true, XL, YL, false, true);
            DrawSpriteWidgetClipped(Canvas, VehicleRPMIndicator, coords, true, XL, YL, false, true);

            // Check if we should draw throttle
            if (ROPlayer(vehicle.Controller) != none
                && ( (ROPlayer(vehicle.Controller).bInterpolatedTankThrottle && threadCraft != none) ||
                     (ROPlayer(vehicle.Controller).bInterpolatedVehicleThrottle && threadCraft == none) ))
            {
                // Draw throttle background
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorBackground, coords, true, XL, YL, false, true);

                // Save YL for use later
                Y_one = YL;

                // Check which throttle variable we should use
                if (PlayerOwner != vehicle.Controller)
                {
                    // Is spectator
                    if (wheeled_vehicle.ThrottleRep <= 100)
                        f = (wheeled_vehicle.ThrottleRep * -1.0) / 100.0;
                    else
                        f = float(wheeled_vehicle.ThrottleRep - 101) / 100.0;
                }
                else
                    f = wheeled_vehicle.Throttle;

                // Figure which part to draw (top or bottom) depending if throttle is positive or negative,
                // updated the scale value and draw the widget
                if (f ~= 0)
                {
                }
                else if (f > 0)
                {
                    VehicleThrottleIndicatorTop.Scale = VehicleThrottleTopZeroPosition
                        + f * (VehicleThrottleTopMaxPosition - VehicleThrottleTopZeroPosition);
                    DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorTop, coords, true, XL, YL, false, true);
                }
                else
                {
                    VehicleThrottleIndicatorBottom.Scale = VehicleThrottleBottomZeroPosition
                        - f * (VehicleThrottleBottomMaxPosition - VehicleThrottleBottomZeroPosition);
                    DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorBottom, coords, true, XL, YL, false, true);
                }

                // Draw throttle foreground
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorForeground, coords, true, XL, YL, false, true);

                // Draw the lever thingy
                if (f ~= 0)
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * VehicleThrottleTopZeroPosition;
                }
                else if (f > 0)
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * VehicleThrottleIndicatorTop.scale;
                }
                else
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * (1 - VehicleThrottleIndicatorBottom.Scale);
                }
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorLever, coords, true, XL, YL, true, true);

                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleGaugesOccupantsTextOffset;
            }
            else
            {
                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleGaugesNoThrottleOccupantsTextOffset;
            }

            // hax to get proper x offset on non-4:3 screens
            VehicleOccupantsText.PosX *= Canvas.ClipY / Canvas.ClipX * 4 / 3;
        }
    }

    // Draw occupant dots
    for (i = 0; i < vehicle.VehicleHudOccupantsX.Length; i++)
    {
        if (vehicle.VehicleHudOccupantsX[i] ~= 0)
            continue;

        if (i == 0)
        {
            // Draw driver
            if (passenger == none) // we're the driver
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
            else if (vehicle.Driver != none)
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsOccupiedColor;
            else
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsVacantColor;

            VehicleOccupants.PosX = vehicle.VehicleHudOccupantsX[0];
            VehicleOccupants.PosY = vehicle.VehicleHudOccupantsY[0];
            DrawSpriteWidgetClipped(Canvas, VehicleOccupants, coords, true);
        }
        else
        {
            if (i - 1 >= vehicle.WeaponPawns.Length)
            {
                warn("VehicleHudOccupantsX[" $ i $ "] causes out-of-bounds access in vehicle.WeaponPawns[] (lenght is " $ vehicle.WeaponPawns.Length $ ")");
                continue;
            }
            else if (vehicle.WeaponPawns[i-1] == passenger && passenger != none)
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
            else if (vehicle.WeaponPawns[i-1].PlayerReplicationInfo != none)
            {
                if (passenger != none &&
                    passenger.PlayerReplicationInfo != none &&
                    vehicle.WeaponPawns[i-1].PlayerReplicationInfo == passenger.PlayerReplicationInfo)
                {
                    VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
                }
                else
                    VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsOccupiedColor;
            }
            else
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsVacantColor;

            // Check to make sure replicated array index doesn'T cause out of bounds access
            current = vehicle.WeaponPawns[i-1].PositionInArray;
            if (current >= vehicle.VehicleHudOccupantsX.Length - 1 ||
                current < 0)
            {
                warn("vehicle.WeaponPawns[" $ (i-1) $ "].PositionInArray "$current$" causes out-of-bounds access in vehicle.VehicleHudOccupantsX[] (lenght is " $ vehicle.VehicleHudOccupantsX.Length $ ")");
            }
            else
            {
                VehicleOccupants.PosX = vehicle.VehicleHudOccupantsX[current + 1];
                VehicleOccupants.PosY = vehicle.VehicleHudOccupantsY[current + 1];
                DrawSpriteWidgetClipped(Canvas, VehicleOccupants, coords, true);
            }
        }
    }


    //////////////////////////////////////
    // Draw passenger names
    //////////////////////////////////////

    // Get self's PRI
    if (passenger != none)
        PRI = passenger.PlayerReplicationInfo;
    else
        PRI = vehicle.PlayerReplicationInfo;

    // Clear lines array
    lines.length = 0;

    // Shift text up some more if we're the driver and we're displaying capture bar
    if (bDrawingCaptureBar && vehicle.PlayerReplicationInfo == PRI)
       modifiedVehicleOccupantsTextYOffset -= 0.12 * Canvas.SizeY * myScale;

    // Driver's name
    if (vehicle.PlayerReplicationInfo != none)
        if (vehicle.PlayerReplicationInfo != PRI) // don't draw our own name!
            lines[lines.length] = class'ROVehicleWeaponPawn'.default.DriverHudName $ ": " $
                vehicle.PlayerReplicationInfo.PlayerName;

    // Passengers' names
    for (i = 0; i < vehicle.WeaponPawns.Length; i++)
    {
        wpawn = ROVehicleWeaponPawn(vehicle.WeaponPawns[i]);
        if (wpawn != none && wpawn.PlayerReplicationInfo != none)
            if (wpawn.PlayerReplicationInfo != PRI) // don't draw our own name!
                lines[lines.length] = wpawn.HudName $ ": " $
                    wpawn.PlayerReplicationInfo.PlayerName;
    }

    // Draw the lines
    if (lines.Length > 0)
    {
        VehicleOccupantsText.OffsetY = default.VehicleOccupantsText.OffsetY * myScale;
        VehicleOccupantsText.OffsetY += modifiedVehicleOccupantsTextYOffset;
        Canvas.Font = GetSmallMenuFont(Canvas);

        for (i = lines.Length - 1; i >= 0 ; i--)
        {
            VehicleOccupantsText.text = lines[i];
            DrawTextWidgetClipped(Canvas, VehicleOccupantsText, coords2, XL, YL, Y_one);
            VehicleOccupantsText.OffsetY -= YL;
        }
    }

}

// test0r!
/*exec function testHint(string text)
{
	ShowHint("My Test Title", text);
}
exec function testHint2()
{
	ShowHint("Welcome", "Welcome to Red Orchestra!||These hint messages will show up periodically in the game to help you survive. They can be disabled from the HUD tab in the configuration menu. (You can open that menu by hitting %SHOWMENU%)");
}
exec function testHint3()
{
	ShowHint("Leaning", "Press %LeanRight% or %LeanLeft% to lean around corners.||Leaning lets you peak around corners without showing as large a target as you would by simply walking around that corner.");
}
exec function testHint4()
{
	ShowHint("Weak Points", "Every tank has its weak points. Try targetting the driver's window or the turret/body seam.");
}*/

simulated function FadeToBlack(float fadeTime, optional bool bInvertFadeDirection)
{
	FadeToBlackTime = fadeTime;
	FadeToBlackStartTime = Level.TimeSeconds;
	bFadeToBlackInvert = bInvertFadeDirection;
	bFadeToBlack = true;
}

simulated function DrawFadeToBlack(Canvas Canvas)
{
	local float alpha;

	if (FadeToBlackTime ~= 0)
		alpha = 0.0;
	else
		alpha = (FadeToBlackTime - Level.TimeSeconds + FadeToBlackStartTime) / FadeToBlackTime;

	if (alpha <= 0)
		alpha = 0.0;
	else if (alpha > 1)
		alpha = 1.0;

	if (!bFadeToBlackInvert)
		alpha = 1.0 - alpha;

	if (alpha ~= 0)
	{
		bFadeToBlack = false;
		return;
	}

	Canvas.SetPos(0, 0);
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = BlackColor;
	Canvas.DrawColor.A = alpha * 255;
	Canvas.DrawTile(Texture'Engine.WhiteTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 4, 4);
}

/*
exec function testFade1()
{
	FadeToBlack(4.0);
}

exec function testFade2()
{
	FadeToBlack(4.0, true);
}

exec function testFade3()
{
	FadeToBlack(0, true);
}*/

simulated function DrawLCDPlayerStatus(Canvas C, GUIController GC)
{
	local int row,x,xl,yl;
	local int Amount;
	local string WName;
	local weapon w;
	local string s;
	local int PawnHealth, Enginehealth;
	local ROPawn ROP;
	local ROGameReplicationInfo GRI;
	local float RoundTime, RespawnTime;
	local ROVehicle ROV;
	local ROVehicleWeaponPawn ROVWP;

	GC.LCDCls();

	if( PawnOwner == none )
	{
		GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

		if (GRI != None)
		{
			if(PlayerOwner.IsInState('Dead') || PlayerOwner.IsInState('DeadSpectating') )
			{
				GC.LCDDrawText("Dead",0,10*row, GC.LCDMedFont);
			}
			else
			{
				GC.LCDDrawText("Waiting To Spawn",0,10*row, GC.LCDMedFont);
			}
			row++;

            GC.LCDDrawTile(Texture'engine.WhiteSquareTexture',0,16*row,160,1,0,0,1,1);

			// Update round timer
			if (!GRI.bMatchHasBegun)
				RoundTime = GRI.RoundStartTime + GRI.PreStartTime - GRI.ElapsedTime;
			else
				RoundTime = GRI.RoundStartTime + GRI.RoundDuration - GRI.ElapsedTime;

			S = default.TimeRemainingText $ GetTimeString(RoundTime);
			GC.LCDDrawText(s,0,20*row, GC.LCDTinyFont);
			row++;

			if (GRI.bMatchHasBegun && ROPlayer(PlayerOwner) != None && ROPlayer(PlayerOwner).CanRestartPlayer()
				&& PlayerOwner.PlayerReplicationInfo.Team != none && GRI.bReinforcementsComing[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] == 1)
			{
				RespawnTime = GRI.LastReinforcementTime[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] + GRI.ReinforcementInterval[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] - GRI.ElapsedTime;
				S = default.ReinforcementText $ GetTimeString(RespawnTime);

				GC.LCDDrawText(s,0,15*row, GC.LCDTinyFont);
				row++;
			}
		}
	}
	else
	{
    	ROP = ROPawn(PawnOwner);
    	ROV = ROVehicle(PawnOwner);
    	ROVWP = ROVehicleWeaponPawn(PawnOwner);

		w = PawnOwner.Weapon;
		if (W!=none)
		{
			Amount = w.GetHudAmmoCount();
			WName = w.ItemName;
		}

		// Draw health info
		if( ROP != none )
		{
			PawnHealth = int((float(PawnOwner.Health)/float(PawnOwner.Default.Health))*100);

			if( PawnHealth == 100 )
			{
			 	s = "No Injuries";
			}
			else if( PawnHealth < 25 )
			{
				s = "Near Death";
			}
			else if( PawnHealth < 50 )
			{
				s = "Seriously Injured";
			}
			else if( PawnHealth < 100 )
			{
				s = "Injured";
			}

			GC.LCDDrawText("Health: "$s,0,10*row, GC.LCDTinyFont);
			row++;
		}
		else if ( Vehicle(PawnOwner) != none )
		{
			if( ROVWP != none )
			{
				PawnHealth = int((float(ROVWP.VehicleBase.Health)/float(ROVWP.VehicleBase.Default.Health))*100);
				Enginehealth = int((float(ROVWP.VehicleBase.EngineHealth)/float(ROVWP.VehicleBase.Default.EngineHealth))*100);
			}
			else
			{
				PawnHealth = int((float(PawnOwner.Health)/float(PawnOwner.Default.Health))*100);
				Enginehealth = int((float(ROVehicle(PawnOwner).EngineHealth)/float(ROVehicle(PawnOwner).Default.EngineHealth))*100);
			}

			if( PawnHealth == 100 )
			{
			 	s = "No Damage";
			}
			else if( PawnHealth < 25 )
			{
				s = "Failure Imminent";
			}
			else if( PawnHealth < 50 )
			{
				s = "Heavy Damage";
			}
			else if( PawnHealth < 100 )
			{
				s = "Damaged";
			}

			GC.LCDDrawText("Vehicle: "$s,0,10*row, GC.LCDTinyFont);
			row++;

			if( Enginehealth == 100 )
			{
			 	s = "No Damage";
			}
			else if( Enginehealth < 25 )
			{
				s = "Failure Imminent";
			}
			else if( Enginehealth < 50 )
			{
				s = "Heavy Damage";
			}
			else if( Enginehealth < 100 )
			{
				s = "Damaged";
			}

			GC.LCDDrawText("Engine : "$s,0,10*row, GC.LCDTinyFont);
			row++;

			if( ROVWP != none )
			{
				if( ROVWP.Gun.ProjectileClass != none )
				{
					if( ROTankCannon(ROVWP.Gun) != none)
					{
						GC.LCDDrawText("Primary Ammo Count : "$ROVWP.Gun.PrimaryAmmoCount(),0,10*row, GC.LCDTinyFont);
					}
					else
					{
						GC.LCDDrawText("Primary Ammo Count : "$ROVehicleWeapon(ROVWP.Gun).getNumMags(),0,10*row, GC.LCDTinyFont);
					}
					row++;
				}
				if( ROVWP.Gun.AltFireProjectileClass != none )
				{
					GC.LCDDrawText("Secondary Ammo Count : "$ROVehicleWeapon(ROVWP.Gun).getNumMags(),0,10*row, GC.LCDTinyFont);
					row++;
				}
			}
		}

    	if(ROP != none)
    	{
			// Stamina
			GC.LCDDrawText("Stamina: ",X,10*row, GC.LCDTinyFont);
			s = int((ROP.Stamina/ROP.Default.Stamina)*100)@"%";
			GC.LCDStrLen(s,GC.LCDTinyFont,xl,yl);
			GC.LCDDrawText(s,100-5-xl,10*row,GC.LCDTinyFont);
			row++;

	    	// Weapon info
			if(W != none)
	    	{
				if(WName != "")
				{
					GC.LCDDrawText(WName,0,10*row, GC.LCDTinyFont);
					row++;

					if(!w.IsA('BinocularsItem'))
					{
						if( w.IsA('MG42Weapon' ) )
						{
						  	s = "MG Belts: "@Amount;
						}
						else if( w.IsA('MG34Weapon' ) )
						{
						 	s = "MG Drums: "@Amount;
						}
						else
						{
							s = w.FireModeClass[0].default.AmmoClass.default.ItemName$": "@Amount;
						}
						GC.LCDDrawText(s,0,10*row,GC.LCDTinyFont);
						row++;
					}
				}
			}
    	}
	}

	GC.LCDRepaint();
}

// Draw objective information on the G15 LCD
simulated function DrawLCDObjectives(Canvas C, GUIController GC)
{
	local ROGameReplicationInfo GRI;
	local int i, objCount, row;
	local string s;
	local bool bHasSecondaryObjectives;

	GRI = ROGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	// Draw objective texts
	objCount = 1;

    GC.LCDCls();

	// See if there are any secondary objectives
	for (i = 0; i < ArrayCount(GRI.Objectives); i++)
	{
		if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive )
			continue;

		if( !GRI.Objectives[i].bRequired )
		{
			bHasSecondaryObjectives=true;
			break;
		}
	}

	if( LCDPage == 0 || !bHasSecondaryObjectives )
	{
	    GC.LCDDrawText(MapRequiredObjectivesTitle.text$" Status:",0,0, GC.LCDTinyFont);
	    row++;

		for (i = 0; i < ArrayCount(GRI.Objectives); i++)
		{
			if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive || !GRI.Objectives[i].bRequired)
				continue;

	        if (GRI.Objectives[i].ObjState == OBJ_Allies)
	        {
		        if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
				{
					s = objCount $ "." $ "Allies"$"-" $ "Under Attack" ;
				}
				else
				{
					s = objCount $ "." $ "Allies"$"-" $ "Captured" ;
				}
	        }
	        else if (GRI.Objectives[i].ObjState == OBJ_Axis)
	        {
	        	if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
				{
					s = objCount $ "." $ "Axis"$"-" $ "Under Attack" ;
				}
				else
				{
					s = objCount $ "." $ "Axis"$"-" $ "Captured" ;
				}
	        }
	        else
	        {
				if (GRI.Objectives[i].CompressedCapProgress != 0 )
				{
					if(GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
					{
			        	if (GRI.Objectives[i].CurrentCapTeam == ALLIES_TEAM_INDEX)
							s = objCount $ "." $ "Neutral"$"-" $ "Allies Attacking";
						else
							s = objCount $ "." $ "Neutral"$"-" $ "Axis Attacking";
					}
					else
					{
						s = objCount $ "." $ "Neutral"$"-" $ "Under Attack";
					}
				}
				else
				{
					s = objCount $ "." $ "Neutral";
				}
	        }

	        GC.LCDDrawText(s,0,8*row + 2, GC.LCDTinyFont);

	        row++;
			objCount++;
		}
	}
	if( LCDPage == 1 && bHasSecondaryObjectives )
	{
	    GC.LCDDrawText(MapSecondaryObjectivesTitle.text$" Status:",0,0, GC.LCDTinyFont);
	    row++;

		for (i = 0; i < ArrayCount(GRI.Objectives); i++)
		{
			if (GRI.Objectives[i] == none || !GRI.Objectives[i].bActive || GRI.Objectives[i].bRequired)
				continue;

	        if (GRI.Objectives[i].ObjState == OBJ_Allies)
	        {
		        if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
				{
					s = objCount $ "." $ "Allies"$"-" $ "Under Attack" ;
				}
				else
				{
					s = objCount $ "." $ "Allies"$"-" $ "Captured" ;
				}
	        }
	        else if (GRI.Objectives[i].ObjState == OBJ_Axis)
	        {
	        	if (GRI.Objectives[i].CompressedCapProgress != 0 && GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
				{
					s = objCount $ "." $ "Axis"$"-" $ "Under Attack" ;
				}
				else
				{
					s = objCount $ "." $ "Axis"$"-" $ "Captured" ;
				}
	        }
	        else
	        {
				if (GRI.Objectives[i].CompressedCapProgress != 0 )
				{
					if(GRI.Objectives[i].CurrentCapTeam != NEUTRAL_TEAM_INDEX)
					{
			        	if (GRI.Objectives[i].CurrentCapTeam == ALLIES_TEAM_INDEX)
							s = objCount $ "." $ "Neutral"$"-" $ "Allies Attacking";
						else
							s = objCount $ "." $ "Neutral"$"-" $ "Axis Attacking";
					}
					else
					{
						s = objCount $ "." $ "Neutral"$"-" $ "Under Attack";
					}
				}
				else
				{
					s = objCount $ "." $ "Neutral";
				}
	        }

	        GC.LCDDrawText(s,0,8*row, GC.LCDTinyFont);

	        row++;
			objCount++;
		}
	}

	GC.LCDRepaint();
}

simulated function string GetScoreTitle()
{
	return "Points";
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bShowCompass=True
     bShowMapUpdatedText=True
     ReinforcementText="Reinforcements: "
     TimeRemainingText="Time Remaining: "
     IPText="IP: "
     TimeText="Time: "
     ViewingText="Viewing: "
     NoReinforcementsText="No reinforcements available"
     TeamMessagePrefix="*PLATOON* "
     ObjectivesText="OBJECTIVES"
     PlayersNeededText="Need: "
     SpectateInstructionText1="Press Fire to switch Viewpoint/Players"
     SpectateInstructionText2="Press Alt-Fire to switch Spectating Modes"
     SpectateInstructionText3="Press Ironsights to toggle First/Third Person View"
     SpectateInstructionText4="Press Jump to return to viewing yourself"
     NeedAmmoText="Needs ammo"
     CanResupplyText="Press %THROWMGAMMO% to resupply"
     OpenMapText="%SHOWOBJECTIVES% to open"
     SituationMapInstructionsText="Press %SHOWOBJECTIVES% to Close/Open Situation Map"
     SpacingText="            "
     MapCoordTextX(0)="1"
     MapCoordTextX(1)="2"
     MapCoordTextX(2)="3"
     MapCoordTextX(3)="4"
     MapCoordTextX(4)="5"
     MapCoordTextX(5)="6"
     MapCoordTextX(6)="7"
     MapCoordTextX(7)="8"
     MapCoordTextX(8)="9"
     MapCoordTextY(0)="A"
     MapCoordTextY(1)="B"
     MapCoordTextY(2)="C"
     MapCoordTextY(3)="D"
     MapCoordTextY(4)="E"
     MapCoordTextY(5)="F"
     MapCoordTextY(6)="G"
     MapCoordTextY(7)="H"
     MapCoordTextY(8)="I"
     LegendAxisObjectiveText="Axis-controlled obj."
     LegendAlliesObjectiveText="Allies-controlled obj."
     LegendNeutralObjectiveText="Neutral objective"
     LegendArtilleryRadioText="Artillery radio"
     LegendResupplyAreaText="Resupply area"
     LegendRallyPointText="Rally point"
     LegendSavedArtilleryText="Saved artillery coords."
     LegendOrderTargetText="Ordered target obj."
     LegendArtyStrikeText="Artillery strike"
     LegendHelpRequestText="Help requested at obj."
     LegendDestroyableItemText="Destroyable target"
     LegendDestroyedItemText="Destroyed target"
     LegendMGResupplyText="MG requesting resupply"
     LegendVehResupplyAreaText="Vehicle resupply area"
     LegendATGunText="Anti Tank Gun"
     SmallFontArrayNames(0)="ROFontsTwo.ROArial24DS"
     SmallFontArrayNames(1)="ROFontsTwo.ROArial24DS"
     SmallFontArrayNames(2)="ROFontsTwo.ROArial22DS"
     SmallFontArrayNames(3)="ROFontsTwo.ROArial22DS"
     SmallFontArrayNames(4)="ROFontsTwo.ROArial18DS"
     SmallFontArrayNames(5)="ROFontsTwo.ROArial14DS"
     SmallFontArrayNames(6)="ROFontsTwo.ROArial12DS"
     SmallFontArrayNames(7)="ROFontsTwo.ROArial9DS"
     SmallFontArrayNames(8)="ROFontsTwo.ROArial7DS"
     MenuFontArrayNames(0)="ROFonts.ROBtsrmVr18"
     MenuFontArrayNames(1)="ROFonts.ROBtsrmVr14"
     MenuFontArrayNames(2)="ROFonts.ROBtsrmVr12"
     MenuFontArrayNames(3)="ROFonts.ROBtsrmVr9"
     MenuFontArrayNames(4)="ROFonts.ROBtsrmVr7"
     CriticalMsgFontArrayNames(0)="ROFonts.ROArial28"
     CriticalMsgFontArrayNames(1)="ROFonts.ROArial26"
     CriticalMsgFontArrayNames(2)="ROFonts.ROArial24"
     CriticalMsgFontArrayNames(3)="ROFonts.ROArial22"
     CriticalMsgFontArrayNames(4)="ROFonts.ROArial18"
     CriticalMsgFontArrayNames(5)="ROFonts.ROArial16"
     CriticalMsgFontArrayNames(6)="ROFonts.ROArial14"
     CriticalMsgFontArrayNames(7)="ROFonts.ROArial12"
     CriticalMsgFontArrayNames(8)="ROFonts.ROArial9"
     SideColors(0)=(B=128,G=128,R=64,A=255)
     SideColors(1)=(B=64,G=64,R=192,A=255)
     Digits=(DigitTexture=Texture'InterfaceArt_tex.HUD.numbers',TextureCoords[0]=(X1=15,X2=47,Y2=63),TextureCoords[1]=(X1=79,X2=111,Y2=63),TextureCoords[2]=(X1=143,X2=175,Y2=63),TextureCoords[3]=(X1=207,X2=239,Y2=63),TextureCoords[4]=(X1=15,Y1=64,X2=47,Y2=127),TextureCoords[5]=(X1=79,Y1=64,X2=111,Y2=127),TextureCoords[6]=(X1=143,Y1=64,X2=175,Y2=127),TextureCoords[7]=(X1=207,Y1=64,X2=239,Y2=127),TextureCoords[8]=(X1=15,Y1=128,X2=47,Y2=191),TextureCoords[9]=(X1=79,Y1=128,X2=111,Y2=191),TextureCoords[10]=(X1=143,Y1=128,X2=175,Y2=191))
     HealthFigure=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=8,OffsetY=-8,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthFigureBackground=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=8,OffsetY=-8,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthFigureStamina=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=8,OffsetY=-8,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255))
     StanceIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=127),TextureScale=0.250000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=155,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AmmoCount=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.250000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=440,OffsetY=-55,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AmmoIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=127),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=240,OffsetY=-7,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AutoFireIcon=(WidgetTexture=Texture'InterfaceArt2_tex.HUD.firemode_auto',RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=31),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=275,OffsetY=-140,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SemiFireIcon=(WidgetTexture=Texture'InterfaceArt2_tex.HUD.firemode_semi',RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=31),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=275,OffsetY=-140,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MGDeployIcon=(WidgetTexture=Texture'InterfaceArt_tex.HUD.MGDeploy',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-144,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ResupplyZoneNormalPlayerIcon=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=192,Y1=192,X2=255,Y2=255),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-200,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=128,G=128,R=255,A=128),Tints[1]=(B=128,G=128,R=255,A=128))
     ResupplyZoneNormalVehicleIcon=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=128,Y1=64,X2=191,Y2=127),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-144,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=128,G=128,R=255,A=128),Tints[1]=(B=128,G=128,R=255,A=128))
     ResupplyZoneResupplyingPlayerIcon=(WidgetTexture=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_icons_fast_flash',RenderStyle=STY_Alpha,TextureCoords=(X1=192,Y1=192,X2=255,Y2=255),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-200,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ResupplyZoneResupplyingVehicleIcon=(WidgetTexture=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_icons_fast_flash',RenderStyle=STY_Alpha,TextureCoords=(X1=128,Y1=64,X2=191,Y2=127),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-144,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponCanRestIcon=(WidgetTexture=Texture'InterfaceArt_tex.HUD.MGDeploy',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-144,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=100,G=100,R=100,A=255),Tints[1]=(B=100,G=100,R=100,A=255))
     WeaponRestingIcon=(WidgetTexture=Texture'InterfaceArt_tex.HUD.MGDeploy',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.450000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-8,OffsetY=-144,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CompassBase=(WidgetTexture=Texture'InterfaceArt_tex.HUD.Compass2_main',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=255),TextureScale=0.150000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-3,OffsetY=3,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CompassNeedle=(WidgetTexture=TexRotator'InterfaceArt_tex.HUD.TexRotator0',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=255),TextureScale=0.155000,DrawPivot=DP_MiddleMiddle,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CompassIcons=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X2=31,Y2=31),TextureScale=0.030000,DrawPivot=DP_MiddleMiddle,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponReloadingColor=(B=128,G=128,R=128,A=128)
     NationHealthFigures(0)=Texture'InterfaceArt_tex.HUD.ger_player'
     NationHealthFigures(1)=Texture'InterfaceArt_tex.HUD.rus_player'
     NationHealthFiguresBackground(0)=Texture'InterfaceArt_tex.HUD.ger_player_background'
     NationHealthFiguresBackground(1)=Texture'InterfaceArt_tex.HUD.rus_player_background'
     NationHealthFiguresStamina(0)=Texture'InterfaceArt_tex.HUD.ger_player_Stamina'
     NationHealthFiguresStamina(1)=Texture'InterfaceArt_tex.HUD.rus_player_Stamina'
     NationHealthFiguresStaminaCritical(0)=FinalBlend'InterfaceArt_tex.HUD.ger_player_Stamina_critical'
     NationHealthFiguresStaminaCritical(1)=FinalBlend'InterfaceArt_tex.HUD.rus_player_Stamina_critical'
     StanceStanding=Texture'InterfaceArt_tex.HUD.stance_stand'
     StanceCrouch=Texture'InterfaceArt_tex.HUD.stance_crouch'
     StanceProne=Texture'InterfaceArt_tex.HUD.stance_prone'
     PlayerArrowTexture=FinalBlend'InterfaceArt_tex.OverheadMap.arrowhead_final'
     ObituaryLifeSpan=8.000000
     FadeTime=-1.000000
     WhiteFlashTime=0.500000
     MapUpdatedIcon=(WidgetTexture=Texture'InterfaceArt_tex.HUD.situation_map_icon',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.050000,DrawPivot=DP_LowerMiddle,PosX=0.850000,PosY=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapUpdatedText=(RenderStyle=STY_Alpha,DrawPivot=DP_LowerMiddle,PosX=0.850000,PosY=1.000000,WrapHeight=1.000000,OffsetY=-80,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconsFlash=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_Icons_flashing'
     MapIconsFastFlash=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_icons_fast_flash'
     MapIconsAltFlash=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_icons_alt_flashing'
     MapIconsAltFastFlash=FinalBlend'InterfaceArt_tex.OverheadMap.overheadmap_icons_alt_fast_flash'
     MaxMapUpdatedIconDisplayTime=8.000000
     AnimateMapCurrentPosition=1.000000
     AnimateMapSpeed=0.300000
     MapBackground=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_background',RenderStyle=STY_Alpha,TextureCoords=(X2=1023,Y2=1023),TextureScale=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=128,G=128,R=128,A=255),Tints[1]=(B=128,G=128,R=128,A=255))
     MapLegendImageCoords=(X=0.040000,Y=0.070000,XL=0.555000,YL=0.705000)
     MapLevelImage=(RenderStyle=STY_Alpha,TextureCoords=(X2=511,Y2=511),TextureScale=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapTexts=(RenderStyle=STY_Alpha,DrawPivot=DP_UpperMiddle,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapPlayerIcon=(WidgetTexture=FinalBlend'InterfaceArt_tex.OverheadMap.arrowhead_final',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(B=255,A=255))
     MapCoordTextXWidget=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosY=-0.022000,WrapWidth=0.100000,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
     MapCoordTextYWidget=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=-0.035000,WrapWidth=0.100000,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
     MapIconTeam(0)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=192,X2=255,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconTeam(1)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=128,X2=191,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconDispute(0)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=128,Y1=192,X2=191,Y2=255),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconDispute(1)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(Y1=192,X2=63,Y2=255),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconNeutral=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=64,X2=127,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconRadio=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=64,Y1=192,X2=127,Y2=255),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconRally(0)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=64,Y1=128,X2=127,Y2=191),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconRally(1)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(Y1=128,X2=63,Y2=191),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconResupply=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=192,Y1=192,X2=255,Y2=255),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconVehicleResupply=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=128,Y1=64,X2=191,Y2=127),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconHelpRequest=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=192,Y1=64,X2=255,Y2=127),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconMGResupplyRequest(0)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=192,Y1=128,X2=255,Y2=191),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconMGResupplyRequest(1)=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=128,Y1=128,X2=191,Y2=191),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconAttackDefendRequest=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconArtyStrike=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(Y1=64,X2=63,Y2=127),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapIconDestroyableItem=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=64,Y1=64,X2=127,Y2=127),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255))
     MapIconDestroyedItem=(WidgetTexture=Texture'InterfaceArt_tex.OverheadMap.overheadmap_Icons',RenderStyle=STY_Alpha,TextureCoords=(X1=64,Y1=64,X2=127,Y2=127),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=128,G=128,R=128,A=128),Tints[1]=(B=128,G=128,R=128,A=128))
     MapIconATGun=(WidgetTexture=Texture'InterfaceArt2_tex.overheadmaps.overheadmap_IconsB',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.050000,DrawPivot=DP_MiddleMiddle,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255))
     MapTimerTitle=(Text="Time Remaining",RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.810000,PosY=0.055000,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapTimerTexts(0)=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.748000,PosY=0.115000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapTimerTexts(1)=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.785000,PosY=0.115000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapTimerTexts(2)=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.832000,PosY=0.115000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapTimerTexts(3)=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.870000,PosY=0.115000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapLegendCoords=(X=0.015000,Y=0.850000,XL=0.970000,YL=0.110000)
     MapLegend=(WidgetTexture=Texture'Engine.WhiteSquareTexture',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=64),Tints[1]=(B=255,G=255,R=255,A=64))
     MapLegendIcons=(RenderStyle=STY_Alpha,TextureCoords=(X2=31,Y2=31),TextureScale=0.300000,DrawPivot=DP_MiddleLeft,PosX=0.050000,PosY=0.100000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MapLegendTitle=(Text="Legend",RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=0.007000,PosY=0.150000,WrapWidth=0.900000,WrapHeight=0.100000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapLegendTexts=(RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=0.150000,PosY=0.100000,WrapWidth=0.800000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapObjectivesCoords=(X=0.640000,Y=0.165000,XL=0.345000,YL=0.640000)
     MapObjectivesTitle=(Text="Objectives",RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=0.025000,PosY=0.026000,WrapWidth=0.500000,WrapHeight=0.100000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapRequiredObjectivesTitle=(Text="Required Objectives",RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=0.025000,PosY=0.026000,WrapWidth=0.500000,WrapHeight=0.100000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapSecondaryObjectivesTitle=(Text="Secondary Objectives",RenderStyle=STY_Alpha,PosX=0.025000,PosY=0.026000,WrapWidth=0.900000,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     MapObjectivesTexts=(RenderStyle=STY_Alpha,PosX=0.050000,PosY=0.100000,WrapWidth=0.900000,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     PortraitIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.060000,DrawPivot=DP_MiddleLeft,PosY=0.500000,OffsetX=80,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     PortraitText(0)=(RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosY=0.500000,OffsetX=8,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     PortraitText(1)=(RenderStyle=STY_Alpha,PosY=0.500000,OffsetX=8,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     NeedleRotator=TexRotator'InterfaceArt_tex.HUD.Needle_rot'
     VoiceMeterBackground=Texture'InterfaceArt_tex.HUD.VUMeter'
     VoiceMeterX=0.725000
     VoiceMeterY=1.000000
     VoiceMeterSize=100.000000
     compassStabilizationConstant=2.000000
     compassIconsFadeSpeed=0.150000
     compassIconsRefreshSpeed=0.700000
     compassIconsPositionRadius=0.800000
     locationHitAxisImages(0)=Texture'InterfaceArt_tex.Player_hits.ger_hit_head'
     locationHitAxisImages(1)=Texture'InterfaceArt_tex.Player_hits.ger_hit_torso'
     locationHitAxisImages(2)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Pelvis'
     locationHitAxisImages(3)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Lupperleg'
     locationHitAxisImages(4)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rupperleg'
     locationHitAxisImages(5)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Lupperarm'
     locationHitAxisImages(6)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rupperarm'
     locationHitAxisImages(7)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Llowerleg'
     locationHitAxisImages(8)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rlowerleg'
     locationHitAxisImages(9)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Llowerarm'
     locationHitAxisImages(10)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rlowerarm'
     locationHitAxisImages(11)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Lhand'
     locationHitAxisImages(12)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rhand'
     locationHitAxisImages(13)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Lfoot'
     locationHitAxisImages(14)=Texture'InterfaceArt_tex.Player_hits.ger_hit_Rfoot'
     locationHitAlliesImages(0)=Texture'InterfaceArt_tex.Player_hits.rus_hit_head'
     locationHitAlliesImages(1)=Texture'InterfaceArt_tex.Player_hits.rus_hit_torso'
     locationHitAlliesImages(2)=Texture'InterfaceArt_tex.Player_hits.rus_hit_pelvis'
     locationHitAlliesImages(3)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Lupperleg'
     locationHitAlliesImages(4)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Rupperleg'
     locationHitAlliesImages(5)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Lupperarm'
     locationHitAlliesImages(6)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Rupperarm'
     locationHitAlliesImages(7)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Llowerleg'
     locationHitAlliesImages(8)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Rlowerleg'
     locationHitAlliesImages(9)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Llowerarm'
     locationHitAlliesImages(10)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Rlowerarm'
     locationHitAlliesImages(11)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Lhand'
     locationHitAlliesImages(12)=Texture'InterfaceArt_tex.Player_hits.rus_hit_Rhand'
     locationHitAlliesImages(13)=Texture'InterfaceArt_tex.Player_hits.rus_hit_LFoot'
     locationHitAlliesImages(14)=Texture'InterfaceArt_tex.Player_hits.rus_hit_RFoot'
     MouseInterfaceIcon=(WidgetTexture=Texture'InterfaceArt_tex.Cursors.Pointer',RenderStyle=STY_Alpha,TextureCoords=(X2=31,Y2=31),TextureScale=1.000000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleIconCoords=(Y=1.000000,YL=0.200000)
     VehicleIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=255),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleIconAlt=(RenderStyle=STY_Alpha,TextureCoords=(X2=511,Y2=511),TextureScale=2.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleThreads(0)=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.tread_left',RenderStyle=STY_Alpha,TextureCoords=(X1=23,Y1=2,X2=37,Y2=125),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=128),Tints[1]=(R=255,A=128))
     VehicleThreads(1)=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.tread_left',RenderStyle=STY_Alpha,TextureCoords=(X1=25,Y1=2,X2=40,Y2=125),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=128),Tints[1]=(R=255,A=128))
     VehicleEngine=(RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.220000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255))
     vehicleOccupants=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.RedDot',RenderStyle=STY_Alpha,TextureCoords=(X2=31,Y2=31),TextureScale=0.120000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleOccupantsText=(RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,WrapHeight=1.000000,OffsetX=8,OffsetY=-4,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleNormalColor=(B=255,G=255,R=255,A=255)
     VehicleDamagedColor=(G=222,R=255,A=255)
     VehicleCriticalColor=(R=154,A=255)
     VehiclePositionIsPlayerColor=(R=255,A=255)
     VehiclePositionIsOccupiedColor=(R=255,A=128)
     VehiclePositionIsVacantColor=(A=128)
     VehicleEngineDamagedTexture=Texture'InterfaceArt_tex.Tank_Hud.engine_hud'
     VehicleEngineCriticalTexture=FinalBlend'InterfaceArt_tex.Tank_Hud.engine_hud_final'
     VehicleAmmoIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,OffsetY=-8,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleAmmoReloadIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,OffsetY=-8,ScaleMode=SM_Up,Scale=0.750000,Tints[0]=(R=255,A=128),Tints[1]=(R=255,A=128))
     VehicleAmmoAmount=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.250000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,OffsetX=135,OffsetY=-130,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleAmmoTypeText=(RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosX=0.190000,PosY=1.000000,WrapHeight=1.000000,OffsetX=8,OffsetY=-4,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleOccupantsTextOffset=0.242000
     VehicleAltAmmoIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=127),TextureScale=0.200000,DrawPivot=DP_LowerLeft,PosX=0.250000,PosY=1.000000,OffsetY=-8,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleAltAmmoAmount=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.200000,DrawPivot=DP_LowerLeft,PosX=0.250000,PosY=1.000000,OffsetX=135,OffsetY=-40,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleAltAmmoOccupantsTextOffset=-35.000000
     VehicleMGAmmoIcon=(RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=127),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,OffsetY=-8,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleMGAmmoAmount=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.250000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=1.000000,OffsetX=145,OffsetY=-60,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleRPMTextures(0)=Texture'InterfaceArt_tex.Tank_Hud.Ger_RPM'
     VehicleRPMTextures(1)=Texture'InterfaceArt_tex.Tank_Hud.Rus_RPM'
     VehicleRPMNeedlesTextures(0)=TexRotator'InterfaceArt_tex.Tank_Hud.Ger_needle_rpm_rot'
     VehicleRPMNeedlesTextures(1)=TexRotator'InterfaceArt_tex.Tank_Hud.Rus_needle_rpm_rot'
     VehicleSpeedTextures(0)=Texture'InterfaceArt_tex.Tank_Hud.Ger_Speedometer'
     VehicleSpeedTextures(1)=Texture'InterfaceArt_tex.Tank_Hud.Rus_Speedometer'
     VehicleSpeedNeedlesTextures(0)=TexRotator'InterfaceArt_tex.Tank_Hud.Ger_needle_rot'
     VehicleSpeedNeedlesTextures(1)=TexRotator'InterfaceArt_tex.Tank_Hud.Rus_needle_rot'
     VehicleSpeedIndicator=(RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=255),TextureScale=0.800000,DrawPivot=DP_LowerLeft,PosX=1.000000,PosY=1.000000,OffsetY=-4,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleRPMIndicator=(RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=255),TextureScale=0.600000,DrawPivot=DP_LowerLeft,PosX=1.810000,PosY=1.000000,OffsetY=-7,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleThrottleIndicatorTop=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.throttle_background2',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=255),TextureScale=0.600000,DrawPivot=DP_LowerMiddle,PosX=2.570000,PosY=1.000000,OffsetY=-7,ScaleMode=SM_Up,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleThrottleIndicatorBottom=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.throttle_background2_bottom',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=255),TextureScale=0.600000,DrawPivot=DP_LowerMiddle,PosX=2.570000,PosY=1.000000,OffsetY=-7,ScaleMode=SM_Down,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleThrottleIndicatorBackground=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.throttle_background',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=255),TextureScale=0.600000,DrawPivot=DP_LowerMiddle,PosX=2.570000,PosY=1.000000,OffsetY=-7,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     VehicleThrottleIndicatorForeground=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.throttle_main',RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=255),TextureScale=0.600000,DrawPivot=DP_LowerMiddle,PosX=2.570000,PosY=1.000000,OffsetY=-7,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleThrottleIndicatorLever=(WidgetTexture=Texture'InterfaceArt_tex.Tank_Hud.throttle_lever',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.200000,DrawPivot=DP_MiddleRight,PosX=2.720000,PosY=1.000000,OffsetY=-7,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleRPMZeroPosition(0)=26000.000000
     VehicleRPMZeroPosition(1)=26000.000000
     VehicleRPMScale(0)=-1300.000000
     VehicleRPMScale(1)=-1300.000000
     VehicleSpeedZeroPosition(0)=-5500.000000
     VehicleSpeedZeroPosition(1)=26000.000000
     VehicleSpeedScale(0)=-545.000000
     VehicleSpeedScale(1)=-430.000000
     VehicleThrottleTopZeroPosition=0.310000
     VehicleThrottleTopMaxPosition=0.890000
     VehicleThrottleBottomZeroPosition=0.700000
     VehicleThrottleBottomMaxPosition=0.880000
     VehicleGaugesOccupantsTextOffset=0.400000
     VehicleGaugesNoThrottleOccupantsTextOffset=0.360000
     VehicleNeedlesRotationSpeed=30000.000000
     CaptureBarBackground=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_filled',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarOutline=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_outline',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarAttacker=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_bar',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Right,Scale=0.450000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarDefender=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_bar',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Left,Scale=0.550000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarAttackerRatio=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_bar2',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Right,Scale=0.450000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarDefenderRatio=(WidgetTexture=Texture'InterfaceArt_tex.HUD.capbar_bar2',RenderStyle=STY_Alpha,TextureCoords=(X2=255,Y2=63),TextureScale=0.500000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,ScaleMode=SM_Left,Scale=0.550000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarIcons(0)=(RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.230000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,OffsetX=-216,OffsetY=-38,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarIcons(1)=(RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.230000,DrawPivot=DP_LowerMiddle,PosX=0.500000,PosY=0.980000,OffsetX=216,OffsetY=-38,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CaptureBarTeamIcons(0)=Texture'InterfaceArt_tex.HUD.ironcross'
     CaptureBarTeamIcons(1)=Texture'InterfaceArt_tex.HUD.russtar'
     CaptureBarTeamColors(0)=(A=255)
     CaptureBarTeamColors(1)=(R=255,A=255)
     HintFadeTime=0.500000
     HintLifetime=12.000000
     HintDesiredAspectRatio=10.000000
     HintBackground=(WidgetTexture=Texture'InterfaceArt_tex.Menu.SectionHeader_captionbar',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosY=0.020000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     HintTitleWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HintTextWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HintCoords=(X=0.980000,Y=0.030000,XL=-1.000000)
     ConsoleColor=(B=255,G=255,R=255)
     ConsoleMessagePosX=0.010000
     ConsoleMessagePosY=0.800000
     FontArrayNames(0)="ROFonts.ROBtsrmVr28"
     FontArrayNames(1)="ROFonts.ROBtsrmVr26"
     FontArrayNames(5)="ROFonts.ROBtsrmVr16"
     FontArrayNames(6)="ROFonts.ROBtsrmVr14"
     FontArrayNames(7)="ROFonts.ROBtsrmVr12"
     FontArrayNames(8)="ROFonts.ROBtsrmVr9"
     bBlockHitPointTraces=False
}
