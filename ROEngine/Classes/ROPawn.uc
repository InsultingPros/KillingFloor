//=============================================================================
// ROPawn
//=============================================================================
// Pawn class for Red Orchestra
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROPawn extends Pawn
	native
	placeable
	config(User)
	exportstructs
	dependsOn(xUtil)
	dependsOn(ROPawnSoundGroup);

//#exec OBJ LOAD FILE=Inf_Player.uax
//#exec OBJ LOAD FILE=Miscsounds.uax
//#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax

// UnrealPawn vars

var	() bool		bNoDefaultInventory;	// don't spawn default inventory for this guy
var bool		bAcceptAllInventory;	// can pick up anything
var(AI) bool	bIsSquadLeader;			// only used as startup property
var bool		bSoakDebug;				// use less verbose version of debug display
var bool		bKeepTaunting;
var config bool bPlayOwnFootsteps;
var byte		LoadOut;

var		float	AttackSuitability;		// range 0 to 1, 0 = pure defender, 1 = pure attacker
var		float	LastFootStepTime;

var eDoubleClickDir CurrentDir;
var vector			GameObjOffset;
var rotator			GameObjRot;
var(AI) name		SquadName;			// only used as startup property

// allowed voices
var string VoiceType;

var globalconfig bool bPlayerShadows;
var globalconfig bool bBlobShadow;

var int spree;

// Xpawn vars
var bool bGibbed;
var bool bAlreadySetup;
var bool bSpawnDone;
var bool bClearWeaponOffsets;		// for certain custom player models

var class<SpeciesType> Species;

var float DeResTime;
var bool bDeRes;

var(Sounds) float GruntVolume;
var(Sounds) float FootstepVolume;

var transient int   SimHitFxTicker;

var float MinTimeBetweenPainSounds;

// Common sounds

var(Sounds) sound   SoundFootsteps[20]; // Indexed by ESurfaceTypes (sorry about the literal).
var(Sounds) class<ROPawnSoundGroup> SoundGroupClass;

var ROWeaponAttachment WeaponAttachment;
var ROWeaponAttachment OldWeaponAttachment; // Used by the native code for animations

var	Weapon SwapWeapon; // Used to keep track of the weapon being swapped during the PutWeaponAway state.

var ShadowProjector PlayerShadow;

var(Karma) float RagdollLifeSpan; // MAXIMUM time the ragdoll will be around. De-res's early if it comes to rest.
var(Karma) float RagInvInertia; // Use to work out how much 'spin' ragdoll gets on death.
var(Karma) float RagDeathVel; // How fast ragdoll moves upon death
var(Karma) float RagShootStrength; // How much effect shooting ragdolls has. Be careful!
var(Karma) float RagSpinScale; // Increase propensity to spin around Z (up).
var(Karma) float RagMaxSpinAmount; // The max we'll scale up spin amount for locational hit damage
var(Karma) float RagDeathUpKick; // Amount of upwards kick ragdolls get when they die
var(Karma) float RagGravScale;

var(Karma) material RagConvulseMaterial;

// Ragdoll impact sounds.
var(Karma) sound			RagImpactSound;
var(Karma) float			RagImpactSoundInterval;
var transient float			RagLastSoundTime;

var string RagdollOverride;

var Controller OldController;

var class<TeamVoicePack> VoiceClass;

var(AI) globalconfig string PlacedCharacterName;
var globalconfig string PlacedFemaleCharacterName;

var byte TeamSkin;		// what team's skin is currently set

var name FireRootBone;
//=============================================================================
// RO Variables
//=============================================================================

// Damage
var					byte		DamageList[15]; // An array that tracks what areas of the body are damaged. Correlates to Hitpoints Array (-1)
var                 int         LastHitIndex;

// Gore
var	SeveredAppendageAttachment 	SeveredLeftArm; // The meaty attachments that get attached when body parts are blown off
var	SeveredAppendageAttachment 	SeveredRightArm;// The meaty attachments that get attached when body parts are blown off
var	SeveredAppendageAttachment 	SeveredLeftLeg; // The meaty attachments that get attached when body parts are blown off
var	SeveredAppendageAttachment 	SeveredRightLeg;// The meaty attachments that get attached when body parts are blown off
var	SeveredAppendageAttachment 	SeveredHead;// The meaty attachments that get attached when body parts are blown off

var	class<SeveredAppendageAttachment> SeveredArmAttachClass; // class of the severed arm for this role
var	class<SeveredAppendageAttachment> SeveredLegAttachClass; // class of the severed arm for this role
var	class<SeveredAppendageAttachment> SeveredHeadAttachClass; // class of the severed arm for this role

var class <ROBloodSpurt>		 BleedingEmitterClass;		// class of the bleeding emitter
var class <ProjectileBloodSplat> ProjectileBloodSplatClass;	// class of the wall bloodsplat from a projectile's impact
var class <SeveredAppendage>	DetachedArmClass;		// class of detached arm to spawn for this pawn. Modified by the RoleInfo to match the player model
var class <SeveredAppendage>	DetachedLegClass;		// class of detached arm to spawn for this pawn. Modified by the RoleInfo to match the player model
var			bool				bLeftArmGibbed;			// LeftArm is already blown off
var			bool				bRightArmGibbed;		// RightArm is already blown off
var			bool				bLeftLegGibbed;			// LeftLeg is already blown off
var			bool				bRightLegGibbed;		// RightLeg is already blown off
var class <Emitter>				ObliteratedEffectClass;	// class of detached arm to spawn for this pawn. Modified by the RoleInfo to match the player model


// Collision
var		ROBulletWhipAttachment  AuxCollisionCylinder;   // Additional collision cylinder for detecting bullets passing by
var 				bool 		SavedAuxCollision;     	// Saved aux collision cylinder status
// Used by physics to set the player's distance from the floor.
var 				const float ROMinFloorDist;
var 				const float ROMaxFloorDist;

const FRONTROTATIONCHECKDIST = 40.0; 					// How far forward to check when prone to determine the rotation of the floor in front of the player

// Stamina
var()				float		Stamina;                // How many second of stamina the player has
var             	byte 		SavedBreathSound;     	// Tracks the old breathing sound
var()				float		JumpStaminaDrain;       // How much stamina is lost by jumping
var() 				float 		StaminaRecoveryRate; 	// How much stamina to recover normally per second
var() 				float 		CrouchStaminaRecoveryRate;// How much stamina to recover per second while crouching
var() 				float 		ProneStaminaRecoveryRate;// How much stamina to recover per second while proning
var() 				float		SlowStaminaRecoveryRate;// How much stamina to recover per second when moving
var					bool		bOldSprinting; 			// Helper flag for SetSprinting(). Since we simulate sprinting and stamina on both client and server, this flag is used to keep track of the local sprinting flags.

// Momentum
var()				InterpCurve	MomentumCurve; 			// The amount of momentum to apply based on an input velocity
var()				float		FrictionScale;			// Used by the native physics to scale the friction when the player is moving. This makes the player feel less like he "sticks" to the the ground


var()				int			PronePitchUpLimit;		// Pitch up limit while prone
var()				int			PronePitchDownLimit;    // Pitch down limit while prone
var()				int			CrawlingPitchUpLimit;	// Pitch up limit while crawling forward or back
var()				int			CrawlingPitchDownLimit; // Pitch down limit while crawling forward or back

var					int			CrawlPitchTweenRate;	// Tween to pitch limit speed  = CrawlingPitchDownLimit-PronePitchDownLimit/NumSecondsToTween(0.15)

// Animation
var 				bool		bPlayTypingAnims;		// Whether or not to play a typing animation when the player is typing
var(ROAnimations)	name 		ProneIdleRestAnim;		// Idling for a long time while prone
var(ROAnimations)	name 		CrouchIdleRestAnim;     // Idling for a long time while crouched

// MG deployed anims
var(ROAnimations)	name 		IdleProneDeployedAnim;
var(ROAnimations)	name        IdleCrouchDeployedAnim;
var(ROAnimations)	name        IdleStandingDeployedAnim;

// Prone Anims
var(ROAnimations)	name		ProneAnims[8];
var(ROAnimations) 	name		IdleProneAnim;
var(ROAnimations) 	name		ProneTurnRightAnim;
var(ROAnimations) 	name		ProneTurnLeftAnim;
var(ROAnimations) 	name		StandToProneAnim;
var(ROAnimations) 	name		ProneToStandAnim;
var(ROAnimations) 	name		CrouchToProneAnim;
var(ROAnimations) 	name		ProneToCrouchAnim;
var(ROAnimations) 	name		DiveToProneStartAnim;
var(ROAnimations) 	name		DiveToProneEndAnim;

// Sprint Anims
var(ROAnimations) 	name		SprintAnims[8];
var(ROAnimations) 	name		SprintCrouchAnims[8];

// Iron Sight Anims
var(ROAnimations) 	name		WalkIronAnims[8];
var(ROAnimations) 	name		IdleIronRestAnim;
var(ROAnimations) 	name		IdleIronWeaponAnim;
var(ROAnimations) 	name		IdleCrouchIronWeaponAnim;
var(ROAnimations) 	name		TurnIronRightAnim;
var(ROAnimations) 	name		TurnIronLeftAnim;
var(ROAnimations) 	name		CrouchTurnIronRightAnim;
var(ROAnimations) 	name		CrouchTurnIronLeftAnim;

// Hit Anims
var(ROAnimations) 	name		HitFAnim;
var(ROAnimations) 	name		HitBAnim;
var(ROAnimations) 	name		HitLAnim;
var(ROAnimations) 	name		HitRAnim;
var(ROAnimations) 	name		HitLLegAnim;
var(ROAnimations) 	name		HitRLegAnim;
var(ROAnimations) 	name		ProneHitAnim;
var(ROAnimations) 	name		CrouchHitUpAnim;
var(ROAnimations) 	name		CrouchHitDownAnim;

var(ROAnimations) 	name		LimpAnims[8];

// General

var				float			NextJumpTime;
// Ramm: Refactor
// These two arent being used properly
var				float			LastLandTime;			// we'll use this for a settling time.  If someone jumps, they'll need a few seconds to settle
var				float			LandRecoveryTime;		// time it takes to recover from a jump to do whatever action, maybe change when injured

// Limping
var				float			LimpTime; 				// How long the player will limp for

// Ramm: Refactor
// Rather than have an entire actor, or array of actors, how about just using a mesh attachment?
var		array<ROAmmoPouch>		AmmoPouches;
var		class<ROAmmoPouch>		AmmoPouchClasses[3];

var		ROHeadgear				Headgear;
var		class<ROHeadgear>		HeadgearClass;

var		BackAttachment			AttachedBackItem;		// Weapon attachment on player's back

var				bool			bInitializedPlayer;

// Objectives
var				byte			CurrentCapArea;
var				byte			CurrentCapProgress;
//var			byte			CurrentCapPlayers;
var             byte            CurrentCapAxisCappers;
var             byte            CurrentCapAlliesCappers;

enum EWeaponState
{
	GS_None,
	GS_Ready,
	GS_FireSingle,
	GS_FireLooped,
	GS_PreReload,
	GS_ReloadSingle,
	GS_ReloadLooped,
	GS_BayonetAttach,
	GS_BayonetDetach,
	GS_GrenadePullBack,
	GS_GrenadeHoldBack,
	GS_IgnoreAnimend,
};

var		EWeaponState			WeaponState;

// MG resupply
// TEMP VARIABLE - put here because I didn't know where else to since I'm in a hurry
// This variable is referenced in ROHud and ROPlayer
var				bool			bCanResupply;
var				bool			bUsedCarriedMGAmmo; 	// have they already resupplied another gunner?

var				bool			bWeaponCanBeResupplied;	// True if the weapon the pawn is holding can be resupplied by other players (ie giving an MGer ammo)
var				bool			bWeaponNeedsResupply;	// True if the weapon the pawn is holding needs to be resupplied

var				Actor			SavedBase; 				// Last base this pawn was on

var 			float			SprintAccelRate;		// How fast the player accelerates when they are sprinting

// Footstep sounds
var()			float 			FootStepSoundRadius;	// The radius that footstep sounds can be heard
var()			float			QuietFootStepVolume;	// The amount to scale footstepsounds when the player is walking slowly

var() 			float			CrouchEyeHeightMod; 	// Modifier for eyeheight while crouched
var() 			float			CrouchMoveEyeHeightMod; // Modifier for eyeheight while crouched and moving
var() 			float			ProneEyeHeight; 		// ProneEyeHeight
var()			float			ProneEyeDist;			// Distance offset from location to put prone camera.
var const 		rotator			OldProneRotation;		// Used by phyics to help smooth prone rotation
var	const		float			DeployedEyeHeight;		// Calculated by physics to determine what the player's eye height should be

var(Camera)     name 			CameraBone;				// The bone used for the camera position during certain transitions (prone)

// For lean
var 			float 			LeanMax;
var 			float 			LeanFactor;
var 			float			LeanAmount;    			// Positive is right, negative is left, zero is center
var 			bool			bLeaningRight, bLeaningLeft;//Is in the process of leaning or stopping leaning or is actually leaning :P
var 			bool			bLeanRight, bLeanLeft;	//True if lean is pressed
var(Lean)		vector			LeanLViewOffset;		// Eyeposition offset for leaning left
var(Lean)		vector			LeanRViewOffset;		// Eyeposition offset for leaning right
var(Lean)		vector			LeanLCrouchViewOffset;	// Eyeposition offset for leaning left
var(Lean)		vector			LeanRCrouchViewOffset;	// Eyeposition offset for leaning right
var(Lean)		vector			LeanLProneViewOffset;	// Eyeposition offset for leaning left
var(Lean)		vector			LeanRProneViewOffset;	// Eyeposition offset for leaning right

var()			int				AnimPitchUpLimit;			// Pitch up limit for third person torso twist
var()			int				AnimPitchDownLimit;    		// Pitch down limit for third person torso twist
var()			int				ProneAnimPitchUpLimit;		// Pitch up limit for third person torso twist while prone
var()			int				ProneAnimPitchDownLimit;    // Pitch down limit for third person torso twist while prone

// Bone settings for the player animation while leaning
var(Lean) 		name			LeanBones[8];
var(Lean)		rotator			LeanLeftStanding[8];
var(Lean)		rotator			LeanRightStanding[8];
var(Lean)		rotator			LeanLeftCrouch[8];
var(Lean)		rotator			LeanRightCrouch[8];
var(Lean)		rotator			LeanLeftProne[8];
var(Lean)		rotator			LeanRightProne[8];
var				rotator 		CurrentRotators[8];

// auto tracing
var 			Actor			AutoTraceActor;			// The actor that this pawn is currently looking at (has selected)

// Deployment system
var				int				OldLookYaw;   			// The last yaw rotation of the player. used for calculating the rotation speed
var 			float 			CantRestWeapTime;       // The last time we were in a position where the weapon could not be rested
var				rotator			InitialDeployedRotation;// The rotation of the player when the weapon is initially bipod deployed
var()			int				DeployedPitchUpLimit;	// The pitch limit when bipod deployed
var()			int				DeployedPitchDownLimit;	// The pitch limit when bipod deployed
var()			int				DeployedPositiveYawLimit;// The yaw limit when bipod deployed
var()			int				DeployedNegativeYawLimit;// The yaw limit when bipod deployed
var const		float 			LastMoveTime;		     // The last time this player moved. Used for calculating crouched eye height

// Stance transition sounds
var             sound           CrouchToProneSound;
var             sound           CrouchToStandSound;
var             sound           ProneToCrouchSound;
var             sound           ProneToStandSound;
var             sound           StandToCrouchSound;
var             sound           StandToProneSound;

var             bool            bPreventWeaponFire;     // Used to prevent firing the weapon during certain pawn transitions

// Breathing sounds
var             sound           BreatheLightSound;
var             sound           BreatheMediumSound;
var             sound           BreatheHeavySound;
var             sound           BreatheExhaustedSound;

// Net code
var()			float			NetSoundRadiusSquared; // The relevant radius for certain pawn sounds to be heard by other net players. If this pawn is doing particular actions (reloading, footstepping, etc) it will be relevant to other pawns within this radius
var				bool			bInitializedWeaponAttachment;// The weapon attachment has completed initial replication


// Hit detection debugging - Only use when debugging
/*var vector DrawLocation;
var rotator DrawRotation;
var int DrawIndex;
var vector HitStart;
var vector HitEnd;
var byte HitPointDebugByte;
var byte OldHitPointDebugByte;*/

var				bool			bRecievedInitialLoadout; // Initial weapon loadout has finished replicating

//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bLeanRight, bLeanLeft;

	reliable if (bNetDirty && Role == ROLE_Authority)
		AmmoPouchClasses, HeadgearClass, DetachedArmClass, DetachedLegClass;

	reliable if (bNetDirty && bNetOwner && Role == ROLE_Authority)
		CurrentCapArea, CurrentCapProgress, CurrentCapAxisCappers, CurrentCapAlliesCappers,
		bUsedCarriedMGAmmo, bPreventWeaponFire;

	reliable if (Role == ROLE_Authority)
		ClientUpdateDamageList, ClientForceStaminaUpdate;

    reliable if ( bNetDirty && !bNetOwner && (Role == ROLE_Authority) )
    	bWeaponCanBeResupplied, bWeaponNeedsResupply;

    // Hit detection debugging - Only use when debugging
    //reliable if (Role == ROLE_Authority)
	///	DrawLocation,DrawRotation,DrawIndex,HitPointDebugByte,HitStart,HitEnd;
}

/*==========================================
* Natives
*=========================================*/

simulated native function int Get8WayDirection();

simulated event HandleWhizSound()
{
 	// Don't play whizz sounds for bots, or from other players
	if ( IsHumanControlled() && IsLocallyControlled() )
	{
		Spawn(class'ROBulletWhiz',,, mWhizSoundLocation);
		ROPlayer(Controller).PlayerWhizzed(VSizeSquared(Location - mWhizSoundLocation));
	}
}

// Blend the upper body back to full body animation.
// Called by the native code when AnimBlendTime counts down to zero
simulated event AnimBlendTimer()
{
	AnimBlendToAlpha(1, 0.0, 0.12);
	WeaponState = GS_Ready;
}
/*==========================================
* ROPawn functions
*=========================================*/

// test execs
/*
exec function TestEye()
{
	local rotator myrot;
    local Vector X,Y,Z;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;


    GetAxes( Controller.rotation, X, Y, Z );

	myrot = Controller.rotation;

    ClearStayingDebugLines();
    DrawStayingDebugLine((EyePosition() + Location), (EyePosition() + Location)+500* X, 0,0,255);
    DrawStayingDebugLine((EyePosition() + Location), (EyePosition() + Location)+200* Y, 0,255,0);
}*/

//-----------------------------------------------------------------------------
// Empty
//-----------------------------------------------------------------------------

//=============================================================
// Initialization
//=============================================================

// Precache pawn related content
static function StaticPrecache(LevelInfo L)
{
 	default.ProjectileBloodSplatClass.static.PrecacheContent(L);
 	default.SeveredArmAttachClass.static.PrecacheContent(L);
 	default.SeveredLegAttachClass.static.PrecacheContent(L);
 	default.SeveredHeadAttachClass.static.PrecacheContent(L);
 	default.BleedingEmitterClass.static.PrecacheContent(L);
 	// TODO: Precache all the blood emitter's texture's when they are done
}

// Little Easter Egg here
function PlayDyingSound()
{
    if( Level.Netmode == NM_Client )
    {
        return;
    }

	if ( bGibbed )
	{
        // Do nothing for now
		//PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,3.5*TransientSoundVolume,true,500);
		return;
	}

    if ( HeadVolume.bWaterVolume )
    {
        PlaySound(GetSound(EST_Drown), SLOT_Pain,2.5*TransientSoundVolume,true,500);
        return;
    }

//    if (FRand() < 0.001)
//    {
//          PlaySound(sound'Miscsounds.DeanScream', SLOT_Pain,2.5*TransientSoundVolume, true,500);
//    }
//    else
//    {
		PlaySound(SoundGroupClass.static.GetDeathSound(LastHitIndex), SLOT_Pain,1.30, true,525);
//    }
}

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    // From UnrealPawn
	if ( Level.bStartup && !bNoDefaultInventory )
		AddDefaultInventory();

    AssignInitialPose();

    UpdateShadow();

	// end from UnrealPawn

    SavedBreathSound = 0;

	if (  AuxCollisionCylinder == none )
	{
		AuxCollisionCylinder = Spawn(class 'ROBulletWhipAttachment',self);
		AttachToBone(AuxCollisionCylinder, 'spine');
	}
	SavedAuxCollision = AuxCollisionCylinder.bCollideActors;

	LastResupplyTime = Level.TimeSeconds - 1;
	bTouchingResupply=false;
}

simulated function UpdateShadow()
{
    if (bActorShadows && bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
    {
        if (PlayerShadow != none)
            PlayerShadow.Destroy();

        PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
        PlayerShadow.ShadowActor = self;
        PlayerShadow.bBlobShadow = bBlobShadow;
        PlayerShadow.LightDirection = Normal(vect(1,1,3));
        PlayerShadow.LightDistance = 320;
        PlayerShadow.MaxTraceDistance = 350;
        PlayerShadow.InitShadow();
    }
    else if (PlayerShadow != none && Level.NetMode != NM_DedicatedServer)
    {
        PlayerShadow.Destroy();
        PlayerShadow = none;
    }
}

//-----------------------------------------------------------------------------
// PostNetBeginPlay - Create dummy attachments on client
//-----------------------------------------------------------------------------

simulated function PostNetBeginPlay()
{
	local int i;
 	local SquadAI S;
	local RosterEntry R;

	Super.PostNetBeginPlay();


	// From UnrealPawn
	if ( (Role == ROLE_Authority) && Level.bStartup )
	{
		if ( UnrealMPGameInfo(Level.Game) == None )
		{
			if ( Bot(Controller) != None )
			{
				foreach DynamicActors(class'SquadAI',S,SquadName)
					break;
				if ( S == None )
					S = spawn(class'SquadAI');
				S.Tag = SquadName;
				if ( bIsSquadLeader || (S.SquadLeader == None) )
					S.SetLeader(Controller);
				S.AddBot(Bot(Controller));
			}
		}
		else
		{
			R = GetPlacedRoster();
			UnrealMPGameInfo(Level.Game).InitPlacedBot(Controller,R);
		}
	}
    // End from UnrealPawn

	// MergeTODO: Maybe refactor this
	if (Role < ROLE_Authority)
	{
		if (HeadgearClass != None)
			Headgear = Spawn(HeadgearClass, self);

		for (i = 0; i < ArrayCount(AmmoPouchClasses); i++)
		{
			if (AmmoPouchClasses[i] == None)
				break;

			AmmoPouches[AmmoPouches.Length] = Spawn(AmmoPouchClasses[i], self);
		}
	}
}

//-----------------------------------------------------------------------------
// PossessedBy - Figure out what dummy attachments are needed
//-----------------------------------------------------------------------------

function PossessedBy(Controller C)
{
	local array<class<ROAmmoPouch> > AmmoClasses;
	local int i, Prim, Sec, Gren;

	Super.PossessedBy(C);

	// From XPawn
	if ( Controller != None )
		OldController = Controller;

	// MergeTODO: Refactor this, I don't think this is the best place to spawn attachments

	// Handle dummy attachments
	if (Role == ROLE_Authority)
	{
		ClientForceStaminaUpdate(Stamina);

		if (ROPlayer(Controller) != None)
		{
			Prim = ROPlayer(Controller).PrimaryWeapon;
			Sec = ROPlayer(Controller).SecondaryWeapon;
			Gren = ROPlayer(Controller).GrenadeWeapon;
		}
		else if (ROBot(Controller) != None)
		{
			Prim = ROBot(Controller).PrimaryWeapon;
			Sec = ROBot(Controller).SecondaryWeapon;
			Gren = ROBot(Controller).GrenadeWeapon;
		}

		HeadgearClass = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo.GetHeadgear();
		ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo.GetAmmoPouches(AmmoClasses, Prim, Sec, Gren);

		if( ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
			ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none )
		{
			DetachedArmClass = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo.static.GetArmClass();
			DetachedLegClass = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo.static.GetLegClass();
		}
		else
		{
			log("Error!!! Possess with no RoleInfo!!!");
		}

		for (i = 0; i < AmmoClasses.Length; i++)
			AmmoPouchClasses[i] = AmmoClasses[i];

		// These don't need to exist on dedicated servers at the moment, though they might if the ammo
		// holding functionality of the pouch is put in - Erik
		if (Level.NetMode != NM_DedicatedServer)
		{
			if (HeadgearClass != None)
				Headgear = Spawn(HeadgearClass, self);

			for (i = 0; i < ArrayCount(AmmoPouchClasses); i++)
			{
				if (AmmoPouchClasses[i] == None)
					break;

				AmmoPouches[AmmoPouches.Length] = Spawn(AmmoPouchClasses[i], self);
			}
		}
	}

	// Send the info to the client now to make sure RoleInfo is replicated quickly
	NetUpdateTime = Level.TimeSeconds - 1;
}

//=============================================================
// Setters
//=============================================================

// Setters for extra collision cylinders
// MergeTODO: Verify we even need these once we have the new native trace support
simulated function ToggleAuxCollision(bool newbCollision)
{
	if ( !newbCollision )
	{
		SavedAuxCollision = AuxCollisionCylinder.bCollideActors;

		AuxCollisionCylinder.SetCollision(false);
	}
	else
	{
		AuxCollisionCylinder.SetCollision(SavedAuxCollision);
	}
}

// Set the player to limping for a time
function SetLimping(float Duration)
{
	bIsLimping = true;
	LimpTime = Duration;
}

// Handle changing Stamina Based breathing sounds - Ramm
function SetBreathingSound(byte NewSound)
{
	if (NewSound == 1)
	{
		if (AmbientSound != BreatheExhaustedSound)
			AmbientSound = BreatheExhaustedSound;
	}
	else if (NewSound == 2)
	{
		if (AmbientSound != BreatheHeavySound)
			AmbientSound = BreatheHeavySound;
	}
	else if (NewSound == 3)
	{
		if (AmbientSound != BreatheHeavySound)
			AmbientSound = BreatheMediumSound;
	}
	else if (NewSound == 4)
	{
		AmbientSound = BreatheLightSound;
	}
	else if (NewSound == 5 )
	{
		if (AmbientSound != None)
		{
			AmbientSound = None;
		}
	}

	SavedBreathSound = NewSound;
}

//-----------------------------------------------------------------------------
// SetSprinting - Enables and disables sprinting
//-----------------------------------------------------------------------------
function SetSprinting(bool bNewIsSprinting)
{
	if (bNewIsSprinting != (bIsSprinting || bOldSprinting) )
	{
		if( bNewIsSprinting && (!AllowSprint() || !bCanStartSprint) )
		{
			return;
		}

		bIsSprinting = bNewIsSprinting;

		SetWalking(false);

		if (bIsSprinting)
		{
			StartSprint();
		}
		else
		{
			EndSprint();
		}

        bOldSprinting = bIsSprinting;
	}
}

function SetWalking(bool bNewIsWalking)
{
	if (bNewIsWalking != bIsWalking)
	{
		bIsWalking = bNewIsWalking;
	}
}

//=============================================================
// Drawing
//=============================================================

//-----------------------------------------------------------------------------
// CalcDrawOffset - Overriden to prevent the player from disabling bobbing
//-----------------------------------------------------------------------------
simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Weapon.DisplayFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{
		// Added these for proneing and leaning
		DrawOffset.Z += EyePosition().Z;
		DrawOffset.X += EyePosition().X;
		DrawOffset.Y += EyePosition().Y;

	    DrawOffset += WeaponBob(Inv.BobDamping);
        DrawOffset += CameraShake();
	}
	return DrawOffset;
}

//-----------------------------------------------------------------------------
// CheckBob - Overriden to prevent the player from disabling bobbing and
// to handle playing footstep sounds in other movement states
//-----------------------------------------------------------------------------
function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D;
	local float OldBobTime;
	local int m,n;
	local float BobModifier;


	OldBobTime = BobTime;

	Bob = FClamp(Bob, -0.01, 0.01);
    BobModifier = 1.0;

	// Modify the amount of bob based on the movement state
	if( bIsSprinting )
	{
		BobModifier = 1.75;
	}
	else if( bIsCrawling && !bIronSights)
	{
		BobModifier = 2.5;
	}
	else if( bIsCrouched )
	{
		BobModifier = 2.5;
	}

	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);

		if( bIsCrawling && !bIronSights )
		{
			BobTime += DeltaTime * ((0.3 + 0.7 * Speed2D/(GroundSpeed*PronePct))/2);
		}
		else if( bIsSprinting )
		{
			if ( Speed2D < 10 )
				BobTime += 0.2 * DeltaTime;
			else
			{
				if ( bIsCrouched )
				{
					BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/((GroundSpeed*CrouchedSprintPct)/1.25));
				}
				else
				{
					BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/((GroundSpeed*SprintPct)/1.25));
				}
			}
		}
		else
		{
			if ( Speed2D < 10 )
				BobTime += 0.2 * DeltaTime;
			else
				BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		}
		WalkBob = Y * (Bob * BobModifier) * Speed2D * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( Speed2D > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * (Bob * BobModifier) * Speed2D * sin(16 * BobTime);
		if ( LandBob > 0.01 )
		{
			AppliedBob += FMin(1, 16 * deltatime) * LandBob;
			LandBob *= (1 - 8*Deltatime);
		}
	}
	else if ( Physics == PHYS_Swimming )
	{
		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}

	if ( (Physics != PHYS_Walking) || (VSize(Velocity) < 10)
		|| ((PlayerController(Controller) != None) && PlayerController(Controller).bBehindView) )
		return;

	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsCrawling)
		FootStepping(0);
}

// Footstep sound checking for non local player or non player bots
// This function is only called on non owned network clients or bots
simulated function CheckFootSteps(float DeltaTime)
{
	local float Speed2D;
	local float OldBobTime;
	local int m,n;

	OldBobTime = BobTime;

	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);

		if( bIsCrawling && !bIronSights )
		{
			BobTime += DeltaTime * ((0.3 + 0.7 * Speed2D/(GroundSpeed*PronePct))/2);
		}
		else if( bIsSprinting )
		{
			if ( Speed2D < 10 )
				BobTime += 0.2 * DeltaTime;
			else
			{
				if ( bIsCrouched )
				{
					BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/((GroundSpeed*CrouchedSprintPct)/1.25));
				}
				else
				{
					BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/((GroundSpeed*SprintPct)/1.25));
				}
			}
		}
		else
		{
			if ( Speed2D < 10 )
				BobTime += 0.2 * DeltaTime;
			else
				BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		}
	}
	else
	{
		BobTime = 0;
	}

	if ( (Physics != PHYS_Walking) || (VSize(Velocity) < 10) )
		return;

	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsCrawling)
		FootStepping(0);
}

//-----------------------------------------------------------------------------
// DisplayDebug - Used to display important debugging info on the hud
// - with bullet debugging and functionality from unrealpawn
//-----------------------------------------------------------------------------
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;

	local int	i;
	local name  Sequence;
	local float Frame, Rate;



	// From Unrealpawn
	/*
	if ( !bSoakDebug )
	{
		Super.DisplayDebug(Canvas, YL, YPos);
		return;
	}*/

	Super.DisplayDebug(Canvas, YL, YPos);

    if ( bSoakDebug )
	{

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.StrLen("TEST", XL, YL);
		YPos = YPos + 8*YL;
		Canvas.SetPos(4,YPos);
		Canvas.SetDrawColor(255,255,0);
		T = GetDebugName();
		if ( bDeleteMe )
			T = T$" DELETED (bDeleteMe == true)";
		Canvas.DrawText(T, false);
		YPos += 3 * YL;
		Canvas.SetPos(4,YPos);

		if ( Controller == None )
		{
			Canvas.SetDrawColor(255,0,0);
			Canvas.DrawText("NO CONTROLLER");
			YPos += YL;
			Canvas.SetPos(4,YPos);
		}
		else
			Controller.DisplayDebug(Canvas,YL,YPos);

		YPos += 2*YL;
		Canvas.SetPos(4,YPos);
		Canvas.SetDrawColor(0,255,255);
		Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
		YPos += YL;
		Canvas.SetPos(4,YPos);

		T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
		if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
			T=T$" on ladder "$OnLadder;
		Canvas.DrawText(T);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		// End from Unrealpawn
	}

	Canvas.SetDrawColor(255,255,255);

    Canvas.DrawText("ROWeapon state is " $GetEnum( enum'EWeaponState', WeaponState));
    YPos += YL;
    Canvas.SetPos(4,YPos);

	Canvas.DrawText("Stamina:"@Stamina);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	for( i = 0; i < 16; i++ )
	{
		if( IsAnimating( i ) )
		{
			GetAnimParams( i, Sequence, Frame, Rate );
			Canvas.DrawText("Anim:: Channel("@i@") Frame("@Frame@") Rate("@Rate@") Name("@Sequence@")");
			YPos += YL;
			Canvas.SetPos(4,YPos);
		}
	}

	if (WeaponAttachment != None)
	{
			WeaponAttachment.GetAnimParams( 0, Sequence, Frame, Rate );
			Canvas.DrawText("WeaponAttachment Anim: Frame("@Frame@") Rate("@Rate@") Name("@Sequence@")");
			YPos += YL;
			Canvas.SetPos(4,YPos);
	}

	if (Weapon != None)
	{
			Weapon.GetAnimParams( 0, Sequence, Frame, Rate );
			Canvas.DrawText("Weapon Anim: Frame("@Frame@") Rate("@Rate@") Name("@Sequence@")");
			YPos += YL;
			Canvas.SetPos(4,YPos);
	}

//	Canvas.DrawText("CanBipodDeploy: "@bCanBipodDeploy$" BipodDeployed: "@bBipodDeployed);
//	YPos += YL;
//	Canvas.SetPos(4,YPos);

//	Canvas.DrawText("BaseEyeHeight: "$default.BaseEyeHeight$"DeployedEyeHeight: "@DeployedEyeHeight$" ProneEyeHeight: "@ProneEyeHeight$" CrouchEyeHeight: "$(CrouchEyeHeightMod * CrouchHeight)$" CrouchMoveEyeHeight "$(CrouchMoveEyeHeightMod * CrouchHeight));
//	YPos += YL;
//	Canvas.SetPos(4,YPos);



/*	Canvas.DrawText("PrePivot:"@PrePivot);
	YPos += YL;
	Canvas.SetPos(4,YPos); */

/*	Canvas.DrawText("maxyaw is "@maxyaw@" minyaw is "@minyaw);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("bUsedCarriedMGAmmo is "@bUsedCarriedMGAmmo);
	YPos += YL;
	Canvas.SetPos(4,YPos);


	Canvas.DrawText("debugPitchUpLimit is "@debugPitchUpLimit@" debugPitchDownLimit is "@debugPitchDownLimit);
	YPos += YL;
	Canvas.SetPos(4,YPos);*/
}

//=============================================================
// Animation
//=============================================================

//-----------------------------------------------------------------------------
// SetIronSightAnims - Sets the proper player animations for aiming and non-aiming
//-----------------------------------------------------------------------------
function SetIronSightAnims(bool bNewIronSights)
{
	bIronSights = bNewIronSights;
}

//-----------------------------------------------------------------------------
// SetMeleeHoldAnims - Sets the proper player animations melee attacks
//-----------------------------------------------------------------------------
function SetMeleeHoldAnims(bool bNewMeleeHold)
{
	bMeleeHolding = bNewMeleeHold;
}

//-----------------------------------------------------------------------------
// SetMeleeHoldAnims - Sets the proper player animations prepping to fire an explosive weapon
//-----------------------------------------------------------------------------
function SetExplosiveHoldAnims(bool bNewExplosiveHold)
{
	bExplosiveHolding = bNewExplosiveHold;
}

//-----------------------------------------------------------------------------
// SetIronSightAnims - Sets the proper player animations for aiming and non-aiming
//-----------------------------------------------------------------------------
function SetBipodDeployed(bool bNewDeployed)
{
	if( !bNewDeployed && bBipodDeployed )
	{
	 	bBipodDeployed = false;
	 	InitialDeployedRotation = rot(0,0,0);

	 	if( bIsCrawling )
	 	{
		 	BaseEyeHeight = ProneEyeHeight;
		}
		else if ( bIsCrouched )
		{
  			BaseEyeHeight = CrouchEyeHeightMod * CrouchHeight;
		}
		else
		{
			BaseEyeHeight = default.BaseEyeHeight;
		}

	 	if( Role == ROLE_Authority )
	 	{
	 		SetAnimAction('DoBipodUnDeploy');
	 	}
	}
	else if( bNewDeployed )
	{
		bBipodDeployed = true;
		InitialDeployedRotation.Pitch = Rotation.Pitch & 65535;
		InitialDeployedRotation.Yaw = Rotation.Yaw;

		if ( !bIsCrouched && !bIsCrawling && DeployedEyeHeight < 30 )
		{
			BaseEyeHeight = DeployedEyeHeight + 10;
			ROPlayer(Controller).Crouch();
		}
		else if ( !bIsCrawling )
		{
        	BaseEyeHeight = DeployedEyeHeight;
        }

	 	if( Role == ROLE_Authority )
	 	{
	 		SetAnimAction('DoBipodDeploy');
	 	}
	}
}


// Returns true if TestAnim is an animation for
// drawing a weapon
simulated function bool IsDrawAnim(name TestAnim)
{
	switch( TestAnim )
    {
        case 'stand_draw_kar':
        case 'stand_draw_nade':
        case 'stand_nadefromrifle':
        case 'stand_riflefromnade':
        case 'stand_pistolfromrifle':
        case 'stand_riflefrompistol':
        case 'stand_nadefrompistol':
        case 'stand_pistolfromnade':
        case 'prone_draw_kar':
        case 'prone_draw_nade':
        case 'prone_nadefromrifle':
        case 'prone_riflefromnade':
        case 'prone_pistolfromrifle':
        case 'prone_riflefrompistol':
        case 'prone_nadefrompistol':
        case 'prone_pistolfromnade':
			return true;
            break;
    }

    return false;
}

// Returns true if TestAnim is an animation for
// putting away a weapon
simulated function bool IsPutAwayAnim(name TestAnim)
{
	switch( TestAnim )
    {
        case 'stand_putaway_kar':
        case 'stand_putaway_nade':
        case 'stand_putaway_pistol':
        case 'prone_putaway_kar':
        case 'prone_putaway_nade':
        case 'prone_putaway_pistol':
			return true;
            break;
    }

    return false;
}

// This function plays an upper body anim that will blend back to full body
// after the animation finishes. Must set the paramaters with an AnimBlendParams()
// call before calling this function
simulated function PlayUpperBodyAnim( name NewAnim, optional float InRate, optional float TweenTime, optional float InBlendTime )
{
	local float Rate;
	local float BlendTime;

	if ( InRate == 0 )
	{
		Rate = 1.0;
	}
	else
	{
		Rate = InRate;
	}

	if ( InBlendTime == 0 )
	{
		BlendTime = GetAnimDuration(NewAnim, Rate) + TweenTime;
	}
	else
	{
		BlendTime = InBlendTime;
	}

    PlayAnim(NewAnim,Rate, TweenTime, 1);
    AnimBlendTime = BlendTime;
}

// Get the alernate animaction name for a given animaction
simulated function name GetAltName(name TestName)
{
	switch( TestName )
    {
        case 'DoStandardReload':
        	return 'DoStandardReloadA';
        	break;
        case 'DoBoltAction':
        	return 'DoBoltActionA';
        	break;
    }

    return GetAnimActionName(TestName);
}

// Get the standard animaction name for a given alternate animaction
simulated function name GetAnimActionName(name TestName)
{
	switch( TestName )
    {
        case 'DoStandardReloadA':
        	return 'DoStandardReload';
        	break;
        case 'DoBoltActionA':
        	return 'DoBoltAction';
        	break;
    }

    return TestName;
}

//-----------------------------------------------------------------------------
// SetAnimAction - Checks WeaponState (new enum for added anim capabilities) instead of FiringState
//-----------------------------------------------------------------------------
// MergeTODO: The way this is done right now is pretty buggy. Lets try and clean this up
simulated event SetAnimAction(name NewAction)
{
	local name UsedAction;

    if (!bWaitForAnim)
    {
		// Since you can't call SetAnimAction for the same action twice in a row (it won't get replicated)
		// For animations that need to happen twice in a row (such as working the bolt of a rifle)
		// we alternate animaction names for these actions so they replicate properly
		if( Level.Netmode == NM_Client )
		{
			UsedAction = GetAnimActionName(NewAction);
		}
		else
		{
			UsedAction = NewAction;

			if( AnimAction == NewAction )
			{
				NewAction = GetAltName(NewAction);
			}
		}


	    AnimAction = NewAction;

	    // Weapon switching actions
		if ( IsDrawAnim(UsedAction) )
        {
            AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
            AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);
            PlayUpperBodyAnim( UsedAction, 1.0, 0.0 );
         }
        else if ( IsPutAwayAnim(UsedAction) )
        {
            AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
            AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);
            WeaponState = GS_IgnoreAnimend;
            PlayUpperBodyAnim( UsedAction, 1.0, 0.1, GetAnimDuration(AnimAction,1.0) * 2);

        }
		else if ( UsedAction == 'ClearAnims' )
		{
   			AnimBlendToAlpha(1, 0.0, 0.12);
		}
		else if ( UsedAction == 'TossedWeapon' )
		{
			SetWeaponAttachment(none);
		}
		else if ( UsedAction == 'DoStandardReload' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayStandardReload();
		}
		else if ( UsedAction == 'DoBayoAttach' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayBayonetAttach();
		}
		else if ( UsedAction == 'DoBayoDetach' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayBayonetDetach();
		}
		else if ( UsedAction == 'DoBipodDeploy' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayBipodDeploy();
		}
		else if ( UsedAction == 'DoBipodUnDeploy' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayBipodUnDeploy();
		}
		else if ( UsedAction == 'DoBoltAction' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayBoltAction();
		}
		else if ( UsedAction == 'DoLoopingReload' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayStartReloading();
		}
		else if ( UsedAction == 'DoReloadEnd' )
		{
			if( Level.NetMode != NM_DedicatedServer )
				PlayStopReloading();
		}
        else if ( UsedAction == 'StartCrawling')
        {
        	bWaitForAnim = true;
        	GotoState('StartProning');
        }
        else if ( UsedAction == 'EndCrawling')
        {
        	bWaitForAnim = true;
        	GotoState('EndProning');
        }
        else if ( UsedAction == 'DiveToProne')
        {
        	bWaitForAnim = true;
        	GotoState('DivingToProne');
        }
        else if ( UsedAction == 'ProneToCrouch')
        {
        	bWaitForAnim = true;
        	GotoState('CrouchingFromProne');
        }
        else if ( UsedAction == 'CrouchToProne')
        {
        	bWaitForAnim = true;
        	GotoState('ProningFromCrouch');
        }
        else if ( (Physics == PHYS_None)
			|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')) )
        {
            PlayAnim(UsedAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
		{
			if ( CheckTauntValid(UsedAction) )
			{
				if (WeaponState == GS_None || WeaponState == GS_Ready)
				{
					AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
					PlayAnim(UsedAction,, 0.1, 1);
					WeaponState = GS_Ready;
				}
			}
			else if ( PlayAnim(UsedAction) )
			{
				if ( Physics != PHYS_None )
				{
					bWaitForAnim = true;
				}
			}
			else
			{
				AnimAction = '';
			}
		}
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {
            PlayAnim(UsedAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
            if (WeaponState == GS_None || WeaponState == GS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                PlayAnim(UsedAction,, 0.1, 1);
                WeaponState = GS_Ready;
            }
        }
    }
}

// Called on the server. Sends a message to the client to let them know to play the bayoattach
function HandleBoltAction()
{
	SetAnimAction('DoBoltAction');
}

//-----------------------------------------------------------------------------
// PlayBayonetAttach - Bayonet anims
//-----------------------------------------------------------------------------

simulated function PlayBoltAction()
{
	local name Anim;
	local bool bIsMoving;

	bIsMoving = VSizeSquared(Velocity) > 25;

	if (WeaponAttachment != None)
	{
		if (bIsCrawling)
		{
			Anim = WeaponAttachment.PA_ProneBoltActionAnim;
		}
		else if( bIsCrouched )
		{
			if( bIsMoving || bIronSights )
			{
				Anim = WeaponAttachment.PA_CrouchIronBoltActionAnim;
			}
			else
			{
				Anim = WeaponAttachment.PA_CrouchBoltActionAnim;
			}
		}
		else
		{
			if( bIronSights )
			{
				Anim = WeaponAttachment.PA_StandIronBoltActionAnim;
			}
			else
			{
				Anim = WeaponAttachment.PA_StandBoltActionAnim;
			}
		}

        AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);

		PlayAnim(Anim,, 0.1, 1);
	// TODO: Plug in the weapons animation
		if (WeaponAttachment.bBayonetAttached)
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_BayonetWorkBolt,, 0.1);
		else
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_WorkBolt,, 0.1);

		AnimBlendTime = GetAnimDuration(Anim, 1.0) + 0.1;
	}
}


// Called on the server. Sends a message to the client to let them know to play the bayoattach
function HandleBayoAttach()
{
	SetAnimAction('DoBayoAttach');
}

//-----------------------------------------------------------------------------
// PlayBayonetAttach - Bayonet anims
//-----------------------------------------------------------------------------

simulated function PlayBayonetAttach()
{
	local name Anim, WeapAnim;

	if (WeaponAttachment != None)
	{
		if (bIsCrawling)
			Anim = WeaponAttachment.PA_ProneBayonetAttachAnim;
		else
			Anim = WeaponAttachment.PA_BayonetAttachAnim;

        AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);

		PlayAnim(Anim,, 0.1, 1);

		if( bIsCrawling )
		{
			WeapAnim = WeaponAttachment.WA_BayonetAttachProne;
		}
		else
		{
		   	WeapAnim = WeaponAttachment.WA_BayonetAttach;
		}

 		WeaponAttachment.PlayAnim(WeapAnim,, 0.1);

		AnimBlendTime = GetAnimDuration(Anim, 1.0)+0.1;
	}
}

// Called on the server. Sends a message to the client to let them know to play the bayoattach
function HandleBayoDetach()
{
	SetAnimAction('DoBayoDetach');
}

//-----------------------------------------------------------------------------
// PlayBayonetDetach - Bayonet anims
//-----------------------------------------------------------------------------

simulated function PlayBayonetDetach()
{
	local name Anim, WeapAnim;

	if (WeaponAttachment != None)
	{
		if (bIsCrawling)
			Anim = WeaponAttachment.PA_ProneBayonetDetachAnim;
		else
			Anim = WeaponAttachment.PA_BayonetDetachAnim;

        AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);

		PlayAnim(Anim,, 0.1, 1);
		if( bIsCrawling )
		{
			WeapAnim = WeaponAttachment.WA_BayonetDetachProne;
		}
		else
		{
		   	WeapAnim = WeaponAttachment.WA_BayonetDetach;
		}

 		WeaponAttachment.PlayAnim(WeapAnim,, 0.1);

		AnimBlendTime = GetAnimDuration(Anim, 1.0)+0.1;
	}
}

//------------------------------------------------------------------------------
// PlayWeaponDeploy - Plays weapon and player deployment animations
//------------------------------------------------------------------------------
simulated function PlayBipodDeploy()
{
	local name Anim;

	if( WeaponAttachment != none )
	{
		if( bIsCrawling )
		{
			Anim = WeaponAttachment.PA_ProneWeaponDeployAnim;
		}
		else
		{
			Anim = WeaponAttachment.PA_StandWeaponDeployAnim;
		}

        AnimBlendParams(1,1.0, 0.0, 0.2, FireRootBone);
		PlayAnim(Anim,, 0.1, 1);

		// Replaceme when we get actual transition anims
		AnimBlendTime = 0.02;//GetAnimDuration(Anim, 1.0)+0.1;

		if( WeaponAttachment.HasAnim(WeaponAttachment.WA_WeaponDeploy) )
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_WeaponDeploy,, 0.1);
	}
}

//------------------------------------------------------------------------------
// PlayWeaponUnDeploy - Plays weapon and player un-deployment animations
//------------------------------------------------------------------------------
simulated function PlayBipodUnDeploy()
{
	local name Anim;

	if( WeaponAttachment != none )
	{
		if( bIsCrawling )
		{
			Anim = WeaponAttachment.PA_ProneWeaponUnDeployAnim;
		}
		else
		{
			Anim = WeaponAttachment.PA_StandWeaponUnDeployAnim;
		}

        AnimBlendParams(1,1.0, 0.0, 0.2, FireRootBone);
		PlayAnim(Anim,, 0.1, 1);

		// Replaceme when we get actual transition anims
		AnimBlendTime = 0.02;//GetAnimDuration(Anim, 1.0)+0.1;

		if( WeaponAttachment.HasAnim(WeaponAttachment.WA_WeaponUnDeploy) )
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_WeaponUnDeploy,, 0.1);
	}
}

//-----------------------------------------------------------------------------
// PlayStartCrawling - Plays the anim going into prone
//-----------------------------------------------------------------------------
simulated function PlayStartCrawling()
{
	local name Anim;
	local float AnimTimer;

	if (bIsCrouched)
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_CrouchToProneAnim;
		else
			Anim = CrouchToProneAnim;

		PlayOwnedSound(CrouchToProneSound, SLOT_Interact, 1.0,, 10);
	}
	else
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_StandToProneAnim;
		else
			Anim = StandToProneAnim;

		PlayOwnedSound(StandToProneSound, SLOT_Interact, 1.0,, 10);
	}

    AnimTimer = GetAnimDuration(Anim, 1.0);

    // Have the server finish the prone transition state slightly before the client (fixes some client/server sync issues)
	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);

	if (bIsIdle && !bIsCrouched)
	{
		PlayAnim(Anim,1.0,0.0,0);
	}
	else
	{
		PlayAnim(Anim,1.0,0.0,0);
		WeaponState = GS_Ready;
	}
}

//-----------------------------------------------------------------------------
// PlayEndCrawling - Plays the anim going out of prone
//-----------------------------------------------------------------------------
simulated function PlayEndCrawling()
{
	local name Anim;
	local float AnimTimer;

	if (bIsCrouched)
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_ProneToCrouchAnim;
		else
			Anim = ProneToCrouchAnim;

		PlayOwnedSound(ProneToCrouchSound, SLOT_Interact, 1.0,, 10);
	}
	else
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_ProneToStandAnim;
		else
			Anim = ProneToStandAnim;

		PlayOwnedSound(ProneToStandSound, SLOT_Interact, 1.0,, 10);
	}

    AnimTimer = GetAnimDuration(Anim, 1.0);

    // Have the server finish the prone transition state slightly before the client (fixes some client/server sync issues)
	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);


	if (bIsIdle && !bIsCrouched)
	{
		PlayAnim(Anim,1.0,0.0,0);
	}
        else
	{
		PlayAnim(Anim,1.0,0.0,0);
		WeaponState = GS_Ready;
	}
}

//-----------------------------------------------------------------------------
// PlayProningFromCrouch - Plays the anim going into prone from crouched
//-----------------------------------------------------------------------------
simulated function PlayProningFromCrouch()
{
	local name Anim;
	local float AnimTimer;

	if (WeaponAttachment != None)
		Anim = WeaponAttachment.PA_CrouchToProneAnim;
	else
		Anim = CrouchToProneAnim;

	PlayOwnedSound(CrouchToProneSound, SLOT_Interact, 1.0,, 10);

    AnimTimer = GetAnimDuration(Anim, 1.0);

    // Have the server finish the prone transition state slightly before the client (fixes some client/server sync issues)
	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
	PlayAnim(Anim,1.0,0.0,0);
}

//-----------------------------------------------------------------------------
// PlayCrouchingFromProne - Plays the anim going out of prone to crouch
//-----------------------------------------------------------------------------
simulated function PlayCrouchingFromProne()
{
	local name Anim;
	local float AnimTimer;

	if (WeaponAttachment != None)
		Anim = WeaponAttachment.PA_ProneToCrouchAnim;
	else
		Anim = ProneToCrouchAnim;

	PlayOwnedSound(ProneToCrouchSound, SLOT_Interact, 1.0,, 10);

	AnimTimer = GetAnimDuration(Anim, 1.0);

    // Have the server finish the prone transition state slightly before the client (fixes some client/server sync issues)
	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);
	PlayAnim(Anim,1.0,0.0,0);
}


//-----------------------------------------------------------------------------
// PlayGrenadeBack
//-----------------------------------------------------------------------------

simulated function PlayGrenadeBack()
{
	AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

	if (bIsCrawling)
		PlayAnim('prone_pullpin_nade',, 0.0, 1);
	else
		PlayAnim('stand_pullpin_nade',, 0.0, 1);

	WeaponState = GS_GrenadePullBack;
}

//-----------------------------------------------------------------------------
// SetWeaponAttachment - Update anims to match attachment
//-----------------------------------------------------------------------------
simulated function SetWeaponAttachment(ROWeaponAttachment NewAtt)
{
	WeaponAttachment = NewAtt;

	if (!bInitializedWeaponAttachment && NewAtt != none)
		bInitializedWeaponAttachment = true;

	if( WeaponAttachment == none )
		return;

	if( ROProjectileWeapon(Weapon) != none )
		WeaponAttachment.bBayonetAttached = ROProjectileWeapon(Weapon).bBayonetMounted;
	WeaponAttachment.AnimEnd(0);
}

//-----------------------------------------------------------------------------
// CheckWeaponAttachment - Occasionally the packets that tell the
// clients when a new weaponattachment should be set arrive out of
// order. The destroy function of ROWeaponAttachment called this
// function to correct that problem (since a destroyed weapon
// attachement should pretty much never be the current weapon
// attachement.
//-----------------------------------------------------------------------------
simulated function CheckWeaponAttachment(ROWeaponAttachment TestAtt)
{
	local int i;

	if( WeaponAttachment == TestAtt )
	{
		// Try and find weapon attachement
	    for( i = 0; i < Attached.length; i++ )
	    {
	        if( Attached[i].IsA('ROWeaponAttachment') && Attached[i] != TestAtt)
	        {
	        	SetWeaponAttachment(ROWeaponAttachment(Attached[i]));
	        	break;
	        }
	    }
    }
}


//-----------------------------------------------------------------------------
// AnimEnd - Figure out what to do with the weapon anims
//-----------------------------------------------------------------------------
// MergeTODO: This looks like a TERRIBLE way to handle reloads and firing anims. Lets refactor this
simulated event AnimEnd(int Channel)
{
	local name WeapAnim, PlayerAnim;
	local bool bIsMoving;
	local name Anim;
	local float frame, rate;

	bIsMoving = VSizeSquared(Velocity) > 25;

	if( DrivenVehicle != none )
	{
		PlayAnim(DrivenVehicle.DriveAnim,1.0,, 1);
	}
	else if (Channel == 1 && WeaponState != GS_IgnoreAnimend)
	{
		if (WeaponState == GS_Ready)
		{
			AnimBlendToAlpha(1, 0.0, 0.12);
			WeaponState = GS_None;
		}
		else if (WeaponState == GS_FireSingle || WeaponState == GS_ReloadSingle)
		{
		 	// This used to play the idle animation after the firing anim was played
		 	// and then set the weaponstate to GS_Ready, which would handle resetting
		 	// the upperbody blending params when the animation ended. That didn't
		 	// work well for us, so now we do that here - Ramm

			// Stop the rapid fire anim from looping
            AnimStopLooping(1);

			if( bIsMoving )
			{
				AnimBlendToAlpha(1, 0.0, 0.12);
				WeaponState = GS_None;
			}
			else
			{
                AnimBlendToAlpha(1, 0.0, 0.12);

				WeaponState = GS_None;
				IdleTime = Level.TimeSeconds;
			}

			if (WeaponAttachment != none)
			{
				WeaponAttachment.GetAnimParams(0, Anim, frame, rate);

				if (WeaponAttachment.bBayonetAttached)
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_BayonetIdleEmpty != '' && Anim != WeaponAttachment.WA_BayonetReloadEmpty)
						WeaponAttachment.LoopAnim(WeaponAttachment.WA_BayonetIdleEmpty);
					else if (WeaponAttachment.WA_BayonetIdle != '')
						WeaponAttachment.LoopAnim(WeaponAttachment.WA_BayonetIdle);
				}
				else
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_IdleEmpty != '' && Anim != WeaponAttachment.WA_ReloadEmpty)
						WeaponAttachment.LoopAnim(WeaponAttachment.WA_IdleEmpty);
					else
						WeaponAttachment.LoopAnim(WeaponAttachment.WA_Idle);
				}
			}
		}
		else if (WeaponState == GS_GrenadePullBack)
		{
			if (bIsCrawling)
				LoopAnim('prone_hold_nade',, 0.0, 1);
			else
				LoopAnim('stand_hold_nade',, 0.0, 1);

			WeaponState = GS_GrenadeHoldBack;
			IdleTime = Level.TimeSeconds;
		}
		else if (WeaponState == GS_PreReload && WeaponAttachment != None)
		{
	        AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
	        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);

			if (WeaponAttachment.bOutOfAmmo)
			{
				if (bIsCrawling)
					PlayerAnim = WeaponAttachment.PA_ProneReloadEmptyAnim;
				else
					PlayerAnim = WeaponAttachment.PA_ReloadEmptyAnim;
			}
			else
			{
				if (bIsCrawling)
					PlayerAnim = WeaponAttachment.PA_ProneReloadAnim;
				else
					PlayerAnim = WeaponAttachment.PA_ReloadAnim;
			}

			LoopAnim(PlayerAnim,, 0.0, 1);
			WeaponState = GS_ReloadLooped;
			IdleTime = Level.TimeSeconds;

			if (WeaponAttachment.bBayonetAttached)
			{
				if( bIsCrawling )
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_BayonetProneReloadEmpty != '')
						WeapAnim = WeaponAttachment.WA_BayonetProneReloadEmpty;
					else if (WeaponAttachment.WA_BayonetProneReload != '')
						WeapAnim = WeaponAttachment.WA_BayonetProneReload;
				}
				else
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_BayonetReloadEmpty != '')
						WeapAnim = WeaponAttachment.WA_BayonetReloadEmpty;
					else if (WeaponAttachment.WA_BayonetReload != '')
						WeapAnim = WeaponAttachment.WA_BayonetReload;
				}
			}
			else
			{
				if( bIsCrawling )
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_ProneReloadEmpty != '')
						WeapAnim = WeaponAttachment.WA_ProneReloadEmpty;
					else if (WeaponAttachment.WA_ProneReload != '')
						WeapAnim = WeaponAttachment.WA_ProneReload;
				}
				else
				{
					if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_ReloadEmpty != '')
						WeapAnim = WeaponAttachment.WA_ReloadEmpty;
					else
						WeapAnim = WeaponAttachment.WA_Reload;
				}
			}

			WeaponAttachment.LoopAnim(WeapAnim);
		}
		else if (WeaponState != GS_ReloadLooped && WeaponState != GS_GrenadeHoldBack && WeaponState != GS_FireLooped)
		{
			//Level.Game.Broadcast(self, "In the else in AnimEnd()");
			AnimBlendToAlpha(1, 0.0, 0.12);
		}
	}
	else if ( bKeepTaunting && (Channel == 0) )
		PlayVictoryAnimation();
}

//-----------------------------------------------------------------------------
// PlayHit - Redone again since butto hacked it up - Ramm
//-----------------------------------------------------------------------------
// MergeTODO: Work on the gore part of this to make it better
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
    local Vector HitNormal;
    local Name HitBone;
    local float HitBoneDist;
    local PlayerController PC;
	local bool bShowEffects, bRecentHit;
	local ProjectileBloodSplat BloodHit;
	local rotator SplatRot;

	bRecentHit = Level.TimeSeconds - LastPainTime < 0.2;

	// Call the modified version of the original Pawn playhit
	OldPlayHit(Damage,InstigatedBy,HitLocation,DamageType,Momentum);

	if ( Damage <= 0 )
		return;

    PC = PlayerController(Controller);
	bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 2.5)
					|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None))
					|| (PC != None) );
	if ( !bShowEffects )
		return;

    if( DamageType.default.bLocationalHit )
    {
        HitBone = GetHitBoneFromIndex(HitIndex);
        HitBoneDist = 0.0f;
    }
    else
    {
        HitLocation = Location;
        HitBone = 'None';
        HitBoneDist = 0.0f;
    }

    if( DamageType.default.bAlwaysSevers && DamageType.default.bSpecial )
        HitBone = 'head';

	if( InstigatedBy != None )
		HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
	else
		HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

	if ( DamageType.Default.bCausesBlood && (!bRecentHit || (bRecentHit && (FRand() > 0.8))))
	{
		if ( !class'GameInfo'.static.NoBlood() ) //class'GameInfo'.static.UseLowGore()
		{
        	if ( Momentum != vect(0,0,0) )
				SplatRot = rotator(Normal(Momentum));
			else
			{
				if ( InstigatedBy != None )
					SplatRot = rotator(Normal(Location - InstigatedBy.Location));
				else
					SplatRot = rotator(Normal(Location - HitLocation));
			}

		 	BloodHit = Spawn(ProjectileBloodSplatClass,InstigatedBy,, HitLocation, SplatRot);
		}
	}

	DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );

	if (DamageType.default.DamageOverlayMaterial != None && Damage > 0 ) // additional check in case shield absorbed
				SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false );
}

// Modified version of the original Pawn playhit. Set up because we want our blood puffs to be directional based
// On the momentum of the bullet, not out from the center of the player
function OldPlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
    local Vector HitNormal;
	local vector BloodOffset, Mo;
	local class<Effects> DesiredEffect;
	local class<Emitter> DesiredEmitter;
	local PlayerController Hearer;

	if ( DamageType == None )
		return;
	if ( (Damage <= 0) && ((Controller == None) || !Controller.bGodMode) )
		return;

	if (Damage > DamageType.Default.DamageThreshold) //spawn some blood
	{

		HitNormal = Normal(HitLocation - Location);

		// Play any set effect
		if ( EffectIsRelevant(Location,true) )
		{
			DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));

			if ( DesiredEffect != None )
			{
				BloodOffset = 0.2 * CollisionRadius * HitNormal;
				BloodOffset.Z = BloodOffset.Z * 0.5;

				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
			}

			// Spawn any preset emitter

			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));
			if (DesiredEmitter != None)
			{
			    if( InstigatedBy != none )
			        HitNormal = Normal((InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight))-HitLocation);

				spawn(DesiredEmitter,,,HitLocation+HitNormal, Rotator(HitNormal));
			}
		}
	}
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}

	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		if ( InstigatedBy != None && (DamageType != None) && DamageType.default.bDirectDamage )
			Hearer = PlayerController(InstigatedBy.Controller);
		if ( Hearer != None )
			Hearer.bAcuteHearing = true;
		PlayTakeHit(HitLocation,Damage,damageType);
		if ( Hearer != None )
			Hearer.bAcuteHearing = false;
		LastPainTime = Level.TimeSeconds;
	}
}

// Returns the bone name for a given hitpoint index
simulated function name GetHitBoneFromIndex(int HitIndex)
{
	// Just return the spine if its out of bounds for the array
	if( HitIndex < 1 || HitIndex > 15 )
	{
		return 'Spine';
	}
	else
	{
		return HitPoints[HitIndex].PointBone;
	}
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;

	GetAxes(Rotation, X,Y,Z);
	HitLoc.Z = Location.Z;

	// random
	if ( VSize(Velocity) < 10.0 && VSize(Location - HitLoc) < 1.0 )
	{
		Dir = VRand();
	}
	// velocity based
	else if ( VSize(Velocity) > 0.0 )
	{
		Dir = Normal(Velocity*Vect(1,1,0));
	}
	// hit location based
	else
	{
		Dir = -Normal(Location - HitLoc);
	}

	// MergeTODO: Need these missing anims
	if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
		PlayAnim('DeathB',, 0.2);
	else if ( Dir Dot X < -0.7 )
		 PlayAnim('DeathF',, 0.2);
	else if ( Dir Dot Y > 0 )
		PlayAnim('DeathL',, 0.2);
	else
		PlayAnim('DeathR',, 0.2);
}

// MergeTODO: This needs work, it really doesn't work properly for a prone player
simulated function PlayDirectionalHit(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;
	local bool bLegHit;

	GetAxes(Rotation, X,Y,Z);

	bLegHit = Location.Z - HitLoc.Z < CollisionHeight * 0.7;

	HitLoc.Z = Location.Z;

	// random
	if ( VSize(Location - HitLoc) < 1.0 )
	{
		Dir = VRand();
	}
	// hit location based
	else
	{
		Dir = -Normal(Location - HitLoc);
	}

	if (bIsCrawling)
	{
		if (WeaponAttachment != None)
			PlayAnim(WeaponAttachment.PA_ProneHitAnim,, 0.1);
		else
			PlayAnim(ProneHitAnim,, 0.1);

		return;
	}
	else if (bIsCrouched)
	{
		if (bLegHit)
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_CrouchHitUpAnim,, 0.1);
			else
				PlayAnim(CrouchHitUpAnim,, 0.1);
		}
		else
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_CrouchHitDownAnim,, 0.1);
			else
				PlayAnim(CrouchHitDownAnim,, 0.1);
		}
	}

	if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
	{
		if (WeaponAttachment != None)
			PlayAnim(WeaponAttachment.PA_HitFAnim,, 0.1);
		else
			PlayAnim(HitFAnim,, 0.1);
	}
	else if ( Dir Dot X < -0.7 )
	{
		if (WeaponAttachment != None)
			PlayAnim(WeaponAttachment.PA_HitBAnim,, 0.1);
		else
			PlayAnim(HitBAnim,, 0.1);
	}
	else if ( Dir Dot Y > 0 )
	{
		if (bLegHit)
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_HitRLegAnim,, 0.1);
			else
				PlayAnim(HitRLegAnim,, 0.1);
		}
		else
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_HitRAnim,, 0.1);
			else
				PlayAnim(HitRAnim,, 0.1);
		}
	}
	else
	{
		if (bLegHit)
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_HitLLegAnim,, 0.1);
			else
				PlayAnim(HitLLegAnim,, 0.1);
		}
		else
		{
			if (WeaponAttachment != None)
				PlayAnim(WeaponAttachment.PA_HitLAnim,, 0.1);
			else
				PlayAnim(HitLAnim,, 0.1);
		}
	}
}

//=============================================================
// Weapons/Inventory
//=============================================================

// Overriden to set the weapon attachment to none when the weapon
// is thrown out. This will cause the correct animations to played
// by the physics system.
function DeleteInventory( inventory Item )
{
	super.DeleteInventory( Item );

	// Don't set the weaponattachment to none because we've already switched to another weapon
	if( WeaponAttachment != none && Item.AttachmentClass != WeaponAttachment.Class )
	{
		return;
	}

	if( Item.IsA('Weapon'))
	{
		SetAnimAction('TossedWeapon');
	}
}


//-----------------------------------------------------------------------------
// AddDefaultInventory - Add inventory based on role and weapons choices
//-----------------------------------------------------------------------------
// MergeTODO: This doesn't seem too bad, except we need to turn nades back on for bots at some point
function AddDefaultInventory()
{
	local int i;
	local string S;
	local ROPlayer P;
	local ROBot B;
	local RORoleInfo RI;

	if (Controller == None)
		return;

	P = ROPlayer(Controller);
	B = ROBot(Controller);

	if (IsLocallyControlled())
	{
		if (P != None)
		{
			S = P.GetPrimaryWeapon();

			if (S != "")
				CreateInventory(S);

			S = P.GetSecondaryWeapon();

			if (S != "")
				CreateInventory(S);

			S = P.GetGrenadeWeapon();

			if (S != "")
				CreateInventory(S);

			RI = P.GetRoleInfo();

			if (RI != None)
			{
				for (i = 0; i < RI.GivenItems.Length; i++)
					CreateInventory(RI.GivenItems[i]);
			}
		}
		else if (B != None)
		{
			S = B.GetPrimaryWeapon();

			if (S != "")
				CreateInventory(S);

			S = B.GetSecondaryWeapon();

			if (S != "")
				CreateInventory(S);

            // Not letting bots have nades till we get code in so bots can use them well - Ramm
/*			S = B.GetGrenadeWeapon();

			if (S != "")
				CreateInventory(S); */

			RI = B.GetRoleInfo();

			if (RI != None)
			{
				for (i = 0; i < RI.GivenItems.Length; i++)
					CreateInventory(RI.GivenItems[i]);
			}
		}

		Level.Game.AddGameSpecificInventory(self);
	}
	else
	{
		Level.Game.AddGameSpecificInventory(self);

		if (P != None)
		{
			RI = P.GetRoleInfo();

			if (RI != None)
			{
				for (i = RI.GivenItems.Length - 1; i >= 0; i--)
					CreateInventory(RI.GivenItems[i]);
			}

			S = P.GetGrenadeWeapon();

			if (S != "")
				CreateInventory(S);

			S = P.GetSecondaryWeapon();

			if (S != "")
				CreateInventory(S);

			S = P.GetPrimaryWeapon();

			if (S != "")
				CreateInventory(S);
		}
	}

    NetUpdateTime = Level.TimeSeconds - 1;

	// HACK FIXME
	if (Inventory != None)
		Inventory.OwnerEvent('LoadOut');

	if( Level.Netmode == NM_Standalone || Level.Netmode == NM_ListenServer && IsLocallyControlled())
	{
		bRecievedInitialLoadout = true;
		Controller.ClientSwitchToBestWeapon();
	}
}

// Hacked in so ammo supply volumes give explosive weapons as well
function bool ResupplyExplosiveWeapons()
{
	local int i;
	local string S;
	local ROPlayer P;
	local RORoleInfo RI;
	local bool bDidResupply;
	local class<Inventory> InventoryClass;

	if (Controller == None)
		return false;

	P = ROPlayer(Controller);

	// For now we don't give bots nades until they know how to use them
	if( P == none )
		return false;

	S = P.GetGrenadeWeapon();

	if( S != "" )
		InventoryClass = Level.Game.BaseMutator.GetInventoryClass(S);

	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		CreateInventory(S);
		bDidResupply=true;
	}

	RI = P.GetRoleInfo();

	if (RI != None)
	{
		for (i = RI.GivenItems.Length - 1; i >= 0; i--)
		{
			InventoryClass = none;
			InventoryClass = Level.Game.BaseMutator.GetInventoryClass(RI.GivenItems[i]);

			if(	(InventoryClass!=None) && (FindInventoryType(InventoryClass)==None)  )
			{
				CreateInventory(RI.GivenItems[i]);
				bDidResupply=true;
			}
		}
	}

	return bDidResupply;
}

//-----------------------------------------------------------------------------
// CanSwitchWeapon
//-----------------------------------------------------------------------------
simulated function bool CanSwitchWeapon()
{
	if( IsInState('StartProning') || IsInState('EndProning') || IsInState('DiveToProne') )
		return false;

	if (bIsCrawling && Acceleration != vect(0,0,0))
		return false;

    // If the weapon is busy, don't allow a switch
	if (Weapon != None && !Weapon.WeaponCanSwitch())
		return false;

	return true;
}

//-----------------------------------------------------------------------------
// CanBusySwitchWeapon - The weapon can be switched even though the player
// or the weapon is busy (Needed for certain cases like nades - don't want to
// prevent someone from finishing throwing thier nade and cause them to
// explode :)
//-----------------------------------------------------------------------------
simulated function bool CanBusySwitchWeapon()
{
    // if the weapon is busy, don't allow a switch
	if (Weapon != None && !Weapon.WeaponCanBusySwitch())
		return false;

	return true;
}

// toss out a weapon
function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;

	if( Weapon == none )
		return;

	// Undeploy the weapon if they are deployed
 	if( bBipodDeployed )
	 	SetBipodDeployed(false);

	Weapon.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
}

//-----------------------------------------------------------------------------
// TossMGAmmo(RO) - toss out MG ammo all players carry
//-----------------------------------------------------------------------------
function TossMGAmmo( Pawn Gunner)
{
	local bool bResupplySuccessful;

	if( bUsedCarriedMGAmmo )
		return;

	if( ROWeapon(Gunner.Weapon) != none && ROWeapon(Gunner.Weapon).ResupplyAmmo())
	{
		bResupplySuccessful=true;
	}

	bUsedCarriedMGAmmo = bResupplySuccessful;
	if( bResupplySuccessful )
	{
		if( (ROTeamGame(Level.Game) != none) && (Controller != none)
			&& (Gunner.Controller != none) )
		{
		    // Send notification message to gunner & remove resupply request
		    if (ROPlayer(Gunner.Controller) != none)
		    {
		        ROPlayer(Gunner.Controller).ReceiveLocalizedMessage(
                    class'ROResupplyMessage', 1, Controller.PlayerReplicationInfo);
                if (ROGameReplicationInfo(ROTeamGame(Level.Game).GameReplicationInfo) != none)
                    ROGameReplicationInfo(ROTeamGame(Level.Game).GameReplicationInfo)
                        .RemoveMGResupplyRequestFor(Gunner.Controller.PlayerReplicationInfo);
            }

            // Send notification message to supplier
            if (PlayerController(Controller) != none)
            {
                PlayerController(Controller).ReceiveLocalizedMessage(
                    class'ROResupplyMessage', 0, Gunner.Controller.PlayerReplicationInfo);
		    }

		    // Score point
			ROTeamGame(Level.Game).ScoreMGResupply(Controller, Gunner.Controller);
		}

    	//PlayOwnedSound(sound'Inf_Weapons_Foley.ammogive', SLOT_Interact, 1.75,, 10);
	}
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
simulated function PrevWeapon()
{
    if ( Level.Pauser != None )
        return;

 	if( !bRecievedInitialLoadout )
 	{
 		return;
 	}

    if ( Weapon == None && Controller != None )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != None )
    {
        if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.PrevWeapon(None, PendingWeapon);
    }
    else
        PendingWeapon = Inventory.PrevWeapon(None, Weapon);

    if ( (PendingWeapon != none) && (PendingWeapon != Weapon) )
        Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
simulated function NextWeapon()
{
    if ( Level.Pauser != None )
        return;

 	if( !bRecievedInitialLoadout )
 	{
 		return;
 	}

    if ( Weapon == None && Controller != None )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != None )
    {
		if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.NextWeapon(None, PendingWeapon);
    }
    else
    {
	    PendingWeapon = Inventory.NextWeapon(None, Weapon);
    }

    if ( (PendingWeapon != none) && (PendingWeapon != Weapon) )
        Weapon.PutDown();
}

// The player wants to switch to weapon group number F. Overriden to fix "no weapon" issues when switching weapons right after spawning
simulated function SwitchWeapon(byte F)
{
    local weapon newWeapon;

 	if( !bRecievedInitialLoadout )
 	{
 		return;
 	}

    if ( (Level.Pauser!=None) || (Inventory == None) )
        return;
    if ( (Weapon != None) && (Weapon.Inventory != None) )
        newWeapon = Weapon.Inventory.WeaponChange(F, false);
    else
        newWeapon = None;
    if ( newWeapon == None )
        newWeapon = Inventory.WeaponChange(F, true);

    if ( newWeapon == None )
	{
		if ( F == 10 )
			ServerNoTranslocator();

		return;
	}

    if ( PendingWeapon != None && PendingWeapon.bForceSwitch )
        return;

    if ( Weapon == None )
    {
        PendingWeapon = newWeapon;
        ChangedWeapon();
    }
    else if ( Weapon != newWeapon || PendingWeapon != None )
    {
        PendingWeapon = newWeapon;
        Weapon.PutDown();
    }
    else if ( Weapon == newWeapon )
        Weapon.Reselect(); // sjs
}

//-----------------------------------------------------------------------------
// GetWeaponBoneFor - Determines proper bone for inventory
//-----------------------------------------------------------------------------
// MergeTODO: These are going to change. Also, rather than hard coding it maybe a variable would be better
function name GetWeaponBoneFor(Inventory I)
{
    if (I.IsA('ROGrenadeWeapon') || I.IsA('ROPistolWeapon') || I.IsA('ROSatchelChargeWeapon'))
		return 'weapon_rhand';//'righthand';
	else if (I.IsA('Weapon'))
		return 'weapon_rhand';//'FlagHand';
}

// Same as GetWeaponBoneFor, but statically and works on a class<Inventory> instead of instance
// Used by ROGUISelection to get weapon attachment bone
static function name StaticGetWeaponBoneFor(class<Inventory> I)
{
    // Not sure how to implement this, but seems righthand is what's always being used :)
    return 'weapon_rhand';
}

//-----------------------------------------------------------------------------
// StartFiring
//-----------------------------------------------------------------------------

simulated function StartFiring(bool bAltFire, bool bRapid)
{
	local name FireAnim;
	local bool bIsMoving;

	if (Physics == PHYS_Swimming || WeaponAttachment == None)
		return;

	bIsMoving = VSizeSquared(Velocity) > 25;

	if (bAltFire)
	{
		if (WeaponAttachment.bBayonetAttached)
		{
			if (bIsCrawling)
				FireAnim = WeaponAttachment.PA_ProneBayonetAltFire;
			else if (bIsCrouched)
				FireAnim = WeaponAttachment.PA_CrouchBayonetAltFire;
			else
				FireAnim = WeaponAttachment.PA_BayonetAltFire;
		}
		else
		{
			if (bIsCrawling)
				FireAnim = WeaponAttachment.PA_ProneAltFire;
			else if (bIsCrouched)
				FireAnim = WeaponAttachment.PA_CrouchAltFire;
			else if( bBipodDeployed )
				FireAnim = WeaponAttachment.PA_DeployedAltFire;
			else
				FireAnim = WeaponAttachment.PA_AltFire;
		}
	}
	// regular fire
	else
	{
		if( bBipodDeployed )
		{
			if (bIsCrouched)
			{
				FireAnim = WeaponAttachment.PA_CrouchDeployedFire;
			}
			else if ( bIsCrawling )
			{
			    FireAnim = WeaponAttachment.PA_ProneDeployedFire;
			}
			else
			{
				FireAnim = WeaponAttachment.PA_DeployedFire;
			}
		}
		else if (bIsCrawling)
			FireAnim = WeaponAttachment.PA_ProneFire;
		else if (bIsCrouched)
		{
			if( bIsMoving )
			{
				FireAnim = WeaponAttachment.PA_MoveCrouchFire[Get8WayDirection()];
			}
			else
			{
			 	if (bIronSights)
			 	{
				 	FireAnim = WeaponAttachment.PA_CrouchIronFire;
				}
				else
				{
				 	FireAnim = WeaponAttachment.PA_CrouchFire;
				}
			}
		}
		else if (bIronSights)
		{
			if( bIsMoving )
			{
				FireAnim = WeaponAttachment.PA_MoveStandIronFire[Get8WayDirection()];
			}
			else
			{
			 	FireAnim = WeaponAttachment.PA_IronFire;
			}
		}
		else
		{
			if( bIsMoving )
			{
				if(bIsWalking)
				{
					FireAnim = WeaponAttachment.PA_MoveWalkFire[Get8WayDirection()];
				}
				else
				{
				 	FireAnim = WeaponAttachment.PA_MoveStandFire[Get8WayDirection()];
				}
			}
			else
			{
			 	FireAnim = WeaponAttachment.PA_Fire;
			}
		}
	}

	// blend the fire animation a bit so the standard player movement animations still play
	AnimBlendParams(1, 0.25, 0.0, 0.2, FireRootBone);

	if (bRapid)
	{
		if (WeaponState != GS_FireLooped)
		{
			LoopAnim(FireAnim,, 0.0, 1);
			WeaponState = GS_FireLooped;

			if (!bAltFire)
			{
				if (WeaponAttachment.bBayonetAttached)
					WeaponAttachment.LoopAnim(WeaponAttachment.WA_BayonetFire);
				else
					WeaponAttachment.LoopAnim(WeaponAttachment.WA_Fire);
			}
		}
	}
	else
	{
		PlayAnim(FireAnim,, 0.0, 1);
		WeaponState = GS_FireSingle;

		if (!bAltFire)
		{
			if (WeaponAttachment.bBayonetAttached)
				WeaponAttachment.PlayAnim(WeaponAttachment.WA_BayonetFire);
			else
				WeaponAttachment.PlayAnim(WeaponAttachment.WA_Fire);
		}
	}

	IdleTime = Level.TimeSeconds;
}

//-----------------------------------------------------------------------------
// StopFiring
//-----------------------------------------------------------------------------

simulated function StopFiring()
{
	if (WeaponState == GS_FireLooped)
	{
		WeaponState = GS_FireSingle;
	}

	IdleTime = Level.TimeSeconds;
}

// Called on the server. Sends a message to the client to let them know to play a the reload
function HandleStandardReload()
{
	local name PlayerAnim;
	local bool bEmpty;

	// Set the anim blend time so the server will make this player relevant for third person reload sounds to be heard
	if( Level.NetMode != NM_StandAlone )
	{
		if (WeaponAttachment != None)
		{
	     	bEmpty = WeaponAttachment.bOutOfAmmo;

			if (bEmpty)
			{
				if (bIsCrawling)
					PlayerAnim = WeaponAttachment.PA_ProneReloadEmptyAnim;
				else
					PlayerAnim = WeaponAttachment.PA_ReloadEmptyAnim;
			}
			else
			{
				if (bIsCrawling)
					PlayerAnim = WeaponAttachment.PA_ProneReloadAnim;
				else
					PlayerAnim = WeaponAttachment.PA_ReloadAnim;
			}

			AnimBlendTime = GetAnimDuration(PlayerAnim, 1.0)+0.1;
		}
	}

	SetAnimAction('DoStandardReload');
}

// Called on the server. Sends a message to the client to let them know to start a looping reload
function StartReload()
{
	SetAnimAction('DoLoopingReload');
}

// Called on the server. Sends a message to the client to let them know to play a the reload
function StopReload()
{
	SetAnimAction('DoReloadEnd');
}

// Play a standard reload on the client
simulated function PlayStandardReload()
{
	local name PlayerAnim;
	local name WeaponAnim;
	local bool bEmpty;

	if (WeaponAttachment != None)
	{
     	bEmpty = WeaponAttachment.bOutOfAmmo;

		if (bEmpty)
		{
			if (bIsCrawling)
				PlayerAnim = WeaponAttachment.PA_ProneReloadEmptyAnim;
			else
				PlayerAnim = WeaponAttachment.PA_ReloadEmptyAnim;
		}
		else
		{
			if (bIsCrawling)
				PlayerAnim = WeaponAttachment.PA_ProneReloadAnim;
			else
				PlayerAnim = WeaponAttachment.PA_ReloadAnim;
		}



		if (WeaponAttachment.bBayonetAttached)
		{
			if( bIsCrawling )
			{
				if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_BayonetProneReloadEmpty != '')
					WeaponAnim = WeaponAttachment.WA_BayonetProneReloadEmpty;
				else if (WeaponAttachment.WA_BayonetProneReload != '')
					WeaponAnim = WeaponAttachment.WA_BayonetProneReload;
			}
			else
			{
				if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_BayonetReloadEmpty != '')
					WeaponAnim = WeaponAttachment.WA_BayonetReloadEmpty;
				else if (WeaponAttachment.WA_BayonetReload != '')
					WeaponAnim = WeaponAttachment.WA_BayonetReload;
			}
		}
		else
		{
			if( bIsCrawling )
			{
				if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_ProneReloadEmpty != '')
					WeaponAnim = WeaponAttachment.WA_ProneReloadEmpty;
				else if (WeaponAttachment.WA_ProneReload != '')
					WeaponAnim = WeaponAttachment.WA_ProneReload;
			}
			else
			{
				if (WeaponAttachment.bOutOfAmmo && WeaponAttachment.WA_ReloadEmpty != '')
					WeaponAnim = WeaponAttachment.WA_ReloadEmpty;
				else
					WeaponAnim = WeaponAttachment.WA_Reload;
			}
		}

        if( bIsCrawling )
		{
	        AnimBlendParams(1,1.0 , 0.0, 0.2, FireRootBone);
        }
        else
        {
			AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
	        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);
        }
		PlayAnim(PlayerAnim,, 0.1, 1);
		WeaponAttachment.PlayAnim(WeaponAnim,, 0.1);

		AnimBlendTime = GetAnimDuration(PlayerAnim, 1.0)+0.1;

		WeaponState = GS_ReloadSingle;
	}
}


//-----------------------------------------------------------------------------
// StartReloading - Play reloading anims
//-----------------------------------------------------------------------------

simulated function PlayStartReloading()
{
	if (WeaponAttachment != None)
	{
		// Play the pre-reload anim and then return if looping
        AnimBlendParams(1,1.0 , 0.0, 0.2, SpineBone1);
        AnimBlendParams(1,1.0, 0.0, 0.2, SpineBone2);

		if (bIsCrawling)
			PlayAnim(WeaponAttachment.PA_PronePreReloadAnim,, 0.1, 1);
		else
			PlayAnim(WeaponAttachment.PA_PreReloadAnim,, 0.1, 1);

		if (WeaponAttachment.bBayonetAttached && WeaponAttachment.WA_BayonetPreReload != '')
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_BayonetPreReload,, 0.1);
		else if (WeaponAttachment.WA_PreReload != '')
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_PreReload,, 0.1);

		WeaponState = GS_PreReload;
	}
}

//-----------------------------------------------------------------------------
// StopReloading - Stop reloading anims if looping
//-----------------------------------------------------------------------------

simulated function PlayStopReloading()
{
	if ((WeaponState == GS_ReloadLooped || WeaponState == GS_PreReload) && WeaponAttachment != None)
	{
		AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

		if (bIsCrawling)
			PlayAnim(WeaponAttachment.PA_PronePostReloadAnim,, 0.1, 1);
		else
			PlayAnim(WeaponAttachment.PA_PostReloadAnim,, 0.1, 1);

		if (WeaponAttachment.bBayonetAttached && WeaponAttachment.WA_BayonetPostReload != '')
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_BayonetPostReload,, 0.1);
		else if (WeaponAttachment.WA_PostReload != '')
			WeaponAttachment.PlayAnim(WeaponAttachment.WA_PostReload,, 0.1);

		WeaponState = GS_ReloadSingle;
	}

	IdleTime = Level.TimeSeconds;
}

//=============================================================
// Movement
//=============================================================

//-----------------------------------------------------------------------------
// StartSprint
//-----------------------------------------------------------------------------

function StartSprint()
{
	if (ROWeapon(Weapon) != None)
		ROWeapon(Weapon).SetSprinting(true);
}

//-----------------------------------------------------------------------------
// EndSprint
//-----------------------------------------------------------------------------

function EndSprint()
{
	if (ROWeapon(Weapon) != None)
		ROWeapon(Weapon).SetSprinting(false);
}

//-----------------------------------------------------------------------------
// BaseChange - Took out pawn damage, and added momentum from vehicle
//-----------------------------------------------------------------------------
singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;

	// If someone jumps off a moving vehicle, give them the vehicles momentum
	if ( base == none && Vehicle(SavedBase) != none && (VSize(Vehicle(SavedBase).Velocity) > 25))
	{
		Velocity += Vehicle(SavedBase).Velocity;
		Velocity.Z += 5;
	}
	SavedBase = base;

	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise jump off.
     else if ( Pawn(Base) != None )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns && ROPawn(Base) == none || ROPawn(Base) != none && VSize(Base.Velocity) > 1)
		{
			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}

// Don't telefrag players when they are near someone going to/from prone or crouch
event EncroachedBy(Actor Other)
{
	// Allow encroachment by Vehicles so they can push the pawn out of the way
	if ( ROPawn(Other) == None && Pawn(Other) != None && Vehicle(Other) == None)
		gibbedBy(Other);
}

// LimitYaw - limits player's yaw or turning amount
function LimitYaw(out int yaw)
{
	local	int MaxBipodYaw;
	local	int MinBipodYaw;

	if( bBipodDeployed )
	{
    	MaxBipodYaw = InitialDeployedRotation.Yaw + DeployedPositiveYawLimit;
    	MinBipodYaw = InitialDeployedRotation.Yaw + DeployedNegativeYawLimit;

    	if( yaw > MaxBipodYaw )
    	{
    		yaw = MaxBipodYaw;
    		return;
    	}
    	else if( yaw < MinBipodYaw )
    	{
    		yaw = MinBipodYaw;
    		return;
    	}
	}
}

 /*
 	 PitchUpLimit=18000
	 PitchDownLimit=49153
 */
function int LimitPitch(int pitch, optional float DeltaTime)
{
	local	int MaxBipodPitch;
	local	int MinBipodPitch;

    pitch = pitch & 65535;

	if( bBipodDeployed )
	{

    	MaxBipodPitch = InitialDeployedRotation.Pitch + DeployedPitchUpLimit;
		MinBipodPitch = InitialDeployedRotation.Pitch + DeployedPitchDownLimit;

		if( MaxBipodPitch > 65535 )
			MaxBipodPitch -= 65535;

		if( MinBipodPitch < 0 )
			MinBipodPitch += 65535;

		if( (MaxBipodPitch > PitchUpLimit) && (MaxBipodPitch < PitchDownLimit) )
			MaxBipodPitch = PitchUpLimit;

		if( (MinBipodPitch < PitchDownLimit) && (MinBipodPitch > PitchUpLimit) )
			MinBipodPitch = PitchDownLimit;

		// handles areas where newPitchUpLimit is less than newPitchDownLimit
    	if( (pitch > MaxBipodPitch) && (pitch < MinBipodPitch) )
    	{
        	if( (pitch - MaxBipodPitch) < (MinBipodPitch - pitch) )
            	pitch = MaxBipodPitch;
        	else
            	pitch = MinBipodPitch;
    	}
    	// following 2 if's handle when newPitchUpLimit is greater than newPitchDownLimit
    	else if( (pitch > MaxBipodPitch) && (MaxBipodPitch > MinBipodPitch) )
    	{
			pitch = MaxBipodPitch;
    	}
    	else if( (pitch < MinBipodPitch) && (MaxBipodPitch > MinBipodPitch) )
    	{
    		pitch = MinBipodPitch;
    	}
	}
	else
	{
		if( bIsCrawling )
		{
			// Smoothly rotate the player to the pitch limit when you start crawling.
			// This prevents the jarring "pop" when the pitch limit kicks in to
			// prevent you from looking through your arms
			if( Weapon != none && Weapon.IsCrawling() )
			{
				if (pitch > CrawlingPitchUpLimit && pitch < CrawlingPitchDownLimit)
		    	{
		        	if (pitch - CrawlingPitchUpLimit < CrawlingPitchDownLimit - pitch)
		        	{
						if( Level.TimeSeconds - Weapon.LastStartCrawlingTime < 0.15 )
						{
							pitch -= CrawlPitchTweenRate * deltatime;
						}
						else
						{
							pitch = CrawlingPitchUpLimit;
						}
		            }
		        	else
		        	{
						if( Level.TimeSeconds - Weapon.LastStartCrawlingTime < 0.15 )
						{
							pitch += CrawlPitchTweenRate * deltatime;
						}
						else
						{
							pitch = CrawlingPitchDownLimit;
						}
		            }
		    	}
			}
			else
			{
				if (pitch > PronePitchUpLimit && pitch < PronePitchDownLimit)
		    	{
		        	if (pitch - PronePitchUpLimit < PronePitchDownLimit - pitch)
		            	pitch = PronePitchUpLimit;
		        	else
		            	pitch = PronePitchDownLimit;
		    	}
	    	}
		}
        else if (pitch > PitchUpLimit && pitch < PitchDownLimit)
    	{
        	if (pitch - PitchUpLimit < PitchDownLimit - pitch)
            	pitch = PitchUpLimit;
        	else
            	pitch = PitchDownLimit;
    	}
    }

    return pitch;
}

simulated function vector EyePosition()
{
	local vector res, x, y, z;
	local float Lean;
	local actor HitActor;
	local vector HitLocation, HitNormal, TraceStart, TraceEnd;

	GetAxes(Rotation, x, y, z);

	if (IsInState('StartProning') || IsInState('EndProning'))
	{
		TraceStart = Location + ((GetBoneCoords(CameraBone).Origin - Location) * vect(0,0,1));
		TraceEnd = GetBoneCoords(CameraBone).Origin;
		HitActor = Trace( HitLocation, HitNormal, TraceEnd, TraceStart, true, vect(10,10,10));

		if( HitActor != none )
		{
			res = (HitLocation - Location) + WalkBob;
		}
		else
		{
        	res = (GetBoneCoords(CameraBone).Origin - Location) + WalkBob;
        }
	}
	else if ( bIsCrawling && !IsInState('DivingToProne'))
		res = EyeHeight * vect(0,0,1) + WalkBob + ((( Location + ProneEyeDist * Normal(x) ) - Location) * vect(1,1,0)) ;
    else
		res = EyeHeight * vect(0,0,1) + WalkBob;

   	if( LeanAmount != 0 )
   	{
   	 	Lean = Abs(LeanAmount / LeanMax);

   		if( bIsCrawling )
   		{
   			if( LeanAmount < 0 )
   				res += Lean * (X * LeanLProneViewOffset.X + Y * LeanLProneViewOffset.Y +  Z * LeanLProneViewOffset.Z);
   			else
   				res += Lean * (X * LeanRProneViewOffset.X + Y * LeanRProneViewOffset.Y +  Z * LeanRProneViewOffset.Z);
   		}
   		else if( bIsCrouched )
   		{
   			if( LeanAmount < 0 )
   				res += Lean * (X * LeanLCrouchViewOffset.X + Y * LeanLCrouchViewOffset.Y +  Z * LeanLCrouchViewOffset.Z);
   			else
   				res += Lean * (X * LeanRCrouchViewOffset.X + Y * LeanRCrouchViewOffset.Y +  Z * LeanRCrouchViewOffset.Z);
   		}
   		else
   		{
   			if( LeanAmount < 0 )
   				res += Lean * (X * LeanLViewOffset.X + Y * LeanLViewOffset.Y +  Z * LeanLViewOffset.Z);
   			else
   				res += Lean * (X * LeanRViewOffset.X + Y * LeanRViewOffset.Y +  Z * LeanRViewOffset.Z);
   		}
   	}

	return res;
}

//-----------------------------------------------------------------------------
// Landed - Added land sound and prevented anim for prone landing
//-----------------------------------------------------------------------------
event Landed(vector HitNormal)
{
	ImpactVelocity = vect(0,0,0);
	TakeFallingDamage();
	if ( Health > 0 && !bIsCrawling)
		PlayLanded(Velocity.Z);
	if ( (Velocity.Z < -200) && (PlayerController(Controller) != None) )
		bJustLanded = PlayerController(Controller).bLandingShake;
	LastHitBy = None;

	if (Health > 0)
	{
		if( bIsCrawling )
		    PlayOwnedSound(GetSound(EST_DiveLand), SLOT_Interact, FMin(2,Abs(Velocity.Z)/MaxFallSpeed),, 10);
        else
            PlayOwnedSound(GetSound(EST_Land), SLOT_Interact, FMin(1,-0.3 * Velocity.Z/JumpZ),, 10);
	}
}

//-----------------------------------------------------------------------------
// TakeFallingDamage - Increased damage once over safe fall threshold
//-----------------------------------------------------------------------------
// MergeTODO: Players complain that the fall distance is too short before getting hurt. Investigate
function TakeFallingDamage()
{
	local float Shake, EffectiveSpeed;

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		if ( Role == ROLE_Authority )
		{
		    MakeNoise(1.0);
		    if (Velocity.Z < -1 * MaxFallSpeed)
		    {
				EffectiveSpeed = Velocity.Z;
				if ( TouchingWaterVolume() )
					EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
				if ( EffectiveSpeed < -1 * MaxFallSpeed )
				{
					TakeDamage(-100 * (1.5 * EffectiveSpeed + MaxFallSpeed)/MaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
					// Damaged the legs
					UpdateDamageList(254);

				}
		    }
		}
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
            Controller.DamageShake(Shake);
		}
	}
	else if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
}

//-----------------------------------------------------------------------------
// FootStepping - overriden to support custom footstep volumes
//-----------------------------------------------------------------------------
simulated function FootStepping(int Side)
{
    local int SurfaceTypeID, i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End,HitLocation,HitNormal;
	local float FootVolumeMod;

    SurfaceTypeID = 0;
    FootVolumeMod = 1.0;

    for ( i=0; i<Touching.Length; i++ )
		if ( ((PhysicsVolume(Touching[i]) != None) && PhysicsVolume(Touching[i]).bWaterVolume)
			|| (FluidSurfaceInfo(Touching[i]) != None) )
		{
			//PlaySound(sound'Inf_Player.FootStepWaterDeep', SLOT_Interact, FootstepVolume * 2,, FootStepSoundRadius);

			// Play a water ring effect as you walk through the water
 			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.NetMode != NM_DedicatedServer)
				&& !Touching[i].TraceThisActor(HitLocation, HitNormal,Location - CollisionHeight*vect(0,0,1.1), Location) )
			{
					Spawn(class'WaterRingEmitter',,,HitLocation,rot(16384,0,0));
			}

			return;
		}

	// Lets still play the sounds when walking slow, just play them quieter
	if ( bIsCrawling )
	{
		return;
	}
	else if ( bIsCrouched || bIsWalking )
	{
        FootVolumeMod = QuietFootStepVolume;
	}

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceTypeID = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,16);
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if (FloorMat !=None)
			SurfaceTypeID = FloorMat.SurfaceType;
	}
	//PlaySound(SoundFootsteps[SurfaceTypeID], SLOT_Interact, (FootstepVolume * FootVolumeMod),,(FootStepSoundRadius * FootVolumeMod));
}

// Returns true if you can jump in this movement state
simulated function bool CanJump()
{
	if( Weapon != none && Weapon.IsMounted() )
		return false;

	if ( bIsLimping || bIsCrouched || bWantsToCrouch || bIsCrawling || bWantsToProne )
		return false;

	return true;
}

//-----------------------------------------------------------------------------
// DoJump - overriden to support a wait time between jumps
//-----------------------------------------------------------------------------
function bool DoJump( bool bUpdating )
{
	// No jumping if stamina is too low
	if ((Stamina < JumpStaminaDrain) || (Level.TimeSeconds < NextJumpTime) )
	{
		if(CanJump() && !bUpdating)
		{
			PlayOwnedSound(GetSound(EST_TiredJump), SLOT_Pain, GruntVolume,,80);
		}
		return false;
	}

	if ( CanJump() && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)))
	{
		// Take stamina away with each jump
		Stamina = FMax(Stamina - JumpStaminaDrain, 0.0);

		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.GameDifficulty > 2) )
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}

		// For playing jumping anims, etc
		if( Weapon != none )
		{
			Weapon.NotifyOwnerJumped();
		}

		if (!bUpdating)
			PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);

		NextJumpTime = Level.TimeSeconds + 2.0;

		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);

		return true;
	}

	return false;
}

//-----------------------------------------------------------------------------
// Proning functions
//-----------------------------------------------------------------------------

// Returns true if the player can switch the prone state. Only valid on the client
simulated function bool CanProneTransition()
{
	if( Physics == PHYS_Walking && (Weapon == none || Weapon.WeaponAllowProneChange()) )
	{
		return true;
	}

	return false;
}

// Returns true if the player can switch the crouch state.
simulated function bool CanCrouchTransition()
{
	if( IsTransitioningToProne() )
	{
		return false;
	}

	if( Weapon == none || Weapon.WeaponAllowCrouchChange() )
	{
		return true;
	}

	return false;
}

// Stub events called when physics actually allows prone to begin or end
// use these for changing the animation (if script controlled)
event EndProne(float HeightAdjust)
{
	// Take the weapon out of iron sights
	// TODO: Give this its own notify, instead of piggybacking the notify owner jumped one
	if( Weapon != none )
	{
		Weapon.NotifyOwnerJumped();
	}

  	SetAnimAction('EndCrawling');

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	EyeHeight -= HeightAdjust;
	OldZ += HeightAdjust;
	BaseEyeHeight = Default.BaseEyeHeight;
}

event StartProne(float HeightAdjust)
{
	SetWalking(false);
	ShouldCrouch(false);

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).ResetSwayValues();
	}

	// Take the weapon out of iron sights
	// TODO: Give this its own notify, instead of piggybacking the notify owner jumped one
	if( Weapon != none )
	{
		Weapon.NotifyOwnerJumped();
	}

  	SetAnimAction('StartCrawling');

	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = ProneEyeHeight;
}

event CrouchToProne(float HeightAdjust)
{
	SetWalking(false);
	ShouldCrouch(false);

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).ResetSwayValues();
	}

	// Take the weapon out of iron sights
	// TODO: Give this its own notify, instead of piggybacking the notify owner jumped one
	if( Weapon != none )
	{
		Weapon.NotifyOwnerJumped();
	}

	// Send the weapon to the crawling state if we are moving
	if( Weapon!= none && VSizeSquared(Velocity) > 1.0 )
	{
		Weapon.NotifyCrawlMoving();
	}

    SetAnimAction('CrouchToProne');

	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = ProneEyeHeight;
}

event ProneToCrouch(float HeightAdjust)
{
	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;

	ShouldProne(false);

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	// Take the weapon out of iron sights
	// TODO: Give this its own notify, instead of piggybacking the notify owner jumped one
	if( Weapon != none )
	{
		Weapon.NotifyOwnerJumped();
	}

    SetAnimAction('ProneToCrouch');

    if( VSizeSquared(Velocity) > 25 )
    {
    	BaseEyeHeight = CrouchMoveEyeHeightMod * CrouchHeight;
    }
    else
    {
    	BaseEyeHeight = CrouchEyeHeightMod * CrouchHeight;
    }
}

event StartProneDive(float HeightAdjust)
{
	SetWalking(false);
	ShouldCrouch(false);

  	SetAnimAction('DiveToProne');

	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = ProneEyeHeight;
}

// Player is prone
simulated state Crawling
{
	simulated function BeginState()
	{
		if( !bBipodDeployed && ROBipodWeapon(Weapon) != none && Weapon.bUsingSights )
		{
			Weapon.NotifyOwnerJumped();
		}

		SetSprinting(false);
	}

	simulated function EndState()
	{
		if ( Weapon != none )
			Weapon.NotifyStopCrawlMoving();
	}
}

simulated state ProningFromCrouch
{
	simulated function bool CanProneTransition(){return false;}
    simulated event bool IsTransitioningToProne(){return true;}
	simulated event bool IsProneTransitioning(){return true;}

    simulated function Timer()
	{
		GotoState('Crawling');
	}

	simulated function BeginState()
	{
		AnimBlendTimer();

		// Cancel any anims playing on the weapon since we do the same for the player
		if( WeaponAttachment != none )
			WeaponAttachment.PlayIdle();

		PlayProningFromCrouch();

		if( Weapon!= none && VSizeSquared(Velocity) > 1.0 )
		{
			Weapon.NotifyCrawlMoving();
		}

	}
}

simulated state CrouchingFromProne
{
	simulated event bool IsProneTransitioning(){return true;}

    simulated function Timer()
	{
		GotoState('');
	}

	simulated function BeginState()
	{
		AnimBlendTimer();

		// Cancel any anims playing on the weapon since we do the same for the player
		if( WeaponAttachment != none )
			WeaponAttachment.PlayIdle();

		PlayCrouchingFromProne();
	}
}

simulated state StartProning
{
	simulated function bool CanProneTransition(){return false;}
    simulated event bool IsTransitioningToProne(){return true;}
	simulated event bool IsProneTransitioning(){return true;}

    simulated function Timer()
	{
		GotoState('Crawling');
	}

	simulated function BeginState()
	{
		if( Weapon!= none && VSizeSquared(Velocity) > 1.0 )
			Weapon.NotifyCrawlMoving();

		AnimBlendTimer();

		// Cancel any anims playing on the weapon since we do the same for the player
		if( WeaponAttachment != none )
			WeaponAttachment.PlayIdle();

		PlayStartCrawling();
	}
}

simulated state EndProning
{
	simulated function bool CanProneTransition(){return false;}
	simulated event bool IsProneTransitioning(){return true;}

    simulated function Timer()
	{
		GotoState('');
	}

	simulated function BeginState()
	{
		AnimBlendTimer();

		// Cancel any anims playing on the weapon since we do the same for the player
		if( WeaponAttachment != none )
			WeaponAttachment.PlayIdle();

		PlayEndCrawling();
	}
}

// This is a little tricky. Animend isn't reliable enough to count on
// serverside to change the pre-pivot value so we use a timer. But
// The timer causes the anim to pop client side so we have to
// use animend client side to switch the pre-pivot value.
simulated state DivingToProne
{
	simulated function bool CanProneTransition(){return false;}
	simulated event bool IsTransitioningToProne(){return true;}

    simulated function Timer()
	{
		GotoState('Crawling');
	}

	simulated event AnimEnd(int Channel)
	{
		Global.AnimEnd(Channel);

		if( Level.NetMode != NM_DedicatedServer )
			GotoState('Crawling');
	}

	simulated function BeginState()
	{
		local name Anim;

		// Merge TODO, replace this with the animation length when we get an animation - Ramm
		if( Level.NetMode == NM_DedicatedServer )
			SetTimer(0.26,false);

		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_DiveToProneStartAnim;
		else
			Anim = DiveToProneStartAnim;

        AnimBlendTimer();

 		// Cancel any anims playing on the weapon since we do the same for the player
		if( WeaponAttachment != none )
			WeaponAttachment.PlayIdle();

		PlayAnim(Anim, 1.0, 0.25, 0);

		if( Weapon!= none )
			Weapon.NotifyCrawlMoving();
	}

	simulated function EndState()
	{
		local float NewHeight;
		local name Anim;

        NewHeight = default.CollisionHeight - ProneHeight;

		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_DiveToProneEndAnim;
		else
			Anim = DiveToProneEndAnim;

		PlayAnim(DiveToProneEndAnim, 0.0, 0.0, 0);
        PrePivot = default.PrePivot + (NewHeight * vect(0,0,1));
	}
}

//-----------------------------------------------------------------------------
// EndCrouch
//-----------------------------------------------------------------------------
event EndCrouch(float HeightAdjust)
{
	EyeHeight -= HeightAdjust;
	OldZ += HeightAdjust;
	BaseEyeHeight = Default.BaseEyeHeight;

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	PlayOwnedSound(CrouchToStandSound, SLOT_Interact, 1.0,, 10);
}

//-----------------------------------------------------------------------------
// StartCrouch - Changed crouch eye height
//-----------------------------------------------------------------------------
event StartCrouch(float HeightAdjust)
{
	EyeHeight += HeightAdjust;
	OldZ -= HeightAdjust;

	if( bBipodDeployed && ROBipodWeapon(Weapon) != none )
	{
		ROBipodWeapon(Weapon).ForceUndeploy();
	}

	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).ResetSwayValues();
	}

	ShouldProne(false);

    PlayOwnedSound(StandToCrouchSound, SLOT_Interact, 1.0,, 10);

    if( VSizeSquared(Velocity) > 25 )
    {
    	BaseEyeHeight = CrouchMoveEyeHeightMod * CrouchHeight;
    }
    else
    {
    	BaseEyeHeight = CrouchEyeHeightMod * CrouchHeight;
    }
}

// Crouch when trying to deploy
event DeployedStartCrouch()
{
	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).ResetSwayValues();
	}

	ShouldProne(false);

    PlayOwnedSound(StandToCrouchSound, SLOT_Interact, 1.0,, 10);
}

//=============================================================
// Death/Damage
//=============================================================

// Sometimes we need to damage only the highest damage hitpoint, this will return that hitpoint index
function int GetHighestDamageHitIndex( array<int> PointsHit )
{
	local int i, besthit, bestdamage;

	if( PointsHit.Length == 1 )
	{
		return 0;
	}

	for(i=0; i<PointsHit.Length; i++)
	{
		if( Hitpoints[PointsHit[i]].DamageMultiplier > bestdamage )
		{
			besthit = i;
			bestdamage = Hitpoints[PointsHit[i]].DamageMultiplier;
		}
	}

	return besthit;
}

// Process a precision hit
function ProcessLocationalDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, array<int> PointsHit)
{
	local int actualDamage, originalDamage, cumulativeDamage, totalDamage, i;
	local int HighestDamagePoint, HighestDamageAmount;
	// Hit detection debugging
    /*local coords CO;
	local vector HeadLoc;
	local bool bFirstHit;*/

    originalDamage = damage;

	// If someone else has killed this player , return
	if( bDeleteMe || PointsHit.Length < 1 || Health <= 0 )
		return;

	for(i=0; i<PointsHit.Length; i++)
	{
		// If someone else has killed this player , return
		if( bDeleteMe || Health <= 0 )
			return;

		actualDamage = originalDamage;

		actualDamage *= Hitpoints[PointsHit[i]].DamageMultiplier;
		totalDamage += actualDamage;
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
		cumulativeDamage += actualDamage;

		if( actualDamage > HighestDamageAmount )
		{
			HighestDamageAmount = actualDamage;
			HighestDamagePoint = PointsHit[i];
		}

		//log("We hit "$GetEnum(enum'EPawnHitPointType',Hitpoints[PointsHit[i]].HitPointType));

        // Hit detection debugging
		/*if( PointsHit[i] != 0 && !bFirstHit )
		{
	        CO = GetBoneCoords(Hitpoints[PointsHit[i]].PointBone);
			HeadLoc = CO.Origin;
			HeadLoc = HeadLoc + (Hitpoints[PointsHit[i]].PointOffset >> GetBoneRotation(Hitpoints[PointsHit[i]].PointBone));

			DrawLocation = HeadLoc;
			DrawRotation = GetBoneRotation(Hitpoints[PointsHit[i]].PointBone);
			DrawIndex = PointsHit[i];
			HitPointDebugByte++;
			bFirstHit = true;
		}*/

		if (Hitpoints[PointsHit[i]].HitPointType == PHP_Leg || Hitpoints[PointsHit[i]].HitPointType ==PHP_Foot)
		{
	        if (ActualDamage > 0 )
				SetLimping(FMin(ActualDamage / 5.0, 10.0));
		}
		else if (Hitpoints[PointsHit[i]].HitPointType == PHP_Hand)
		{
            if( (ROPlayer(Controller) != none) && (ROTeamGame(Level.Game).FriendlyFireScale > 0.0) && !InGodMode())
            {
	            ROPlayer(Controller).ThrowWeapon();
	            ROPlayer(Controller).ReceiveLocalizedMessage(class'ROWeaponLostMessage');
            }
		}

		// Update the locational damage list
		//UpdateDamageList(Hitpoints[PointsHit[i]].HitPointType);
		UpdateDamageList(PointsHit[i] - 1);

		// Lets exit out if one of the shots killed the player
		if ( cumulativeDamage >=  Health )
		{
			TakeDamage(totalDamage, instigatedBy, hitlocation, momentum, damageType, HighestDamagePoint);
		}
	}

	if( totalDamage > 0 )
	{
		// If someone else has killed this player , return
		if( bDeleteMe || Health <= 0 )
			return;

		TakeDamage(totalDamage, instigatedBy, hitlocation, momentum, damageType, HighestDamagePoint);
	}
}

// Update the list of damaged areas for the pawn
// 255 = All areas, 254 = Just the legs
function UpdateDamageList(byte NewDamagePoint)
{
	if( Role == ROLE_Authority )
	{
		if( NewDamagePoint == 254 )
		{
			DamageList[3] = 1;
			DamageList[4] = 1;
			DamageList[7] = 1;
			DamageList[8] = 1;
			DamageList[13] = 1;
			DamageList[14] = 1;

			ClientUpdateDamageList(NewDamagePoint);
		}
		else if( DamageList[NewDamagePoint] == 0 )
		{
			DamageList[NewDamagePoint] = 1;

			ClientUpdateDamageList(NewDamagePoint);
		}
	}
}

// Replicated from server to client to set the clients
// Damage areas
simulated function ClientUpdateDamageList(byte NewDamagePoint)
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();

	if( NewDamagePoint == 254 )
	{
		DamageList[3] = 1;
		DamageList[4] = 1;
		DamageList[7] = 1;
		DamageList[8] = 1;
		DamageList[13] = 1;
		DamageList[14] = 1;
	}
	else
	{
		DamageList[NewDamagePoint] = 1;
	}
}

// Hit detection debugging - Only use when debugging
/*
simulated function DrawBoneLocation()
{
    local vector X, Y, Z;

    GetAxes(DrawRotation, X,Y,Z);
    ClearStayingDebugLines();

	DrawStayingDebugLine(HitStart, HitEnd, 0,255,0);
	Spawn(class 'ROEngine.RODebugTracer',self,,HitStart,Rotator(Normal(HitEnd-HitStart)));

	DrawDebugCylinder(DrawLocation,Z,Y,X,Hitpoints[DrawIndex].PointRadius * Hitpoints[DrawIndex].PointScale,Hitpoints[DrawIndex].PointHeight * Hitpoints[DrawIndex].PointScale,10,0, 255, 0);
}

simulated function DrawDebugCylinder(vector Base,vector X, vector Y,vector Z, FLOAT Radius,float HalfHeight,int NumSides, byte R, byte G, byte B)
{
	local float AngleDelta;
	local vector LastVertex, Vertex;
	local int SideIndex;

	AngleDelta = 2.0f * PI / NumSides;
	LastVertex = Base + X * Radius;

	for(SideIndex = 0;SideIndex < NumSides;SideIndex++)
	{
		Vertex = Base + (X * Cos(AngleDelta * (SideIndex + 1)) + Y * Sin(AngleDelta * (SideIndex + 1))) * Radius;

        DrawStayingDebugLine( LastVertex - Z * HalfHeight,Vertex - Z * HalfHeight,R,G,B);
        DrawStayingDebugLine( LastVertex + Z * HalfHeight,Vertex + Z * HalfHeight,R,G,B);
        DrawStayingDebugLine( LastVertex - Z * HalfHeight,LastVertex + Z * HalfHeight,R,G,B);

		LastVertex = Vertex;
	}
}*/

//returns how exposed this player is to another actor
function float GetExposureTo(vector TestLocation)
{
	local int i;
	local float PercentExposed;

	for(i=0; i<Hitpoints.Length; i++)
	{
		if( i == 0 )
		{
			if( FastTrace(GetBoneCoords(Hitpoints[i].PointBone).Origin,TestLocation))
			{
				PercentExposed += 0.4;
			}
		}
		else if ( i == 1)
		{
			if( FastTrace(GetBoneCoords(Hitpoints[i].PointBone).Origin,TestLocation))
			{
				PercentExposed += 0.3;
			}
		}
		else if ( i == 13)
		{
			if( FastTrace(GetBoneCoords(Hitpoints[i].PointBone).Origin,TestLocation))
			{
				PercentExposed += 0.15;
			}
		}
		else if ( i == 14)
		{
			if( FastTrace(GetBoneCoords(Hitpoints[i].PointBone).Origin,TestLocation))
			{
				PercentExposed += 0.15;
			}
		}
	}

	return PercentExposed;
}


// Overriden so pawns don't go to the falling state every time they are shot
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces || (NewVelocity == vect(0,0,0)) )
		return;
	if ( (Physics == PHYS_Falling) && (AIController(Controller) != None) )
		ImpactVelocity += NewVelocity;
	if ( (Physics == PHYS_Walking && (NewVelocity.Z > (Default.JumpZ/2)))
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

//-----------------------------------------------------------------------------
// TakeDamage - Handle locational damage
//-----------------------------------------------------------------------------
// MergeTODO: This function needs some work
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local int actualDamage;
	local Controller Killer;

	if ( damagetype == None )
	{
		if ( InstigatedBy != None )
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType = class'DamageType';
	}

	if ( Role < ROLE_Authority )
	{
		//log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Health <= 0 )
		return;

	if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( (Physics == PHYS_None) && (DrivenVehicle == None) )
		SetMovementPhysics();
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	if (Weapon != None)
		Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

	if (DrivenVehicle != None)
        	DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

	ActualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	if (ActualDamage > 0 && (DamageType.Name == 'Fell'))
		SetLimping(FMin(ActualDamage / 5.0, 10.0));

	//ClientMessage("Hit area:" @ HitBone @ "Damage:" @ ActualDamage);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	LastHitIndex = HitIndex;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum, HitIndex);
	if ( Health <= 0 )
	{
		// pawn died
		if ( DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None )
			Killer = LastHitBy;
		else if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		if ( bPhysicsAnimUpdate )
			SetTearOffMomemtum(momentum);
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		AddVelocity( momentum );
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);

		if ( instigatedBy != None && instigatedBy != self )
			LastHitBy = instigatedBy.Controller;
	}
	MakeNoise(1.0);
}

/**
  * When player dies this method is called to find and drop
  * all other weapons in their inventory
  */
// MergeTODO: This function was probably crashing due to the bDeleteMe flag problem. Search unprog for the fix
function DropWeaponInventory(Vector TossVel)
{
	local Inventory Inv;
	local Weapon invWeapon;
	local Vector X,Y,Z;
	local int count, i;
	local array<class> DroppedClasses;
	local bool bAlreadyUsedClass;

	GetAxes(Rotation,X,Y,Z);

	count=0;
	Inv=Inventory;

	// consider doing a check on count to make sure it doesn't get too high
	// and force Unreal to crash with a run away loop
    while((Inv != none) && (count < 15))// 500
    {
        count++;
        if(Inv.IsA('Weapon'))
        {
            invWeapon = Weapon(Inv);

            if(invWeapon != none && invWeapon.bCanThrow)
            {
                for ( i=0;i<DroppedClasses.Length;i++ )
                {
                    //log("Dropped classes "$i$" = "$DroppedClasses[i]);
                    if( invWeapon.Class == DroppedClasses[i] )
                    {
                        bAlreadyUsedClass = true;
                        break;
                    }
                }

                if( !bAlreadyUsedClass )
                {
                    // because the weapon is destroyed from inventory need to start over again
                    // and search through the inventory from the beginning.
                    DroppedClasses[DroppedClasses.Length] = invWeapon.Class;
                    invWeapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
                    Inv = Inventory;
                }
                else
                {
                    //log("Trying to drop the same weapon: "$invWeapon.Class$" twice - possible lag bug cause");
                    Inv=Inv.Inventory;
                }
            }
            else
            {
                Inv=Inv.Inventory;
            }
        }
        else
        {
            Inv=Inv.Inventory;
        }

        bAlreadyUsedClass=false;
    }
}

// Clean up weapon inventory before level change since certain weapons
// (sniper scopes with 3d scopes) won't get properly garbage collected
// otherwise. This lead to the webadmin and memory leak issues - Ramm
simulated function PreTravelCleanUp()
{
	local Inventory Inv;
	local ROWeapon invWeapon;
	local int count;

	count=0;

	// consider doing a check on count to make sure it doesn't get too high
	// and force Unreal to crash with a run away loop
	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		invWeapon = ROWeapon(Inv);
		if ( invWeapon != None )
		{
			invWeapon.PreTravelCleanUp();
		}

		count++;

		if( count > 500 )
			break;
	}
}

//-----------------------------------------------------------------------------
// Died - A few minor additions
//-----------------------------------------------------------------------------

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Vector			TossVel;
	local Trigger			T;
	local NavigationPoint	N;
	local float	DamageBeyondZero;
	local vector HitDirection;

	if ( bDeleteMe || Level.bLevelChange || Level.Game == None )
		return; // already destroyed, or level is being cleaned up

	if ( DamageType.default.bCausedByWorld && (Killer == None || Killer == Controller) && LastHitBy != None )
		Killer = LastHitBy;

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}

	// Turn off the auxilary collision when the player dies
	if (  AuxCollisionCylinder != none )
	{
	    AuxCollisionCylinder.SetCollision(false,false,false);
	}

    DamageBeyondZero = Health;

	Health = Min(0, Health);

	// Fix for suicide death messages
    if (DamageType == class'Suicided')
	    DamageType = class'ROSuicided';

    if ( Weapon != None && (DrivenVehicle == None || DrivenVehicle.bAllowWeaponToss) )
    {
		if ( Controller != None )
			Controller.LastPawnWeapon = Weapon.Class;
        Weapon.HolderDied();
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Velocity Dot TossVel) + 50) + Vect(0,0,200);
        TossWeapon(TossVel);
    }

	DropWeaponInventory(TossVel);		// drops all weapons in inventory

	if ( DrivenVehicle != None )
	{
		Velocity = DrivenVehicle.Velocity;
		DrivenVehicle.DriverDied();
	}

	if ( Controller != None )
	{
		Controller.WasKilledBy(Killer);
		Level.Game.Killed(Killer, Controller, self, damageType);
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	DrivenVehicle = None;

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	// make sure to untrigger any triggers requiring player touch
	if ( IsPlayerPawn() || WasPlayerPawn() )
	{
		PhysicsVolume.PlayerPawnDiedInVolume(self);
		ForEach TouchingActors(class'Trigger',T)
			T.PlayerToucherDied(self);

		// event for HoldObjectives
		foreach TouchingActors(class'NavigationPoint', N)
			if ( N.bReceivePlayerToucherDiedNotify )
				N.PlayerToucherDied( Self );
	}

	// remove powerup effects, etc.
	RemovePowerups();

	Velocity.Z *= 1.3;
	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();
	if ( ROPlayer(Controller) != none
         && class<ROWeaponDamageType>(DamageType) != none
         && class<ROWeaponDamageType>(DamageType).default.bCauseViewJarring == true )
	{
        HitDirection = Location - HitLocation;
        HitDirection.Z = 0.0f;
        HitDirection = normal(HitDirection);

	    ROPlayer(Controller).PlayerJarred(HitDirection,3.0f);
	}
    if ( (DamageType != None) && DamageType.default.bAlwaysGibs && !class'GameInfo'.static.UseLowGore())
    {
        if ( Level.NetMode == NM_DedicatedServer )
           DoDamageFX('obliterate',1010,class'RODiedInTankDamType', Rotation);
        ChunkUp( Rotation, DamageType.default.GibPerterbation );
	}
	else if (DamageType != none && (Abs(DamageBeyondZero) + default.Health) > DamageType.default.HumanObliterationThreshhold &&
		!class'GameInfo'.static.UseLowGore())
	{
	    if ( Level.NetMode == NM_DedicatedServer )
	       DoDamageFX('obliterate',1010,class'RODiedInTankDamType', Rotation);
        ChunkUp( rotator(GetTearOffMomemtum()), DamageType.default.GibPerterbation );
	}
	else
	{
		NetUpdateFrequency = Default.NetUpdateFrequency;
		PlayDying(DamageType, HitLocation);
		if ( Level.Game.bGameEnded )
			return;
		if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
			ClientDying(DamageType, HitLocation);
	}
}

// Overridden to support some Xpawn functionality we wanted
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	WeaponState = GS_None;
	if( PlayerController(Controller) != none )
		PlayerController(Controller).bFreeCamera = false;

	AmbientSound = None;
    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    if ( DamageType != None )
    {
		if ( DamageType.Default.DeathOverlayMaterial != None && !class'GameInfo'.static.UseLowGore() )
			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
		else if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 2*DamageType.default.DamageOverlayTime, true);
	}

    // stop shooting
    AnimBlendParams(1, 0.0);
	LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

	PlayDyingAnimation(DamageType, HitLoc);
}

//-----------------------------------------------------------------------------
// KilledBy - Changed damage type - butto 9/14/03
//-----------------------------------------------------------------------------
function KilledBy( pawn EventInstigator )
{
	local Controller Killer;

	Health = 0;
	if ( EventInstigator != None )
		Killer = EventInstigator.Controller;
	Died( Killer, class'ROSuicided', Location );
}

// Killed yourself (like with a grenade that you let go off in your hand)
function KilledSelf( class<DamageType> damageType )
{
	local Controller Killer;

	Health = 0;

	Killer = Controller;
	Died( Killer, damageType, Location );
}

//-----------------------------------------------------------------------------
// DoDamageFX
//-----------------------------------------------------------------------------
// TODO: This is where are gib stuff will go
function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r )
{
	local float DismemberProbability;
    local int RandBone;
    local bool bDidSever;

    if (  FRand() > 0.3f || Damage > 30 || Health <= 0 )
    {
        HitFX[HitFxTicker].damtype = DamageType;

        if( Health <= 0 )
        {
            switch( boneName )
            {
                case 'lfoot':
                case 'lthigh':
                case 'lupperthigh':
                    boneName = 'lthigh';
                    break;

                case 'rfoot':
                case 'rthigh':
                case 'rupperthigh':
                    boneName = 'rthigh';
                    break;

                case 'lhand':
                case 'lfarm':
                case 'lupperarm':
                case 'lshoulder':
                    boneName = 'lfarm';
                    break;

                case 'rhand':
                case 'rfarm':
                case 'rupperarm':
                case 'rshoulder':
                    boneName = 'rfarm';
                    break;

                case 'None':
                    boneName = 'Spine';
                    break;
            }

//	        if( !DamageType.default.bLocationalHit && (boneName == 'None' || boneName == 'Upperspine' ||
//				boneName == 'Spine' ))
//	        {
//	        	RandBone = Rand(4);
//
//				switch( RandBone )
//	            {
//	                case 0:
//						boneName = 'lthigh';
//						break;
//	                case 1:
//						boneName = 'rthigh';
//						break;
//	                case 2:
//						boneName = 'lfarm';
//	                    break;
//	                case 3:
//						boneName = 'rfarm';
//	                    break;
//	                case 4:
//						boneName = 'head';
//	                    break;
//	                default:
//	                	boneName = 'lthigh';
//	            }
//	        }

			if( DamageType.default.bAlwaysSevers || (Damage == 1000) )
			{
                HitFX[HitFxTicker].bSever = true;
                bDidSever = true;
                if ( boneName == 'None' )
                {
					boneName = 'spine';
				}
			}
            else if( DamageType.Default.GibModifier > 0.0 )
            {
	            DismemberProbability = Abs( (Health - Damage*DamageType.Default.GibModifier) / 130.0f );
/*				switch( boneName )
                {
                    case 'lfoot':
                    case 'rfoot':
	                case 'lthigh':
                    case 'rthigh':
                    case 'lhand':
                    case 'rhand':
                    case 'rfarm':
                    case 'lfarm':
                    case 'head':
                        if( FRand() < DismemberProbability )
                            HitFX[HitFxTicker].bSever = true;
                        break;

                    case 'None':
 						boneName = 'spine';
                     case 'spine':
                        if( FRand() < DismemberProbability * 0.3 )
                        {
                            HitFX[HitFxTicker].bSever = true;
                            if ( FRand() < 0.65 )
								bExtraGib = true;
						}
                        break;
                }*/

                if( FRand() < DismemberProbability )
                {
                	HitFX[HitFxTicker].bSever = true;
                	bDidSever = true;
                }
            }
        }

        if ( class'GameInfo'.static.UseLowGore() )
        {
			HitFX[HitFxTicker].bSever = false;
			bDidSever = false;
		}


        if ( HitFX[HitFxTicker].bSever )
        {
	        if( !DamageType.default.bLocationalHit && (boneName == 'None' || boneName == 'Upperspine' ||
				boneName == 'Spine' ))
	        {
	        	RandBone = Rand(4);

				switch( RandBone )
	            {
	                case 0:
						boneName = 'lthigh';
						break;
	                case 1:
						boneName = 'rthigh';
						break;
	                case 2:
						boneName = 'lfarm';
	                    break;
	                case 3:
						boneName = 'rfarm';
	                    break;
	                case 4:
						boneName = 'head';
	                    break;
	                default:
	                	boneName = 'lthigh';
	            }
	        }
        }

		if( Health < 0 && Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 )
		{
			boneName = 'obliterate';
		}

       	HitFX[HitFxTicker].bone = boneName;
        HitFX[HitFxTicker].rotDir = r;
        HitFxTicker = HitFxTicker + 1;
        if( HitFxTicker > ArrayCount(HitFX)-1 )
            HitFxTicker = 0;

        // If this was a really hardcore damage from an explosion, randomly spawn some arms and legs
        if ( bDidSever && !DamageType.default.bLocationalHit && Damage > 200 && Damage != 1000 )
        {
			if ((Damage > 400 && FRand() < 0.3) || FRand() < 0.1 )
			{
				DoDamageFX('head',1000,DamageType,r);
				DoDamageFX('lthigh',1000,DamageType,r);
				DoDamageFX('rthigh',1000,DamageType,r);
				DoDamageFX('lfarm',1000,DamageType,r);
				DoDamageFX('rfarm',1000,DamageType,r);
			}
			if ( FRand() < 0.25 )
			{
				DoDamageFX('lthigh',1000,DamageType,r);
				DoDamageFX('rthigh',1000,DamageType,r);
				if ( FRand() < 0.5 )
				{
					DoDamageFX('lfarm',1000,DamageType,r);
				}
				else
				{
					DoDamageFX('rfarm',1000,DamageType,r);
				}
			}
			else if ( FRand() < 0.35 )
				DoDamageFX('lthigh',1000,DamageType,r);
			else if ( FRand() < 0.5 )
				DoDamageFX('rthigh',1000,DamageType,r);
			else if ( FRand() < 0.75 )
			{
				if ( FRand() < 0.5 )
				{
					DoDamageFX('lfarm',1000,DamageType,r);
				}
				else
				{
					DoDamageFX('rfarm',1000,DamageType,r);
				}
			}
		}
    }
}

//-----------------------------------------------------------------------------
// ProcessHitFX
//-----------------------------------------------------------------------------
 // MergeTODO: Replace this with realistic gibbing
simulated function ProcessHitFX()
{
    local Coords boneCoords;
    //local class<xEmitter> HitEffects[4];
    local int j;//i,j;
    local float GibPerterbation;

    if( (Level.NetMode == NM_DedicatedServer) )
    {
		SimHitFxTicker = HitFxTicker;
        return;
    }

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
		j++;
		if ( j > 30 )
		{
			SimHitFxTicker = HitFxTicker;
			return;
		}

        if( (HitFX[SimHitFxTicker].damtype == None) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )
            continue;

		//log("Processing effects for damtype "$HitFX[SimHitFxTicker].damtype);

		if( HitFX[SimHitFxTicker].bone == 'obliterate' && !class'GameInfo'.static.UseLowGore())
		{
			SpawnGibs( HitFX[SimHitFxTicker].rotDir, 0);
			bGibbed = true;
			Destroy();
			return;
		}

        boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

        if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood())
        {
			AttachEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

//			HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );
//
//			if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
//			{
//				for( i = 0; i < ArrayCount(HitEffects); i++ )
//				{
//					if( HitEffects[i] == none )
//						continue;
//
//					AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
//				}
//			}
		}
        if ( class'GameInfo'.static.UseLowGore() )
			HitFX[SimHitFxTicker].bSever = false;

        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'obliterate':
                    break;

				case 'lthigh':
                case 'lupperthigh':
                	if( !bLeftLegGibbed )
					{
	                    SpawnGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bLeftLegGibbed=true;
                    }
                    break;

                case 'rthigh':
                case 'rupperthigh':
                	if( !bRightLegGibbed )
					{
	                    SpawnGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bRightLegGibbed=true;
                    }
                    break;

                case 'lfarm':
                case 'lupperarm':
                	if( !bLeftArmGibbed )
					{
	                    SpawnGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bLeftArmGibbed=true;
                    }
                    break;

                case 'rfarm':
                case 'rupperarm':
                	if( !bRightArmGibbed )
					{
	                    SpawnGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bRightArmGibbed=true;
                    }
                    break;

                case 'head':
                  	HelmetShotOff(HitFX[SimHitFxTicker].rotDir);
                    break;

//                case 'spine':
//                case 'Upperspine':
//                case 'None':
//					  bGibbed = true;
//                    break;
            }
            //never hide the head
//            if(HitFX[SimHitFXTicker].bone == 'head')
//            {
//            	if( Headgear != none )
//            	{
//            		Headgear.Destroy();
//            	}
//            }

			if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != 'UpperSpine' )
            	HideBone(HitFX[SimHitFxTicker].bone);
        }

        if(HitFX[SimHitFXTicker].bone == 'head' && Health < 0)
        {
        	if( Headgear != none )
        	{
        		HelmetShotOff(HitFX[SimHitFxTicker].rotDir);
        	}
        }
    }
}

//-----------------------------------------------------------------------------
// HelmetShotOff
//-----------------------------------------------------------------------------
simulated function HelmetShotOff(Rotator Rotation)
{
/*    local DroppedHeadGear Hat;

    if( HeadGear == none )
    {
    	return;
    }

    Hat = Spawn( class'DroppedHeadGear',,, HeadGear.Location, HeadGear.Rotation );
    if( Hat == none )
        return;

    Hat.LinkMesh(HeadGear.Mesh);

    HeadGear.Destroy();

    Hat.Velocity = Velocity + vector(Rotation) * (Hat.MaxSpeed + (Hat.MaxSpeed/2) * FRand());
    Hat.LifeSpan = Hat.LifeSpan + 2 * FRand() - 1;*/
}



//-----------------------------------------------------------------------------
// StartDeRes
//-----------------------------------------------------------------------------
// MergeTODO: This Deres stuff is crap. Replace with something better
simulated function StartDeRes()
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

	MaxLights=0;

	// Turn off collision when we de-res (avoids rockets etc. hitting corpse!)
	SetCollision(true, false, false);

	// Remove/disallow projectors
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;

	// Remove shadow
	if(PlayerShadow != None)
		PlayerShadow.bShadowActive = false;

	// Turn off any overlays
	SetOverlayMaterial(None, 0.0f, true);

}

//-----------------------------------------------------------------------------
// Destroyed - Destroy any dummy attachments
//-----------------------------------------------------------------------------

simulated event Destroyed()
{
	local int i;

	if( Headgear != none )
	{
		Headgear.Destroy();
	}

	for (i = AmmoPouches.Length - 1; i >= 0; i--)
	{
		if( AmmoPouches[i] != none )
			AmmoPouches[i].Destroy();

		AmmoPouches.Length = AmmoPouches.Length - 1;
	}

	if (  AuxCollisionCylinder != none )
	{
	    AuxCollisionCylinder.Destroy();
	}

	// Delete any attached emitters
    for( i = 0; i < Attached.length; i++ )
    {
        if( Attached[i].IsA('Emitter') && Attached[i].bDeleteMe )
        {
        	Attached[i].Destroy();
        }
    }

	// TODO: lets throw out the weapon that was on the player's back
	if( AttachedBackItem != none )
	{
		AttachedBackItem.Destroy();
	}

	if( SeveredLeftArm != none )
	{
		SeveredLeftArm.Destroy();
	}

	if( SeveredRightArm != none )
	{
		SeveredRightArm.Destroy();
	}

	if( SeveredRightLeg != none )
	{
		SeveredRightLeg.Destroy();
	}

	if( SeveredLeftLeg != none )
	{
		SeveredLeftLeg.Destroy();
	}

	if( SeveredHead != none )
	{
		SeveredHead.Destroy();
	}

    if( PlayerShadow != none )
        PlayerShadow.Destroy();


	Super.Destroyed();
}

//-----------------------------------------------------------------------------
// TickFX
//-----------------------------------------------------------------------------

simulated function TickFX(float DeltaTime)
{
    if ( SimHitFxTicker != HitFxTicker )
    {
		ProcessHitFX();
    }
}

//-----------------------------------------------------------------------------
// Dying - Improvements to corpse handling
//-----------------------------------------------------------------------------

state Dying
{
	// from UnrealPawn
	function Landed(vector HitNormal)
	{
		//do nothing
/*		if ( Level.NetMode == NM_DedicatedServer )
			return;
		if ( Shadow != None )
			Shadow.Destroy();*/
	}

	// From Xpawn
	simulated function AnimEnd( int Channel )
	{
	    ReduceCylinder();
	}

    function LandThump()
    {
        // animation notify - play sound if actually landed, and animation also shows it
        if ( Physics == PHYS_None)
        {
            bThumped = true;
            //PlaySound(GetSound(EST_CorpseLanded));
        }
    }
    // end from Xpawn

	simulated function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
	{
		local Vector SelfToHit, SelfToInstigator, CrossPlaneNormal;
		local float W;
		local float YawDir;

		local Vector HitNormal, shotDir;
		local Vector PushLinVel, PushAngVel;
		local Name HitBone;
		local float HitBoneDist;
		local int MaxCorpseYawRate;

		if (DamageType == None)
			return;

		if(Physics == PHYS_KarmaRagdoll)
		{
			// Can't shoot corpses during de-res
			if(bDeRes)
				return;

			//log("HIT RAGDOLL. M:"$Momentum);
			// Throw the body if its a rocket explosion or shock combo
			if(damageType.Name == 'ROSMineDamType' || damageType.Name == 'ROStielGranateDamType' || damageType.Name == 'ROMineDamType' || damageType.Name == 'ROF1GrenadeDamType')
			{
				shotDir = Normal(Momentum);
				PushLinVel = (RagDeathVel * shotDir) +  vect(0, 0, 250);
				PushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * -18000;
				KSetSkelVel( PushLinVel, PushAngVel );
			}
			else if( damageType.Default.bRagdollBullet )
			{
				if ( Momentum == vect(0,0,0) )
					Momentum = HitLocation - InstigatedBy.Location;
				if ( FRand() < 0.65 )
				{
					if ( Velocity.Z <= 0 )
						PushLinVel = vect(0,0,40);
					PushAngVel = Normal(Normal(Momentum) Cross vect(0, 0, 1)) * -8000 ;
					PushAngVel.X *= 0.5;
					PushAngVel.Y *= 0.5;
					PushAngVel.Z *= 4;
					KSetSkelVel( PushLinVel, PushAngVel );
				}
                PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
				if ( (LifeSpan > 0) && (LifeSpan < DeResTime + 2) )
					LifeSpan += 0.2;
			}
			else
			{
				PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
			}
			if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
				SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
			return;
		}

		if (Damage > 0)
		{
			if ( InstigatedBy != None )
			{

				// Figure out which direction to spin:

				if( InstigatedBy.Location != Location )
				{
					SelfToInstigator = InstigatedBy.Location - Location;
					SelfToHit = HitLocation - Location;

					CrossPlaneNormal = Normal( SelfToInstigator cross Vect(0,0,1) );
					W = CrossPlaneNormal dot Location;

					if( HitLocation dot CrossPlaneNormal < W )
						YawDir = -1.0;
					else
						YawDir = 1.0;
				}
			}
			if( VSize(Momentum) < 10 )
			{
				Momentum = - Normal(SelfToInstigator) * Damage * 1000.0;
				Momentum.Z = Abs( Momentum.Z );
			}

			SetPhysics(PHYS_Falling);
			Momentum = Momentum / Mass;
			AddVelocity( Momentum );
			bBounce = true;

			RotationRate.Pitch = 0;
			RotationRate.Yaw += VSize(Momentum) * YawDir;

			MaxCorpseYawRate = 150000;
			RotationRate.Yaw = Clamp( RotationRate.Yaw, -MaxCorpseYawRate, MaxCorpseYawRate );
			RotationRate.Roll = 0;

			bFixedRotationDir = true;
			bRotateToDesired = false;

			Health -= Damage;
			CalcHitLoc( HitLocation, vect(0,0,0), HitBone, HitBoneDist );

			if( InstigatedBy != None )
				HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
			else
				HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

			DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
		}
	}

	function BeginState()
	{
		local int i;

		SetCollision(true,false,false);
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

        SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}

		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();

		AmbientSound = None;
 	}

	simulated function Timer()
	{
		local KarmaParamsSkel skelParams;

		//log("ROPawn dead viewtarget = "$PlayerController(OldController).ViewTarget);

		// Regular PlayerCanSeeMe() check is not good enough, since we don't render the body, but use the karma for first person death
		if ( !PlayerCanSeeMe() && (PlayerController(OldController) == None) || ((PlayerController(OldController) != None) && (PlayerController(OldController).ViewTarget != self)))
		{
			StartDeRes();
			Destroy();
		}
		// If we are running out of life, but we still haven't come to rest, force the de-res.
		// unless pawn is the viewtarget of a player who used to own it
		else if ( LifeSpan <= DeResTime && bDeRes == false )
		{
			skelParams = KarmaParamsSkel(KParams);

			// check not viewtarget
			if ( (PlayerController(OldController) != None) && (PlayerController(OldController).ViewTarget == self) )
			{
				skelParams.bKImportantRagdoll = true;
				LifeSpan = FMax(LifeSpan,DeResTime + 2.0);
				SetTimer(1.0, false);
				return;
			}
			else
			{
				skelParams.bKImportantRagdoll = false;
			}

			// spawn derez
			bDeRes=true;
		}
		else
		{
			SetTimer(1.0, false);
		}
	}
}

// Overriden to send the weapon to the idle state when entering a vehicle.
// Apparantly calling the super here isn't good enough. Get accessed nones if this
// isn't in ROPawn
simulated event StartDriving(Vehicle V)
{
	local int i;

	DrivenVehicle = V;
	NetUpdateTime = Level.TimeSeconds - 1;
	AmbientSound = None;
	StopWeaponFiring();
	DeactivateSpawnProtection();

	// Move the driver into position, and attach to car.
	ShouldCrouch(false);
	ShouldProne(false);
	bIgnoreForces = true;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	bCanTeleport = false;

	if ( !V.bRemoteControlled || V.bHideRemoteDriver )
    	{
		SetCollision( False, False, False);
		bCollideWorld = false;
		V.AttachDriver( Self );
		if ( V.bDrawDriverinTP )
			CullDistance = 5000;
		else
		   	bHidden = true;
    	}

	// set animation
	bPhysicsAnimUpdate = false;
	bWaitForAnim = false;
	if ( !V.bHideRemoteDriver && V.bDrawDriverinTP )
	{
		if ( HasAnim(DrivenVehicle.DriveAnim) )
			LoopAnim(DrivenVehicle.DriveAnim);
		else
			LoopAnim('Vehicle_Driving');
		SetAnimFrame(0.5);
		SmoothViewYaw = Rotation.Yaw;
		SetTwistLook(0,0);
	}

	if( PlayerShadow != none )
		PlayerShadow.bShadowActive = false;

	if ( WeaponAttachment != None )
		WeaponAttachment.Hide(true);

	//hack for sticky grenades
	for (i = 0; i < Attached.Length; i++)
		if (Projectile(Attached[i]) != None)
			Attached[i].SetBase(None);

    if( V.bKeepDriverAuxCollision )
    {
	   ToggleAuxCollision(true);
	}
	else
	{
       ToggleAuxCollision(false);
    }

	if( ROWeapon(Weapon)!=none)
	{
	   ROWeapon(Weapon).GotoState('Idle');
	}

    if( Weapon != none )
		Weapon.NotifyOwnerJumped();
}

// Overriden to turn the aux collision back on when you leave the vehicle
simulated function StopDriving(Vehicle V)
{
	Super.StopDriving(V);

	if( PlayerShadow != None )
		PlayerShadow.bShadowActive = true;

	if ( WeaponAttachment != None )
		WeaponAttachment.Hide(false);

	ToggleAuxCollision(true);

	// Clear any upper body animations. for when leaving a vehicle
	SetAnimAction('ClearAnims');
}

// Helper function for PostNetRecieve. Returns true if it finds a matching
// Primary weapon for this player and their role,and the weapon's instigator
// has finished replicating
simulated function bool VerifyPrimary(Inventory Inv)
{
	local int i;
	local bool bFoundMatch;
	local RORoleInfo RI;
	local int EmptyCount;

	if ( PlayerReplicationInfo != none && ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
				ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none )
	{
		RI = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;

		for (i = 0; i < ArrayCount(RI.PrimaryWeapons); i++)
		{
			if (RI.PrimaryWeapons[i].Item == None)
			{
				EmptyCount++;
				continue;
			}
	        else
	        {
	        	if( RI.PrimaryWeapons[i].Item == Inv.Class )
	        	{
	        		bFoundMatch = true;
					break;
	        	}
	        }
		}

		// There were no possible primary weapons
		if( EmptyCount == ArrayCount(RI.PrimaryWeapons) )
		{
			return true;
		}
	}

	return (bFoundMatch && (Inv.Instigator != none));
}

// Helper function for PostNetRecieve. Returns true if it finds a matching
// Secondary weapon for this player and their role,and the weapon's instigator
// has finished replicating
simulated function bool VerifySecondary(Inventory Inv)
{
	local int i;
	local bool bFoundMatch;
	local RORoleInfo RI;
	local int EmptyCount;

	if ( PlayerReplicationInfo != none && ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
				ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none )
	{
		RI = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;

			for (i = 0; i < ArrayCount(RI.SecondaryWeapons); i++)
			{
				if (RI.SecondaryWeapons[i].Item == None)
				{
					EmptyCount++;
					continue;
				}
		        else
		        {
		        	if( RI.SecondaryWeapons[i].Item == Inv.Class )
		        	{
		        		bFoundMatch = true;
						break;
		        	}
		        }
			}


		if( EmptyCount == ArrayCount(RI.SecondaryWeapons) )
		{
			return true;
		}
	}

	return (bFoundMatch && (Inv.Instigator != none));
}

// Helper function for PostNetRecieve. Returns true if it finds a matching
// Nade weapon for this player and their role,and the weapon's instigator
// has finished replicating
simulated function bool VerifyNades(Inventory Inv)
{
	local int i;
	local bool bFoundMatch;
	local RORoleInfo RI;
	local int EmptyCount;

	if ( PlayerReplicationInfo != none && ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
				ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none )
	{
		RI = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;

			for (i = 0; i < ArrayCount(RI.Grenades); i++)
			{
				if (RI.Grenades[i].Item == None)
				{
					EmptyCount++;
					continue;
				}
		        else
		        {
		        	if( RI.Grenades[i].Item == Inv.Class )
		        	{
		        		bFoundMatch = true;
						break;
		        	}
		        }
			}


		if( EmptyCount == ArrayCount(RI.Grenades) )
		{
			return true;
		}
	}

	return (bFoundMatch && (Inv.Instigator != none));
}

// Helper function for PostNetRecieve. Returns true if it finds a matching
// Given items for this player and their role,and the weapon's instigator
// has finished replicating
simulated function bool VerifyGivenItems()
{
	local inventory Inv;
	local int i, j, ItemCount;
	local RORoleInfo RI;
	local class<Inventory> InventoryClass;

 	if ( PlayerReplicationInfo != none && ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
				ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none )
	{
		RI = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;

		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if ( (Weapon(Inv) != None) )
			{
				for (j = 0; j < RI.GivenItems.Length; j++)
				{
                		InventoryClass = class<Inventory>(DynamicLoadObject(RI.GivenItems[j], class'Class'));

			        	if( InventoryClass == Inv.Class && Inv.Instigator != none)
			        	{
			        		ItemCount++;
							break;
			        	}

				}
			}
			i++;
			if ( i > 500 )
				break;
		}

		if( ItemCount == RI.GivenItems.Length )
		{
			return true;
		}
	}

	return false;
}

//-----------------------------------------------------------------------------
// PostNetReceive - Change player animations appropriately
//-----------------------------------------------------------------------------
// MergeTODO: look into setting bNetNotify to false here like Xpawn does
simulated function PostNetReceive()
{
	local int i;
	local inventory Inv;
	local int j;
	local bool bVerifiedPrimary, bVerifiedSecondary, bVerifiedNades, bVerifiedGivenItems;

    if( !bRecievedInitialLoadout )
    {
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if ( (Weapon(Inv) != None) )
			{
				if( VerifyPrimary(Inv) )
				{
					bVerifiedPrimary = true;
				}

				if( VerifySecondary(Inv) )
				{
					bVerifiedSecondary = true;
				}

				if( VerifyNades(Inv) )
				{
					bVerifiedNades = true;
				}
			}
			j++;
			if ( j > 500 )
				break;
		}

		if( VerifyGivenItems() )
		{
			bVerifiedGivenItems = true;
		}

		if( bVerifiedPrimary && bVerifiedSecondary && bVerifiedNades && bVerifiedGivenItems )
		{
			bRecievedInitialLoadout = true;
			Controller.SwitchToBestWeapon();
			//log("*********** Got Initial Loadout!!!****************");
		}
	}

	// Hit detection debugging
/*	if(	HitPointDebugByte != OldHitPointDebugByte)
	{
  		DrawBoneLocation();
  		OldHitPointDebugByte = HitPointDebugByte;
	}*/

    if (!bInitializedPlayer)
	{
		if ( ForceDefaultCharacter() )
		{
			Setup(class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter()));
			bInitializedPlayer = true;
		}
		else if ( PlayerReplicationInfo != none && ROPlayerReplicationInfo(PlayerReplicationInfo) != none &&
			ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo != none &&
			ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo.static.GetModel() == PlayerReplicationInfo.CharacterName)
		{
			Setup(class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName));
			bInitializedPlayer = true;
		}
		else if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
		{
			Setup(class'xUtil'.static.FindPlayerRecord(DrivenVehicle.PlayerReplicationInfo.CharacterName));
			bInitializedPlayer = true;
		}
	}

	if( !bInitializedWeaponAttachment && WeaponAttachment == none)
	{
		// Try and find weapon attachement
	    for( i = 0; i < Attached.length; i++ )
	    {
	        if( Attached[i].IsA('ROWeaponAttachment') )
	        {
	        	SetWeaponAttachment(ROWeaponAttachment(Attached[i]));
	        	bInitializedWeaponAttachment = true;
	        	break;
	        }
	    }
	}

	if( bInitializedPlayer && bInitializedWeaponAttachment && bRecievedInitialLoadout)
		bNetNotify = false;
}

// MergeTODO: commented out turning off the bNetNotify stuff. However, it should probably be turned
// back on when we refactor PostNetRecieve.
simulated function NotifyTeamChanged()
{
	// my PRI now has a new team
	if ( ForceDefaultCharacter() )
	{
		Setup(class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter()));
        bNetNotify = false;
	}
	else if ( PlayerReplicationInfo != None )
    {
		Setup(class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName));
        bNetNotify = false;
    }
    else if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
    {
		Setup(class'xUtil'.static.FindPlayerRecord(DrivenVehicle.PlayerReplicationInfo.CharacterName));
        bNetNotify = false;
    }
}

// Can we sprint in this state?
simulated function bool AllowSprint()
{
	if (!bIsCrawling &&((Weapon == None || Weapon.WeaponAllowSprint()) && Acceleration != vect(0,0,0)))
	{
		return true;
	}

	return false;
}

// Force a stamina update on the client
simulated function ClientForceStaminaUpdate(float NewStamina)
{
	Stamina = NewStamina;
}

// Handles the stamina calculations and sprinting functionality
function HandleStamina(float DeltaTime)
{
	local byte NewBreathSound;

	// Prone
	if( bIsCrawling )
	{
		if (Stamina < default.Stamina && Acceleration == vect(0,0,0))
		{
			Stamina = FMin(default.Stamina, Stamina + (DeltaTime * ProneStaminaRecoveryRate));
		}
		else
		{
		    Stamina = FMin(default.Stamina, Stamina + (DeltaTime * SlowStaminaRecoveryRate));
		}
	}
	else
	{
		// Walking
		if (bIsSprinting)
		{
			// Use more stamina when crouch sprinting
			if ( bIsCrouched )
			{
				Stamina = FMax(0.0, Stamina - (DeltaTime * 1.25));
			}
			else
			{
			   	Stamina = FMax(0.0, Stamina - DeltaTime);
			}
		}
		else
		{
			if (Stamina < default.Stamina && !bIsWalking && !bIsCrouched && VSizeSquared(Velocity) > 0.0 )
			{
				Stamina = FMin(default.Stamina, Stamina + (DeltaTime * SlowStaminaRecoveryRate));
			}
			else
			{
				if ( bIsCrouched )
				{
					Stamina = FMin(default.Stamina, Stamina + (DeltaTime * CrouchStaminaRecoveryRate));
				}
				else
				{
                 	Stamina = FMin(default.Stamina, Stamina + (DeltaTime * StaminaRecoveryRate));
				}
			}
		}
	}

	// Only set this flag on the server
	if ( Level.NetMode != NM_Client )
	{
		bCanStartSprint = Stamina > 2.0;
	}

	if( Stamina == 0.0 || Acceleration == vect(0,0,0) )
	{
		SetSprinting(false);
	}

    // Stamina sound handling. Sets the ambient breathing sound based on stamina level
	if ( Level.NetMode != NM_Client )
	{
		if (Health > 0 && Stamina < 10.0)
		{
		    if ( Stamina <= 2.0 )
			{
		    	NewBreathSound = 1;
			}
			else if (Stamina < 5.0 )
			{
				NewBreathSound = 2;
			}
			else if ( Stamina < 7.5 )
			{
		        NewBreathSound = 3;
			}
			else
			{
		        NewBreathSound = 4;
			}

		}
		else
		{
		    NewBreathSound = 5;
		}

		if( SavedBreathSound != NewBreathSound )
			SetBreathingSound(NewBreathSound);
	}
}

//-----------------------------------------------------------------------------
// Turned this tick back on to do stamina based breathing calculations -Ramm
// 08/15/04
//-----------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	if( Role > ROLE_SimulatedProxy )
		HandleStamina(DeltaTime);
	// Handle limping

	if( Role == ROLE_Authority )
	{
	    if( bIsLimping )
	    {
	    	if ( LimpTime <= 0 )
	    	{
	    		bIsLimping =  false;
				GroundSpeed=Default.GroundSpeed;
	    	}
	    	else
	    	{
	    	   	LimpTime -= DeltaTime;

				if (LimpTime>0)
				{
					GroundSpeed=Default.GroundSpeed - LimpTime * 20;
					if (GroundSpeed < 0)
						GroundSpeed = 0;
				}
	    	}
	    }
    }

	if( Level.Netmode != NM_DedicatedServer )
	{
		if ( Controller != None )
			OldController = Controller;

		// do footsteps for nonlocal pawns and bots
		if( !IsLocallyControlled() || (Level.Netmode == NM_Standalone && !IsHumanControlled()))
		{
			CheckFootSteps(DeltaTime);
		}

	    TickFX(DeltaTime);
	}
	TickLean(DeltaTime);
}

/*==========================================
* UnrealPawn functions
*=========================================*/

function gibbedBy(actor Other)
{
	if ( Role < ROLE_Authority )
		return;
	if ( Pawn(Other) != None )
	{
		if ( (Pawn(Other).Weapon != None) && Pawn(Other).Weapon.IsA('Translauncher') )
			Died(Pawn(Other).Controller, Pawn(Other).Weapon.GetDamageType(), Location);
		else
			Died(Pawn(Other).Controller, class'DamTypeTelefragged', Location);
	}
	else
		Died(None, class'Gibbed', Location);
}

function HoldFlag(Actor FlagActor)
{
	if ( GameObject(FlagActor) != None )
		HoldGameObject(GameObject(FlagActor),GameObject(FlagActor).GameObjBone);
}

function HoldGameObject(GameObject gameObj, name GameObjBone)
{
	if ( GameObjBone == 'None' )
	{
		GameObj.SetPhysics(PHYS_Rotating);
		GameObj.SetLocation(Location);
		GameObj.SetBase(self);
		GameObj.SetRelativeLocation(vect(0,0,0));
	}
	else
	{
		AttachToBone(gameObj,GameObjBone);
		gameObj.SetRelativeRotation(GameObjRot + gameObj.GameObjRot);
		gameObj.SetRelativeLocation(GameObjOffset + gameObj.GameObjOffset );
	}
}

function EndJump();	// Called when stop jumping

simulated function ShouldUnCrouch();

function String GetDebugName()
{
	if ( (Bot(Controller) != None) && Bot(Controller).bSoaking && (Level.Pauser != None) )
		return GetHumanReadableName()@Bot(Controller).SoakString;
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return GetItemName(string(self));
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	//MergeTODO: Write proper RO specific functionality for this
	return true;
/*	local int i;
	local string invstring;

	if ( bAcceptAllInventory )
		return true;

	invstring = string(InventoryClass);

	for ( i=0; i<16; i++ )
	{
		if ( RequiredEquipment[i] ~= invstring )
			return true;
		else if ( RequiredEquipment[i] == "" )
			break;
	}

	for ( i=0; i<16; i++ )
	{
		if ( OptionalEquipment[i] ~= invstring )
			return true;
		else if ( OptionalEquipment[i] == "" )
			break;
	}
	return false; */
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			if ( Inv != None )
				Inv.PickupFunction(self);
		}
	}
}

function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking);
}

function TakeDrowningDamage()
{
	TakeDamage(5, None, Location + CollisionHeight * vect(0,0,0.5)+ 0.7 * CollisionRadius * vector(Controller.Rotation), vect(0,0,0), class'Drowned');
}

function int GetSpree()
{
	return spree;
}

function IncrementSpree()
{
	spree++;
}

simulated function PlayFootStep(int Side)
{
	if ( (Role==ROLE_SimulatedProxy) || (PlayerController(Controller) == None) || PlayerController(Controller).bBehindView )
	{
		FootStepping(Side);
		return;
	}
}

//-----------------------------------------------------------------------------

/*
Pawn was killed - detach any controller, and die
*/
simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation )
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}

	bTearOff = true;
	HitDamageType = class'Gibbed'; // make sure clients gib also
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		GotoState('TimingOut');
	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.static.UseLowGore() )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,ChunkPerterbation);

	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

/* TimingOut - where gibbed pawns go to die (delay so they can get replicated)
*/
state TimingOut
{
ignores BaseChange, Landed, AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional int HitIndex)
	{
	}

	function BeginState()
	{
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		LifeSpan = 1.0;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
	}
}


/*==========================================
* Xpawn functions
*=========================================*/
simulated function PlayWaiting() {}

function RosterEntry GetPlacedRoster()
{
	PlayerReplicationInfo.CharacterName = PlacedCharacterName;
	return class'RORosterEntry'.static.CreateRosterEntryCharacter(PlacedCharacterName);
}

// return true if was controlled by a Player (AI or human)
simulated function bool WasPlayerPawn()
{
	return ( (OldController != None) && OldController.bIsPlayer );
}

// Set up default blending parameters and pose. Ensures the mesh doesn't have only a T-pose whenever it first springs into view.
simulated function AssignInitialPose()
{
    if ( DrivenVehicle != None )
    {
		if ( HasAnim(DrivenVehicle.DriveAnim) )
			LoopAnim(DrivenVehicle.DriveAnim,, 0.1);
		else
			LoopAnim('Vehicle_Driving',, 0.1);
	}
	else
		TweenAnim(MovementAnims[0],0.0);
	AnimBlendParams(1, 1.0, 0.2, 0.2, 'Bip01_Spine1');
    BoneRefresh();
}

function DeactivateSpawnProtection()
{
	if ( bSpawnDone )
		return;
	bSpawnDone = true;
	if ( Level.TimeSeconds - SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime )
	{
		SpawnTime = Level.TimeSeconds - DeathMatch(Level.Game).SpawnProtectionTime - 1;
	}
}

function PlayMoverHitSound()
{
	//PlaySound(SoundGroupClass.static.GetHitSound(), SLOT_Interact);
}

function Gasp()
{
    if ( Role != ROLE_Authority )
        return;
    //if ( BreathTime < 2 )
        //PlaySound(GetSound(EST_Gasp), SLOT_Interact);
    //else
        //PlaySound(GetSound(EST_BreatheAgain), SLOT_Interact);
}

function Controller GetKillerController()
{
	if ( Controller != None )
		return Controller;
	if ( OldController != None )
		return OldController;
	return None;
}

simulated function int GetTeamNum()
{
	if ( Controller != None )
		return Controller.GetTeamNum();
	if ( (DrivenVehicle != None) && (DrivenVehicle.Controller != None) )
		return DrivenVehicle.Controller.GetTeamNum();
	if ( OldController != None )
		return OldController.GetTeamNum();
	if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) )
		return 255;
	return PlayerReplicationInfo.Team.TeamIndex;
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	if ( (DrivenVehicle != None) && (DrivenVehicle.PlayerReplicationInfo != None) )
		return DrivenVehicle.PlayerReplicationInfo.Team;
	if ( (OldController != None) && (OldController.PlayerReplicationInfo != None) )
		return OldController.PlayerReplicationInfo.Team;
	return None;
}

simulated function AttachEffect( class<Emitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
{
    local Actor a;
    local int i;

    if( BoneName == 'None' )
        return;

    for( i = 0; i < Attached.Length; i++ )
    {
        if( Attached[i] == None )
            continue;

        if( Attached[i].AttachmentBone != BoneName )
            continue;

        if( ClassIsChildOf( EmitterClass, Attached[i].Class ) )
            return;
    }

    a = Spawn( EmitterClass,,, Location, Rotation );

    if( !AttachToBone( a, BoneName ) )
    {
        log( "Couldn't attach "$EmitterClass$" to "$BoneName, 'Error' );
        a.Destroy();
        return;
    }

    for( i = 0; i < Attached.length; i++ )
    {
        if( Attached[i] == a )
            break;
    }

    a.SetRelativeRotation( Rotation );
}

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
	SetBoneScale(4,HeadScale,'head');
}

simulated function SpawnGiblet( class<SeveredAppendage> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local SeveredAppendage Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );
    if( Giblet == None )
        return;
	Giblet.SpawnTrail();

    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (Giblet.MaxSpeed + (Giblet.MaxSpeed/2) * FRand());
    Giblet.LifeSpan = self.RagdollLifeSpan;
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;

    if( boneName == 'lthigh' )
    {
		boneScaleSlot = 0;
		if( SeveredLeftLeg == none )
		{
			SeveredLeftLeg = Spawn(SeveredLegAttachClass,self);
			AttachToBone(SeveredLeftLeg, 'lupperthigh');
		}
	}
	else if ( boneName == 'rthigh' )
	{
		boneScaleSlot = 1;
		if( SeveredRightLeg == none )
		{
			SeveredRightLeg = Spawn(SeveredLegAttachClass,self);
			AttachToBone(SeveredRightLeg, 'rupperthigh');
		}
	}
	else if( boneName == 'rfarm' )
	{
		boneScaleSlot = 2;
		if( SeveredRightArm == none )
		{
			SeveredRightArm = Spawn(SeveredArmAttachClass,self);
			AttachToBone(SeveredRightArm, 'rupperarm');
		}
	}
	else if ( boneName == 'lfarm' )
	{
		boneScaleSlot = 3;
		if( SeveredLeftArm == none )
		{
			SeveredLeftArm = Spawn(SeveredArmAttachClass,self);
			AttachToBone(SeveredLeftArm, 'lupperarm');
		}
	}
	else if ( boneName == 'head' )
	{
		boneScaleSlot = 4;
		if( SeveredHead == none )
		{
			SeveredHead = Spawn(SeveredHeadAttachClass,self);
			AttachToBone(SeveredHead, 'Bip01_Neck');
		}
	}
	else if ( boneName == 'spine' )
		boneScaleSlot = 5;

    SetBoneScale(BoneScaleSlot, 0.0, BoneName);
}

// MergeTODO: This needs to be replaced with our more precise system
function CalcHitLoc( Vector hitLoc, Vector hitRay, out Name boneName, out float dist )
{
    boneName = GetClosestBone( hitLoc, hitRay, dist );
}

simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
	if ( Level.bDropDetail || Level.DetailMode == DM_Low )
		time *= 0.75;
	Super.SetOverlayMaterial(mat,time,bOverride);
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    if (Weapon != None)
        return Weapon.CheckReflect( HitLocation, RefNormal, Damage );
    else
        return false;
}

function name GetOffhandBoneFor(Inventory I)
{
     return 'bip01 l hand';
}

// ----- animation ----- //

simulated function name GetAnimSequence()
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
    return anim;
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
    SetAnimAction('stand_draw_kar');
}

// Need to override to support weapons on the back
function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
	local PlayerController PC;

    PC = PlayerController(Controller);

 	// New weapon switching code

	// For offline or when your running a listen server and your not watching yourself in third person
	// Just switch the attachment, don't worry about playing all the third person player stuff.
	// That was borking up the first person weapon switches
	if( PC != none && !PC.bBehindView && IsLocallyControlled() && Level.Netmode != NM_DedicatedServer )
	{
	    Weapon = NewWeapon;

	    if ( Controller != None )
			Controller.ChangedWeapon();

	    PendingWeapon = None;

		if ( OldWeapon != None )
		{
			if( OldWeapon.bCanAttachOnBack )
			{
				if( AttachedBackItem != none )
				{
					AttachedBackItem.Destroy();
					AttachedBackItem = None;
				}

		        AttachedBackItem = Spawn(class 'BackAttachment',self);
		        AttachedBackItem.InitFor(OldWeapon);
		        AttachToBone(AttachedBackItem,AttachedBackItem.AttachmentBone);
	        }

			OldWeapon.SetDefaultDisplayProperties();
			OldWeapon.DetachFromPawn(self);
	        OldWeapon.GotoState('Hidden');
	        OldWeapon.NetUpdateFrequency = 2;
		}

		if ( Weapon != None )
		{
			if( AttachedBackItem != none && AttachedBackItem.InventoryClass == Weapon.Class)
			{
				AttachedBackItem.Destroy();
				AttachedBackItem = None;
			}

		    Weapon.NetUpdateFrequency = 100;
			Weapon.AttachToPawn(self);
			Weapon.BringUp(OldWeapon);
	        PlayWeaponSwitch(NewWeapon);
		}

		if ( Inventory != None )
			Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
	}
	else
	{
		if( OldWeapon != none )
		{
			// If we are already in state PutWeaponAway, exit that state and then switch
			// to this new weapon
			if( IsInState('PutWeaponAway') )
			{
				GotoState('');

				PendingWeapon = NewWeapon;

				GotoState('PutWeaponAway');
			}
			else
			{
				PendingWeapon = NewWeapon;
			    GotoState('PutWeaponAway');
		    }
	    }
	// end new stuff
	    else
	    {
		    Weapon = NewWeapon;

		    if ( Controller != None )
				Controller.ChangedWeapon();

		    PendingWeapon = None;

			if ( OldWeapon != None )
			{
				OldWeapon.SetDefaultDisplayProperties();
				OldWeapon.DetachFromPawn(self);
		        OldWeapon.GotoState('Hidden');
		        OldWeapon.NetUpdateFrequency = 2;
			}

			if ( Weapon != None )
			{
				if( AttachedBackItem != none && AttachedBackItem.InventoryClass == Weapon.Class)
				{
					AttachedBackItem.Destroy();
					AttachedBackItem = None;
				}

			    Weapon.NetUpdateFrequency = 100;
				Weapon.AttachToPawn(self);
				Weapon.BringUp(OldWeapon);
		        PlayWeaponSwitch(NewWeapon);
			}

			if ( Inventory != None )
				Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
		}
	}
}

// Not sure if we need this, its the same as the super, but keep here until the weapon switching code is final
// Just changed to pendingWeapon
simulated function ChangedWeapon()
{
    local Weapon OldWeapon;

    ServerChangedWeapon(Weapon, PendingWeapon);
    if (Role < ROLE_Authority)
	{
       	// When switching weapons, don't let the client attempt to fire until the switch is complete
        if( Weapon != none )
		{
			bPreventWeaponFire = true;
        }

        OldWeapon = Weapon;
        Weapon = PendingWeapon;
		PendingWeapon = None;
		if ( Controller != None )
			Controller.ChangedWeapon();

        if (Weapon != None)
		    Weapon.BringUp(OldWeapon);
    }
}

// Handles creating the back attachment if the weapon should go on the back
// as well as playing the proper draw/put away anims for the weapons that are being switched
state PutWeaponAway
{
    simulated function Timer()
	{
		GotoState('');
	}

	simulated function BeginState()
	{
		local name Anim;

		bPreventWeaponFire = true;

		// Put the weapon down on the server as well as the client
		if( Level.NetMode == NM_DedicatedServer && Weapon != none)
		{
			Weapon.PutDown();
		}

		// select the proper animation to play based on what the player is holding
		// Weapon could be none because it might have been destroyed before getting here (nades, faust, etc)
    	if( Weapon != none )
    	{
	 		if( Weapon.IsA('ROExplosiveWeapon') || Weapon.IsA('BinocularsItem') )
			{
	    		if( bIsCrawling )
	    		{
	    			Anim = 'prone_putaway_nade';
	    		}
	    		else
	    		{
	    			Anim = 'stand_putaway_nade';
	    		}
			}
			else if( (Weapon.IsA('ROBoltActionWeapon') || Weapon.IsA('ROAutoWeapon') ||
				Weapon.IsA('ROSemiAutoWeapon')))
			{
	    		if( bIsCrawling )
	    		{
	    			Anim = 'prone_putaway_kar';
	    		}
	    		else
	    		{
	    			Anim = 'stand_putaway_kar';
	    		}
			}
			else if( Weapon.IsA('ROPistolWeapon'))
			{
	    		if( bIsCrawling )
	    		{
	    			Anim = 'prone_putaway_pistol';
	    		}
	    		else
	    		{
	    			Anim = 'stand_putaway_pistol';
	    		}
			}
			else
			{
				// Default in case there is no anim
	    		if( bIsCrawling )
	    		{
	    			Anim = 'prone_putaway_kar';
	    		}
	    		else
	    		{
	    			Anim = 'stand_putaway_kar';
	    		}
			}
    	}
    	else
    	{
			// TODO: Need a put away empty anim
    		if( bIsCrawling )
    		{
    			Anim = 'prone_putaway_kar';
    		}
    		else
    		{
    			Anim = 'stand_putaway_kar';
    		}
    	}

        // Handle the inventory side of swapping the weapon, not the visual side
		SwapWeapon = Weapon;

    	if ( Weapon != None )
    	{
            Weapon.GotoState('Hidden');
            Weapon.NetUpdateFrequency = 2;
    	}

		Weapon = PendingWeapon;

	    if ( Controller != None )
			Controller.ChangedWeapon();

		PendingWeapon = None;

		if ( Weapon != None )
		{
		    Weapon.NetUpdateFrequency = 100;
		    Weapon.AttachToPawnHidden(self);
			Weapon.BringUp(SwapWeapon);
		}

        if( !Weapon.IsA('ROExplosiveWeapon') )
        {
			bPreventWeaponFire = false;
		}

		if ( Inventory != none )
			Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)

		SetTimer(GetAnimDuration(Anim, 1.0) + 0.1,false);

        SetAnimAction(Anim);
	}

	simulated function EndState()
	{
		local name Anim;

    	if ( SwapWeapon != None )
    	{

    		if( SwapWeapon.bCanAttachOnBack )
    		{
    			if( AttachedBackItem != none )
    			{
    				AttachedBackItem.Destroy();
    				AttachedBackItem = None;
    			}

    	        AttachedBackItem = Spawn(class 'BackAttachment',self);
    	        AttachedBackItem.InitFor(SwapWeapon);
    	        AttachToBone(AttachedBackItem,AttachedBackItem.AttachmentBone);
            }

			SwapWeapon.SetDefaultDisplayProperties();
    		SwapWeapon.DetachFromPawn(self);
    	}

        // select the proper animation to play based on what the player is holding and
        // what weapon they are switching to

    	// From grenade or binocs to rifle
    	if( SwapWeapon == none )
    	{
    		// TODO: Need a put away empty anim
    		if( bIsCrawling )
    		{
    			Anim = 'prone_draw_kar';
    		}
    		else
    		{
    			Anim = 'stand_draw_kar';
    		}
    	}
    	else if( Weapon == none )
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_nadeFromRifle';
    		}
    		else
    		{
    			Anim = 'stand_nadefromrifle';
    		}
    	}
    	else if( ( SwapWeapon.IsA('ROExplosiveWeapon') || SwapWeapon.IsA('BinocularsItem') )&&
    		(Weapon.IsA('ROBoltActionWeapon') || Weapon.IsA('ROAutoWeapon') ||
    		 Weapon.IsA('ROSemiAutoWeapon')) )
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_rifleFromNade';
    		}
    		else
    		{
    			Anim = 'stand_riflefromnade';
    		}
    	}
    	// from rifle to grenade or binocs
    	else if( (SwapWeapon.IsA('ROBoltActionWeapon') || SwapWeapon.IsA('ROAutoWeapon') ||
    		SwapWeapon.IsA('ROSemiAutoWeapon')) && (Weapon.IsA('ROExplosiveWeapon') ||
    		Weapon.IsA('BinocularsItem')))
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_nadeFromRifle';
    		}
    		else
    		{
    			Anim = 'stand_nadefromrifle';
    		}
    	}
    	// from pistol to rifle
    	else if( SwapWeapon.IsA('ROPistolWeapon') && (Weapon.IsA('ROBoltActionWeapon') ||
    		Weapon.IsA('ROAutoWeapon') || Weapon.IsA('ROSemiAutoWeapon')))
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_riflefrompistol';
    		}
    		else
    		{
    			Anim = 'stand_riflefrompistol';
    		}
    	}
    	// from rifle to pistol
    	else if( (SwapWeapon.IsA('ROBoltActionWeapon') || SwapWeapon.IsA('ROAutoWeapon') ||
    		SwapWeapon.IsA('ROSemiAutoWeapon')) && Weapon.IsA('ROPistolWeapon'))
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_pistolfromrifle';
    		}
    		else
    		{
    			Anim = 'stand_pistolfromrifle';
    		}
    	}
    	// from pistol to grenade or binocs
    	else if( SwapWeapon.IsA('ROPistolWeapon') && (Weapon.IsA('ROExplosiveWeapon') ||
    		Weapon.IsA('BinocularsItem')))
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_nadefrompistol';
    		}
    		else
    		{
    			Anim = 'stand_nadefrompistol';
    		}
    	}
    	// from grenade or binocs to pistol
    	else if( ( SwapWeapon.IsA('ROExplosiveWeapon') || SwapWeapon.IsA('BinocularsItem')) &&
    		Weapon.IsA('ROPistolWeapon') )
    	{
    		if( bIsCrawling )
    		{
    			Anim = 'prone_pistolfromnade';
    		}
    		else
    		{
    			Anim = 'stand_pistolfromnade';
    		}
    	}
    	// from grenade or binocs, to grenade or binocs
    	else if( ( SwapWeapon.IsA('ROExplosiveWeapon') || SwapWeapon.IsA('BinocularsItem')) &&
    		(Weapon.IsA('ROExplosiveWeapon') || Weapon.IsA('BinocularsItem') ) )
    	{
    		// TODO: Need a real anim here
    		if( bIsCrawling )
    		{
    			Anim = 'prone_draw_nade';
    		}
    		else
    		{
    			Anim = 'stand_draw_nade';
    		}
    	}
    	else
    	{
    		// Default in case there is no anim
    		if( bIsCrawling )
    		{
    			Anim = 'prone_draw_kar';
    		}
    		else
    		{
    			Anim = 'stand_draw_kar';
    		}
    	}

    	SetAnimAction(Anim);

		if ( Weapon != None )
		{
			if( AttachedBackItem != none && AttachedBackItem.InventoryClass == Weapon.Class)
			{
				AttachedBackItem.Destroy();
				AttachedBackItem = None;
			}

			//Weapon.AttachToPawn(self);
			// unhide the weapon now
			if( Weapon.ThirdPersonActor != none )
				Weapon.ThirdPersonActor.bHidden = false;
			else
				Weapon.AttachToPawn(self);
		}

        SwapWeapon = none;

        bPreventWeaponFire = false;
	}
}

simulated final function RandSpin(float spinRate)
{
    DesiredRotation = RotRand(true);
    RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
    RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
    RotationRate.Roll = spinRate * 2 *FRand() - spinRate;

    bFixedRotationDir = true;
    bRotateToDesired = false;
}

function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != None && pc.ViewTarget == self )
			PlayersRagdoll = true;

		if( FRand() < 0.3 )
		{
			HelmetShotOff(Rotator(Normal(GetTearOffMomemtum())));
		}

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.
		if( (Level.PhysicsDetailLevel != PDL_High) && !PlayersRagdoll && (Level.TimeSeconds - LastRenderTime > 3) )
		{
			Destroy();
			return;
		}

		// Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else if(Species != None)
			RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
		else
			Log("xPawn.PlayDying: No Species");

		// If we managed to find a name, try and make a rag-doll slot availbale.
		if( RagSkelName != "" )
		{
			KMakeRagdollAvailable();
		}

		if( KIsRagdollAvailable() && RagSkelName != "" )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;

			// Stop animation playing.
			StopAnimating(true);

			if( DamageType != None )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
					RagShootStrength = DamageType.default.KDamageImpulse;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(GetTearOffMomemtum());
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;



			if( DamageType.default.bLocationalHit )
			{
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;

				if( Abs(hitLocRel.X)  > RagMaxSpinAmount )
				{
					if( hitLocRel.X < 0 )
					{
						hitLocRel.X = FMax((hitLocRel.X * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.X = FMin((hitLocRel.X * RagSpinScale), RagMaxSpinAmount);
					}
				}

				if( Abs(hitLocRel.Y)  > RagMaxSpinAmount )
				{
					if( hitLocRel.Y < 0 )
					{
						hitLocRel.Y = FMax((hitLocRel.Y * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.Y = FMin((hitLocRel.Y * RagSpinScale), RagMaxSpinAmount);
					}
				}

			}
			else
			{
				// We scale the hit location out sideways a bit, to get more spin around Z.
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;
			}

			//log("hitLocRel.X = "$hitLocRel.X$" hitLocRel.Y = "$hitLocRel.Y);
			//log("TearOffMomentum = "$VSize(GetTearOffMomemtum()));

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(GetTearOffMomemtum()) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else
			{
				deathAngVel = RagInvInertia * (hitLocRel cross shotStrength);
			}

    		// Set initial angular and linear velocity for ragdoll.
			// Scale horizontal velocity for characters - they run really fast!
			if ( DamageType.Default.bRubbery )
				skelParams.KStartLinVel = vect(0,0,0);
			if ( Damagetype.default.bKUseTearOffMomentum )
				skelParams.KStartLinVel = GetTearOffMomemtum() + Velocity;
			else
			{
				skelParams.KStartLinVel.X = 0.6 * Velocity.X;
				skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
				skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
    				skelParams.KStartLinVel += shotStrength;
			}
			// if not moving downwards - give extra upward kick
			if( !DamageType.default.bLeaveBodyEffect && !DamageType.Default.bRubbery && (Velocity.Z > -10) )
				skelParams.KStartLinVel.Z += RagDeathUpKick;

			if ( DamageType.Default.bRubbery )
			{
				Velocity = vect(0,0,0);
    			skelParams.KStartAngVel = vect(0,0,0);
    		}
			else
			{
    			skelParams.KStartAngVel = deathAngVel;

    			// Set up deferred shot-bone impulse
				maxDim = Max(CollisionRadius, CollisionHeight);

    			skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
    			skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
    			skelParams.KShotStrength = RagShootStrength;
			}

			//log("RagDeathVel = "$RagDeathVel$" KShotStrength = "$skelParams.KShotStrength$" RagDeathUpKick = "$RagDeathUpKick);

    		// If this damage type causes convulsions, turn them on here.
    		if(DamageType != none && DamageType.default.bCauseConvulsions)
    		{
    			RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
    			skelParams.bKDoConvulsions = true;
		    }

    		// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);

			// Set physics mode to ragdoll.
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			// If viewing this ragdoll, set the flag to indicate that it is 'important'
			if( PlayersRagdoll )
				skelParams.bKImportantRagdoll = true;

			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}

	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    // We don't do this - Ramm
    //PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

// Apply karma from client side explosions to a ragdoll for a dead pawn
simulated function DeadExplosionKarma(class<DamageType> DamageType, vector Momentum, float Strength)
{
    local Vector shotDir;
    local Vector PushLinVel, PushAngVel;

	if( (RagdollLifeSpan - LifeSpan) < 1.0 )
	{
		return;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( class'GameInfo'.static.UseLowGore() )
			return;

		if( DamageType != none )
		{
			if( DamageType.default.bKUseOwnDeathVel )
			{
				RagDeathVel = DamageType.default.KDeathVel;
				RagDeathUpKick = DamageType.default.KDeathUpKick;
				RagShootStrength = DamageType.default.KDamageImpulse;
			}
		}


		shotDir = Normal(Momentum);
	    PushLinVel = (RagDeathVel * shotDir);
	    PushLinVel.Z += RagDeathUpKick*(RagShootStrength*DamageType.default.KDeadLinZVelScale);

		PushAngVel = Normal(shotDir cross vect(0, 0, 1)) * -18000;
		PushAngVel *= RagShootStrength*DamageType.default.KDeadAngVelScale;

		PushLinVel *= Strength;
		PushAngVel *= Strength;

		KSetSkelVel( PushLinVel, PushAngVel );

		if ( DamageType.Default.DeathOverlayMaterial != None )
			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
	}
}

// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	PlayDyingSound();

    if ( class'GameInfo'.static.UseLowGore() )
		return;

	if( ObliteratedEffectClass != none )
		Spawn( ObliteratedEffectClass,,, Location, HitRotation );

    if ( FRand() < 0.1 )
	{
		SpawnGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
		SpawnGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
	}
	else if ( FRand() < 0.25 )
	{
		SpawnGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		if ( FRand() < 0.5 )
		{
			SpawnGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
		}
	}
	else if ( FRand() < 0.35 )
		SpawnGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
	else if ( FRand() < 0.5 )
	{
		SpawnGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
	}
}

function ClientDying(class<DamageType> DamageType, vector HitLocation){}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local vector direction;
    local rotator InvRotation;
    local float jarscale;
    // This doesn't really fit our system - Ramm
	//PlayDirectionalHit(HitLocation);

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;

    if( HeadVolume.bWaterVolume )
    {
        //if( DamageType.IsA('Drowned') )
            //PlaySound( GetSound(EST_Drown), SLOT_Pain,1.5*TransientSoundVolume );
        //else
            //PlaySound( GetSound(EST_HitUnderwater), SLOT_Pain,1.5*TransientSoundVolume );
        return;
    }

    // for standalone and client
    // Cooney
    if ( Level.NetMode != NM_DedicatedServer )
    {
       if ( class<ROWeaponDamageType>(DamageType) != none )
       {
           if (class<ROWeaponDamageType>(DamageType).default.bCauseViewJarring == true
              && ROPlayer(Controller) != none)
           {
               // Get the approximate direction
               // that the hit went into the body
               direction = self.Location - HitLocation;
               // No up-down jarring effects since
               // I dont have the barrel valocity
               direction.Z = 0.0f;
               direction = normal(direction);

               // We need to rotate the jarring direction
               // in screen space so basically the
               // exact opposite of the player's pawn's
               // rotation.
               InvRotation.Yaw = -Rotation.Yaw;
               InvRotation.Roll = -Rotation.Roll;
               InvRotation.Pitch = -Rotation.Pitch;
               direction = direction >> InvRotation;

               jarscale = 0.1f + (Damage/50.0f);
               if ( jarscale > 1.0f ) jarscale = 1.0f;

               ROPlayer(Controller).PlayerJarred(direction,jarscale);
           }
       }
    }

    PlayOwnedSound(SoundGroupClass.static.GetHitSound(DamageType), SLOT_Pain,3*TransientSoundVolume,,200);
}

// jag
// Called when in Ragdoll when we hit something over a certain threshold velocity
// Used to play impact sounds.
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local float VelocitySquared;
	local float RagHitVolume;

	if(Level.TimeSeconds > RagLastSoundTime + RagImpactSoundInterval)
	{
    	VelocitySquared = VSizeSquared(impactVel);

		//log("Ragimpact velocity: "$VSize(impactVel)$" VelocitySquared: "$VelocitySquared);

		RagHitVolume = FMin(2.0,(VelocitySquared/40000));

		//log("RagHitVolume = "$RagHitVolume);

		//PlaySound(RagImpactSound, SLOT_None, RagHitVolume);
		RagLastSoundTime = Level.TimeSeconds;
	}
}
//jag

simulated function PlayFootStepLeft()
{
    PlayFootStep(-1);
}

simulated function PlayFootStepRight()
{
    PlayFootStep(1);
}

simulated function ClientRestart()
{
	Super.ClientRestart();
	if ( Controller != None )
		OldController = Controller;
}

// MergeTODO: Write some real code for this
simulated function bool ForceDefaultCharacter()
{

	//log("MergeTODO: Write some real code for ForceDefaultCharacter!!!");

	return false;
/*	local PlayerController P;

	if ( !class'DeathMatch'.default.bForceDefaultCharacter )
		return false;

	// validate and use player's model for enemies of same sex
	P = Level.GetLocalPlayerController();
	if ( (P != None) && (P.PlayerReplicationInfo != None) )
	{
		if ( P.PlayerReplicationInfo.bIsFemale )
		{
			PlacedFemaleCharacterName = P.PlayerReplicationInfo.CharacterName;
			if ( !CheckValidFemaleDefault() )
			{
				PlacedFemaleCharacterName = "Tamika";
				return false;
			}
		}
		else
		{
			PlacedCharacterName = P.PlayerReplicationInfo.CharacterName;
			if ( !CheckValidMaleDefault() )
			{
				PlacedCharacterName = "Jakob";
				return false;
			}
		}
	}
	return true;  */
}

// MergeTODO: Write some real code for this
simulated function string GetDefaultCharacter()
{
	//log("MergeTODO: Write some real code for GetDefaultCharacter!!!");

    return "FixmePlease";

/*	if ( Level.IsDemoBuild() )
	{
		PlacedFemaleCharacterName = "Tamika";
		PlacedCharacterName = "Jakob";
	}
	else
	{
		// make sure picking from valid default characters
		if ( !CheckValidFemaleDefault() )
			PlacedFemaleCharacterName = "Tamika";

		if ( !CheckValidMaleDefault() )
			PlacedCharacterName = "Jakob";
	}
	// return appropriate character based on this pawn's sex
	if ( (PlayerReplicationInfo != None) && PlayerReplicationInfo.bIsFemale )
		return PlacedFemaleCharacterName;
	else
		return PlacedCharacterName; */
}

// MergeTODO: Replace xUtil with ROUtil
simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	if ( (rec.Species == None) || ForceDefaultCharacter() )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());

    Species = rec.Species;
	RagdollOverride = rec.Ragdoll;

	if ( !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		if ( !Species.static.Setup(self,rec) )
			return;
	}
	ResetPhysicsBasedAnim();
}

simulated function ResetPhysicsBasedAnim()
{
    bIsIdle = false;
    bWaitForAnim = false;
}

function Sound GetSound(ROPawnSoundGroup.ESoundType soundType)
{
	local int SurfaceTypeID;
	local actor A;
	local vector HL,HN,Start,End;
	local material FloorMat;

    if( soundType == EST_Land || soundType == EST_Jump )
	{
		if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
		{
			SurfaceTypeID = Base.SurfaceType;
		}
		else
		{
			Start = Location - Vect(0,0,1)*CollisionHeight;
			End = Start - Vect(0,0,16);
			A = Trace(hl,hn,End,Start,false,,FloorMat);
			if (FloorMat !=None)
				SurfaceTypeID = FloorMat.SurfaceType;
		}
	}

    return SoundGroupClass.static.GetSound(soundType, SurfaceTypeID);
}

// End Xpawn functions

//Lean functions
simulated function bool TraceWall(int Direction, float CheckDist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, TraceStart, TraceEnd;
	local rotator Angle;

	Angle.Yaw=Direction;

	TraceStart=Location;
	TraceStart.Z+=BaseEyeHeight;
	TraceEnd=TraceStart+vector(Rotation+Angle)*CheckDist;

	HitActor=Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

	if ( HitActor != None )
		return true;

	return false;
}

simulated function TickLean(float DeltaTime)
{
    if( Role > ROLE_SimulatedProxy )
    {
		//If theres a wall to the side of the lean can't be leaning
		if (bLeanLeft && TraceWall(-16384, 64))
			bLeanLeft = false;

		if (bLeanRight && TraceWall(16384, 64))
			bLeanRight = false;

		if ( bIsSprinting )
		{
			bLeanLeft = false;
			bLeanRight = false;
		}
	}

	//Return from leaning right to center
	if ( bLeaningRight && !bLeanRight )
	{
		LeanAmount -= LeanFactor * deltatime;
		if ( LeanAmount < 0 )
		{
			LeanAmount = 0;
			bLeaningRight=false;
		}
	}
	//Leaning right
	else if ( bLeanRight )
	{
		if ( abs(LeanAmount) < LeanMax )
			LeanAmount += LeanFactor * deltatime;
		else if ( abs(LeanAmount) >= LeanMax )
			LeanAmount = LeanMax;
		bLeaningRight=true;
	}
	//Returning from lean left to center
	if (bLeaningLeft && !bLeanLeft)
	{
		LeanAmount += LeanFactor * deltatime;
		if ( LeanAmount > 0 )
		{
			LeanAmount = 0;
			bLeaningLeft=false;
		}
	}
	//Leaning left
	else if (bLeanLeft)
	{
		if ( abs(LeanAmount) < LeanMax )
			LeanAmount -= LeanFactor * deltatime;
		else if ( abs(LeanAmount) >= LeanMax )
			LeanAmount = -LeanMax;
		bLeaningLeft=true;
	}
}

simulated function LeanRight()
{
	if ( TraceWall(16384, 64) || bLeaningLeft || bIsSprinting )
	{
		bLeanRight=false;
		return;
	}

	if ( !bLeanLeft )
		bLeanRight=true;
}

simulated function LeanRightReleased()
{
	bLeanRight=false;
}

simulated function LeanLeft()
{
	if ( TraceWall(-16384, 64) || bLeaningRight || bIsSprinting )
	{
		bLeanLeft=false;
		return;
	}

	if ( !bLeanRight )
		bLeanLeft=true;
}

simulated function LeanLeftReleased()
{
	bLeanLeft=false;
}

function float ModifyThreat(float current, Pawn Threat)
{
	if (Vehicle(Threat) != None)
		current -= 2.0;
	else
		current += 0.5;
	return current;
}

defaultproperties
{
     bNoDefaultInventory=True
     bAcceptAllInventory=True
     bPlayOwnFootsteps=True
     AttackSuitability=0.500000
     SquadName="Squad"
     VoiceType="ROGame.ROGerman1Voice"
     bPlayerShadows=True
     Species=Class'ROEngine.ROSPECIES_Human'
     DeResTime=6.000000
     GruntVolume=0.180000
     FootstepVolume=0.500000
     MinTimeBetweenPainSounds=0.350000
     SoundGroupClass=Class'ROEngine.ROPawnSoundGroup'
     RagdollLifeSpan=30.000000
     RagInvInertia=4.000000
     RagDeathVel=100.000000
     RagShootStrength=200.000000
     RagSpinScale=7.500000
     RagMaxSpinAmount=100.000000
     RagGravScale=1.000000
     RagImpactSoundInterval=0.250000
     PlacedCharacterName="Soldier"
     FireRootBone="Bip01_Spine"
     SeveredArmAttachClass=Class'ROEffects.SeveredArmAttachment'
     SeveredLegAttachClass=Class'ROEffects.SeveredLegAttachment'
     SeveredHeadAttachClass=Class'ROEffects.SeveredHeadAttachment'
     BleedingEmitterClass=Class'ROEffects.ROBloodSpurt'
     ProjectileBloodSplatClass=Class'ROEffects.ProjectileBloodSplat'
     DetachedArmClass=Class'ROEffects.SeveredArm'
     DetachedLegClass=Class'ROEffects.SeveredLeg'
     ObliteratedEffectClass=Class'ROEffects.PlayerObliteratedEmitter'
     Stamina=20.000000
     JumpStaminaDrain=4.000000
     StaminaRecoveryRate=0.650000
     CrouchStaminaRecoveryRate=0.800000
     ProneStaminaRecoveryRate=1.000000
     SlowStaminaRecoveryRate=0.200000
     MomentumCurve=(Points=((InVal=400.000000),(InVal=625.000000,OutVal=1.250000),(InVal=2500.000000,OutVal=3.125000),(InVal=5625.000000,OutVal=6.250000),(InVal=1000000000.000000,OutVal=6.250000)))
     FrictionScale=0.543750
     PronePitchUpLimit=14000
     PronePitchDownLimit=51000
     CrawlingPitchUpLimit=14000
     CrawlingPitchDownLimit=60000
     CrawlPitchTweenRate=60000
     ProneIdleRestAnim="prone_idle_nade"
     CrouchIdleRestAnim="crouch_idle_nade"
     ProneAnims(0)="prone_crawlF_nade"
     ProneAnims(1)="prone_crawlB_nade"
     ProneAnims(2)="prone_crawlL_nade"
     ProneAnims(3)="prone_crawlR_nade"
     ProneAnims(4)="prone_crawlFL_nade"
     ProneAnims(5)="prone_crawlFR_nade"
     ProneAnims(6)="prone_crawlBL_nade"
     ProneAnims(7)="prone_crawlBR_nade"
     IdleProneAnim="prone_idle_nade"
     ProneTurnRightAnim="prone_turnR_binoc"
     ProneTurnLeftAnim="prone_turnL_binoc"
     StandToProneAnim="StandtoProne_nade"
     ProneToStandAnim="PronetoStand_nade"
     CrouchToProneAnim="CrouchtoProne_nade"
     ProneToCrouchAnim="PronetoCrouch_nade"
     DiveToProneStartAnim="prone_divef_nade"
     DiveToProneEndAnim="prone_diveend_nade"
     SprintAnims(0)="stand_sprintF_nade"
     SprintAnims(1)="stand_sprintB_nade"
     SprintAnims(2)="stand_sprintL_nade"
     SprintAnims(3)="stand_sprintR_nade"
     SprintAnims(4)="stand_sprintFL_nade"
     SprintAnims(5)="stand_sprintFR_nade"
     SprintAnims(6)="stand_sprintBL_nade"
     SprintAnims(7)="stand_sprintBR_nade"
     SprintCrouchAnims(0)="crouch_sprintF_nade"
     SprintCrouchAnims(1)="crouch_sprintB_nade"
     SprintCrouchAnims(2)="crouch_sprintL_nade"
     SprintCrouchAnims(3)="crouch_sprintR_nade"
     SprintCrouchAnims(4)="crouch_sprintFL_nade"
     SprintCrouchAnims(5)="crouch_sprintFR_nade"
     SprintCrouchAnims(6)="crouch_sprintBL_nade"
     SprintCrouchAnims(7)="crouch_sprintBR_nade"
     WalkIronAnims(0)="stand_walkFiron_binoc"
     WalkIronAnims(1)="stand_walkBiron_binoc"
     WalkIronAnims(2)="stand_walkLiron_binoc"
     WalkIronAnims(3)="stand_walkRiron_binoc"
     WalkIronAnims(4)="stand_walkFLiron_binoc"
     WalkIronAnims(5)="stand_walkFRiron_binoc"
     WalkIronAnims(6)="stand_walkBLiron_binoc"
     WalkIronAnims(7)="stand_walkBRiron_binoc"
     IdleIronRestAnim="stand_idleiron_binoc"
     IdleIronWeaponAnim="stand_idleiron_binoc"
     IdleCrouchIronWeaponAnim="crouch_idle_nade"
     TurnIronRightAnim="stand_turnRiron_binoc"
     TurnIronLeftAnim="stand_turnLiron_binoc"
     CrouchTurnIronRightAnim="crouch_turnRiron_binoc"
     CrouchTurnIronLeftAnim="crouch_turnLiron_binoc"
     LimpAnims(0)="stand_limpFhip_binoc"
     LimpAnims(1)="stand_limpBhip_binoc"
     LimpAnims(2)="stand_limpLhip_binoc"
     LimpAnims(3)="stand_limpRhip_binoc"
     LimpAnims(4)="stand_limpFLhip_binoc"
     LimpAnims(5)="stand_limpFRhip_binoc"
     LimpAnims(6)="stand_limpBLhip_binoc"
     LimpAnims(7)="stand_limpBRhip_binoc"
     LandRecoveryTime=1.500000
     CurrentCapArea=255
     SprintAccelRate=350.000000
     FootStepSoundRadius=125.000000
     QuietFootStepVolume=0.450000
     CrouchEyeHeightMod=0.300000
     CrouchMoveEyeHeightMod=0.770000
     ProneEyeHeight=5.000000
     ProneEyeDist=10.000000
     CameraBone="Camera_Bone"
     LeanMax=3000.000000
     LeanFactor=10000.000000
     LeanLViewOffset=(Y=-18.000000,Z=-8.000000)
     LeanRViewOffset=(Y=21.000000,Z=-14.000000)
     LeanLCrouchViewOffset=(Y=-14.000000,Z=-1.000000)
     LeanRCrouchViewOffset=(Y=17.000000,Z=-8.000000)
     LeanLProneViewOffset=(Y=-14.000000,Z=2.000000)
     LeanRProneViewOffset=(Y=17.000000,Z=1.000000)
     AnimPitchUpLimit=9000
     AnimPitchDownLimit=-14000
     ProneAnimPitchUpLimit=4500
     ProneAnimPitchDownLimit=-2000
     LeanBones(0)="Bip01_Spine"
     LeanBones(1)="Bip01_Spine1"
     LeanBones(2)="Bip01_Spine2"
     LeanBones(3)="Bip01_Spine3"
     LeanBones(4)="Bip01_Neck"
     LeanBones(5)="Bip01_Head"
     LeanBones(6)="ShovelCase01"
     LeanLeftStanding(0)=(Pitch=4850)
     LeanLeftStanding(1)=(Pitch=4850)
     LeanLeftStanding(6)=(Pitch=-3800)
     LeanRightStanding(0)=(Pitch=-6500)
     LeanRightStanding(1)=(Pitch=350)
     LeanRightStanding(6)=(Pitch=3000)
     LeanLeftCrouch(0)=(Pitch=6000)
     LeanLeftCrouch(1)=(Pitch=4000,Yaw=1000)
     LeanLeftCrouch(5)=(Pitch=-4000)
     LeanLeftCrouch(6)=(Pitch=-7000)
     LeanRightCrouch(0)=(Pitch=-3000)
     LeanRightCrouch(1)=(Pitch=-2800)
     LeanRightCrouch(5)=(Roll=-1000)
     LeanRightCrouch(6)=(Pitch=1300)
     LeanLeftProne(0)=(Pitch=2500,Yaw=6000,Roll=2500)
     LeanLeftProne(1)=(Pitch=4000,Yaw=-3000,Roll=-300)
     LeanLeftProne(5)=(Pitch=-2000)
     LeanLeftProne(6)=(Pitch=-1000,Yaw=-5000)
     LeanRightProne(0)=(Pitch=2000,Yaw=-4500,Roll=2000)
     LeanRightProne(1)=(Pitch=-7000,Yaw=3000,Roll=500)
     LeanRightProne(6)=(Pitch=-1500,Yaw=2000)
     DeployedPitchUpLimit=12000
     DeployedPitchDownLimit=-10000
     DeployedPositiveYawLimit=7300
     DeployedNegativeYawLimit=-7300
     NetSoundRadiusSquared=820000.000000
     bCanCrouch=True
     bCanSwim=True
     bCanClimbLadders=True
     bCanStrafe=True
     bCanDoubleJump=False
     bCanWalkOffLedges=True
     bNoCoronas=False
     bCanPickupInventory=True
     bMuffledHearing=True
     SightRadius=6000.000000
     MeleeRange=20.000000
     GroundSpeed=200.000000
     WaterSpeed=100.000000
     AirSpeed=70.000000
     LadderSpeed=75.000000
     AccelRate=300.000000
     JumpZ=315.000000
     AirControl=0.020000
     WalkingPct=0.350000
     CrouchedPct=0.300000
     MaxFallSpeed=650.000000
     BaseEyeHeight=42.000000
     EyeHeight=42.000000
     CrouchHeight=38.000000
     CrouchRadius=22.000000
     UnderWaterTime=20.000000
     Bob=0.010000
     ControllerClass=Class'ROEngine.ROBot'
     bPhysicsAnimUpdate=True
     bDoTorsoTwist=True
     MovementAnims(0)="stand_jogF_nade"
     MovementAnims(1)="stand_jogB_nade"
     MovementAnims(2)="stand_jogL_nade"
     MovementAnims(3)="stand_jogR_nade"
     MovementAnims(4)="stand_jogFL_nade"
     MovementAnims(5)="stand_jogFR_nade"
     MovementAnims(6)="stand_jogBL_nade"
     MovementAnims(7)="stand_jogBR_nade"
     TurnLeftAnim="stand_turnLhip_binoc"
     TurnRightAnim="stand_turnRhip_binoc"
     SwimAnims(0)="stand_jogF_nade"
     SwimAnims(1)="stand_jogB_nade"
     SwimAnims(2)="stand_jogL_nade"
     SwimAnims(3)="stand_jogR_nade"
     CrouchAnims(0)="crouch_walkF_nade"
     CrouchAnims(1)="crouch_walkB_nade"
     CrouchAnims(2)="crouch_walkL_nade"
     CrouchAnims(3)="crouch_walkR_nade"
     CrouchAnims(4)="crouch_walkFL_nade"
     CrouchAnims(5)="crouch_walkFR_nade"
     CrouchAnims(6)="crouch_walkBL_nade"
     CrouchAnims(7)="crouch_walkBR_nade"
     WalkAnims(0)="stand_walkFhip_binoc"
     WalkAnims(1)="stand_walkBhip_binoc"
     WalkAnims(2)="stand_walkLhip_binoc"
     WalkAnims(3)="stand_walkRhip_binoc"
     WalkAnims(4)="stand_walkFLhip_binoc"
     WalkAnims(5)="stand_walkFRhip_binoc"
     WalkAnims(6)="stand_walkBLhip_binoc"
     WalkAnims(7)="stand_walkBRhip_binoc"
     AirAnims(0)="jumpF_mid_binoc"
     AirAnims(1)="jumpB_mid_binoc"
     AirAnims(2)="jumpL_mid_binoc"
     AirAnims(3)="jumpR_mid_binoc"
     TakeoffAnims(0)="jumpF_takeoff_binoc"
     TakeoffAnims(1)="jumpB_takeoff_binoc"
     TakeoffAnims(2)="jumpL_takeoff_binoc"
     TakeoffAnims(3)="jumpR_takeoff_binoc"
     LandAnims(0)="jumpF_land_binoc"
     LandAnims(1)="jumpB_land_binoc"
     LandAnims(2)="jumpL_land_binoc"
     LandAnims(3)="jumpR_land_binoc"
     DodgeAnims(0)="jumpF_mid_binoc"
     DodgeAnims(1)="jumpB_mid_binoc"
     DodgeAnims(2)="jumpL_mid_binoc"
     DodgeAnims(3)="jumpR_mid_binoc"
     AirStillAnim="jump_mid_binoc"
     TakeoffStillAnim="jump_takeoff_binoc"
     CrouchTurnRightAnim="crouch_turnR_nade"
     CrouchTurnLeftAnim="crouch_turnL_nade"
     IdleCrouchAnim="crouch_idle_nade"
     IdleWeaponAnim="stand_idlehip_binoc"
     IdleRestAnim="stand_idlehip_binoc"
     IdleChatAnim="Idle_Chat"
     RootBone="HIP"
     HeadBone="Bip01_Head"
     SpineBone1="Bip01_Spine"
     SpineBone2="Bip01_Spine1"
     bCanProne=True
     ProneHeight=10.000000
     HitPoints(0)=(PointRadius=60.000000,PointHeight=75.000000,PointScale=1.000000,PointBone="HIP")
     HitPoints(1)=(PointRadius=6.500000,PointHeight=8.000000,PointScale=1.000000,PointBone="head",PointOffset=(X=4.000000,Y=-2.500000),DamageMultiplier=2.000000,HitPointType=PHP_Head)
     HitPoints(2)=(PointRadius=11.000000,PointHeight=13.000000,PointScale=1.000000,PointBone="UpperSpine",PointOffset=(X=5.000000),DamageMultiplier=1.000000,HitPointType=PHP_Torso)
     HitPoints(3)=(PointRadius=10.500000,PointHeight=10.000000,PointScale=1.000000,PointBone="spine",PointOffset=(X=-5.000000),DamageMultiplier=1.000000,HitPointType=PHP_Torso)
     HitPoints(4)=(PointRadius=6.000000,PointHeight=12.000000,PointScale=1.000000,PointBone="lupperthigh",PointOffset=(X=16.000000,Z=1.000000),DamageMultiplier=0.500000,HitPointType=PHP_Leg)
     HitPoints(5)=(PointRadius=6.000000,PointHeight=12.000000,PointScale=1.000000,PointBone="rupperthigh",PointOffset=(X=16.000000,Z=-1.000000),DamageMultiplier=0.500000,HitPointType=PHP_Leg)
     HitPoints(6)=(PointRadius=5.000000,PointHeight=9.000000,PointScale=1.000000,PointBone="lupperarm",PointOffset=(X=7.000000),DamageMultiplier=0.300000,HitPointType=PHP_Arm)
     HitPoints(7)=(PointRadius=5.000000,PointHeight=9.000000,PointScale=1.000000,PointBone="rupperarm",PointOffset=(X=7.000000),DamageMultiplier=0.300000,HitPointType=PHP_Arm)
     HitPoints(8)=(PointRadius=5.000000,PointHeight=15.000000,PointScale=1.000000,PointBone="lthigh",PointOffset=(X=15.000000),DamageMultiplier=0.400000,HitPointType=PHP_Leg)
     HitPoints(9)=(PointRadius=5.000000,PointHeight=15.000000,PointScale=1.000000,PointBone="rthigh",PointOffset=(X=15.000000),DamageMultiplier=0.400000,HitPointType=PHP_Leg)
     HitPoints(10)=(PointRadius=4.000000,PointHeight=10.000000,PointScale=1.000000,PointBone="lfarm",PointOffset=(X=7.000000),DamageMultiplier=0.200000,HitPointType=PHP_Arm)
     HitPoints(11)=(PointRadius=4.000000,PointHeight=10.000000,PointScale=1.000000,PointBone="rfarm",PointOffset=(X=7.000000),DamageMultiplier=0.200000,HitPointType=PHP_Arm)
     HitPoints(12)=(PointRadius=4.000000,PointHeight=5.000000,PointScale=1.000000,PointBone="lhand",PointOffset=(X=5.000000,Y=-1.000000,Z=-1.000000),DamageMultiplier=0.100000,HitPointType=PHP_Hand)
     HitPoints(13)=(PointRadius=4.000000,PointHeight=5.000000,PointScale=1.000000,PointBone="rhand",PointOffset=(X=5.000000,Y=-2.000000),DamageMultiplier=0.100000,HitPointType=PHP_Hand)
     HitPoints(14)=(PointRadius=4.000000,PointHeight=7.000000,PointScale=1.000000,PointBone="lfoot",PointOffset=(Y=-2.000000),DamageMultiplier=0.100000,HitPointType=PHP_Foot)
     HitPoints(15)=(PointRadius=4.000000,PointHeight=7.000000,PointScale=1.000000,PointBone="rfoot",PointOffset=(Y=-2.000000),DamageMultiplier=0.100000,HitPointType=PHP_Foot)
     LightHue=204
     LightBrightness=255.000000
     LightRadius=3.000000
     bActorShadows=True
     bDramaticLighting=True
     bStasis=False
     LODBias=1.800000
     Texture=None
     PrePivot=(Z=-42.000000)
     AmbientGlow=5
     MaxLights=8
     bForceSkelUpdate=True
     SoundVolume=150
     SoundRadius=75.000000
     CollisionRadius=23.000000
     CollisionHeight=52.000000
     bUseCylinderCollision=True
     bNetNotify=True
     bBlockHitPointTraces=False
     Buoyancy=99.000000
     RotationRate=(Pitch=3072,Roll=2048)
     Begin Object Class=KarmaParamsSkel Name=PawnKParams
         KConvulseSpacing=(Max=2.200000)
         KLinearDamping=0.150000
         KAngularDamping=0.050000
         KBuoyancy=1.000000
         KStartEnabled=True
         KVelDropBelowThreshold=50.000000
         bHighDetailOnly=False
         KFriction=1.300000
         KRestitution=0.200000
         KImpactThreshold=85.000000
     End Object
     KParams=KarmaParamsSkel'ROEngine.ROPawn.PawnKParams'

     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=2.500000
}
