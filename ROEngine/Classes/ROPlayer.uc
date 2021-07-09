//=============================================================================
// ROPlayer
//=============================================================================
// PlayerController class used by Red Orchestra
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2006 Tripwire Interactive LLC
// Created by John Gibson
// Additional code Erik Christensen
//=============================================================================

class ROPlayer extends xPlayer;

//=============================================================================
// Variables
//=============================================================================

var		int								DesiredRole;		// Role the player wants to be
var		int								CurrentRole;		// Role the player is currently
var		int								PrimaryWeapon;		// Stores the weapon selections
var		int								SecondaryWeapon;
var		int								GrenadeWeapon;
var		bool							bWeaponsSelected;	// Player has all weapons selected?

var		int								NumVotes;			// Votes cast against this player
var		float							LastVoteTime;
var		array<PlayerReplicationInfo>	VotedBy;

var		bool							bCanRespawn;		// Added to prevent ability to respawn immediately after dying

var     bool                            bPendingMapDisplay;
var     bool                            bFirstRoleAndTeamChange;   // hax? used to detect first time player joins the game (to show map updated icon)
var		bool							bFirstObjectiveScreenDisplayed;
var 	config    	bool  				bShowMapOnFirstSpawn; // Whether or not we want to display the overhead map on the first spawn
var 	config    	bool  				bUseNativeRoleNames;  // Use the old native role names instead of translated role names

// Variables for fade-from-black effect
var     bool                            bDisplayedRoleSelectAtLeastOnce; // Used to do that nifty fade-from-black-after-joining-game effect
var     bool                            bDoFadeFromBlackEffect;
var     float                           FadeFromBlackCurrentOpacity;
var     float                           FadeFromBlackFadeSpeed;
var     float                           FadeFromBlackLastUpdateTime;

// spectating
enum ESpectatorMode
{
	SPEC_Self,
	SPEC_Roaming,
	SPEC_Players,
	SPEC_ViewPoints,
};
var		ESpectatorMode					SpecMode;			// The current view mode when spectating
var		byte							CurrentEntryCam;	// Stores the camera the players is currently viewing from in PlayerWaitng state
var		float							LastSpectateChangeTime; // used to limit how often the player can switch spectate view. Prevents the player from spamming the server

var	localized string 					SpectatingModeName[4]; // localized description of this spectating mode


// Free Aim Area variables

// new free-aim
var		rotator		RecoilRotator;					// Stores recoil added to the free-aim buffer
var		float		LastRecoilTime;                 // Last time we got recoil
var		float		RecoilSpeed;					// The amount of time it will take to process this recoil
var		int			FreeAimMaxYawLimit;				// Maximum yaw rotation of the weapon in free-aim mode
var		int			FreeAimMinYawLimit;             // Minimum yaw rotation of the weapon in free-aim mode
var		int			FreeAimMaxPitchLimit;           // Maximum pitch rotation of the weapon in free-aim mode
var		int			FreeAimMinPitchLimit;           // Minimum pitch rotation of the weapon in free-aim mode

var		float		FAAWeaponRotationFactor;		// FA rotation factor for weapons in their buffer box
var		float		LastFreeAimSuspendTime;			// Used in smoothing out transitions to/from free-aim

var		int 		YawTweenRate;					// Yaw return to center speed when not using free-aim  = FreeAimMaxYawLimit/NumSecondsToTween(0.25)
var		int 		PitchTweenRate;                 // Pitch return to center speed when not using free-aim  = FreeAimMaxPitchLimit/NumSecondsToTween(0.25)

// Weapon Sway
var		bool		bSway;	                        // Weapon sway is enabled
var     float       baseSwayYawAcc;                 // base rate of vertical sway acc
var     float       baseSwayPitchAcc;               // base rate of horizontal sway acc
var     float       SwayPitch;
var     float       SwayYaw;
var     float       WeaponSwayYawRate;
var     float       WeaponSwayPitchRate;
var     float       SwayTime;
var()	InterpCurve	SwayCurve;		 				// The amount of sway to apply based on an input time in ironsights
var 	float		SwayClearTime;
const   SwayElasticFactor = 3.0; 					// is ( 0.002 *   baseSwayYawAcc)
const   SwayDampingFactor = 0.1732;					// dampingFactor = 0.1*sqrt(elasticFactor); // underdamped damping, smoother sway; 0.5*sqrt(elasticFactor) is critically damped

var(Menu)	string	        ROMidGameMenuClass;		// Menu that is shown when Escape is pressed
//var ROCampaignData CampaignData;
var()       config int      GlobalDetailLevel;
var         int             ForcedTeamSelectOnRoleSelectPage;   // -5 == none, -1 = spectator

var vector SavedArtilleryCoords;					// The vector location saved for an artillery

// for switching roles
var     int        	DesiredPrimary;
var     int        	DesiredSecondary;
var     int        	DesiredGrenade;

// Motion blur
var		float		CurrentBlurAmount;				// how much we are blurred currently
var		float		CurrentFadeAmount;				// how much we are blurred currently
var		float		InitialBlurTime;  				// Saves the current blur time
var 	MotionBlur	ShellShockBlur;   				// The motion blur effect
var config    bool  bUseBlurEffect;   				// Wether or not the blur effect should be used
var		byte		AltBlurLevel;
var()	byte		MaxAltBlurLevel;  				// The max amount we want to darken the screen for the alternative blur effect

// Rally point vars
var	    float		LastRallyTime; 					// The last time this controller set a rally point

var	    float		LastPlayerListTime; 			// The last time this player requested the player list (limits how often the player can request the player list so they don't spam the server)

// Destroyable static meshes array
var     array<RODestroyableStaticMeshBase>      Destroyables;

// This is to capture mouse input on the situation map
var     bool        bHudCapturesMouseInputs;
var     bool        bHudLocksPlayerRotation;
var     vector      PlayerMouse;

// For hint management
var     ROHintManager   HintManager;
var     config  bool    bShowHints;

// Vehicle driving
var()	float			ThrottleChangeRate;  		// How quickly to raise/lower the interpolated throttle
var		config bool		bInterpolatedTankThrottle;  // Use an interpolated throttle for tanks. Will gradually increase the throttle while the forward/reverse buttons are pressed instead of the standard all or nothing throttle
var		config bool		bInterpolatedVehicleThrottle;// Use an interpolated throttle for non tank vehicles. Will gradually increase the throttle while the forward/reverse buttons are pressed instead of the standard all or nothing throttle
var     config bool     bManualTankShellReloading;   // Turn on/off automatic tank shell reloading(when off, allows for selection of ammo before loading round)

// Music settings
var     config bool     bDisableMusicInGame;

// Jarring
var     float           JarrMoveMag;                 // Magnitude to move the player
var     float           JarrMoveRate;                // Rate at which the player oscillates
var     float           JarrMoveDuration;            // scalar duration of the movement
var     float           JarrRotateMag;               // Magnitude the player 'rolls'
var     float           JarrRotateRate;              // Rate at which the player oscillates/rolls around
var     float           JarrRotateDuration;          // scalar duration of the roll

// Kill Info
var     ROPlayerReplicationInfo     LastFFKiller;       // PRI of the last person who TKed you
var     float                       LastFFKillAmount;   // The amount that the last person that TKed you was penalized(used to reverse the penalty in the Forgive system)


//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (bNetOwner && Role == ROLE_Authority)
		AddHudDeathMessage;

	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		bWeaponsSelected, DesiredRole, SpecMode, SavedArtilleryCoords;

	// client to server functions
	reliable if (Role < ROLE_Authority)
		ServerLeanRight, ServerLeanLeft,
		ChangeRole, ChangeWeapons, ServerThrowMGAmmo, ServerRemoveWeapon,
		GetNorthDirection, ServerSaveArtilleryPosition,
		ServerSaveRallyPoint, ServerSaveRallyPointFromHud, ServerRequestDeadSpectating,
        ServerChangePlayerInfo, xServerSpeech, ServerCancelBehindview, ServerVerifyTeamVOIP,
		ServerListPlayers, ServerInfoQuery, ServerSetManualTankShellReloading;

	// unreliable client to server functions
	unreliable if (Role < ROLE_Authority)
		ServerChangeSpecMode, ServerNextViewPoint, SendVehicleVoiceMessage,
		ServerVehicleSay, VehicleMessage, ServerRequestPOVChange,
        ServerAutoSelectAndChangeTeam;

    //server to client functions
    reliable if (Role == ROLE_Authority)
		ClientLocationalVoiceMessage, SendNorthDirection, NotifyOfMapInfoChange,
        ClientChangePlayerInfoResult, ClientForcedTeamChange, PlayerJarred;
}

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// Empty
//-----------------------------------------------------------------------------

exec function CycleLoadout() {}
exec function ChangeLoadout(string LoadoutName) {}
simulated function PrecacheAnnouncements() {}
exec function Taunt(name Sequence) {}
exec function RandomTaunt() {}
function ServerTaunt(name AnimName) {}
function ServerSetAutoTaunt(bool Value) {}
exec function SetAutoTaunt(bool Value) {}
exec function L33TPhrase(int phraseNum) {} // No l33t players, kthnx :)
function AwardAdrenaline(float amount) {}
function LogMultiKills(float Reward, bool bEnemyKill) {}
function bool AutoTaunt() { return false; }
function bool DontReuseTaunt(int T) { return true; }
exec function DropFlag() {}
function ServerDropFlag() {}
exec function SetVoice(coerce string S) {}
function ServerChangeLoadout(string LoadoutName) {}
function PlayStartupMessage(byte StartupStage) {}
simulated function ClientReceiveLoginMenu(string MenuClass, bool bForce) {}
exec function PlayVehicleHorn( int HornIndex ){}

exec function InfoQuery()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	log("*********************Client***********************");
	ServerInfoQuery();
}

function ServerInfoQuery()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	log("*********************Server***********************");
}

// Implemented in certain states to switch between first and third person spectating
function HandlePOVChange(){}
function ServerRequestPOVChange()
{
	HandlePOVChange();
}
// Implemented in the dead state to switch to dead spectating mode
function ServerRequestDeadSpectating(){}

// When the client has requested a switch to behindview right before they spawn, the server can
// get the call before they spawn, but the return call to the client to switch the view can
// arrive after they spawn. When this happens, this is called to reset the user to not be in
// behindview on the server
function ServerCancelBehindview()
{
	bBehindview=false;
}

simulated function NotifySpeakingInTeamChannel()
{
	local int idx;
	local VoiceChatRoom VCR;

	if (VoiceReplicationInfo == None || !VoiceReplicationInfo.bEnableVoiceChat )
		return;

	if (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
		idx = PlayerReplicationInfo.Team.TeamIndex;

	// Check that we are a member of this room
	VCR = VoiceReplicationInfo.GetChannel("Team", idx);
	if (VCR == None)
	{
		return;
	}

	if (VCR.ChannelIndex >= 0)
	{
		//log("Client calling ServerVerifyTeamVOIP");
		ServerVerifyTeamVOIP(VCR.ChannelIndex);
	}
}

function ServerVerifyTeamVOIP(int TeamChannel)
{
	local VoiceChatRoom VCR;
	local int Index;

	//log(PlayerReplicationinfo.PlayerName$" ServerVerifyTeamVOIP");

	if (VoiceReplicationInfo == None)
		return;

	VCR = VoiceReplicationInfo.GetChannelAt(TeamChannel);
	if ( VCR == None )
	{
		return;
	}

	if ( !VCR.IsMember(PlayerReplicationInfo) )
	{
		//log(PlayerReplicationinfo.PlayerName$" ServerVerifyTeamVOIP");

		if ( ServerJoinVoiceChannel(TeamChannel, "") != JCR_Success )
			return;

		//log(PlayerReplicationinfo.PlayerName$" ServerVerifyTeamVOIP Set the player to the right channel");
	}

    //log(PlayerReplicationinfo.PlayerName$" ServerVerifyTeamVOIP probably in the right channel");

	if (ActiveRoom != VCR)
	{
		ActiveRoom = VCR;
		ClientSetActiveRoom(VCR.ChannelIndex);
		Index = VCR.ChannelIndex;

		if ( PlayerReplicationInfo != None )
			PlayerReplicationinfo.ActiveChannel = VCR.ChannelIndex;
	}
}

// this is used to build a list of destroyable static meshes in the level.
// that list is used in ROHud to draw destroyed/destroyable targets on the map
simulated event PostBeginPlay()
{
    local RODestroyableStaticMeshBase D;

	// Avoid calling all that Announcer crap
    super(PlayerController).PostBeginPlay();

    // Build destroyable actors reference list
    foreach DynamicActors(class'RODestroyableStaticMeshBase', D)
        if (D.bShowOnSituationMap)
            Destroyables[Destroyables.Length] = D;

    // Spawn hint manager (if needed)
    UpdateHintManagement(bShowHints);
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if ( Role < ROLE_Authority )
        ServerSetManualTankShellReloading(bManualTankShellReloading);
}

event ClientReset()
{
    local Actor A;

	// Reset client special timed sounds on the client
	foreach AllActors(class'Actor', A)
	{
		if( A.IsA('ClientSpecialTimedSound') )
            A.Reset();
        else if( A.IsA('KrivoiPlaneController') )
            A.Reset();
	}

    super.ClientReset();
}


//Overridden to allow a setting that doesn't play music in game
function ClientSetMusic(string NewSong, EMusicTransition NewTransition)
{
    if ( !bDisableMusicInGame || Level.ZoneTag == 'ROEntry' )
        super.ClientSetMusic(NewSong, NewTransition);
}

// Overriden to get rid of some terrible UT2k4 VOIP behavior
function ServerSpeak(int ChannelIndex, optional string ChannelPassword)
{
	local VoiceChatRoom VCR;
	local int Index;//, IndexTwo;

	if (VoiceReplicationInfo == None)
		return;

	VCR = VoiceReplicationInfo.GetChannelAt(ChannelIndex);
	if ( VCR == None )
	{
		if ( VoiceReplicationInfo.bEnableVoiceChat )
			ChatRoomMessage(0, ChannelIndex);

		else ChatRoomMessage(15, ChannelIndex);
		return;
	}

	if ( !VCR.IsMember(PlayerReplicationInfo) )
	{
		if ( ServerJoinVoiceChannel(ChannelIndex, ChannelPassword) != JCR_Success )
			return;
	}

	Index = -1;
	if (ActiveRoom == VCR)
	{
//      	if ( (VCR.GetTitle() ~= "Public") )
//      	{
//      		if (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
//				IndexTwo = PlayerReplicationInfo.Team.TeamIndex;
//
//			// Just put us back in the team channel if we leave public
//			VCR = VoiceReplicationInfo.GetChannel("Team", IndexTwo);
//
//			if( VCR != none )
//			{
//				ActiveRoom = VCR;
//				ClientSetActiveRoom(VCR.ChannelIndex);
//				Index = (VCR.ChannelIndex);
//				ClientMessage( ChatRoomMessageClass.static.AssembleMessage(9, VCR.GetTitle(), PlayerReplicationInfo) );
//			}
//			else
//			{
//				ChatRoomMessage(0, ChannelIndex);
//				Index = -1;
//				ActiveRoom = None;
//				ClientSetActiveRoom(-1);
//			}
//      	}
//      	else
//      	{

			// This is gay, don't leave the channel if we press that channels button again FFS
	//		ChatRoomMessage(10, ChannelIndex);
	//		log(PlayerReplicationInfo.PlayerName@"no longer speaking on "$VCR.GetTitle(),'VoiceChat');
	//		ActiveRoom = None;
	//		ClientSetActiveRoom(-1);
			if ( (VCR.GetTitle() ~= "Team") || (VCR.GetTitle() ~= "Public") || (VCR.GetTitle() ~= "Local") )
			{
				ClientMessage( ChatRoomMessageClass.static.AssembleMessage(1, VCR.GetTitle(), PlayerReplicationInfo) );
			}

			return;
//		}

	}
	else
	{
		ActiveRoom = VCR;
		log(PlayerReplicationInfo.PlayerName@"speaking on"@VCR.GetTitle(),'VoiceChat');
		ChatRoomMessage(9, ChannelIndex);
		ClientSetActiveRoom(VCR.ChannelIndex);
		Index = VCR.ChannelIndex;

		if ( (VCR.GetTitle() ~= "Team") || (VCR.GetTitle() ~= "Public") || (VCR.GetTitle() ~= "Local") )
		{
			ClientMessage( ChatRoomMessageClass.static.AssembleMessage(9, VCR.GetTitle(), PlayerReplicationInfo) );
		}
	}

	if ( PlayerReplicationInfo != None )
		PlayerReplicationinfo.ActiveChannel = Index;
}

exec function ListPlayers()
{
	if( Level.TimeSeconds - LastPlayerListTime > 1.0 )
	{
   	   	LastPlayerListTime = Level.TimeSeconds;
	   	ServerListPlayers();
   	}
}

function ServerListPlayers()
{
	local array<PlayerReplicationInfo> AllPRI;
	local int i;

    if( Level.TimeSeconds - LastPlayerListTime < 0.9 )
    {
    	return;
    }

    LastPlayerListTime = Level.TimeSeconds;

	// Get the list of players to kick by showing their PlayerID
	Level.Game.GameReplicationInfo.GetPRIArray(AllPRI);
	for (i = 0; i<AllPRI.Length; i++)
	{
		if( PlayerController(AllPRI[i].Owner) != none && AllPRI[i].PlayerName != "WebAdmin")
		{
			//log(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName@" "$PlayerController(AllPRI[i].Owner).GetPlayerIDHash());
			ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName@" "$PlayerController(AllPRI[i].Owner).GetPlayerIDHash());
		}
		else
		{
			//log(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName);
			ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName);
		}
	}
}

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

    if (!bDoNotTurnOffFadeFromBlackEffect)
        bDoFadeFromBlackEffect = false;

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

//TEMP END

// emh: remove 'exec' from this line
/*
exec function StartFadeFromBlackEffect()
{
    FadeFromBlackCurrentOpacity = 1.0;
    FadeFromBlackLastUpdateTime = Level.TimeSeconds;
    postfxon(2);
    postfxbw(FadeFromBlackCurrentOpacity, true);
    bDoFadeFromBlackEffect = true;
}*/

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;
	local vector AttackLoc;

//	log("Notifytakehit is screwing us");
//	return;

	super(Controller).NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	// Don't damageshake in vehicles till we figure out why it is messing our view up - Ramm
	if( Vehicle(Pawn) == none )
	{
		DamageShake(Damage);
	}

	iDam = Clamp(Damage,0,250);
	if ( InstigatedBy != None )
		AttackLoc = InstigatedBy.Location;

	NewClientPlayTakeHit(AttackLoc, hitLocation - Pawn.Location, iDam, damageType);
}

simulated event RenderOverlays( Canvas Canvas )
{
	if((!bUseBlurEffect || !PostFX_IsReady()) && BlurTime > 0)
 	{
		Canvas.DrawColor.A = Min(MaxAltBlurLevel,AltBlurLevel) * (BlurTime/InitialBlurTime);
    	Canvas.Style = ERenderStyle.STY_Alpha;

    	Canvas.SetPos(0,0);
    	//Canvas.DrawTile( texture'Engine.BlackTexture', Canvas.SizeX, Canvas.SizeY, 0.0, 0.0, texture'Weapons1st_tex.zoomblur10'.USize, texture'Weapons1st_tex.zoomblur10'.VSize );
 	}

    if (bDoFadeFromBlackEffect)
    {
        FadeFromBlackCurrentOpacity -= (Level.TimeSeconds - FadeFromBlackLastUpdateTime) * FadeFromBlackFadeSpeed;
        FadeFromBlackLastUpdateTime = Level.TimeSeconds;
        if (FadeFromBlackCurrentOpacity < 0)
            postfxoff(2);
        else
            postfxbw(FadeFromBlackCurrentOpacity, true);
    }
}

// Overridden to support our autotrace select/use system
function ServerUse()
{
    local Actor A;
	local Vehicle DrivenVehicle, EntryVehicle;

	if ( Role < ROLE_Authority )
		return;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }

    if (Pawn == None || !Pawn.bCanUse)
        return;

	DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
	{
		DrivenVehicle.KDriverLeave(false);
		return;
	}

    if( ROPawn(Pawn).AutoTraceActor != none )
    {
    	if( ROVehicle(ROPawn(Pawn).AutoTraceActor) != none )
    	{
			EntryVehicle = ROVehicle(ROPawn(Pawn).AutoTraceActor).FindEntryVehicle(Pawn);
        	if (EntryVehicle != None && EntryVehicle.TryToDrive(Pawn))
            	return;
    	}
    	else
    	{
			ROPawn(Pawn).AutoTraceActor.UsedBy( Pawn );
			return;
		}
    }

    // Send the 'DoUse' event to each actor player is touching.
    foreach Pawn.TouchingActors(class'Actor', A)
    {
        if( !A.bCanAutoTraceSelect )
			A.UsedBy(Pawn);
    }

	if ( Pawn.Base != None )
		Pawn.Base.UsedBy( Pawn );
}
//-----------------------------------------------------------------------------
// Crappy test execs - Remove later - Ramm
//-----------------------------------------------------------------------------
/*
exec function HitBone()
{
	local name HitBone;     	//the bone that was hit
	local float HitBoneDist;    //the dist to bone that was hit
	local vector X,Y,Z;

	local Vector End, HitLocation, HitNormal, Start ;
	local Actor Other;
	local vector LocDir, HitDir;
	local float HitAngle,Side;

	Start = Pawn.Location + Pawn.EyePosition();
	End = Start + 500 * vector(Pawn.Rotation);


	Other = Trace(HitLocation, HitNormal, End, Start, true);

    //log("Location = "$Location);
    //log("Vector(Rotation) = "$Vector(Rotation));
    LocDir = vector(Other.Rotation);
    Spawn(class 'RODebugTracer',self,,Other.Location,Rotator(LocDir));
    LocDir.Z = 0;
    HitDir =  Hitlocation - Other.Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));


    HitAngle*=50;

    GetAxes(Other.Rotation,X,Y,Z);
    Side = Y dot HitDir;
    log("Side = "$Side);

    if( side >= 0)
    {
       HitAngle = 360 + (HitAngle* -1);//+= 180;
    }

    log("HitAngle = "$HitAngle);

     //Spawn(class 'RODebugTracer',self,,Hitlocation,Rotator(HitDir));
    Spawn(class 'RODebugTracerGreen',self,,Hitlocation,Rotator(HitDir));


    //log("Momentum = "$Momentum);
    log("Other = "$Other);

	HitBone = Other.GetClosestBone(HitLocation, vector(Pawn.Rotation), HitBoneDist); //, 'spine', 0.1);

	log("Hitbone = "$Hitbone);
}

exec function TestAngle()
{
    	local vector X,Y,Z;
	local Vector End, HitLocation, HitNormal, Start ;
    	local Actor Other;
 	local vector LocDir, HitDir;
	local float HitAngle, Inangle;

    	Start = Pawn.Location + Pawn.EyePosition();
    	End = Start + 500 * vector(Rotation);

        Other = Trace(HitLocation, HitNormal, End, Start, true);

    LocDir = vector(Other.Rotation);
    Spawn(class 'RODebugTracer',self,,Other.Location,Rotator(LocDir));
    LocDir.Z = 0;
    HitDir =  Hitlocation - Other.Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

    //Spawn(class 'RODebugTracerGreen',self,,Hitlocation,Rotator(-HitNormal));

    GetAxes(Other.Rotation,X,Y,Z);

    //Y.X = 0.0;
    HitDir = Hitlocation - Other.Location;
    //HitDir.X=0.0;

    InAngle= Acos(Normal(HitDir) dot Normal(Z));

    log("InAngle = "$InAngle);

    //log("PN= "$(12-((Fmin(InAngle,1.5)/1.5)*12)));


     //Spawn(class 'RODebugTracer',self,,Hitlocation,Rotator(HitDir));
    Spawn(class 'RODebugTracerGreen',self,,Hitlocation,Rotator(-HitDir));


    //log("Momentum = "$Momentum);
    log("Other = "$Other);
}
 */

 /*
exec function SpawnPronePawn()
{
	local ROPawn p;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	p = Spawn( class 'ROPawn',,,Pawn.Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
 	p.setphysics(PHYS_Falling);
    p.bWantsToProne = true;
}

exec function SpawnPawn()
{
	local ROPawn p;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	p = Spawn( class 'ROPawn',,,Pawn.Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );

	p.LoopAnim('stand_idlehip_kar');

	p.setphysics(PHYS_Falling);
}

exec function SpawnRunningPawn()
{
	local ROPawn p;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	p = Spawn( class 'ROPawn',,,Pawn.Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );

	p.LoopAnim('stand_sprintF_kar');
}

exec function ToggleXHair()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	if ( myHUD.bCrosshairShow )
	{
		myHUD.bCrosshairShow = false;
	}
	else
	{
		// return to normal
		myHUD.bCrosshairShow = true;
	}
}   */

exec function Fade(float time)
{
	ROHud(MyHud).FadeToBlack(time, false);
}

exec function ShowDebugMap()
{
    ROHud(myHUD).bShowDebugInfoOnMap = !ROHud(myHUD).bShowDebugInfoOnMap;
}

exec function ShowNetDebugMap(optional int DebugMode)
{
    ROHud(myHUD).bShowRelevancyDebugOnMap = !ROHud(myHUD).bShowRelevancyDebugOnMap;

    if( ROHud(myHUD).bShowRelevancyDebugOnMap )
        ROHud(myHUD).SetNetDebugMode(DebugMode);
}

exec function ShowNetDebugOverlay(optional int DebugMode)
{
    ROHud(myHUD).bShowRelevancyDebugOverlay = !ROHud(myHUD).bShowRelevancyDebugOverlay;

    if( ROHud(myHUD).bShowRelevancyDebugOverlay )
        ROHud(myHUD).SetNetDebugMode(DebugMode);
}

/*
simulated exec function HitPoint()
{
   HitPointCheck();
}

function HitPointCheck()
{
 	local actor HitActor;
	local vector HitLocation, HitNormal, StartTrace;
	local int TraceDist;
	local rotator AimRot;
	local array<int> HitPoints;
	local rotator myrot;
	local ROPawn ROP;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	myrot = rotation;

	MyRot.Roll += 16384;

  	TraceDist = GetMaxViewDistance();
  	StartTrace = Pawn.Location + Pawn.EyePosition();
  	AimRot = Rotation;

	ClearStayingDebugLines();
//	DrawStayingDebugLine( StartTrace, StartTrace + TraceDist*vector(AimRot),0, 255, 0);


	HitActor = HitPointTrace(HitLocation,HitNormal,StartTrace + TraceDist*vector(AimRot),HitPoints,StartTrace);

     ROP = ROPawn(HitActor);

    if( ROP != none )
    	ROP.ProcessLocationalDamage(0, Pawn, HitLocation, StartTrace + TraceDist*vector(AimRot), class'DamageType',HitPoints);
	//Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,AimRot);

	log("HitPoints.Length = "$HitPoints.Length);

}

exec function ClearLines()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	ClearStayingDebugLines();
} */

/*
exec function RegularTrace()
{
 	local actor HitActor;
	local vector HitLocation, HitNormal, StartTrace;
	local int TraceDist;
	local ROGameReplicationInfo GRI;
	local rotator AimRot;
	local array<int> HitPoints;
	local rotator myrot;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;


	myrot = rotation;

	MyRot.Roll += 16384;

  	TraceDist = GetMaxViewDistance();
  	StartTrace = Pawn.Location + Pawn.EyePosition();
  	AimRot = Rotation;

	ClearStayingDebugLines();
	DrawStayingDebugLine( StartTrace, StartTrace + TraceDist*vector(AimRot),0, 255, 0);


	HitActor = Trace(HitLocation,HitNormal,StartTrace + TraceDist*vector(AimRot),StartTrace,true);

	Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,AimRot);
}*/

/*
exec function DotTest()
{
	local pawn Victims;
	local vector dir, lookdir, RadiusHitLocation;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	foreach VisibleCollidingActors( class 'Pawn', Victims, 50000 ) //, RadiusHitLocation
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( Victims != Pawn)
		{
			lookdir = Normal(Vector(Rotation));
			DrawStayingDebugLine(Pawn.Location, Pawn.Location + lookdir * 100, 0,255,0);
			dir = Normal(Victims.Location - Pawn.Location);
			DrawStayingDebugLine(Pawn.Location, Pawn.Location + dir * 100, 0,0,255);

			log("We are "$(Vsize(Victims.Location - Pawn.Location)/60)$" Meters apart");

           	log(Instigator$" dot "$Victims$" = "$lookdir dot dir);
		}
	}
}*/

//-----------------------------------------------------------------------------
// End Crappy test execs
//-----------------------------------------------------------------------------

simulated exec function DriverCollisionDebug()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	if( ROHud(myHUD).bDebugDriverCollision )
	{
		ROHud(myHUD).bDebugDriverCollision = false;
	}
	else
	{
		ROHud(myHUD).bDebugDriverCollision = true;
	}
}

simulated exec function PlayerCollisionDebug()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	if( ROHud(myHUD).bDebugPlayerCollision )
	{
		ROHud(myHUD).bDebugPlayerCollision = false;
	}
	else
	{
		ROHud(myHUD).bDebugPlayerCollision = true;
	}
}

simulated exec function ROIronSights()
{
	if( Pawn != none && Pawn.Weapon != none)
	{
		Pawn.Weapon.ROIronSights();
	}
}

// Save the rally point vector
simulated function SaveRallyPoint()
{
	ServerSaveRallyPoint();
}

/* =================================================================================== *
* ServerSaveArtilleryPosition()
* 	Sends out a trace to find the saved artillery coordinates, then verifies that
* 	the coordinates are in a valid location. Sends a confirmation or denial
*	message to the player. Client calls this function on the server.
*
* modified by: Ramm 10/21/04
* =================================================================================== */
function ServerSaveRallyPoint()
{
	local actor HitActor;
	local vector HitLocation, HitNormal, StartTrace;
	local int TraceDist;
	local rotator AimRot;
    local ROPlayerReplicationInfo PRI;

	if( (Level.TimeSeconds - LastRallyTime) < ROTeamGame(Level.Game).LevelInfo.RallyPointInterval )
	{
		// Dont spam rally point messages
		ReceiveLocalizedMessage(class'RORallyMsg', 2, PlayerReplicationInfo);
		return;
	}

    // Only leaders can set rally points!
    PRI = ROPlayerReplicationInfo(PlayerReplicationInfo);
    if (PRI == none || PRI.RoleInfo == none || !PRI.RoleInfo.bIsLeader)
        return;

	// if you don't have binocs can't save rally points
	if ( Pawn.Weapon != none && Pawn.Weapon.IsA('BinocularsItem' ))
	{
	  	TraceDist = GetMaxViewDistance();
	  	StartTrace = Pawn.Location + Pawn.EyePosition();
	  	AimRot = Rotation;
	}
 	else if( Pawn.IsA('ROVehicleWeaponPawn') )
	{
		TraceDist = GetMaxViewDistance();
		AimRot = ROVehicleWeaponPawn(Pawn).CustomAim;
		StartTrace = ROVehicleWeaponPawn(Pawn).GetViewLocation() + 500 * vector(AimRot);
	}
	else
	{
	   return;
	}

	//StartTrace = Pawn.Location + Pawn.EyePosition();
	HitActor = trace(HitLocation,HitNormal,StartTrace + TraceDist*vector(AimRot),StartTrace,true);

    ServerSaveRallyPointNoTrace(HitLocation);
}

// Get the maximum possible view distance for this level
simulated function float GetMaxViewDistance()
{
	switch (Level.ViewDistanceLevel)
	{
    	case VDL_Default_1000m:
            return 65536;
    		break;

    	case VDL_Medium_2000m:
            return 131072;
    		break;

    	case VDL_High_3000m:
            return 196608;
    		break;

    	case VDL_Extreme_4000m:
            return 262144;
    		break;

    	default:
            return 65536;
	}
}

function ServerSaveRallyPointFromHud(vector RallyLocation)
{
    local ROPlayerReplicationInfo PRI;

    // Only leaders can set rally points!
    PRI = ROPlayerReplicationInfo(PlayerReplicationInfo);
    if (PRI == none || PRI.RoleInfo == none || !PRI.RoleInfo.bIsLeader)
        return;

    if( (Level.TimeSeconds - LastRallyTime) < ROTeamGame(Level.Game).LevelInfo.RallyPointInterval )
	{
		// Dont spam rally point messages
		ReceiveLocalizedMessage(class'RORallyMsg', 2, PlayerReplicationInfo);
		return;
	}

	ServerSaveRallyPointNoTrace(RallyLocation);
}

function ServerSaveRallyPointNoTrace(vector RallyLocation)
{
    local ROGameReplicationInfo GRI;

	GRI = ROGameReplicationInfo(GameReplicationInfo);

	// Rally point saved for yourself
    ReceiveLocalizedMessage(class'RORallyMsg', 0, PlayerReplicationInfo);

	// Tell the rest of the team the rally point is saved.
	BroadcastLocalizedMessage(class'RORallyMsg', 1, PlayerReplicationInfo);

	// Set this as the last rally point time
	LastRallyTime = Level.TimeSeconds;

 	GRI.AddRallyPoint(PlayerReplicationInfo, RallyLocation);

 	// Notify teammates that map has been updated
 	if (PlayerReplicationInfo.Team != none)
 	    ROTeamGame(Level.Game).NotifyPlayersOfMapInfoChange(PlayerReplicationInfo.Team.TeamIndex, self);
}

/* =================================================================================== *
* ServerSaveArtilleryPosition()
* 	Sends out a trace to find the saved artillery coordinates, then verifies that
* 	the coordinates are in a valid location. Sends a confirmation or denial
*	message to the player. Client calls this function on the server.
*
* modified by: Ramm 10/21/04
* =================================================================================== */
function ServerSaveArtilleryPosition()
{
	local actor HitActor;
	local vector HitLocation, HitNormal, StartTrace;
	local ROGameReplicationInfo GRI;
	local int TraceDist;
	local ROVolumeTest RVT;
	local rotator AimRot;
	local ROPlayerReplicationInfo PRI;
	local bool bFoundARadio;
	local int i;

    GRI = ROGameReplicationInfo(GameReplicationInfo);

    // Only leaders can set rally points!
    PRI = ROPlayerReplicationInfo(PlayerReplicationInfo);
    if (PRI == none || PRI.RoleInfo == none || !PRI.RoleInfo.bIsLeader)
        return;

	// If a player tries to mark artillery on a level with no arty for their team, give them a message
	if ( PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX )
	{
	    for ( i = 0; i < ArrayCount(GRI.AlliedRadios); i++)
		{
			if(GRI.AlliedRadios[i] != none)
			{
				bFoundARadio = true;
				break;
			}
		}
	}
	else if ( PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX )
	{
	    for ( i = 0; i < ArrayCount(GRI.AxisRadios); i++)
		{
			if(GRI.AxisRadios[i] != none)
			{
				bFoundARadio = true;
				break;
			}
		}
	}

	if (!bFoundARadio)
	{
		ReceiveLocalizedMessage(class'ROArtilleryMsg', 9);
		return;
	}

	// if you don't have binocs can't call arty strike
	if ( Pawn.Weapon != none && Pawn.Weapon.IsA('BinocularsItem' ))
	{
	  	TraceDist = GetMaxViewDistance();
	  	StartTrace = Pawn.Location + Pawn.EyePosition();
	  	AimRot = Rotation;
	}
	else if( Pawn.IsA('ROVehicleWeaponPawn') )
	{
		TraceDist = GetMaxViewDistance();
		AimRot = ROVehicleWeaponPawn(Pawn).CustomAim;
		StartTrace = ROVehicleWeaponPawn(Pawn).GetViewLocation() + 500 * vector(AimRot);
	}
	else
	{
	   return;
	}

	//StartTrace = Pawn.Location + Pawn.EyePosition();
	HitActor = trace(HitLocation,HitNormal,StartTrace + TraceDist*vector(AimRot),StartTrace,true);

     RVT = Spawn(class'ROVolumeTest',self,,HitLocation);

     if ((RVT != none && RVT.IsInNoArtyVolume()) || HitActor == none)
     {
     	ReceiveLocalizedMessage(class'ROArtilleryMsg', 5);
		RVT.Destroy();
		return;
     }

     RVT.Destroy();

     ReceiveLocalizedMessage(class'ROArtilleryMsg', 0);

	SavedArtilleryCoords = HitLocation;

/*   if ( Pawn.GetTeamNum() == 0 )
     {
         ROGameReplicationInfo(GameReplicationInfo).AxisArtilleryCoords = HitLocation;
     }
     else
     {
         ROGameReplicationInfo(GameReplicationInfo).AlliedArtilleryCoords = HitLocation;
     }*/
}

/* =================================================================================== *
* ServerArtyStrike()
* 	Spawn the artillery strike at the appropriate position.
*
* modified by: Ramm 10/21/04
* =================================================================================== */
function ServerArtyStrike()
{
     local vector SpawnLocation;
     local ROGameReplicationInfo GRI;
     local ROArtillerySpawner Spawner;

     GRI = ROGameReplicationInfo(GameReplicationInfo);

/*     if ( Pawn.GetTeamNum() == 0 )
     {
         SpawnLocation = GRI.AxisArtilleryCoords;
     }
     else
     {
         SpawnLocation = GRI.AlliedArtilleryCoords;
     }*/


     SpawnLocation = SavedArtilleryCoords;

     SpawnLocation.Z = GRI.NorthEastBounds.Z;

     Spawner =  Spawn(class 'ROArtillerySpawner',self,, SpawnLocation, rotator(PhysicsVolume.Gravity));

     if (Spawner == none)
     {
         log("Error Spawning Artillery Shell Spawnner ");
     }
     else
     {
        Spawner.OriginalArtyLocation = SavedArtilleryCoords;
     }
}

/* For Debugging only
exec function HitIt()
{
     ServerArtyStrike();
}*/

/* =================================================================================== *
* ServerArtyStrike()
* 	Attempt to call in an artillery strike, and give approval/denial text and
*	voice messages to the player based on that.
*
* modified by: Ramm 10/21/04
* =================================================================================== */
function HitThis(ROArtilleryTrigger RAT)
{
    local ROGameReplicationInfo GRI;
    local int TimeTilNextStrike;
    local int PawnTeam;

    GRI = ROGameReplicationInfo(GameReplicationInfo);
    PawnTeam = Pawn.GetTeamNum();

    if (GRI.bArtilleryAvailable[Pawn.GetTeamNum()] == 1)
    {
	  ReceiveLocalizedMessage(class'ROArtilleryMsg', 3,,,self);

       if ( PawnTeam ==  0 )
       {
           RAT.PlaySound( RAT.GermanConfirmSound, Slot_None, 3.0, false, 100,1.0,true );
       }
       else
       {
           RAT.PlaySound( RAT.RussianConfirmSound, Slot_None, 3.0, false, 100,1.0,true );
       }

       GRI.LastArtyStrikeTime[PawnTeam] = GRI.ElapsedTime;
	  GRI.TotalStrikes[PawnTeam]++;
       ServerArtyStrike();
        ROTeamGame(Level.Game).NotifyPlayersOfMapInfoChange(PawnTeam, self);
    }
    else
    {
       if ( PawnTeam ==  0 )
       {
           RAT.PlaySound( RAT.GermanDenySound, Slot_None, 3.0, false, 100,1.0,true );
           //RAT.SetTimer(GetSoundDuration(RAT.GermanDenySound), false);
       }
       else
       {
           RAT.PlaySound( RAT.RussianDenySound, Slot_None, 3.0, false, 100,1.0,true );
       }


	  TimeTilNextStrike = (GRI.LastArtyStrikeTime[PawnTeam] + ROTeamGame(Level.Game).LevelInfo.GetStrikeInterval(PawnTeam)) - GRI.ElapsedTime;

 	  if (GRI.TotalStrikes[PawnTeam] >= GRI.ArtilleryStrikeLimit[PawnTeam])
 	  {
 	  	 ReceiveLocalizedMessage(class'ROArtilleryMsg', 6);
 	  }
 	  else if ( TimeTilNextStrike >= 20 )
 	  {
 	  	   ReceiveLocalizedMessage(class'ROArtilleryMsg', 7);
 	  }
 	  else if ( TimeTilNextStrike >= 0 )
 	  {
 	  	   ReceiveLocalizedMessage(class'ROArtilleryMsg', 8);
 	  }
 	  else
 	  {
 	  	   ReceiveLocalizedMessage(class'ROArtilleryMsg', 2);
 	  }
    }
}

/*
exec function PokeIt()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;


	local vector StartTrace;

	local int TraceDist;

	local rotator AimRot;




	  	TraceDist = GetMaxViewDistance();
	  	StartTrace = Pawn.Location + Pawn.EyePosition();
	  	AimRot = Rotation;


	//StartTrace = Pawn.Location + Pawn.EyePosition();
	HitActor = trace(HitLocation,HitNormal,StartTrace + TraceDist*vector(AimRot),StartTrace,true);

//DistanceToTarget = VSize(Location - HitLocation);

//    log("HitActor = "$HitActor);

		if (  HitActor.IsA('TerrainInfo') )
		{

		   TerrainInfo(HitActor).PokeTerrain((HitLocation + 16 * HitNormal) , 25, 25);
		}


}


exec function UnPoke()
{
     local int i;
     local ROGameReplicationInfo GRI;

     GRI = ROGameReplicationInfo(GameReplicationInfo);

     for ( i=0; i<ArrayCount(GRI.SavedPoke); i++ )
     {
           if ( GRI.SavedPoke[i].PokeLocation != vect(0,0,0))
              GRI.SavedPoke[i].PokedTerrain.PokeTerrain(GRI.SavedPoke[i].PokeLocation , GRI.SavedPoke[i].PokeRadius, (GRI.SavedPoke[i].PokeDepth * -1));
		   //TerrainInfo(Wall).PokeTerrain((Location + 16 * HitNormal) , 100, 50);
     }
}  */

//-----------------------------------------------------------------------------
// Set the NorthEast map bound to the player's current location
//-----------------------------------------------------------------------------
exec function SetNE()
{
	if ( Level.NetMode != NM_Standalone )
		return;

    ROTeamGame(Level.Game).SetNEBound(Pawn.Location);

    if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
    	log("Setting NE Corner Location to: "$Pawn.Location);
	}
}

//-----------------------------------------------------------------------------
// Set the SouthWest map bound to the player's current location
//-----------------------------------------------------------------------------
exec function SetSW()
{
	if ( Level.NetMode != NM_Standalone )
		return;

	ROTeamGame(Level.Game).SetSWBound(Pawn.Location);

    if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    {
		log("Setting SW Corner Location to: "$Pawn.Location);
	}
}

//-----------------------------------------------------------------------------
// Turn sway on and off -- for debug use only
//-----------------------------------------------------------------------------
exec function Sway( bool B )
{
	if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		bSway = B;
	}
}

function GetNorthDirection()
{
	if( ROTeamGame(Level.Game).LevelInfo != none )
	{
		//log("at SendNorthDirection, north is "$ROTeamGame(Level.Game).LevelInfo.Rotation);
    	SendNorthDirection(ROTeamGame(Level.Game).LevelInfo.Rotation.Yaw);
	}
}

simulated function SendNorthDirection(int North)
{
	if( ROHud(myHud) != none )
		ROHud(myHud).NorthDirection.Yaw = North;
}

simulated function ResetFreeAimValues()
{
   WeaponBufferRotation = rot(0,0,0);
}

//-----------------------------------------------------------------------------
// AddHudDeathMessage - Replicated function that adds a death message to the HUD
//-----------------------------------------------------------------------------

function AddHudDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> DamageType)
{
	if (ROHud(myHud) == None)
		return;

	ROHud(myHud).AddDeathMessage(Killer, Victim, DamageType);

	if (!class'RODeathMessage'.default.bNoConsoleDeathMessages && (Player != None) && (Player.Console != None))
		Player.Console.Message(class'RODeathMessage'.Static.GetString(0, Killer, Victim, DamageType),0 );
}


/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
Modified to use our PlayerInput class - Ramm 10/26/03
*/
event InitInputSystem()
{
	InputClass = class'ROEngine.ROPlayerInput';
	//SaveConfig();  UT2k4Merge - Ramm

	Super.InitInputSystem();
}

// These is an accessor for the ROPlayerInput class. It looks here to see what to set the mouse sensitivy to.
// Used primarily for lowering the mouse sensitivity while sniping. Returning -1 will do no modification at all.
// Ramm - 10/27/03
function float GetMouseModifier()
{
	local ROWeapon weap;

	if (Pawn == none || Pawn.Weapon == none)
		return -1.0;

	weap = ROWeapon(Pawn.Weapon);

	if (weap== none )
		return -1.0;


	if(weap.ScopeDetail == RO_ModelScope && weap.ShouldDrawPortal())
	{
		return 24;
	}
	else if(weap.ScopeDetail == RO_ModelScopeHigh && weap.ShouldDrawPortal())
	{
		return 24;
	}
	else
	{
		return -1.0;
	}

}

// Update the blur amount for this player
simulated function UpdateBlurEffect(float DeltaTime)
{
	if( BlurTime > 0 )
	{
		 BlurTime -= DeltaTime;

		 if( bUseBlurEffect )
		 {
			 if( InitialBlurTime > 0 )
			 {
			 	//ShellShockBlur.BlurAlpha = 255 - ((BlurTime/InitialBlurTime) * 255);
			 	CurrentBlurAmount = BlurTime/InitialBlurTime;
			 }
			 else
			 {
			 	//ShellShockBlur.BlurAlpha = 255;
			 	CurrentBlurAmount = 0;
			 }
			postfxblur(CurrentBlurAmount);
		 }
	}

	if( ColorFadeTime > 0 )
	{
		 ColorFadeTime -= DeltaTime * 2;

		 if( bUseBlurEffect )
		 {
			 if( InitialBlurTime > 0 )
			 {
			 	CurrentFadeAmount = ColorFadeTime/InitialBlurTime;
			 }
			 else
			 {
			 	CurrentFadeAmount = 0;
			 }

			postfxbw(CurrentFadeAmount);
		 }
	}

	if( ColorFadeTime <= 0 )
	{
        CurrentFadeAmount = 0;
		postfxbw(CurrentFadeAmount);

		postfxoff(2);
	}

	if( BlurTime <= 0 )
	{
		BlurTime=0;
		AltBlurLevel = 0;

        CurrentBlurAmount = 0;
        //CurrentFadeAmount = 0;
 		postfxblur(CurrentBlurAmount);
		//postfxbw(CurrentFadeAmount);

		postfxoff(1);
		//postfxoff(2);
	}
}

// Cause the player's view to be blurred for a specified time
simulated function AddBlur(float NewBlurTime, float NewBlurScale)
{
	if( bUseBlurEffect )
	{
		if( CurrentBlurAmount < NewBlurScale)
		{
			CurrentBlurAmount = NewBlurScale;
			CurrentFadeAmount = NewBlurScale/2;
		}

		postfxblur(CurrentBlurAmount);
		postfxon(1);

		// Don't do the black and white effect if the detail settings are low
		if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
		{
			postfxbw(CurrentFadeAmount);
			postfxon(2);
		}


//		if (ShellShockBlur == None)
//		{
//			ShellShockBlur = new(None) class'MotionBlur';
//		}
//		if( ShellShockBlur.BlurAlpha > (255 - (255 * NewBlurScale)))
//			ShellShockBlur.BlurAlpha = 255 - (255 * NewBlurScale);//0;
//
//		AddCameraEffect(ShellShockBlur, true);
	}

	if( (MaxAltBlurLevel * NewBlurScale) > AltBlurLevel )
    	AltBlurLevel = MaxAltBlurLevel * NewBlurScale;

    if( NewBlurTime > BlurTime )
    {
	    BlurTime = NewBlurTime;
	    ColorFadeTime = NewBlurTime/2;
	    InitialBlurTime = NewBlurTime;
    }
}

// reset the motion blur vars
simulated function ResetBlur()
{
	BlurTime = 0.0;
	ColorFadeTime = 0.0;

    CurrentFadeAmount = 0;
	AltBlurLevel = 0;
    CurrentBlurAmount = 0;

	if( PostFX_IsReady() )
	{
		postfxbw(CurrentFadeAmount);
		postfxoff(2);
		postfxblur(CurrentBlurAmount);
		postfxoff(1);
	}
}

// Overriden to support resetting motion blur before switching maps and cleaning
// up weapons that aren't properly garbage collected under normal circumstances
event PreClientTravel()
{
	super.PreClientTravel();

	if( Level.NetMode != NM_DedicatedServer )
	{
		ResetBlur();

		if( Pawn != none)
		{
			if( Vehicle(Pawn) != none && Vehicle(Pawn).Driver != none && ROPawn(Vehicle(Pawn).Driver) != none )
			{
				ROPawn(Vehicle(Pawn).Driver).PreTravelCleanUp();
			}
			else if ( ROPawn(Pawn) != none )
			{
				ROPawn(Pawn).PreTravelCleanUp();
			}
		}
	}
}

// Give the player a quick blur effect
simulated function PlayerWhizzed(float DistSquared)
{
	local float Intensity;

    //log("DistSquared of whiz is "$DistSquared);

	Intensity = 1.0 - ((FMin(DistSquared,22500))/22500);  // 22500 = (150*150) = Radius of bullet whiz cylinder squared

	//log("Intensity of whiz is "$Intensity);

	AddBlur(0.15, Intensity/2);
}

// Jarr the player's vision as if they were bumped by something
// such as the butt of a gun. The HitDirection must be
// passed in screen-space rotation.
simulated function PlayerJarred(vector HitDirection, float JarrScale)
{
    local vector localShakeMoveMag;
    local vector localShakeMoveRate;
    local vector localShakeRotateMag;
    local vector localShakeRotateRate;

    // Shake Moving
    //
    localShakeMoveMag = HitDirection * JarrMoveMag;
    //
    localShakeMoveRate.X = JarrMoveRate;
    localShakeMoveRate.Y = JarrMoveRate;
    localShakeMoveRate.Z = JarrMoveRate;
    //
    // Unfortunately, the HitDirection
    // only transfers maximum offsets to
    // the shake offset max. I have to
    // check it's sign and move that into
    // the rate so it moves the right direction.
    if ( HitDirection.X < 0 )
        localShakeMoveRate.X *= -1;
    if ( HitDirection.Y < 0 )
        localShakeMoveRate.Y *= -1;
    if ( HitDirection.Z < 0 )
        localShakeMoveRate.Z *= -1;

    // Shake Rotation
    //
    localShakeRotateMag.X = JarrRotateMag*-HitDirection.X;
    localShakeRotateMag.Z = JarrRotateMag*HitDirection.Y;
    //
    localShakeRotateRate.X = JarrRotateRate*-HitDirection.X;
    localShakeRotateRate.Z = JarrRotateRate*HitDirection.Y;

    ShakeView(localShakeRotateMag*JarrScale,
              localShakeRotateRate*(2.0f-JarrScale),
              JarrRotateDuration,
              localShakeMoveMag*JarrScale,
              localShakeMoveRate*(2.0f-JarrScale),
              JarrMoveDuration);
    AddBlur(0.5f+JarrScale,1.0f);
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation, ViewRotation;
    local ROVehicle ROVeh;
    local ROPawn ROPwn;
    local ROWeapon ROWeap;

	// Lets avoid casting 20 times every tick - Ramm
    ROPwn = ROPawn(Pawn);
    if(Pawn != none)
    	ROWeap = ROWeapon(Pawn.Weapon);

    if( bSway && (Pawn != none)
          && !Pawn.bBipodDeployed
		  && Pawn.Weapon != none
		  && Pawn.Weapon.bCanSway
		  && Pawn.Weapon.bUsingSights)
    {
		SwayHandler(DeltaTime);
    }
    else
    {
        SwayYaw = 0.0;
        SwayPitch = 0.0;
        WeaponSwayYawRate = 0.0;
        WeaponSwayPitchRate = 0.0;
        SwayTime = 0.0;
    }


    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bHudLocksPlayerRotation)
        {
            // No camera change if we're locking rotation
        }
        else if (bFreeCamZoom == True)
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

		if(Pawn != none && Pawn.Physics != PHYS_Flying) // mmmmm
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

        if ( bTurnToNearest != 0 )
            TurnTowardNearestEnemy();
        else if ( bTurn180 != 0 )
            TurnAround();
        else
        {
            TurnTarget = None;
            bRotateToDesired = false;
            bSetTurnRot = false;

            if (bHudLocksPlayerRotation)
            {
                // No camera change if we're locking rotation
            }
            else if( ROPwn!= none && ROPwn.bRestingWeapon )
            {
	           	ViewRotation.Yaw += 16.0 * DeltaTime * aTurn;
		       	ViewRotation.Pitch += 16.0 * DeltaTime * aLookUp;
            }
            else
            {
	           	ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		       	ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	       	}

			if( (Pawn != none ) && (Pawn.Weapon != none) && (ROPwn != none))
			{
				ViewRotation = FreeAimHandler(ViewRotation, DeltaTime);
            }
        }

        if( ROPwn != none )
        	ViewRotation.Pitch = ROPwn.LimitPitch(ViewRotation.Pitch,DeltaTime); //amb

        if( (ROPwn != none) && (ROPwn.bBipodDeployed) )
		{
            ROPwn.LimitYaw(ViewRotation.Yaw);
        }

        // Limit Pitch and yaw for the ROVehicles - Ramm
        if ( Pawn != none )
        {
             if( Pawn.IsA('ROVehicle'))
             {
                  ROVeh = ROVehicle(Pawn);

                  ViewRotation.Yaw = ROVeh.LimitYaw(ViewRotation.Yaw);
                  ViewRotation.Pitch = ROVeh.LimitPawnPitch( ViewRotation.Pitch );
             }
        }

// TODO: Fix and Optimize this when the weapons are converted over
//        if(  bSway && (Pawn != none)
//              && (ROProjectileWeapon(Pawn.Weapon) != none)
//			  && ROProjectileWeapon(Pawn.Weapon).bUsingSights)
//        {
            ViewRotation.Yaw += SwayYaw;
            ViewRotation.Pitch += SwayPitch;
 //       }

		SetRotation(ViewRotation);

        ViewShake(deltaTime);
        ViewFlash(deltaTime);

		NewRotation = ViewRotation;

        NewRotation.Roll = Rotation.Roll;

        if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
            Pawn.FaceRotation(NewRotation, deltatime);
    }
}

simulated function SetRecoil(rotator NewRecoilRotation, float NewRecoilSpeed)
{
	RecoilRotator += NewRecoilRotation;
	LastRecoilTime = Level.TimeSeconds;
	RecoilSpeed = NewRecoilSpeed;

}

// Calculate the weapon sway
simulated function SwayHandler(float DeltaTime)
{
     local float WeaponSwayYawAcc;
     local float WeaponSwayPitchAcc;
     local float DeltaSwayYaw;
     local float DeltaSwayPitch;
     local float timeFactor;
     local float staminaFactor;
     local ROPawn P;
     //local float zoomFactor;

	 P = ROPawn(Pawn);

	 if (P == None )
		return;

     StaminaFactor = (P.default.Stamina - P.Stamina)/(P.default.Stamina*0.5);

     SwayTime += DeltaTime;

     if( SwayClearTime > 0.05 )
     {
 		SwayClearTime = 0.0;
		WeaponSwayYawAcc = RandRange( -baseSwayYawAcc, baseSwayYawAcc );
        WeaponSwayPitchAcc = RandRange( -baseSwayPitchAcc, baseSwayPitchAcc );
     }
     else
     {
		WeaponSwayYawAcc = 0.0;
        WeaponSwayPitchAcc = 0.0;
        SwayClearTime += DeltaTime;
     }

     timeFactor = InterpCurveEval(SwayCurve,SwayTime);

     // weapon acceleration (sway) is based on time in iron sights and
     // on lost stamina
     WeaponSwayYawAcc =  (timeFactor * WeaponSwayYawAcc) + (staminaFactor * WeaponSwayYawAcc);
     WeaponSwayPitchAcc =  (timeFactor * WeaponSwayPitchAcc) + (staminaFactor * WeaponSwayPitchAcc);

     // Sway reduction for crouching, prone, and resting the weapon
     if (P.bRestingWeapon)
     {
         WeaponSwayYawAcc *= 0.1;
         WeaponSwayPitchAcc *= 0.1;
     }
	 else if (P.bIsCrouched)
     {
         WeaponSwayYawAcc *= 0.5;
         WeaponSwayPitchAcc *= 0.5;
     }
     else if (P.bIsCrawling)
     {
         WeaponSwayYawAcc *= 0.15;
         WeaponSwayPitchAcc *= 0.15;
     }

     if( P.LeanAmount != 0)
     {
 		 WeaponSwayYawAcc *= 1.45;
         WeaponSwayPitchAcc *= 1.45;
     }

     // added a elastic factor to get sway near the original aim-point
     // added a damping factor to keep the elastic factor from causing wild oscillations
     WeaponSwayYawAcc = WeaponSwayYawAcc - (SwayElasticFactor*SwayYaw) - (SwayDampingFactor*WeaponSwayYawRate);
     WeaponSwayPitchAcc = WeaponSwayPitchAcc - (SwayElasticFactor*SwayPitch) - (SwayDampingFactor*WeaponSwayPitchRate);

     // basic equation of motion (deltaX = vt + 1/2*a*t^2)
     DeltaSwayYaw = (WeaponSwayYawRate * DeltaTime) + (0.5*WeaponSwayYawAcc*DeltaTime*DeltaTime);
     DeltaSwayPitch = (WeaponSwayPitchRate * DeltaTime) + (0.5*WeaponSwayPitchAcc*DeltaTime*DeltaTime);
     SwayYaw += DeltaSwayYaw;
     SwayPitch += DeltaSwayPitch;

	 if (P.bRestingWeapon)
     {
         SwayYaw = 0;
         SwayPitch = 0;
     }

	// Maybe re-add this when we get the scoped weapons in
//    // Adjust by zoom factor of weapon
//    zoomFactor =0.65;//0.65*(DefaultFOV/ROWeapon(P.Weapon).ROPlayerFOVZoom);
//
//     // Sway reduction for crouching and prone - lets add this for snipers too!!! - Ramm
//	if (P.bIsCrouched)
//	{
//		FOVSwayYaw = 0.5*zoomFactor*(DeltaSwayYaw + SwayYawFraction);
//		FOVSwayPitch = 0.5*zoomFactor*(DeltaSwayPitch + SwayPitchFraction);
//	}
//	else if (P.bIsCrawling)
//	{
//		FOVSwayYaw = 0.35*zoomFactor*(DeltaSwayYaw + SwayYawFraction);
//		FOVSwayPitch = 0.35*zoomFactor*(DeltaSwayPitch + SwayPitchFraction);
//	}
//	else
//	{
//        FOVSwayYaw = zoomFactor*(DeltaSwayYaw + SwayYawFraction);
//        FOVSwayPitch = zoomFactor*(DeltaSwayPitch + SwayPitchFraction);
//    }

	// update new sway velocity
	WeaponSwayYawRate += WeaponSwayYawAcc*DeltaTime;
	WeaponSwayPitchRate += WeaponSwayPitchAcc*DeltaTime;
}

// Need to reset the sway when you switch stances so you don't retain the worse
// sway state when switching to a better sway state.
simulated function ResetSwayValues()
{
	WeaponSwayYawRate = 0;
	WeaponSwayPitchRate = 0;
}

//------------------------------------------------------------------------------
//	FreeAimHandler
// Calculate free-aim and process recoil
//------------------------------------------------------------------------------
simulated function rotator FreeAimHandler(rotator NewRotation, float DeltaTime)
{
	// try to move these to class variables so they aren't created every tick
	local rotator NewPlayerRotation;
    local int YawAdjust;
    local int PitchAdjust;
    local float	FreeAimBlendAmount;
    local rotator AppliedRecoil;

	if( Pawn == none || ROProjectileWeapon(Pawn.Weapon) == none ||
		!ROProjectileWeapon(Pawn.Weapon).ShouldUseFreeAim() )
	{
		LastFreeAimSuspendTime=Level.TimeSeconds;

		if( WeaponBufferRotation.Yaw != 0 )
		{
			if( WeaponBufferRotation.Yaw > 32768 )
			{
				WeaponBufferRotation.Yaw +=	YawTweenRate * deltatime;

				if( WeaponBufferRotation.Yaw > 65536 )
				{
					WeaponBufferRotation.Yaw = 0;
				}
			}
			else
			{
				WeaponBufferRotation.Yaw -=	YawTweenRate * deltatime;

				if( WeaponBufferRotation.Yaw <  0)
				{
					WeaponBufferRotation.Yaw = 0;
				}
			}
		}

		if( WeaponBufferRotation.Pitch != 0 )
		{
			if( WeaponBufferRotation.Pitch > 32768 )
			{
				WeaponBufferRotation.Pitch += PitchTweenRate * deltatime;

				if( WeaponBufferRotation.Pitch > 65536 )
				{
					WeaponBufferRotation.Pitch = 0;
				}
			}
			else
			{
				WeaponBufferRotation.Pitch -= PitchTweenRate * deltatime;

				if( WeaponBufferRotation.Pitch <  0)
				{
					WeaponBufferRotation.Pitch = 0;
				}
			}
		}

		// Process recoil
		// Handle recoil if the framerate is really low causing deltatime to be really high
/*		if( deltatime >= RecoilSpeed && ((Level.TimeSeconds - LastRecoilTime) <= (deltatime + (deltatime * 0.03))))
		{
			NewRotation += (RecoilRotator/RecoilSpeed) * deltatime/(deltatime/RecoilSpeed);
		}
		// Standard recoil
        else*/ if( Level.TimeSeconds - LastRecoilTime <= RecoilSpeed )
        {
			NewRotation += (RecoilRotator/RecoilSpeed) * deltatime;
        }
        else
        {
			RecoilRotator = rot(0,0,0);
        }

		return NewRotation;
	}

	NewPlayerRotation = NewRotation;

//	if( Level.TimeSeconds - LastFreeAimSuspendTime < 0.5 )
//	{
//		FreeAimBlendAmount = (Level.TimeSeconds - LastFreeAimSuspendTime)/0.5;
//	}
//	else
//	{
		FreeAimBlendAmount = 1;
//	}

	// Add the freeaim movement in
	if (!bHudLocksPlayerRotation)
	{
    	WeaponBufferRotation.Yaw += (FAAWeaponRotationFactor * DeltaTime * aTurn) * FreeAimBlendAmount;
    	WeaponBufferRotation.Pitch += (FAAWeaponRotationFactor * DeltaTime * aLookUp) * FreeAimBlendAmount;
    }

	// Process recoil
	// Handle recoil if the framerate is really low causing deltatime to be really high
/*	if( deltatime >= RecoilSpeed && ((Level.TimeSeconds - LastRecoilTime) <= (deltatime + (deltatime * 0.03))))
	{
	    AppliedRecoil = (RecoilRotator/RecoilSpeed) * deltatime/(deltatime/RecoilSpeed);
		WeaponBufferRotation += AppliedRecoil;
	}
	// standard recoil
    else*/ if( Level.TimeSeconds - LastRecoilTime <= RecoilSpeed )
    {
	    AppliedRecoil = (RecoilRotator/RecoilSpeed) * deltatime;
		WeaponBufferRotation += AppliedRecoil;
    }
    else
    {
		RecoilRotator = rot(0,0,0);
    }

	// Add recoil from a weapon that has been fired
	//WeaponBufferRotation += RecoilRotator;

	// Do the pitch and yaw limitation
    YawAdjust = WeaponBufferRotation.Yaw & 65535;

    if (YawAdjust > FreeAimMaxYawLimit && YawAdjust < FreeAimMinYawLimit)
    {
        if (YawAdjust - FreeAimMaxYawLimit < FreeAimMinYawLimit - YawAdjust)
            YawAdjust = FreeAimMaxYawLimit;
        else
            YawAdjust = FreeAimMinYawLimit;

       	NewPlayerRotation.Yaw += AppliedRecoil.Yaw;
    }

    WeaponBufferRotation.Yaw = YawAdjust;

    PitchAdjust = WeaponBufferRotation.Pitch & 65535;

    if (PitchAdjust > FreeAimMaxPitchLimit && PitchAdjust < FreeAimMinPitchLimit)
    {
        if (PitchAdjust - FreeAimMaxPitchLimit < FreeAimMinPitchLimit - PitchAdjust)
            PitchAdjust = FreeAimMaxPitchLimit;
        else
            PitchAdjust = FreeAimMinPitchLimit;

        NewPlayerRotation.Pitch += AppliedRecoil.Pitch;
    }

    WeaponBufferRotation.Pitch = PitchAdjust;

    //RecoilRotator = rot(0,0,0);

	return NewPlayerRotation;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

/*	Canvas.DrawText("PlayerController Rotation is "@Rotation);
	YPos += YL;
	Canvas.SetPos(4,YPos);*/

	Canvas.DrawText("bCrawl: "@bCrawl);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText(PlayerReplicationInfo.PlayerName$" bOnlySpectator: "$PlayerReplicationInfo.bOnlySpectator$" in state: "$GetStateName());
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// overload function and set flag to always false
// to prevent idle animation from playing while typing
// Puma 5-15-2004
function Typing( bool bTyping )
{
    bIsTyping = false;
    if ( (Pawn != None) )
        Pawn.bIsTyping = bIsTyping;
}


// Added this here so we could have bob in the textured scopes - Ramm
// Added AmbientShake functionality from UT2004 - Erik
function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	local vector x, y, z, AmbShakeOffset;
	local rotator AmbShakeRot, RollMod;
	local float FalloffScaling;
	local ROWeapon weap;
	local ROPawn rpawn;

    GetAxes(Rotation, x, y, z);

	if(bEnableAmbientShake)
	{
		if (AmbientShakeFalloffStartTime > 0 && Level.TimeSeconds - AmbientShakeFalloffStartTime > AmbientShakeFalloffTime)
			bEnableAmbientShake = false;
		else
		{
			if (AmbientShakeFalloffStartTime > 0)
			{
				FalloffScaling = 1.0 - ((Level.TimeSeconds - AmbientShakeFalloffStartTime) / AmbientShakeFalloffTime);
				FalloffScaling = FClamp(FalloffScaling, 0.0, 1.0);
			}
			else
				FalloffScaling = 1.0;

			AmbShakeOffset = AmbientShakeOffsetMag * FalloffScaling *
				sin(Level.TimeSeconds * AmbientShakeOffsetFreq * 2 * Pi);

			AmbShakeRot = AmbientShakeRotMag * FalloffScaling *
				sin(Level.TimeSeconds * AmbientShakeRotFreq * 2 * Pi);
		}
	}

	weap = ROWeapon(Pawn.Weapon);

    RollMod = Rotation;

	// Make the texture scope shake too
	// WeaponTODO: Add this scope stuff back in
	if ( (weap != none) && (weap.bUsingSights) && (weap.ScopeDetail == RO_TextureScope)
		&& weap.ShouldDrawPortal())
	{
		// First-person view
		CameraRotation = Normalize(RollMod/*Rotation*/ + ShakeRot); // amb
		CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob + (Pawn.WeaponBob(Pawn.Weapon.BobDamping) * 25) +
					 	ShakeOffset.X * x +
					 	ShakeOffset.Y * y +
					 	ShakeOffset.Z * z +
						AmbShakeOffset;
	}
	else
	{
		// First-person view.
		CameraRotation = Normalize(RollMod/*Rotation*/ + ShakeRot + AmbShakeRot); // amb
		CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob +
                     ShakeOffset.X * x +
                     ShakeOffset.Y * y +
                     ShakeOffset.Z * z +
					 AmbShakeOffset;
	}

	//Adjust camera roll for lean
	rpawn=ROPawn(pawn);
	if (rpawn != none && rpawn.LeanAmount != 0)
	{
		CameraRotation.Roll += rpawn.LeanAmount;
	}
}

//-----------------------------------------------------------------------------
// AskForPawn - Don't let the player restart on his own
//-----------------------------------------------------------------------------

function AskForPawn()
{
	if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( Pawn != None )
		GivePawn(Pawn);
	/*else
	{
		bFrozen = false;
		ServerRestartPlayer();
	}*/
}

//-----------------------------------------------------------------------------
// PawnDied - Change to desired role after death
//-----------------------------------------------------------------------------

function PawnDied(Pawn P)
{
    local ROTeamGame ROTeamGame;

	if ( P != Pawn )
		return;

    EndZoom();

    if ( Pawn != None )
        Pawn.RemoteRole = ROLE_SimulatedProxy;

    //if ( ViewTarget == Pawn )
    //    bBehindView = true;

	LastKillTime = -5.0;

    if (Pawn != None && bBehindView)
    {
        curcam = -1;
        SetLocation(FindFloatingCam(Pawn));
        SetRotation(CameraTrack(Pawn, 0));
    }

    Super(Controller).PawnDied(P);

    ROTeamGame = ROTeamGame(Level.Game);
	if (ROTeamGame != None && Role == ROLE_Authority)
    {
		if (!ROTeamGame.HandleDeath(self) && CurrentRole != DesiredRole)
		{
//			ROTeamGame.ChangeRole(self, DesiredRole, true);
			ROTeamGame.ChangeRole(self, DesiredRole, false);
 		    ROTeamGame.ChangeWeapons(self, DesiredPrimary, DesiredSecondary, DesiredGrenade);
		}
	}
}

simulated function ClientForcedTeamChange(int NewTeamIndex, int NewRoleIndex)
{
    //Store the new team and role info
    ForcedTeamSelectOnRoleSelectPage = NewTeamIndex;
    DesiredRole = NewRoleIndex;

    //Open the Role Selection Window
    ClientOpenMenu("ROInterface.ROGUIRoleSelection");
}

//-----------------------------------------------------------------------------
// GetRoleInfo - Returns the current RORoleInfo
//-----------------------------------------------------------------------------

function RORoleInfo GetRoleInfo()
{
	return ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;
}

//-----------------------------------------------------------------------------
// GetPrimaryWeapon
//-----------------------------------------------------------------------------

function string GetPrimaryWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || PrimaryWeapon < 0)
	{
		return "";
	}

	return string(RI.PrimaryWeapons[PrimaryWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetPrimaryAmmo
//-----------------------------------------------------------------------------

function int GetPrimaryAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || PrimaryWeapon < 0)
		return -1;

	return RI.PrimaryWeapons[PrimaryWeapon].Amount;
}

//-----------------------------------------------------------------------------
// GetSecondaryWeapon
//-----------------------------------------------------------------------------

function string GetSecondaryWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || SecondaryWeapon < 0)
		return "";

	return string(RI.SecondaryWeapons[SecondaryWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetSecondaryAmmo
//-----------------------------------------------------------------------------

function int GetSecondaryAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || SecondaryWeapon < 0)
		return -1;

	return RI.SecondaryWeapons[SecondaryWeapon].Amount;
}

//-----------------------------------------------------------------------------
// GetGrenadeWeapon
//-----------------------------------------------------------------------------

function string GetGrenadeWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || GrenadeWeapon < 0)
		return "";

	return string(RI.Grenades[GrenadeWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetGrenadeAmmo
//-----------------------------------------------------------------------------

function int GetGrenadeAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || GrenadeWeapon < 0)
		return -1;

	return RI.Grenades[GrenadeWeapon].Amount;
}

//-----------------------------------------------------------------------------
// HasSelectedTeam
//-----------------------------------------------------------------------------

function bool HasSelectedTeam()
{
	return PlayerReplicationInfo.Team != none && PlayerReplicationInfo.Team.TeamIndex < 2;
}

//-----------------------------------------------------------------------------
// HasSelectedRole
//-----------------------------------------------------------------------------

function bool HasSelectedRole()
{
	return GetRoleInfo() != None;
}

//-----------------------------------------------------------------------------
// HasSelectedWeapons
//-----------------------------------------------------------------------------

function bool HasSelectedWeapons()
{
	return bWeaponsSelected;
}

//-----------------------------------------------------------------------------
// CanRestartPlayer - Returns true if the player is allowed to spawn
//-----------------------------------------------------------------------------

function bool CanRestartPlayer()
{
	if (PlayerReplicationInfo.bOnlySpectator || !bCanRespawn)
		return false;
	else if (!HasSelectedTeam() || !HasSelectedRole() || !HasSelectedWeapons())
		return false;

	return true;
}

//-----------------------------------------------------------------------------
// ChangeWeapons - Allows selection of all weapons
//-----------------------------------------------------------------------------

exec function ChangeWeapons(int Primary, int Secondary, int Grenade)
{
	if (Role == ROLE_Authority && ROTeamGame(Level.Game) != None)
	{
		if (CurrentRole != DesiredRole)
		{
            DesiredPrimary = Primary;
            DesiredSecondary = Secondary;
            DesiredGrenade = Grenade;
	    }
	    else
	    {
       		ROTeamGame(Level.Game).ChangeWeapons(self, Primary, Secondary, Grenade);
   		}
	}
}

//-----------------------------------------------------------------------------
// NewRole - Console command to change role by number
//-----------------------------------------------------------------------------

exec function ChangeRole(int i)
{
	if (Role == ROLE_Authority && ROTeamGame(Level.Game) != None)
		ROTeamGame(Level.Game).ChangeRole(self, i);
}

//-----------------------------------------------------------------------------
// ChangeCharacter - Subclassed to allow for setting the correct team or role specific model in ROTeamgame - Ramm
//-----------------------------------------------------------------------------
function ChangeCharacter(string newCharacter, optional string inClass)
{
	if( inClass != "")
	{
		SetPawnClass(inClass, newCharacter);
	}
	else
	{
		SetPawnClass(string(PawnClass), newCharacter);
	}

	UpdateURL("Character", newCharacter, true);
	SaveConfig();

	// Send the info to the client now!
	NetUpdateTime = Level.TimeSeconds - 1;
}

// Overriden to allow for setting the correct RO-specific pawn class
function SetPawnClass(string inClass, string inCharacter)
{
    local class<ROPawn> pClass;

    if ( inClass != "" )
	{
		pClass = class<ROPawn>(DynamicLoadObject(inClass, class'Class'));
		if ( (pClass != None) && pClass.Default.bCanPickupInventory )
			PawnClass = pClass;
	}

    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(inCharacter);
}

//-----------------------------------------------------------------------------
// ServerChangePlayerInfo - client to server function used to change player's
// team, role and weapons. Calls back a function on the client to confirm
// success or failure.
// Variable constants:
// 255 == no change
// 254 == switch to spectator
//-----------------------------------------------------------------------------
// Return values:
// 0 - all is well
// 97 - successfully switched to axis team
// 98 - successfully switched to allies team
// everything else - error
//-----------------------------------------------------------------------------

function ServerChangePlayerInfo(byte newTeam, byte newRole, byte newWeapon1, byte newWeapon2)
{
    // Attempt to change teams
    if (newTeam != 255)
    {
        //log("changing team...");
        // Try to switch teams
        if (newTeam == 254) // spectate
        {
            BecomeSpectator();

            // Check if change was successfull
            if (!PlayerReplicationInfo.bOnlySpectator)
            {
                if (PlayerReplicationInfo == none)
                    ClientChangePlayerInfoResult(01);
                else if (Level.Game.NumSpectators >= Level.Game.MaxSpectators)
                    ClientChangePlayerInfoResult(02);
                else if (IsInState('GameEnded'))
                    ClientChangePlayerInfoResult(03);
                else if (IsInState('RoundEnded'))
                    ClientChangePlayerInfoResult(04);
                else
                    ClientChangePlayerInfoResult(99);
                return;
            }
        }
        else
        {
            if (PlayerReplicationInfo == none || PlayerReplicationInfo.bOnlySpectator)
                BecomeActivePlayer();

            if (newTeam == 250) // auto select
                newTeam = ServerAutoSelectAndChangeTeam();
            else
                ServerChangeTeam(newTeam);

            // Check if change was successfull
            if (PlayerReplicationInfo == none || PlayerReplicationInfo.Team == none ||
                PlayerReplicationInfo.Team.TeamIndex != newTeam)
            {
                if (PlayerReplicationInfo == none)
                    ClientChangePlayerInfoResult(10);
                else if (Level.Game.bMustJoinBeforeStart)
                    ClientChangePlayerInfoResult(11);
                else if (Level.Game.NumPlayers >= Level.Game.MaxPlayers)
                    ClientChangePlayerInfoResult(12);
                else if (Level.Game.MaxLives > 0)
                    ClientChangePlayerInfoResult(13);
                else if (IsInState('GameEnded'))
                    ClientChangePlayerInfoResult(14);
                else if (IsInState('RoundEnded'))
                    ClientChangePlayerInfoResult(15);
                else if (Level.Game.bMustJoinBeforeStart && Level.Game.GameReplicationInfo.bMatchHasBegun)
                    ClientChangePlayerInfoResult(16);
                else if (ROTeamGame(Level.Game) != none && ROTeamGame(Level.Game).PickTeam(newTeam, self) != newTeam)
                {
                    if (ROTeamGame(Level.Game).bPlayersVsBots && (Level.NetMode != NM_Standalone))
                        ClientChangePlayerInfoResult(17);
                    else
                        ClientChangePlayerInfoResult(18);
                }
                else
                    ClientChangePlayerInfoResult(99);

                return;
            }
        }
    }

    // Attempt to change role
    if (newRole != 255)
    {
        //log("changing role...");
        ChangeRole(newRole);

        // Check if change was successfull
        if (DesiredRole != newRole)
        {
            if (ROTeamGame(Level.Game) != none &&
                PlayerReplicationInfo != none &&
                PlayerReplicationInfo.Team != none &&
                ROTeamGame(Level.Game).RoleLimitReached(PlayerReplicationInfo.Team.TeamIndex, newRole))
            {
                ClientChangePlayerInfoResult(100);
            }
            else
                ClientChangePlayerInfoResult(199);
            return;
        }
    }

    // Attempt to change weapons
    //if (newWeapon1 != 255)
    //{
        //log("Changing weapons...");
        ChangeWeapons(newWeapon1, newWeapon2, 0);

        // No success check here, let's just assume it worked :)
    //}

    // Success!
    if (newTeam == AXIS_TEAM_INDEX)
        ClientChangePlayerInfoResult(97); // successfully picked axis team
    else if (newTeam == ALLIES_TEAM_INDEX)
        ClientChangePlayerInfoResult(98); // successfully picked allies team
    else
        ClientChangePlayerInfoResult(00);
}

//-----------------------------------------------------------------------------
// ClientChangePlayerInfoResult - server to client function called after
// attempting to change a player's team, role and weapons.
// Valid result codeS:
// 0 - all ok! w00t.
// 1 - unable to change team
// 2 - unable to change role (role is full)
// 3 - unable to chaneg weapons (wtf?)
//-----------------------------------------------------------------------------

function ClientChangePlayerInfoResult(byte result)
{
    local UT2K4GUIController c;
    local GUIPage page;
    local class<GUIPage> page_class;

    // Update state of hint manager (if needed)
    // This is done here so that we still have a hint manager even if
    // we joined game as spectator and later joined an active team.
    UpdateHintManagement(bShowHints);

    // Find the currently open ROGUIRoleSelection menu and notify it
    c = UT2K4GUIController(Player.GUIController);

    if (c == none)
    {
        warn("Unable to cast guicontroller to UT2K4GUIController.");
        return;
    }

    //page_class = class<GUIPage>(DynamicLoadObject("ROInterface.ROGUIRoleSelection", class'class'));
    page_class = class'GUIPage';
    if (page_class != none)
    {
        page = c.FindMenuByClass(page_class);
        if (page != none)
            page.OnMessage("notify_gui_role_selection_page", result);
    }
    else
        warn("Unable to dynamically load RoleSelection menu class: ROInterface.ROGUIRoleSelection");
}

//-----------------------------------------------------------------------------
// Overide code to prevent glowing emitter which leads to objectives
// inherited from UT
//-----------------------------------------------------------------------------
function ServerShowPathToBase(int TeamNum)
{
   // allow functionality in single player
   if ( Level.NetMode == NM_Standalone )
   {
        Super.ServerShowPathToBase(TeamNum);
   }
}

//-----------------------------------------------------------------------------
// ServerSay
//-----------------------------------------------------------------------------
function ServerSay(string Msg)
{
    if ( ROTeamGame(Level.Game) != none && ROTeamGame(Level.Game).bForgiveFFKillsEnabled && LastFFKiller != none &&
        (Msg ~= "np" || Msg ~= "forgive" || Msg ~= "no prob" || Msg ~= "no problem") )
    {
		Level.Game.BroadcastLocalizedMessage(Level.Game.default.GameMessageClass, 19, LastFFKiller, PlayerReplicationInfo);
        LastFFKiller.FFKills -= LastFFKillAmount;
        LastFFKiller = none;
    }

    super.ServerSay(Msg);
}

//-----------------------------------------------------------------------------
// ServerTeamSay
//-----------------------------------------------------------------------------
function ServerTeamSay( string Msg )
{
    if ( ROTeamGame(Level.Game) != none && ROTeamGame(Level.Game).bForgiveFFKillsEnabled && LastFFKiller != none &&
        (Msg ~= "np" || Msg ~= "forgive" || Msg ~= "no prob" || Msg ~= "no problem") )
    {
		Level.Game.BroadcastLocalizedMessage(Level.Game.default.GameMessageClass, 19, LastFFKiller, PlayerReplicationInfo);
        LastFFKiller.FFKills -= LastFFKillAmount;
        LastFFKiller = none;
    }

	LastActiveTime = Level.TimeSeconds;
    Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( Level.Game.BaseMutator , self, Msg ) , 'TeamSay');
}

//-----------------------------------------------------------------------------
// ServerVehicleSay - Added to incorporate VehicleSay - MrMethane 01/10/2005
//-----------------------------------------------------------------------------
function ServerVehicleSay( string Msg )
{
    local ROPlayer ROP;
    local int i;
    local array<PlayerController> vehicleOccupants;

    if ( ROTeamGame(Level.Game) != none && ROTeamGame(Level.Game).bForgiveFFKillsEnabled && LastFFKiller != none &&
        (Msg ~= "np" || Msg ~= "forgive" || Msg ~= "no prob" || Msg ~= "no problem") )
    {
		Level.Game.BroadcastLocalizedMessage(Level.Game.default.GameMessageClass, 19, LastFFKiller, PlayerReplicationInfo);
        LastFFKiller.FFKills -= LastFFKillAmount;
        LastFFKiller = none;
    }

    LastActiveTime = Level.TimeSeconds;
    vehicleOccupants = GetVehicleOccupants(self);

    for ( i =0; i<vehicleOccupants.length; i++ )
	{
	    ROP =  ROPlayer(vehicleOccupants[i]);

		if ( ROP != None )
		{
			if((Pawn != none) )
			{
               ROP.VehicleMessage(self.PlayerReplicationInfo, Msg);
			}
		}
	}
}

//========================================================================================
// VehicleMessage - new function to send message to individual player MrMethane 01/10/2005
//========================================================================================
function VehicleMessage(PlayerReplicationInfo Sender, string Msg )
{
    local ROBroadCastHandler handler;

    if(Level.Game.BroadcastHandler.IsA('ROBroadcastHandler'))
    {
       handler = ROBroadCastHandler(Level.Game.BroadcastHandler);
       handler.BroadcastText(Sender,self ,Msg,'VehicleSay');
    }
    else
    {
       //Log("Server not using ROBroadcastHandler");
       // In case for some reason game isn't using ROBroadCastHandler just use TeamSay
       ServerTeamSay(Msg);
    }
}

//-----------------------------------------------------------------------------
// TeamSay - Spectators can only do say messages
//-----------------------------------------------------------------------------

exec function TeamSay(string Msg)
{
	if (PlayerReplicationInfo.bOnlySpectator || (PlayerReplicationInfo.Team != None && PlayerReplicationInfo.Team.TeamIndex == 2))
	{
		Say( Msg );
		return;
	}

	Msg = Left(Msg,128);
	if ( AllowTextMessage(Msg) )
		ServerTeamSay(Msg);
}

//-----------------------------------------------------------------------------
// VehicleSay - Added for vehicle communitcatoin -MrMethane 01/10/2005
//-----------------------------------------------------------------------------

exec function VehicleSay(string Msg)
{
	if (PlayerReplicationInfo.bOnlySpectator || (PlayerReplicationInfo.Team != None && PlayerReplicationInfo.Team.TeamIndex == 2))
	{
		Say( Msg );
		return;
	}

	Msg = Left(Msg,128);
	if ( AllowTextMessage(Msg) )
		ServerVehicleSay(Msg);
}

//-----------------------------------------------------------------------------
// PlayerMenu - Menu for the player's entire selection process
//-----------------------------------------------------------------------------

exec function PlayerMenu(optional int Tab)
{
	/*
    if (Tab == 2)
		ClientReplaceMenu("ROInterface.ROUT2K4PlayerSetupPage",, "Role");
	else if (Tab == 3)
		ClientReplaceMenu("ROInterface.ROUT2K4PlayerSetupPage",, "Weapons");
	else
		ClientReplaceMenu("ROInterface.ROUT2K4PlayerSetupPage");
	*/

	// new menu code :)

    bPendingMapDisplay = false;

	// If we havn't picked a team, role and weapons yet, open the team pick menu
	if (!bWeaponsSelected)
	    ClientReplaceMenu("ROInterface.ROGUITeamSelection");
	else
	    ClientReplaceMenu("ROInterface.ROGUIRoleSelection");
}

//-----------------------------------------------------------------------------
// ShowMidGameMenu - Eliminated LoginMenu getting shown here
//-----------------------------------------------------------------------------

function ShowMidGameMenu(bool bPause)
{
	// Pause if not already
	if(Level.Pauser == None)
		SetPause(true);

	if ( Level.NetMode != NM_DedicatedServer )
		StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu
	if (bDemoOwner)
		ClientOpenMenu(DemoMenuClass);
	else
	{
	    // renamed this from MidGameMenuClass because I could not change the value - Puma
		ClientOpenMenu(ROMidGameMenuClass);
	}
}

//-----------------------------------------------------------------------------
// ShowLoginMenu - Modified to always show menu if called
//-----------------------------------------------------------------------------


simulated function ShowLoginMenu()
{
	if (Level.NetMode == NM_DedicatedServer )
	{
		return;
	}

	ClientReplaceMenu("ROInterface.ROUT2K4PlayerSetupPage");
}


//-----------------------------------------------------------------------------
// Prone - Toggles the bCrawl flag client side so the player will attempt to
// transition prone states
//-----------------------------------------------------------------------------
exec function Prone()
{
	if( Pawn != none && Pawn.CanProneTransition() )
	{
		if( bCrawl == 0 )
		{
			bCrawl = 1;
		}
		else
		{
			bCrawl = 0;
		}
	}
}

//-----------------------------------------------------------------------------
// Prone - Toggles the bCrawl flag client side so the player will attempt to
// transition prone states
//-----------------------------------------------------------------------------
exec function ToggleDuck()
{
	if( Pawn != none && Pawn.CanCrouchTransition())
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
	if( Pawn != none && Pawn.CanCrouchTransition())
	{
		bDuck = 1;
	}
}

exec function UnCrouch()
{
	if( Pawn != none && Pawn.CanCrouchTransition())
	{
		bDuck = 0;
	}
}

//==================================================================
// FOV(UT) - Put here to make sure people can't mess with the FOV
//	while playing online
//==================================================================
exec function FOV(float F)
{
    if( Level.Netmode==NM_Standalone )
    {
        DefaultFOV = FClamp(F, 1, 170);
        DesiredFOV = DefaultFOV;
        // Lets not save this to config. This allows poeple to cheat
        //SaveConfig    ();
    }
}

//-----------------------------------------------------------------------------
// Possess - No voice setup here
//-----------------------------------------------------------------------------

function Possess(Pawn aPawn)
{
	local ROPawn xp;

	Super(PlayerController).Possess(aPawn);

	StopViewShaking();

	ClientResetMovement();

	xp = ROPawn(aPawn);
	if(xp != None)
		xp.Setup(PawnSetupRecord, true);
}

// Overidden to support resetting shake and blur values when you posses the pawn
function AcknowledgePossession(Pawn P)
{
	if( P != none )
	{
		StopViewShaking();
		if( Level.NetMode != NM_DedicatedServer )
		{
			ResetBlur();
		}
	}

	if ( Viewport(Player) != None )
	{
		AcknowledgedPawn = P;
		if ( P != None )
			P.SetBaseEyeHeight();
		ServerAcknowledgePossession(P, Handedness, bAutoTaunt);
	}
}

// Overriden to clear up view shake issues on respawn
simulated function StopViewShaking()
{
    ShakeRotMax  = vect(0,0,0);
    ShakeRotRate = vect(0,0,0);
    ShakeRotTime = vect(0,0,0);
	ShakeOffsetMax  = vect(0,0,0);
    ShakeOffsetRate = vect(0,0,0);
    ShakeOffsetTime = vect(0,0,0);

// if _RO_
	ShakeOffset = vect(0,0,0);
	ShakeRot = Rot(0,0,0);
// end _RO_
}

//-----------------------------------------------------------------------------
// AllowWeaponSwitch
//-----------------------------------------------------------------------------

simulated function bool AllowWeaponSwitch()
{
	// See if the pawn can switch

	if (SVehicle(Pawn) != none || VehicleWeaponPawn(Pawn) != none)
       return true;

	if (ROPawn(Pawn) == None || !ROPawn(Pawn).CanSwitchWeapon()  && !ROPawn(Pawn).CanBusySwitchWeapon() ||
		((ROPawn(Pawn).bIsSprinting && Pawn.Acceleration != vect(0,0,0)) && !ROPawn(Pawn).CanBusySwitchWeapon()))
		return false;


	return true;
}

//-----------------------------------------------------------------------------
// SwitchToBestWeapon
//-----------------------------------------------------------------------------

exec function SwitchToBestWeapon()
{
	if (AllowWeaponSwitch())
		Super.SwitchToBestWeapon();
}

//-----------------------------------------------------------------------------
// SwitchWeapon
//-----------------------------------------------------------------------------

exec function SwitchWeapon(byte F)
{
	// allow switching if
	//	1. player has a ROWeapon
	//	2. player is manning a SVehicle
	//	3. player is manning a ONSWeaponPawn
	// we might need to remove 2 and 3 if we don't want to let players switch positions
	if( AllowWeaponSwitch() || (SVehicle(Pawn) != none) || (VehicleWeaponPawn(Pawn) != none) )
		Super.SwitchWeapon(F);

	if( class'ROEngine.ROLevelInfo'.static.RODebugMode() && ((SVehicle(Pawn) != none) || (VehicleWeaponPawn(Pawn) != none) ))
		super.SwitchWeapon(F);
}

//-----------------------------------------------------------------------------
// NextWeapon
//-----------------------------------------------------------------------------

exec function NextWeapon()
{
    if (AllowWeaponSwitch())
		Super.NextWeapon();
}

//-----------------------------------------------------------------------------
// PrevWeapon
//-----------------------------------------------------------------------------

exec function PrevWeapon()
{
	if (AllowWeaponSwitch())
		Super.PrevWeapon();
}

//-----------------------------------------------------------------------------
// GetWeapon
//-----------------------------------------------------------------------------

exec function GetWeapon(class<Weapon> NewWeaponClass)
{
	if (AllowWeaponSwitch())
		Super.GetWeapon(NewWeaponClass);
}

//
// AddWeapon - attempts to add the specified weapon to the player's inventory
exec function AddWeapon( string NewWeaponStr )
{
	local	class<ROWeapon>	NewWeaponClass;
	local	ROWeapon      	NewWeapon;
	local	ROPawn			PlayerPawn;

	PlayerPawn = ROPawn(Pawn);

	if( (Level.NetMode != NM_StandAlone) || (PlayerPawn == none)
		|| !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	NewWeaponClass = class<ROWeapon>(DynamicLoadObject(NewWeaponStr, class'Class'));
	if( NewWeaponClass == none )
	{
		NewWeaponStr = "ROInventory." $ NewWeaponStr;
		NewWeaponClass = class<ROWeapon>(DynamicLoadObject(NewWeaponStr, class'Class'));
	}

	if( NewWeaponClass != none )
	{
     	NewWeapon = Spawn(NewWeaponClass, PlayerPawn);
     	NewWeapon.GiveTo( PlayerPawn );
     	Pawn.Weapon = none;
		NewWeapon.BringUp();
		Pawn.Weapon = NewWeapon;
		log("AddWeapon Command Was Used for " $ NewWeaponStr);
	}
}

//-----------------------------------------------------------------------------
// ThrowMGAmmo(RO) - Throws the MG ammo in the default inventory of all players
//-----------------------------------------------------------------------------
exec function ThrowMGAmmo()
{
    if( ROPawn(Pawn) == none )
        return;

		//log("Attempted to throw MG Ammo");
	if( (ROHud(myHud).NamedPlayer != none) && ROPawn(Pawn).bCanResupply
		&& !ROPawn(Pawn).bUsedCarriedMGAmmo )
	{
     	ServerThrowMGAmmo( ROHud(myHud).NamedPlayer );
	}
}

function ServerThrowMGAmmo(Pawn Gunner)
{
	//log("ROPlayer::ServerThrowMGAmmo");
	// do a check to see if we're in a state where we can throw ammo
    //if( Pawn.CanThrowWeapon() )
    //{
        ROPawn(Pawn).TossMGAmmo(Gunner);
    //}
}

//------------------------------------------------------------------------------
// ServerRemoveWeapon(RO) - Removes a weapon from a players inventory without
//	spawning a pickup and sets the client to bring up the next best weapon.
//	Used for destroying grenades
//------------------------------------------------------------------------------
// WeaponTODO: reimplement this if needed
function ServerRemoveWeapon()
{
	if( ROPawn(Pawn) == none )
		return;
//
//    ROPawn(Pawn).RemoveWeapon();
//    ClientSwitchToBestWeapon();
}

//-----------------------------------------------------------------------------
// ServerViewNextPlayer - Switches the next player
//-----------------------------------------------------------------------------
function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
			PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
        if ( Level.Game.CanSpectate(self,bRealSpec,C) )
        {
            if ( Pick == None )
                Pick = C;
            if ( bFound )
            {
                Pick = C;
                break;
            }
            else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
        }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);

    if( Vehicle(ViewTarget) != none ) // First person view doesn't look right for these
    	bBehindView = true;
    else if ((ViewTarget == self) || bWasSpec || ROTeamGame(Level.Game).bSpectateFirstPersonOnly )
        bBehindView = false;
    else
        bBehindView = true; //bChaseCam;
    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

// Overriden because we don't want to view the next player ffs
function ServerSpectate()
{
	// Proper fix for phantom pawns

	if (Pawn != none && !Pawn.bDeleteMe)
	{
		Pawn.Died(self, class'DamageType', Pawn.Location);
	}

	GotoState('Spectating');
}

// get the next valid spectator mode based on the servers settings
function ESpectatorMode GetNextValidSpecMode()
{
	local ROTeamGame ROG;

	ROG = ROTeamGame(Level.Game);

	if(  SpecMode == SPEC_Self )
	{
		if( PlayersToSpectate() )
		{
			return SPEC_Players;
		}
		else if( ROG.bSpectateAllowViewPoints && ROG.ViewPoints.Length > 0)
		{
			return SPEC_ViewPoints;
		}
		else if( ROG.bSpectateAllowRoaming )
		{
			return SPEC_Roaming;
		}
		else
		{
			return SPEC_Self;
		}
	}
	else if ( SpecMode == SPEC_Players )
	{
		if( ROG.bSpectateAllowViewPoints && ROG.ViewPoints.Length > 0)
		{
			return SPEC_ViewPoints;
		}
		else if( ROG.bSpectateAllowRoaming )
		{
			return SPEC_Roaming;
		}
		else if( !ROG.bSpectateAllowRoaming && PlayersToSpectate() )
		{
			return SPEC_Players;
		}
		else
		{
			return SPEC_Self;
		}
	}
	else if ( SpecMode == SPEC_ViewPoints )
	{
		if( ROG.bSpectateAllowRoaming )
		{
			return SPEC_Roaming;
		}
		else
		{
			return SPEC_Self;
		}
	}
 	else if ( SpecMode == SPEC_ViewPoints )
	{
		return SPEC_Self;
	}

	return SPEC_Self;
}

// Returns the string representation of the spectating mode
simulated function string GetSpecModeDescription()
{
	Switch(SpecMode)
	{
		case SPEC_Self: return SpectatingModeName[0];
		case SPEC_Roaming: return SpectatingModeName[1];
		case SPEC_Players: return SpectatingModeName[2];
		case SPEC_ViewPoints: return SpectatingModeName[3];
	}

	return "Spectating Mode Not Set";
}

// Returns true if there are players to spectate
function bool PlayersToSpectate()
{
	local Controller C;
	local bool bFound;

	// Make sure there are players we can spectate.  if not, leave the players looking at their corpse.
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C != self && Level.Game.CanSpectate(self, PlayerReplicationInfo.bOnlySpectator, C.Pawn))
		{
			bFound = true;
			break;
		}
	}

	return bFound;
}

// Used to limit the number of client side called to spectating views.
// this will prevent clients from overloading the server
simulated function bool CanRequestSpectateChange()
{
	if((Level.TimeSeconds -	LastSpectateChangeTime) > 0.25 )
	{
		LastSpectateChangeTime = Level.TimeSeconds;
		return true;
	}

	return false;
}
//-----------------------------------------------------------------------------
// ServerChangeSpecMode - Tells the server to switch between modes available
//-----------------------------------------------------------------------------
function ServerChangeSpecMode()
{
	local ESpectatorMode NewMode;

	if (Role < ROLE_Authority)
		return;

    NewMode = GetNextValidSpecMode();

    if (NewMode == SPEC_Self)
    {
    	SpecMode = SPEC_Self;
		ServerViewSelf();
    }
    else if (NewMode == SPEC_Roaming)
    {
    	SpecMode = SPEC_Roaming;
		ServerViewSelf();
    }
 	else if (NewMode == SPEC_Players)
	{
 		SpecMode = SPEC_Players;
		ServerViewNextPlayer();
	}
 	else if (NewMode == SPEC_ViewPoints)
	{
		SpecMode = SPEC_ViewPoints;
 		ServerNextViewPoint();
	}
}

// Switch to the next viewpoint in the level
function ServerNextViewPoint()
{
	local ROTeamGame G;

	if (Role < ROLE_Authority)
		return;

	G = ROTeamGame(Level.Game);

	if (G == None || G.ViewPoints.Length == 0)
		return;

	CurrentEntryCam++;

	if (CurrentEntryCam > (G.ViewPoints.Length - 1))
		CurrentEntryCam = 0;

	SetViewTarget(G.ViewPoints[CurrentEntryCam]);
	ClientSetViewTarget(G.ViewPoints[CurrentEntryCam]);
}

//-----------------------------------------------------------------------------
// CalcBehindView - Move in the camera with the locked view
//-----------------------------------------------------------------------------

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist,RealDist;
	local vector globalX,globalY,globalZ;
	local vector localX,localY,localZ;
	// dead behindview locked stuff
	local ROPawn rpawn;
	local rotator ViewRot;
	local coords C;

	// Red Orchestra stuff to prevent players from looking around when this is the enforced view mode
	if (IsSpectating() && bLockedBehindView)
	{
		CameraRotation = ViewTarget.Rotation;

		RPawn = ROPawn(ViewTarget);

		if( RPawn != none )
		{
			CameraRotation.Pitch = RPawn.SmoothViewPitch;
			CameraRotation.Yaw = RPawn.SmoothViewYaw;
		}
		//Dist *= 0.5;
	}
	else if ( IsInState('Dead') && bLockedBehindView )
	{
		RPawn = ROPawn(ViewTarget);

		if( RPawn != none )
		{
            C = ViewTarget.GetBoneCoords(RPawn.HeadBone);

            // Rotate the view the proper direction
            ViewRot = OrthoRotation( -C.YAxis, -C.ZAxis, C.XAxis );

			CameraRotation = ViewRot;
		}
		else
		{
			CameraRotation = Rotation;
		}
	}
	else
	{
		CameraRotation = Rotation;
	}

	CameraRotation.Roll = 0;
	CameraLocation.Z += 12;

	// add view rotation offset to cameraview (amb)
	CameraRotation += CameraDeltaRotation;

	View = vect(1,0,0) >> CameraRotation;

	// add view radius offset to camera location and move viewpoint up from origin (amb)
	RealDist = Dist;
	Dist += CameraDeltaRad;

	if( Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation,false,vect(10,10,10) ) != none )
		ViewDist = FMin( (CameraLocation - HitLocation) dot View, Dist );
	else
		ViewDist = Dist;

	if ( !bBlockCloseCamera || !bValidBehindCamera || (ViewDist > 10 + FMax(ViewTarget.CollisionRadius, ViewTarget.CollisionHeight)) )
	{
		//Log("Update Cam ");
		bValidBehindCamera = true;
		OldCameraLoc = CameraLocation - ViewDist * View;
		OldCameraRot = CameraRotation;
	}
	else
	{
		//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
		SetRotation(OldCameraRot);
	}

	CameraLocation = OldCameraLoc;
	CameraRotation = OldCameraRot;

	// add view swivel rotation to cameraview (amb)
	GetAxes(CameraSwivel,globalX,globalY,globalZ);
	localX = globalX >> CameraRotation;
	localY = globalY >> CameraRotation;
	localZ = globalZ >> CameraRotation;
	CameraRotation = OrthoRotation(localX,localY,localZ);
}

//-----------------------------------------------------------------------------
// HandleWalking - Slightly more complicated walk conditions
//-----------------------------------------------------------------------------
// new handlewalking
function HandleWalking()
{
	local ROPawn P;

	P = ROPawn(Pawn);

	if (P == None)
		return;

	if (P.bIsCrawling)
		P.SetWalking(false);
	else if (P.bIronSights)
		P.SetWalking(true);
	else
		P.SetWalking(bRun != 0);

// MergeTODO: this could probably be handled better
	P.SetSprinting(bSprint != 0);
}

//-----------------------------------------------------------------------------
// override so that dead players cannot send voice messages
//-----------------------------------------------------------------------------

function bool AllowVoiceMessage(name MessageType)
{
    if(Pawn == None)
    {
       return false;
    }

    return super.AllowVoiceMessage(MessageType);
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function SendVoiceMessage(PlayerReplicationInfo Sender,
                          PlayerReplicationInfo Recipient,
                          name messagetype,
                          byte messageID,
                          name broadcasttype,
                          optional Pawn soundSender,
                          optional vector senderLocation)
{
	local Controller P;
    local ROPlayer ROP;
    local ROBot ROB;
    //local string msg;
    local float distanceToOther;
    // Bot vehicle message stuff
	local array<Controller> vehicleOccupants;
    local int i;

    //log("ROPlayer::SendVoiceMessage()");
	if ( !AllowVoiceMessage(MessageType) )
		return;

    if(messagetype == 'VEH_ORDERS' || messagetype == 'VEH_ALERTS' || messagetype == 'VEH_GOTO')
    {
      SendVehicleVoiceMessage(Sender,Recipient,messagetype,messageID,broadcasttype);

	    ROP = ROPlayer(Sender.Owner);
	    vehicleOccupants = GetBotVehicleOccupants(ROP);

	    for ( i =0; i<vehicleOccupants.length; i++ )
		{
		    ROB =  ROBot(vehicleOccupants[i]);

			if ( ROB != None )
			{
			    ROB.BotVoiceMessage(messagetype, messageID, self);
			}
		}
      return;
    }

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
	    ROP =  ROPlayer(P);

		if ( ROP != None )
		{
			if((Pawn != none) )
			{
				// do we want people who are dead to hear voice commands? - Antarian
                if( (ROP.Pawn != none) && (Pawn != ROP.Pawn) )
                {//other player
			        distanceToOther = VSize(Pawn.Location-ROP.Pawn.Location);
			        if(class'ROVoicePack'.static.isValidDistanceForMessageType(messagetype,distanceToOther))
			        {
			           //log("ROPlayer::SendVoiceMessage(), other player in range");

			           if (ROP.PlayerReplicationInfo.Team.TeamIndex == PlayerReplicationInfo.Team.TeamIndex)
			           {
			               // Same team; no need to send sender pawn
			               ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype,
                                                  messageID, none, senderLocation);
			           }
			           else
                           ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype,
                                                  messageID, soundSender, senderLocation);
			        }

                }
                else //sending to self
                {
                   ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype,
                                                  messageID, soundSender, senderLocation);
                }


       //dead men can't speak

            }
		}
		else if (((messagetype == 'ORDER') || (messagetype == 'ATTACK') || (messagetype == 'DEFEND'))
			 && ((Recipient == None) || (Recipient == P.PlayerReplicationInfo) ||
                 ( Bot(P) != none && Bot(P).Squad != none && Bot(P).Squad.SquadLeader != none &&
                   Bot(P).Squad.SquadLeader.PlayerReplicationInfo == Recipient)  ))
		{
			//log("Bot message area, messagetype = "$messagetype$" messageID = "$messageID);
			P.BotVoiceMessage(messagetype, messageID, self);
	    }
	}

	// Lets make the bots attack/defend particular objectives
    if ((messagetype == 'ATTACK') || (messagetype == 'DEFEND'))
    {
 		//TellBotsTo(messageID);
 		if (Recipient == none)
 		    ROTeamGame(Level.Game).SetTeamAIObjectives(messageID, PlayerReplicationInfo.Team.TeamIndex);
 		else
 		    ROTeamGame(Level.Game).SetSquadObjectives(messageID, PlayerReplicationInfo.Team.TeamIndex, Recipient);
 	}

    // Add to 'help request' array if needed
 	if (messagetype == 'ATTACK')
 	    AttemptToAddHelpRequest(PlayerReplicationInfo, messageID, 1, getObjectiveLocation(messageID)); // Send locations all the time (easier on hud drawing code)
 	else if (messagetype == 'DEFEND')
 	    AttemptToAddHelpRequest(PlayerReplicationInfo, messageID, 2, getObjectiveLocation(messageID)); // Ditto
 	else if (messagetype == 'HELPAT')
 	    AttemptToAddHelpRequest(PlayerReplicationInfo, messageID, 0, getObjectiveLocation(messageID)); // Idem
 	else if (messagetype == 'SUPPORT' && messageID == 0) // need help at coords
 	{
 	    if (Pawn != none)
 	        AttemptToAddHelpRequest(PlayerReplicationInfo, messageID, 4, Pawn.location);
 	}
 	else if (messagetype == 'SUPPORT' && messageID == 2) // need mg ammo
 	{
 	    if (Pawn != none)
 	        AttemptToAddHelpRequest(PlayerReplicationInfo, messageID, 3, Pawn.location);
 	}



	/*if(Sender.Team.TeamIndex == Level.GetLocalPlayerController().PlayerReplicationInfo.Team.TeamIndex)
    {
          msg = class'ROVoicePack'.static.getMessagePhraseFor(messagetype,messageID);
          TeamMessage(Sender,msg,'TEAMSAY');
    } */
}

// called server-side by SendVoiceMessage()
function AttemptToAddHelpRequest(PlayerReplicationInfo PRI, int objID, int requestType, optional vector requestLocation)
{
    local ROGameReplicationInfo GRI;
    local ROPlayerReplicationInfo RO_PRI;

    RO_PRI = ROPlayerReplicationInfo(PRI);
    if (RO_PRI == none || RO_PRI.RoleInfo == none)
        return;

    // Check if caller is a leader
    if (!RO_PRI.RoleInfo.bIsLeader)
    {
        // If not, check if we're a MG requesting ammo
        if (requestType != 3 || !RO_PRI.RoleInfo.bIsGunner)
            return;
    }

    GRI = ROGameReplicationInfo(GameReplicationInfo);
    if (GRI != none)
    {
        GRI.AddHelpRequest(PRI, objID, requestType, requestLocation);

        // Notify team members to check their map
        if (RO_PRI.Team != none)
            ROTeamGame(Level.Game).NotifyPlayersOfMapInfoChange(RO_PRI.Team.TeamIndex, self);
    }
}

// Return a vector corresponding to the specified objective's position
function vector getObjectiveLocation(int id)
{
    local ROGameReplicationInfo GRI;
    GRI = ROGameReplicationInfo(GameReplicationInfo);
    if (GRI == none)
        return vect(0,0,0);

    if (GRI.Objectives[id] != none) // Shouldn't be needed but you never know..
        return GRI.Objectives[id].Location;
    else
        return vect(0,0,0);
}

//===============================================================================
// SendVehicleVoiceMessage - new function to handle voice message send only
// to occupants of the same vehicle - MrMethane 01/10/2005
//===============================================================================
function SendVehicleVoiceMessage(PlayerReplicationInfo Sender,
                          PlayerReplicationInfo Recipient,
                          name messagetype,
                          byte messageID,
                          name broadcasttype)
{
    local ROPlayer ROP,P;
    local int i;
    local array<PlayerController> vehicleOccupants;

    P = ROPlayer(Sender.Owner);
    vehicleOccupants = GetVehicleOccupants(P);

    for ( i =0; i<vehicleOccupants.length; i++ )
	{
	    ROP =  ROPlayer(vehicleOccupants[i]);

		if ( ROP != None )
		{
               ROP.ClientLocationalVoiceMessage(Sender,Recipient,messagetype,messageID,Pawn);
		}
	}
}

//======================================================================================
// GetVehicleOccupants - Get all players in current vehicle - MrMethane 01/10/2005
//=====================================================================================
function array<PlayerController> GetVehicleOccupants(Controller Sender)
{
    local int i;
    local array<VehicleWeaponPawn> passengers;
    local ROVehicle v;
    local VehicleWeaponPawn weaponPawn;
    local PlayerController playerC,driver;
    local Pawn senderPawn;

    local array<PlayerController> allOccupants;

	senderPawn = PlayerController(Sender).Pawn;

    if(senderPawn != none && senderPawn.isA('ROVehicle'))
    {
        v = ROVehicle(senderPawn);
    }
    else if(senderPawn != none && senderPawn.isA('VehicleWeaponPawn'))
    {
        weaponPawn = VehicleWeaponPawn(Sender.Pawn);
        v = ROVehicle(weaponPawn.GetVehicleBase()); // get vehicle weapon pawn is attached to
    }

    if(v != None)
    {
        driver = PlayerController(v.Controller); // get vehicle controller

        if(driver != none)
        {
           AllOccupants[AllOccupants.length] = driver; // add driver
        }

        passengers = v.WeaponPawns;

        // get all passengers
        for(i=0; i < passengers.Length; i++)
        {
           playerC = PlayerController(passengers[i].Controller);

           if(playerC != none)
           {
              AllOccupants[AllOccupants.length] = playerC; // add driver
           }
        }
     }

     return AllOccupants;
}

//======================================================================================
// GetBotVehicleOccupants - Get all bots in current vehicle - Ramm
//=====================================================================================

function array<ROBot> GetBotVehicleOccupants(Controller Sender)
{
    local int i;
    local array<VehicleWeaponPawn> passengers;
    local ROVehicle v;
    local VehicleWeaponPawn weaponPawn;
    local ROBot driver, botC;
    local Pawn senderPawn;

    local array<ROBot> allOccupants;

	senderPawn = PlayerController(Sender).Pawn;

    if(senderPawn.isA('ROVehicle'))
    {
        v = ROVehicle(senderPawn);
    }
    else if(senderPawn.isA('VehicleWeaponPawn'))
    {
        weaponPawn = VehicleWeaponPawn(Sender.Pawn);
        v = ROVehicle(weaponPawn.GetVehicleBase()); // get vehicle weapon pawn is attached to
    }

    if(v != None)
    {
        driver = ROBot(v.Controller); // get vehicle controller

        if(driver != none)
        {
           AllOccupants[AllOccupants.length] = driver; // add driver
        }

        passengers = v.WeaponPawns;

        // get all passengers
        for(i=0; i < passengers.Length; i++)
        {
           botC = ROBot(passengers[i].Controller);

           if(botC != none)
           {
              AllOccupants[AllOccupants.length] = botC; // add driver
           }
        }
     }

     return AllOccupants;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function ClientLocationalVoiceMessage(PlayerReplicationInfo Sender,
                                      PlayerReplicationInfo Recipient,
                                      name messagetype, byte messageID,
                                      optional Pawn senderPawn, optional vector senderLocation)
{
    local VoicePack voice;
    local ROVoicePack V;
    local bool isTeamVoice;
    local class<ROVoicePack> rov;
    local ROPlayerReplicationInfo playerRepInfo;

    isTeamVoice = false;

    if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
        return;

    if (//Level.NetMode ==  NM_ListenServer ||
        Level.NetMode ==  NM_DedicatedServer)
    {
          return;
    }

    //if the sender is receiving the sound then allow them to hear the
    //voicepack from their settings instead of the regular voicepack
    playerRepInfo = ROPlayerReplicationInfo(Sender);
    if(playerRepInfo != none && playerRepInfo.RoleInfo != none)
    {
        if( Level.GetLocalPlayerController().PlayerReplicationInfo.Team == none ||
			Sender.Team.TeamIndex == Level.GetLocalPlayerController().PlayerReplicationInfo.Team.TeamIndex)
        {
            rov = class<ROVoicePack>(DynamicLoadObject(playerRepInfo.RoleInfo.AltVoiceType,class'Class'));
            isTeamVoice = true;
            V = Spawn(rov, self);
        }
        else
        {
            rov = class<ROVoicePack>(DynamicLoadObject(playerRepInfo.RoleInfo.VoiceType,class'Class'));
            //log("different team, send native voice");
            V = Spawn(rov, self);
            if (V != none)
            {
                v.bUseLocationalVoice = true;
                v.bIsFromDifferentTeam = true;
            }
        }

        if(V != none)
        {
            V.ClientInitializeLocational(Sender, Recipient, messagetype, messageID, senderPawn, senderLocation);
            if(isTeamVoice)
            {
                if(MessageType == 'VEH_ORDERS' || MessageType == 'VEH_ALERTS' || MessageType == 'VEH_GOTO')
                    VehicleMessage(Sender, V.getClientParsedMessage());
                else if (MessageType == 'TAUNT')
                    TeamMessage(Sender,V.getClientParsedMessage(),'SAY');
                    //ServerSay(V.getClientParsedMessage());
                else
                    TeamMessage(Sender,V.getClientParsedMessage(),'TEAMSAY');
            }
        }

    }
    else
    {
       voice = Spawn(Sender.voicetype, self);
       if ( voice != None )
       {
          log("Fallback: voice.ClientInitialize(Sender, Recipient, messagetype, messageID);");
          voice.ClientInitialize(Sender, Recipient, messagetype, messageID);
       }
    }
}

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
// Overload to allow reverting FOV back to default
exec function ThrowWeapon()
{
    //Ramm: Refactor
    // The way this works stinks, lets replace it with something good
    //local RORocketWeapon myRocket;

    // Dont reset the FOV if the player is in a vehicle
    //log("Pawn is  "$pawn);
/*    if( Pawn.IsA('ROVehicleWeaponPawn'))
    {
        //log("Returning because Pawn.IsA ROVehicleWeaponPawn");
        return;
    }*/

    if ((SVehicle(Pawn) != none) || (VehicleWeaponPawn(Pawn) != none) )
    {
       //log("Returning because you can't throw out your vehicle weapon");
       return;
    }

    ResetFOV();  // resets the FOV if weapon was zoomed

    if ( (Pawn == None) || (Pawn.Weapon == None) )
        return;


    // this is a special check just for panzerfausts
    // it may need to be moved but I think it needs to be
    // done on the client before going to the server

    //Ramm: Refactor
    // The way this works stinks, lets replace it with something good
	/*
    if( (RORocketWeapon(Pawn.Weapon) != None) )
    {
         myRocket = RORocketWeapon(Pawn.Weapon);
         if((myRocket.RocketAttachment == None) && (myRocket.AmmoAmount(0) > 0))
         {
             Pawn.NextWeapon();
             return;
         }
    }
	*/
    ServerThrowWeapon();
}

// mostly same as ShowMenu in PlayerController, but added support for closing situation map
exec function ShowMenu()
{
	local bool bCloseHUDScreen;

	if ( MyHUD != None )
	{
		bCloseHUDScreen = MyHUD.bShowScoreboard || MyHUD.bShowLocalStats ||
            (ROHud(MyHUD) != none && ROHud(MyHUD).bShowObjectives);
		if ( MyHUD.bShowScoreboard )
			MyHUD.bShowScoreboard = false;
		if ( MyHUD.bShowLocalStats )
			MyHUD.bShowLocalStats = false;
		if ( ROHud(MyHUD) != none && ROHud(MyHUD).bShowObjectives )
		    ROHud(MyHUD).HideObjectives();

		if ( bCloseHUDScreen )
			return;
	}

	ShowMidGameMenu(true);
}

/*function ClientSetBehindView(bool B)
{
    //If we're driving a vehicle and we're switching to the behind view, show the exterior mesh
    if ( ROVehicle(Pawn) != none )
    	ROVehicle(Pawn).SwitchToExteriorMesh();

    //If we're a gunner in a vehicle and we're switching to the behind view, show the exterior mesh
    else if ( ROVehicleWeaponPawn(Pawn) != none )
    	ROVehicleWeaponPawn(Pawn).SwitchToExteriorMesh();

    super.ClientSetBehindView(B);
}*/

//=============================================================================
// States
//=============================================================================

//-----------------------------------------------------------------------------
// PlayerWalking
//-----------------------------------------------------------------------------
state PlayerWalking
{
	ignores SeePlayer, HearNoise, Bump;

	// Prevent spectating changes after the players spawns. Fixes the "Spectating Bug"
    function ServerViewNextPlayer(){}
    function ServerNextViewPoint(){}
    function ServerChangeSpecMode(){}
	function ServerRequestPOVChange(){/*log("ServerRequestPOVChange in state "$GetStateName());*/}
	function HandlePOVChange(){}

	function ClientSetBehindView(bool B)
	{
		if( B && Role < ROLE_Authority )
		{
			ServerCancelBehindview();
			return;
		}

		super.ClientSetBehindView(B);
	}


	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	exec function Fire( optional float F )
	{
	    if (bHudCapturesMouseInputs)
	        HandleMouseClick();
	    else
	        super.Fire(F);
	}

	// Client side
	function PlayerMove( float DeltaTime )
	{
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;
		local ROPawn P;

		P = ROPawn(Pawn);

        if (P == None)
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        if (bHudCapturesMouseInputs)
            HandleMousePlayerMove(DeltaTime);

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
        NewAccel = aForward*X + aStrafe*Y;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

		//DoubleClickMove = PlayerInput.CheckForDoubleClickMove(1.1*DeltaTime/Level.TimeDilation);

        GroundPitch = 0;
        ViewRotation = Rotation;

        if ( Pawn.Physics == PHYS_Walking )
        {
			// Take the bipod weapon out of deployed if the player tries to move
 			if( Pawn.bBipodDeployed && NewAccel != vect(0,0,0) )
 			{
 				ROBipodWeapon(Pawn.Weapon).ForceUndeploy();
 			}

            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
             if ( (bLook == 0)
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
            {
                if ( bLookUpStairs || bSnapToLevel )
                {
                    GroundPitch = FindStairRotation(deltaTime);
                    ViewRotation.Pitch = GroundPitch;
                }
            }
        }

        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local ROPawn P;

		P = ROPawn(Pawn);

		if (P == None)
			return;

		OldAccel = Pawn.Acceleration;

        // WeaponTODO: Bipod system
//		if ((ROMasterWeapon(Pawn.Weapon) != None) && ROMasterWeapon(Pawn.Weapon).IsMounted())
//		{
//			NewAccel = vect(0,0,0);
//		}

		if (Pawn.Acceleration != NewAccel)
			Pawn.Acceleration = NewAccel;

		// Take away stamina from jumping
		if (bPressedJump)
		{
			P.DoJump(bUpdating);
		}

		Pawn.SetViewPitch(Rotation.Pitch);

		if ( Pawn.Physics != PHYS_Falling )
		{
			if (bDuck == 0 )
				Pawn.ShouldCrouch(false);
			else if ( Pawn.bCanCrouch )
				Pawn.ShouldCrouch(true);

			if (bCrawl == 0)
				Pawn.ShouldProne(false);
			else if ( Pawn.bCanProne )
				Pawn.ShouldProne(true);
		}
	}

	function BeginState()
	{
	   	DoubleClickDir = DCLICK_None;
	   	bPressedJump = false;
	   	GroundPitch = 0;
		if ( Pawn != None )
		{
			if ( Pawn.Mesh == None )
				Pawn.SetMesh();
			Pawn.ShouldCrouch(false);

			// Not sure if we need this or not - Ramm
			Pawn.ShouldProne(false);

			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Karma) // FIXME HACK!!!
				Pawn.SetPhysics(PHYS_Walking);
		}

		// This is the magic right here. This can fix the player view bug where you are stuck view someone else
	    if( Role==ROLE_Authority )
	    {
		    if( Pawn!=none )
		    {
				SetViewTarget(Pawn);
				ClientSetViewTarget(Pawn);
			}
			else
			{
				SetViewTarget(self);
				ClientSetViewTarget(self);
			}

		    ClientSetBehindView(false);
	    }

	    // Hint!
	    CheckForHint(0); // player respawned
	 }

	function EndState()
	{

		GroundPitch = 0;
		if ( Pawn != None )
		{
			if( bDuck==0 )
				Pawn.ShouldCrouch(false);

			// Not sure if we need this or not - Ramm
			if( bCrawl==0 )
				Pawn.ShouldProne(false);
		}
	}
}

state Spectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    // Return to spectator's own camera.
    exec function Jump( optional float F )
    {
		if( ViewTarget != self && CanRequestSpectateChange() )
		{
	    	ServerViewSelf();
    	}
    }

    event PlayerTick( float DeltaTime )
    {
        super.PlayerTick( DeltaTime );

        if ( Level.NetMode != NM_DedicatedServer && ViewTarget != none && !bBehindView)
        {
           if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
           {
                bBehindView = true;
                super.ClientSetBehindView(bBehindView);
           }
        }
    }

    // Cycle view positions
	exec function Fire( optional float F )
    {
    	if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}

		if (SpecMode == SPEC_Players)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerViewNextPlayer();
		}
	 	else if (SpecMode == SPEC_ViewPoints)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerNextViewPoint();
		}

		if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
    }

    // switch spectating modes
    exec function AltFire( optional float F )
    {
    	if ( CanRequestSpectateChange() )
			ServerChangeSpecMode();

		if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
    }

	simulated exec function ROIronSights()
	{
		if ( CanRequestSpectateChange() )
		{
			ServerRequestPOVChange();
		}
	}

    function Timer()
    {
    	bFrozen = false;
    }

	function HandlePOVChange()
	{
		if( Role == ROLE_Authority && !ROTeamGame(Level.Game).bSpectateFirstPersonOnly && Pawn(ViewTarget) != none)
		{
			bBehindView = !bBehindView;
			ClientSetBehindView(bBehindView);
		}

		if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
	}

    function PlayerMove(float DeltaTime)
    {

        local vector X,Y,Z;

        if( SpecMode == SPEC_ViewPoints )
        {
	        if ( ViewTarget != None )
	            SetRotation(ViewTarget.Rotation);
	    }
	    else
	    {
			if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
			{
				if ( Pawn(ViewTarget).bSimulateGravity )
					TargetViewRotation.Roll = 0;
				BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
				BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
				BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
			}
	        GetAxes(Rotation,X,Y,Z);

	        Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

	        UpdateRotation(DeltaTime, 1);
    	}

        if( SpecMode == SPEC_Self || SpecMode == SPEC_ViewPoints || !bAllowRoamWhileSpectating )
        {
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else
		{
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        }
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        bCollideWorld = true;
		CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	function bool IsSpectating()
	{
		return false;
	}

	// new calcview stuff to handle our death camera
	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		if ( ROPawn(ViewTarget) != none && !bBehindView )
	    {
			ViewActor = ViewTarget;

            CalcFirstPersonView( CameraLocation, CameraRotation );

			CacheCalcView(ViewActor,CameraLocation,CameraRotation);
	        return;
	    }
	    else
	    {
			super.PlayerCalcView( ViewActor, CameraLocation, CameraRotation);
		}
	}

    // New calcview stuff to handle our death camera
	function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
	{
		local ROPawn rpawn;
		local rotator ViewRot;
		local coords C;

		RPawn = ROPawn(ViewTarget);

		if( RPawn != none )
		{
            C = ViewTarget.GetBoneCoords(RPawn.HeadBone);

            // Rotate the view the proper direction
            ViewRot = OrthoRotation( -C.YAxis, -C.ZAxis, C.XAxis );

			CameraRotation = ViewRot;
			CameraLocation = ViewTarget.GetBoneCoords(RPawn.HeadBone).Origin;
		}
	}

	function ServerRequestDeadSpectating()
	{
      	GotoState('DeadSpectating');
	}

	exec function ThrowWeapon()
	{
		//clientmessage("Throwweapon while dead, pawn "$Pawn$" health "$Pawn.health);
	}

	function bool IsDead()
	{
		return true;
	}

	function ServerReStartPlayer()
	{
		if ( !Level.Game.PlayerCanRestart( Self ) )
			return;

		super.ServerRestartPlayer();
	}

    exec function Fire( optional float F )
    {
		if ( myHUD != None )
			myHUD.bShowScoreBoard = false;
		if( !bBehindView && !bFirstPersonSpectateOnly)
		{
			if (ROHud(myHud) != None)
				ROHud(myHud).StopFadeEffect();

 			if (Pawn(ViewTarget) != None)
 			{
				Pawn(ViewTarget).SetHeadScale(Pawn(ViewTarget).default.HeadScale);
				ViewTarget.bHidden = false;
			}

		  	bBehindView = true;
		  	bBlockCloseCamera = true;
		  	bValidBehindCamera = false;
		  	FindGoodView();
		}
		else if ( CanRequestSpectateChange() && (!bFirstPersonSpectateOnly || VSizeSquared(ViewTarget.Velocity) <= 2.0))
		{
			ServerRequestDeadSpectating();
		}

		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
           /*
        LoadPlayers();

        if (bMenuBeforeRespawn)
        {
        	bMenuBeforeRespawn = false;
       		ShowMidGameMenu(false);
        }
        else
	        ServerReStartPlayer();*/
    }

    exec function AltFire( optional float F )
    {
    	Fire(F);
    }

    exec function Use()
    {
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		if ( Level.Game != None )
			Level.Game.DeadUse(self);
    }

	function ServerMove
	(
	    float TimeStamp,
	    vector InAccel,
	    vector ClientLoc,
		byte NewActions,
	    eDoubleClickDir DoubleClickMove,
	    byte ClientRoll,
	    int View,
	    optional int FreeAimRot,
	    optional byte OldTimeDelta,
	    optional int OldAccel
	)
    {
        Global.ServerMove(
                    TimeStamp,
                    InAccel,
                    ClientLoc,
                    0,
                    DoubleClickMove,
                    ClientRoll,
                    View);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local rotator ViewRotation;

        if ( !bFrozen )
        {
            if ( bPressedJump )
            {
                Fire(0);
                bPressedJump = false;
            }
            GetAxes(Rotation,X,Y,Z);
            // Update view rotation.
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            if (Pawn != None)
	            ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch, DeltaTime);
            SetRotation(ViewRotation);
            if ( Role < ROLE_Authority ) // then save this move and replicate it
                ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        }
        else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
			bFrozen = false;

        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ////log("Find good death scene view");
        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        if (!bFrozen)
            return;

        bFrozen = false;
        bPressedJump = false;
    }

    function BeginState()
    {
		local Actor A;

		if ( (Pawn != None) && ((Pawn.Controller == self) || (Pawn.Controller == None)) )
			Pawn.Controller = None;
		EndZoom();
		CameraDist = Default.CameraDist;
		FOVAngle = DesiredFOV;
		Pawn = None;
        Enemy = None;
        //bBehindView = true;
        bFrozen = true;
		bJumpStatus = false;
        bPressedJump = false;
        //bBlockCloseCamera = true;
		//bValidBehindCamera = false;
		bFreeCamera = False;
		if ( Viewport(Player) != None )
			foreach DynamicActors(class'Actor',A)
				A.NotifyLocalPlayerDead(self);
        //FindGoodView();
        SetTimer(1.0, false);
		StopForceFeedback();
		ClientPlayForceFeedback("Damage");  // jdf
		CleanOutSavedMoves();

		if( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
		    bBehindView = true;
		    bValidBehindCamera = false;
		    FindGoodView();
		}

		// First person death
		// View your own body during first person death. Have to scale the head down so
		// you don't see the back of your face
		if (!bBehindView && Level.NetMode != NM_DedicatedServer )
		{
			if ( Pawn(ViewTarget) != none && !Pawn(ViewTarget).IsA('Vehicle'))
			{
				ViewTarget.bOwnerNoSee = false;
				Pawn(ViewTarget).SetHeadScale(0.1);
			}
		}

        // Check hint
        CheckForHint(5);

		if (ROHud(myHud) != None)
			ROHud(myHud).StartFadeEffect();
    }

    function EndState()
    {
		StopForceFeedback();
		bBlockCloseCamera = false;
		CleanOutSavedMoves();
        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        if ( !PlayerReplicationInfo.bOutOfLives )
			bBehindView = false;
        bPressedJump = false;
        if ( myHUD != None )
			myHUD.bShowScoreBoard = false;

		StopViewShaking();

		if (Pawn(ViewTarget) != None)
			Pawn(ViewTarget).SetHeadScale(Pawn(ViewTarget).default.HeadScale);

		if (!bBehindView && Level.NetMode != NM_DedicatedServer)
		{
			if (Pawn(ViewTarget) != None)
				ViewTarget.bHidden = false;
		}

		if (ROHud(myHud) != None)
			ROHud(myHud).StopFadeEffect();

    }

Begin:
    if( Level.NetMode != NM_DedicatedServer)
    {
	    Sleep(3.0);
		if ( (ViewTarget == None) || (ViewTarget == self) && (VSizeSquared(ViewTarget.Velocity) > 2.0) )
		{
			Sleep(1.0);
			if ( myHUD != None )
				myHUD.bShowScoreBoard = true;
		}
		else if ( VSizeSquared(ViewTarget.Velocity) <= 2.0)
		{
			ServerRequestDeadSpectating();
		}
		else
			Goto('Begin');
	}
	else
	{
		Sleep(10.0);
		GotoState('DeadSpectating');
	}
}

state DeadSpectating extends Spectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

	function bool IsDead()
	{
		return true;
	}

    event PlayerTick( float DeltaTime )
    {
        super.PlayerTick( DeltaTime );

        if( Level.NetMode != NM_DedicatedServer && !bViewBlackWhenDead && bViewBlackOnDeadNotViewingPlayers)
        {
            if ( Pawn(ViewTarget) == none )
            {
        		if (ROHud(myHud) != None)
        			ROHud(myHud).ForceFadeEffect();
            }
            else
            {
        		if (ROHud(myHud) != None)
        			ROHud(myHud).StopFadeEffect();
            }
        }
    }

    // return to spectator's own camera.
    exec function Jump( optional float F )
    {
		if( ViewTarget != self && CanRequestSpectateChange())
		{
	    	ServerViewSelf();
    	}
    }

    // Cycle view positions
	exec function Fire( optional float F )
    {
    	if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}

		if (SpecMode == SPEC_Players)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerViewNextPlayer();
		}
	 	else if (SpecMode == SPEC_ViewPoints)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerNextViewPoint();
		}

		if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
    }

    // switch spectating modes
    exec function AltFire( optional float F )
    {
    	if ( CanRequestSpectateChange() )
			ServerChangeSpecMode();

        if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
    }

	simulated exec function ROIronSights()
	{
		if ( CanRequestSpectateChange() )
		{
			ServerRequestPOVChange();
		}
	}

	function ServerViewSelf()
	{
		// Don't allow the player to start roaming if they aren't supposed to roam
		if( (!ROTeamGame(Level.Game).bSpectateAllowRoaming || !ROTeamGame(Level.Game).bSpectateAllowDeadRoaming )
            && PlayersToSpectate() )
		{
			return;
		}

		SetLocation(ViewTarget.Location);
		ClientSetLocation(ViewTarget.Location, Rotation);

	    bBehindView = false;
	    SetViewTarget(self);
	    ClientSetViewTarget(self);
	    ClientMessage(OwnCamera, 'Event');
	}


    function Timer()
    {
    	bFrozen = false;
    }

	function HandlePOVChange()
	{
		if( Role == ROLE_Authority && !ROTeamGame(Level.Game).bSpectateFirstPersonOnly && Pawn(ViewTarget) != none)
		{
			bBehindView = !bBehindView;
			ClientSetBehindView(bBehindView);
		}

		if ( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
        	bBehindView = true;
            super.ClientSetBehindView(bBehindView);
		}
	}

    function PlayerMove(float DeltaTime)
    {

        local vector X,Y,Z;

        if( SpecMode == SPEC_ViewPoints )
        {
	        if ( ViewTarget != None )
	            SetRotation(ViewTarget.Rotation);
	    }
	    else
	    {
			if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
			{
				if ( Pawn(ViewTarget).bSimulateGravity )
					TargetViewRotation.Roll = 0;
				BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
				BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
				BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
			}

	        GetAxes(Rotation,X,Y,Z);

	        Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

	        UpdateRotation(DeltaTime, 1);
    	}

        if( SpecMode == SPEC_Self || SpecMode == SPEC_ViewPoints || !bAllowRoamWhileSpectating || !bAllowRoamWhileDeadSpectating)
        {
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else
		{
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        }
    }

    function BeginState()
    {
		if( Role == ROLE_Authority )
		{
			bBehindView = false;
			ClientSetBehindView(bBehindView);

		   	SpecMode = SPEC_Self;
			ServerChangeSpecMode();
		}

        bCollideWorld = true;
		CameraDist = Default.CameraDist;

        if( bViewBlackWhenDead )
        {
    		if (ROHud(myHud) != none)
    		{
    			ROHud(myHud).ForceFadeEffect();
    		}
		}

		if( Pawn(ViewTarget) != none && Pawn(ViewTarget).IsA('Vehicle') )
		{
		    bBehindView = true;
		    bValidBehindCamera = false;
		}
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;

		if (ROHud(myHud) != None)
		{
			ROHud(myHud).StopFadeEffect();
		}


    }
}

//-----------------------------------------------------------------------------
// PlayerWaiting - Don't allow fire to respawn
//-----------------------------------------------------------------------------

auto state PlayerWaiting
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, /*NextWeapon, PrevWeapon,*/ SwitchToBestWeapon;

	//Return to spectator's own camera.
    exec function Jump( optional float F )
    {
		if( ViewTarget != self && CanRequestSpectateChange() )
		{
	    	ServerViewSelf();
    	}
    }

    exec function Suicide()
    {
    }

    function ServerRestartPlayer()
    {
        if ( Level.TimeSeconds < WaitDelay )
            return;
        if ( Level.NetMode == NM_Client )
            return;
        if ( Level.Game.bWaitingToStartMatch )
            PlayerReplicationInfo.bReadyToPlay = true;
        else
            Level.Game.RestartPlayer(self);
    }

    exec function Fire( optional float F )
    {
		if (SpecMode == SPEC_Players)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerViewNextPlayer();
		}
	 	else if (SpecMode == SPEC_ViewPoints)
		{
	 		 if ( CanRequestSpectateChange() )
			 	ServerNextViewPoint();
		}
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
    	if ( CanRequestSpectateChange() )
			ServerChangeSpecMode();
    }

	simulated exec function ROIronSights()
	{
		if ( CanRequestSpectateChange() )
		{
			ServerRequestPOVChange();
		}
	}

	function HandlePOVChange()
	{
		if( Role == ROLE_Authority && ViewTarget != self && !ROTeamGame(Level.Game).bSpectateFirstPersonOnly && Pawn(ViewTarget) != none )
		{
			bBehindView = !bBehindView;
			ClientSetBehindView(bBehindView);
		}
	}

	function bool CanRestartPlayer()
    {
    	return Global.CanRestartPlayer();
    }

    function PlayerMove(float DeltaTime)
    {

        local vector X,Y,Z;

        if( SpecMode == SPEC_ViewPoints )
        {
	        if ( ViewTarget != None )
	            SetRotation(ViewTarget.Rotation);
	    }
	    else
	    {
			if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
			{
				if ( Pawn(ViewTarget).bSimulateGravity )
					TargetViewRotation.Roll = 0;
				BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
				BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
				BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
			}
	        GetAxes(Rotation,X,Y,Z);

	        Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

	        UpdateRotation(DeltaTime, 1);
    	}

        if( SpecMode == SPEC_Self || SpecMode == SPEC_ViewPoints || !bAllowRoamWhileSpectating )
        {
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else
		{
	        if ( Role < ROLE_Authority ) // then save this move and replicate it
	            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	        else
	            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        }
    }

    simulated function Timer()
    {
        if (!bPendingMapDisplay || bDemoOwner)
        {
            SetTimer(0, false);
        }
        else if(Player != None && GUIController(Player.GUIController) != None && !GUIController(Player.GUIController).bActive)
	    {
		    bPendingMapDisplay = false;
		    SetTimer(0, false);
            PlayerMenu();

            // We init the hint manager here because it needs to be
            // initialized after the Player variables has been set
            UpdateHintManagement(bShowHints);
		}
    }

    function EndState()
    {
        bFrozen = false;
		if ( Pawn != None )
            Pawn.SetMesh();
        if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
        bCollideWorld = false;
    }

    // hax to open menu when player joins the game
    simulated function BeginState()
    {
        if (Role == Role_Authority)
        {
    		CameraDist = Default.CameraDist;
            if ( PlayerReplicationInfo != None )
                PlayerReplicationInfo.SetWaitingPlayer(true);
            bCollideWorld = true;
            bFrozen = true;
        }

		if( Level.NetMode != NM_DedicatedServer )
		{
			ResetBlur();
		}

        if (Level.NetMode != NM_DedicatedServer && bPendingMapDisplay)
        {
            SetTimer(0.1, true);
            Timer();
        }
    }
}


//-----------------------------------------------------------------------------
// GameEnded
//-----------------------------------------------------------------------------

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	function ServerReStartPlayer()
	{
	}

	function bool IsSpectating()
	{
		return true;
	}

    exec function ThrowWeapon()
    {
    }

    function ServerReStartGame()
    {
        Level.Game.RestartGame();
    }

    exec function Fire( optional float F )
    {
        if ( Role < ROLE_Authority)
            return;
        if ( !bFrozen )
            ServerReStartGame();
        //else if ( TimerRate <= 0 )
         //   SetTimer(1.5, false);
    }

    exec function AltFire( optional float F )
    {
        Fire(F);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
       // local Rotator ViewRotation;

        GetAxes(Rotation,X,Y,Z);
        // Update view rotation.

        /*if ( !bFixedCamera )
        {
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch,DeltaTime); //amb
            SetRotation(ViewRotation);
        }
        else*/ if ( ViewTarget != None )
            SetRotation(ViewTarget.Rotation);

        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        bPressedJump = false;
    }

	function ServerMove
	(
	    float TimeStamp,
	    vector InAccel,
	    vector ClientLoc,
		byte NewActions,
	    eDoubleClickDir DoubleClickMove,
	    byte ClientRoll,
	    int View,
	    optional int FreeAimRot,
	    optional byte OldTimeDelta,
	    optional int OldAccel
	)
    {
        Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewActions,
                            DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)) );
    }

    function FindGoodView()
    {
        /*local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);*/
    }

    function Timer()
    {
        bFrozen = false;
    }

	/*function LongClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX,
		float NewLocY,
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
	}*/

    function BeginState()
    {
        local Pawn P;

        EndZoom();
        FOVAngle = DesiredFOV;
        bFire = 0;
        bAltFire = 0;
        if ( Pawn != None )
        {
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
			Pawn.AmbientSound = None;
			Pawn.bSpecialHUD = false;
 			Pawn.bNoWeaponFiring = true;
            Pawn.SimAnim.AnimRate = 0;
            Pawn.bPhysicsAnimUpdate = false;
            Pawn.bIsIdle = true;
            Pawn.bWaitForAnim = false;
            Pawn.StopAnimating();
            Pawn.SetCollision(true,false,false);
            if ( Pawn.Weapon != None )
            {
				Pawn.Weapon.StopFire(0);
				Pawn.Weapon.StopFire(1);
				Pawn.Weapon.ClientState = WS_Hidden;
			}
 			Pawn.bIgnoreForces = true;
       }
        bFrozen = true;
        /*if ( !bFixedCamera )
        {
            FindGoodView();
            bBehindView = true;
        }*/
        SetTimer(5, false);
        foreach DynamicActors(class'Pawn', P)
        {
			if ( P.Role == ROLE_Authority )
				P.RemoteRole = ROLE_DumbProxy;
			P.SetCollision(true,false,false);
			P.AmbientSound = None;
 			P.bNoWeaponFiring = true;
            P.Velocity = vect(0,0,0);
            P.SetPhysics(PHYS_None);
            P.bPhysicsAnimUpdate = false;
            P.bIsIdle = true;
            P.bWaitForAnim = false;
            P.StopAnimating();
            P.bIgnoreForces = true;
        }
    }

Begin:
    if ( myHUD != None )
	    myHUD.bShowScoreBoard = true;
}

//-----------------------------------------------------------------------------
// PlayerTurreting - Overriden to allow yaw limitation
//-----------------------------------------------------------------------------

state PlayerTurreting
{
ignores SeePlayer, HearNoise, Bump;

	function CallServerMove
	(
	    float TimeStamp,
	    vector InAccel,
	    vector ClientLoc,
	    bool NewbRun,
	    bool NewbDuck,
	    bool NewbPendingJumpStatus,
	    bool NewbJumpStatus,
	    bool NewbSprint,
		bool NewbCrawl,
	    eDoubleClickDir DoubleClickMove,
	    byte ClientRoll,
	    int View,
	    optional int FreeAimRot,
	    optional byte OldTimeDelta,
	    optional int OldAccel
	)
	{

		if ( PendingMove != None )
		{
			DualTurretServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.bDuck,
		        ((PendingMove.Rotation.Roll >> 8) & 255),
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View,
				FreeAimRot
			);
		}
		else
			TurretServerMove
			(
				TimeStamp,
				ClientLoc,
				NewbDuck,
				ClientRoll,
				View,
				FreeAimRot
			);
	}

	/* ServerMove()
	- replicated function sent by client to server - contains client movement and firing info
	Passes acceleration in components so it doesn't get rounded.
	IGNORE VANILLA SERVER MOVES
	*/
	function ServerMove
	(
	    float TimeStamp,
	    vector InAccel,
	    vector ClientLoc,
		byte NewActions,
	    eDoubleClickDir DoubleClickMove,
	    byte ClientRoll,
	    int View,
	    optional int FreeAimRot,
	    optional byte OldTimeDelta,
	    optional int OldAccel
	)
	{
		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
			return;

		if ( AcknowledgedPawn != Pawn )
		{
			OldTimeDelta = 0;
			InAccel = vect(0,0,0);
		}

		if ( AcknowledgedPawn == Pawn && CurrentTimeStamp < TimeStamp )
	       Pawn.AutonomousPhysics(TimeStamp - CurrentTimeStamp);
		CurrentTimeStamp = TimeStamp;
		ServerTimeStamp = Level.TimeSeconds;
	}

	function TurretServerMove
	(
		float	TimeStamp,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View,
		optional int FreeAimRot
	)
	{
		local byte NewActions;
		local int FreeAimPitch, FreeAimYaw;
		local rotator NewFreeAimRot;

		if( Pawn != none )
		{
		    // Free-aim vars
		    FreeAimPitch = FreeAimRot/32768;
			FreeAimYaw = 2 * (FreeAimRot - 32768 * FreeAimPitch);
			FreeAimPitch *= 2;

			NewFreeAimRot.Pitch  = FreeAimPitch;
			NewFreeAimRot.Yaw  = FreeAimYaw;

	        if( Pawn.IsA('VehicleWeaponPawn'))
	        {
	            VehicleWeaponPawn(Pawn).CustomAim = NewFreeAimRot;
	        }
		}

		// Put together new actions to send (compressed into one byte)
		if (NewbDuck)
			NewActions += 2;

		Global.ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,NewActions, DCLICK_NONE,ClientRoll,View,FreeAimRot);
	}

	/* DualTurretServerMove()
	compressed version of server move for PlayerTurreting state
	*/
	function DualTurretServerMove
	(
		float	TimeStamp0,
		bool	NewbDuck0,
		byte	ClientRoll0,
		int		View0,
		float	TimeStamp,
		vector	ClientLoc,
		bool	NewbDuck,
		byte	ClientRoll,
		int		View,
		optional int FreeAimRot
	)
	{
		local byte NewActions, NewActions0;
		local int FreeAimPitch, FreeAimYaw;
		local rotator NewFreeAimRot;

		if( Pawn != none )
		{
		    // Free-aim vars
		    FreeAimPitch = FreeAimRot/32768;
			FreeAimYaw = 2 * (FreeAimRot - 32768 * FreeAimPitch);
			FreeAimPitch *= 2;

			NewFreeAimRot.Pitch  = FreeAimPitch;
			NewFreeAimRot.Yaw  = FreeAimYaw;

	        if( Pawn.IsA('VehicleWeaponPawn'))
	        {
	            VehicleWeaponPawn(Pawn).CustomAim = NewFreeAimRot;
	        }
		}

		// Put together new actions to send (compressed into one byte)
		if (NewbDuck)
			NewActions += 2;

		if (NewbDuck0)
			NewActions0 += 2;

		Global.ServerMove(TimeStamp0,Vect(0,0,0),vect(0,0,0),NewActions0, DCLICK_NONE,ClientRoll0,View0,FreeAimRot);
		Global.ServerMove(TimeStamp,Vect(0,0,0),ClientLoc,NewActions, DCLICK_NONE,ClientRoll,View,FreeAimRot);
	}

	exec function Fire( optional float F )
	{
	    if (bHudCapturesMouseInputs)
	        HandleMouseClick();
	    else
	        super.Fire(F);
	}

    function PlayerMove(float DeltaTime)
    {
        local Vehicle CurrentVehicle;
        local rotator TempRot;
        local ROVehicleWeapon VehWep;

		if ( Pawn == None )
		{
			GotoState('dead');
			return;
		}

		if (bHudCapturesMouseInputs)
            HandleMousePlayerMove(DeltaTime);

		Pawn.UpdateRocketAcceleration(DeltaTime, aTurn, aLookUp);
		Pawn.HandleTurretRotation(DeltaTime, aStrafe, aForward);
		// RO - We don't allow freecamera suckaz.
		// This bit here is for limiting MG/Turret rotation
		if ( !bFreeCamera )
		{
			TempRot =  Pawn.Rotation;

	        if( Pawn.IsA('VehicleWeaponPawn'))
	        {
	            VehWep = ROVehicleWeapon(VehicleWeaponPawn(Pawn).Gun);

	            if ( VehWep !=none )
	            {
	                TempRot.Yaw = VehWep.LimitYaw(TempRot.Yaw);
	                Pawn.SetRotation( TempRot );
	            }
	        }
			SetRotation( TempRot );
		}

		ViewShake( deltaTime );
        ViewFlash( deltaTime );

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));

		CurrentVehicle = Vehicle(Pawn);
		if ( CurrentVehicle != None )
		{
			if ( bFire == 0 && CurrentVehicle.bWeaponIsFiring )
				CurrentVehicle.ClientVehicleCeaseFire( false );

			if ( bAltFire == 0 && CurrentVehicle.bWeaponIsAltFiring )
				CurrentVehicle.ClientVehicleCeaseFire( true );
		}
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn == None )
			return;

		Pawn.Acceleration = newAccel;
	}

    function BeginState()
    {
		if ( Pawn != None )
		{
			Pawn.SetPhysics( PHYS_Flying );
		}

		RotationRate.Pitch	= 16384; // extending pitch limit (limits network weapon aiming)

		// Check for hint
		CheckForHint(3);
    }

    function EndState()
    {
		RotationRate.Pitch = default.RotationRate.Pitch; // restoring pitch limit
	}

Begin:
}

//-----------------------------------------------------------------------------
// PlayerPlayerDriving - Overriden to allow throttle limitation
//-----------------------------------------------------------------------------
state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
    }
	// Set the throttle, steering etc. for the vehicle based on the input provided
	function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
	{
		local Vehicle CurrentVehicle;
		local ROVehicle ROVeh;
		local ROTreadCraft ROTank;

	    CurrentVehicle = Vehicle(Pawn);
	    ROVeh = ROVehicle(Pawn);
	    ROTank = ROTreadCraft(Pawn);

        if(CurrentVehicle == None)
            return;

        // Prevent the vehicles from moving without a crew/or if they haven't waited long enough
        if (ROVeh != none && ROVeh.bDisableThrottle)
        {
           	if(ROTreadCraft(CurrentVehicle) != none)
           	{
		   		if( (FClamp( InForward/5000.0, -1.0, 1.0 )) > 0)
					ROTreadCraft(CurrentVehicle).bWantsToThrottle = true;//IntendedThrottle = FClamp( InForward/5000.0, -1.0, 1.0 );
				else
					ROTreadCraft(CurrentVehicle).bWantsToThrottle = false;//.IntendedThrottle = 0;
			}

		   return;
        }

		//log("ProcessDrive Forward:"@InForward@" Strafe:"@InStrafe@" Up:"@InUp);

		CurrentVehicle.Throttle = FClamp( InForward/5000.0, -1.0, 1.0 );
		CurrentVehicle.Steering = FClamp( -InStrafe/5000.0, -1.0, 1.0 );
		CurrentVehicle.Rise = FClamp( InUp/5000.0, -1.0, 1.0 );
	}

	exec function Fire( optional float F )
	{
	    if (bHudCapturesMouseInputs)
	        HandleMouseClick();
	    else
	        super.Fire(F);
	}

    function PlayerMove( float DeltaTime )
    {
		local Vehicle CurrentVehicle;
		local float NewPing;
		local ROTreadCraft ROTank;
		local float AppliedThrottle;

		CurrentVehicle = Vehicle(Pawn);
		ROTank = ROTreadCraft(Pawn);

		if (bHudCapturesMouseInputs)
            HandleMousePlayerMove(DeltaTime);

		// update 'looking' rotation
        UpdateRotation(DeltaTime, 2);

        // TODO: Don't send things like aForward and aStrafe for gunners who don't need it
		// Only servers can actually do the driving logic.
        if (Role < ROLE_Authority )
        {
			if ( (Level.TimeSeconds - LastPingUpdate > 4) && (PlayerReplicationInfo != None) && !bDemoOwner )
			{
				LastPingUpdate = Level.TimeSeconds;
				NewPing = float(ConsoleCommand("GETPING"));
				if ( ExactPing < 0.006 )
					ExactPing = FMin(0.1,0.001 * NewPing);
				else
					ExactPing = 0.99 * ExactPing + 0.0001 * NewPing;
				PlayerReplicationInfo.Ping = Min(250.0 * ExactPing, 255);
				PlayerReplicationInfo.bReceivedPing = true;
				OldPing = ExactPing;
				ServerUpdatePing(1000 * ExactPing);
			}
            if (!bSkippedLastUpdate &&                              // in order to skip this update we must not have skipped the last one
                (Player.CurrentNetSpeed < 10000) &&                 // and netspeed must be low
                (Level.TimeSeconds - ClientUpdateTime < 0.0222) &&  // and time since last update must be short
                bPressedJump == bLastPressedJump &&                 // and update must not contain major changes
                aUp - aLastUp < 0.01 &&                             // "
                aForward - aLastForward < 0.01 &&                   // "
                aStrafe - aLastStrafe < 0.01                        // "
               )
            {
//                log("!bSkippedLastUpdate: "$!bSkippedLastUpdate);
//                log("(Player.CurrentNetSpeed < 10000): "$(Player.CurrentNetSpeed < 10000));
//                log("(Level.TimeSeconds - ClientUpdateTime < 0.0222): "$(Level.TimeSeconds - ClientUpdateTime < 0.0222)$"  - "$Level.TimeSeconds - ClientUpdateTime);
//                log("bPressedJump == bLastPressedJump: "$bPressedJump == bLastPressedJump);
//                log("aUp - aLastUp < 0.01: "$aUp - aLastUp < 0.01);
//                log("aForward - aLastForward < 0.01: "$aForward - aLastForward < 0.01);
//                log("aStrafe - aLastStrafe < 0.01: "$aStrafe - aLastStrafe < 0.01);

                bSkippedLastUpdate = True;
                return;
            }
            else
            {
                bSkippedLastUpdate = False;
                ClientUpdateTime = Level.TimeSeconds;

                // Save Move
                bLastPressedJump = bPressedJump;
                aLastUp = aUp;
                aLastForward = aForward;
                aLastStrafe = aStrafe;

                //log("PlayerMove Forward:"@aForward@" Strafe:"@aStrafe@" Up:"@aUp);

	    		if( CurrentVehicle != none && (bInterpolatedVehicleThrottle || (ROTank != none && bInterpolatedTankThrottle)))
	            {
					if( aForward > 0 )
					{
						CurrentVehicle.ThrottleAmount += DeltaTime * ThrottleChangeRate;
					}
					else if ( aForward < 0 )
					{
						CurrentVehicle.ThrottleAmount -= DeltaTime * ThrottleChangeRate;
					}

					CurrentVehicle.ThrottleAmount = FClamp( CurrentVehicle.ThrottleAmount, -6000.0, 6000.0 );

	                AppliedThrottle = CurrentVehicle.ThrottleAmount;

					// Stop if the throttle is below this amount
					if( Abs(AppliedThrottle) < 500 )
					{
						AppliedThrottle = 0;
					}

					// Brakes are on, so zero the throttle
					if( aUp > 0 )
					{
					 	AppliedThrottle = 0;
					 	CurrentVehicle.ThrottleAmount = 0;
					}

                    CurrentVehicle.Throttle = FClamp( AppliedThrottle/5000.0, -1.0, 1.0 );
                    CurrentVehicle.Steering = FClamp( -aStrafe/5000.0, -1.0, 1.0 );
                    CurrentVehicle.Rise = FClamp( aUp/5000.0, -1.0, 1.0 );

	                ServerDrive(AppliedThrottle, aStrafe, aUp, bPressedJump, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
				}
				else
				{
	                if (CurrentVehicle != None)
	                {
	                    CurrentVehicle.Throttle = FClamp( aForward/5000.0, -1.0, 1.0 );
	                    CurrentVehicle.Steering = FClamp( -aStrafe/5000.0, -1.0, 1.0 );
	                    CurrentVehicle.Rise = FClamp( aUp/5000.0, -1.0, 1.0 );
	                }

	                ServerDrive(aForward, aStrafe, aUp, bPressedJump, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
				}
            }
        }
		else
		{
    		if(CurrentVehicle != none && (bInterpolatedVehicleThrottle || (ROTank != none && bInterpolatedTankThrottle)))
            {
				if( aForward > 0 )
				{
					CurrentVehicle.ThrottleAmount += DeltaTime * ThrottleChangeRate;
				}
				else if ( aForward < 0 )
				{
					CurrentVehicle.ThrottleAmount -= DeltaTime * ThrottleChangeRate;
				}

				CurrentVehicle.ThrottleAmount = FClamp( CurrentVehicle.ThrottleAmount, -6000.0, 6000.0 );

                AppliedThrottle = CurrentVehicle.ThrottleAmount;

				// Stop if the throttle is below this amount
				if( Abs(AppliedThrottle) < 500 )
				{
					AppliedThrottle = 0;
				}

				// Brakes are on, so zero the throttle
				if( aUp > 0 )
				{
				 	AppliedThrottle = 0;
				 	CurrentVehicle.ThrottleAmount = 0;
				}

				ProcessDrive(AppliedThrottle, aStrafe, aUp, bPressedJump);
			}
			else
			{
				ProcessDrive(aForward, aStrafe, aUp, bPressedJump);
			}
		}

		// If the vehicle is being controlled here - set replicated variables.
		if (CurrentVehicle != None)
		{
			if(bFire == 0 && CurrentVehicle.bWeaponIsFiring)
				CurrentVehicle.ClientVehicleCeaseFire(False);

			if(bAltFire == 0 && CurrentVehicle.bWeaponIsAltFiring)
				CurrentVehicle.ClientVehicleCeaseFire(True);
		}
    }

	function BeginState()
	{
		PlayerReplicationInfo.bReceivedPing = false;
		CleanOutSavedMoves();

		// Check for hint
		CheckForHint(3);
	}

	function EndState()
	{
		CleanOutSavedMoves();
	}
}

//=============================================================================
// Lean functions
//=============================================================================

exec function LeanRight()
{
	if( Pawn != none && ROPawn(Pawn) != none && !Pawn.bBipodDeployed)
		ROPawn(pawn).LeanRight();
	ServerLeanRight(true);
}

exec function LeanRightReleased()
{
	if( Pawn != none && ROPawn(Pawn) != none )
	{
		ROPawn(pawn).LeanRightReleased();
		ServerLeanRight(false);
	}
}

function ServerLeanRight(bool leanstate)
{
	if( Pawn != none )
	{
 		if( ROPawn(Pawn) != none )
		{
			if (leanstate)
			{
				if( !Pawn.bBipodDeployed )
					ROPawn(pawn).LeanRight();
			}
			else
				ROPawn(pawn).LeanRightReleased();
		}
		else if ( leanstate && VehicleWeaponPawn(Pawn) != none )
		{
			VehicleWeaponPawn(Pawn).IncrementRange();
		}
	}
}

exec function LeanLeft()
{
	if( Pawn != none && ROPawn(Pawn) != none && !Pawn.bBipodDeployed)
		ROPawn(pawn).LeanLeft();
	ServerLeanLeft(true);
}

exec function LeanLeftReleased()
{
	if( Pawn != none && ROPawn(Pawn) != none )
	{
		ROPawn(pawn).LeanLeftReleased();
		ServerLeanLeft(false);
	}
}

function ServerLeanLeft(bool leanstate)
{
	if( Pawn != none )
	{
 		if( ROPawn(Pawn) != none )
		{
			if (leanstate)
			{
				if( !Pawn.bBipodDeployed )
					ROPawn(pawn).LeanLeft();
			}
			else
				ROPawn(pawn).LeanLeftReleased();
		}
		else if ( leanstate && VehicleWeaponPawn(Pawn) != none )
		{
			VehicleWeaponPawn(Pawn).DecrementRange();
		}
	}
}

simulated function NotifyOfMapInfoChange()
{
    if (ROHud(myHUD) != none)
        ROHud(myHUD).ShowMapUpdatedIcon();

    // Check for hint
    CheckForHint(15);
}

// most of this code comes from UDN:
// https://udn.epicgames.com/Two/MouseCursorInterface
simulated function HandleMousePlayerMove(float DeltaTime)
{
    local vector MouseV;

    // calc mouse position offset
    MouseV.X = DeltaTime * aMouseX / (InputClass.default.MouseSensitivity * DesiredFOV * 0.01111);
    MouseV.Y = DeltaTime * aMouseY / (InputClass.default.MouseSensitivity * DesiredFOV * -0.01111);

    // update mouse position
    PlayerMouse += MouseV;

    // notify hud of new mouse position
    ROHud(myHUD).MouseInterfaceUpdatePosition(PlayerMouse);
}

simulated function HandleMouseClick()
{
    ROHud(myHUD).MouseInterfaceClick();
}

simulated function MouseInterfaceSetMousePos(vector newPos)
{
    PlayerMouse = newPos;
}

simulated function MouseInterfaceSetRotationLock(bool bLocked)
{
    bHudLocksPlayerRotation = bLocked;
}

// omg hax
// same as function in PlayerController, but doesn't pick a team automatically
// when switching from spectator to active player.
function BecomeActivePlayer()
{
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.AllowBecomeActivePlayer(self) )
		return;

	bBehindView = false;
	SetViewDistance();
	FixFOV();
	ServerViewSelf();
	PlayerReplicationInfo.bOnlySpectator = false;
	PlayerReplicationInfo.bOutOfLives = false;
	Level.Game.NumSpectators--;
	Level.Game.NumPlayers++;
	PlayerReplicationInfo.Reset();
	Adrenaline = 0;
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 1, PlayerReplicationInfo);
	//if (Level.Game.bTeamGame)
	//	Level.Game.ChangeTeam(self, Level.Game.PickTeam(int(GetURLOption("Team")), None), false);
	if (!Level.Game.bDelayedStart)
    {
		// start match, or let player enter, immediately
		Level.Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
		if (Level.Game.bWaitingToStartMatch)
			Level.Game.StartMatch();
		else
			Level.Game.RestartPlayer(PlayerController(Owner));
		Level.Game.bRestartLevel = Level.Game.Default.bRestartLevel;
    }
    else
        GotoState('PlayerWaiting');

    ClientBecameActivePlayer();
}

function Reset()
{
    super.Reset();

    // Reset the artillery coords when the round resets
	SavedArtilleryCoords = vect(0,0,0);
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
            HintManager = spawn(class'ROHintManager', self);
            if (HintManager == none)
                warn("Unable to spawn hint manager");
        }
        else if (!bUseHints && HintManager != none)
        {
            HintManager.Destroy();
            HintManager = none;
        }

        if (!bUseHints)
            if (ROHud(myHUD) != none)
                ROHud(myHUD).bDrawHint = false;
    }
}

simulated function CheckForHint(int hintType)
{
    if (HintManager != none)
        HintManager.CheckForHint(hintType);
}

// For debug
exec function DumpHints()
{
    if (HintManager != none)
        HintManager.DumpHints();
    else
        log("No HintManager present in ROPlayer. Are hints enabled?");
}

exec function Jump( optional float F )
{
    super.jump(f);
    CheckForHint(1);
}

exec function xSpeech(name Type, int Index, PlayerReplicationInfo SquadLeader)
{
    xServerSpeech(Type, Index, SquadLeader);
}

function xServerSpeech(name Type, int Index, PlayerReplicationInfo SquadLeader)
{
	if (PlayerReplicationInfo.VoiceType != None)
		PlayerReplicationInfo.VoiceType.static.xPlayerSpeech(Type, Index, SquadLeader, self);
}

function int ServerAutoSelectAndChangeTeam()
{
    local int tempTeam;

    tempTeam = Level.Game.PickTeam(rand(2), self);
    ServerChangeTeam(tempTeam);

    return tempTeam;
}

function ServerSetManualTankShellReloading(bool bUseManualReloading)
{
    //If the cannon is waiting to reload, force a reload on the client
    if( bUseManualReloading == false && Pawn != none && VehicleWeaponPawn(Pawn) != none &&
        VehicleWeaponPawn(Pawn).Gun != none && ROTankCannon(VehicleWeaponPawn(Pawn).Gun) != none &&
        ROTankCannon(VehicleWeaponPawn(Pawn).Gun).CannonReloadState == CR_Waiting)
    {
        ROTankCannon(VehicleWeaponPawn(Pawn).Gun).ServerManualReload();
    }

    bManualTankShellReloading = bUseManualReloading;
}

simulated function SetManualTankShellReloading(bool bUseManualReloading)
{
    bManualTankShellReloading = bUseManualReloading;

    //Replicate the new setting to the server
    ServerSetManualTankShellReloading(bManualTankShellReloading);
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DesiredRole=-1
     CurrentRole=-1
     PrimaryWeapon=-1
     SecondaryWeapon=-1
     GrenadeWeapon=-1
     bCanRespawn=True
     bPendingMapDisplay=True
     bFirstRoleAndTeamChange=True
     bShowMapOnFirstSpawn=True
     FadeFromBlackFadeSpeed=0.150000
     SpectatingModeName(0)="Viewing Self"
     SpectatingModeName(1)="Roaming"
     SpectatingModeName(2)="Viewing Players"
     SpectatingModeName(3)="Spectating Viewpoints"
     FreeAimMaxYawLimit=2000
     FreeAimMinYawLimit=63535
     FreeAimMaxPitchLimit=1500
     FreeAimMinPitchLimit=64035
     FAAWeaponRotationFactor=8.000000
     YawTweenRate=8000
     PitchTweenRate=6000
     bSway=True
     baseSwayYawAcc=100.000000
     baseSwayPitchAcc=200.000000
     SwayCurve=(Points=(,(InVal=0.750000,OutVal=0.100000),(InVal=1.500000,OutVal=0.250000),(InVal=3.000000,OutVal=0.500000),(InVal=10.000000,OutVal=1.000000),(InVal=1000000000.000000,OutVal=1.000000)))
     ROMidGameMenuClass="ROInterface.ROGUIRoleSelection"
     GlobalDetailLevel=-1
     ForcedTeamSelectOnRoleSelectPage=-5
     bUseBlurEffect=True
     MaxAltBlurLevel=215
     bShowHints=True
     ThrottleChangeRate=2200.000000
     bInterpolatedTankThrottle=True
     JarrMoveMag=40.000000
     JarrMoveRate=200.000000
     JarrMoveDuration=3.000000
     JarrRotateMag=2000.000000
     JarrRotateRate=10000.000000
     JarrRotateDuration=4.000000
     AutoJoinMask=7
     VehicleCheckRadius=350.000000
     DesiredFOV=85.000000
     DefaultFOV=85.000000
     InputClass=Class'ROEngine.ROPlayerInput'
     PlayerReplicationInfoClass=Class'ROEngine.ROPlayerReplicationInfo'
     PawnClass=Class'ROEngine.ROPawn'
}
