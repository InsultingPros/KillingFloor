#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=PatchTex.utx
#exec OBJ LOAD FILE=KFInterfaceContent.utx
#exec OBJ LOAD FILE=KFKillMeNow.utx
#exec OBJ LOAD FILE=KFMapEndTextures.utx
#exec OBJ LOAD FILE=InterfaceArt_tex.utx
#exec OBJ LOAD FILE=kf_fx_trip_t.utx


class HUDKillingFloor extends HudBase
	config(User);

var     int                     KFHUDAlpha;
var     int                     GrainAlpha;

var()   SpriteWidget            HealthBG;
var()   SpriteWidget            HealthIcon;
var()   NumericWidget           HealthDigits;

var()   SpriteWidget            ArmorBG;
var()   SpriteWidget            ArmorIcon;
var()   NumericWidget           ArmorDigits;

var()   SpriteWidget            WeightBG;
var()   SpriteWidget            WeightIcon;
var()   NumericWidget           WeightDigits;

var()   SpriteWidget            GrenadeBG;
var()   SpriteWidget            GrenadeIcon;
var()   NumericWidget           GrenadeDigits;

var()   SpriteWidget            ClipsBG;
var()   SpriteWidget            ClipsIcon;
var()   NumericWidget           ClipsDigits;

var()   SpriteWidget            SecondaryClipsBG;
var()   SpriteWidget            SecondaryClipsIcon;
var()   NumericWidget           SecondaryClipsDigits;

var()   SpriteWidget            BulletsInClipBG;
var()   SpriteWidget            BulletsInClipIcon;
var()   NumericWidget           BulletsInClipDigits;

var()   SpriteWidget			M79Icon;
var()   SpriteWidget			PipeBombIcon;
var()   SpriteWidget			LawRocketIcon;
var()   SpriteWidget			ArrowheadIcon;
var()   SpriteWidget			SingleBulletIcon;
var()   SpriteWidget			FlameIcon;
var()   SpriteWidget			FlameTankIcon;
var()   SpriteWidget			HuskAmmoIcon;
var()   SpriteWidget			SawAmmoIcon;
var()   SpriteWidget			ZEDAmmoIcon;

var()   SpriteWidget            FlashlightBG;
var()   SpriteWidget            FlashlightIcon;
var()   SpriteWidget            FlashlightOffIcon;
var()   NumericWidget           FlashlightDigits;

var()   SpriteWidget            WelderBG;
var()   SpriteWidget            WelderIcon;
var()   NumericWidget           WelderDigits;

var()   SpriteWidget            SyringeBG;
var()   SpriteWidget            SyringeIcon;
var()   NumericWidget           SyringeDigits;

var()   SpriteWidget            MedicGunBG;
var()   SpriteWidget            MedicGunIcon;
var()   NumericWidget           MedicGunDigits;

var		bool					bDisplayQuickSyringe;
var		float					QuickSyringeStartTime;
var		float					QuickSyringeDisplayTime;
var		float					QuickSyringeFadeInTime;
var		float					QuickSyringeFadeOutTime;
var()   SpriteWidget            QuickSyringeBG;
var()   SpriteWidget            QuickSyringeIcon;
var()   NumericWidget           QuickSyringeDigits;

var()   SpriteWidget            CashIcon;
var()   NumericWidget           CashDigits;

var		Material				VetStarMaterial;
var		Material				VetStarGoldMaterial;
var		float					VetStarSize;

var		float					EnemyHealthBarLength;
var		float					EnemyHealthBarHeight;
var     float                   HealthBarFullVisDist;
var     float                   HealthBarCutoffDist;
var     float                   BarLength;
var     float                   BarHeight;
var		float					ArmorIconSize;
var		float					HealthIconSize;
var		Material				WhiteMaterial;

var()   DigitSet                DigitsSmall;
var()   DigitSet                DigitsBig;

var     transient float         MaxAmmoPrimary;
var     transient float         CurAmmoPrimary;
var     transient float         CurClipsPrimary;
var     transient float         CurClipsSecondary;

var     transient Frag          PlayerGrenade;

var     KFDoorMover             DoorMover;
var     string                  WeldText;

var     Material                Portrait;
var     float                   PortraitTime;
var     float                   PortraitX;
var		Material				TraderPortrait;

var()   Material                VisionOverlay;
var()   Material                SpectatorOverlay;
var()   Material                NearDeathOverlay;
var()   Material                FireOverlay;

var()   Font                    LevelActionFontFont;
var()   color                   LevelActionFontColor;

var()   float                   LevelActionPositionX;
var()   float                   LevelActionPositionY;

var     class<DamageType>       HUDHitDamage;
var     bool                    DamageIsUber;

var     ZoneInfo                CurrentZone;
var     ZoneInfo                LastZone;
var     PhysicsVolume           CurrentVolume;
var     PhysicsVolume           LastVolume;

var     bool                    bZoneChanged;
var     bool                    bTicksTurn;
var     int                     ValueCheckOut;

var     material                LastWeaponMat;

var     float                   NextModLogTime;

var     bool                    bInitialDark;  // a variable that initializes the overlay as black so theres' no pop-in when it adjusts to the zone color

var()   float                   VeterancyMatScaleFactor;   // Amount to scale all Veterancy indicators on the HUD by

var     float                   CurrentR;
var     float                   CurrentG;
var     float                   CurrentB;
var     float                   LastR;
var     float                   LastG;
var     float                   LastB;
var()   float                   OverlayFadeSpeed;  // How quickly the HUD color overlay blends between zones.  default = 0.025
//var color FogColor;
var     int                     NumCalls;

var		localized string		WaveString;
var		localized string		TraderString;
var		localized string		WeldIntegrityString;
var		localized string		DistanceUnitString;

// KF Cinematic Subtitles
var     string                  Subtitle;
var     int                     SubIndex;
var     float                   LastSubChangeTime;
var     bool                    bGetNewSub;
var     bool                    bDisplayDeathScreen;
var     Actor                   GoalTarget;

var     KFSPLevelInfo           KFLevelRule;

// intro cinematic
var     float                   IntroTitleFade,DamageStartTime;
var     float                   Global_Delta;

var     KFPlayerReplicationInfo KFPRI;
var     KFGameReplicationInfo   KFGRI;

var     float                   NextStatsUdpTime;
var     float                   EndGameHUDTime;
var     float                   VomitHudTimer;
var     float                   DamageHUDTimer;
var     ColorModifier           MyColorMod;
var     KFShopDirectionPointer  ShopDirPointer;

// Voice meter
var     TexRotator              NeedleRotator; 			// The texture for the VU Meter needle
var     texture                 VoiceMeterBackground;   // Background texture for the voice meter
var()   float                   VoiceMeterX;    		// Voice meter X position
var()   float                   VoiceMeterY;    		// Voice meter Y position
var()   float                   VoiceMeterSize;         // Size of the voice meter icon
var     bool                    bUsingVOIP; // Player is using VOIP

var     bool                    bDrawDoorHealth;
var		float					LastDoorBarHealthUpdate;
var 	array<KFDoorMover>		DoorCache;
var		texture 				DoorWelderBG;
var		texture					DoorWelderIcon;

// Inventory Display
var	bool		bDisplayInventory;
var	bool		bInventoryFadingIn;
var	bool		bInventoryFadingOut;
var	float		InventoryFadeTime;
var	float		InventoryFadeStartTime;
var	texture		InventoryBackgroundTexture;
var	texture		SelectedInventoryBackgroundTexture;
var	float		InventoryX;
var	float		InventoryY;
var	float		InventoryBoxWidth;
var	float		InventoryBoxHeight;
var	float		BorderSize;
var	int			SelectedInventoryCategory;
var	int			SelectedInventoryIndex;
var	Inventory	SelectedInventory;

struct InventoryCategory
{
	var	Inventory	Items[6];
	var	int			ItemCount;
};

// Popup notification
var	bool	bShowNotification;
var	int		NotificationFontSize;
var	string	NotificationString;
var	texture	NotificationIcon;
var	texture	NotificationBackground;
var	float	NotificationWidth;
var	float	NotificationHeight;
var	float	NotificationBorderSize;
var	float	NotificationIconSpacing;
var	float	NotificationShowTime;
var	float	NotificationHideTime;
var	float	NotificationHideDelay;
var	int		NotificationPhase;			// 0 = Showing, 1 = Delaying, 2 = Hiding
var	float	NotificationPhaseStartTime;	// Time at which the current Notification Phase started(Showing, Delaying, Hiding)

// Fonts
var		localized	string		SmallFontArrayNames[9];
var		Font					SmallFontArrayFonts[9];

var		localized	string		MenuFontArrayNames[5];
var		Font					MenuFontArrayFonts[5];

var		localized	string		WaitingFontArrayNames[3];
var		Font					WaitingFontArrayFonts[3];

// General hud
var		float					hudLastRenderTime;
var		float					SwitchDigitColorTime;

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


// for hints
var						bool				bDrawHint;
var         			bool                bFirstHintRender; // Used to only calculate hint sizing constants once
var(HUDKillingFloor)  	float               HintFadeTime; // How long it takes to fade in/out
var         			float               HintRemainingTime;
var(HUDKillingFloor)  	float               HintLifetime;
var(HUDKillingFloor)  	float               HintDesiredAspectRatio; // Aspect ratio used to wrap hint data
var         			string              HintTitle, HintText; // This is localized in KFHintManager
var         			array<string>       HintWrappedText;
var(HUDKillingFloor)  	SpriteWidget        HintBackground;
var(HUDKillingFloor)  	TextWidget          HintTitleWidget;
var(HUDKillingFloor)  	TextWidget          HintTextWidget;
var(HUDKillingFloor)  	RelativeCoordsInfo  HintCoords; // default properties of this are used when rendering, XL and YL are used to pivot around the X and Y pos
var						bool				bIsSecondDowntime;
var						float				Hint_45_Time;
var						bool				bHint_45_TimeSet;

// Player Info List(Used to draw Name, Health, Armor, and Veterancy over players)
struct PlayerInfoPawnType
{
	var KFPawn	Pawn;
	var	float	PlayerInfoScreenPosX;
	var	float	PlayerInfoScreenPosY;
	var float	RendTime;
};
var	array<PlayerInfoPawnType>				PlayerInfoPawns;

var globalconfig bool           			bShowMapUpdatedText;

var                     bool                bShowBuddyDebug;    // Dev only, show info about your buddies
var                     bool                bShowEnemyDebug;    // Dev only, show info about your enemies

var                     bool                bShowKFDebugXHair;

var globalconfig		bool				bLightHud;

/* Should we display Specimen kills on the HUD as they occur ?  (Marco's mod) */
var globalconfig        bool                bTallySpecimenKills;

var                     int                 MessageHealthLimit,MessageMassLimit;

// Screen Blackout
var	float	FadeTime;
var	color	FadeColor;
var	float	WhiteFlashTime;

// debugging
var bool bDebugPlayerCollision;

simulated function PostBeginPlay()
{
	local Font MyFont;

	if ( MyColorMod==None )
	{
		MyColorMod = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
		MyColorMod.AlphaBlend = True;
		MyColorMod.Color.R = 255;
		MyColorMod.Color.B = 255;
		MyColorMod.Color.G = 255;
	}

	Super.PostBeginPlay();
	SetHUDAlpha();

	foreach DynamicActors(class'KFSPLevelInfo', KFLevelRule)
	{
	   Break;
	}

	Hint_45_Time = 9999999;

	MyFont = LoadWaitingFont(0);
	MyFont = LoadWaitingFont(1);
}
simulated function Destroyed()
{
	if ( MyColorMod!=None )
	{
		MyColorMod.AlphaBlend = MyColorMod.Default.AlphaBlend;
		MyColorMod.Material = None;
		MyColorMod.Color = MyColorMod.Default.Color;
		Level.ObjectPool.FreeObject(MyColorMod);
		MyColorMod = None;
	}

	if ( ShopDirPointer!=None )
	{
		ShopDirPointer.Destroy();
	}

	Super.Destroyed();
}

/* toggles displaying properties of player's current viewtarget
*/
exec function ShowDebug()
{
	if( Level.NetMode != NM_Standalone && !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

    bShowDebugInfo = !bShowDebugInfo;
}


// Take it out.
exec function ShowHud()
{
    bHideHud = !bHideHud;

	if ( ShopDirPointer!=None )
	{
		ShopDirPointer.bHidden = bHideHud;
	}

	SaveConfig();
}

exec function HideScores()
{
	bShowScoreboard = false;
}

simulated function SetHUDAlpha()
{
	HealthBG.Tints[0].A = KFHUDAlpha;
	HealthBG.Tints[1].A = KFHUDAlpha;
	HealthIcon.Tints[0].A = KFHUDAlpha;
	HealthIcon.Tints[1].A = KFHUDAlpha;
	HealthDigits.Tints[0].A = KFHUDAlpha;
	HealthDigits.Tints[1].A = KFHUDAlpha;

	ArmorBG.Tints[0].A = KFHUDAlpha;
	ArmorBG.Tints[1].A = KFHUDAlpha;
	ArmorIcon.Tints[0].A = KFHUDAlpha;
	ArmorIcon.Tints[1].A = KFHUDAlpha;
	ArmorDigits.Tints[0].A = KFHUDAlpha;
	ArmorDigits.Tints[1].A = KFHUDAlpha;

	WeightBG.Tints[0].A = KFHUDAlpha;
	WeightBG.Tints[1].A = KFHUDAlpha;
	WeightIcon.Tints[0].A = KFHUDAlpha;
	WeightIcon.Tints[1].A = KFHUDAlpha;
	WeightDigits.Tints[0].A = KFHUDAlpha;
	WeightDigits.Tints[1].A = KFHUDAlpha;

	GrenadeBG.Tints[0].A = KFHUDAlpha;
	GrenadeBG.Tints[1].A = KFHUDAlpha;
	GrenadeIcon.Tints[0].A = KFHUDAlpha;
	GrenadeIcon.Tints[1].A = KFHUDAlpha;
	GrenadeDigits.Tints[0].A = KFHUDAlpha;
	GrenadeDigits.Tints[1].A = KFHUDAlpha;

	ClipsBG.Tints[0].A = KFHUDAlpha;
	ClipsBG.Tints[1].A = KFHUDAlpha;
	ClipsIcon.Tints[0].A = KFHUDAlpha;
	ClipsIcon.Tints[1].A = KFHUDAlpha;
	ClipsDigits.Tints[0].A = KFHUDAlpha;
	ClipsDigits.Tints[1].A = KFHUDAlpha;

	SecondaryClipsBG.Tints[0].A = KFHUDAlpha;
	SecondaryClipsBG.Tints[1].A = KFHUDAlpha;
	SecondaryClipsIcon.Tints[0].A = KFHUDAlpha;
	SecondaryClipsIcon.Tints[1].A = KFHUDAlpha;
	SecondaryClipsDigits.Tints[0].A = KFHUDAlpha;
	SecondaryClipsDigits.Tints[1].A = KFHUDAlpha;

	BulletsInClipBG.Tints[0].A = KFHUDAlpha;
	BulletsInClipBG.Tints[1].A = KFHUDAlpha;
	BulletsInClipIcon.Tints[0].A = KFHUDAlpha;
	BulletsInClipIcon.Tints[1].A = KFHUDAlpha;
	BulletsInClipDigits.Tints[0].A = KFHUDAlpha;
	BulletsInClipDigits.Tints[1].A = KFHUDAlpha;

	M79Icon.Tints[0].A = KFHUDAlpha;
	M79Icon.Tints[1].A = KFHUDAlpha;
	HuskAmmoIcon.Tints[0].A = KFHUDAlpha;
	HuskAmmoIcon.Tints[1].A = KFHUDAlpha;
	PipeBombIcon.Tints[0].A = KFHUDAlpha;
	PipeBombIcon.Tints[1].A = KFHUDAlpha;
	LawRocketIcon.Tints[0].A = KFHUDAlpha;
	LawRocketIcon.Tints[1].A = KFHUDAlpha;
    ArrowheadIcon.Tints[0].A = KFHUDAlpha;
    ArrowheadIcon.Tints[1].A = KFHUDAlpha;
    SawAmmoIcon.Tints[0].A = KFHUDAlpha;
    SawAmmoIcon.Tints[1].A = KFHUDAlpha;
    SingleBulletIcon.Tints[0].A = KFHUDAlpha;
    SingleBulletIcon.Tints[1].A = KFHUDAlpha;
    FlameIcon.Tints[0].A = KFHUDAlpha;
    FlameIcon.Tints[1].A = KFHUDAlpha;
	FlameTankIcon.Tints[0].A = KFHUDAlpha;
	FlameTankIcon.Tints[1].A = KFHUDAlpha;
	ZEDAmmoIcon.Tints[0].A = KFHUDAlpha;
	ZEDAmmoIcon.Tints[1].A = KFHUDAlpha;

	FlashlightBG.Tints[0].A = KFHUDAlpha;
	FlashlightBG.Tints[1].A = KFHUDAlpha;
	FlashlightIcon.Tints[0].A = KFHUDAlpha;
	FlashlightIcon.Tints[1].A = KFHUDAlpha;
	FlashlightOffIcon.Tints[0].A = KFHUDAlpha;
	FlashlightOffIcon.Tints[1].A = KFHUDAlpha;
	FlashlightDigits.Tints[0].A = KFHUDAlpha;
	FlashlightDigits.Tints[1].A = KFHUDAlpha;

	WelderBG.Tints[0].A = KFHUDAlpha;
	WelderBG.Tints[1].A = KFHUDAlpha;
	WelderIcon.Tints[0].A = KFHUDAlpha;
	WelderIcon.Tints[1].A = KFHUDAlpha;
	WelderDigits.Tints[0].A = KFHUDAlpha;
	WelderDigits.Tints[1].A = KFHUDAlpha;

	SyringeBG.Tints[0].A = KFHUDAlpha;
	SyringeBG.Tints[1].A = KFHUDAlpha;
	SyringeIcon.Tints[0].A = KFHUDAlpha;
	SyringeIcon.Tints[1].A = KFHUDAlpha;
	SyringeDigits.Tints[0].A = KFHUDAlpha;
	SyringeDigits.Tints[1].A = KFHUDAlpha;

	MedicGunBG.Tints[0].A = KFHUDAlpha;
	MedicGunBG.Tints[1].A = KFHUDAlpha;
	MedicGunIcon.Tints[0].A = KFHUDAlpha;
	MedicGunIcon.Tints[1].A = KFHUDAlpha;
	MedicGunDigits.Tints[0].A = KFHUDAlpha;
	MedicGunDigits.Tints[1].A = KFHUDAlpha;

	QuickSyringeBG.Tints[0].A = KFHUDAlpha;
	QuickSyringeBG.Tints[1].A = KFHUDAlpha;
	QuickSyringeIcon.Tints[0].A = KFHUDAlpha;
	QuickSyringeIcon.Tints[1].A = KFHUDAlpha;
	QuickSyringeDigits.Tints[0].A = KFHUDAlpha;
	QuickSyringeDigits.Tints[1].A = KFHUDAlpha;

	CashIcon.Tints[0].A = KFHUDAlpha;
	CashIcon.Tints[1].A = KFHUDAlpha;
	CashDigits.Tints[0].A = KFHUDAlpha;
	CashDigits.Tints[1].A = KFHUDAlpha;
}

simulated function Tick(float deltaTime)
{
	local Material NewPortrait;

	if ( KFGameReplicationInfo(Level.GRI)!= none && KFGameReplicationInfo(Level.GRI).EndGameType > 0 && EndGameHUDTime < 1 )
	{
		EndGameHUDTime += (deltaTime / 3.f);
	}

	Super.Tick(deltaTime);

	Global_Delta = DeltaTime;

   	if ( (Level.TimeSeconds - LastPlayerIDTalkingTime < 0.1) && (PlayerOwner.GameReplicationInfo != None) )
	{
		if ( (PortraitPRI == None) || (PortraitPRI.PlayerID != LastPlayerIDTalking) )
		{
			PortraitPRI = PlayerOwner.GameReplicationInfo.FindPlayerByID(LastPlayerIDTalking);
			if ( PortraitPRI != None )
			{
				NewPortrait = PortraitPRI.GetPortrait();

				if ( NewPortrait != None )
				{
					if ( Portrait == None )
					{
						PortraitX = 1;
					}

					Portrait = NewPortrait;
					PortraitTime = Level.TimeSeconds + 3;
				}
			}
		}
		else
		{
			PortraitTime = Level.TimeSeconds + 0.2;
		}
	}
	else
	{
		LastPlayerIDTalking = 0;
	}

	if ( PortraitTime - Level.TimeSeconds > 0 )
	{
		PortraitX = FMax(0, PortraitX - 3 * deltaTime);
	}
	else if ( Portrait != None )
	{
		PortraitX = FMin(1, PortraitX + 3 * deltaTime);

		if ( PortraitX == 1 )
		{
			Portrait = None;
			PortraitPRI = None;
		}
	}

	if ( KFPRI == none )
	{
		if ( PawnOwner != none )
		{
			KFPRI = KFPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo);
		}

		if ( KFPRI == none && PlayerOwner != none )
		{
			KFPRI = KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);
		}
	}

	if ( KFGRI == None )
	{
		KFGRI = KFGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	}
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local int i;
	local KFPawn KFP;

	KFP = KFPawn(P);

	if ( KFP == none || PawnOwner == none ||
		 KFP.PlayerReplicationInfo == none || PawnOwner.PlayerReplicationInfo == none ||
		 KFP.PlayerReplicationInfo.Team != PawnOwner.PlayerReplicationInfo.Team )
	{
		return;
	}

	for ( i = 0; i < PlayerInfoPawns.Length; i++ )
	{
		if ( PlayerInfoPawns[i].Pawn == P )
		{
			PlayerInfoPawns[i].PlayerInfoScreenPosX = ScreenLocX;
			PlayerInfoPawns[i].PlayerInfoScreenPosY = ScreenLocY;
			PlayerInfoPawns[i].RendTime = Level.TimeSeconds + 0.1;
			return;
		}
	}

	i = PlayerInfoPawns.Length;
	PlayerInfoPawns.Length = i + 1;
	PlayerInfoPawns[i].Pawn = KFP;
	PlayerInfoPawns[i].PlayerInfoScreenPosX = ScreenLocX;
	PlayerInfoPawns[i].PlayerInfoScreenPosY = ScreenLocY;
	PlayerInfoPawns[i].RendTime = Level.TimeSeconds + 0.1;
}

function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize;
	local string PlayerName;
	local float Dist, OffsetX;
	local byte BeaconAlpha;
	local float OldZ;
	local Material TempMaterial, TempStarMaterial;
	local int i, TempLevel;

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo) == none || KFPRI == none || KFPRI.bViewingMatineeCinematic )
	{
		return;
	}

	Dist = vsize(P.Location - PlayerOwner.CalcViewLocation);
	Dist -= HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
	Dist = Dist / (HealthBarCutoffDist - HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);

	if ( BeaconAlpha == 0 )
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255, 255, 255, BeaconAlpha);
	C.Font = GetConsoleFont(C);
	PlayerName = Left(P.PlayerReplicationInfo.PlayerName, 16);
	C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75));
	C.DrawTextClipped(PlayerName);

    BarLength = FMin(default.BarLength * (float(C.SizeX) / 1024.f),default.BarLength);
    BarHeight = FMin(default.BarHeight * (float(C.SizeX) / 1024.f),default.BarHeight);

	OffsetX = (36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill != none &&
		 KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon != none )
	{
		if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel > 5 )
		{
			TempMaterial = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDGoldIcon;
			TempStarMaterial = VetStarGoldMaterial;
			TempLevel = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel - 5;
		}
		else
		{
			TempMaterial = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon;
			TempStarMaterial = VetStarMaterial;
			TempLevel = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel;
		}

		TempSize = FMin((36 * VeterancyMatScaleFactor ) * (float(C.SizeX) / 1024.f),36 * VeterancyMatScaleFactor) ;
		VetStarSize = FMin(default.VetStarSize * (float(C.SizeX) / 1024.f),default.VetStarSize);
		TempX = ScreenLocX + ((BarLength + HealthIconSize) * 0.5) - (TempSize * 0.25) - OffsetX;
		TempY = ScreenLocY - YL - (TempSize * 0.75);

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - (VetStarSize * 0.75));
		TempY += (TempSize - (VetStarSize * 1.5));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(TempStarMaterial, VetStarSize * 0.7, VetStarSize * 0.7, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			TempY -= VetStarSize * 0.7;
		}
	}

	// Health
	if ( P.Health > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 0.4 * BarHeight, FClamp(P.Health / P.HealthMax, 0, 1), BeaconAlpha);

	// Armor
	if ( P.ShieldStrength > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, FClamp(P.ShieldStrength / 100.f, 0, 1), BeaconAlpha, true);

	C.Z = OldZ;
}

simulated function DrawKFBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha, optional bool bArmor)
{
	C.SetDrawColor(192, 192, 192, BarAlpha);
	C.SetPos(XCentre - 0.5 * BarLength, YCentre - 0.5 * BarHeight);
	C.DrawTileStretched(WhiteMaterial, BarLength, BarHeight);

	if ( bArmor )
	{
		C.SetDrawColor(255, 255, 255, BarAlpha);
		C.SetPos(XCentre - (0.5 * BarLength) - ArmorIconSize - 2.0, YCentre - (ArmorIconSize * 0.5));
		C.DrawTile(ArmorIcon.WidgetTexture, ArmorIconSize, ArmorIconSize, 0, 0, ArmorIcon.WidgetTexture.MaterialUSize(), ArmorIcon.WidgetTexture.MaterialVSize());

		C.SetDrawColor(0, 0, 255, BarAlpha);
	}
	else
	{
		C.SetDrawColor(255, 255, 255, BarAlpha);
		C.SetPos(XCentre - (0.5 * BarLength) - HealthIconSize - 2.0, YCentre - (HealthIconSize * 0.5));
		C.DrawTile(HealthIcon.WidgetTexture, HealthIconSize, HealthIconSize, 0, 0, HealthIcon.WidgetTexture.MaterialUSize(), HealthIcon.WidgetTexture.MaterialVSize());

		C.SetDrawColor(255, 0, 0, BarAlpha);
	}

	C.SetPos(XCentre - (0.5 * BarLength) + 1.0, YCentre - (0.5 * BarHeight) + 1.0);
	C.DrawTileStretched(WhiteMaterial, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0);
}

// Debugging only player info display
simulated function DrawEnemyInfo(Canvas C, KFMonster A, float Height)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist;
	local color OldDrawColor;
	local string EnemyName;
	local float XL,YL;
	local name  Sequence, Sequence2;
	local float Frame, Rate, Frame2, Rate2;

	if( !bShowEnemyDebug || !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		return;
	}

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu

	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' )
	{
		return;
	}

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + vect(0, 0, 1) * Height;
	Dist = VSize(TargetLocation - CameraLocation);

	CamDir  = vector(CameraRotation);

	// Check behind camera cut off
	if ( (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	{
		return;
	}

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);
		HBScreenPos = C.WorldToScreen(TargetLocation);

		if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.ClipX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.ClipY)
		{
			return;
		}
	}


	C.DrawColor = WhiteColor;

	EnemyName = "Enemy";

	if ( EnemyName != "" )
	{



        //A.GetAnimParams( 0, Sequence, Frame, Rate );
        //A.GetAnimParams( 1, Sequence2, Frame2, Rate2 );

		//EnemyName = EnemyName @ ":" @ (VSize(A.Location  - C.ViewPort.Actor.Pawn.Location)/50.0) @ "m " @ VSize(A.Velocity) @ "UU/S";
		EnemyName = " state = " @ (A.GetStateName()) @ " C state = " @ (A.Controller.GetStateName()) @ " Anim 0: " @ Sequence @ " Rate: " @ Rate @ " Frame: " @ Frame @ " Anim 1: " @ Sequence2 @ " Rate2: " @ Rate2 @ " Frame2: " @ Frame2;
		//EnemyName = " Anim 0: " @ Sequence @ " Rate: " @ Rate @ " Frame: " @ Frame @ " Anim 1: " @ Sequence2 @ " Rate2: " @ Rate2 @ " Frame2: " @ Frame2;
		C.Font = GetFontSizeIndex(C, -2);
		C.StrLen(EnemyName, XL, YL);

		if ( XL > 0.125 * C.ClipY )
		{
			C.Font = GetFontSizeIndex(C, -4);
			C.StrLen(EnemyName, XL, YL);
		}

		C.SetPos(HBScreenPos.X - 0.5*XL , HBScreenPos.Y - YL);
		C.DrawText(EnemyName);
	}

	C.DrawColor = OldDrawColor;
}

// Debugging only player info display
simulated function DrawBuddyInfo(Canvas C, Actor A, float Height)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist;
	local color OldDrawColor;
	local string EnemyName;
	local float XL,YL;

	if( !bShowBuddyDebug || !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		return;
	}

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu

	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' )
	{
		return;
	}

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + vect(0, 0, 1) * Height;
	Dist = VSize(TargetLocation - CameraLocation);

	CamDir  = vector(CameraRotation);

	// Check Distance Threshold / behind camera cut off
	if ( (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	{
		return;
	}

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);
		HBScreenPos = C.WorldToScreen(TargetLocation);

		if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.ClipX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.ClipY)
		{
			return;
		}
	}


	C.DrawColor = WhiteColor;

	EnemyName = "Buddy";

	if ( EnemyName != "" )
	{

		EnemyName = EnemyName @ ":" @ (VSize(A.Location  - C.ViewPort.Actor.Pawn.Location)/50.0) @ DistanceUnitString;
		C.Font = GetFontSizeIndex(C, -2);
		C.StrLen(EnemyName, XL, YL);

		if ( XL > 0.125 * C.ClipY )
		{
			C.Font = GetFontSizeIndex(C, -4);
			C.StrLen(EnemyName, XL, YL);
		}

		C.SetPos(HBScreenPos.X - 0.5*XL , HBScreenPos.Y - YL);
		C.DrawText(EnemyName);
	}

	C.DrawColor = OldDrawColor;
}


simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	local KFMonster KFEnemy;
	local KFPawn KFBuddy;
	local rotator CamRot;
	local vector CamPos, ViewDir;
	local int i;
	local bool bBloom;

	if ( KFGameType(PlayerOwner.Level.Game) != none )
		CurrentGame = KFGameReplicationInfo(PlayerOwner.Level.GRI);

	if ( FontsPrecached < 2 )
		PrecacheFonts(C);

	UpdateHud();

	PassStyle = STY_Modulated;
	DrawModOverlay(C);

	bBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	if ( bBloom )
	{
		PlayerOwner.PostFX_SetActive(0, true);
	}

	if ( bHideHud )
	{
		// Draw fade effects even if the hud is hidden so poeple can't just turn off thier hud
		C.Style = ERenderStyle.STY_Alpha;
		DrawFadeEffect(C);
		return;
	}

	if( bShowEnemyDebug && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		if ( C.ViewPort.Actor.Pawn != none )
		{
			foreach C.ViewPort.Actor.DynamicActors(class'KFMonster',KFEnemy)
			{
				if ( KFEnemy.Health > 0 && !KFEnemy.Cloaked() )
				{
					DrawEnemyInfo(C, KFEnemy, 50.0);
				}
			}
		}
	}

	if( bShowBuddyDebug && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		if ( C.ViewPort.Actor.Pawn != none )
		{
			foreach C.ViewPort.Actor.DynamicActors(class'KFPawn',KFBuddy)
			{
				if ( KFBuddy.Health > 0 )
				{
					DrawBuddyInfo(C, KFBuddy, 50.0);
				}
			}
		}
	}

	if ( !KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		if ( bShowTargeting )
			DrawTargeting(C);

		// Grab our View Direction
		C.GetCameraLocation(CamPos,CamRot);
		ViewDir = vector(CamRot);

		// Draw the Name, Health, Armor, and Veterancy above other players
		for ( i = 0; i < PlayerInfoPawns.Length; i++ )
		{
			if ( PlayerInfoPawns[i].Pawn != none && PlayerInfoPawns[i].Pawn.Health > 0 && (PlayerInfoPawns[i].Pawn.Location - PawnOwner.Location) dot ViewDir > 0.8 &&
				 PlayerInfoPawns[i].RendTime > Level.TimeSeconds )
			{
				DrawPlayerInfo(C, PlayerInfoPawns[i].Pawn, PlayerInfoPawns[i].PlayerInfoScreenPosX, PlayerInfoPawns[i].PlayerInfoScreenPosY);
			}
			else
			{
				PlayerInfoPawns.Remove(i--, 1);
			}
		}

		PassStyle = STY_Alpha;
		DrawDamageIndicators(C);
		DrawHudPassA(C);
		DrawHudPassC(C);

		if ( KFPlayerController(PlayerOwner)!= None && KFPlayerController(PlayerOwner).ActiveNote!= None )
		{
			if( PlayerOwner.Pawn == none )
				KFPlayerController(PlayerOwner).ActiveNote = None;
			else KFPlayerController(PlayerOwner).ActiveNote.RenderNote(C);
		}

		PassStyle = STY_None;
		DisplayLocalMessages(C);
		DrawWeaponName(C);
		DrawVehicleName(C);

		PassStyle = STY_Modulated;

		if ( KFGameReplicationInfo(Level.GRI)!= None && KFGameReplicationInfo(Level.GRI).EndGameType > 0 )
		{
			if ( KFGameReplicationInfo(Level.GRI).EndGameType == 2 )
			{
				DrawEndGameHUD(C, True);
				Return;
			}
			else
			{
				DrawEndGameHUD(C, False);
			}
		}

		DrawKFHUDTextElements(C);
	}

	if ( KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		PassStyle = STY_Alpha;
		DrawCinematicHUD(C);
	}

	if ( bShowNotification )
	{
		DrawPopupNotification(C);
	}

	//DrawHeadShotSphere();
}

// For debugging headshots
//simulated function DrawHeadShotSphere() // Dave@Psyonix
//{
//    local KFMonster KFM;
//    local coords CO;
//    local vector HeadLoc;
//
//    //super.DrawHeadShotSphere();
//
//    foreach DynamicActors(class'KFMonster', KFM)
//    {
//        if( KFM != none && KFM.ServerHeadLocation != KFM.LastServerHeadLocation )
//        {
//            //KFM.DrawDebugSphere(KFM.Location + (KFM.OnlineHeadshotOffset >> KFM.Rotation), KFM.HeadRadius * KFM.HeadScale * KFM.OnlineHeadshotScale, 10, 0, 255, 0);
//
//            ClearStayingDebugLines();
//            KFM.LastServerHeadLocation = KFM.ServerHeadLocation;
//            DrawStayingDebugSphere(KFM.ServerHeadLocation, KFM.HeadRadius * KFM.HeadScale, 10, 128, 255, 255);
//            CO = KFM.GetBoneCoords(KFM.HeadBone);
//            HeadLoc = CO.Origin + (KFM.HeadHeight * KFM.HeadScale * CO.XAxis);
//            DrawStayingDebugSphere(HeadLoc, KFM.HeadRadius * KFM.HeadScale, 10, 0, 255, 0);
//            break;
//        }
//    }
//}

simulated function DrawStayingDebugSphere(vector Base, float Radius, int NumDivisions, byte R, byte G, byte B)
{
	local float AngleDelta;
	local int SideIndex;
	local float	SegmentDist;
	local float TempZ;
	local vector UsedBase;

	AngleDelta = 2.0f * PI / NumDivisions;
	SegmentDist = 2.0 * Radius / NumDivisions;

	// Horizontal circles change in scale
	for( SideIndex = -NumDivisions/2; SideIndex < NumDivisions/2; SideIndex++)
	{
		TempZ = SideIndex*SegmentDist;
		UsedBase = Base;// - vect(0,0,TempZ);
		UsedBase.Z -= TempZ;
        DrawStayingDebugCircle(UsedBase, vect(1,0,0), vect(0,1,0), R,G,B, Sqrt(Radius*Radius - SideIndex*SegmentDist*SideIndex*SegmentDist), NumDivisions);
	}

	// Vertical circles change in angle
	for(SideIndex = 0; SideIndex < NumDivisions; SideIndex++)
	{
		DrawStayingDebugCircle(Base, vect(0,0,1), vect(1,0,0) * Cos(AngleDelta * SideIndex) + vect(0,1,0) * Sin(AngleDelta * SideIndex),  R,G,B, Radius, NumDivisions);
	}
}

simulated function DrawStayingDebugCircle(vector Base,vector X,vector Y, byte R, byte G, byte B,float Radius,int NumSides)
{
	local float AngleDelta;
	local int SideIndex;
	local vector LastVertex, Vertex;

	AngleDelta = 2.0f * PI / NumSides;
	LastVertex = Base + X * Radius;

	for(SideIndex = 0;SideIndex < NumSides;SideIndex++)
	{
		Vertex = Base + (X * Cos(AngleDelta * (SideIndex + 1)) + Y * Sin(AngleDelta * (SideIndex + 1))) * Radius;

		DrawStayingDebugLine(LastVertex,Vertex,R,G,B);

		LastVertex = Vertex;
	}
}

simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist, HealthPct;
	local color OldDrawColor;

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu

	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' )
	{
		return;
	}

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);
	Dist = VSize(TargetLocation - CameraLocation);

    EnemyHealthBarLength = FMin(default.EnemyHealthBarLength * (float(C.SizeX) / 1024.f),default.EnemyHealthBarLength);
    EnemyHealthBarHeight = FMin(default.EnemyHealthBarHeight * (float(C.SizeX) / 1024.f),default.EnemyHealthBarHeight);


	CamDir  = vector(CameraRotation);

	// Check Distance Threshold / behind camera cut off
	if ( Dist > HealthBarCutoffDist || (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	{
		return;
	}

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		return;
	}

	if ( FastTrace(TargetLocation, CameraLocation) )
	{
		C.SetDrawColor(192, 192, 192, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5, HBScreenPos.Y);
		C.DrawTileStretched(WhiteMaterial, EnemyHealthBarLength, EnemyHealthBarHeight);

		HealthPct = 1.0f * Health / MaxHealth;

		C.SetDrawColor(255, 0, 0, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5 + 1.0, HBScreenPos.Y + 1.0);
		C.DrawTileStretched(WhiteMaterial, (EnemyHealthBarLength - 2.0) * HealthPct, EnemyHealthBarHeight - 2.0);
	}

	C.DrawColor = OldDrawColor;
}


simulated function FindPlayerGrenade()
{
	local inventory inv;
	local class<Ammunition> AmmoClass;

	if( PawnOwner == none )
	{
		return;
	}

	for ( inv = PawnOwner.inventory; inv != none; inv = inv.Inventory)
	{
		if ( Frag(inv) != none )
		{
			PlayerGrenade = Frag(inv);
			AmmoClass = PlayerGrenade.GetAmmoClass(0);
		}
	}
}

simulated function UpdateHud()
{
	local float MaxGren, CurGren;
	local KFHumanPawn KFHPawn;
	local Syringe S;

	if( PawnOwner == none )
	{
		super.UpdateHud();
		return;
	}

	KFHPawn = KFHumanPawn(PawnOwner);

	CalculateAmmo();

	if ( KFHPawn != none )
	{
		FlashlightDigits.Value = 100 * (float(KFHPawn.TorchBatteryLife) / float(KFHPawn.default.TorchBatteryLife));
	}

	if ( KFWeapon(PawnOwner.Weapon) != none )
	{
		BulletsInClipDigits.Value = KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;

		if ( BulletsInClipDigits.Value < 0 )
		{
			BulletsInClipDigits.Value = 0;
		}
	}

	ClipsDigits.Value = CurClipsPrimary;
	SecondaryClipsDigits.Value = CurClipsSecondary;

	if ( LAW(PawnOwner.Weapon) != none || Crossbow(PawnOwner.Weapon) != none
        || M79GrenadeLauncher(PawnOwner.Weapon) != none || PipeBombExplosive(PawnOwner.Weapon) != none
        || HuskGun(PawnOwner.Weapon) != none || CrossBuzzSaw(PawnOwner.Weapon) != none
        || SPGrenadeLauncher(PawnOwner.Weapon) != none  )
	{
		ClipsDigits.Value = KFWeapon(PawnOwner.Weapon).AmmoAmount(0);
	}

	if ( PlayerGrenade == none )
	{
		FindPlayerGrenade();
	}

	if ( PlayerGrenade != none )
	{
		PlayerGrenade.GetAmmoCount(MaxGren, CurGren);
		GrenadeDigits.Value = CurGren;
	}
	else
	{
		GrenadeDigits.Value = 0;
	}

 	HealthDigits.Value = PawnOwner.Health;
	ArmorDigits.Value = xPawn(PawnOwner).ShieldStrength;

	// "Poison" the health meter
	if ( VomitHudTimer > Level.TimeSeconds )
	{
		HealthDigits.Tints[0].R = 196;
		HealthDigits.Tints[0].G = 206;
		HealthDigits.Tints[0].B = 0;

		HealthDigits.Tints[1].R = 196;
		HealthDigits.Tints[1].G = 206;
		HealthDigits.Tints[1].B = 0;
	}
	else if ( PawnOwner.Health < 50 )
	{
		if ( Level.TimeSeconds < SwitchDigitColorTime )
		{
			HealthDigits.Tints[0].R = 255;
			HealthDigits.Tints[0].G = 200;
			HealthDigits.Tints[0].B = 0;

			HealthDigits.Tints[1].R = 255;
			HealthDigits.Tints[1].G = 200;
			HealthDigits.Tints[1].B = 0;
		}
		else
		{
			HealthDigits.Tints[0].R = 255;
			HealthDigits.Tints[0].G = 0;
			HealthDigits.Tints[0].B = 0;

			HealthDigits.Tints[1].R = 255;
			HealthDigits.Tints[1].G = 0;
			HealthDigits.Tints[1].B = 0;

			if ( Level.TimeSeconds > SwitchDigitColorTime + 0.2 )
			{
				SwitchDigitColorTime = Level.TimeSeconds + 0.2;
			}
		}
	}
	else
	{
		HealthDigits.Tints[0].R = 255;
		HealthDigits.Tints[0].G = 50;
		HealthDigits.Tints[0].B = 50;

		HealthDigits.Tints[1].R = 255;
		HealthDigits.Tints[1].G = 50;
		HealthDigits.Tints[1].B = 50;
	}



	CashDigits.Value = PawnOwnerPRI.Score;

	WelderDigits.Value = 100 * (CurAmmoPrimary / MaxAmmoPrimary);
	SyringeDigits.Value = WelderDigits.Value;

	if ( SyringeDigits.Value < 50 )
	{
		SyringeDigits.Tints[0].R = 128;
		SyringeDigits.Tints[0].G = 128;
		SyringeDigits.Tints[0].B = 128;

		SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
	}
	else if ( SyringeDigits.Value < 100 )
	{
		SyringeDigits.Tints[0].R = 192;
		SyringeDigits.Tints[0].G = 96;
		SyringeDigits.Tints[0].B = 96;

		SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
	}
	else
	{
		SyringeDigits.Tints[0].R = 255;
		SyringeDigits.Tints[0].G = 64;
		SyringeDigits.Tints[0].B = 64;

		SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
	}

	if ( bDisplayQuickSyringe  )
	{
		S = Syringe(PawnOwner.FindInventoryType(class'Syringe'));
		if ( S != none )
		{
			QuickSyringeDigits.Value = S.ChargeBar() * 100;

			if ( QuickSyringeDigits.Value < 50 )
			{
				QuickSyringeDigits.Tints[0].R = 128;
				QuickSyringeDigits.Tints[0].G = 128;
				QuickSyringeDigits.Tints[0].B = 128;

				QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
			}
			else if ( QuickSyringeDigits.Value < 100 )
			{
				QuickSyringeDigits.Tints[0].R = 192;
				QuickSyringeDigits.Tints[0].G = 96;
				QuickSyringeDigits.Tints[0].B = 96;

				QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
			}
			else
			{
				QuickSyringeDigits.Tints[0].R = 255;
				QuickSyringeDigits.Tints[0].G = 64;
				QuickSyringeDigits.Tints[0].B = 64;

				QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
			}
		}
	}

	// Hints
	if ( PawnOwner.Health <= 50 )
	{
		KFPlayerController(PlayerOwner).CheckForHint(51);
	}

	Super.UpdateHud();
}

simulated function ShowQuickSyringe()
{
	if ( bDisplayQuickSyringe )
	{
		if ( Level.TimeSeconds - QuickSyringeStartTime > QuickSyringeFadeInTime )
		{
			if ( Level.TimeSeconds - QuickSyringeStartTime > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
			{
				QuickSyringeStartTime = Level.TimeSeconds - QuickSyringeFadeInTime + ((QuickSyringeDisplayTime - (Level.TimeSeconds - QuickSyringeStartTime)) * QuickSyringeFadeInTime);
			}
			else
			{
				QuickSyringeStartTime = Level.TimeSeconds - QuickSyringeFadeInTime;
			}
		}
	}
	else
	{
		bDisplayQuickSyringe = true;
		QuickSyringeStartTime = Level.TimeSeconds;
	}
}

simulated function CalculateAmmo()
{
	MaxAmmoPrimary = 1;
	CurAmmoPrimary = 1;

	if ( PawnOwner == None || KFWeapon(PawnOwner.Weapon) == none )
		return;

	PawnOwner.Weapon.GetAmmoCount(MaxAmmoPrimary,CurAmmoPrimary);

	if( PawnOwner.Weapon.FireModeClass[1].default.AmmoClass != none )
	{
	   CurClipsSecondary = PawnOwner.Weapon.AmmoAmount(1);
	}

	if( KFWeapon(PawnOwner.Weapon).bHoldToReload )
	{
		CurClipsPrimary = Max(CurAmmoPrimary-KFWeapon(PawnOwner.Weapon).MagAmmoRemaining,0); // Single rounds reload, just show the true ammo count.
		return;
	}

	CurClipsPrimary = (CurAmmoPrimary - KFWeapon(PawnOwner.Weapon).MagAmmoRemaining) / KFWeapon(PawnOwner.Weapon).MagCapacity;

	// count the partial clip if there is one
	if ( (CurAmmoPrimary - KFWeapon(PawnOwner.Weapon).MagAmmoRemaining) % KFWeapon(PawnOwner.Weapon).MagCapacity > 0 )
		CurClipsPrimary += 1;

	if ( CurClipsPrimary < 0 )
		CurClipsPrimary = 0;
}

simulated function DrawHudPassA (Canvas C)
{
	local KFHumanPawn KFHPawn;
	local Material TempMaterial, TempStarMaterial;
	local int i, TempLevel;
	local float TempX, TempY, TempSize;

	KFHPawn = KFHumanPawn(PawnOwner);

	DrawDoorHealthBars(C);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, HealthBG);
	}

	DrawSpriteWidget(C, HealthIcon);
	DrawNumericWidget(C, HealthDigits, DigitsSmall);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, ArmorBG);
	}

	DrawSpriteWidget(C, ArmorIcon);
	DrawNumericWidget(C, ArmorDigits, DigitsSmall);

	if ( KFHPawn != none )
	{
		C.SetPos(C.ClipX * WeightBG.PosX, C.ClipY * WeightBG.PosY);

		if ( !bLightHud )
		{
			C.DrawTile(WeightBG.WidgetTexture, WeightBG.WidgetTexture.MaterialUSize() * WeightBG.TextureScale * 1.5 * HudCanvasScale * ResScaleX * HudScale, WeightBG.WidgetTexture.MaterialVSize() * WeightBG.TextureScale * HudCanvasScale * ResScaleY * HudScale, 0, 0, WeightBG.WidgetTexture.MaterialUSize(), WeightBG.WidgetTexture.MaterialVSize());
		}

		DrawSpriteWidget(C, WeightIcon);

		C.Font = LoadSmallFontStatic(5);
		C.FontScaleX = C.ClipX / 1024.0;
		C.FontScaleY = C.FontScaleX;
		C.SetPos(C.ClipX * WeightDigits.PosX, C.ClipY * WeightDigits.PosY);
		C.DrawColor = WeightDigits.Tints[0];
		C.DrawText(int(KFHPawn.CurrentWeight)$"/"$int(KFHPawn.MaxCarryWeight));
		C.FontScaleX = 1;
		C.FontScaleY = 1;
	}

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, GrenadeBG);
	}

	DrawSpriteWidget(C, GrenadeIcon);
	DrawNumericWidget(C, GrenadeDigits, DigitsSmall);

	if ( PawnOwner != none && PawnOwner.Weapon != none )
	{
		if ( Syringe(PawnOwner.Weapon) != none )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, SyringeBG);
			}

			DrawSpriteWidget(C, SyringeIcon);
			DrawNumericWidget(C, SyringeDigits, DigitsSmall);
		}
		else
		{
			if ( bDisplayQuickSyringe )
			{
				TempSize = Level.TimeSeconds - QuickSyringeStartTime;
				if ( TempSize < QuickSyringeDisplayTime )
				{
					if ( TempSize < QuickSyringeFadeInTime )
					{
						QuickSyringeBG.Tints[0].A = int((TempSize / QuickSyringeFadeInTime) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else if ( TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
					{
						QuickSyringeBG.Tints[0].A = int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else
					{
						QuickSyringeBG.Tints[0].A = 255;
						QuickSyringeBG.Tints[1].A = 255;
						QuickSyringeIcon.Tints[0].A = 255;
						QuickSyringeIcon.Tints[1].A = 255;
						QuickSyringeDigits.Tints[0].A = 255;
						QuickSyringeDigits.Tints[1].A = 255;
					}

					if ( !bLightHud )
					{
						DrawSpriteWidget(C, QuickSyringeBG);
					}

					DrawSpriteWidget(C, QuickSyringeIcon);
					DrawNumericWidget(C, QuickSyringeDigits, DigitsSmall);
				}
				else
				{
					bDisplayQuickSyringe = false;
				}
			}

    		if ( MP7MMedicGun(PawnOwner.Weapon) != none || MP5MMedicGun(PawnOwner.Weapon) != none || M7A3MMedicGun(PawnOwner.Weapon) != none  )
    		if ( MP7MMedicGun(PawnOwner.Weapon) != none || MP5MMedicGun(PawnOwner.Weapon) != none
                || M7A3MMedicGun(PawnOwner.Weapon) != none || KrissMMedicGun(PawnOwner.Weapon) != none )
    		if ( MP7MMedicGun(PawnOwner.Weapon) != none || MP5MMedicGun(PawnOwner.Weapon) != none )
    		{
                if( MP7MMedicGun(PawnOwner.Weapon) != none )
                {
                    MedicGunDigits.Value = MP7MMedicGun(PawnOwner.Weapon).ChargeBar() * 100;
                }
                else if( M7A3MMedicGun(PawnOwner.Weapon) != none )
                {
                    MedicGunDigits.Value = M7A3MMedicGun(PawnOwner.Weapon).ChargeBar() * 100;
                }
                else if( MP5MMedicGun(PawnOwner.Weapon) != none )
                {
                    MedicGunDigits.Value = MP5MMedicGun(PawnOwner.Weapon).ChargeBar() * 100;
                }
                else
                {
                    MedicGunDigits.Value = KrissMMedicGun(PawnOwner.Weapon).ChargeBar() * 100;
                }

            	if ( MedicGunDigits.Value < 50 )
            	{
            		MedicGunDigits.Tints[0].R = 128;
            		MedicGunDigits.Tints[0].G = 128;
            		MedicGunDigits.Tints[0].B = 128;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else if ( MedicGunDigits.Value < 100 )
            	{
            		MedicGunDigits.Tints[0].R = 192;
            		MedicGunDigits.Tints[0].G = 96;
            		MedicGunDigits.Tints[0].B = 96;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else
            	{
            		MedicGunDigits.Tints[0].R = 255;
            		MedicGunDigits.Tints[0].G = 64;
            		MedicGunDigits.Tints[0].B = 64;

            		MedicGunDigits.Tints[1] = MedicGunDigits.Tints[0];
            	}

    			if ( !bLightHud )
    			{
    				DrawSpriteWidget(C, MedicGunBG);
    			}

    			DrawSpriteWidget(C, MedicGunIcon);
    			DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
    		}

			if ( Welder(PawnOwner.Weapon) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, WelderBG);
				}

				DrawSpriteWidget(C, WelderIcon);
				DrawNumericWidget(C, WelderDigits, DigitsSmall);
			}
			else if ( PawnOwner.Weapon.GetAmmoClass(0) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, ClipsBG);
				}

				if ( HuskGun(PawnOwner.Weapon) != none )
				{
					ClipsDigits.PosX = 0.873;
                    DrawNumericWidget(C, ClipsDigits, DigitsSmall);
                    ClipsDigits.PosX = default.ClipsDigits.PosX;
				}
				else
				{
				    DrawNumericWidget(C, ClipsDigits, DigitsSmall);
				}

				if ( LAW(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, LawRocketIcon);
				}
				else if ( Crossbow(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, ArrowheadIcon);
				}
				else if ( CrossBuzzSaw(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, SawAmmoIcon);
				}
				else if ( PipeBombExplosive(PawnOwner.Weapon) != none )
				{
                    DrawSpriteWidget(C, PipeBombIcon);
				}
				else if ( M79GrenadeLauncher(PawnOwner.Weapon) != none || SPGrenadeLauncher(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, M79Icon);
				}
				else if ( HuskGun(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, HuskAmmoIcon);
				}
				else
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, BulletsInClipBG);
					}

					DrawNumericWidget(C, BulletsInClipDigits, DigitsSmall);

					if ( Flamethrower(PawnOwner.Weapon) != none )
					{
						DrawSpriteWidget(C, FlameIcon);
						DrawSpriteWidget(C, FlameTankIcon);
					}
				    else if ( Shotgun(PawnOwner.Weapon) != none || BoomStick(PawnOwner.Weapon) != none || Winchester(PawnOwner.Weapon) != none
                        || BenelliShotgun(PawnOwner.Weapon) != none )
				    {
					    DrawSpriteWidget(C, SingleBulletIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
				    }
					else if ( ZEDGun(PawnOwner.Weapon) != none )
					{
						DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, ZedAmmoIcon);
					}
					else
					{
						DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
				}

				if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bTorchEnabled )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, FlashlightBG);
					}

					DrawNumericWidget(C, FlashlightDigits, DigitsSmall);

					if ( KFWeapon(PawnOwner.Weapon).FlashLight != none && KFWeapon(PawnOwner.Weapon).FlashLight.bHasLight )
					{
						DrawSpriteWidget(C, FlashlightIcon);
					}
					else
					{
						DrawSpriteWidget(C, FlashlightOffIcon);
					}
				}
			}

            // Secondary ammo
            if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bHasSecondaryAmmo )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, SecondaryClipsBG);
				}

				DrawNumericWidget(C, SecondaryClipsDigits, DigitsSmall);
				DrawSpriteWidget(C, SecondaryClipsIcon);
			}
		}
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
	{
		KFPRI.ClientVeteranSkill.Static.SpecialHUDInfo(KFPRI, C);
	}

	if ( KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo) == none || KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHUDShowCash )
	{
		DrawSpriteWidget(C, CashIcon);
		DrawNumericWidget(C, CashDigits, DigitsBig);
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.default.OnHUDIcon != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel > 5 )
		{
			TempMaterial = KFPRI.ClientVeteranSkill.default.OnHUDGoldIcon;
			TempStarMaterial = VetStarGoldMaterial;
			TempLevel = KFPRI.ClientVeteranSkillLevel - 5;
			C.SetDrawColor(255, 255, 255, 192);
		}
		else
		{
			TempMaterial = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
			TempStarMaterial = VetStarMaterial;
			TempLevel = KFPRI.ClientVeteranSkillLevel;
		}

		TempSize = FMin((36 * VeterancyMatScaleFactor * 1.4) * (float(C.SizeX) / 1024.f),36 * VeterancyMatScaleFactor * 1.4) ;
		VetStarSize = FMin(default.VetStarSize * (float(C.SizeX) / 1024.f),default.VetStarSize);
		TempX = C.ClipX * 0.007;
		TempY = C.ClipY * 0.93 - TempSize;

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - VetStarSize);
		TempY += (TempSize - (2.0 * VetStarSize));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(TempStarMaterial, VetStarSize, VetStarSize, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			TempY -= VetStarSize;
		}
	}

	if ( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			 PlayerOwner.ActiveRoom.GetTitle() == "Team" )
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP = false;
	}

	if ( bDisplayInventory || bInventoryFadingOut )
	{
		DrawInventory(C);
	}
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

	VoiceGain = (1 - 3 * Min(Level.TimeSeconds - LastVoiceGainTime, 0.3333 )) * LastVoiceGain;

	YOffset = 12 * scale;
	IconSize = VoiceMeterSize * Scale;

	PosY = VoiceMeterY * C.ClipY - IconSize - YOffset;
	PosX = VoiceMeterX * C.ClipX;
	C.SetPos(PosX, PosY);

	C.DrawTile(VoiceMeterBackground, IconSize, IconSize, 0, 0, VoiceMeterBackground.USize, VoiceMeterBackground.VSize);

	NeedleRotator.Rotation.Yaw = -1 * ((20000 * VoiceGain) + 55000);

	C.SetPos(PosX, PosY);
	C.DrawTileScaled(NeedleRotator, scale * VoiceMeterSize / 128.0, scale * VoiceMeterSize / 128.0);

	// Display name of currently active channel
	if ( PlayerOwner != None && PlayerOwner.ActiveRoom != None )
	{
		ActiveName = PlayerOwner.ActiveRoom.GetTitle();
	}

	// Remove for release
	if ( ActiveName == "" )
	{
		ActiveName = "No Channel Selected!";
	}

	if ( ActiveName != "" )
	{
	    C.SetPos(0, 0);
		ActiveName = "(" @ ActiveName @ ")";
		C.Font = GetFontSizeIndex(C, -2);
		C.StrLen(ActiveName, XL, YL);

		if ( XL > 0.125 * C.ClipY )
		{
			C.Font = GetFontSizeIndex(C, -4);
			C.StrLen(ActiveName, XL, YL);
		}

		C.SetPos(PosX + ((IconSize / 2) - (XL / 2)), PosY - YL);
		C.DrawColor = C.MakeColor(160, 160, 160);

		if ( PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None )
		{
			if ( PlayerOwner.PlayerReplicationInfo.Team != None )
			{
				if ( PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == 0 )
				{
					C.DrawColor = RedColor;
				}
				else
				{
					C.DrawColor = TurqColor;
				}
			}
		}

		C.DrawText(ActiveName);
	}

	C.DrawColor = SavedColor;
}

simulated event PostRender( canvas Canvas )
{
	local float XPos, YPos;
	local plane OldModulate;
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

	if ( PawnOwner != None && PawnOwner.bSpecialHUD )
	{
		PawnOwner.DrawHud(Canvas);
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetConsoleFont(Canvas);
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor = ConsoleColor;

		PlayerOwner.ViewTarget.DisplayDebug(Canvas, XPos, YPos);
		if  (PlayerOwner.ViewTarget != PlayerOwner && (Pawn(PlayerOwner.ViewTarget) == None ||
			 Pawn(PlayerOwner.ViewTarget).Controller == None) )
		{
			YPos += XPos * 2;
			Canvas.SetPos(4, YPos);
			Canvas.DrawText("----- VIEWER INFO -----");
			YPos += XPos;
			Canvas.SetPos(4, YPos);
			PlayerOwner.DisplayDebug(Canvas, XPos, YPos);
		}
	}
	else
	{
		if ( PlayerOwner == None || (PawnOwner == None) || (PawnOwnerPRI == None) ||
			 (PlayerOwner.IsSpectating() && PlayerOwner.bBehindView) )
		{
			DrawSpectatingHud(Canvas);
		}
		else if ( !PawnOwner.bHideRegularHUD )
		{
			DrawHud(Canvas);
		}

		if( !bHideHud )
		{
    		for ( i = 0; i < Overlays.length; i++ )
    		{
    			Overlays[i].Render(Canvas);
    		}

    		if ( !DrawLevelAction(Canvas) )
    		{
    			if ( PlayerOwner != None )
    			{
    				if ( PlayerOwner.ProgressTimeOut > Level.TimeSeconds )
    				{
    					DisplayProgressMessages(Canvas);
    				}
    				else if ( MOTDState == 1 )
    				{
    					MOTDState=2;
    				}
    			}
    		}

    		if ( bShowBadConnectionAlert )
    		{
    			DisplayBadConnectionAlert(Canvas);
    		}

    		DisplayMessages(Canvas);

    		if ( bShowVoteMenu && VoteMenu != None )
    		{
    			VoteMenu.RenderOverlays(Canvas);
    		}
		}
	}

	PlayerOwner.RenderOverlays(Canvas);

	if ( PlayerConsole != None && PlayerConsole.bTyping )
	{
		DrawTypingPrompt(Canvas, PlayerConsole.TypedStr, PlayerConsole.TypedStrPos);
	}

	if ( bDrawHint && !bHideHud )
	{
	    DrawHint(Canvas);
	}

	hudLastRenderTime = Level.TimeSeconds;

	Canvas.ColorModulate = OldModulate;
	Canvas.DrawColor = OldColor;
	OnPostRender(Self, Canvas);
}

simulated function DrawTypingPrompt (Canvas C, String Text, optional int Pos)
{
    local float XPos, YPos;
    local float XL, YL;

    C.Font = GetConsoleFont(C);
    C.Style = ERenderStyle.STY_Alpha;
    //C.DrawColor = ConsoleColor;
    C.SetDrawColor(244, 237, 205, 255);

    C.TextSize ("A", XL, YL);

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeY) - YL;

    C.SetPos (XPos, YPos);
    //C.DrawTextClipped ("(>"@Left(Text, Pos)$"_"$Right(Text, Len(Text) - Pos), false);
    C.DrawTextClipped("(>"@Left(Text, Pos)$chr(4)$Eval(Pos < Len(Text), Mid(Text, Pos), "_"), true);
}


function CanvasDrawActors(Canvas C, bool bClearedZBuffer)
{
	if ( PawnOwner!= none && !PlayerOwner.bBehindView && PawnOwner.Weapon != None )
	{
		if ( !bClearedZBuffer )
		{
			C.DrawActor(None, false, true); // Clear the z-buffer here
		}

		//TODO: only draw one when suitably prepared
		if ( KFPawn(PawnOwner).SecondaryItem != none )
		{
			KFPawn(PawnOwner).SecondaryItem.RenderOverlays(C);
		}
		else
		{
			PawnOwner.Weapon.RenderOverlays(C);
		}
	}
}

function DisplayMessages(Canvas C)
{
	local int i, j, XPos, YPos,MessageCount;
	local float XL, YL;

	for( i = 0; i < ConsoleMessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
			break;
		else if( TextMessages[i].MessageLife < Level.TimeSeconds )
		{
			TextMessages[i].Text = "";

			if( i < ConsoleMessageCount - 1 )
			{
				for( j=i; j<ConsoleMessageCount-1; j++ )
					TextMessages[j] = TextMessages[j+1];
			}
			TextMessages[j].Text = "";
			break;
		}
		else
			MessageCount++;
	}

	YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);
	if ( PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none || !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	{
		XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}
	else
	{
		XPos = (0.005 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}

	C.Font = GetConsoleFont(C);
	C.DrawColor = LevelActionFontColor;

	C.TextSize ("A", XL, YL);

	YPos -= YL * MessageCount+1; // DP_LowerLeft
	YPos -= YL; // Room for typing prompt

	for( i=0; i<MessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
			break;

		C.StrLen( TextMessages[i].Text, XL, YL );
		C.SetPos( XPos, YPos );
		C.DrawColor = TextMessages[i].TextColor;
		C.DrawText( TextMessages[i].Text, false );
		YPos += YL;
	}
}

simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local int      NumZombies, Min;
	local string   S;
	local vector   Pos, FixedZPos;
	local rotator  ShopDirPointerRotation;
	local float    CircleSize;
	local float    ResScale;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping )
	{
		return;
	}

    ResScale =  C.SizeX / 1024.0;
    CircleSize = FMin(128 * ResScale,128);
	C.FontScaleX = FMin(ResScale,1.f);
	C.FontScaleY = FMin(ResScale,1.f);

	// Countdown Text
	if( !KFGRI.bWaveInProgress )
	{
		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX - CircleSize, 2);
		C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Clock_Circle', CircleSize, CircleSize, 0, 0, 256, 256);

		if ( KFGRI.TimeToNextWave <= 5 )
		{
			// Hints
		   	if ( bIsSecondDowntime )
		   	{
				KFPlayerController(PlayerOwner).CheckForHint(40);
			}
		}

		Min = KFGRI.TimeToNextWave / 60;
		NumZombies = KFGRI.TimeToNextWave - (Min * 60);

		S = Eval((Min >= 10), string(Min), "0" $ Min) $ ":" $ Eval((NumZombies >= 10), string(NumZombies), "0" $ NumZombies);
		C.Font = LoadFont(2);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - YL / 2);
		C.DrawText(S, False);
	}
	else
	{
		//Hints
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(30);

			if ( !bHint_45_TimeSet && KFGRI.WaveNumber == 1)
			{
				Hint_45_Time = Level.TimeSeconds + 5;
				bHint_45_TimeSet = true;
			}
		}

		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX - CircleSize, 2);
		C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', CircleSize, CircleSize, 0, 0, 256, 256);

		S = string(KFGRI.MaxMonsters);
		C.Font = LoadFont(1);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - (YL / 1.5));
		C.DrawText(S);

		// Show the number of waves
		S = WaveString @ string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
		C.Font = LoadFont(5);
		C.Strlen(S, XL, YL);
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 + (YL / 2.5));
		C.DrawText(S);

   		//Needed for the hints showing up in the second downtime
		bIsSecondDowntime = true;
	}

	C.FontScaleX = 1;
	C.FontScaleY = 1;


	if ( KFPRI == none || KFPRI.Team == none || KFPRI.bOnlySpectator || PawnOwner == none )
	{
		return;
	}

	// Draw the shop pointer
	if ( ShopDirPointer == None )
	{
		ShopDirPointer = Spawn(Class'KFShopDirectionPointer');
		ShopDirPointer.bHidden = bHideHud;
	}

	Pos.X = C.SizeX / 18.0;
	Pos.Y = C.SizeX / 18.0;
	Pos = PlayerOwner.Player.Console.ScreenToWorld(Pos) * 10.f * (PlayerOwner.default.DefaultFOV / PlayerOwner.FovAngle) + PlayerOwner.CalcViewLocation;
	ShopDirPointer.SetLocation(Pos);

	if ( KFGRI.CurrentShop != none )
	{
		// Let's check for a real Z difference (i.e. different floor) doesn't make sense to rotate the arrow
		// only because the trader is a midget or placed slightly wrong
		if ( KFGRI.CurrentShop.Location.Z > PawnOwner.Location.Z + 50.f || KFGRI.CurrentShop.Location.Z < PawnOwner.Location.Z - 50.f )
		{
		    ShopDirPointerRotation = rotator(KFGRI.CurrentShop.Location - PawnOwner.Location);
		}
		else
		{
		    FixedZPos = KFGRI.CurrentShop.Location;
		    FixedZPos.Z = PawnOwner.Location.Z;
		    ShopDirPointerRotation = rotator(FixedZPos - PawnOwner.Location);
		}
	}
	else
	{
		ShopDirPointer.bHidden = true;
		return;
	}

   	ShopDirPointer.SetRotation(ShopDirPointerRotation);

	if ( Level.TimeSeconds > Hint_45_Time && Level.TimeSeconds < Hint_45_Time + 2 )
	{
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(45);
		}
	}

	C.DrawActor(None, False, True); // Clear Z.
	ShopDirPointer.bHidden = false;
	C.DrawActor(ShopDirPointer, False, false);
	ShopDirPointer.bHidden = true;
	DrawTraderDistance(C);
}

// Draws the distance to the trader in meters when the ShopDirPointer is active
simulated final function DrawTraderDistance(Canvas C)
{
	local int       FontSize;
	local float     StrWidth, StrHeight;
	local string    TraderDistanceText;

   	if ( PawnOwner != none && KFGRI != none )
   	{
		if ( KFGRI.CurrentShop != none )
		{
		   	TraderDistanceText = TraderString$":" @ int(VSize(KFGRI.CurrentShop.Location - PawnOwner.Location) / 50) $ DistanceUnitString;
		}
		else
		{
			return;
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

		C.Font = LoadFont(FontSize);
		C.SetDrawColor(255, 50, 50, 255);
		C.StrLen(TraderDistanceText, StrWidth, StrHeight);
		C.SetPos((C.SizeX / 14.0) - (StrWidth / 2.0), C.SizeX / 10.0);
		C.DrawText(TraderDistanceText);
	}
}

simulated function Timer()
{
	if ( KFLevelRule != none && !KFLevelRule.bUseVisionOverlay )
	{
		return;
	}

	if ( bZoneChanged )
	{
		// Lets get the facts straight, first.
		if ( CurrentZone != none )
		{
			if( CurrentZone.bNewKFColorCorrection )
			{
                CurrentR = CurrentZone.KFOverlayColor.R;
				CurrentG = CurrentZone.KFOverlayColor.G;
				CurrentB = CurrentZone.KFOverlayColor.B;
			}
			else
			{
    			CurrentR = CurrentZone.DistanceFogColor.R ;
    			CurrentG = CurrentZone.DistanceFogColor.G ;
    			CurrentB = CurrentZone.DistanceFogColor.B ;
			}
		}
		else if ( CurrentVolume != none )
		{
			if( CurrentVolume.bNewKFColorCorrection )
			{
                CurrentR = CurrentVolume.KFOverlayColor.R;
				CurrentG = CurrentVolume.KFOverlayColor.G;
				CurrentB = CurrentVolume.KFOverlayColor.B;
			}
			else
			{
    			CurrentR = CurrentVolume.DistanceFogColor.R ;
    			CurrentG = CurrentVolume.DistanceFogColor.G ;
    			CurrentB = CurrentVolume.DistanceFogColor.B ;
		}
		}
		else return;

		// Do we even need to tally up, or we sorted?
		if( LastR == CurrentR && LastG == CurrentG && LastB == CurrentB )
		{
			bZoneChanged = false;
			bTicksTurn = false;
			return;
		}

		// Now to even them out.
		if ( ValueCheckOut < 3 )
		{
			if ( LastR < CurrentR )
			{
				LastR += (Round(Abs(LastR-CurrentR) * 0.1) + 0.0625);
			}
			else if ( LastR > CurrentR )
			{
				LastR -= (Round(Abs(LastR-CurrentR) * 0.1) + 0.0625);
			}

			if ( LastG < CurrentG )
			{
				LastG += (Round(Abs(LastG-CurrentG) * 0.1) + 0.0625);
			}
			else if ( LastG > CurrentG )
			{
				LastG -= (Round(Abs(LastG-CurrentG) * 0.1) + 0.0625);
			}

			if ( LastB < CurrentB )
			{
				LastB += (Round(Abs(LastB-CurrentB) * 0.1) + 0.0625);
			}
			else if ( LastB > CurrentB )
			{
				LastB -= (Round(Abs(LastB-CurrentB) * 0.1) + 0.0625);
			}

			ValueCheckOut = 3;
		}
		// Bounce back 'atcha to display the result of my maths!
		if ( ValueCheckOut == 3 )
		{
			bTicksTurn = false;
		}
		// Joy , we're all sorted. Time to alert The Canvas.
	}
}

// "Mood" overlay.
// : By Alex
// Simulates post process
// This is my finest achievement! It basically Blends between
// ZoneInfo DistanceFog R G B   colorvalues  and applies that
// information to the DrawColor of the Screen overlay

simulated function DrawModOverlay( Canvas C )
{
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;
	local PlayerReplicationInfo PRI;
	local bool bHasDefaultPhysicsVolume, bHasKFPhysicsVolume;

	C.SetPos(0, 0);

	// We want the overlay to start black, and fade in, almost like the player opened their eyes
	// BrightFactor = 1.5;   // Not too bright.  Not too dark.  Livens things up just abit
	// Hook for Optional Vision overlay.  - Alex
	if ( VisionOverlay != none )
	{
		if( PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none )
		{
			return;
		}

		PRI = PlayerOwner.PlayerReplicationInfo;

		// if critical, pulsate.  otherwise, dont.
		if ( PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health > 0 )
		{
			if ( PlayerOwner.pawn.Health < PlayerOwner.pawn.HealthMax * 0.25 )
			{
				VisionOverlay = NearDeathOverlay;
			}
			else if ( KFPawn(PlayerOwner.pawn).BurnDown > 0 )
			{
				//Chris: disabled for now, can't see shit in single or listen server
				//VisionOverlay = FireOverlay;
			}
			else
			{
				VisionOverlay = default.VisionOverlay;
			}
		}

		// Dead Players see Red
		if( PRI.bOutOfLives || PRI.bIsSpectator )
		{
/*			if( !bDisplayDeathScreen )
			{
				Return;
			}
			if ( PlayerOwner.ViewTarget != GoalTarget || GoalTarget == None )
			{
				bDisplayDeathScreen = False;
			}

*/			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(SpectatorOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
			return;
		}
		// So Do Lobby players
/*		else if ( CurrentZone == none && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
		{
			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(GhostMat, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
		}
*/
		// Hook for fade in from black at the start.
		if ( !bInitialDark && PRI.bReadyToPlay )
		{
			C.SetDrawColor(0, 0, 0, 255);
			C.DrawTile(VisionOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
			bInitialDark = true;
			return;
		}

		// Players can choose to turn this feature off completely.
		// conversely, setting bDistanceFog = false in a Zone
		//will cause the code to ignore that zone for a shift in RGB tint
		if ( KFLevelRule != none && !KFLevelRule.bUseVisionOverlay )
		{
			return;
		}

		// here we determine the maximum "brighten" amounts for each value.  CANNOT exceed 255
		MaxRBrighten = Round(LastR* (1.0 - (LastR / 255)) - 2) ;
		MaxGBrighten = Round(LastG* (1.0 - (LastG / 255)) - 2) ;
		MaxBBrighten = Round(LastB* (1.0 - (LastB / 255)) - 2) ;

		C.SetDrawColor(LastR + MaxRBrighten, LastG + MaxGBrighten, LastB + MaxBBrighten, GrainAlpha);
		C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);  //,0,0,1024,1024);

		/*
				// Added Canvas Modulation
				C.ColorModulate.X = LastR;  //R
				C.ColorModulate.Y = LastG;  //G
				C.ColorModulate.Z = LastB;  //B
				*/

		// Here we change over the Zone.
		// What happens of importance is
		// A.  Set Old Zone to current
		// B.  Set New Zone
		// C.  Set Color info up for use by Tick()

		// if we're in a new zone or volume without distance fog...just , dont touch anything.
		// the physicsvolume check is abit screwy because the player is always in a volume called "DefaultPhyicsVolume"
		// so we've gotta make sure that the return checks take this into consideration.

        // The checks for KFPhysicsVolume below fix the issue with Moonbase's zoneinfo fog
        // settings being overridden. Moonbase is the only map (now, at least) using one of
        // these volumes.
		if ( PlayerOwner != none && PlayerOwner.Pawn != none )
		{
			// This block of code here just makes sure that if we've already got a tint, and we step into a zone/volume without
			// bDistanceFog, our current tint is not affected.
			// a.  If I'm in a zone and its not bDistanceFog. AND IM NOT IN A PHYSICSVOLUME. Just a zone.
			// b.  If I'm in a Volume
			if( DefaultPhysicsVolume( PlayerOwner.Pawn.PhysicsVolume ) != none ||
				PlayerOwner.Pawn.PhysicsVolume.IsA( 'KF_StoryCheckPointVolume' ) )
			{
				bHasDefaultPhysicsVolume = true;
			}
			else if( KFPhysicsVolume( PlayerOwner.Pawn.PhysicsVolume ) != none )
			{
				bHasKFPhysicsVolume = true;
			}

			if ( PRI.PlayerZone != none && !PRI.PlayerZone.bDistanceFog &&
				 PRI.PlayerVolume == none || !bHasDefaultPhysicsVolume &&
				 !PlayerOwner.Pawn.PhysicsVolume.bDistanceFog )
			{
				if( !bHasKFPhysicsVolume )
				{
					return;
				}
			}
		}

		if ( PlayerOwner != none && !bZoneChanged && PlayerOwner.Pawn != none )
		{
			// Grab the most recent zone info from our PRI
			// Only update if it's different
			// EDIT:  AND HAS bDISTANCEFOG true
			if ( CurrentZone != PlayerOwner.PlayerReplicationInfo.PlayerZone || ( !bHasDefaultPhysicsVolume
				&& !bHasKFPhysicsVolume ) && CurrentVolume != PlayerOwner.Pawn.PhysicsVolume )
			{
				if ( CurrentZone != none )
				{
				    LastZone = CurrentZone;
				}
				else if ( CurrentVolume != none )
				{
					LastVolume = CurrentVolume;
				}

				// This is for all occasions where we're either in a Levelinfo handled zone
				// Or a zoneinfo.
				// If we're in a LevelInfo / ZoneInfo  and NOT touching a Volume.  Set current Zone
				if ( PRI.PlayerZone != none && PRI.PlayerZone.bDistanceFog &&
					 ( bHasDefaultPhysicsVolume || bHasKFPhysicsVolume ) && !PRI.PlayerZone.bNoKFColorCorrection )
				{
					CurrentVolume = none;
					CurrentZone = PRI.PlayerZone;
				}
				else if ( !bHasDefaultPhysicsVolume && PlayerOwner.Pawn.PhysicsVolume.bDistanceFog &&
					!PlayerOwner.Pawn.PhysicsVolume.bNoKFColorCorrection)
				{
					CurrentZone = none;
					CurrentVolume = PlayerOwner.Pawn.PhysicsVolume;
				}

				if ( CurrentVolume != none )
				{
					LastZone = none;
				}
				else if ( CurrentZone != none )
				{
					LastVolume = none;
				}

				if ( LastZone != none )
				{
					if( LastZone.bNewKFColorCorrection )
					{
                        LastR = LastZone.KFOverlayColor.R;
    					LastG = LastZone.KFOverlayColor.G;
    					LastB = LastZone.KFOverlayColor.B;
					}
					else
					{
                        LastR = LastZone.DistanceFogColor.R;
    					LastG = LastZone.DistanceFogColor.G;
    					LastB = LastZone.DistanceFogColor.B;
					}
				}
				else if ( LastVolume != none )
				{
					if( LastVolume.bNewKFColorCorrection )
					{
                        LastR = LastVolume.KFOverlayColor.R;
    					LastG = LastVolume.KFOverlayColor.G;
    					LastB = LastVolume.KFOverlayColor.B;
					}
					else
					{
    					LastR = LastVolume.DistanceFogColor.R;
    					LastG = LastVolume.DistanceFogColor.G;
    					LastB = LastVolume.DistanceFogColor.B;
					}
				}
				else if ( LastZone != none && LastVolume != none )
				{
					return;
				}

				if ( LastZone != CurrentZone || LastVolume != CurrentVolume )
				{
					bZoneChanged = true;
					SetTimer(OverlayFadeSpeed, false);
				}
			}
		}
		if ( !bTicksTurn && bZoneChanged )
		{
			// Pass it off to the tick now
			// valueCheckout signifies that none of the three values have been
			// altered by Tick() yet.

			// BOUNCE IT BACK! :D
			ValueCheckOut = 0;
			bTicksTurn = true;
			SetTimer(OverlayFadeSpeed, false);
		}
	}
}

simulated function DrawHudPassC(Canvas C)
{
	DrawFadeEffect(C);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}

	// portrait
	if ( bShowPortrait && (Portrait != None) )
	{
		DrawPortrait(C);
	}

	// Comment Out for Release
	if( Level.NetMode == NM_StandAlone )
	{
		DrawCrosshair(C);
	}

	// Slow, for debugging only
	if( bDebugPlayerCollision && (class'ROEngine.ROLevelInfo'.static.RODebugMode() || Level.NetMode == NM_StandAlone) )
	{
		DrawPointSphere();
	}

}

simulated final function DrawPortrait( Canvas C )
{
	local float PortraitWidth, PortraitHeight, XL, YL, Abbrev;
	local string PortraitString;

	PortraitWidth = 0.125 * C.ClipY;
	PortraitHeight = 1.5 * PortraitWidth;
	C.DrawColor = WhiteColor;

	C.SetPos(-PortraitWidth * PortraitX + 0.025 * PortraitWidth, 0.5 * (C.ClipY - PortraitHeight) + 0.025 * PortraitHeight);
	C.DrawTile(Portrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);

	C.SetPos(-PortraitWidth * PortraitX, 0.5 * (C.ClipY - PortraitHeight));
	C.Font = GetFontSizeIndex(C, -2);

	if ( PortraitPRI != None )
	{
		PortraitString = PortraitPRI.PlayerName;
		C.StrLen(PortraitString, XL, YL);

		if ( XL > PortraitWidth )
		{
			C.Font = GetFontSizeIndex(C, -4);
			C.StrLen(PortraitString, XL, YL);

			if ( XL > PortraitWidth )
			{
				Abbrev = float(len(PortraitString)) * PortraitWidth / XL;
				PortraitString = left(PortraitString, Abbrev);
				C.StrLen(PortraitString, XL, YL);
			}
		}
	}
	else if ( Portrait == TraderPortrait )
	{
		PortraitString = TraderString;
		C.StrLen(PortraitString, XL, YL);
	}

	C.DrawColor = C.static.MakeColor(160, 160, 160);
	C.SetPos(-PortraitWidth * PortraitX + 0.025 * PortraitWidth, 0.5 * (C.ClipY - PortraitHeight) + 0.025 * PortraitHeight);
	C.DrawTile( Material'kf_fx_trip_t.Misc.KFModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

	C.DrawColor = WhiteColor;
	C.SetPos(-PortraitWidth * PortraitX, 0.5 * (C.ClipY - PortraitHeight));
	C.DrawTileStretched(texture'InterfaceContent.Menu.BorderBoxA1', 1.05 * PortraitWidth, 1.05 * PortraitHeight);

	C.DrawColor = WhiteColor;
	C.SetPos(C.ClipY / 256 - PortraitWidth * PortraitX + 0.5 * (PortraitWidth - XL), 0.5 * (C.ClipY + PortraitHeight) + 0.06 * PortraitHeight);

	if ( PortraitPRI != None )
	{
		if ( PortraitPRI.Team != None )
		{
			if ( PortraitPRI.Team.TeamIndex == 0 )
				C.DrawColor = RedColor;
			else C.DrawColor = TurqColor;
		}
	}
	else if ( Portrait == TraderPortrait )
	{
		C.DrawColor = RedColor;
	}

	if ( PortraitString != "" )
	{
		C.DrawText(PortraitString,true);
	}
}

// Comment Out for Release
simulated function DrawCrosshair (Canvas C)
{
	local float NormalScale;
	local int i, CurrentCrosshair;
	local float OldScale,OldW, CurrentCrosshairScale;
	local color CurrentCrosshairColor;
	local SpriteWidget CHtexture;

	if (!bCrosshairShow || !class'ROEngine.ROLevelInfo'.static.RODebugMode() || !bShowKFDebugXHair)
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
	CHTexture.TextureScale = NormalScale;

	//DrawEnemyName(C);
}

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
	Y = (0.5 * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);

	Y -= FontDY * (float (LineCount) / 2.0);

	X += KFPlayerController(PlayerOwner).RandXOffset;
	Y += KFPlayerController(PlayerOwner).RandYOffset;

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

function bool DrawLevelAction (Canvas C)
{
	local String LevelActionText;
	local Plane OldModulate;

	if ( Level.LevelAction == LEVACT_None && Level.Pauser != none )
	{
		LevelActionText = LevelActionPaused;
	}
	else if ( Level.LevelAction == LEVACT_Loading || Level.LevelAction == LEVACT_Precaching )
	{
		LevelActionText = LevelActionLoading;
	}
	else
	{
		LevelActionText = "";
	}

	if ( LevelActionText == "" )
	{
		return false;
	}

	C.Font = LoadLevelActionFont();
	C.DrawColor = LevelActionFontColor;
	C.Style = ERenderStyle.STY_Alpha;

	OldModulate = C.ColorModulate;
	C.ColorModulate = C.default.ColorModulate;
	C.DrawScreenText(LevelActionText, LevelActionPositionX, LevelActionPositionY, DP_MiddleMiddle);
	C.ColorModulate = OldModulate;

	return true;
}

function DisplayPortrait(PlayerReplicationInfo PRI)
{
	local Material NewPortrait;

	if ( LastPlayerIDTalking > 0 )
	{
		return;
	}

	NewPortrait = PRI.GetPortrait();

	if ( NewPortrait == None )
	{
		return;
	}

	if ( Portrait == None )
	{
		PortraitX = 1;
	}

	Portrait = NewPortrait;
	PortraitTime = Level.TimeSeconds + 3;
	PortraitPRI = PRI;
}

function DisplayTraderPortrait()
{
	if ( Portrait == None )
	{
		PortraitX = 1;
	}

	Portrait = TraderPortrait;
	PortraitTime = Level.TimeSeconds + 5;
	PortraitPRI = none;
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	local Class<LocalMessage> LocalMessageClass;

	if ( PRI != None && MsgType == 'Say' || MsgType == 'TeamSay' )
	{
		DisplayPortrait(PRI);
	}

	switch( MsgType )
	{
		case 'Trader':
			Msg = TraderString$":" @ Msg;
			LocalMessageClass = class'SayMessagePlus';
			break;
		case 'Voice':
		case 'Say':
			if ( PRI == None )
			{
				return;
			}

			Msg = PRI.PlayerName $ ":" @ Msg;
			LocalMessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			if ( PRI == None )
			{
				return;
			}

			Msg = PRI.PlayerName $ "(" $ PRI.GetLocationName() $ "):" @ Msg;
			LocalMessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			LocalMessageClass = class'KFCriticalEventPlus';
			LocalizedMessage(LocalMessageClass, 0, None, None, None, Msg);
			return;
		case 'DeathMessage':
			LocalMessageClass = class'xDeathMessage';
			break;
		default:
			LocalMessageClass = class'StringMessagePlus';
			break;
	}
	AddTextMessage(Msg, LocalMessageClass, PRI);
}

simulated function LayoutMessage( out HudLocalizedMessage Message, Canvas C )
{
	local int FontSize;

	Message.StringMessage = class'KFGameType'.static.ParseLoadingHintNoColor(Message.StringMessage, PlayerOwner);

	FontSize = Message.Message.static.GetFontSize(Message.Switch, Message.RelatedPRI, Message.RelatedPRI2, PlayerOwner.PlayerReplicationInfo);

	if ( Message.Message == class'WaitingMessage' && (Message.Switch <= 3 || Message.Switch == 5) )
	{
		Message.StringFont = GetWaitingFontSizeIndex(C, FontSize);
	}
	else
	{
		Message.StringFont = GetFontSizeIndex(C, FontSize);
	}

	Message.DrawColor = Message.Message.static.GetColor( Message.Switch, Message.RelatedPRI, Message.RelatedPRI2 );
	Message.Message.static.GetPos( Message.Switch, Message.DrawPivot, Message.StackMode, Message.PosX, Message.PosY );
	C.Font = Message.StringFont;
	C.TextSize( Message.StringMessage, Message.DX, Message.DY );
}

function Font GetWaitingFontSizeIndex(Canvas C, int FontSize)
{
	if ( C.ClipX <= 1024 )
		return LoadWaitingFont(1);

	return LoadWaitingFont(0);
}

simulated function Font LoadWaitingFont(int i)
{
	if( WaitingFontArrayFonts[i] == none )
	{
		WaitingFontArrayFonts[i] = Font(DynamicLoadObject(WaitingFontArrayNames[i], class'Font'));
		if( WaitingFontArrayFonts[i] == none )
			Log("Warning: "$Self$" Couldn't dynamically load font "$WaitingFontArrayNames[i]);
	}

	return WaitingFontArrayFonts[i];
}

simulated function font LoadLevelActionFont()
{
	if ( LevelActionFontFont == none )
	{
		LevelActionFontFont = Font(DynamicLoadObject(LevelActionFontName, class'Font'));
		if ( LevelActionFontFont == None )
		{
			Log("Warning: "$Self$" Couldn't dynamically load font "$LevelActionFontName);
		}
	}

	return LevelActionFontFont;
}

// Draw Health Bars for damage opened doors.
function DrawDoorHealthBars(Canvas C)
{
	local KFDoorMover DamageDoor;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local name DoorTag;
	local int i;


	if ( Level.TimeSeconds > LastDoorBarHealthUpdate + 0.2 ||
        (PlayerOwner.Pawn.Weapon != none && PlayerOwner.Pawn.Weapon.class == class'Welder' && PlayerOwner.bFire == 1) )
	{
		DoorCache.Remove(0, DoorCache.Length);

		foreach VisibleCollidingActors(class'KFDoorMover', DamageDoor, 300.00, PlayerOwner.Pawn.Location)
		{
			if ( DamageDoor.WeldStrength > 0 )
			{
				DoorCache.Insert(0, 1);
				DoorCache[0] = DamageDoor;

				C.GetCameraLocation(CameraLocation, CameraRotation);
				TargetLocation = DamageDoor.WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
				TargetLocation.Z = CameraLocation.Z;
				CamDir	= vector(CameraRotation);

				if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DamageDoor.Tag != DoorTag && FastTrace(DamageDoor.WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
				{
					HBScreenPos = C.WorldToScreen(TargetLocation);
					DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DamageDoor.WeldStrength / DamageDoor.MaxWeld, 255);
					DoorTag = DamageDoor.Tag;
				}
			}
		}

		LastDoorBarHealthUpdate = Level.TimeSeconds;
	}
	else
	{
		for ( i = 0; i < DoorCache.Length; i++ )
		{
	 		C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation = DoorCache[i].WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z = CameraLocation.Z;
			CamDir	= vector(CameraRotation);

			if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DoorCache[i].Tag != DoorTag && FastTrace(DoorCache[i].WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
			{
				HBScreenPos = C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DoorCache[i].WeldStrength / DoorCache[i].MaxWeld, 255);
				DoorTag = DoorCache[i].Tag;
			}
		}
	}
}

function DrawDoorBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha)
{
	local float TextWidth, TextHeight;
	local string IntegrityText;

	IntegrityText = int(BarPercentage * 100) $ "%";

	if ( !bLightHud )
	{
		C.SetDrawColor(255, 255, 255, 112);
		C.Style = ERenderStyle.STY_Alpha;
		C.SetPos(XCentre - ((DoorWelderBG.USize * 1.18) / 2) , YCentre - ((DoorWelderBG.VSize * 0.9) / 2));
		C.DrawTileScaled(DoorWelderBG, 1.18, 0.9);
	}

	C.SetDrawColor(255, 50, 50, 255);

	C.Font = LoadSmallFontStatic(4);
	C.StrLen(IntegrityText, TextWidth, TextHeight);
	C.SetDrawColor(255, 50, 50, 255);
	C.SetPos(XCentre + 5 , YCentre - (TextHeight / 2.4));
	C.DrawTextClipped(IntegrityText);

	C.SetPos((XCentre - 5) - 64, YCentre - 24);
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawTile(DoorWelderIcon, 64, 48, 0, 0, 256, 192);
}

simulated function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	// What type of damage are we sustaining?
	HUDHitDamage = damageType;

	if( DamageTime[0] > 0 )
	{
		DamageIsUber = true;
	}
	else
	{
		DamageIsUber = false;
	}

	if( class<DamTypeZombieAttack>(HUDHitDamage) != none )
	{
		DamageStartTime = class<DamTypeZombieAttack>(HUDHitDamage).default.HUDTime;
		if ( HUDHitDamage==Class'DamTypeVomit' )
		{
			VomitHudTimer = Level.TimeSeconds + 0.8;
		}
	}
	else
	{
		DamageStartTime = Clamp(float(Damage) / 5.f, 0.2, 1.5);
	}

	DamageHUDTimer = Level.TimeSeconds + DamageStartTime;
}

simulated function DrawDamageIndicators(Canvas C)
{
	local class<DamTypeZombieAttack> ZHUDDam;
	local float DltA;

	// let's mod this to account for other types of damage effects.
	// - ALEX
	if ( DamageHUDTimer>Level.TimeSeconds )
	{
		C.SetPos(0, 0);
		DltA = DamageHUDTimer - Level.TimeSeconds;
		C.SetDrawColor(255, 255, 255, clamp((DltA / DamageStartTime * 200.f), 0, 200));

		ZHUDDam = class<DamTypeZombieAttack>(HUDHitDamage);

		if ( ZHUDDam == none )
		{
			C.DrawTile( FinalBlend'KillingfloorHUD.GoreSplashFB', C.SizeX, C.SizeY, 0.0, 0.0, 512, 512);
		}
		else
		{
			if ( DamageIsUber )
			{
				C.DrawTile( ZHUDDam.default.HUDUberDamageTex, C.SizeX, C.SizeY, 0.0, 0.0, ZHUDDam.default.HUDUberDamageTex.MaterialUSize(), ZHUDDam.default.HUDUberDamageTex.MaterialVSize());
			}
			else
			{
				C.DrawTile( ZHUDDam.default.HUDDamageTex, C.SizeX, C.SizeY, 0.0, 0.0, ZHUDDam.default.HUDDamageTex.MaterialUSize(), ZHUDDam.default.HUDDamageTex.MaterialVSize());
			}
		}
	}
}

simulated function DrawSpectatingHud(Canvas C)
{
	local rotator CamRot;
	local vector CamPos, ViewDir;
	local int i;

	DrawModOverlay(C);

	if( bHideHud )
	{
		return;
	}

	PlayerOwner.PostFX_SetActive(0, false);

	// Grab our View Direction
	C.GetCameraLocation(CamPos, CamRot);
	ViewDir = vector(CamRot);

	// Draw the Name, Health, Armor, and Veterancy above other players
	for ( i = 0; i < PlayerInfoPawns.Length; i++ )
	{
		if ( PlayerInfoPawns[i].Pawn != None && PlayerInfoPawns[i].Pawn.Health > 0 && (PlayerInfoPawns[i].Pawn.Location - CamPos) dot ViewDir > 0.6 &&
			 PlayerInfoPawns[i].RendTime > Level.TimeSeconds )
		{
			DrawPlayerInfo(C, PlayerInfoPawns[i].Pawn, PlayerInfoPawns[i].PlayerInfoScreenPosX, PlayerInfoPawns[i].PlayerInfoScreenPosY);
		}
		else
		{
			PlayerInfoPawns.Remove(i--, 1);
		}
	}

	super.DrawSpectatingHud(C);

	DrawFadeEffect(C);

	if ( KFPlayerController(PlayerOwner) != None && KFPlayerController(PlayerOwner).ActiveNote != None )
	{
		KFPlayerController(PlayerOwner).ActiveNote = None;
	}

	if( KFGameReplicationInfo(Level.GRI) != none && KFGameReplicationInfo(Level.GRI).EndGameType > 0 )
	{
		if( KFGameReplicationInfo(Level.GRI).EndGameType == 2 )
		{
			DrawEndGameHUD(C, True);
			Return;
		}
		else
		{
			DrawEndGameHUD(C, False);
		}
	}

	DrawKFHUDTextElements(C);
	DisplayLocalMessages(C);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}

	// portrait
	if ( bShowPortrait && Portrait != None )
	{
		DrawPortrait(C);
	}

	// Draw hints
	if ( bDrawHint )
	{
		DrawHint(C);
	}
}

simulated function DrawWeaponName(Canvas C)
{
	local string CurWeaponName;
	local float XL,YL;

	if (  PawnOwner == None || PawnOwner.Weapon == None )
	{
		return;
	}

	CurWeaponName = PawnOwner.Weapon.GetHumanReadableName();
	C.Font  = GetFontSizeIndex(C, -1);
	C.SetDrawColor(255, 50, 50, KFHUDAlpha);
	C.Strlen(CurWeaponName, XL, YL);

	// Diet Hud needs to move the weapon name a little bit or it looks weird
	if ( !bLightHud )
	{
		C.SetPos((C.ClipX * 0.983) - XL, C.ClipY * 0.90);
	}
	else
	{
		C.SetPos((C.ClipX * 0.97) - XL, C.ClipY * 0.915);
	}

	C.DrawText(CurWeaponName);
}

/* Called when viewing a Matinee cinematic */
simulated function DrawCinematicHUD( Canvas C )
{
	IntroTitleFade += Global_Delta * 2;

	if ( IntroTitleFade < 10 && KFPRI != None )
	{
		Subtitle =  KFPRI.Subtitle[SubIndex];
		DrawSubtitle(C, Subtitle);

		// The Subtitle List has been played through
		// Reset for next cam.
		if ( SubIndex > 4 )
		{
			Subtitle = "";
			SubIndex = 0;
		}
	}

	super.DrawCinematicHUD(C);

	// Film Grain Overlay
	if ( !Level.IsSoftwareRendering() && Level.DetailMode > DM_LOW && KFPRI != None && KFPRI.bWideScreenOverlay )
	{
		C.SetPos(0, 0);
		C.Style = ERenderStyle.STY_Modulated;
		C.DrawColor.A = 255;
		C.DrawTileScaled(Material 'KillingFloorHUD.ClassMenu.CinematicOverlay', C.ClipX / 1024, C.ClipY / 1024);
	}
}

simulated function DrawSubtitle( Canvas C , string Text )
{
	local int	   FontIndex;
	local String	LevelTitle;
	local float	 XL, YL;
	local float  SubYLoc;

	C.DrawColor = WhiteColor;
	C.Style	 = ERenderStyle.STY_Alpha;
	FontIndex   = 8;
	LevelTitle  = Text;

	do  // make sure name is not too big
	{
		C.Font = GetFontSizeIndex(C, FontIndex--);
		C.TextSize( LevelTitle, XL, YL );
	} until ( XL < C.ClipX * 0.67 && YL < C.ClipY * 0.67 )

	if ( IntroTitleFade < 1 )								   // Hidden
	{
		C.DrawColor.A = 0;
	}
	else if ( IntroTitleFade < 3 )							  // fade in
	{
		C.DrawColor.A = 255 * ((IntroTitleFade - 1) * 0.5);
	}
	else if ( IntroTitleFade > 6 )							  // fade out
	{
		C.DrawColor.A = 255 * (1.f - ((IntroTitleFade - 6) / 4));
	}
	else
	{
		C.DrawColor.A = 255;									// normal
	}

	// Adjust the Y Location of the Subtitle based on whether the Widescreen is on, or not.
	if ( KFPRI != None && KFPRI.bWideScreenOverlay )
	{
		SubYLoc = 0.75;
	}
	else
	{
		SubYLoc = 1.0;
	}

	C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * SubYLoc);
	C.DrawText(LevelTitle, false);

	if ( IntroTitleFade >= 9.9 )
	{
		if ( SubIndex < 5 && Level.TimeSeconds - LastSubChangeTime > 1.0 )
		{
			SubIndex ++;
			bGetNewSub = false;
			LastSubChangeTime = Level.TimeSeconds;
		}

		IntroTitleFade = 0;
	}
}

simulated function string Strl(int Value)
{
	local int Hours, Minutes, Seconds;

	Seconds = Abs(Value);
	Minutes = Seconds / 60;
	Hours   = Minutes / 60;
	Seconds = Seconds - (Minutes * 60);
	Minutes = Minutes - (Hours * 60);
	return Hours $ ":" $ Eval(Minutes < 10, "0" $ Minutes, string(Minutes)) $ ":" $ Eval(Seconds < 10,"0" $ Seconds, string(Seconds));
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	local float Scalar;

	C.DrawColor.A = 255;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	Scalar = FClamp(C.ClipY, 320, 1024);
	C.CurX = C.ClipX / 2 - Scalar / 2;
	C.CurY = C.ClipY / 2 - Scalar / 2;
	C.Style = ERenderStyle.STY_Alpha;

	if ( bVictory )
	{
		MyColorMod.Material = Combiner'VictoryCombiner';
	}
	else
	{
		MyColorMod.Material = Combiner'DefeatCombiner';
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

function DrawInventory(Canvas C)
{
	local Inventory CurInv;
	local InventoryCategory Categorized[5];
	local int i, j;
	local float TempX, TempY, TempWidth, TempHeight, TempBorder;

	if( PawnOwner == none )
	{
		return;
	}

	if ( bInventoryFadingIn )
	{
		if ( Level.TimeSeconds < InventoryFadeStartTime + InventoryFadeTime )
		{
			C.SetDrawColor(255, 255, 255, byte(((Level.TimeSeconds - InventoryFadeStartTime) / InventoryFadeTime) * 255.0));
		}
		else
		{
			bInventoryFadingIn = false;
			C.SetDrawColor(255, 255, 255, 255);
		}
	}
	else if ( bInventoryFadingOut )
	{
		if ( Level.TimeSeconds < InventoryFadeStartTime + InventoryFadeTime )
		{
			C.SetDrawColor(255, 255, 255, byte((1.0 - ((Level.TimeSeconds - InventoryFadeStartTime) / InventoryFadeTime)) * 255.0));
		}
		else
		{
			bInventoryFadingOut = false;
			return;
		}
	}
	else
	{
		C.SetDrawColor(255, 255, 255, 255);
	}

	for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		// Don't allow non-categorized or Grenades
		if ( CurInv.InventoryGroup > 0 )
		{
			Categorized[CurInv.InventoryGroup - 1].Items[Categorized[CurInv.InventoryGroup - 1].ItemCount++] = CurInv;
		}
	}

	TempX = InventoryX * C.ClipX;
	TempWidth = InventoryBoxWidth * C.ClipX;
	TempHeight = InventoryBoxHeight * C.ClipX;
	TempBorder = BorderSize * C.ClipX;

	for ( i = 0; i < 5; i++ )
	{
		if ( Categorized[i].ItemCount == 0 )
		{
			C.SetPos(TempX, InventoryY * C.ClipY);
			C.DrawTileStretched(InventoryBackgroundTexture, TempWidth, TempHeight * 0.25);
		}
		else
		{
			TempY = InventoryY * C.ClipY;

			for ( j = 0; j < Categorized[i].ItemCount; j++ )
			{
				// If this is the currently Selected Item
				if ( i == SelectedInventoryCategory && j == SelectedInventoryIndex )
				{
					// Draw this item's Background
					C.SetPos(TempX, TempY);
					C.DrawTileStretched(SelectedInventoryBackgroundTexture, TempWidth, TempHeight);

					// Draw the Weapon's Icon over the Background
					C.SetPos(TempX + TempBorder, TempY + TempBorder);
					C.DrawTile(KFWeapon(Categorized[i].Items[j]).SelectedHudImage, TempWidth - (2.0 * TempBorder), TempHeight - (2.0 * TempBorder), 0, 0, 256, 192);
				}
				else
				{
					// Draw this item's Background
					C.SetPos(TempX, TempY);
					C.DrawTileStretched(InventoryBackgroundTexture, TempWidth, TempHeight);

					// Draw the Weapon's Icon over the Background
					C.SetPos(TempX + TempBorder, TempY + TempBorder);
					C.DrawTile(KFWeapon(Categorized[i].Items[j]).HudImage, TempWidth - (2.0 * TempBorder), TempHeight - (2.0 * TempBorder), 0, 0, 256, 192);
				}

				TempY += TempHeight;
			}
		}

		TempX += TempWidth;
	}
}

function bool ShowInventory()
{
	if ( !bDisplayInventory )
	{
		bDisplayInventory = true;
		bInventoryFadingIn = true;
		bInventoryFadingOut = false;
		InventoryFadeStartTime = Level.TimeSeconds - 0.01;

		if ( PawnOwner != none && PawnOwner.Weapon != none )
		{
			SelectedInventory = PawnOwner.Weapon;
		}
		else if ( PawnOwner != none && PawnOwner.Inventory != none )
		{
			SelectedInventory = PawnOwner.Inventory;
		}
		else
		{
			return false;
		}
	}

	return true;
}

function PrevWeapon()
{
	local Inventory CurInv;
	local InventoryCategory Categorized[5];
	local int i, j;

	if ( PawnOwner != none && PawnOwner.Inventory != none && ShowInventory() )
	{
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			// Don't allow non-categorized or Grenades
			if ( CurInv.InventoryGroup > 0 )
			{
				if ( CurInv == SelectedInventory )
				{
					SelectedInventoryCategory = CurInv.InventoryGroup - 1;
					SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount;
				}

				Categorized[CurInv.InventoryGroup - 1].Items[Categorized[CurInv.InventoryGroup - 1].ItemCount++] = CurInv;
			}
		}

		if ( SelectedInventoryIndex >= Categorized[SelectedInventoryCategory].ItemCount )
		{
			SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
		}

		if ( SelectedInventoryIndex > 0 )
		{
			SelectedInventoryIndex--;
			SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
		}
		else
		{
			for ( i = SelectedInventoryCategory - 1; i != SelectedInventoryCategory && j < 10; i-- )
			{
				if ( i < 0 )
				{
					i = 4;
				}

				if ( Categorized[i].ItemCount > 0 )
				{
					SelectedInventoryCategory = i;
					SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
					SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
					return;
				}

				j++;
			}

			// if we only have one category with items in it, this will move to the last(or lowest) item in this category
			SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
		}
	}
}

function NextWeapon()
{
	local Inventory CurInv;
	local InventoryCategory Categorized[5];
	local int i, j;

	if ( PawnOwner!= none && PawnOwner.Inventory != none && ShowInventory() )
	{
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			// Don't allow non-categorized or Grenades
			if ( CurInv.InventoryGroup > 0 )
			{
				if ( CurInv == SelectedInventory )
				{
					SelectedInventoryCategory = CurInv.InventoryGroup - 1;
					SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount;
				}

				Categorized[CurInv.InventoryGroup - 1].Items[Categorized[CurInv.InventoryGroup - 1].ItemCount++] = CurInv;
			}
		}

		if ( SelectedInventoryIndex >= Categorized[SelectedInventoryCategory].ItemCount )
		{
			SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
		}

		if ( SelectedInventoryIndex < Categorized[SelectedInventoryCategory].ItemCount - 1 )
		{
			SelectedInventoryIndex++;
			SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
		}
		else
		{
			for ( i = SelectedInventoryCategory + 1; i != SelectedInventoryCategory && j < 10; i++ )
			{
				if ( i > 4 )
				{
					i = 0;
				}

				if ( Categorized[i].ItemCount > 0 )
				{
					SelectedInventoryCategory = i;
					SelectedInventoryIndex = 0;
					SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
					return;
				}

				j++;
			}

			// if we only have one category with items in it, this will move to the first(or highest) item in this category
			SelectedInventoryIndex = 0;
		}
	}
}

/* Lol, why is the HUD initating weapon changes for the player?  o_ 0*/
function SelectWeapon()
{
	local Inventory I;
	local bool bFoundItem,bAllowSelect;
	local KFHumanPawn KFHP;

	HideInventory();

	if( PawnOwner == none)
	{
		return;
	}

    KFHP = KFHumanPawn(PawnOwner);

	for ( I = PawnOwner.Inventory; I != none; I = I.Inventory )
	{
		if ( I == SelectedInventory )
		{
			bFoundItem = true;
		}
	}

	if ( !bFoundItem )
	{
		return;
	}

    bAllowSelect = KFHP.AllowHoldWeapon(KFWeapon(SelectedInventory));
//    log("Allow Select : "@SelectedInventory@"?"@bAllowSelect);
    if(!bAllowSelect)
    {
//        log("you cannnot select : "@SelectedInventory);
        return;
    }

	PawnOwner.PendingWeapon = Weapon(SelectedInventory);

	if ( PawnOwner.Weapon != none )
	{
		if ( PawnOwner.Weapon != PawnOwner.PendingWeapon )
		{
			PawnOwner.Weapon.PutDown();
		}
	}
	else
	{
		PawnOwner.ChangedWeapon();
	}
}

function HideInventory()
{
	bDisplayInventory = false;
	bInventoryFadingIn = false;
	bInventoryFadingOut = true;
	InventoryFadeStartTime = Level.TimeSeconds - 0.01;
}

function DrawPopupNotification(Canvas C)
{
	local float TimeElapsed;
	local float	DrawHeight;
	local array<string> WrappedArray;
	local float IconSize, TempX, TempY, TempWidth, TempHeight;
	local int i;

	TimeElapsed = Level.TimeSeconds - NotificationPhaseStartTime;

	if ( NotificationPhase == 0 ) // Showing Phase
	{
		if ( TimeElapsed < NotificationShowTime )
		{
			DrawHeight = (TimeElapsed / NotificationShowTime) * NotificationHeight;
		}
		else
		{
			NotificationPhase = 1; // Delaying Phase
			NotificationPhaseStartTime = Level.TimeSeconds - (TimeElapsed - NotificationShowTime);
			DrawHeight = NotificationHeight;
		}
	}
	else if ( NotificationPhase == 1 )
	{
		if ( TimeElapsed < NotificationHideDelay )
		{
			DrawHeight = NotificationHeight;
		}
		else
		{
			NotificationPhase = 3; // Hiding Phase
			TimeElapsed -= NotificationHideDelay;
			NotificationPhaseStartTime = Level.TimeSeconds - TimeElapsed;
			DrawHeight = (TimeElapsed / NotificationHideTime) * NotificationHeight;
		}
	}
	else
	{
		if ( TimeElapsed < NotificationHideTime )
		{
			DrawHeight = (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
		}
		else
		{
			// We're done
			bShowNotification = false;
			return;
		}
	}

	// Initialize the Canvas
	C.Style = 1;
	C.Font = class'ROHUD'.Static.LoadMenuFontStatic(NotificationFontSize);
	C.SetDrawColor(255, 255, 255, 255);

	// Calc Notification's Screen Offset
	TempX = (C.ClipX / 2.0) - (NotificationWidth / 2.0);
	TempY = C.ClipY - DrawHeight;

	// Draw the Background
	C.SetPos(TempX, TempY);
	C.DrawTileStretched(NotificationBackground, NotificationWidth, NotificationHeight);

	// Offset for Border and Calc Icon Size
	TempX += NotificationBorderSize;
	TempY += NotificationBorderSize;

	// Draw Icon if set
	if ( NotificationIcon != none )
	{
		IconSize = NotificationHeight - (NotificationBorderSize * 2.0);
		C.SetPos(TempX, TempY);
		C.DrawTile(NotificationIcon, IconSize, IconSize, 0, 0, NotificationIcon.USize, NotificationIcon.VSize);

		// Offset for desired Spacing between Icon and Text
		TempX += IconSize + NotificationIconSpacing;

		// Break up Notification String into lines
		C.WrapStringToArray(NotificationString, WrappedArray, NotificationWidth - IconSize - NotificationBorderSize * 2.0 - NotificationIconSpacing, "|");
	}
	else
	{
		// break up Notification String into lines
		C.WrapStringToArray(NotificationString, WrappedArray, NotificationWidth - NotificationBorderSize * 2.0, "|");
	}

	// Draw the Notification String line by line
	for ( i = 0; i < WrappedArray.Length && (i * (TempHeight * 0.8)) < NotificationHeight; i++ )
	{
		C.SetPos(TempX, TempY);
		C.DrawText(WrappedArray[i]);

		// Set up next line
		C.StrLen(WrappedArray[i], TempWidth, TempHeight);
		TempY += (TempHeight * 0.8);
	}
}

function ShowPopupNotification(float DisplayTime, int FontSize, string Text, optional texture Icon)
{
	bShowNotification = true;

	// Store the Info
	NotificationHideDelay = DisplayTime;
	NotificationFontSize = FontSize;
	NotificationString = Text;
	NotificationIcon = Icon;

	// Start in the Showing Phase
	NotificationPhase = 0;
	NotificationPhaseStartTime = Level.TimeSeconds;
}

simulated function ShowHint(string title, string text)
{
	bFirstHintRender = true;
	HintWrappedText.Length = 0;
	HintRemainingTime = HintLifetime + HintFadeTime * 2;
	HintTitle = title;

	// Parse keybinds
	if (PlayerOwner != none)
		HintText = class'KFGameType'.static.ParseLoadingHintNoColor(text, PlayerOwner);
	else
		HintText = text;
	bDrawHint = true;
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
		if (KFPlayerController(PlayerOwner) != none)
			KFPlayerController(PlayerOwner).NotifyHintRenderingDone();
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
	if( default.SmallFontArrayFonts[i] == none )
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
	if( default.MenuFontArrayFonts[i] == none )
	{
		default.MenuFontArrayFonts[i] = Font(DynamicLoadObject(default.MenuFontArrayNames[i], class'Font'));
		if( default.MenuFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.MenuFontArrayNames[i]);
	}

	return default.MenuFontArrayFonts[i];
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
	/*
	if (bDebugDrawHudBounds)
	{
		C.SetPos(ScreenX + C.OrgX, ScreenY + C.OrgY);
		C.DrawColor = RedColor;
		c.DrawTileStretched(Material'InterfaceArt_tex.HUD.white_border_alpha', ScreenXL, ScreenYL);
		C.DrawColor = widget.Tints[TeamIndex];
	}
	*/

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

simulated function DrawPointSphere()
{
	local coords CO;
	local KFPawn P;
	local vector HeadLoc;
	local int i;

	foreach DynamicActors(class'KFPawn', P)
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
//					if( i == MAINCOLLISIONINDEX )
//					{
//						DrawDebugCylinder(HeadLoc,CO.XAxis,CO.YAxis,CO.ZAxis,P.Hitpoints[i].PointRadius * P.Hitpoints[i].PointScale,P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale,10,0, 255, 0);
//					}
//					else
//					{
						DrawDebugCylinder(HeadLoc,CO.ZAxis,CO.YAxis,CO.XAxis,P.Hitpoints[i].PointRadius * P.Hitpoints[i].PointScale,P.Hitpoints[i].PointHeight * P.Hitpoints[i].PointScale,10,0, 255, 0);
//					}
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

function UpdateKillMessage(Object OptionalObject,PlayerReplicationInfo RelatedPRI_1)
{
    local int i;

	for( i=0; i< arraycount(LocalMessages); ++i )
	{
		if( LocalMessages[i].Message== class 'KillsMessage' &&
        LocalMessages[i].OptionalObject==OptionalObject &&
        LocalMessages[i].RelatedPRI==RelatedPRI_1 )
		{
			++LocalMessages[i].Switch;
			LocalMessages[i].DrawColor = class'KillsMessage'.static.GetColor(LocalMessages[i].Switch);
			LocalMessages[i].LifeTime = class 'KillsMessage'.Default.MessageShowTime;
			LocalMessages[i].EndOfLife = class 'KillsMessage'.Default.MessageShowTime + Level.TimeSeconds;
			LocalMessages[i].StringMessage = class 'KillsMessage'.static.GetString(LocalMessages[i].Switch,RelatedPRI_1,,OptionalObject);
			return;
		}
	}
}

defaultproperties
{
     KFHUDAlpha=200
     GrainAlpha=200
     HealthBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.015000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
     HealthIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Medical_Cross',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.160000,PosX=0.021000,PosY=0.947000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.042500,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     ArmorBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.085000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=128),Tints[1]=(B=255,G=255,R=255,A=128))
     ArmorIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Shield',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.090000,PosY=0.945000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ArmorDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.115000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     WeightBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=64),TextureScale=0.350000,PosX=0.155000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeightIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Weight',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.280000,PosX=0.160000,PosY=0.941000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeightDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.195000,PosY=0.946000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     GrenadeBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.915000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     GrenadeIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Grenade',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.930000,PosY=0.945000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     GrenadeDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.960000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     ClipsBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.845000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ClipsIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Ammo_Clip',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ClipsDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.880000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     SecondaryClipsBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.705000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SecondaryClipsIcon=(WidgetTexture=Texture'KillingFloor2HUD.HUD.Hud_M79',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.704000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SecondaryClipsDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.731000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     BulletsInClipBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.775000,PosY=0.935000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BulletsInClipIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Bullets',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.781000,PosY=0.945000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BulletsInClipDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.807000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     M79Icon=(WidgetTexture=Texture'KillingFloor2HUD.HUD.Hud_M79',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     PipeBombIcon=(WidgetTexture=Texture'KillingFloor2HUD.HUD.Hud_Pipebomb',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.300000,PosX=0.850000,PosY=0.937700,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     LawRocketIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Law_Rocket',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ArrowheadIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Arrowhead',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SingleBulletIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlameIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flame',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.781000,PosY=0.945000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlameTankIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flame_Tank',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HuskAmmoIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flame',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.848000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SawAmmoIcon=(WidgetTexture=Texture'KillingFloor2HUD.HUD.Texture_Hud_Sawblade',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.853000,PosY=0.943000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ZEDAmmoIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Lightning_Bolt',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.781000,PosY=0.945000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlashlightBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.705000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlashlightIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flashlight',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.310000,PosX=0.704000,PosY=0.938000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlashlightOffIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flashlight_Off',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.310000,PosX=0.704000,PosY=0.938000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlashlightDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.731000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     WelderBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.845000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WelderIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Lightning_Bolt',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.850000,PosY=0.945000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WelderDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.875000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     SyringeBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.845000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SyringeIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Syringe',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.850000,PosY=0.945000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SyringeDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.875000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     MedicGunBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.705000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MedicGunIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Syringe',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.707500,PosY=0.945000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MedicGunDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.731000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     QuickSyringeDisplayTime=5.000000
     QuickSyringeFadeInTime=1.000000
     QuickSyringeFadeOutTime=0.500000
     QuickSyringeBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.470000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     QuickSyringeIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Syringe',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.475000,PosY=0.945000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     QuickSyringeDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.500000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     CashIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Pound_Symbol',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.300000,PosX=0.850000,PosY=0.860000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CashDigits=(RenderStyle=STY_Alpha,TextureScale=0.500000,PosX=0.882000,PosY=0.867000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     VetStarMaterial=Texture'KillingFloorHUD.HUD.Hud_Perk_Star'
     VetStarGoldMaterial=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold'
     VetStarSize=12.000000
     EnemyHealthBarLength=50.000000
     EnemyHealthBarHeight=6.000000
     HealthBarFullVisDist=700.000000
     HealthBarCutoffDist=2000.000000
     BarLength=60.000000
     BarHeight=10.000000
     ArmorIconSize=12.000000
     HealthIconSize=12.000000
     WhiteMaterial=Texture'KillingFloorHUD.HUD.WhiteTexture'
     DigitsSmall=(DigitTexture=Texture'KillingFloorHUD.Generic.HUD',TextureCoords[0]=(X1=8,Y1=6,X2=36,Y2=38),TextureCoords[1]=(X1=50,Y1=6,X2=68,Y2=38),TextureCoords[2]=(X1=83,Y1=6,X2=113,Y2=38),TextureCoords[3]=(X1=129,Y1=6,X2=157,Y2=38),TextureCoords[4]=(X1=169,Y1=6,X2=197,Y2=38),TextureCoords[5]=(X1=206,Y1=6,X2=235,Y2=38),TextureCoords[6]=(X1=241,Y1=6,X2=269,Y2=38),TextureCoords[7]=(X1=285,Y1=6,X2=315,Y2=38),TextureCoords[8]=(X1=318,Y1=6,X2=348,Y2=38),TextureCoords[9]=(X1=357,Y1=6,X2=388,Y2=38),TextureCoords[10]=(X1=390,Y1=6,X2=428,Y2=38))
     DigitsBig=(DigitTexture=Texture'KillingFloorHUD.Generic.HUD',TextureCoords[0]=(X1=8,Y1=6,X2=36,Y2=38),TextureCoords[1]=(X1=50,Y1=6,X2=68,Y2=38),TextureCoords[2]=(X1=83,Y1=6,X2=113,Y2=38),TextureCoords[3]=(X1=129,Y1=6,X2=157,Y2=38),TextureCoords[4]=(X1=169,Y1=6,X2=197,Y2=38),TextureCoords[5]=(X1=206,Y1=6,X2=235,Y2=38),TextureCoords[6]=(X1=241,Y1=6,X2=269,Y2=38),TextureCoords[7]=(X1=285,Y1=6,X2=315,Y2=38),TextureCoords[8]=(X1=318,Y1=6,X2=348,Y2=38),TextureCoords[9]=(X1=357,Y1=6,X2=388,Y2=38),TextureCoords[10]=(X1=390,Y1=6,X2=428,Y2=38))
     TraderPortrait=Texture'KFPortraits.Trader_portrait'
     VisionOverlay=Shader'KFX.SepiaShader'
     SpectatorOverlay=FinalBlend'InterfaceArt2_tex.filmgrain.FilmgrainOverlayFB'
     NearDeathOverlay=Shader'KFX.NearDeathShader'
     FireOverlay=Shader'KFX.BlazingShader'
     LevelActionFontColor=(B=255,G=255,R=255,A=255)
     LevelActionPositionX=0.500000
     LevelActionPositionY=0.250000
     VeterancyMatScaleFactor=1.500000
     OverlayFadeSpeed=0.024250
     WaveString="Wave"
     TraderString="Trader"
     WeldIntegrityString="Weld Integrity"
     DistanceUnitString="m"
     NeedleRotator=TexRotator'InterfaceArt_tex.HUD.Needle_rot'
     VoiceMeterBackground=Texture'InterfaceArt_tex.HUD.VUMeter'
     VoiceMeterX=0.640000
     VoiceMeterY=1.000000
     VoiceMeterSize=85.000000
     DoorWelderBG=Texture'KillingFloorHUD.HUD.Hud_Box_128x64'
     DoorWelderIcon=Texture'KillingFloorHUD.WeaponSelect.Welder'
     InventoryFadeTime=0.300000
     InventoryBackgroundTexture=Texture'KillingFloorHUD.HUD.Hud_Rectangel_W_Stroke'
     SelectedInventoryBackgroundTexture=Texture'KillingFloorHUD.HUD.Hud_Rectangel_selected'
     InventoryX=0.220000
     InventoryBoxWidth=0.100000
     InventoryBoxHeight=0.075000
     BorderSize=0.005000
     NotificationBackground=Texture'InterfaceArt_tex.Menu.DownTickBlurry'
     NotificationWidth=300.000000
     NotificationHeight=100.000000
     NotificationBorderSize=7.000000
     NotificationIconSpacing=10.000000
     NotificationShowTime=0.300000
     NotificationHideTime=0.500000
     NotificationHideDelay=5.000000
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
     WaitingFontArrayNames(0)="KFFonts.KFBase02DS36"
     WaitingFontArrayNames(1)="KFFonts.KFBase02DS24"
     HintFadeTime=0.500000
     HintLifetime=8.000000
     HintDesiredAspectRatio=10.000000
     HintBackground=(WidgetTexture=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosY=0.020000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=192),Tints[1]=(B=255,G=255,R=255,A=192))
     HintTitleWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,bDrawShadow=True,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HintTextWidget=(RenderStyle=STY_Alpha,WrapHeight=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HintCoords=(X=0.980000,Y=0.250000,XL=-1.000000)
     MessageHealthLimit=1000
     MessageMassLimit=5000
     FadeTime=-1.000000
     WhiteFlashTime=0.500000
     YouveWonTheMatch="Your squad survived!"
     YouveLostTheMatch="Squad eliminated."
     ConsoleColor=(B=220,G=220,R=255)
     ConsoleMessagePosX=0.105000
     ConsoleMessagePosY=0.920000
     FontArrayNames(0)="ROFontsTwo.ROArial24DS"
     FontArrayNames(1)="ROFontsTwo.ROArial24DS"
     FontArrayNames(2)="ROFontsTwo.ROArial22DS"
     FontArrayNames(3)="ROFontsTwo.ROArial18DS"
     FontArrayNames(4)="ROFontsTwo.ROArial18DS"
     FontArrayNames(5)="ROFontsTwo.ROArial14DS"
     FontArrayNames(6)="ROFontsTwo.ROArial12DS"
     FontArrayNames(7)="ROFontsTwo.ROArial9DS"
     FontArrayNames(8)="ROFontsTwo.ROArial7DS"
}
