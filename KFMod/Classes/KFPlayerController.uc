class KFPlayerController extends KFPC;

#exec OBJ LOAD FILE=KF_InterfaceSnd.uax

//const MAX_BUYITEMS=50;
const BUYLIST_CATS=7;
const LIBLIST_CATS=3;

//TODO: Kill these last remenants of the old buy system
var string BuyListHeaders[BUYLIST_CATS];
var string LibraryListHeaders[LIBLIST_CATS];

var bool bChoseStarting, bClassChosen;
var bool IsInLobby;
var int CashThrowAmount; // Amount of cash a player throws per keypress.   Set in the player settings menu

var KFMusicInteraction KFInterAct;
var string DelayedSongToPlay;
var bool bHasDelayedSong;

var KFSPNoteMessage ActiveNote;

var bool    bShopping;

var array<Actor> LightSources;

var	string	LobbyMenuClassString;
var	bool	bPendingLobbyDisplay;	// Set when we want to show the Lobby menu and then cleared once we show it
var bool 	bRequestedSteamData;	// Used to track if we've requested Steam Stats and Achievements from Steam while bPendingLobbyDisplay is true
var	int		ForceShowLobby;			// Counter to know how long we've waitied for Steam Stats and Achievements to return while bPendingLobbyDisplay is true

// Recoil
var		rotator		RecoilRotator;					// Stores recoil added to the free-aim buffer
var		float		LastRecoilTime;                 // Last time we got recoil
var		float		RecoilSpeed;					// The amount of time it will take to process this recoil

// Smooth FOV Management
var()   float       TargetFOV;                      // The FOV that the Camera is trying to acheive
var		float		TransitionStartFOV;             // The FOV that was being used at the start of the FOV Transition
var		float		TransitionTimeElapsed;          // How long (in seconds) the camera has been transitioning to TargetFOV
var		float		TransitionTimeTotal;            // How long it should take to transition to the target FOV

// Perks, Stats, and Achievements
var	config class<KFVeterancyTypes>	SelectedVeterancy;	// Current Desired Perk/Veterancy(during a wave, use KFPRI.ClientVeterancySkill as the Perk/Veterancy being used)
var	bool							bVomittedOn;
var	float							VomittedOnTime;
var	bool							bScreamedAt;
var	float							ScreamTime;

var	localized string	YouAreNowPerkString;			// You are now the selected Perk string
var	localized string	YouWillBecomePerkString;		// You will become the selected Perk at the end of this Wave string
var	localized string	PerkChangeOncePerWaveString;	// Only allowed to change Perk once per Wave string
var	localized string	PerkFirstLevelUnlockedString;	// First Perk has been unlocked string
var	localized string	PerkUnlockedString;				// New Perk has been unlocked string
var	localized string	LevelString;					// Localization string for "Level"

var()       float       TraderPathInterval;             // How ofter to draw the TraderPath when bShowTraderPath is true
var         bool        bShowTraderPath;                // Should show the trader path
var config  bool        bWantsTraderPath;               // Whether or not this player wants the trader paths at all

// For hint management
var     KFHintManager   HintManager;
var     config  bool    bShowHints;

// ZED time message
var     config	bool	bHadZED;

var KFSteamWebApi webAPIAccessor;

// Voice Messages
var	bool	bHasHeardTraderWelcomeMessage;
var	float	LastClotGrabMessageTime;
var	float	LastReloadMessageTime;
var	float	ReloadMessageDelay;
var	float	LastWeaponPulloutMessageTime;
var	float	WeaponPulloutMessageDelay;

//trader menu
var bool	bDoTraderUpdate;

var     config  bool    bUseTrueWideScreenFOV;          // When set to true, the game will use True widescreen with a wider fov when in widescreen mode. Otherwise, will do the default UE2.5 thing of chopping off the top and bottom (which gives better performance)

var	bool	bSpawnedThisWave;	// Whether or not this player has already spawned this wave

//Audio messages
var 	config	int		AudioMessageLevel;

//Temp Ammo needed for dualdeagle pickups
var		int				PendingAmmo;

// ZEDGun Support
var	vector					EnemyLocation[16];	// Location of all enemies within 100 meter radius(5000 unreal units)

var int						RandXOffset;
var int						RandYOffset;

var int                     BuyMenuFilterIndex;

replication
{
	reliable if(REMOTEROLE == ROLE_AUTONOMOUSPROXY)
		NetPlayMusic, NetStopMusic, ClientSwitchToBestMeleeWeapon, ShowLobbyMenu, DoTraderUpdate;

	reliable if( Role < ROLE_Authority )
		KFSwitchToBestWeapon, ServerSetGRIPendingBots, ServerSetTempBotName,
		ServerSetWantsTraderPath, GRIKillBotCall, SelectVeterancy, /*ServerGiveAll, ServerHackSlomo,*/
		ServerUnreadyPlayer;

	// Functions server can call.
	reliable if( Role == ROLE_Authority )
		KFClientNetWorkMsg, ClientLocationalVoiceMessage, ClientEnterZedTime, ClientExitZedTime,
		ClientWeaponSpawned, ClientWeaponDestroyed, ClientZedsSpawn, ClientForceCollectGarbage, EnemyLocation;
}

simulated event PreBeginPlay()
{
	class'BullpupFire'.static.PreloadAssets(Level);
	class'DeagleFire'.static.PreloadAssets(Level);
	class'DualDeagleFire'.static.PreloadAssets(Level);
	class'GoldenDualDeagleFire'.static.PreloadAssets(Level);
	class'DualiesFire'.static.PreloadAssets(Level);
	class'ShotgunFire'.static.PreloadAssets(Level);
	class'SingleFire'.static.PreloadAssets(Level);
	class'WinchesterFire'.static.PreloadAssets(Level);

	super.PreBeginPlay();
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

   // Spawn hint manager (if needed)
    UpdateHintManagement(bShowHints);
}

simulated function InitInputSystem()
{
	InputClass = class'KFMod.KFPlayerInput';

    Super.InitInputSystem();

    InitFOV();
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;
	local vector AttackLoc;

	super(Controller).NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

    // Don't need to do this if there wasn't actually any damage!!! - Ramm
    if( Damage <= 0 )
    {
        return;
    }

	DamageShake(Damage);
	iDam = Clamp(Damage,0,250);
	if ( InstigatedBy != None )
		AttackLoc = InstigatedBy.Location;

	NewClientPlayTakeHit(AttackLoc, hitLocation - Pawn.Location, iDam, damageType);
}

simulated function CheckZEDMessage()
{
	if ( !bHadZED )
	{
		ReceiveLocalizedMessage(class'KFMod.WaitingMessage', 5);
		bHadZED = true;
		SaveConfig();
	}
}


// Called by the server when the game enters zed time. Used to play the effects
simulated function ClientEnterZedTime()
{
    CheckZEDMessage();

    // if we have a weapon, play the zed time sound from it so it is higher priority and doesn't get cut off
    if( Pawn != none && Pawn.Weapon != none )
    {
        Pawn.Weapon.PlaySound(Sound'KF_PlayerGlobalSnd.Zedtime_Enter', SLOT_Talk, 2.0,false,500.0,1.1/Level.TimeDilation,false);
    }
    else
    {
        PlaySound(Sound'KF_PlayerGlobalSnd.Zedtime_Enter', SLOT_Talk, 2.0,false,500.0,1.1/Level.TimeDilation,false);
    }
}

// Called by the server when the game exits zed time. Used to play the effects
simulated function ClientExitZedTime()
{
    // if we have a weapon, play the zed time sound from it so it is higher priority and doesn't get cut off
    if( Pawn != none && Pawn.Weapon != none )
    {
        Pawn.Weapon.PlaySound(Sound'KF_PlayerGlobalSnd.Zedtime_Exit', SLOT_Talk, 2.0,false,500.0,1.1/Level.TimeDilation,false);
    }
    else
    {
        PlaySound(Sound'KF_PlayerGlobalSnd.Zedtime_Exit', SLOT_Talk, 2.0,false,500.0,1.1/Level.TimeDilation,false);
    }
}

simulated function DoTraderUpdate()
{
	bDoTraderUpdate = true;
}

exec function ShowKickMenu()
{
	if ( Level.NetMode != NM_StandAlone && VoteReplicationInfo != none && VoteReplicationInfo.KickVoteEnabled() )
	{
		Player.GUIController.OpenMenu(Player.GUIController.GetPropertyText("KickVotingMenu"));
	}
}

exec function SpawnTargets()
{
	local KFHumanPawn p;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	p = Spawn( class 'KFHumanPawn',,,Pawn.Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );

	p.LoopAnim('Idle_Bullpup');

	p.setphysics(PHYS_Falling);
}

simulated exec function PlayerCollisionDebug()
{
	local KFBulletWhipAttachment WhipAttach;

	if( Level.NetMode != NM_StandAlone )
	{
        if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		  return;
	}

	if( HudKillingFloor(myHUD).bDebugPlayerCollision )
	{
    	foreach DynamicActors(class'KFBulletWhipAttachment', WhipAttach)
    	{
            WhipAttach.SetDrawType(DT_None);
    	}

		HudKillingFloor(myHUD).bDebugPlayerCollision = false;
	}
	else
	{
    	foreach DynamicActors(class'KFBulletWhipAttachment', WhipAttach)
    	{
            WhipAttach.SetDrawType(DT_Sprite);
    	}

    	HudKillingFloor(myHUD).bDebugPlayerCollision = true;
	}
}

// These is an accessor for the KFPlayerInput class. It looks here to see what to set the mouse sensitivy to.
// Used primarily for lowering the mouse sensitivity while sniping. Returning -1 will do no modification at all.
// Ramm - 10/27/03
function float GetMouseModifier()
{
	local KFWeapon weap;

	if (Pawn == none || Pawn.Weapon == none)
		return -1.0;

	weap = KFWeapon(Pawn.Weapon);

	if (weap== none )
		return -1.0;


	if(weap.KFScopeDetail == KF_ModelScope && weap.ShouldDrawPortal())
	{
		return 24;
	}
	else if(weap.KFScopeDetail == KF_ModelScopeHigh && weap.ShouldDrawPortal())
	{
		return 24;
	}
	else
	{
		return -1.0;
	}
}

// Set up the widescreen FOV values for this player
simulated final function InitFOV()
{
	local Inventory inv;
	local KFWeapon KFWeap;
	local int i;
	local float ResX, ResY;
	local float AspectRatio;
	local float OriginalAspectRatio;
	local float NewFOV;

    ResX = float(GUIController(Player.GUIController).ResX);
    ResY = float(GUIController(Player.GUIController).ResY);
    AspectRatio = ResX / ResY;

	if ( bUseTrueWideScreenFOV && AspectRatio >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
	{
        OriginalAspectRatio = 4/3;

        NewFOV = (ATan((Tan((90.0*Pi)/360.0)*(AspectRatio/OriginalAspectRatio)),1)*360.0)/Pi;

        default.DefaultFOV = NewFOV;
        DefaultFOV = NewFOV;

        // 16X9
        if( AspectRatio >= 1.70 )
        {
            //log("Detected 16X9: "$(float(GUIController(Player.GUIController).ResX) / GUIController(Player.GUIController).ResY));
        }
        else
        {
            //log("Detected 16X10: "$(float(GUIController(Player.GUIController).ResX) / GUIController(Player.GUIController).ResY));
        }
    }
	else
	{
            //log("Detected 4X3: "$(float(GUIController(Player.GUIController).ResX) / GUIController(Player.GUIController).ResY));
            default.DefaultFOV = 90.0;
            DefaultFOV = 90.0;
	}

    // Initialize the FOV of all the weapons the player is carrying
	if( Pawn != none )
    {
    	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		i++;
            KFWeap = KFWeapon(Inv);
    		if ( KFWeap != None )
    		{
                KFWeap.InitFOV();
    		}

    		// Little hack to catch possible runaway loops. Gotta love those linked listed in UE2.5 - Ramm
    		if( i > 10000 )
    		  break;
    	}
	}

	// Set the FOV to the default FOV
	TransitionFOV(DefaultFOV,0.);
}


/*
// Dev commands for trailers, commented out when not filming, remove for final release - Ramm

// Send a voice message of a certain type to a certain player.
exec function Speech( name Type, int Index, string Callsign )
{
    // No speech for now for vid recording!!! - Ramm
	//ServerSpeech(Type,Index,Callsign);
}

exec function ToggleScreenShotMode()
{
	if ( myHUD.bCrosshairShow )
	{
		myHUD.bCrosshairShow = false;
		SetWeaponHand("Hidden");
		myHUD.bHideHUD = true;
		//TeamBeaconMaxDist = 0;
		//bHideVehicleNoEntryIndicator = true;
	}
	else
	{
		// return to normal
		myHUD.bCrosshairShow = true;
		SetWeaponHand("Right");
		myHUD.bHideHUD = false;
		//TeamBeaconMaxDist = default.TeamBeaconMaxDist;
		//bHideVehicleNoEntryIndicator = false;
	}
}

exec function ZoomTimed(float newZoom)
{
    StartZoomWithMax(newZoom);
}

exec function PoundRage()
{
	local KFMonster KFMonst;

	Level.Game.KillBots(Level.Game.NumBots);
	foreach DynamicActors(class'KFMonster', KFMonst)
	{
        KFMonst.StartCharging();
	}
}

exec function GiveAll()
{
    ServerGiveAll();
}

function ServerGiveAll()
{
	local Inventory Inv;

	Pawn.GiveWeapon("KFmod.Bullpup");
	Pawn.GiveWeapon("KFmod.Winchester");
	Pawn.GiveWeapon("KFmod.Crossbow");
	Pawn.GiveWeapon("KFmod.DualDeagle");
	Pawn.GiveWeapon("KFmod.Deagle");
	Pawn.GiveWeapon("KFmod.Single");
	Pawn.GiveWeapon("KFmod.Dualies");
	Pawn.GiveWeapon("KFmod.Axe");
	Pawn.GiveWeapon("KFmod.Machete");
	Pawn.GiveWeapon("KFmod.Knife");
	Pawn.GiveWeapon("KFmod.Chainsaw");
	Pawn.GiveWeapon("KFmod.LAW");
	Pawn.GiveWeapon("KFmod.Shotgun");
	Pawn.GiveWeapon("KFmod.BoomStick");
	Pawn.GiveWeapon("KFMod.FlameThrower");


	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Weapon(Inv)!=None )
			Weapon(Inv).SuperMaxOutAmmo();
	}
}

exec function HackSlomo(float NewSpeed)
{
    ServerHackSlomo(NewSpeed);
}

function ServerHackSlomo(float NewSpeed)
{
    Level.Game.SetGameSpeed(NewSpeed);
}*/

exec function ToggleBuddyHudDebug()
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        return;
    }

	if ( HudKillingFloor(myHUD) != none )
	{
		HudKillingFloor(myHUD).bShowBuddyDebug = !HudKillingFloor(myHUD).bShowBuddyDebug;
	}
}


exec function ToggleZedHudDebug()
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
        return;
    }

	if ( HudKillingFloor(myHUD) != none )
	{
		HudKillingFloor(myHUD).bShowEnemyDebug = !HudKillingFloor(myHUD).bShowEnemyDebug;
	}
}


/* RO Bloom Stuff Begin */
//TEMP START

// 0 = bloom
// 1 = blur
// 2 = b&w

// Toggle the bloom on and off as well as the ini setting for it
exec function Bloom()
{
	local bool bBloom;

	bBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));

    if( bBloom )
    {
    	PostFX_SetActive(0, false);
    	ConsoleCommand("set ini:Engine.Engine.ViewportManager Bloom"@False);
    }
    else
    {
    	PostFX_SetActive(0, true);
    	ConsoleCommand("set ini:Engine.Engine.ViewportManager Bloom"@True);
    }
}

// Debug tool for the black and white effect
exec function BWEffect(float NewAmount)
{
	if ( SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat BWEffect");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	if( NewAmount > 0 )
	{
		postfxon(2);
		postfxbw(NewAmount);
	}
	else
	{
		postfxoff(2);
	}
}

/*
exec function TestWhiz(float duration, float intensity)
{
	AddBlur(duration, Intensity/2);
}*/

simulated function SetBlur(float NewAmount)
{
	if( NewAmount > 0 )
	{
		if( class'KFMod.KFHumanPawn'.default.bUseBlurEffect )
		{
            postfxon(1);
    		postfxblur(NewAmount);
		}
	}
	else
	{
		postfxoff(1);
	}
}

// Bloom functions

simulated function postfxon(int i)
{
   	if( PostFX_IsReady() )
		PostFX_SetActive(i, true);
}

simulated function postfxoff(int i)
{
	if( PostFX_IsReady() )
		PostFX_SetActive(i, false);
}

simulated function postfxblur(float f)//0... 1
{
   	if( PostFX_IsReady() )
		PostFX_SetParameter(1, 0, f);
}

simulated function postfxbw(float f, optional bool bDoNotTurnOffFadeFromBlackEffect)	//0... 1
{
	if( !PostFX_IsReady() )
		return;

//    if (!bDoNotTurnOffFadeFromBlackEffect)
//        bDoFadeFromBlackEffect = false;

	PostFX_SetParameter(2, 0, f);
}

/*exec function postfxbloom(float f)	//0... 1 (default 0.7f)
{
	if( Level.NetMode != NM_Standalone )
		return;

	PostFX_SetParameter(0, 0, f);
}*/ // I'm not needed no more!

exec function postfxbloom_bpcontrast(float f)	//0.0f ... 4.0f (default 3.0f)
{
	if( Level.NetMode != NM_Standalone )
		return;

	PostFX_SetParameter(0, 2, f);
}

exec function postfxbloom_blurmult(float f)	//1.0f ... 2.0f (Default 1.5f)
{
	if( Level.NetMode != NM_Standalone )
		return;

	PostFX_SetParameter(0, 3, f);
}

exec function postfxbloom_ratiomin(float f) // 0.0f-1.0f (Default 0.0f)
{
     if( Level.NetMode != NM_Standalone )
         return;

     PostFX_SetParameter(0,4, f);
}

exec function postfxbloom_ratiomax(float f) // 0.0-1.0f (Default 0.5f)
{
     if( Level.NetMode != NM_Standalone )
         return;

     PostFX_SetParameter(0,5, f);
}

exec function postfxbloom_ratio(float f) // 0.0-1.0f (Default 0.5f)
{
     if( Level.NetMode != NM_Standalone )
         return;

     PostFX_SetParameter(0,6, f);
}

exec function postfxbloom_togglegpu()
{
     if( Level.NetMode != NM_Standalone )
         return;

     PostFX_SetParameter(0,7, 0);
}

exec function postfxbloom_gpucalcs()
{
     // 2000 is a hacked in number, using to determine if avgbloom calcs are done on the GPU
     self.Player.Console.Message("Doing GPU Calcs: "$PostFX_IsActive(2000),0);
}
/* RO Bloom Stuff End */

exec function ToggleDuck()
{
	if( Pawn != none )
	{
		if( bDuck == 0 )
		{
			bDuck = 1;
		}
		else
		{
			bDuck = 0;
		}
	}
}

exec function Crouch()
{
	if( Pawn != none )
	{
		bDuck = 1;
	}
}

exec function UnCrouch()
{
	if( Pawn != none )
	{
		bDuck = 0;
	}
}

// Overriden to support resetting motion blur before switching maps and cleaning
// up weapons that aren't properly garbage collected under normal circumstances
event PreClientTravel()
{
	super.PreClientTravel();

	if( Level.NetMode != NM_DedicatedServer )
	{
		SetBlur(0);

		if( Pawn != none)
		{
			if( Vehicle(Pawn) != none && Vehicle(Pawn).Driver != none && KFPawn(Vehicle(Pawn).Driver) != none )
			{
				KFPawn(Vehicle(Pawn).Driver).PreTravelCleanUp();
			}
			else if ( KFPawn(Pawn) != none )
			{
				KFPawn(Pawn).PreTravelCleanUp();
			}
		}
	}
}

function Possess(Pawn aPawn)
{
	bSpawnedThisWave = true;
	bVomittedOn = false;
	bScreamedAt = false;

	super.Possess(aPawn);
}

// Overidden to support resetting shake and blur values when you posses the pawn
function AcknowledgePossession(Pawn P)
{
    // Tell the server if we want the trader path or not
    if( Role < ROLE_Authority )
    {
        ServerSetWantsTraderPath(bWantsTraderPath);
    }

	if( P != none )
	{
		StopViewShaking();
		if( Level.NetMode != NM_DedicatedServer )
		{
			SetBlur(0);
		}

		if( KFHumanPawn(P) != none )
		{
            KFHumanPawn(P).KFPC = self;
		}
	}

    super.AcknowledgePossession(P);
}

event ClientOpenMenu (string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	if(Player == None)
		Return;
	else Super.ClientOpenMenu(Menu,bDisconnect,Msg1,Msg2);
}

// TODO : Why are we not in state PlayerWaiting, where this was cut n' pasted
//        from in the first place?
function ServerReStartPlayer()
{
	if( PlayerReplicationInfo.bOutOfLives )
		Return; // No more main menu bug closing.

	ClientCloseMenu(true, true);

	if ( Level.Game.bWaitingToStartMatch )
		PlayerReplicationInfo.bReadyToPlay = true;
	else Level.Game.RestartPlayer(self);
}

function ServerUnreadyPlayer()
{
	if ( Level.Game.bWaitingToStartMatch )
		PlayerReplicationInfo.bReadyToPlay = false;
}

exec function FreeCamera( bool B )
{
	if ( SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat FreeCamera");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

    bFreeCamera = B;
    bBehindView = B;
}

//pass in FalloffStartTime = 0 for constant shaking
event SetAmbientShake(float FalloffStartTime, float	FalloffTime, vector	OffsetMag, float OffsetFreq, rotator RotMag, float RotFreq)
{
	local float FalloffScaling;
	local float CurrentOffsetMag;

	// Calculate current shake's magnitude
    if (AmbientShakeFalloffStartTime > 0)
	{
		FalloffScaling = 1.0 - ((Level.TimeSeconds - AmbientShakeFalloffStartTime) / AmbientShakeFalloffTime);
		FalloffScaling = FClamp(FalloffScaling, 0.0, 1.0);
	}
	else
	{
		FalloffScaling = 1.0;
	}
	CurrentOffsetMag = VSize(AmbientShakeOffsetMag * FalloffScaling);

    // If new shake is less than old shake just ignore it
	if( VSize(OffsetMag) < CurrentOffsetMag )
	{
	   return;
	}

	bEnableAmbientShake = true;
	AmbientShakeFalloffStartTime = FalloffStartTime;
	AmbientShakeFalloffTime = FalloffTime;
	AmbientShakeOffsetMag = OffsetMag;
	AmbientShakeOffsetFreq = OffsetFreq;
	AmbientShakeRotMag = RotMag;
	AmbientShakeRotFreq = RotFreq;
}

// Toggle the Flashlight on or off via an exec call.
exec function ToggleTorch()
{
	if (pawn.Weapon != none && KFWeapon(pawn.Weapon).bTorchEnabled)
		KFWeapon(pawn.Weapon).LightFire();
}

// Set a new recoil amount
simulated function SetRecoil(rotator NewRecoilRotation, float NewRecoilSpeed)
{
	RecoilRotator += NewRecoilRotation;
	LastRecoilTime = Level.TimeSeconds;
	RecoilSpeed = NewRecoilSpeed;

}

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation, ViewRotation;

    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bFreeCamZoom == True)
        {
            CameraDeltaRad += DeltaTime * 0.25 * aLookUp;
        }
        else if (bFreeCamSwivel == True)
        {
            CameraSwivel.Yaw += 16.0 * DeltaTime * aTurn;
            CameraSwivel.Pitch += 16.0 * DeltaTime * aLookUp;
        }
        else
        {
            CameraDeltaRotation.Yaw += 32.0 * DeltaTime * aTurn;
            CameraDeltaRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        }
    }
    else
    {
	    ViewRotation = Rotation;

		if(Pawn != None && Pawn.Physics != PHYS_Flying) // mmmmm
		{
			// Ensure we are not setting the pawn to a rotation beyond its desired
			if(	Pawn.DesiredRotation.Roll < 65535 &&
				(ViewRotation.Roll < Pawn.DesiredRotation.Roll || ViewRotation.Roll > 0))
				ViewRotation.Roll = 0;
			else if( Pawn.DesiredRotation.Roll > 0 &&
				(ViewRotation.Roll > Pawn.DesiredRotation.Roll || ViewRotation.Roll < 65535))
				ViewRotation.Roll = 0;
		}

        DesiredRotation = ViewRotation; //save old rotation

        // Removing TurnTowardNearestEnemy and TurnAround since we don't need them and they can be used to exploit ini settings to have no recoil - Ramm
        /*if ( bTurnToNearest != 0 )
            TurnTowardNearestEnemy();
        else if ( bTurn180 != 0 )
            TurnAround();
        else
        {*/
            TurnTarget = None;
            bRotateToDesired = false;
            bSetTurnRot = false;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
	       	ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;


			if( (Pawn != none ) && (Pawn.Weapon != none) )
			{
				ViewRotation = RecoilHandler(ViewRotation, DeltaTime);
            }
        /*}*/

        if (Pawn != None)
	        ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);

		SetRotation(ViewRotation);

        ViewShake(deltaTime);
        ViewFlash(deltaTime);

		NewRotation = ViewRotation;
        //NewRotation.Roll = Rotation.Roll;

        if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
            Pawn.FaceRotation(NewRotation, deltatime);
    }
}

//------------------------------------------------------------------------------
//	Recoi;mHandler
// Process recoil
//------------------------------------------------------------------------------
simulated function rotator RecoilHandler(rotator NewRotation, float DeltaTime)
{
	// Process recoil
    if( Level.TimeSeconds - LastRecoilTime <= RecoilSpeed )
    {
		NewRotation += (RecoilRotator/RecoilSpeed) * deltatime;
    }
    else
    {
		RecoilRotator = rot(0,0,0);
    }

	return NewRotation;
}

function GRIKillBotCall(int NumBotsToKill)
{
	if (KFGameType(Level.Game) != none && NumBotsToKill > 0)
		KFGameType(Level.Game).KillBots(NumBotsToKill);
}

function KFClientNetWorkMsg(string ParamA, string ParamB)
{
	ClientOpenMenu("KFGUI.KFNetworkStatusMsg", true, ParamA, ParamB);
}

function BecomeSpectator()
{
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.BecomeSpectator(self) )
		return;

	if ( Pawn != None )
		Pawn.Died(self, class'DamageType', Pawn.Location);

	if ( PlayerReplicationInfo.Team != None )
		PlayerReplicationInfo.Team.RemoveFromTeam(self);
	PlayerReplicationInfo.Team = None;
	ServerSpectate();
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);

	ClientBecameSpectator();
}

// Returns true if there are players to spectate
function bool PlayersToSpectate()
{
	local Controller C;

	// Make sure there are players we can spectate.  if not, leave the players looking at their corpse.
	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C != self && Level.Game.CanSpectate(self, PlayerReplicationInfo.bOnlySpectator, C.Pawn) )
		{
			return true;
		}
	}

	return false;
}

function ServerSetGRIPendingBots(int NumBotsPending,string BotName)
{
	local int arraydifference;

	//if (KFGameReplicationInfo(GameReplicationInfo).PendingBots  > 0)
	//	arraydifference = 1;
	//else
         arraydifference = 0;

	KFGameReplicationInfo(GameReplicationInfo).PendingBots = NumBotsPending;
	KFGameReplicationInfo(GameReplicationInfo).LastBotName[KFGameReplicationInfo(GameReplicationInfo).PendingBots - arraydifference] = BotName;
}


function ServerSetTempBotName(string KFBotName)
{
	KFGameReplicationInfo(GameReplicationInfo).TempBotName = KFBotName;
}


exec function ThrowGrenade()
{
	KFPawn(Pawn).ThrowGrenade();
}

exec function NextWeapon()
{
	if ( HudKillingFloor(myHUD) != none )
	{
		HudKillingFloor(myHUD).NextWeapon();
	}
	else
	{
		super.NextWeapon();
	}
}

exec function PrevWeapon()
{
	if ( HudKillingFloor(myHUD) != none )
	{
		HudKillingFloor(myHUD).PrevWeapon();
	}
	else
	{
		super.PrevWeapon();
	}
}

exec function Fire(optional float F)
{
	if ( HudKillingFloor(myHUD) != none && HudKillingFloor(myHUD).bDisplayInventory )
	{
		HudKillingFloor(myHUD).SelectWeapon();
		bFire = 0;
	}
	else
	{
		super.Fire(F);
	}
}

/*
// KFTODO: Removed this hack for now, I'm not sure if its needed anymore, and seems to be kind of inefficient - Ramm
simulated event PostNetReceive()
{
	Super.PostNetReceive();

	if ( PlayerReplicationInfo != none) // && bWaitingForPRI )
	{
		//bWaitingForPRI = False;

        //rec = class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName);
		//if ( rec.Species != None )
		//{
		//	if ( PlayerReplicationInfo.Team == None )
		//		rec.Species.static.LoadResources(rec, Level, PlayerReplicationInfo, 255);
		//	else
		//		rec.Species.static.LoadResources(rec, Level, PlayerReplicationInfo, PlayerReplicationInfo.Team.TeamIndex);

        // HACK !!!
        // TODO: remove hack
		PlayerReplicationInfo.VoiceTypeName = "KFCoreVoicePack.AussieVoice";
		PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(PlayerReplicationInfo.VoiceTypeName,class'Class'));
	}
}*/

function KFSwitchToBestWeapon()
{
	KFClientSwitchToBestWeapon();
}


function KFClientSwitchToBestWeapon()
{
	nextWeapon();
}

function ShowBuyMenu(string wlTag,float maxweight)
{
	StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu
	ClientOpenMenu("KFGUI.GUIBuyMenu",,wlTag,string(maxweight));
}

function ShowLobbyMenu()
{
	StopForceFeedback();  // jdf - no way to pause feedback

	bPendingLobbyDisplay = false;

	// Open menu
	ClientOpenMenu(LobbyMenuClassString);
}

function ClientRestart(Pawn NewPawn)
{
	//KILL LOBBY
	ClientCloseMenu(true, true);
	super.ClientRestart(NewPawn);
}

simulated function bool FindInterAction()
{
	local int i;

	if( Player.InteractionMaster==None )
		Return False;
	For( i=0; i<Player.InteractionMaster.GlobalInteractions.Length; i++ ) // First search if one remains from last map.
	{
		if( KFMusicInteraction(Player.InteractionMaster.GlobalInteractions[i])!=None )
		{
			KFInterAct = KFMusicInteraction(Player.InteractionMaster.GlobalInteractions[i]);
			Return True;
		}
	}
	// Else create one.
	KFInterAct = New(None)Class'KFMusicInteraction';
	KFInterAct.ViewportOwner = Player;
	KFInterAct.Master = Player.InteractionMaster;
	i = Player.InteractionMaster.GlobalInteractions.Length;
	Player.InteractionMaster.GlobalInteractions.Length = i+1;
	Player.InteractionMaster.GlobalInteractions[i] = KFInterAct;
	KFInterAct.Initialize();
	Return True;
}

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
	local float FadeIn, FadeOut;

	switch (NewTransition)
	{
		case MTRAN_Segue:
			FadeIn = 7.0;
			FadeOut = 3.0;
			break;
		case MTRAN_Fade:
			FadeIn = 3.0;
			FadeOut = 3.0;
			break;
		case MTRAN_FastFade:
			FadeIn = 1.0;
			FadeOut = 1.0;
			break;
		case MTRAN_SlowFade:
			FadeIn = 5.0;
			FadeOut = 5.0;
			break;
	}
	if( NewSong=="" )
		NetStopMusic(FadeOut);
	else NetPlayMusic(NewSong,FadeIn,FadeOut);
}
function NetPlayMusic( string Song, float FadeInTime, float FadeOutTime )
{
	if( Player==None )
	{
		if( Song=="" )
			Return;
		DelayedSongToPlay = Song;
		bHasDelayedSong = True;
		Return;
	}
	else if( NetConnection(Player)!=None )
		Return;
	if( KFInterAct==None && !FindInterAction() )
		Return;
	bHasDelayedSong = False;
	KFInterAct.SetSong(Song,FadeInTime,FadeOutTime);
}
function NetStopMusic(float FadeOutTime)
{
	bHasDelayedSong = False;
	if( Player==None || NetConnection(Player)!=None )
		Return;
	if( KFInterAct==None && !FindInterAction() )
		Return;
	KFInterAct.StopSong(FadeOutTime);
}

event PlayerTick( float DeltaTime )
{
	if( bHasDelayedSong && Player!=None )
		NetPlayMusic(DelayedSongToPlay,0.5,0);

    if( Level.GRI != none )
    {
    	if ( KFGameReplicationInfo(Level.GRI) != None && KFGameReplicationInfo(Level.GRI).EndGameType > 0)
    	{
    		Advertising_EnterZone("mp_lobby");
    	}
    	else if (Level.GRI.bMatchHasBegun )
    	{
    		Advertising_ExitZone();
    	}
    }

	Super.PlayerTick(DeltaTime);
}

//  enforce Lobby menu appearance here - there were all sorts of conditions attached,
//  but none of them should occur in KF. This simplifies matters ;)
simulated function ShowLoginMenu()
{
	if( (Pawn != none && Pawn.Health > 0) || (Pawn.PlayerReplicationInfo != none && Pawn.PlayerReplicationInfo.bReadyToPlay) )
		return;

	if ( GameReplicationInfo != none )
	{
		// Open menu
		ClientReplaceMenu(LobbyMenuClassString);
	}
}

auto state PlayerWaiting
{
	exec function Fire(optional float F)
	{
		LoadPlayers();
	}

	function bool CanRestartPlayer()
	{
		if(Level.Game.GameReplicationInfo.bMatchHasBegun)
			return False;
		return ((bReadyToStart || (DeathMatch(Level.Game) != None && DeathMatch(Level.Game).bForceRespawn)) && Super.CanRestartPlayer());
	}

    simulated function Timer()
    {
        if ( !bPendingLobbyDisplay || bDemoOwner || (PlayerReplicationInfo != none && PlayerReplicationInfo.bReadyToPlay) )
        {
            SetTimer(0, false);
        }
        else if ( !bRequestedSteamData && SteamStatsAndAchievements == none )
    	{
			if ( Level.NetMode == NM_Standalone )
			{
				SteamStatsAndAchievements = Spawn(SteamStatsAndAchievementsClass, self);
				if ( SteamStatsAndAchievements == none || !SteamStatsAndAchievements.Initialize(self) )
				{
					SteamStatsAndAchievements.Destroy();
					SteamStatsAndAchievements = none;
					bRequestedSteamData = true;
				}
			}
			else
			{
				bRequestedSteamData = true;
			}
    	}
        else if ( SteamStatsAndAchievements != none && !SteamStatsAndAchievements.bInitialized && ForceShowLobby < 10 )
    	{
    		if ( !bRequestedSteamData )
    		{
    			ForceShowLobby = 0;
				SteamStatsAndAchievements.GetStatsAndAchievements();
				bRequestedSteamData = true;
			}

			ForceShowLobby++;
        }
		else if ( Player != None && GUIController(Player.GUIController) != None && !GUIController(Player.GUIController).bActive && GameReplicationInfo != none )
	    {
			// Spawn hint manager (if needed)
		    UpdateHintManagement(bShowHints);

			ShowLobbyMenu();

			SetTimer(0, false);
		}


    }

    simulated function EndState()
    {
        super.EndState();

        if (Level.NetMode != NM_DedicatedServer)
        {
			SetupWebAPI();
		}
    }

    // hax to open menu when player joins the game
    simulated function BeginState()
    {
        super.BeginState();

        bRequestedSteamData = false;

        if (Level.NetMode != NM_DedicatedServer && bPendingLobbyDisplay)
        {
			SetTimer(0.1, true);
            Timer();
        }
    }
}

simulated function SetupWebAPI()
{
	if( Player != None  && webAPIAccessor == none && SteamStatsAndAchievements != none )
    {
    	webAPIAccessor = Spawn(class'KFSteamWebAPI', self);
		webAPIAccessor.AchievementReport = KFSteamStatsAndAchievements(SteamStatsAndAchievements).OnAchievementReport;

		if ( SteamStatsAndAchievements.PCowner == None )
			SteamStatsAndAchievements.PCOwner= self;

		log("webapi*************", 'DevNet');
		if( Level.NetMode != NM_DedicatedServer && Player != none && Player.GUIController != none )
		{
			webAPIAccessor.GetAchievements(Player.GUIController.SteamGetUserID());
			log(Player.GUIController.SteamGetUserID(), 'DevNet');
        }
		else
		{
	        webAPIAccessor.GetAchievements(SteamStatsAndAchievements.GetSteamUserID());
	        log(SteamStatsAndAchievements.GetSteamUserID(), 'DevNet');
        }
	}
}

// unpossessed a pawn (because pawn was killed)
function PawnDied(Pawn P)
{
	local int i;

	for (i = 0; i < CameraEffects.Length; i++)
	{
      	RemoveCameraEffect(CameraEffects[i]);
	}

	Super.PawnDied(P);
}


function ZoneInfo GetCurrentZone()
{
  return Region.Zone;
}

simulated function PlayBeepSound()
{
    if ( ViewTarget != None )
        ViewTarget.PlaySound(sound'KFWeaponSound.bullethitflesh2', SLOT_None,,,,,false);
}

function ShowMidGameMenu(bool bPause)
{
	if ( HUDKillingFloor(MyHud).bDisplayInventory )
	{
		HUDKillingFloor(MyHud).HideInventory();
	}
	else
	{
		// Pause if not already
		if( Level.Pauser==None && Level.NetMode==NM_StandAlone )
			SetPause(true);

		if ( Level.NetMode != NM_DedicatedServer )
			StopForceFeedback();  // jdf - no way to pause feedback

		// Open menu
		if (bDemoOwner)
			ClientopenMenu(DemoMenuClass);

		else if ( LoginMenuClass != "" )
			ClientOpenMenu(LoginMenuClass);

		else ClientOpenMenu(MidGameMenuClass);
	}
}

// Fast Melee Switch Code.
// server calls this to force client to switch
function ClientSwitchToBestMeleeWeapon()
{
	SwitchToBestMeleeWeapon();
}

// Same as SwitchToBestWeapon, but we're only dealing in Melee arms now.
exec function SwitchToBestMeleeWeapon()
{
	local inventory inv;

	if ( Pawn == None || KFMeleeGun(Pawn.Inventory) == None )
		return;

	if ( (Pawn.PendingWeapon == None)  )
	{
		for(inv = pawn.Inventory; inv!=None; inv=inv.Inventory)
      	{
			if(inv.IsA('Knife'))
			{
				Pawn.PendingWeapon = Knife(inv);
				Break;
			}
		}
		if ( Pawn.PendingWeapon == Pawn.Weapon )
			Pawn.PendingWeapon = None;
		if ( Pawn.PendingWeapon == None )
			return;
	}
	StopFiring();

	if ( Pawn.Weapon == None )
		Pawn.ChangedWeapon();
	else if ( Pawn.Weapon != Pawn.PendingWeapon )
		Pawn.Weapon.PutDown();
}

simulated function SendSelectedVeterancyToServer(optional bool bForceChange)
{
	SelectVeterancy(SelectedVeterancy, bForceChange);
}

function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange)
{
	if ( VetSkill == none || KFPlayerReplicationInfo(PlayerReplicationInfo) == none )
	{
		return;
	}

	if ( KFSteamStatsAndAchievements(SteamStatsAndAchievements) != none )
	{
		SetSelectedVeterancy( VetSkill );

		if ( KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress && VetSkill != KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill )
		{
			bChangedVeterancyThisWave = false;
			ClientMessage(Repl(YouWillBecomePerkString, "%Perk%", VetSkill.Default.VeterancyName));
		}
		else if ( !bChangedVeterancyThisWave || bForceChange )
		{
			if ( VetSkill != KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill )
			{
				ClientMessage(Repl(YouAreNowPerkString, "%Perk%", VetSkill.Default.VeterancyName));
			}

			if ( GameReplicationInfo.bMatchHasBegun )
			{
				bChangedVeterancyThisWave = true;
			}

			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill = VetSkill;
			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = KFSteamStatsAndAchievements(SteamStatsAndAchievements).PerkHighestLevelAvailable(VetSkill.default.PerkIndex);

			if( KFHumanPawn(Pawn) != none )
			{
				KFHumanPawn(Pawn).VeterancyChanged();
			}
		}
		else
		{
			ClientMessage(PerkChangeOncePerWaveString);
		}
	}
}

function SetSelectedVeterancy( class<KFVeterancyTypes> VetSkill )
{
    local int i;

    SelectedVeterancy = VetSkill;

    for( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; ++i )
    {
        if( class'KFGameType'.default.LoadedSkills[i] == VetSkill )
        {
            BuyMenuFilterIndex = i;
            break;
        }
    }
}

function SetPawnClass(string inClass, string inCharacter)
{
	PawnClass = Class'KFHumanPawn';
	inCharacter = Class'KFGameType'.Static.GetValidCharacter(inCharacter);
	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

/* Taken out for release - Ramm
exec function RMode2( byte MD )
{
	if ( SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat RMode2");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	RendMap = MD;
}*/

exec function TogglePathToTrader()
{
	SetShowPathToTrader(!bShowTraderPath);
}

// Handle toggling showing the path to the trader
function SetShowPathToTrader(bool bShouldShowPath)
{
    if( !bWantsTraderPath )
    {
        bShowTraderPath = false;
    }
    else
    {
        if( bShouldShowPath )
        {
            Timer();
            SetTimer(TraderPathInterval, true);
            bShowTraderPath = true;
        }
        else
        {
            bShowTraderPath = false;
            SetTimer(0, false);
        }
    }
}

// Show the path the trader
function Timer()
{
	if ( !bWantsTraderPath )
    {
        bShowTraderPath = false;
        SetTimer(0, false);
    }
	else
	{
	    // Fairly lame place to call this, but I need a place that is called very often that is run on the server
		if( Role == ROLE_Authority && bShowTraderPath  )
		{
	        UnrealMPGameInfo(Level.Game).ShowPathTo(Self, 0);
		}
	}

	if ( Role == ROLE_Authority && bVomittedOn )
	{
		if ( Level.TimeSeconds - VomittedOnTime > 10.0 )
		{
			if ( KFSteamStatsAndAchievements(SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(SteamStatsAndAchievements).Survived10SecondsAfterVomit();
				bVomittedOn = false;
			}
		}
		else if ( !bTimerLoop || TimerRate == 0.0 )
		{
			SetTimer(10.0 - (Level.TimeSeconds - VomittedOnTime), false);
		}
	}

	if ( Role == ROLE_Authority && bScreamedAt && Pawn != none && Pawn.Health > 0 )
	{
		if ( Level.TimeSeconds - ScreamTime > 10.0 )
		{
			if ( KFSteamStatsAndAchievements(SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(SteamStatsAndAchievements).Survived10SecondsAfterScream();
				bScreamedAt = false;
			}
		}
		else if ( !bTimerLoop || TimerRate == 0.0 )
		{
			SetTimer(10.0 - (Level.TimeSeconds - ScreamTime), false);
		}
	}
}

// Sets the bWantsTraderPath var on the server, since thats where its used
function ServerSetWantsTraderPath(bool bNewWantsTraderPath)
{
    bWantsTraderPath = bNewWantsTraderPath;
}

state Dead
{
	function Timer()
	{
	    if ( !bSpawnedThisWave && KFGameType(Level.Game) != none && Level.Game.GameReplicationInfo.bMatchHasBegun &&
			 Role == ROLE_Authority && !KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress )
		{
			PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash, int(PlayerReplicationInfo.Score));
			SetViewTarget(self);
			ClientSetBehindView(false);
			bBehindView = False;
			ClientSetViewTarget(Pawn);
			PlayerReplicationInfo.bOutOfLives = false;
			Pawn = none;
			ServerReStartPlayer();
		}

		super.Timer();
	}

	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		if( Level.NetMode==NM_DedicatedServer )
		{
			Global.PlayerCalcView(ViewActor,CameraLocation,CameraRotation);
			Return;
		}
		if ( LastPlayerCalcView == Level.TimeSeconds && CalcViewActor != None && CalcViewActor.Location == CalcViewActorLocation )
		{
			ViewActor	= CalcViewActor;
			CameraLocation	= CalcViewLocation;
			CameraRotation	= CalcViewRotation;
			return;
		}
		if( Pawn(ViewTarget)!=None && Pawn(ViewTarget).bSpecialCalcView )
		{
			// try the 'special' calcview. This may return false if its not applicable, and we do the usual.
			if ( Pawn(ViewTarget).SpecialCalcView(ViewActor, CameraLocation, CameraRotation) )
			{
				CacheCalcView(ViewActor,CameraLocation,CameraRotation);
				return;
			}
		}
		Global.PlayerCalcView(ViewActor,CameraLocation,CameraRotation);
	}

	simulated function BeginState()
	{
		// Unzoom if we were zoomed
        TransitionFOV(DefaultFOV,0.);

        Super.BeginState();
		if ( HudKillingFloor(myHUD) != none )
		{
			HudKillingFloor(myHUD).bDisplayDeathScreen = True;
			HudKillingFloor(myHUD).GoalTarget = ViewTarget;
		}

		if ( Role == ROLE_Authority )
		{
			SetTimer(1.0, false);
		}
	}

	simulated function EndState()
	{
		super.EndState();

		if ( HudKillingFloor(myHUD) != none )
		{
			HUDKillingFloor(myHud).StopFadeEffect();
		}
	}
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
	simulated function BeginState()
	{
        Super.BeginState();
        // Unzoom if we were zoomed
        TransitionFOV(DefaultFOV,0.);
	}
}

function HandleWalking()
{
	local KFHumanPawn P;

	P = KFHumanPawn(Pawn);

	if (P == None)
		return;

    if (P.bAimingRifle)
		P.SetWalking(true);
	else
		P.SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') );
}

function AdjustView(float DeltaTime )
{
    local bool bReachedTargetFOV;

	// Updating the FOV
	if( TransitionTimeTotal > 0.0f && FOVAngle != TargetFOV )
	{
		TransitionTimeElapsed += DeltaTime;
		if( TransitionTimeElapsed > TransitionTimeTotal )
		{
			TransitionTimeElapsed = TransitionTimeTotal;
			bReachedTargetFOV = true;
		}

        FOVAngle = Lerp( (TransitionTimeElapsed / TransitionTimeTotal), TransitionStartFOV, TargetFOV );
        DesiredFOV = FOVAngle;

        if( bReachedTargetFOV )
        {
            TransitionTimeTotal = 0;
        }
	}

    super.AdjustView(DeltaTime);
}

//________________
// TransitionFOV
//
// Created to implement the interface for smooth transitioning
// between FOVs. NewFOV specifies the TargetFOV and TransitionTime
// specifies how long in seconds the transition should take from the
// current FOV.
function TransitionFOV(float NewFOV, float TransitionTime)
{
	if( TransitionTime > 0.0f )
	{
		TargetFOV = NewFOV;
		TransitionTimeTotal = TransitionTime;
		TransitionStartFOV = FOVAngle;
		TransitionTimeElapsed = 0.0f;
	}
	else
	{
		FOVAngle = NewFOV;
		TargetFOV = NewFOV;
		DesiredFOV = FOVAngle;
		TransitionTimeTotal = 0.0f; // The system won't attempt an FOV transition if TimeTotal is 0.
	}
}

exec function ToggleXHair()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	if ( myHUD.bCrosshairShow )
	{
		myHUD.bCrosshairShow = false;
		HudKillingFloor(myHUD).bShowKFDebugXHair = false;
	}
	else
	{
		// return to normal
		myHUD.bCrosshairShow = true;
		HudKillingFloor(myHUD).bShowKFDebugXHair = true;
	}
}

function SendVoiceMessage(PlayerReplicationInfo Sender,
						  PlayerReplicationInfo Recipient,
						  name messagetype,
						  byte messageID,
						  name broadcasttype,
						  optional Pawn soundSender,
						  optional vector senderLocation)
{
	local Controller P;
	local KFPlayerController KFPC;

	if ( !AllowVoiceMessage(MessageType) )
	{
		return;
	}

	for ( P = Level.ControllerList; P != none; P = P.NextController )
	{
		KFPC = KFPlayerController(P);

		if ( KFPC != None )
		{
			// Don't allow dead people to talk
			if ( Pawn != none )
			{
				KFPC.ClientLocationalVoiceMessage(Sender, Recipient, messagetype, messageID, soundSender, senderLocation);
			}
		}
	}
}

function ClientLocationalVoiceMessage(PlayerReplicationInfo Sender,
									  PlayerReplicationInfo Recipient,
									  name MessageType, byte MessageID,
									  optional Pawn SenderPawn, optional vector SenderLocation)
{
	local VoicePack Voice;
	local ShopVolume Shop;

	if ( Sender == none || Sender.VoiceType == none || Player.Console == none || Level.NetMode == NM_DedicatedServer )
	{
		return;
	}

	Voice = Spawn(Sender.VoiceType, self);
	if ( KFVoicePack(Voice) != none )
	{
		if ( MessageType == 'TRADER' )
		{
			if ( Pawn != none && MessageID >= 4 )
			{
				foreach Pawn.TouchingActors(Class'ShopVolume', Shop)
				{
					SenderLocation = Shop.MyTrader.Location;

					// Only play the 30 Seconds remaining messages come across as Locational Speech if we're in the Shop
					if ( MessageID == 4 )
					{
						return;
					}
					else if ( MessageID == 5 )
					{
						MessageID = 999;
					}

					break;
				}
			}

			// Only play the 10 Seconds remaining message if we are in the Shop
			// and only play the 30 seconds remaning message if we haven't been to the Shop
			if ( MessageID == 5 || (MessageID == 4 && bHasHeardTraderWelcomeMessage) )
			{
				return;
			}
			else if ( MessageID == 999 )
			{
				MessageID = 5;
			}

			// Store the fact that we've heard the Trader's Welcome message on the client
			if ( MessageID == 7 )
			{
				bHasHeardTraderWelcomeMessage = true;
			}
			// If we're hearing the Shop's Closed Message, reset the Trader's Welcome message flag
			else if ( MessageID == 6 )
			{
				bHasHeardTraderWelcomeMessage = false;
			}

			KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);

			if ( MessageID > 6 /*&& bBuyMenuIsOpen*/ )
			{
				// TODO: Show KFVoicePack(Voice).GetClientParsedMessage() in the Buy Menu
			}
			else if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )
			{
				// Radio commands print to Text
				TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Trader');
			}
		}
		else
		{
			KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);

			if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )
			{
				TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Voice');
			}
		}
	}
	else if ( Voice != None )
	{
		Voice.ClientInitialize(Sender, Recipient, MessageType, MessageID);
	}
}

simulated event NotifyPerkAvailable(int PerkType, int PerkLevel)
{
	local class<KFVeterancyTypes> NewPerkClass;

	switch ( PerkType )
	{
		case 0:
			NewPerkClass = class'KFVetFieldMedic';
			break;
		case 1:
			NewPerkClass = class'KFVetSupportSpec';
			break;
		case 2:
			NewPerkClass = class'KFVetSharpshooter';
			break;
		case 3:
			NewPerkClass = class'KFVetCommando';
			break;
		case 4:
			NewPerkClass = class'KFVetBerserker';
			break;
		case 5:
			NewPerkClass = class'KFVetFirebug';
			break;
		case 6:
			NewPerkClass = class'KFVetDemolitions';
			break;
	}

	// Show Pop up notification of Perk Unlocked and Play Sound
	if ( HudKillingFloor(myHUD) != none )
	{
		// Play perk sound
        ViewTarget.PlaySound(sound'KF_InterfaceSnd.PerkAchieved', Slot_None, 2.0,true,,,false);

        if ( PerkLevel == 1 )
		{
			HudKillingFloor(myHUD).ShowPopupNotification(5.0, 3, Repl(PerkFirstLevelUnlockedString, "%x", NewPerkClass.default.VeterancyName), NewPerkClass.default.OnHUDIcon);
		}
		else if ( PerkLevel <= 5 )
		{
			HudKillingFloor(myHUD).ShowPopupNotification(3.0, 2, Repl(PerkUnlockedString, "%x", NewPerkClass.default.VeterancyName @ "-" @ LevelString @ PerkLevel), NewPerkClass.default.OnHUDIcon);
		}
		else
		{
			HudKillingFloor(myHUD).ShowPopupNotification(3.0, 2, Repl(PerkUnlockedString, "%x", NewPerkClass.default.VeterancyName @ "-" @ LevelString @ PerkLevel), NewPerkClass.default.OnHUDGoldIcon);
		}
	}
}

exec function ShowFakeNotification()
{
	HudKillingFloor(myHUD).ShowPopupNotification(5.0, 3, Repl(PerkFirstLevelUnlockedString, "%x", class'KFVetFirebug'.default.VeterancyName), class'KFVetFirebug'.default.OnHUDIcon);
}

// Cheat overrides to disable Stats/Perks/Achievements
exec function KillAll(class<Actor> aClass)
{
	if ( Role == ROLE_Authority && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat KillAll");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.KillAll(aClass);
}

exec function FOV(float F)
{
	if ( Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat FOV");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.FOV(F);
}

exec function Mutate(string MutateString)
{
	if ( Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat Mutate");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.Mutate(MutateString);
}

exec function BehindView(bool B)
{
	if ( B && Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat BehindView");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.BehindView(B);
}

exec function ToggleBehindView()
{
	if ( Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat ToggleBehindView");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.ToggleBehindView();
}

exec function SwitchTeam()
{
	if ( Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat SwitchTeam");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.SwitchTeam();
}

exec function ChangeTeam(int N)
{
	if ( Level.NetMode == NM_Standalone && SteamStatsAndAchievements != none )
	{
		log("STEAMSTATS: Used Cheat ChangeTeam");
		SteamStatsAndAchievements.bUsedCheats = true;
	}

	super.ChangeTeam(N);
}

// Hint management functions
simulated function NotifyHintRenderingDone()
{
    if (HintManager != none)
        HintManager.NotifyHintRenderingDone();
}

simulated function UpdateHintManagement(bool bUseHints)
{
    if (Level.GetLocalPlayerController() == self)
    {
        if (bUseHints && HintManager == none)
        {
            HintManager = spawn(class'KFHintManager', self);
            if (HintManager == none)
                warn("Unable to spawn hint manager");
        }
        else if (!bUseHints && HintManager != none)
        {
            HintManager.Destroy();
            HintManager = none;
        }

        if (!bUseHints)
            if (HUDKillingFloor(myHUD) != none)
                HUDKillingFloor(myHUD).bDrawHint = false;
    }
}

simulated function CheckForHint(int hintType)
{
    if (HintManager != none)
    {
		HintManager.CheckForHint(hintType);
    }
}

simulated function ClientWeaponSpawned(class<Weapon> WClass, Inventory Inv)
{
	switch ( WClass )
	{
		case class'AA12AutoShotgun':
			class'AA12AutoShotgun'.static.PreloadAssets(Inv);
			class'AA12Fire'.static.PreloadAssets(Level);
			class'AA12Attachment'.static.PreloadAssets();
			break;

		case class'GoldenAA12AutoShotgun':
			class'GoldenAA12AutoShotgun'.static.PreloadAssets(Inv);
			class'GoldenAA12Fire'.static.PreloadAssets(Level);
			class'GoldenAA12Attachment'.static.PreloadAssets();
			break;

		case class'SPAutoShotgun':
			class'SPAutoShotgun'.static.PreloadAssets(Inv);
			class'SPShotgunFire'.static.PreloadAssets(Level);
			class'SPShotgunAltFire'.static.PreloadAssets(Level);
			class'SPShotgunAttachment'.static.PreloadAssets();
			break;

		case class'AK47AssaultRifle':
			class'AK47AssaultRifle'.static.PreloadAssets(Inv);
			class'AK47Fire'.static.PreloadAssets(Level);
			class'AK47Attachment'.static.PreloadAssets();
			break;

		case class'GoldenAK47AssaultRifle':
			class'GoldenAK47AssaultRifle'.static.PreloadAssets(Inv);
			class'GoldenAK47Fire'.static.PreloadAssets(Level);
			class'GoldenAK47Attachment'.static.PreloadAssets();
			break;

		case class'BenelliShotgun':
			class'BenelliShotgun'.static.PreloadAssets(Inv);
			class'BenelliFire'.static.PreloadAssets(Level);
			class'BenelliAttachment'.static.PreloadAssets();
			break;

		case class'BlowerThrower':
			class'BlowerThrower'.static.PreloadAssets(Inv);
			class'BlowerThrowerFire'.static.PreloadAssets(Level);
			class'BlowerThrowerAltFire'.static.PreloadAssets(Level);
			class'BlowerThrowerAttachment'.static.PreloadAssets();
			break;

		case class'GoldenBenelliShotgun':
			class'GoldenBenelliShotgun'.static.PreloadAssets(Inv);
			class'GoldenBenelliFire'.static.PreloadAssets(Level);
			class'GoldenBenelliAttachment'.static.PreloadAssets();
			break;

		case class'Chainsaw':
			class'Chainsaw'.static.PreloadAssets(Inv);
			class'ChainsawFire'.static.PreloadAssets();
			class'ChainsawAltFire'.static.PreloadAssets();
			class'ChainsawAttachment'.static.PreloadAssets();
			break;

		case class'GoldenChainsaw':
			class'GoldenChainsaw'.static.PreloadAssets(Inv);
			class'GoldenChainsawAttachment'.static.PreloadAssets();
			break;

		case class'Crossbow':
			class'Crossbow'.static.PreloadAssets(Inv);
			class'CrossbowArrow'.static.PreloadAssets();
			class'CrossbowFire'.static.PreloadAssets(Level);
			class'CrossbowAttachment'.static.PreloadAssets();
			break;

		case class'FlameThrower':
			class'FlameThrower'.static.PreloadAssets(Inv);
			class'FlameBurstFire'.static.PreloadAssets(Level);
			class'FlameThrowerAttachment'.static.PreloadAssets();
			break;

		case class'GoldenFlameThrower':
			class'GoldenFlameThrower'.static.PreloadAssets(Inv);
			class'GoldenFlameBurstFire'.static.PreloadAssets(Level);
			class'GoldenFTAttachment'.static.PreloadAssets();
			break;

		case class'BoomStick':
			class'BoomStick'.static.PreloadAssets(Inv);
			class'BoomStickFire'.static.PreloadAssets(Level);
			class'BoomStickAltFire'.static.PreloadAssets(Level);
			class'BoomStickAttachment'.static.PreloadAssets();
			break;

		case class'KSGShotgun':
			class'KSGShotgun'.static.PreloadAssets(Inv);
			class'KSGFire'.static.PreloadAssets(Level);
			class'KSGAttachment'.static.PreloadAssets();
			break;

		case class'HuskGun':
			class'HuskGun'.static.PreloadAssets(Inv);
			class'HuskGunFire'.static.PreloadAssets(Level);
			class'HuskGunProjectile'.static.PreloadAssets();
			class'HuskGunProjectile_Weak'.static.PreloadAssets();
			class'HuskGunProjectile_Strong'.static.PreloadAssets();
			class'HuskGunAttachment'.static.PreloadAssets();
			break;

		case class'ZEDGun':
			class'ZEDGun'.static.PreloadAssets(Inv);
			class'ZEDGunFire'.static.PreloadAssets(Level);
			class'ZEDGunAltFire'.static.PreloadAssets(Level);
			class'ZEDGunProjectile'.static.PreloadAssets();
			class'ZEDGunAttachment'.static.PreloadAssets();
			break;

		case class'ZEDMKIIWeapon':
			class'ZEDMKIIWeapon'.static.PreloadAssets(Inv);
			class'ZEDMKIIFire'.static.PreloadAssets(Level);
			class'ZEDMKIIAltFire'.static.PreloadAssets(Level);
			class'ZEDMKIIPrimaryProjectile'.static.PreloadAssets();
			class'ZEDMKIISecondaryProjectile'.static.PreloadAssets();
			class'ZEDMKIIAttachment'.static.PreloadAssets();
			break;

		case class'Katana':
			class'Katana'.static.PreloadAssets(Inv);
			class'KatanaFire'.static.PreloadAssets();
			class'KatanaFireB'.static.PreloadAssets();
			class'KatanaAttachment'.static.PreloadAssets();
			break;

		case class'GoldenKatana':
			class'GoldenKatana'.static.PreloadAssets(Inv);
			class'KatanaFire'.static.PreloadAssets();
			class'KatanaFireB'.static.PreloadAssets();
			class'GoldenKatanaAttachment'.static.PreloadAssets();
			break;

		case class'ClaymoreSword':
			class'ClaymoreSword'.static.PreloadAssets(Inv);
			class'ClaymoreSwordFire'.static.PreloadAssets();
			class'ClaymoreSwordFireB'.static.PreloadAssets();
			class'ClaymoreSwordAttachment'.static.PreloadAssets();
			break;

		case class'DwarfAxe':
			class'DwarfAxe'.static.PreloadAssets(Inv);
			class'DwarfAxeFire'.static.PreloadAssets();
			class'DwarfAxeFireB'.static.PreloadAssets();
			class'DwarfAxeAttachment'.static.PreloadAssets();
			break;

		case class'FNFAL_ACOG_AssaultRifle':
			class'FNFAL_ACOG_AssaultRifle'.static.PreloadAssets(Inv);
			class'FNFALFire'.static.PreloadAssets(Level);
			class'FNFAL_ACOG_Attachment'.static.PreloadAssets();
			break;

		case class'LAW':
			class'LAW'.static.PreloadAssets(Inv);
			class'LAWFire'.static.PreloadAssets(Level);
			class'LAWProj'.static.PreloadAssets();
			class'LAWAttachment'.static.PreloadAssets();
			break;

		case class'M14EBRBattleRifle':
			class'M14EBRBattleRifle'.static.PreloadAssets(Inv);
			class'M14EBRFire'.static.PreloadAssets(Level);
			class'M14EBRAttachment'.static.PreloadAssets();
			break;

		case class'M4AssaultRifle':
			class'M4AssaultRifle'.static.PreloadAssets(Inv);
			class'M4Fire'.static.PreloadAssets(Level);
			class'M4Attachment'.static.PreloadAssets();
			break;

		case class'M32GrenadeLauncher':
			class'M32GrenadeLauncher'.static.PreloadAssets(Inv);
			class'M32Fire'.static.PreloadAssets(Level);
			class'M32GrenadeProjectile'.static.PreloadAssets();
			class'M32Attachment'.static.PreloadAssets();
			break;

		case class'M79GrenadeLauncher':
			class'M79GrenadeLauncher'.static.PreloadAssets(Inv);
			class'M79Fire'.static.PreloadAssets(Level);
			class'M79GrenadeProjectile'.static.PreloadAssets();
			class'M79Attachment'.static.PreloadAssets();
			break;

		case class'GoldenM79GrenadeLauncher':
			class'GoldenM79GrenadeLauncher'.static.PreloadAssets(Inv);
			class'GoldenM79Fire'.static.PreloadAssets(Level);
			class'M79GrenadeProjectile'.static.PreloadAssets();
			class'GoldenM79Attachment'.static.PreloadAssets();
			break;

		case class'M4203AssaultRifle':
			class'M4203AssaultRifle'.static.PreloadAssets(Inv);
			class'M203Fire'.static.PreloadAssets(Level);
			class'M4203BulletFire'.static.PreloadAssets(Level);
			class'M203GrenadeProjectile'.static.PreloadAssets();
			class'M4203Attachment'.static.PreloadAssets();
			break;

		case class'M7A3MMedicGun':
			class'M7A3MMedicGun'.static.PreloadAssets(Inv);
			class'M7A3MFire'.static.PreloadAssets(Level);
			class'M7A3MAltFire'.static.PreloadAssets(Level);
			class'M7A3MHealinglProjectile'.static.PreloadAssets();
			class'M7A3MAttachment'.static.PreloadAssets();
			break;

		case class'M99SniperRifle':
			class'M99SniperRifle'.static.PreloadAssets(Inv);
			class'M99Bullet'.static.PreloadAssets();
			class'M99Fire'.static.PreloadAssets(Level);
			class'M99Attachment'.static.PreloadAssets();
			break;

		case class'MAC10MP':
			class'MAC10MP'.static.PreloadAssets(Inv);
			class'MAC10Fire'.static.PreloadAssets(Level);
			class'MAC10Attachment'.static.PreloadAssets();
			break;

		case class'Magnum44Pistol':
			class'Magnum44Pistol'.static.PreloadAssets(Inv);
			class'Magnum44Fire'.static.PreloadAssets(Level);
			class'Magnum44Attachment'.static.PreloadAssets();
			break;

		case class'MK23Pistol':
			class'MK23Pistol'.static.PreloadAssets(Inv);
			class'MK23Fire'.static.PreloadAssets(Level);
			class'MK23Attachment'.static.PreloadAssets();
			break;

		case class'MKb42AssaultRifle':
			class'MKb42AssaultRifle'.static.PreloadAssets(Inv);
			class'MKb42Fire'.static.PreloadAssets(Level);
			class'MKb42Attachment'.static.PreloadAssets();
			break;

		case class'MP7MMedicGun':
			class'MP7MMedicGun'.static.PreloadAssets(Inv);
			class'MP7MFire'.static.PreloadAssets(Level);
			class'MP7MAltFire'.static.PreloadAssets(Level);
			class'MP7MHealinglProjectile'.static.PreloadAssets();
			class'MP7MAttachment'.static.PreloadAssets();
			break;

		case class'KrissMMedicGun':
			class'KrissMMedicGun'.static.PreloadAssets(Inv);
			class'KrissMFire'.static.PreloadAssets(Level);
			class'KrissMAltFire'.static.PreloadAssets(Level);
			class'KrissMHealingProjectile'.static.PreloadAssets();
			class'KrissMAttachment'.static.PreloadAssets();
			break;

		case class'MP5MMedicGun':
			class'MP5MMedicGun'.static.PreloadAssets(Inv);
			class'MP5MFire'.static.PreloadAssets(Level);
			class'MP5MAltFire'.static.PreloadAssets(Level);
			class'MP5MHealinglProjectile'.static.PreloadAssets();
			class'MP5MAttachment'.static.PreloadAssets();
			break;

		case class'PipeBombExplosive':
			class'PipeBombExplosive'.static.PreloadAssets(Inv);
			class'PipeBombProjectile'.static.PreloadAssets();
			class'PipeBombAttachment'.static.PreloadAssets();
			break;

		case class'SCARMK17AssaultRifle':
			class'SCARMK17AssaultRifle'.static.PreloadAssets(Inv);
			class'SCARMK17Fire'.static.PreloadAssets(Level);
			class'SCARMK17Attachment'.static.PreloadAssets();
			break;

		case class'SealSquealHarpoonBomber':
			class'SealSquealHarpoonBomber'.static.PreloadAssets(Inv);
			class'SealSquealProjectile'.static.PreloadAssets();
			class'SealSquealFire'.static.PreloadAssets(Level);
			class'SealSquealAttachment'.static.PreloadAssets();
			break;

		case class'SeekerSixRocketLauncher':
			class'SeekerSixRocketLauncher'.static.PreloadAssets(Inv);
			class'SeekerSixRocketProjectile'.static.PreloadAssets();
			class'SeekerSixSeekingRocketProjectile'.static.PreloadAssets();
			class'SeekerSixFire'.static.PreloadAssets(Level);
			class'SeekerSixAttachment'.static.PreloadAssets();
			break;

		case class'Trenchgun':
			class'Trenchgun'.static.PreloadAssets(Inv);
			class'TrenchgunBullet'.static.PreloadAssets();
			class'TrenchgunFire'.static.PreloadAssets(Level);
			class'TrenchgunAttachment'.static.PreloadAssets();
			break;

		case class'NailGun':
			class'NailGun'.static.PreloadAssets(Inv);
			class'NailGunFire'.static.PreloadAssets(Level);
			class'NailGunProjectile'.static.PreloadAssets();
			class'NailGunAltFire'.static.PreloadAssets(Level);
			class'NailGunAttachment'.static.PreloadAssets();
			break;

		case class'ThompsonSMG':
			class'ThompsonSMG'.static.PreloadAssets(Inv);
			class'ThompsonFire'.static.PreloadAssets(Level);
			class'ThompsonAttachment'.static.PreloadAssets();
			break;

		case class'ThompsonDrumSMG':
			class'ThompsonDrumSMG'.static.PreloadAssets(Inv);
			class'ThompsonDrumFire'.static.PreloadAssets(Level);
			class'ThompsonDrumAttachment'.static.PreloadAssets();
			break;

		case class'Scythe':
			class'Scythe'.static.PreloadAssets(Inv);
			class'ScytheFire'.static.PreloadAssets();
			class'ScytheFireB'.static.PreloadAssets();
			class'ScytheAttachment'.static.PreloadAssets();
			break;

		case class'SPGrenadeLauncher':
			class'SPGrenadeLauncher'.static.PreloadAssets(Inv);
			class'SPGrenadeFire'.static.PreloadAssets(Level);
			class'SPGrenadeProjectile'.static.PreloadAssets();
			class'SPGrenadeAttachment'.static.PreloadAssets();
			break;

		case class'SPSniperRifle':
			class'SPSniperRifle'.static.PreloadAssets(Inv);
			class'SPSniperFire'.static.PreloadAssets(Level);
			class'SPSniperAttachment'.static.PreloadAssets();
			break;

		case class'SPThompsonSMG':
			class'SPThompsonSMG'.static.PreloadAssets(Inv);
			class'SPThompsonFire'.static.PreloadAssets(Level);
			class'SPThompsonAttachment'.static.PreloadAssets();
			break;

 		case class'Crossbuzzsaw':
			class'Crossbuzzsaw'.static.PreloadAssets(Inv);
			class'CrossbuzzsawFire'.static.PreloadAssets(Level);
			class'CrossbuzzsawBlade'.static.PreloadAssets();
			class'CrossbuzzsawAttachment'.static.PreloadAssets();
			break;

		case class'FlareRevolver':
			class'FlareRevolver'.static.PreloadAssets(Inv);
			class'FlareRevolverFire'.static.PreloadAssets(Level);
			class'FlareRevolverProjectile'.static.PreloadAssets();
			class'FlareRevolverAttachment'.static.PreloadAssets();
			break;

		case class'Deagle':
			class'Deagle'.static.PreloadAssets(Inv);
			class'DeagleFire'.static.PreloadAssets(Level);
			class'DeagleAltFire'.static.PreloadAssets(Level);
			class'DeagleAttachment'.static.PreloadAssets();
			break;

		case class'GoldenDeagle':
			class'GoldenDeagle'.static.PreloadAssets(Inv);
			class'GoldenDeagleFire'.static.PreloadAssets(Level);
			class'GoldenDeagleAltFire'.static.PreloadAssets(Level);
			class'GoldenDeagleAttachment'.static.PreloadAssets();
			break;
	}
}

simulated function ClientWeaponDestroyed(class<Weapon> WClass)
{
	switch ( WClass )
	{
		case class'AA12AutoShotgun':
			if ( class'AA12AutoShotgun'.static.UnloadAssets() )
			{
				class'AA12Fire'.static.UnloadAssets();
				class'AA12Attachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenAA12AutoShotgun':
			if ( class'GoldenAA12AutoShotgun'.static.UnloadAssets() )
			{
				class'GoldenAA12Fire'.static.UnloadAssets();
				class'GoldenAA12Attachment'.static.UnloadAssets();
			}
			break;

		case class'SPAutoShotgun':
			if ( class'SPAutoShotgun'.static.UnloadAssets() )
			{
				class'SPShotgunFire'.static.UnloadAssets();
				class'SPShotgunAltFire'.static.UnloadAssets();
				class'SPShotgunAttachment'.static.UnloadAssets();
			}
			break;

		case class'AK47AssaultRifle':
			if ( class'AK47AssaultRifle'.static.UnloadAssets() )
			{
				class'AK47Fire'.static.UnloadAssets();
				class'AK47Attachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenAK47AssaultRifle':
			if ( class'GoldenAK47AssaultRifle'.static.UnloadAssets() )
			{
				class'GoldenAK47Fire'.static.UnloadAssets();
				class'GoldenAK47Attachment'.static.UnloadAssets();
			}
			break;

		case class'BenelliShotgun':
			if ( class'BenelliShotgun'.static.UnloadAssets() )
			{
				class'BenelliFire'.static.UnloadAssets();
				class'BenelliAttachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenBenelliShotgun':
			if ( class'GoldenBenelliShotgun'.static.UnloadAssets() )
			{
				class'GoldenBenelliFire'.static.UnloadAssets();
				class'GoldenBenelliAttachment'.static.UnloadAssets();
			}
			break;

		case class'Chainsaw':
			if ( class'Chainsaw'.static.UnloadAssets() )
			{
				class'ChainsawFire'.static.UnloadAssets();
				class'ChainsawAltFire'.static.UnloadAssets();
				class'ChainsawAttachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenChainsaw':
			if ( class'GoldenChainsaw'.static.UnloadAssets() )
			{
				class'GoldenChainsawAttachment'.static.UnloadAssets();
			}
			break;

		case class'Crossbow':
			if ( class'Crossbow'.static.UnloadAssets() )
			{
				class'CrossbowArrow'.static.UnloadAssets();
				class'CrossbowFire'.static.UnloadAssets();
				class'CrossbowAttachment'.static.UnloadAssets();
			}
			break;

		case class'FlameThrower':
			if ( class'FlameThrower'.static.UnloadAssets() )
			{
				class'FlameBurstFire'.static.UnloadAssets();
				class'FlameThrowerAttachment'.static.UnloadAssets();
			}
			break;

		case class'BlowerThrower':
			if ( class'BlowerThrower'.static.UnloadAssets() )
			{
				class'BlowerThrowerFire'.static.UnloadAssets();
				class'BlowerThrowerAltFire'.static.UnloadAssets();
				class'BlowerThrowerAttachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenFlameThrower':
			if ( class'GoldenFlameThrower'.static.UnloadAssets() )
			{
				class'GoldenFlameBurstFire'.static.UnloadAssets();
				class'GoldenFTAttachment'.static.UnloadAssets();
			}
			break;

		case class'BoomStick':
			if ( class'BoomStick'.static.UnloadAssets() )
			{
				class'BoomStickFire'.static.UnloadAssets();
				class'BoomStickAltFire'.static.UnloadAssets();
				class'BoomStickAttachment'.static.UnloadAssets();
			}
			break;

		case class'KSGShotgun':
			if ( class'KSGShotgun'.static.UnloadAssets() )
			{
				class'KSGFire'.static.UnloadAssets();
				class'KSGAttachment'.static.UnloadAssets();
			}
			break;

		case class'HuskGun':
			if ( class'HuskGun'.static.UnloadAssets() )
			{
				class'HuskGunFire'.static.UnloadAssets();
				class'HuskGunProjectile'.static.UnloadAssets();
				class'HuskGunAttachment'.static.UnloadAssets();
			}
			break;

		case class'ZEDGun':
			if ( class'ZEDGun'.static.UnloadAssets() )
			{
				class'ZEDGunFire'.static.UnloadAssets();
				class'ZEDGunAltFire'.static.UnloadAssets();
				class'ZEDGunProjectile'.static.UnloadAssets();
				class'ZEDGunAttachment'.static.UnloadAssets();
			}
			break;

		case class'ZEDMKIIWeapon':
			if ( class'ZEDMKIIWeapon'.static.UnloadAssets() )
			{
				class'ZEDMKIIFire'.static.UnloadAssets();
				class'ZEDMKIIAltFire'.static.UnloadAssets();
				class'ZEDMKIIPrimaryProjectile'.static.UnloadAssets();
				class'ZEDMKIISecondaryProjectile'.static.UnloadAssets();
				class'ZEDMKIIAttachment'.static.UnloadAssets();
			}
			break;

		case class'Katana':
			if ( class'Katana'.static.UnloadAssets() )
			{
				class'KatanaFire'.static.UnloadAssets();
				class'KatanaFireB'.static.UnloadAssets();
				class'KatanaAttachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenKatana':
			if ( class'GoldenKatana'.static.UnloadAssets() )
			{
				class'KatanaFire'.static.UnloadAssets();
				class'KatanaFireB'.static.UnloadAssets();
				class'GoldenKatanaAttachment'.static.UnloadAssets();
			}
			break;

		case class'ClaymoreSword':
			if ( class'ClaymoreSword'.static.UnloadAssets() )
			{
				class'ClaymoreSwordFire'.static.UnloadAssets();
				class'ClaymoreSwordFireB'.static.UnloadAssets();
				class'ClaymoreSwordAttachment'.static.UnloadAssets();
			}
			break;

		case class'DwarfAxe':
			if ( class'DwarfAxe'.static.UnloadAssets() )
			{
				class'DwarfAxeFire'.static.UnloadAssets();
				class'DwarfAxeFireB'.static.UnloadAssets();
				class'DwarfAxeAttachment'.static.UnloadAssets();
			}
			break;

		case class'FNFAL_ACOG_AssaultRifle':
			if ( class'FNFAL_ACOG_AssaultRifle'.static.UnloadAssets() )
			{
				class'FNFALFire'.static.UnloadAssets();
				class'FNFAL_ACOG_Attachment'.static.UnloadAssets();
			}
			break;

		case class'LAW':
			if ( class'LAW'.static.UnloadAssets() )
			{
				class'LAWFire'.static.UnloadAssets();
				class'LAWProj'.static.UnloadAssets();
				class'LAWAttachment'.static.UnloadAssets();
			}
			break;

		case class'M14EBRBattleRifle':
			if ( class'M14EBRBattleRifle'.static.UnloadAssets() )
			{
				class'M14EBRFire'.static.UnloadAssets();
				class'M14EBRAttachment'.static.UnloadAssets();
			}
			break;

		case class'M4AssaultRifle':
			if ( class'M4AssaultRifle'.static.UnloadAssets() )
			{
				class'M4Fire'.static.UnloadAssets();
				class'M4Attachment'.static.UnloadAssets();
			}
			break;

		case class'M32GrenadeLauncher':
			if ( class'M32GrenadeLauncher'.static.UnloadAssets() )
			{
				class'M32Fire'.static.UnloadAssets();
				class'M32GrenadeProjectile'.static.UnloadAssets();
				class'M32Attachment'.static.UnloadAssets();
			}
			break;

		case class'M79GrenadeLauncher':
			if ( class'M79GrenadeLauncher'.static.UnloadAssets() )
			{
				class'M79Fire'.static.UnloadAssets();
				class'M79GrenadeProjectile'.static.UnloadAssets();
				class'M79Attachment'.static.UnloadAssets();
			}
			break;

		case class'GoldenM79GrenadeLauncher':
			if ( class'GoldenM79GrenadeLauncher'.static.UnloadAssets() )
			{
				class'GoldenM79Fire'.static.UnloadAssets();
				class'M79GrenadeProjectile'.static.UnloadAssets();
				class'GoldenM79Attachment'.static.UnloadAssets();
			}
			break;

		case class'M4203AssaultRifle':
			if ( class'M4203AssaultRifle'.static.UnloadAssets() )
			{
				class'M4203BulletFire'.static.UnloadAssets();
                class'M203Fire'.static.UnloadAssets();
				class'M203GrenadeProjectile'.static.UnloadAssets();
				class'M4203Attachment'.static.UnloadAssets();
			}
			break;

		case class'M7A3MMedicGun':
			if ( class'M7A3MMedicGun'.static.UnloadAssets() )
			{
				class'M7A3MFire'.static.UnloadAssets();
				class'M7A3MAltFire'.static.UnloadAssets();
				class'M7A3MHealinglProjectile'.static.UnloadAssets();
				class'M7A3MAttachment'.static.UnloadAssets();
			}
			break;

		case class'M99SniperRifle':
			if ( class'M99SniperRifle'.static.UnloadAssets() )
			{
				class'M99Bullet'.static.UnloadAssets();
				class'M99Fire'.static.UnloadAssets();
				class'M99Attachment'.static.UnloadAssets();
			}
			break;

		case class'MAC10MP':
			if ( class'MAC10MP'.static.UnloadAssets() )
			{
				class'MAC10Fire'.static.UnloadAssets();
				class'MAC10Attachment'.static.UnloadAssets();
			}
			break;

		case class'Magnum44Pistol':
			if ( class'Magnum44Pistol'.static.UnloadAssets() )
			{
				class'Magnum44Fire'.static.UnloadAssets();
				class'Magnum44Attachment'.static.UnloadAssets();
			}
			break;

		case class'MK23Pistol':
			if ( class'MK23Pistol'.static.UnloadAssets() )
			{
				class'MK23Fire'.static.UnloadAssets();
				class'MK23Attachment'.static.UnloadAssets();
			}
			break;

		case class'MKb42AssaultRifle':
			if ( class'MKb42AssaultRifle'.static.UnloadAssets() )
			{
				class'MKb42Fire'.static.UnloadAssets();
				class'MKb42Attachment'.static.UnloadAssets();
			}
			break;

		case class'MP7MMedicGun':
			if ( class'MP7MMedicGun'.static.UnloadAssets() )
			{
				class'MP7MFire'.static.UnloadAssets();
				class'MP7MAltFire'.static.UnloadAssets();
				class'MP7MHealinglProjectile'.static.UnloadAssets();
				class'MP7MAttachment'.static.UnloadAssets();
			}
			break;

		case class'KrissMMedicGun':
			if ( class'KrissMMedicGun'.static.UnloadAssets() )
			{
				class'KrissMFire'.static.UnloadAssets();
				class'KrissMAltFire'.static.UnloadAssets();
				class'KrissMHealingProjectile'.static.UnloadAssets();
				class'KrissMAttachment'.static.UnloadAssets();
			}
			break;

		case class'MP5MMedicGun':
			if ( class'MP5MMedicGun'.static.UnloadAssets() )
			{
				class'MP5MFire'.static.UnloadAssets();
				class'MP5MAltFire'.static.UnloadAssets();
				class'MP5MHealinglProjectile'.static.UnloadAssets();
				class'MP5MAttachment'.static.UnloadAssets();
			}
			break;

		case class'PipeBombExplosive':
			if ( class'PipeBombExplosive'.static.UnloadAssets() )
			{
				class'PipeBombProjectile'.static.UnloadAssets();
				class'PipeBombAttachment'.static.UnloadAssets();
			}
			break;

		case class'SCARMK17AssaultRifle':
			if ( class'SCARMK17AssaultRifle'.static.UnloadAssets() )
			{
				class'SCARMK17Fire'.static.UnloadAssets();
				class'SCARMK17Attachment'.static.UnloadAssets();
			}
			break;

		case class'SealSquealHarpoonBomber':
			if ( class'SealSquealHarpoonBomber'.static.UnloadAssets() )
			{
				class'SealSquealFire'.static.UnloadAssets();
				class'SealSquealProjectile'.static.UnloadAssets();
				class'SealSquealAttachment'.static.UnloadAssets();
			}

		case class'SeekerSixRocketLauncher':
			if ( class'SeekerSixRocketLauncher'.static.UnloadAssets() )
			{
				class'SeekerSixFire'.static.UnloadAssets();
				class'SeekerSixRocketProjectile'.static.UnloadAssets();
				class'SeekerSixSeekingRocketProjectile'.static.UnloadAssets();
				class'SeekerSixAttachment'.static.UnloadAssets();
			}

		case class'Trenchgun':
			if ( class'Trenchgun'.static.UnloadAssets() )
			{
				class'TrenchgunFire'.static.UnloadAssets();
				class'TrenchgunBullet'.static.UnloadAssets();
				class'TrenchgunAttachment'.static.UnloadAssets();
			}

		case class'NailGun':
			if ( class'NailGun'.static.UnloadAssets() )
			{
				class'NailGunFire'.static.UnloadAssets();
				class'NailGunProjectile'.static.UnloadAssets();
				class'NailGunAltFire'.static.UnloadAssets();
				class'NailGunAttachment'.static.UnloadAssets();
			}
			break;

		case class'ThompsonSMG':
			if ( class'ThompsonSMG'.static.UnloadAssets() )
			{
				class'ThompsonFire'.static.UnloadAssets();
				class'ThompsonAttachment'.static.UnloadAssets();
			}
			break;

		case class'ThompsonDrumSMG':
			if ( class'ThompsonDrumSMG'.static.UnloadAssets() )
			{
				class'ThompsonDrumFire'.static.UnloadAssets();
				class'ThompsonDrumAttachment'.static.UnloadAssets();
			}
			break;

		case class'Crossbuzzsaw':
			if ( class'Crossbuzzsaw'.static.UnloadAssets() )
			{

				class'CrossbuzzsawFire'.static.UnloadAssets();
				class'CrossbuzzsawBlade'.static.UnloadAssets();
				class'CrossbuzzsawAttachment'.static.UnloadAssets();
			}
			break;

		case class'Scythe':
			if ( class'Scythe'.static.UnloadAssets() )
			{
				class'ScytheFire'.static.UnloadAssets();
				class'ScytheAttachment'.static.UnloadAssets();
			}
			break;

		case class'SPGrenadeLauncher':
			if ( class'SPGrenadeLauncher'.static.UnloadAssets() )
			{
				class'SPGrenadeFire'.static.UnloadAssets();
				class'SPGrenadeProjectile'.static.UnloadAssets();
				class'SPGrenadeAttachment'.static.UnloadAssets();
			}
			break;

		case class'SPSniperRifle':
			if ( class'SPSniperRifle'.static.UnloadAssets() )
			{
				class'SPSniperFire'.static.UnloadAssets();
				class'SPSniperAttachment'.static.UnloadAssets();
			}
			break;

		case class'SPThompsonSMG':
			if ( class'SPThompsonSMG'.static.UnloadAssets() )
			{
				class'SPThompsonFire'.static.UnloadAssets();
				class'SPThompsonAttachment'.static.UnloadAssets();
			}
			break;

		case class'FlareRevolver':
			if ( class'FlareRevolver'.static.UnloadAssets() )
			{
				class'FlareRevolverFire'.static.UnloadAssets();
				class'FlareRevolverProjectile'.static.UnloadAssets();
				class'FlareRevolverAttachment'.static.UnloadAssets();
			}
			break;
	}
}

simulated function WeaponPulloutRemark(int RemarkIndex)
{
	if ( FRand() < 0.10 && Level.TimeSeconds - LastWeaponPulloutMessageTime > WeaponPulloutMessageDelay )
	{
		Speech('AUTO', RemarkIndex, "");
		LastWeaponPulloutMessageTime = Level.TimeSeconds;
	}
}

function JoinedAsSpectatorOnly()
{
	if ( Pawn != None )
		Pawn.Died(self, class'DamageType', Pawn.Location);

	if ( PlayerReplicationInfo.Team != None )
		PlayerReplicationInfo.Team.RemoveFromTeam(self);

	PlayerReplicationInfo.Team = None;
	ServerSpectate();

	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);

	ClientBecameSpectator();
}

// for changing character on the fly (for next respawn)
exec function ChangeCharacter(string newCharacter, optional string inClass)
{
	if ( NewCharacter != "" && CharacterAvailable(newCharacter) )
	{
	    SetPawnClass(string(PawnClass), newCharacter);
		UpdateURL("Character", newCharacter, true);
	    SaveConfig();
	}
}

exec event SetProgressMessage( int Index, string S, color C )
{
	if ( Index < ArrayCount(ProgressMessage) )
	{
		ProgressMessage[Index] = S;
		ProgressColor[Index] = C;
	}

	AddRandomOffset();
}


simulated function AddRandomOffset()
{
	local float MyOffsetX, MyOffsetY;

	MyOffsetX = Rand(30) + 20;
	MyOffsetY = Rand(30) + 20;

	if ( Rand(10) > 5 )
	{
		MyOffsetX *= -1;
	}

	if ( Rand(10) > 5 )
	{
		MyOffsetY *= -1;
	}

	RandXOffset = MyOffsetX;
	RandYOffset = MyOffsetY;
}

simulated function ClientForceCollectGarbage()
{
	ConsoleCommand("obj garbage");
}

simulated function ClientPickedup( KFGrabbable item )
{
   KFSteamStatsAndAchievements(SteamStatsAndAchievements).ZEDPieceGrabbed();
}

simulated function ClientZedsSpawn(int eventNum)
{
   if(eventNum == 0)
   {
       class'KFMonstersCollection'.static.PreLoadAssets();
   }
   else if(eventNum == 2)
   {
       class'KFMonstersHalloween'.static.PreLoadAssets();
   }
   else if(eventNum == 3)
   {
       class'KFMonstersXmas'.static.PreLoadAssets();
   }
}

function bool IsVariantInInventory(class<Pickup> PickupToCheck)
{
    local Inventory CurInv;
    local class<KFWeaponPickup> InvPickupClass;
    local class<KFWeaponPickup> CheckPickupClass;
    local class<KFWeaponPickup> VariantPickupClass;
    local int i;

    for ( CurInv = Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
        if ( CurInv.default.PickupClass == PickupToCheck )
        {
            return true;
        }

        // check if Item is variant of normal inventory item
        InvPickupClass = class<KFWeaponPickup>(CurInv.default.PickupClass);
        if( InvPickupClass != none )
        {
            for( i = 0; i < InvPickupClass.default.VariantClasses.Length; ++i )
            {
                VariantPickupClass = class<KFWeaponPickup>(InvPickupClass.default.VariantClasses[i]);
                if( VariantPickupClass != none && VariantPickupClass == PickupToCheck )
                {
                    return true;
                }
            }
        }

        // check if Item is normal version of variant inventory item
        CheckPickupClass = class<KFWeaponPickup>(PickupToCheck);
        if( CheckPickupClass != none )
        {
            for( i = 0; i < CheckPickupClass.default.VariantClasses.Length; ++i )
            {
                VariantPickupClass = class<KFWeaponPickup>(CheckPickupClass.default.VariantClasses[i]);
                if( VariantPickupClass != none && VariantPickupClass == CurInv.default.PickupClass )
                {
                    return true;
                }
            }
        }
    }

    return false;
}

defaultproperties
{
     BuyListHeaders(0)="My Inventory"
     BuyListHeaders(1)="Melee"
     BuyListHeaders(2)="Power"
     BuyListHeaders(3)="Speed"
     BuyListHeaders(4)="Range"
     BuyListHeaders(5)="Ammo"
     BuyListHeaders(6)="Equipment"
     LibraryListHeaders(0)="BackStory"
     LibraryListHeaders(1)="Equipment"
     LibraryListHeaders(2)="Enemies"
     LobbyMenuClassString="KFGUI.LobbyMenu"
     bPendingLobbyDisplay=True
     YouAreNowPerkString="You are now a '%Perk%'"
     YouWillBecomePerkString="You will become a '%Perk%' at the end of this Wave"
     PerkChangeOncePerWaveString="You can only change your Perk once per Wave"
     PerkFirstLevelUnlockedString="You have unlocked Level 1 of the %x Perk.|To change your active Perk, hit Escape, click Perks, and select a new Perk from the list."
     PerkUnlockedString="You have unlocked a new Perk Level:|%x"
     TraderPathInterval=1.100000
     bWantsTraderPath=True
     bShowHints=True
     bUseTrueWideScreenFOV=True
     bBehindView=True
     CheatClass=Class'KFMod.KFCheatManager'
     MidGameMenuClass="KFGUI.KFInvasionLoginMenu"
     SteamStatsAndAchievementsClass=Class'ROEngine.KFSteamStatsAndAchievements'
     PlayerReplicationInfoClass=Class'KFMod.KFPlayerReplicationInfo'
}
