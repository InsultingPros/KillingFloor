// Base Zombie Class.
class KFMonster extends Skaarj
	hidecategories(AnimTweaks,DeRes,Force,Gib,Karma,Udamage,UnrealPawn)
	Abstract;

#exec OBJ LOAD FILE=KF_EnemyGlobalSndTwo.uax
#exec OBJ LOAD FILE=KFZED_Temp_UT.utx
#exec OBJ LOAD FILE=KFZED_FX_T.utx


var array<string> EventClasses;
/*
var string MeshRef;
var	array<string> SkinsRef;
var string	DetachedArmClassRef;		// class of detached arm to spawn for this pawn. Modified by the subclass to match the player model
var string	DetachedLegClassRef;		// class of detached leg to spawn for this pawn. Modified by the subclass to match the player model
var string	DetachedHeadClassRef;		// class of detached head to spawn for this pawn. Modified by the subclass to match the player model
var string	DetachedSpecialArmClassRef;// class of detached special arm to spawn for this pawn. Modified by the subclass to match the player model

//dynamic sound loading stuff
var array<string> HitSoundRef;
var string AmbientSoundRef;
var array<string> ChallengeSoundRef;
var string MoanVoiceRef;
var array<string> DeathSoundRef;
var string JumpSoundRef;
var string MeleeAttackHitSoundRef;
*/
/* reference to the ZombieVolume which spawned me .. */
var ZombieVolume                            SpawnVolume;

var name MeleeAnims[3];
var name HitAnims[3];

var(Sounds)     sound   MoanVoice; // The sound of this Monster randomly "talking"
var(Sounds)     float   MoanVolume;// The volume to use for the zombie moaning

var float NextBileTime, BileFrequency;
var int BileCount;
var Pawn BileInstigator;
var class<DamTypeVomit> LastBileDamagedByType;

var name KFHitFront;
var name KFHitBack;
var name KFHitLeft;
var name KFHitRight;

var(Karma) float RagMaxSpinAmount; // The max we'll scale up spin amount for locational hit damage

var int LookRotPitch,LookRotYaw;
var Pawn LookTarget;

var int HitMomentum;

var bool bRanged;

var() 	bool 	bStunImmune; 		// is the zombie immune to stun hit effects?
var 	bool 	bSTUNNED;
var		float	StunTime;
var		int		StunsRemaining;		// Number of stuns that can ever play on one instance of this character(-1 is the default and is infinite)
var		bool 	bDecapitated; 		// has he lost his noggin'!?
var 	int  	Gored; 				// Has he lost his whole torso?! if so, how much of it?
var 	bool 	DECAP;
var 	bool 	bBurnified;
var 	bool 	bBurnApplied;
var 	byte 	HeatAmount;
var()	float	BleedOutDuration;   // How long this zombie survives after losing its head
var		float	BleedOutTime;       // When this zombie will die from bleeding out
var     bool    bNoBrainBitEmitter; // We want to skip the brain bit emitter for this zed

var() bool bCannibal;  // If true, this enemy will stop to eat corpses it finds.

var     bool    bZapped;            // This zed has been zapped by the ZEDGun
var     bool    bOldZapped;         // The last state of the bZapped flag
var     float   RemainingZap;       // How much zap time this zed has left
var     float   TotalZap;           // How much zap this zed has taken
var     float   LastZapTime;        // The last time we recieved any "zap"
var()   float   ZapDuration;        // How long a zap lasts
var()   float   ZappedSpeedMod;     // How much to slow down zeds when they are zapped
var()   float   ZapThreshold;       // How much time of being hit with zap before this zed get's "zapped"
var()   float   ZappedDamageMod;    // How much to scale damage by when this zed is zapped
var()   float   ZapResistanceScale; // Every time the zed gets zapped, scale his resistance up by this modifier. This prevent zeds from getting constantly raped by zap (like the fleshpound)
var     Pawn    ZappedBy;  //who did the zapping

var     bool    bHarpoonStunned;    // This zed has been stunned by a harpoon
var     bool    bOldHarpoonStunned; // The last state of the bHarpoonStunned flag
var()   bool    bHarpoonToHeadStuns;// A harpoon to this zeds head will stun it
var()   bool    bHarpoonToBodyStuns;// A harpoon to this zeds body will stun it
var     int     NumHarpoonsAttached;// The number of harpoons stuck in us

var     float   DamageToMonsterScale;// How much to scale up damage for this zed damaging other monsters. Monsters have much higher health than humans, so when monsters duke it out they need to do more damage to each other
var     float   HumanBileAggroChance;// What random percentage chance (0.15-1.0) to have a zed go attack the nearest bloat when a human sprays them with a bloat bile weapon

// Zombie flags:
// 0 - Normal zombie
// 1 - Ranged zombie
// 2 - Leaping zombie
// 3 - Massive zombie
var() byte ZombieFlag;

var float LastPuntTime, DecapTime;

var rotator NewTorsoRotation;
//var int MaxTorsoYaw,MaxTorsoPitch,MaxTorsoRoll;  // limits on SetBoneRot for hit reactions.

var(AI) int MaxSpineVariation; // Maximum base amount the bone can bend. Set in defprops.
var(AI) bool bContorts ;  // Does this guy do the LIiiiMBO!!!
var(AI) float MaxContortionPercentage; // def. 0.25

var()   int     MeleeDamage;    // The amount of damage this Zed does when melee attacking
var int damageForce;
var float LastPainAnim;
var(AI) float MinTimeBetweenPainAnims;
var bool playedHit;
var vector KickLocation, ImpactVector;
var actor KickTarget;

var bool bPlayBrainSplash;
var bool bPlayGoreSplash;
var float FeedThreshold; // OBSOLOTE.

var float CorpseStaticTime;   // The level.timeseconds record of when the corpse has stopped moving, and should soon go static.  1 second later, it will.
var bool bCorpsePositionSet;
var float CorpseLifeSpan;  // The time the zombie corpse will be around for.
var bool bDestroyNextTick; // Destroy this pawn next tick because destroying it now will cause problems
var float TimeSetDestroyNextTickTime; // The time we set the bDestroyNextTick flag

var pawn LastDamagedBy;
var class<damagetype> LastDamagedByType;
var int LastDamageAmount;
var vector LastHitLocation,LastMomentum ;
var float TorsoReturnAlpha;
var bool bBackstabbed;

var bool bFatAss; // HACK for pathfinding

var string KFRagdollName;

var class<DamTypeZombieAttack> ZombieDamType[3];
var class<DamTypeZombieAttack> CurrentDamType;

var sound MiscSound; //

var(Sounds)     sound   HeadLessDeathSound;   //The sound of this zombie dieing without a head
var(Sounds)     sound   DecapitationSound;    //The sound of this zombies head exploding
var(Sounds)     sound   MeleeAttackHitSound;  //The sound of this zombie's melee attack hitting a player
var(Sounds)     sound   JumpSound;            // sound of this zombie jumping

var float SpinDamConst;
var float SpinDamRand;
var() int ScreamDamage;

var() bool bMeleeStunImmune; // if true, this monster cannot be stunned or staggered by melee blows

// Fire Related
var 	int 			BurnDown; 				// Number of times our zombie must suffer Fire Damage.
var 	bool 			bAshen; 				// is our Zed crispy yet?
var 	class<Emitter> 	BurnEffect;  			// The appearance of the flames we are attaching to our Zed.
var 	class<Emitter> 	AltBurnEffect;  		// The low gore appearance of the "flames" we are attaching to our Zed.
var 	int 			LastBurnDamage; 		// Record the last amount of Fire damage the pawn suffered.
var()   int     		CrispUpThreshhold;  	// How much burn down does this zed have to take before crisping up
var     bool    		bCrispified;        	// The zed has been "ashen" alredy
var		class<DamageType>	FireDamageClass;		// Holds the Fire Damage Type that was last done(Flamethrower or Mac10)

var Effect_ShadowController RealtimeShadow;
var(Pawn) bool bRealtimeShadows; // Advanced Shadows care of Squirrelzero's code.

var(Pawn) Name PuntAnim; // The animation to play when a zombie punts a karma object


// Add an animation name here, to have it randomize with the monster's default movement animations.
var Array<Name>AdditionalWalkAnims;
var Name SpawningWalkAnim;  // the anim we're confirmed to spawn with.

var float BloodStreakInterval;
var transient float LastStreakTime;
var vector  LastStreakLocation;     // Stores the last place we left a streak, so we don't put them too close together


var class <KFGib> MonsterHeadGiblet;
var class <KFGib> MonsterThighGiblet;
var class <KFGib> MonsterArmGiblet;
var class <KFGib> MonsterLegGiblet;
var class <KFGib> MonsterTorsoGiblet;
var class <KFGib> MonsterLowerTorsoGiblet;

// Better Gore

var(Pawn) Material GoredMat;  // Swap this in when he's blown in half.

var bool bDiffAdjusted; // has this monster had it's stats adjusted for the server's difficulty? Do once.

var bool bCloaked;
var bool bSpotted; // if true , use the "revealed" shader, instead of the cloak effect
var Emitter FlamingFXs;

var Pawn BurnInstigator;

var(AI) enum EIntelligence
{
	BRAINS_Retarded, // Dumbasses
	BRAINS_Stupid, // Just plain stupid.
	BRAINS_Mammal,
	BRAINS_Human // Smarties
} Intelligence;
var(AI) bool bCanDistanceAttackDoors;
var     bool bDistanceAttackingDoor;

var() bool bStartUpDisabled,bNoAutoHuntEnemies;
var() int HealthModifer;
var() name FirstSeePlayerEvent;

var int ExpectingChannel;
var bool bResetAnimAct;
var float ResetAnimActTime;

var(ExtendedCollision)  bool        bUseExtendedCollision;      // Whether or not this monster has an extra collision cylinder
var(ExtendedCollision)  vector      ColOffset;                  // The offset of the extended collision cylinder from the root bone
var(ExtendedCollision)  float       ColRadius,ColHeight;        // The size of the extended collision cylinder
var(ExtendedCollision)  name        ExtCollAttachBoneName;      // The bone name to attach the extended collision to
var ExtendedZCollision MyExtCollision;                          // The extended collision cylinder
var                     bool        SavedExtCollision;          // Saved original state of the external collision

// Bone Names - These are used by the gore system. Need to use variables instead
// of hard coding these while we switch over from old player models to new ones - Ramm
var()   name    LeftShoulderBone;   // The bone name of the left shoulder bone
var()   name    RightShoulderBone;  // The bone name of the right shoulder bone
var()   name    LeftThighBone;      // The bone name of the left thigh bone
var()   name    RightThighBone;     // The bone name of the right thigh bone
var()   name    LeftFArmBone;       // The bone name of the left forearm bone
var()   name    RightFArmBone;      // The bone name of the right forearm bone
var()   name    LeftFootBone;       // The bone name of the left foot bone
var()   name    RightFootBone;      // The bone name of the right foot bone
var()   name    LeftHandBone;       // The bone name of the left hand bone
var()   name    RightHandBone;      // The bone name of the right hand bone
var()   name    NeckBone;           // The bone name of the neck bone

var     float   OriginalGroundSpeed;// The difficulty adjusted ground speed (need to store this off, because we have to restore this value at certain times)

// Gore
var	        SeveredAppendageAttachment 	SeveredLeftArm;         // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredRightArm;        // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredLeftLeg;         // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredRightLeg;        // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredHead;            // The meaty attachments that get attached when body parts are blown off
var(Gore)   float                       SeveredArmAttachScale;  // The drawscale of the arm gore attachement
var(Gore)   float                       SeveredLegAttachScale;  // The drawscale of the leg gore attachement
var(Gore)   float                       SeveredHeadAttachScale; // The drawscale of the head gore attachement

var	class<DismembermentJetHead>         NeckSpurtEmitterClass;  // class of the destroyed head neck emitter
var	class<DismembermentJetDecapitate>   NeckSpurtNoGibEmitterClass;// class of the chopped off head neck emitter
var	class<DismembermentJetLimb>         LimbSpurtEmitterClass;  // class of the chopped off head neck emitter

var	class<SeveredAppendageAttachment> SeveredArmAttachClass; // class of the severed arm for this role
var	class<SeveredAppendageAttachment> SeveredLegAttachClass; // class of the severed arm for this role
var	class<SeveredAppendageAttachment> SeveredHeadAttachClass; // class of the severed arm for this role

var class <ProjectileBloodSplat> ProjectileBloodSplatClass;	// class of the wall bloodsplat from a projectile's impact
var class <SeveredAppendage>	DetachedArmClass;		// class of detached arm to spawn for this pawn. Modified by the subclass to match the player model
var class <SeveredAppendage>	DetachedLegClass;		// class of detached leg to spawn for this pawn. Modified by the subclass to match the player model
var class <SeveredAppendage>	DetachedHeadClass;		// class of detached head to spawn for this pawn. Modified by the subclass to match the player model
var class <SeveredAppendage>	DetachedSpecialArmClass;// class of detached special arm to spawn for this pawn. Modified by the subclass to match the player model

var			bool				bLeftArmGibbed;			// LeftArm is already blown off
var			bool				bRightArmGibbed;		// RightArm is already blown off
var			bool				bLeftLegGibbed;			// LeftLeg is already blown off
var			bool				bRightLegGibbed;		// RightLeg is already blown off
var			bool				bHeadGibbed;		    // Head is already blown off
var class <Emitter>				ObliteratedEffectClass;	// class of detached arm to spawn for this pawn. Modified by the RoleInfo to match the player model

var()       float               PlayerCountHealthScale; // How much % of total health to add to this Zed for each additional player in the game

var         float               LastViewCheckTime;      // internal use, used to see how long its been since we checked if there was line of site between this Zed and the local player controller
var         float               LastSeenOrRelevantTime; // The last time this Zed was seen, or was relevant

var         name                HeadlessWalkAnims[4];	// Headless movement anims - Forward, Back, Left, Right
var         name                BurningWalkFAnims[3];	// Burning move forward anims
var         name                BurningWalkAnims[3];	// Burning movement anims, Back, Left, Right

var()       float               PoundRageBumpDamScale;  // How much to scale the damage from the FleshPound running into this AI

var()       float               HiddenGroundSpeed;      // How fast this Zed should move when it's out of view;

var 		rotator				NeckRot;				// Used for the low gore "decapitaton"
var         bool                bZedUnderControl;       // The zed is under the control of the zed control device
var         int                 NumZCDHits;             // How many times has this zed been hit with the ZCD Device

var()       vector              OnlineHeadshotOffset;   // Headshot offset for when a zed isn't animating online. "Best guess" since movement anims aren't played on the server side
var()       float               OnlineHeadshotScale;    // Headshot scale for when a zed isn't animating online. Scaled a little bit to cover the area the head might be in when moving, since movement anims aren't played server side
var()       float               HeadHealth;             // How much health the zed's head has, get below this and they lose thier head
var()       float               PlayerNumHeadHealthScale;// How much % of total head health to add to this Zed for each additional player in the game

var()       float               MotionDetectorThreat;   // How much of a threat is this zed considered to be to motion sensing devices

// Headshot debugging
//var         vector              ServerHeadLocation;     // The location of the Zed's head on the server, used for debugging
//var         vector              LastServerHeadLocation;

// Achievements Helpers
var	bool	bHealed;
var	bool	bOnlyDamagedByCrossbow;
var bool	bDamagedAPlayer;
var	bool	bLaserSightedEBRM14Headshotted;

replication
{
	reliable if(bNetDirty && Role == ROLE_Authority)
		bDecapitated,Gored,LookTarget,bBurnified,bAshen,FeedThreshold,bCannibal,bDiffAdjusted,bCloaked,
		bCrispified,bZedUnderControl;

	reliable if(bNetDirty && Role == ROLE_Authority)
		bZapped, bHarpoonStunned;

// Headshot debugging
//	reliable if(Role == ROLE_Authority)
//		ServerHeadLocation;
}

event PreBeginPlay()
{
	Super.PreBeginPlay();

	CalcAmbientRelevancyScale();
}

simulated function CalcAmbientRelevancyScale()
{
	// Make the zed only relevant by thier ambient sound out to a range of 10 meters
	CustomAmbientRelevancyScale = 500/(100 * SoundRadius);
}

// empty functions to avoid casting
function StartCharging(){}
function DebugLog(){}
function BreakGrapple(){}

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	local float RandomGroundSpeedScale;
	local float MovementSpeedDifficultyScale;
	local vector AttachPos;

	if(ROLE==ROLE_Authority)
	{
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);

		if ( Controller != None )
			Controller.Possess(self);

		SplashTime = 0;
		SpawnTime = Level.TimeSeconds;
		EyeHeight = BaseEyeHeight;
		OldRotYaw = Rotation.Yaw;
		if( HealthModifer!=0 )
			Health = HealthModifer;

		if ( bUseExtendedCollision && MyExtCollision == none )
		{
			MyExtCollision = Spawn(class 'ExtendedZCollision',self);
			MyExtCollision.SetCollisionSize(ColRadius,ColHeight);

			MyExtCollision.bHardAttach = true;
			AttachPos = Location + (ColOffset >> Rotation);
			MyExtCollision.SetLocation( AttachPos );
			MyExtCollision.SetPhysics( PHYS_None );
			MyExtCollision.SetBase( self );
			SavedExtCollision = MyExtCollision.bCollideActors;
		}

	}


	AssignInitialPose();
	// Let's randomly alter the position of our zombies' spines, to give their animations
	// the appearance of being somewhat unique.
	SetTimer(1.0, false);

	//Set Karma Ragdoll skeleton for this character.
	if (KFRagdollName != "")
		RagdollOverride = KFRagdollName; //ClotKarma
	//Log("Ragdoll Skeleton name is :"$RagdollOverride);

	if (bActorShadows && bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
	{
		// decide which type of shadow to spawn
		if (!bRealtimeShadows)
		{
			PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
			PlayerShadow.ShadowActor = self;
			PlayerShadow.bBlobShadow = bBlobShadow;
			PlayerShadow.LightDirection = Normal(vect(1,1,3));
			PlayerShadow.LightDistance = 320;
			PlayerShadow.MaxTraceDistance = 350;
			PlayerShadow.InitShadow();
		}
		else
		{
			RealtimeShadow = Spawn(class'Effect_ShadowController',self,'',Location);
			RealtimeShadow.Instigator = self;
			RealtimeShadow.Initialize();
		}
	}

	bSTUNNED = false;
	DECAP = false;

	// Difficulty Scaling
	if (Level.Game != none && !bDiffAdjusted)
	{
		//log(self$" Beginning ground speed "$default.GroundSpeed);

		if( Level.Game.NumPlayers <= 3 )
		{
			HiddenGroundSpeed = default.HiddenGroundSpeed;
		}
		else if( Level.Game.NumPlayers <= 5 )
		{
			HiddenGroundSpeed = default.HiddenGroundSpeed * 1.3;
		}
		else if( Level.Game.NumPlayers >= 6 )
		{
			HiddenGroundSpeed = default.HiddenGroundSpeed * 1.65;
		}

		// Some randomization to their walk speeds.
		RandomGroundSpeedScale = 1.0 + ((1.0 - (FRand() * 2.0)) * 0.1); // +/- 10%
		SetGroundSpeed(default.GroundSpeed * RandomGroundSpeedScale);
		//log(self$" Randomized ground speed "$GroundSpeed$" RandomGroundSpeedScale "$RandomGroundSpeedScale);

		if( Level.Game.GameDifficulty < 2.0 )
		{
			MovementSpeedDifficultyScale = 0.95;
		}
		else if( Level.Game.GameDifficulty < 4.0 )
		{
			MovementSpeedDifficultyScale = 1.0;
		}
		else if( Level.Game.GameDifficulty < 5.0 )
		{
			MovementSpeedDifficultyScale = 1.15;
		}
		else if( Level.Game.GameDifficulty < 7.0 )
		{
			MovementSpeedDifficultyScale = 1.22;
		}
		else // Hardest difficulty
		{
			MovementSpeedDifficultyScale = 1.3;
		}

		GroundSpeed *= MovementSpeedDifficultyScale;
		AirSpeed *= MovementSpeedDifficultyScale;
		WaterSpeed *= MovementSpeedDifficultyScale;
		// Store the difficulty adjusted ground speed to restore if we change it elsewhere
		OriginalGroundSpeed = GroundSpeed;

		//log(self$" Scaled ground speed "$GroundSpeed$" Difficulty "$Level.Game.GameDifficulty$" MovementSpeedDifficultyScale "$MovementSpeedDifficultyScale);

		// Scale health by difficulty
		Health *= DifficultyHealthModifer();
		HealthMax *= DifficultyHealthModifer();
		HeadHealth *= DifficultyHeadHealthModifer();

		// Scale health by number of players
		Health *= NumPlayersHealthModifer();
		HealthMax *= NumPlayersHealthModifer();
		HeadHealth *= NumPlayersHeadHealthModifer();

		MeleeDamage = Max((DifficultyDamageModifer() * MeleeDamage),1);

		SpinDamConst = Max((DifficultyDamageModifer() * SpinDamConst),1);
		SpinDamRand = Max((DifficultyDamageModifer() * SpinDamRand),1);

		ScreamDamage = Max((DifficultyDamageModifer() * ScreamDamage),1);

		bDiffAdjusted = true;
	}

	if( Level.NetMode!=NM_DedicatedServer )
	{
		AdditionalWalkAnims[AdditionalWalkAnims.length] = default.MovementAnims[0];
		MovementAnims[0] = AdditionalWalkAnims[Rand(AdditionalWalkAnims.length)];
	}
}

// Accessor for GroundSpeed so we can track what is setting it
simulated function SetGroundSpeed(float NewGroundSpeed)
{
    GroundSpeed = NewGroundSpeed;
}

// Scales the damage this Zed deals by the difficulty level
function float DifficultyDamageModifer()
{
	local float AdjustedDamageModifier;

	if ( Level.Game.GameDifficulty >= 7.0 ) // Hell on Earth
	{
		AdjustedDamageModifier = 1.75;
	}
	else if ( Level.Game.GameDifficulty >= 5.0 ) // Suicidal
	{
		AdjustedDamageModifier = 1.50;
	}
	else if ( Level.Game.GameDifficulty >= 4.0 ) // Hard
	{
		AdjustedDamageModifier = 1.25;
	}
	else if ( Level.Game.GameDifficulty >= 2.0 ) // Normal
	{
		AdjustedDamageModifier = 1.0;
	}
	else //if ( GameDifficulty == 1.0 ) // Beginner
	{
		AdjustedDamageModifier = 0.3;
	}

	// Do less damage if we're alone
	if( Level.Game.NumPlayers == 1 )
	{
		AdjustedDamageModifier *= 0.75;
	}

	return AdjustedDamageModifier;
}

// Scales the health this Zed has by the difficulty level
function float DifficultyHealthModifer()
{
	local float AdjustedModifier;

	if ( Level.Game.GameDifficulty >= 7.0 ) // Hell on Earth
	{
		AdjustedModifier = 1.75;
	}
	else if ( Level.Game.GameDifficulty >= 5.0 ) // Suicidal
	{
		AdjustedModifier = 1.55;
	}
	else if ( Level.Game.GameDifficulty >= 4.0 ) // Hard
	{
		AdjustedModifier = 1.35;
	}
	else if ( Level.Game.GameDifficulty >= 2.0 ) // Normal
	{
		AdjustedModifier = 1.0;
	}
	else //if ( GameDifficulty == 1.0 ) // Beginner
	{
		AdjustedModifier = 0.5;
	}

	return AdjustedModifier;
}

// Scales the health this Zed has by number of players
function float NumPlayersHealthModifer()
{
	local float AdjustedModifier;
	local int NumEnemies;
	local Controller C;

	AdjustedModifier = 1.0;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0 )
		{
			NumEnemies++;
		}
	}

	if( NumEnemies > 1 )
	{
		AdjustedModifier += (NumEnemies - 1) * PlayerCountHealthScale;
	}

	return AdjustedModifier;
}

// Scales the head health this Zed has by the difficulty level
function float DifficultyHeadHealthModifer()
{
	local float AdjustedModifier;

	if ( Level.Game.GameDifficulty >= 7.0 ) // Hell on Earth
	{
		AdjustedModifier = 1.75;
	}
	else if ( Level.Game.GameDifficulty >= 5.0 ) // Suicidal
	{
		AdjustedModifier = 1.55;
	}
	else if ( Level.Game.GameDifficulty >= 4.0 ) // Hard
	{
		AdjustedModifier = 1.35;
	}
	else if ( Level.Game.GameDifficulty >= 2.0 ) // Normal
	{
		AdjustedModifier = 1.0;
	}
	else //if ( GameDifficulty == 1.0 ) // Beginner
	{
		AdjustedModifier = 0.5;
	}

	return AdjustedModifier;
}

// Scales the head health this Zed has by number of players
function float NumPlayersHeadHealthModifer()
{
	local float AdjustedModifier;
	local int NumEnemies;
	local Controller C;

	AdjustedModifier = 1.0;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0 )
		{
			NumEnemies++;
		}
	}

	if( NumEnemies > 1 )
	{
		AdjustedModifier += (NumEnemies - 1) * PlayerNumHeadHealthScale;
	}

	return AdjustedModifier;
}

simulated function PostNetBeginPlay()
{
	EnableChannelNotify ( 1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	AnimBlendParams(1, 1.0, 0.0,, HeadBone);
	super(pawn).PostNetBeginPlay();
}

// This zed can dodge an incoming shot right now. Overriden in various states
// to prevent certain actions from being interrupted.
function bool CanGetOutOfWay()
{
	return true;
}

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local int i;
	local name  Sequence;
	local float Frame, Rate;

	Super.DisplayDebug(Canvas, YL, YPos);

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

	Canvas.DrawText("bShotAnim: "@bShotAnim);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
	if( bNewMindControlled )
	{
		NumZCDHits++;

		if( bNewMindControlled != bZedUnderControl )
		{
			SetGroundSpeed(OriginalGroundSpeed * 1.25);
			Health *= 1.25;
			HealthMax *= 1.25;
		}
	}
	else
	{
		NumZCDHits=0;
	}

	bZedUnderControl = bNewMindControlled;
}

// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
	GotoState('');
}

// Getter for the Original groundspeed of the zed (adjusted for difficulty, etc)
simulated function float GetOriginalGroundSpeed()
{
	if( bZedUnderControl )
	{
		return OriginalGroundSpeed * 1.25;
	}
	else
	{
		return OriginalGroundSpeed;
	}
}

//returns how exposed this player is to another actor
function float GetExposureTo(vector TestLocation)
{
	local float PercentExposed;

	if( FastTrace(GetBoneCoords(HeadBone).Origin,TestLocation))
	{
		PercentExposed += 0.4;
	}

	if( FastTrace(GetBoneCoords(RootBone).Origin,TestLocation))
	{
		PercentExposed += 0.3;
	}

	if( FastTrace(GetBoneCoords(LeftFootBone).Origin,TestLocation))
	{
		PercentExposed += 0.15;
	}

	if( FastTrace(GetBoneCoords(RightFootBone).Origin,TestLocation))
	{
		PercentExposed += 0.15;
	}

	return PercentExposed;
}

// Update the shadow if the detail settings have changed in the detail menu
simulated function UpdateShadow()
{
	if (bActorShadows && bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
	{
		if (PlayerShadow != none)
			PlayerShadow.Destroy();

		if (RealtimeShadow != none)
			RealtimeShadow.Destroy();

		// decide which type of shadow to spawn
		if (!bRealtimeShadows)
		{
			PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
			PlayerShadow.ShadowActor = self;
			PlayerShadow.bBlobShadow = bBlobShadow;
			PlayerShadow.LightDirection = Normal(vect(1,1,3));
			PlayerShadow.LightDistance = 320;
			PlayerShadow.MaxTraceDistance = 350;
			PlayerShadow.InitShadow();
		}
		else
		{
			RealtimeShadow = Spawn(class'Effect_ShadowController',self,'',Location);
			RealtimeShadow.Instigator = self;
			RealtimeShadow.Initialize();
		}
	}
	else if (PlayerShadow != none && Level.NetMode != NM_DedicatedServer)
	{
		PlayerShadow.Destroy();
		PlayerShadow = none;
	}
	else if (RealtimeShadow != none && Level.NetMode != NM_DedicatedServer)
	{
		RealtimeShadow.Destroy();
		RealtimeShadow = none;
	}
}

// Setters for extra collision cylinders
simulated function ToggleAuxCollision(bool newbCollision)
{
	if ( !newbCollision )
	{
		SavedExtCollision = MyExtCollision.bCollideActors;

		MyExtCollision.SetCollision(false);
	}
	else
	{
		MyExtCollision.SetCollision(SavedExtCollision);
	}
}

function bool MakeGrandEntry()
{
	Return False;
}

function bool Cloaked()
{
	return bCloaked;
}

// move karma objects by a kick
// The Kick animation will ONLY be called if the Zombie is On level ground with the KActor,
// and is facing it.
event Bump(actor Other)
{
	local Vector X,Y,Z;

	GetAxes(Rotation, X,Y,Z);

	super.Bump(Other);
	if( Other==none )
		return;

	if( Other.IsA('NetKActor') && Physics != PHYS_Falling && Location.Z < Other.Location.Z + CollisionHeight
	 && Location.Z > Other.Location.Z - (CollisionHeight * 0.5) && Base!=Other && Base.bStatic
	 && normal(X) dot normal(Other.Location - Location) >= 0.7)
	{
		if( KActor(Other).KGetMass()>=0.5 && !MonsterController(Controller).CanAttack(Controller.Enemy) )
		{
			// Store kick impact data

			ImpactVector = Vector(controller.Rotation)*15000 + (velocity * (Mass / 2) )  ;   // 30
			KickLocation = Other.Location;
			KickTarget = Other;
			KFMonsterController(Controller).KickTarget = KActor(Other);
			SetAnimAction(PuntAnim);
		}
	}
}

// No more File cabinet surfing zombies please..
singular event BaseChange()
{
	if ( KActor(Base) != None || Pawn(Base) != None )
	{
		JumpOffPawn();
	}
}

function JumpOffPawn()
{
	Velocity += (50 + CollisionRadius) * VRand();
	Velocity.Z = 80 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	if ( Controller != None )
	{
		Controller.SetFall();
	}
}

event PickWallAdjustInLowGravity( vector WallHitNormal, actor HitActor )
{
	//Controller.SetFall();
}

// Actually execute the kick (this is notified in the ZombieKick animation)
function KickActor()
{
	KickTarget.Velocity.Z += (Mass * 5 + (KGetMass() * 10));
	KickTarget.KAddImpulse(ImpactVector, KickLocation);
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	KFMonsterController(controller).GotoState('Kicking');
	bShotAnim = true;
}

simulated function bool IsMoreThanHalf ( int AngleRot )
{
	if ( AngleRot > 32768 )
	{
		return True;
	}
	else
	{
		return False;
	}
}

// Return true if we can do the Zombie speed adjust that gets the Zeds
// to the player faster if they can't be seen
function bool CanSpeedAdjust()
{
	if ( !bDecapitated && !bZapped )
	{
		return true;
	}

	return false;
}

simulated function Tick(float DeltaTime)
{
	local PlayerController P;
	local float DistSquared;

//    if(Level.NetMode == NM_DedicatedServer)
//    {
//        IsHeadShot(vect(0,0,0), vect(0,0,0), 1.0);
//    }

    // If we've flagged this character to be destroyed next tick, handle that
    if( bDestroyNextTick && TimeSetDestroyNextTickTime < Level.TimeSeconds )
    {
        Destroy();
    }

	// Make Zeds move faster if they aren't net relevant, or noone has seen them
	// in a while. This well get the Zeds to the player in larger groups, and
	// quicker - Ramm
	if ( Level.NetMode != NM_Client && CanSpeedAdjust() )
	{
		if ( Level.NetMode == NM_Standalone )
		{
			if ( Level.TimeSeconds - LastRenderTime > 5.0 )
			{
				P = Level.GetLocalPlayerController();

				if ( P != none && P.Pawn != none )
				{
					if ( Level.TimeSeconds - LastViewCheckTime > 1.0 )
					{
						LastViewCheckTime = Level.TimeSeconds;
						DistSquared = VSizeSquared(P.Pawn.Location - Location);
						if( (!P.Pawn.Region.Zone.bDistanceFog || (DistSquared < Square(P.Pawn.Region.Zone.DistanceFogEnd))) &&
							FastTrace(Location + EyePosition(), P.Pawn.Location + P.Pawn.EyePosition()) )
						{
							LastSeenOrRelevantTime = Level.TimeSeconds;
							SetGroundSpeed(GetOriginalGroundSpeed());
						}
						else
						{
							SetGroundSpeed(default.GroundSpeed * (HiddenGroundSpeed / default.GroundSpeed));
						}
					}
				}
			}
			else
			{
				LastSeenOrRelevantTime = Level.TimeSeconds;
				SetGroundSpeed(GetOriginalGroundSpeed());
			}
		}
		else if ( Level.NetMode == NM_DedicatedServer )
		{
			if ( Level.TimeSeconds - LastReplicateTime > 0.5 )
			{
				SetGroundSpeed(default.GroundSpeed * (300.0 / default.GroundSpeed));
			}
			else
			{
				LastSeenOrRelevantTime = Level.TimeSeconds;
				SetGroundSpeed(GetOriginalGroundSpeed());
			}
		}
		else if ( Level.NetMode == NM_ListenServer )
		{
			if ( Level.TimeSeconds - LastReplicateTime > 0.5 && Level.TimeSeconds - LastRenderTime > 5.0 )
			{
				P = Level.GetLocalPlayerController();

				if ( P != none && P.Pawn != none )
				{
					if ( Level.TimeSeconds - LastViewCheckTime > 1.0 )
					{
						LastViewCheckTime = Level.TimeSeconds;
						DistSquared = VSizeSquared(P.Pawn.Location - Location);

						if ( (!P.Pawn.Region.Zone.bDistanceFog || (DistSquared < Square(P.Pawn.Region.Zone.DistanceFogEnd))) &&
							FastTrace(Location + EyePosition(), P.Pawn.Location + P.Pawn.EyePosition()) )
						{
							LastSeenOrRelevantTime = Level.TimeSeconds;
							SetGroundSpeed(GetOriginalGroundSpeed());
						}
						else
						{
							SetGroundSpeed(default.GroundSpeed * (300.0 / default.GroundSpeed));
						}
					}
				}
			}
			else
			{
				LastSeenOrRelevantTime = Level.TimeSeconds;
				SetGroundSpeed(GetOriginalGroundSpeed());
			}
		}
	}

	if ( bResetAnimAct && ResetAnimActTime<Level.TimeSeconds )
	{
		AnimAction = '';
		bResetAnimAct = False;
	}

	if ( Controller != None )
	{
		LookTarget = Controller.Enemy;
	}

	// If the Zed has been bleeding long enough, make it die
	if ( Role == ROLE_Authority && bDecapitated )
	{
		if ( BleedOutTime > 0 && Level.TimeSeconds - BleedOutTime >= 0 )
		{
			Died(LastDamagedBy.Controller,class'DamTypeBleedOut',Location);
			BleedOutTime=0;
		}

	}

	//SPLATTER!!!!!!!!!
	//TODO - can we work this into Epic's gib code?
	//Will we see enough improvement in efficiency to be worth the effort?
	if ( Level.NetMode!=NM_DedicatedServer )
	{
		TickFX(DeltaTime);

		if ( bBurnified && !bBurnApplied )
		{
			if ( !bGibbed )
			{
				StartBurnFX();
			}
		}
		else if ( !bBurnified && bBurnApplied )
		{
			StopBurnFX();
		}

		if ( bAshen && Level.NetMode == NM_Client && !class'GameInfo'.static.UseLowGore() )
		{
			ZombieCrispUp();
			bAshen = False;
		}
	}

	if ( DECAP )
	{
		if ( Level.TimeSeconds > (DecapTime + 2.0) && Controller != none )
		{
			DECAP = false;
			MonsterController(Controller).ExecuteWhatToDoNext();
		}
	}

	if ( BileCount > 0 && NextBileTime<level.TimeSeconds )
	{
		--BileCount;
		NextBileTime+=BileFrequency;
		TakeBileDamage();
	}

    if( bZapped && Role == ROLE_Authority )
    {
        RemainingZap -= DeltaTime;

        if( RemainingZap <= 0 )
        {
            RemainingZap = 0;
            bZapped = False;
            ZappedBy = none;
            // The Zed can take more zap each time they get zapped
            ZapThreshold *= ZapResistanceScale;
        }
    }

    if( !bZapped && TotalZap > 0 && ((Level.TimeSeconds - LastZapTime) > 0.1)  )
    {
        TotalZap -= DeltaTime;
    }

    if( bZapped != bOldZapped )
    {
        if( bZapped )
        {
            SetZappedBehavior();
        }
        else
        {
            UnSetZappedBehavior();
        }

        bOldZapped = bZapped;
    }

    if( bHarpoonStunned != bOldHarpoonStunned )
    {
        if( bHarpoonStunned )
        {
            SetBurningBehavior();
        }
        else
        {
            UnSetBurningBehavior();
        }

        bOldHarpoonStunned = bHarpoonStunned;
    }
}

// Apply "Zap" to the Zed
function SetZapped(float ZapAmount, Pawn Instigator)
{
    LastZapTime = Level.TimeSeconds;

    if( bZapped )
    {
        TotalZap = ZapThreshold;
        RemainingZap = ZapDuration;
        SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', RemainingZap, true);
    }
    else
    {
        TotalZap += ZapAmount;

        if( TotalZap >= ZapThreshold )
        {
            RemainingZap = ZapDuration;
            SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', RemainingZap, true);
            bZapped = true;
        }
    }
    ZappedBy = Instigator;
}

// Set the zed to the zapped behavior
simulated function SetZappedBehavior()
{
	if( Role == Role_Authority )
	{
		Intelligence = BRAINS_Retarded; // burning dumbasses!

		SetGroundSpeed(OriginalGroundSpeed * ZappedSpeedMod);
		AirSpeed *= ZappedSpeedMod;
		WaterSpeed *= ZappedSpeedMod;

		// Make them less accurate while they are burning
		if( Controller != none )
		{
		   MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's burning now, after all) :-D
		}
	}

	// Set the forward movement anim to a random burning anim
	MovementAnims[0] = BurningWalkFAnims[Rand(3)];
	WalkAnims[0]     = BurningWalkFAnims[Rand(3)];

	// Set the rest of the movement anims to the headless anim (not sure if these ever even get played) - Ramm
	MovementAnims[1] = BurningWalkAnims[0];
	WalkAnims[1]     = BurningWalkAnims[0];
	MovementAnims[2] = BurningWalkAnims[1];
	WalkAnims[2]     = BurningWalkAnims[1];
	MovementAnims[3] = BurningWalkAnims[2];
	WalkAnims[3]     = BurningWalkAnims[2];
}

// Turn off the on-fire behavior
simulated function UnSetZappedBehavior()
{
	local int i;

	if ( Role == Role_Authority )
	{
		Intelligence = default.Intelligence;

		if( bBurnified )
		{
            SetGroundSpeed(GetOriginalGroundSpeed() * 0.80);
        }
        else
        {
            SetGroundSpeed(GetOriginalGroundSpeed());
        }
		AirSpeed = default.AirSpeed;
		WaterSpeed = default.WaterSpeed;

		// Set normal accuracy
		if ( Controller != none )
		{
		   MonsterController(Controller).Accuracy = MonsterController(Controller).default.Accuracy;
		}
	}

	// restore regular anims
	for ( i = 0; i < 4; i++ )
	{
		MovementAnims[i] = default.MovementAnims[i];
		WalkAnims[i]     = default.WalkAnims[i];
	}
}

function TakeBileDamage()
{
	Super.TakeDamage(2 + Rand(3), BileInstigator, Location, vect(0,0,0), LastBileDamagedByType);
}

simulated function StartBurnFX()
{
	local class<emitter> Effect;

    if( bDeleteMe )
    {
        return;
    }

	// No real flames when low gore, make them smoke, smoking kills
	if ( class'GameInfo'.static.UseLowGore() )
	{
		Effect = AltBurnEffect;
	}
	else
	{
		Effect = BurnEffect;
	}

	if ( FlamingFXs == None )
	{
		FlamingFXs = Spawn(Effect);
	}

	FlamingFXs.SetBase(Self);
	FlamingFXs.Emitters[0].SkeletalMeshActor = self;
	FlamingFXs.Emitters[0].UseSkeletalLocationAs = PTSU_SpawnOffset;
	AttachEmitterEffect(Effect, HeadBone, Location, Rotation);
	bBurnApplied = True;
}

simulated function StopBurnFX()
{
	UnSetBurningBehavior();
	RemoveFlamingEffects();

	if ( FlamingFXs != None )
	{
		FlamingFXs.Kill();
	}

	bBurnApplied = False;
}

// High damage was taken, make em fall over.
function bool FlipOver()
{
	if( Physics==PHYS_Falling )
	{
		SetPhysics(PHYS_Walking);
	}

	bShotAnim = true;
	SetAnimAction('KnockDown');
	Acceleration = vect(0, 0, 0);
	Velocity.X = 0;
	Velocity.Y = 0;
	Controller.GoToState('WaitForAnim');
	KFMonsterController(Controller).bUseFreezeHack = True;
	Return True;
}

function AddVelocity( vector NewVelocity)
{
	if( VSize(NewVelocity) > 50 )
	{
		Super.AddVelocity(NewVelocity);
	}
}

// Important Block of code controlling how the Zombies (excluding the Bloat and Fleshpound who cannot be stunned, respond to damage from the
// various weapons in the game. The basic rule is that any damage amount equal to or greater than 40 points will cause a stun.
// There are exceptions with the fists however, which are substantially under the damage quota but can still cause stuns 50% of the time.
// Why? Cus if they didn't at least have that functionality, they would be fundamentally useless. And anyone willing to take on a hoarde of zombies
// with only the gloves on his hands, deserves more respect than that!

simulated function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	local int FistStrikeStunChance;

	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
		return;

	// No anim if we're burning, we're already playing an anim
	if ( !(bCrispified && bBurnified) /*DamageType.name != 'DamTypeBurned' &&  DamageType.name != 'DamTypeFlamethrower'*/ )
	{
		if( Damage>=5 )
			PlayDirectionalHit(HitLocation);
		else if (DamageType.name == 'DamTypeShotgun' || DamageType.name == 'DamTypeDBShotgun'
		|| DamageType.name == 'DamTypeFrag' || DamageType.name == 'DamTypeAA12Shotgun'
		|| DamageType.name == 'DamTypePipeBomb' || DamageType.name == 'DamTypeM79Grenade'
		|| DamageType.name == 'DamTypeM32Grenade' || DamageType.name == 'DamTypeM203Grenade'
        || DamageType.name == 'DamTypeBenelli' || DamageType.name == 'DamTypeKSGShotgun'
        || DamageType.name == 'DamTypeTrenchgun' || DamageType.name == 'DamTypeNailgun'
        || DamageType.name == 'DamTypeSPShotgun' || DamageType.name == 'DamTypeSPGrenade'
        || DamageType.name == 'DamTypeSealSquealExplosion' || DamageType.name == 'DamTypeSeekerSixRocket')
			PlayDirectionalHit(HitLocation);
		else if (DamageType.name == 'DamTypeClaws')
		{
			FistStrikeStunChance = rand(10);
			if ( FistStrikeStunChance > 5 )
				PlayDirectionalHit(HitLocation);
		}
		else if (DamageType.name == 'DamTypeKnife')
		{
			FistStrikeStunChance = rand(10);
			if ( FistStrikeStunChance > 7 )
				PlayDirectionalHit(HitLocation);
		}
		else if (DamageType.name == 'DamTypeChainsaw')
			PlayDirectionalHit(HitLocation);
		else if (DamageType.name == 'DamTypeStunNade')
			PlayDirectionalHit(HitLocation);
		else if (DamageType.name == 'DamTypeCrossbowHeadshot' || DamageType.name == 'DamTypeCrossbuzzsaw'
            || DamageType.name == 'DamTypeCrossbowHeadShot' )
			PlayDirectionalHit(HitLocation);
		LastPainAnim = Level.TimeSeconds;
	}

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;

	if ( class<DamTypeBurned>(DamageType) == none && class<DamTypeFlamethrower>(DamageType) == none )
	{
		PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
	}
}

simulated function DoDerezEffect(); // fuck no!

simulated function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r )
{
	local float DismemberProbability;
	local int RandBone;
	local bool bDidSever;

	//log("DamageFX bonename = "$boneName$" "$Level.TimeSeconds$" Damage "$Damage);

	if( bDecapitated && !bPlayBrainSplash )
	{
        if( class<DamTypeMelee>(DamageType) != none )
		{
			 HitFX[HitFxTicker].damtype = class'DamTypeMeleeDecapitation';
		}
		else if( class<DamTypeNailGun>(DamageType) != none )
		{
        	HitFX[HitFxTicker].damtype = class'DamTypeProjectileDecap';
        }
		else
		{
			HitFX[HitFxTicker].damtype = class'DamTypeDecapitation';
		}

		if ( DamageType.default.bNeverSevers || class'GameInfo'.static.UseLowGore()
			|| (Level.Game != none && Level.Game.PreventSever(self, boneName, Damage, DamageType)) )
		{
			HitFX[HitFxTicker].bSever = false;
		}
		else
		{
			HitFX[HitFxTicker].bSever = true;
		}

		HitFX[HitFxTicker].bone = HeadBone;
		HitFX[HitFxTicker].rotDir = r;
		HitFxTicker = HitFxTicker + 1;
		if( HitFxTicker > ArrayCount(HitFX)-1 )
			HitFxTicker = 0;

		bPlayBrainSplash = true;

        if( Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 )
		{
		  // Do nothing
		}
		else
		{
		  return;
		}
	}

	if ( FRand() > 0.3f || Damage > 30 || Health <= 0 /*|| DamageType == class 'DamTypeCrossbowHeadshot'*/)
	{
		HitFX[HitFxTicker].damtype = DamageType;

		if( Health <= 0 /*|| DamageType == class 'DamTypeCrossbowHeadshot'*/)
		{
			switch( boneName )
			{
				case 'neck':
					boneName = HeadBone;
					break;

				case LeftFootBone:
				case 'lleg':
					boneName = LeftThighBone;
					break;

				case RightFootBone:
				case 'rleg':
					boneName = RightThighBone;
					break;

				case RightHandBone:
				case RightShoulderBone:
				case 'rarm':
					boneName = RightFArmBone;
					break;

				case LeftHandBone:
				case LeftShoulderBone:
				case 'larm':
					boneName = LeftFArmBone;
					break;

				case 'None':
				case 'spine':
					boneName = FireRootBone;
					break;
			}

			if( DamageType.default.bAlwaysSevers || (Damage == 1000) )
			{
				HitFX[HitFxTicker].bSever = true;
				bDidSever = true;
				if ( boneName == 'None' )
				{
					boneName = FireRootBone;
				}
			}
			else if( DamageType.Default.GibModifier > 0.0 )
			{
	            DismemberProbability = Abs( (Health - Damage*DamageType.Default.GibModifier) / 130.0f );

				if( FRand() < DismemberProbability )
				{
					HitFX[HitFxTicker].bSever = true;
					bDidSever = true;
				}
			}
		}

		if ( DamageType.default.bNeverSevers || class'GameInfo'.static.UseLowGore()
			|| (Level.Game != none && Level.Game.PreventSever(self, boneName, Damage, DamageType)) )
		{
			HitFX[HitFxTicker].bSever = false;
			bDidSever = false;
		}

		if ( HitFX[HitFxTicker].bSever )
		{
	        if( !DamageType.default.bLocationalHit && (boneName == 'None' || boneName == FireRootBone ||
				boneName == 'Spine' ))
	        {
	        	RandBone = Rand(4);

				switch( RandBone )
	            {
	                case 0:
						boneName = LeftThighBone;
						break;
	                case 1:
						boneName = RightThighBone;
						break;
	                case 2:
						boneName = LeftFArmBone;
	                    break;
	                case 3:
						boneName = RightFArmBone;
	                    break;
	                case 4:
						boneName = HeadBone;
	                    break;
	                default:
	                	boneName = LeftThighBone;
	            }
	        }
		}

		if ( Health < 0 && Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 && !class'GameInfo'.static.UseLowGore() )
		{
			boneName = 'obliterate';
		}

		HitFX[HitFxTicker].bone = boneName;
		HitFX[HitFxTicker].rotDir = r;
		HitFxTicker = HitFxTicker + 1;
		if( HitFxTicker > ArrayCount(HitFX)-1 )
			HitFxTicker = 0;

		// If this was a really hardcore damage from an explosion, randomly spawn some arms and legs
		if ( bDidSever && !DamageType.default.bLocationalHit && Damage > 200 && Damage != 1000 && !class'GameInfo'.static.UseLowGore() )
		{
			if ((Damage > 400 && FRand() < 0.3) || FRand() < 0.1 )
			{
				DoDamageFX(HeadBone,1000,DamageType,r);
				DoDamageFX(LeftThighBone,1000,DamageType,r);
				DoDamageFX(RightThighBone,1000,DamageType,r);
				DoDamageFX(LeftFArmBone,1000,DamageType,r);
				DoDamageFX(RightFArmBone,1000,DamageType,r);
			}
			if ( FRand() < 0.25 )
			{
				DoDamageFX(LeftThighBone,1000,DamageType,r);
				DoDamageFX(RightThighBone,1000,DamageType,r);
				if ( FRand() < 0.5 )
				{
					DoDamageFX(LeftFArmBone,1000,DamageType,r);
				}
				else
				{
					DoDamageFX(RightFArmBone,1000,DamageType,r);
				}
			}
			else if ( FRand() < 0.35 )
				DoDamageFX(LeftThighBone,1000,DamageType,r);
			else if ( FRand() < 0.5 )
				DoDamageFX(RightThighBone,1000,DamageType,r);
			else if ( FRand() < 0.75 )
			{
				if ( FRand() < 0.5 )
				{
					DoDamageFX(LeftFArmBone,1000,DamageType,r);
				}
				else
				{
					DoDamageFX(RightFArmBone,1000,DamageType,r);
				}
			}
		}
	}
}

// Overriden to allow for specifying velocities for the gibs
simulated function KFSpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation, optional float GibVelocity )
{
	local Gib Giblet;
	local Vector Direction, Dummy;

	if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
		return;

	Instigator = self;
	Giblet = Spawn( GibClass,,, Location, Rotation );

	if( Giblet == None )
		return;

	Giblet.SetDrawScale(Giblet.DrawScale * (CollisionRadius*CollisionHeight)/1100); // 1100 = 25 * 44
	GibPerterbation *= 32768.0;
	Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

	GetAxes( Rotation, Dummy, Dummy, Direction );

	if( GibVelocity > 0 )
	{
		Giblet.Velocity = Velocity + Normal(Direction) * (GibVelocity + (GibVelocity * (FRand() * 0.25)));
	}
	else
	{
		Giblet.Velocity = Velocity + Normal(Direction) * 512;
	}
}

//Stops the green shit when a player dies.
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local float frame, rate;
	local name seq;
	local LavaDeath LD;
	local MiscEmmiter BE;

	AmbientSound = None;
	bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	StopBurnFX();

	if (CurrentCombo != None)
		CurrentCombo.Destroy();

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	bSTUNNED = false;
	bMovable = true;

	if ( class<DamTypeBurned>(DamageType) != none || class<DamTypeFlamethrower>(DamageType) != none )
	{
		ZombieCrispUp();
	}

	ProcessHitFX() ;

	if ( DamageType != None )
	{
		if ( DamageType.default.bSkeletize )
		{
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 4.0, true);
			if (!bSkeletized)
			{
				if ( (Level.NetMode != NM_DedicatedServer) && (SkeletonMesh != None) )
				{
					if ( DamageType.default.bLeaveBodyEffect )
					{
						BE = spawn(class'MiscEmmiter',self);
						if ( BE != None )
						{
							BE.DamageType = DamageType;
							BE.HitLoc = HitLoc;
							bFrozenBody = true;
						}
					}
					GetAnimParams( 0, seq, frame, rate );
					LinkMesh(SkeletonMesh, true);
					Skins.Length = 0;
					PlayAnim(seq, 0, 0);
					SetAnimFrame(frame);
				}
				if (Physics == PHYS_Walking)
					Velocity = Vect(0,0,0);
				SetTearOffMomemtum(GetTearOffMomemtum() * 0.25);
				bSkeletized = true;
				if ( (Level.NetMode != NM_DedicatedServer) && (DamageType == class'FellLava') )
				{
					LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
					if ( LD != None )
						LD.SetBase(self);
					//PlaySound( sound'WeaponSounds.BExplosion5', SLOT_None, 1.5*TransientSoundVolume );
				}
			}
		}
		else if ( DamageType.Default.DeathOverlayMaterial != None )
			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
		else if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 2*DamageType.default.DamageOverlayTime, true);
	}

	// stop shooting
	AnimBlendParams(1, 0.0);
	FireState = FS_None;

	// Try to adjust around performance
	//log(Level.DetailMode);

	LifeSpan = RagdollLifeSpan;

	GotoState('ZombieDying');
	if ( BE != None )
		return;
	PlayDyingAnimation(DamageType, HitLoc);
}


State ZombieDying extends Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack;     //Tick

	function bool CanGetOutOfWay()
	{
		return false;
	}

	simulated function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		if( !bDestroyNextTick )
		{
            Disable('Tick');
		}
	}

	simulated function Timer()
	{
        local KarmaParamsSkel skelParams;

        if( bDestroyNextTick )
        {
            // If we've flagged this character to be destroyed next tick, handle that
            if( TimeSetDestroyNextTickTime < Level.TimeSeconds )
            {
                Destroy();
            }
            else
            {
                SetTimer(0.01, false);
            }

            return;
        }

		if ( !PlayerCanSeeMe() )
		{
			StartDeRes();
			Destroy();
		}
		// If we are running out of life, but we still haven't come to rest, force the de-res.
		// unless pawn is the viewtarget of a player who used to own it
		else if ( LifeSpan <= DeResTime && bDeRes == false )
		{
			skelParams = KarmaParamsSkel(KParams);

			skelParams.bKImportantRagdoll = false;

			// spawn derez
			bDeRes=true;
		}
		else
		{
			SetTimer(1.0, false);
		}
	}

	simulated function BeginState()
	{
        if( bDestroyNextTick )
        {
            // If we've flagged this character to be destroyed next tick, handle that
            if( TimeSetDestroyNextTickTime < Level.TimeSeconds )
            {
                Destroy();
            }
            else
            {
                SetTimer(0.01, false);
            }
        }
        else
        {
            if ( bTearOff && (Level.NetMode == NM_DedicatedServer) || class'GameInfo'.static.UseLowGore() )
                LifeSpan = 1.0;
            else
                SetTimer(2.0, false);
		}

		SetPhysics(PHYS_Falling);
		if ( Controller != None )
		{
			Controller.Destroy();
		}
 	}

	simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex )
	{
		local Vector HitNormal, shotDir;
		local Vector PushLinVel, PushAngVel;
		local Name HitBone;
		local float HitBoneDist;
		local bool bIsHeadshot;
		local vector HitRay;

		if ( bFrozenBody || bRubbery )
			return;

		if( Physics == PHYS_KarmaRagdoll )
		{
			// Can't shoot corpses during de-res
			if ( bDeRes )
				return;

			// Throw the body if its a rocket explosion or shock combo
			if( damageType.Default.bThrowRagdoll )
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
		}

		if (Damage > 0)
		{
			Health -= Damage;

			if ( !bDecapitated && class<KFWeaponDamageType>(damageType)!=none &&
				class<KFWeaponDamageType>(damageType).default.bCheckForHeadShots )
			{
				bIsHeadShot = IsHeadShot(HitLocation, normal(Momentum), 1.0);
		    }

			if( bIsHeadShot )
				RemoveHead();

			HitRay = vect(0,0,0);
			if( InstigatedBy != none )
				HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));

			CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );

			if( InstigatedBy != None )
				HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
			else
				HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

			// Actually do blood on a client
			PlayHit(Damage, InstigatedBy, hitLocation, damageType, Momentum);

			DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
		}

		if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
	}
}

simulated function Timer()
{
	// bSTUNNED variable actually indicates flinching, not stunning! So don't get confused.
    bSTUNNED = false;

    // If burn tick count > 0, call TakeFireDamage() function.
    // Otherwise stop burning and turn off the timer
    if (BurnDown > 0)
	{
         // Every tick LastBurnDamage is increased by 3 + random value from 0 to 2 (excluding)
        TakeFireDamage(LastBurnDamage + rand(2) + 3 , LastDamagedBy);
		SetTimer(1.0,false); // Sets timer function to be executed each second
	}
    else
    {
        UnSetBurningBehavior();

        RemoveFlamingEffects();
        StopBurnFX();
        SetTimer(0, false);  // Disable timer
    }
}

simulated function ProcessHitFX()
{
	local Coords boneCoords;
	local class<xEmitter> HitEffects[4];
	local int i,j;
	local float GibPerterbation;

	if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh))
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
            SpawnGibs( HitFX[SimHitFxTicker].rotDir, 1);
			bGibbed = true;

			// Wait a tick on a listen server so the obliteration can replicate before the pawn is destroyed
            if( Level.NetMode == NM_ListenServer )
			{
                bDestroyNextTick = true;
                TimeSetDestroyNextTickTime = Level.TimeSeconds;
            }
            else
            {
                Destroy();
			}
			return;
		}

		boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

		if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore())
		{
			//AttachEmitterEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

			HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

			if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
			{
				for( i = 0; i < ArrayCount(HitEffects); i++ )
				{
					if( HitEffects[i] == None )
						continue;

					  AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
				}
			}
		}

		if ( class'GameInfo'.static.UseLowGore() )
		{
			HitFX[SimHitFxTicker].bSever = false;

			switch( HitFX[SimHitFxTicker].bone )
			{
				 case 'head':
					if( !bHeadGibbed )
					{
						if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
						}
						else if( HitFX[SimHitFxTicker].damtype == class'DamTypeProjectileDecap' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false, true);
						}
						else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
						}

					  	bHeadGibbed=true;
				  	}
					break;
			}
		}

		if( HitFX[SimHitFxTicker].bSever )
		{
			GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

			switch( HitFX[SimHitFxTicker].bone )
			{
				case 'obliterate':
					break;

				case LeftThighBone:
					if( !bLeftLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bLeftLegGibbed=true;
					}
					break;

				case RightThighBone:
					if( !bRightLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightLegGibbed=true;
					}
					break;

				case LeftFArmBone:
					if( !bLeftArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;;
	                    bLeftArmGibbed=true;
					}
					break;

				case RightFArmBone:
					if( !bRightArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
						KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
						KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightArmGibbed=true;
					}
					break;

				case 'head':
					if( !bHeadGibbed )
					{
						if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
						}
						else if( HitFX[SimHitFxTicker].damtype == class'DamTypeProjectileDecap' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false, true);
						}
						else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
						}

					  	bHeadGibbed=true;
				  	}
					break;
			}


			if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&
				HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
				HideBone(HitFX[SimHitFxTicker].bone);
		}
	}
}

// Handle doing the decapitation hit effects
simulated function DecapFX( Vector DecapLocation, Rotator DecapRotation, bool bSpawnDetachedHead, optional bool bNoBrainBits )
{
	local float GibPerterbation;
	local BrainSplash SplatExplosion;
	local int i;

	// Do the cute version of the Decapitation
	if ( class'GameInfo'.static.UseLowGore() )
	{
		CuteDecapFX();

		return;
	}

	bNoBrainBitEmitter = bNoBrainBits;

	GibPerterbation = 0.060000; // damageType.default.GibPerterbation;

	if(bSpawnDetachedHead)
	{
	   SpecialHideHead();
	}
	else
	{
		HideBone(HeadBone);
	}

	if( bSpawnDetachedHead )
	{
		SpawnSeveredGiblet( DetachedHeadClass, DecapLocation, DecapRotation, GibPerterbation, GetBoneRotation(HeadBone) );
	}

	// Plug in headless anims if we have them
	for( i = 0; i < 4; i++ )
	{
		if( HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i]) )
		{
			MovementAnims[i] = HeadlessWalkAnims[i];
			WalkAnims[i]     = HeadlessWalkAnims[i];
		}
	}

	if ( !bSpawnDetachedHead && !bNoBrainBits && EffectIsRelevant(DecapLocation,false) )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrain',DecapLocation, self.Rotation, GibPerterbation, 250 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',DecapLocation, self.Rotation, GibPerterbation, 250 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',DecapLocation, self.Rotation, GibPerterbation, 250 ) ;
	}
	SplatExplosion = Spawn(class 'BrainSplash',self,, DecapLocation );
}

// Handle hiding the head when its been melee chopped off
simulated function SpecialHideHead()
{
	local int BoneScaleSlot;
	local coords boneCoords;

	// Only scale the bone down once
	if( SeveredHead == none )
	{
		boneScaleSlot = 4;
		SeveredHead = Spawn(SeveredHeadAttachClass,self);
		SeveredHead.SetDrawScale(SeveredHeadAttachScale);
		boneCoords = GetBoneCoords( 'neck' );
		AttachEmitterEffect( NeckSpurtNoGibEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
		AttachToBone(SeveredHead, 'neck');
	}
	else
	{
		return;
	}

	SetBoneScale(BoneScaleSlot, 0.0, 'head');
}

simulated function CuteDecapFX()
{
	local int LeftRight;

	LeftRight = 1;

	if ( rand(10) > 5 )
	{
		LeftRight = -1;
	}

	NeckRot.Yaw = -clamp(rand(24000), 14000, 24000);
	NeckRot.Roll = LeftRight * clamp(rand(8000), 2000, 8000);
	NeckRot.Pitch =  LeftRight * clamp(rand(12000), 2000, 12000);

	SetBoneRotation('neck', NeckRot);

	RemoveHead();
}


simulated function SpawnSeveredGiblet( class<SeveredAppendage> GibClass, Vector Location, Rotator Rotation, float GibPerterbation, rotator SpawnRotation )
{
	local SeveredAppendage Giblet;
	local Vector Direction, Dummy;

	if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
		return;

	Instigator = self;
	Giblet = Spawn( GibClass,,, Location, SpawnRotation );
	if( Giblet == None )
		return;
	Giblet.SpawnTrail();

	GibPerterbation *= 32768.0;
	Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

	GetAxes( Rotation, Dummy, Dummy, Direction );

	Giblet.Velocity = Velocity + Normal(Direction) * (Giblet.MaxSpeed + (Giblet.MaxSpeed/2) * FRand());

	// Give a little upward motion to the decapitated head
	if( class<SeveredHead>(GibClass) != none )
	{
		Giblet.Velocity.Z += 50;
	}

	//Giblet.LifeSpan = self.RagdollLifeSpan;
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;
	local coords boneCoords;
	local bool bValidBoneToHide;

	if( boneName == LeftThighBone )
	{
		boneScaleSlot = 0;
		bValidBoneToHide = true;
		if( SeveredLeftLeg == none )
		{
			SeveredLeftLeg = Spawn(SeveredLegAttachClass,self);
			SeveredLeftLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'lleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'lleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredLeftLeg, 'lleg');
		}
	}
	else if ( boneName == RightThighBone )
	{
		boneScaleSlot = 1;
		bValidBoneToHide = true;
		if( SeveredRightLeg == none )
		{
			SeveredRightLeg = Spawn(SeveredLegAttachClass,self);
			SeveredRightLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'rleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightLeg, 'rleg');
		}
	}
	else if( boneName == RightFArmBone )
	{
		boneScaleSlot = 2;
		bValidBoneToHide = true;
		if( SeveredRightArm == none )
		{
			SeveredRightArm = Spawn(SeveredArmAttachClass,self);
			SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'rarm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightArm, 'rarm');
		}
	}
	else if ( boneName == LeftFArmBone )
	{
		boneScaleSlot = 3;
		bValidBoneToHide = true;
		if( SeveredLeftArm == none )
		{
			SeveredLeftArm = Spawn(SeveredArmAttachClass,self);
			SeveredLeftArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'larm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'larm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredLeftArm, 'larm');
		}
	}
	else if ( boneName == HeadBone )
	{
		// Only scale the bone down once
		if( SeveredHead == none )
		{
			bValidBoneToHide = true;
			boneScaleSlot = 4;
			SeveredHead = Spawn(SeveredHeadAttachClass,self);
			SeveredHead.SetDrawScale(SeveredHeadAttachScale);
			boneCoords = GetBoneCoords( 'neck' );
			if( bNoBrainBitEmitter )
			{
                AttachEmitterEffect( NeckSpurtNoGibEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
			}
			else
			{
                AttachEmitterEffect( NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
			}
			AttachToBone(SeveredHead, 'neck');
		}
		else
		{
			return;
		}
	}
	else if ( boneName == 'spine' )
	{
	    bValidBoneToHide = true;
		boneScaleSlot = 5;
	}

	// Only hide the bone if it is one of the arms, legs, or head, don't hide other misc bones
	if( bValidBoneToHide )
	{
		SetBoneScale(BoneScaleSlot, 0.0, BoneName);
	}
}

// Used to attach an emitter instead of an xemitter
simulated function AttachEmitterEffect( class<Emitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
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

// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	PlayDyingSound();

	if ( class'GameInfo'.static.UseLowGore() )
		return;

	if ( FlamingFXs != none )
	{
		FlamingFXs.Emitters[0].SkeletalMeshActor = none;
		FlamingFXs.Destroy();
	}

	if( ObliteratedEffectClass != none )
		Spawn( ObliteratedEffectClass,,, Location, HitRotation );

	super.SpawnGibs(HitRotation,ChunkPerterbation);

	if ( FRand() < 0.1 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;

		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );

		if ( DetachedSpecialArmClass != None )
		{
			SpawnSeveredGiblet( DetachedSpecialArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		}
		else
		{
			SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		}
	}
	else if ( FRand() < 0.25 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;

		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		if ( FRand() < 0.5 )
		{
			KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
			SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		}
	}
	else if ( FRand() < 0.35 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
	}
	else if ( FRand() < 0.5 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
	}
}


simulated function StartDeRes()
{
	if( Level.NetMode == NM_DedicatedServer )
		return;

	AmbientGlow=0;
	MaxLights=5;

	if( Physics == PHYS_KarmaRagdoll )
	{
		// Remove flames
		RemoveFlamingEffects();
		KSetBlockKarma(true);
		// Turn off any overlays
		SetOverlayMaterial(None, 0.0f, true);
		SetCollision(true, true, true);
	}
}

function bool CanAttack(Actor A)
{
	if (A == none)
		return false;
	if(bSTUNNED)
		return false;
	if(KFDoorMover(A)!=none)
		return true;
	else if(KFHumanPawn(A)!=none && KFHumanPawn(A).Health <= 0)
		return ( VSize(A.Location - Location) < MeleeRange + CollisionRadius);
	else return ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius );
}

function DoorAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( A!=None )
	{
		bShotAnim = true;

		SetAnimAction('DoorBash');
		GotoState('DoorBashing');
		//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		return;
	}
}

function CorpseAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	Velocity.X = 0;
	Velocity.Y = 0;
	Acceleration = vect(0,0,0);
	bShotAnim = true;
	SetAnimAction('ZombieFeed');
	Health+=(1+Rand(3));
	Health = Min(Health,Default.Health*1.5);
}
function RangedAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		return;
	}
}
simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;

	if( NewAction=='' )
		Return;
	if(NewAction == 'Claw')
	{
		meleeAnimIndex = Rand(3);
		NewAction = meleeAnims[meleeAnimIndex];
		CurrentDamtype = ZombieDamType[meleeAnimIndex];
	}
	else if( NewAction == 'DoorBash' )
	{
	   CurrentDamtype = ZombieDamType[Rand(3)];
	}

	ExpectingChannel = DoAnimAction(NewAction);

	if( AnimNeedsWait(NewAction) )
	{
		bWaitForAnim = true;
	}
	else
	{
		bWaitForAnim = false;
	}

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;
		ResetAnimActTime = Level.TimeSeconds+0.3;
	}
}

simulated function bool AnimNeedsWait(name TestAnim)
{
	if( ExpectingChannel == 0 )
	{
		return true;
	}

	return false;
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='HitF' || AnimName=='HitF2' || AnimName=='HitF3' || AnimName==KFHitFront || AnimName==KFHitBack || AnimName==KFHitRight
	 || AnimName==KFHitLeft )
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,, 0.1, 1);
		return 1;
	}

	PlayAnim(AnimName,,0.1);
	return 0;
}

simulated function AnimEnd(int Channel)
{
/*	local name  Sequence;
	local float Frame, Rate;


	GetAnimParams( ExpectingChannel, Sequence, Frame, Rate );

	log(Level.TimeSeconds$" "$self$" "$GetStateName()$" AnimEnd for Exp Chan "$ExpectingChannel$" = "$Sequence$" Channel: "$Channel);

	GetAnimParams( 0, Sequence, Frame, Rate );
	log(self$" "$GetStateName()$" AnimEnd for Chan 0 = "$Sequence);

	GetAnimParams( 1, Sequence, Frame, Rate );
	log(self$" "$GetStateName()$" AnimEnd for Chan 1 = "$Sequence);

	log(self$" "$GetStateName()$" AnimEnd bShotAnim = "$bShotAnim);*/


	AnimAction = '';
	if ( bShotAnim && Channel==ExpectingChannel )
	{
		bShotAnim = false;
		if( Controller!=None )
			Controller.bPreparingMove = false;
	}
	if( !bPhysicsAnimUpdate && Channel==0 )
		bPhysicsAnimUpdate = Default.bPhysicsAnimUpdate;
	Super(xPawn).AnimEnd(Channel);
}

simulated function HandleBumpGlass()
{
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);

	SetAnimAction(MeleeAnims[0]);
	bShotAnim = true;
	controller.GotoState('WaitForAnim');
}

simulated function StoodUp();
simulated function FellDown();

function ClawDamageTarget()
{
	local vector PushDir;
	local float UsedMeleeDamage;

	if( MeleeDamage > 1 )
	{
	   UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
	}
	else
	{
	   UsedMeleeDamage = MeleeDamage;
	}

	if(Controller!=none && Controller.Target!=none)
		PushDir = (damageForce * Normal(Controller.Target.Location - Location));
	else PushDir = damageForce * vector(Rotation);
	// Melee damage is +/- 10% of default
	if ( MeleeDamageTarget(UsedMeleeDamage, PushDir) )
	{
		PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);
	}
}

function ZombieMoan() // Moved from Controller to here (so we don't need an own controller for each moan type).
{
	PlaySound(MoanVoice, SLOT_Misc, MoanVolume,,250.0);
}

function RemoveHead()
{
	local int i;

	Intelligence = BRAINS_Retarded; // Headless dumbasses!

	bDecapitated  = true;
	DECAP = true;
	DecapTime = Level.TimeSeconds;

	Velocity = vect(0,0,0);
	SetAnimAction('HitF');
	SetGroundSpeed(GroundSpeed *= 0.80);
	AirSpeed *= 0.8;
	WaterSpeed *= 0.8;

	// No more raspy breathin'...cuz he has no throat or mouth :S
	AmbientSound = MiscSound;

	//TODO - do we need to inform the controller that we can't move owing to lack of head,
	//	   or is that handled elsewhere
	if ( Controller != none )
	{
		MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's headless now, after all) :-D
	}

	// Head explodes, causing additional hurty.
	if( KFPawn(LastDamagedBy)!=None )
	{
		TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

		if ( BurnDown > 0 )
		{
			KFSteamStatsAndAchievements(KFPawn(LastDamagedBy).PlayerReplicationInfo.SteamStatsAndAchievements).AddBurningDecapKill(class'KFGameType'.static.GetCurrentMapName(Level));
		}
	}

	if( Health > 0 )
	{
		BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
	}

	//TODO - Find right place for this
	// He's got no head so biting is out.
	if (MeleeAnims[2] == 'Claw3')
		MeleeAnims[2] = 'Claw2';
	if (MeleeAnims[1] == 'Claw3')
		MeleeAnims[1] = 'Claw1';

	// Plug in headless anims if we have them
	for( i = 0; i < 4; i++ )
	{
		if( HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i]) )
		{
			MovementAnims[i] = HeadlessWalkAnims[i];
			WalkAnims[i]     = HeadlessWalkAnims[i];
		}
	}

	PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	local bool bIsHeadshot;
	local KFPlayerReplicationInfo KFPRI;
	local float HeadShotCheckScale;

	LastDamagedBy = instigatedBy;
	LastDamagedByType = damageType;
	HitMomentum = VSize(momentum);
	LastHitLocation = hitlocation;
	LastMomentum = momentum;

	if ( KFPawn(instigatedBy) != none && instigatedBy.PlayerReplicationInfo != none )
	{
		KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);
	}

	// Scale damage if the Zed has been zapped
    if( bZapped )
    {
        Damage *= ZappedDamageMod;
    }

	// Zeds and fire dont mix.
	if ( class<KFWeaponDamageType>(damageType) != none && class<KFWeaponDamageType>(damageType).default.bDealBurningDamage )
    {
        if( BurnDown<=0 || Damage > LastBurnDamage )
        {
			 // LastBurnDamage variable is storing last burn damage (unperked) received,
			// which will be used to make additional damage per every burn tick (second).
			LastBurnDamage = Damage;

			// FireDamageClass variable stores damage type, which started zed's burning
			// and will be passed to this function again every next burn tick (as damageType argument)
			if ( class<DamTypeTrenchgun>(damageType) != none ||
				 class<DamTypeFlareRevolver>(damageType) != none ||
				 class<DamTypeMAC10MPInc>(damageType) != none)
			{
				 FireDamageClass = damageType;
			}
			else
			{
				FireDamageClass = class'DamTypeFlamethrower';
			}
        }

		if ( class<DamTypeMAC10MPInc>(damageType) == none )
        {
            Damage *= 1.5; // Increase burn damage 1.5 times, except MAC10.
        }

        // BurnDown variable indicates how many ticks are remaining for zed to burn.
        // It is 0, when zed isn't burning (or stopped burning).
        // So all the code below will be executed only, if zed isn't already burning
        if( BurnDown<=0 )
        {
            if( HeatAmount>4 || Damage >= 15 )
            {
                bBurnified = true;
                BurnDown = 10; // Inits burn tick count to 10
                SetGroundSpeed(GroundSpeed *= 0.80); // Lowers movement speed by 20%
                BurnInstigator = instigatedBy;
                SetTimer(1.0,false); // Sets timer function to be executed each second
            }
            else HeatAmount++;
        }
    }

	if ( !bDecapitated && class<KFWeaponDamageType>(damageType)!=none &&
		class<KFWeaponDamageType>(damageType).default.bCheckForHeadShots )
	{
		HeadShotCheckScale = 1.0;

		// Do larger headshot checks if it is a melee attach
		if( class<DamTypeMelee>(damageType) != none )
		{
			HeadShotCheckScale *= 1.25;
		}

		bIsHeadShot = IsHeadShot(hitlocation, normal(momentum), HeadShotCheckScale);
		bLaserSightedEBRM14Headshotted = bIsHeadshot && M14EBRBattleRifle(instigatedBy.Weapon) != none && M14EBRBattleRifle(instigatedBy.Weapon).bLaserActive;
	}
	else
	{
		bLaserSightedEBRM14Headshotted = bLaserSightedEBRM14Headshotted && bDecapitated;
	}

	if ( KFPRI != none  )
	{
		if ( KFPRI.ClientVeteranSkill != none )
		{
			Damage = KFPRI.ClientVeteranSkill.Static.AddDamage(KFPRI, self, KFPawn(instigatedBy), Damage, DamageType);
		}
	}

	if ( damageType != none && LastDamagedBy.IsPlayerPawn() && LastDamagedBy.Controller != none )
	{
		if ( KFMonsterController(Controller) != none )
		{
			KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, FMin(Health, Damage));
		}
	}

	if ( (bDecapitated || bIsHeadShot) && class<DamTypeBurned>(DamageType) == none && class<DamTypeFlamethrower>(DamageType) == none )
	{
		if(class<KFWeaponDamageType>(damageType)!=none)
			Damage = Damage * class<KFWeaponDamageType>(damageType).default.HeadShotDamageMult;

		if ( class<DamTypeMelee>(damageType) == none && KFPRI != none &&
			 KFPRI.ClientVeteranSkill != none )
		{
            Damage = float(Damage) * KFPRI.ClientVeteranSkill.Static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType);
		}

		LastDamageAmount = Damage;

		if( !bDecapitated )
		{
			if( bIsHeadShot )
			{
			    // Play a sound when someone gets a headshot TODO: Put in the real sound here
			    if( bIsHeadShot )
			    {
					PlaySound(sound'KF_EnemyGlobalSndTwo.Impact_Skull', SLOT_None,2.0,true,500);
				}
				HeadHealth -= LastDamageAmount;
				if( HeadHealth <= 0 || Damage > Health )
				{
				   RemoveHead();
				}
			}

			// Award headshot here, not when zombie died.
			if( bDecapitated && Class<KFWeaponDamageType>(damageType) != none && instigatedBy != none && KFPlayerController(instigatedBy.Controller) != none )
			{
				bLaserSightedEBRM14Headshotted = M14EBRBattleRifle(instigatedBy.Weapon) != none && M14EBRBattleRifle(instigatedBy.Weapon).bLaserActive;
				Class<KFWeaponDamageType>(damageType).Static.ScoredHeadshot(KFSteamStatsAndAchievements(PlayerController(instigatedBy.Controller).SteamStatsAndAchievements), self.Class, bLaserSightedEBRM14Headshotted);
			}
		}
	}

	// Client check for Gore FX
	//BodyPartRemoval(Damage,instigatedBy,hitlocation,momentum,damageType);

	if( Health-Damage > 0 && DamageType!=class'DamTypeFrag' && DamageType!=class'DamTypePipeBomb'
		&& DamageType!=class'DamTypeM79Grenade' && DamageType!=class'DamTypeM32Grenade'
        && DamageType!=class'DamTypeM203Grenade' && DamageType!=class'DamTypeDwarfAxe'
        && DamageType!=class'DamTypeSPGrenade' && DamageType!=class'DamTypeSealSquealExplosion'
        && DamageType!=class'DamTypeSeekerSixRocket')
	{
		Momentum = vect(0,0,0);
	}

	if(class<DamTypeVomit>(DamageType)!=none) // Same rules apply to zombies as players.
	{
		BileCount=7;
		BileInstigator = instigatedBy;
		LastBileDamagedByType=class<DamTypeVomit>(DamageType);
		if(NextBileTime< Level.TimeSeconds )
			NextBileTime = Level.TimeSeconds+BileFrequency;
	}

	if ( KFPRI != none && Health-Damage <= 0 && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.static.KilledShouldExplode(KFPRI, KFPawn(instigatedBy)) )
	{
		Super.takeDamage(Damage + 600, instigatedBy, hitLocation, momentum, damageType);
		HurtRadius(500, 1000, class'DamTypeFrag', 100000, Location);
	}
	else
	{
		Super.takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);
	}

	if( bIsHeadShot && Health <= 0 )
	{
	   KFGameType(Level.Game).DramaticEvent(0.03);
	}

	bBackstabbed = false;
}

function PlayDyingSound()
{
	if( Level.NetMode!=NM_Client )
	{
		if ( bGibbed )
		{
			// Do nothing for now
			PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.0,true,525);
			return;
		}

		if( bDecapitated )
		{

			PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
		}
		else
		{
			PlaySound(DeathSound[0], SLOT_Pain,1.30,true,525);
		}
	}
}

// New Hit FX for Zombies!
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIdx )
{
	local Vector HitNormal;
	local Vector HitRay ;
	local Name HitBone;
	local float HitBoneDist;
	local PlayerController PC;
	local bool bShowEffects, bRecentHit;
	local ProjectileBloodSplat BloodHit;
	local rotator SplatRot;

	bRecentHit = Level.TimeSeconds - LastPainTime < 0.2;

	LastDamageAmount = Damage;

	// Call the modified version of the original Pawn playhit
	OldPlayHit(Damage, InstigatedBy, HitLocation, DamageType,Momentum);

	if ( Damage <= 0 )
		return;

	if( Health>0 && Damage>(float(Default.Health)/1.5) )
		FlipOver();

	PC = PlayerController(Controller);
	bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 2.5)
					|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None))
					|| (PC != None) );
	if ( !bShowEffects )
		return;

	if ( BurnDown > 0 && !bBurnified )
	{
		bBurnified = true;
	}

	HitRay = vect(0,0,0);
	if( InstigatedBy != None )
		HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));

	if( DamageType.default.bLocationalHit )
	{
		CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );

        // Do a zapped effect is someone shoots us and we're zapped to help show that the zed is taking more damage
        if ( bZapped && DamageType.name != 'DamTypeZEDGun' )
        {
            PlaySound(class'ZedGunProjectile'.default.ExplosionSound,,class'ZedGunProjectile'.default.ExplosionSoundVolume);
            Spawn(class'ZedGunProjectile'.default.ExplosionEmitter,,,HitLocation + HitNormal*20,rotator(HitNormal));
        }
	}
	else
	{
		HitLocation = Location ;
		HitBone = FireRootBone;
		HitBoneDist = 0.0f;
	}

	if( DamageType.default.bAlwaysSevers && DamageType.default.bSpecial )
		HitBone = 'head';

	if( InstigatedBy != None )
		HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
	else
		HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

	//log("HitLocation "$Hitlocation) ;

	if ( DamageType.Default.bCausesBlood && (!bRecentHit || (bRecentHit && (FRand() > 0.8))))
	{
		if ( !class'GameInfo'.static.NoBlood() && !class'GameInfo'.static.UseLowGore() )
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

	if( InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none &&
		KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements) != none &&
		Health <= 0 && Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 && (!bDecapitated || bPlayBrainSplash) )
	{
		KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements).AddGibKill(class<DamTypeM79Grenade>(damageType) != none);

		if ( self.IsA('ZombieFleshPound') )
		{
			KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements).AddFleshpoundGibKill();
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
            // Don't spawn the blood when we're zapped as we're spawning the zapped damage emitter elsewhere
            if( !bZapped || (bZapped && !DamageType.default.bLocationalHit) )
            {
    			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));
    			if (DesiredEmitter != None)
    			{
    			    if( InstigatedBy != none )
    			        HitNormal = Normal((InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight))-HitLocation);

    				spawn(DesiredEmitter,,,HitLocation+HitNormal + (-HitNormal * CollisionRadius), Rotator(HitNormal));
    			}
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

// Implemented in subclasses - return false if there is some action that we don't want the direction hit to interrupt
simulated function bool HitCanInterruptAction()
{
	return true;
}

function PlayDirectionalHit(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;

	GetAxes(Rotation, X,Y,Z);
	HitLoc.Z = Location.Z;
	Dir = -Normal(Location - HitLoc);

	if( !HitCanInterruptAction() )
	{
		return;
	}

	// random
	if ( VSize(Location - HitLoc) < 1.0 )
		Dir = VRand();
	else Dir = -Normal(Location - HitLoc);

	if ( Dir dot X > 0.7 || Dir == vect(0,0,0))
	{
		if( LastDamagedBy!=none && LastDamageAmount>0 )
		{
			if ( StunsRemaining != 0 && (LastDamageAmount >= (0.5 * default.Health) ||
			    (VSize(LastDamagedBy.Location - Location) <= (MeleeRange * 2) && ClassIsChildOf(LastDamagedbyType,class 'DamTypeMelee') &&
				 KFPawn(LastDamagedBy) != none && LastDamageAmount > (0.10* default.Health))) )
			{
				SetAnimAction(HitAnims[Rand(3)]);
				bSTUNNED = true;
				SetTimer(StunTime,false);
				StunsRemaining--;
			}
			else
				SetAnimAction(KFHitFront);
			}
	}
	else if ( Dir Dot X < -0.7 )
		SetAnimAction(KFHitBack);
	else if ( Dir Dot Y > 0 )
		SetAnimAction(KFHitRight);
	else SetAnimAction(KFHitLeft);
}

simulated function PlayDirectionalDeath(Vector HitLoc); // Death animation replaced with ragdoll.

// Overridden so that anims don't get interrupted on the server if one is already playing
function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
	local coords C;
	local vector HeadLoc, B, M, diff;
	local float t, DotMM, Distance;
	local int look;
	local bool bUseAltHeadShotLocation;
	local bool bWasAnimating;

	if (HeadBone == '')
		return False;

	// If we are a dedicated server estimate what animation is most likely playing on the client
	if (Level.NetMode == NM_DedicatedServer)
	{
		if (Physics == PHYS_Falling)
			PlayAnim(AirAnims[0], 1.0, 0.0);
		else if (Physics == PHYS_Walking)
		{
			// Only play the idle anim if we're not already doing a different anim.
			// This prevents anims getting interrupted on the server and borking things up - Ramm

			if( !IsAnimating(0) && !IsAnimating(1) )
			{
				if (bIsCrouched)
				{
					PlayAnim(IdleCrouchAnim, 1.0, 0.0);
				}
				else
				{
					bUseAltHeadShotLocation=true;
				}
			}
			else
			{
				bWasAnimating = true;
			}

			if ( bDoTorsoTwist )
			{
				SmoothViewYaw = Rotation.Yaw;
				SmoothViewPitch = ViewPitch;

				look = (256 * ViewPitch) & 65535;
				if (look > 32768)
					look -= 65536;

				SetTwistLook(0, look);
			}
		}
		else if (Physics == PHYS_Swimming)
			PlayAnim(SwimAnims[0], 1.0, 0.0);

		if( !bWasAnimating )
		{
			SetAnimFrame(0.5);
		}
	}

	if( bUseAltHeadShotLocation )
	{
		HeadLoc = Location + (OnlineHeadshotOffset >> Rotation);
		AdditionalScale *= OnlineHeadshotScale;
	}
	else
	{
		C = GetBoneCoords(HeadBone);

		HeadLoc = C.Origin + (HeadHeight * HeadScale * AdditionalScale * C.XAxis);
	}
	//ServerHeadLocation = HeadLoc;

	// Express snipe trace line in terms of B + tM
	B = loc;
	M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

	// Find Point-Line Squared Distance
	diff = HeadLoc - B;
	t = M Dot diff;
	if (t > 0)
	{
		DotMM = M dot M;
		if (t < DotMM)
		{
			t = t / DotMM;
			diff = diff - (t * M);
		}
		else
		{
			t = 1;
			diff -= M;
		}
	}
	else
		t = 0;

	Distance = Sqrt(diff Dot diff);

	return (Distance < (HeadRadius * HeadScale * AdditionalScale));
}

//TODO - log this to hell to find the last ANs,
//	   and look to consolidate any duplicate code,
//	   including multiple !=nones for the same target
function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local Name TearBone;
	local float dummy;
	local Emitter BloodHit;
	//local vector TraceDir;

	if( Level.NetMode==NM_Client || Controller==None )
		Return False; // Never should be done on client.
	if ( Controller.Target!=none && Controller.Target.IsA('KFDoorMover'))
	{
		Controller.Target.TakeDamage(hitdamage, self ,HitLocation,pushdir, CurrentDamType);
		Return True;
	}

	/*ClearStayingDebugLines();

	TraceDir = Normal(Controller.Target.Location - Location);

	DrawStayingDebugLine(Location, Location + (TraceDir * (MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)) , 255,255,0);*/

	// check if still in melee range
	if ( (Controller.target != None) && (bSTUNNED == false) && (DECAP == false) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z)
			<= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
	{
		// See if a trace would hit a pawn (Have to turn of hit point collision so trace doesn't hit the Human Pawn's bullet whiz cylinder)
		bBlockHitPointTraces = false;
		HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location , Location + EyePosition(), true);
		bBlockHitPointTraces = true;

		// If the trace wouldn't hit a pawn, do the old thing of just checking if there is something blocking the trace
		if( Pawn(HitActor) == none )
		{
			// Have to turn of hit point collision so trace doesn't hit the Human Pawn's bullet whiz cylinder
			bBlockHitPointTraces = false;
			HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
			bBlockHitPointTraces = true;

			if ( HitActor != None )
				return false;
		}

        if ( KFHumanPawn(Controller.Target) != none )
		{
			//TODO - line below was KFPawn. Does this whole block need to be KFPawn, or is it OK as KFHumanPawn?
			KFHumanPawn(Controller.Target).TakeDamage(hitdamage, Instigator ,HitLocation,pushdir, CurrentDamType); //class 'KFmod.ZombieMeleeDamage');

			if (KFHumanPawn(Controller.Target).Health <=0)
			{
				if ( !class'GameInfo'.static.UseLowGore() )
				{
					BloodHit = Spawn(class'KFMod.FeedingSpray',self,,Controller.Target.Location,rotator(pushdir));	 //
					KFHumanPawn(Controller.Target).SpawnGibs(rotator(pushdir), 1);
					TearBone=KFPawn(Controller.Target).GetClosestBone(HitLocation,Velocity,dummy);
					KFHumanPawn(Controller.Target).HideBone(TearBone);
				}

				// Give us some Health back
				if (Health <= (1.0-FeedThreshold)*HealthMax)
				{
					Health += FeedThreshold*HealthMax * Health/HealthMax;
				}
			}

		}
		else if (Controller.target != None)
		{
			// Do more damage if you are attacking another zed so that zeds don't just stand there whacking each other forever! - Ramm
            if( KFMonster(Controller.Target) != none )
			{
                hitdamage *= DamageToMonsterScale;
			}

            Controller.Target.TakeDamage(hitdamage, self ,HitLocation,pushdir, CurrentDamType); //class 'KFmod.ZombieMeleeDamage');
		}

		return true;
	}

	return false;
}

simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if( MyExtCollision!=None )
		MyExtCollision.Destroy();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != None && pc.ViewTarget == self )
			PlayersRagdoll = true;

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.

		if( Level.NetMode == NM_ListenServer )
		{
			// For a listen server, use LastSeenOrRelevantTime instead of render time so
			// monsters don't disappear for other players that the host can't see - Ramm
			if( Level.PhysicsDetailLevel != PDL_High && !PlayersRagdoll && (Level.TimeSeconds-LastSeenOrRelevantTime)>3 ||
				bGibbed )
			{
    			// Wait a tick on a listen server so the obliteration can replicate before the pawn is destroyed
                if( Level.NetMode == NM_ListenServer )
    			{
                    bDestroyNextTick = true;
                    TimeSetDestroyNextTickTime = Level.TimeSeconds;
                }
                else
                {
                    Destroy();
    			}
				return;
			}
		}
		else if( Level.PhysicsDetailLevel!=PDL_High && !PlayersRagdoll && (Level.TimeSeconds-LastRenderTime)>3 ||
			bGibbed)
		{
			// Wait a tick on a listen server so the obliteration can replicate before the pawn is destroyed
            if( Level.NetMode == NM_ListenServer )
			{
                bDestroyNextTick = true;
                TimeSetDestroyNextTickTime = Level.TimeSeconds;
            }
            else
            {
                Destroy();
			}
			return;
		}

		// Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else if(Species != None)
			RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
		else RagSkelName = "Male1"; // Otherwise assume it is Male1 ragdoll were after here.

		KMakeRagdollAvailable();

		if( KIsRagdollAvailable() && RagSkelName != "" )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;

			// Stop animation playing.
			StopAnimating(true);

			// StopAnimating() resets the neck bone rotation, we have to set it again
			// if the zed was decapitated the cute way
			if ( class'GameInfo'.static.UseLowGore() && NeckRot != rot(0,0,0) )
			{
				SetBoneRotation('neck', NeckRot);
			}

			if( DamageType != none )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if ( DamageType.default.bKUseOwnDeathVel )
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
			// If not moving downwards - give extra upward kick
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

			skelParams.bRubbery = DamageType.Default.bRubbery;
			bRubbery = DamageType.Default.bRubbery;

			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}
	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
	BaseEyeHeight = Default.BaseEyeHeight;
	SetTwistLook(0, 0);
	SetInvisibility(0.0);
	// We don't do this - Ramm
	//PlayDirectionalDeath(HitLoc);
	SetPhysics(PHYS_Falling);
}

// Give zombies forward momentum with jumps.
function bool DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		PlayOwnedSound(JumpSound, SLOT_Pain, GruntVolume,,80);

		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.GameDifficulty > 2) )
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
		{
			Velocity.Z = Default.JumpZ;
			Velocity.X = (Default.JumpZ * 0.5);
		}
		else
		{
			Velocity.Z = JumpZ;
			Velocity.X = (JumpZ * 0.5);
		}

		if ( (Base != None) && !Base.bWorldGeometry )
		{
			Velocity.Z += Base.Velocity.Z;
			Velocity.X += Base.Velocity.X;
		}
		SetPhysics(PHYS_Falling);
		return true;
	}
	return false;
}


// Overridden to handle making attached explosives explode when this pawn dies
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local int i;

 	for( i=0; i<Attached.length; i++ )
	{
		if( SealSquealProjectile(Attached[i])!=None )
		{
			SealSquealProjectile(Attached[i]).HandleBasePawnDestroyed();
		}
	}

    super.Died(Killer,damageType,HitLocation);
}

// Overridden to handle making attached explosives explode when this pawn dies
simulated function Destroyed()
{
	local int i;

	for( i=0; i<Attached.length; i++ )
	{
		if( Emitter(Attached[i])!=None && Attached[i].IsA('DismembermentJet') )
		{
			Emitter(Attached[i]).Kill();
			Attached[i].LifeSpan = 2;
		}

		// Make attached explosives blow up when this pawn dies
        if( SealSquealProjectile(Attached[i])!=None )
		{
			SealSquealProjectile(Attached[i]).HandleBasePawnDestroyed();
		}
	}

	if( MyExtCollision!=None )
		MyExtCollision.Destroy();
	if( PlayerShadow != None )
		PlayerShadow.Destroy();

	if ( FlamingFXs != none )
	{
		FlamingFXs.Emitters[0].SkeletalMeshActor = none;
		FlamingFXs.Destroy();
	}

	if(RealtimeShadow !=none)
		RealtimeShadow.Destroy();

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

	if(SpawnVolume != none)
	{
	    SpawnVolume.RemoveZEDFromSpawnList(self);
	}

	RemoveFlamingEffects();
	Super.Destroyed();
}

simulated function ZombieCrispUp()
{
	bAshen = true;
	bCrispified = true;

	SetBurningBehavior();

	if ( Level.NetMode == NM_DedicatedServer || class'GameInfo'.static.UseLowGore() )
	{
		Return;
	}

	Skins[0]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	Skins[1]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	Skins[2]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	Skins[3]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
}

// Set the zed to the on fire behavior
simulated function SetBurningBehavior()
{
	if( Role == Role_Authority )
	{
		Intelligence = BRAINS_Retarded; // burning dumbasses!

		SetGroundSpeed(OriginalGroundSpeed * 0.8);
		AirSpeed *= 0.8;
		WaterSpeed *= 0.8;

		// Make them less accurate while they are burning
		if( Controller != none )
		{
		   MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's burning now, after all) :-D
		}
	}

	// Set the forward movement anim to a random burning anim
	MovementAnims[0] = BurningWalkFAnims[Rand(3)];
	WalkAnims[0]     = BurningWalkFAnims[Rand(3)];

	// Set the rest of the movement anims to the headless anim (not sure if these ever even get played) - Ramm
	MovementAnims[1] = BurningWalkAnims[0];
	WalkAnims[1]     = BurningWalkAnims[0];
	MovementAnims[2] = BurningWalkAnims[1];
	WalkAnims[2]     = BurningWalkAnims[1];
	MovementAnims[3] = BurningWalkAnims[2];
	WalkAnims[3]     = BurningWalkAnims[2];
}

// Turn off the on-fire behavior
simulated function UnSetBurningBehavior()
{
	local int i;

    // Don't turn off this behavior until the harpoon stun is over
    if( bHarpoonStunned )
    {
        return;
    }

	if ( Role == Role_Authority )
	{
		Intelligence = default.Intelligence;

		if( !bZapped )
		{
    		SetGroundSpeed(GetOriginalGroundSpeed());
    		AirSpeed = default.AirSpeed;
    		WaterSpeed = default.WaterSpeed;
        }

		// Set normal accuracy
		if ( Controller != none )
		{
		   MonsterController(Controller).Accuracy = MonsterController(Controller).default.Accuracy;
		}
	}

	bAshen = False;

	// restore regular anims
	for ( i = 0; i < 4; i++ )
	{
		MovementAnims[i] = default.MovementAnims[i];
		WalkAnims[i]     = default.WalkAnims[i];
	}
}

function TakeFireDamage(int Damage,pawn Instigator)
{
	local Vector DummyHitLoc,DummyMomentum;

	TakeDamage(Damage, BurnInstigator, DummyHitLoc, DummyMomentum, FireDamageClass);

	if ( BurnDown > 0 )
	{
		// Decrement the number of FireDamage calls left before our Zombie is extinguished :)
		BurnDown --;
	}

	// Melt em' :)
	if ( BurnDown < CrispUpThreshhold )
	{
		ZombieCrispUp();
	}

	if ( BurnDown == 0 )
	{
		bBurnified = false;
		if( !bZapped )
		{
            SetGroundSpeed(default.GroundSpeed);
        }
	}
}

// We can add blood streak decals here, as the Actor's body moves in Ragdoll
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds, soundNum;
	local vector WallHit, WallNormal;
	local Actor WallActor;
	local KFBloodStreakDecal Streak;
	local float VelocitySquared;
	local float RagHitVolume;
	local float StreakDist;

	numSounds = RagImpactSounds.Length;

	if ( LastStreakLocation == vect(0,0,0) )
	{
		StreakDist = 0;
	}
	else
	{
		StreakDist = VSizeSquared(LastStreakLocation - pos);
	}

	LastStreakLocation = pos;

	WallActor = Trace(WallHit, WallNormal, pos - impactNorm * 16, pos + impactNorm * 16, false);

	//Added no blood for low gore
	if ( WallActor != None && Level.TimeSeconds > LastStreakTime + BloodStreakInterval && !class'GameInfo'.static.UseLowGore() )
	{
		if ( StreakDist < 1400 ) //0.75m
		{
		   //log("Streak dist too small "$ Sqrt(StreakDist)/50$"m");
		   return;
		}

		Streak = spawn(class 'KFMod.KFBloodStreakDecal',,, WallHit, rotator(-WallNormal));

		LastStreakTime = Level.TimeSeconds;
	}

	if ( numSounds > 0 && Level.TimeSeconds > RagLastSoundTime + RagImpactSoundInterval )
	{
		VelocitySquared = VSizeSquared(impactVel);
		RagHitVolume = FMin(2.0, (VelocitySquared / 40000));
		soundNum = Rand(numSounds);

		PlaySound(RagImpactSounds[soundNum], SLOT_None, RagHitVolume);
		RagLastSoundTime = Level.TimeSeconds;
	}
}

simulated function RemoveFlamingEffects()
{
	local int i;

	if ( Level.NetMode == NM_DedicatedServer )
	{
		return;
	}

	for ( i = 0; i < Attached.length; i++ )
	{
		if ( xEmitter(Attached[i]) != none )
		{
			xEmitter(Attached[i]).mRegen = false;
			Attached[i].LifeSpan = 2;
		}
		else if ( Emitter(Attached[i]) != None && !Attached[i].IsA('DismembermentJet') )
		{
			Emitter(Attached[i]).Kill();
			Attached[i].LifeSpan = 2;
		}
	}
}

simulated function TurnOff()
{
	RemoteRole = ROLE_SimulatedProxy;
}

// this could have been responsible for making the zombies "lethargic" in wander state.
// they should retain the same walk speed at all times.
event SetWalking(bool bNewIsWalking);

function Trigger( actor Other, pawn EventInstigator )
{
	if( Controller!=None )
		Controller.Trigger(Other,EventInstigator);
}

// Laught at victory of boss battle.
function bool SetBossLaught()
{
	Return False; // Normal zeds have no feelings..
}

state DoorBashing
{
	simulated function bool HitCanInterruptAction()
	{
		return false;
	}

	function Tick( float Delta )
	{
		Acceleration = vect(0,0,0);

		global.Tick(Delta);
	}

Begin:
	Sleep(GetAnimDuration('DoorBash') + 0.1);
	GotoState('');
}

static simulated function PreCacheAssets(LevelInfo myLevel)
{

    //log("*********");
    //log(default.Class);
    //DynamicLoadSounds();
    PreCacheStaticMeshes(myLevel);
    if(myLevel != none)
        PreCacheMaterials(myLevel);
    //DynamicLoadMeshAndSkins();

}

static simulated function DynamicLoadMeshAndSkins()
{
    /*
    local int i;

    if(default.MeshRef != "")
        UpdateDefaultMesh( SkeletalMesh(DynamicLoadObject(default.MeshRef, Class'SkeletalMesh')) );

	for ( i = 0; i < default.SkinsRef.Length; i++ )
	{
	    if(default.SkinsRef[i] != "")
  		    default.Skins[i] = Material(DynamicLoadObject(default.SkinsRef[i], class'Material'));
	}
	*/
}

static simulated function DynamicLoadSounds()
{
    /*    local int i;

    if( default.AmbientSoundRef == "" )
    {
       log("don't have sound refs, bailing out");
       return;
    }

    for(i = 0;i < default.HitSoundRef.length;i++)
    {
        default.HitSound[i] = Sound(DynamicLoadObject(default.HitSoundRef[i], Class'Sound'));
    }

    for(i = 0;i < default.ChallengeSoundRef.length;i++)
    {
        default.ChallengeSound[i] = Sound(DynamicLoadObject(default.ChallengeSoundRef[i], Class'Sound'));
    }

    for(i = 0;i < default.DeathSoundRef.length;i++)
    {
        default.DeathSound[i] = Sound(DynamicLoadObject(default.DeathSoundRef[i], Class'Sound'));
    }

    default.AmbientSound = Sound(DynamicLoadObject(default.AmbientSoundRef, Class'Sound'));
    default.MoanVoice = Sound(DynamicLoadObject(default.MoanVoiceRef, Class'Sound'));
    default.JumpSound = Sound(DynamicLoadObject(default.JumpSoundRef, Class'Sound'));

    if( default.MeleeAttackHitSoundRef != "" )
        default.MeleeAttackHitSound = Sound(DynamicLoadObject(default.MeleeAttackHitSoundRef, Class'Sound'));
*/
}

static simulated function PreCacheStaticMeshes(LevelInfo myLevel)
{//should be derived and used.
/*
    if( default.DetachedArmClassRef != "" )
        default.DetachedArmClass = class<SeveredAppendage>(DynamicLoadObject(default.DetachedArmClassRef, Class'Class'));

    if( default.DetachedLegClassRef != "" )
        default.DetachedLegClass = class<SeveredAppendage>(DynamicLoadObject(default.DetachedLegClassRef, Class'Class'));

    if( default.DetachedHeadClassRef != "" )
        default.DetachedHeadClass = class<SeveredAppendage>(DynamicLoadObject(default.DetachedHeadClassRef, Class'Class'));

    if( default.DetachedSpecialArmClassRef != "" )
        default.DetachedSpecialArmClass = class<SeveredAppendage>(DynamicLoadObject(default.DetachedSpecialArmClassRef, Class'Class'));
*/
    if(myLevel == none)
       return;

    if( default.DetachedArmClass != none )
        myLevel.AddPrecacheStaticMesh(default.DetachedArmClass.default.StaticMesh);

    if( default.DetachedLegClass != none )
        myLevel.AddPrecacheStaticMesh(default.DetachedLegClass.default.StaticMesh);

    if( default.DetachedHeadClass != none )
        myLevel.AddPrecacheStaticMesh(default.DetachedHeadClass.default.StaticMesh);

    if( default.DetachedSpecialArmClass != none )
        myLevel.AddPrecacheStaticMesh(default.DetachedSpecialArmClass.default.StaticMesh);
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
}

defaultproperties
{
     MeleeAnims(0)="Claw"
     MeleeAnims(1)="Claw2"
     MeleeAnims(2)="Claw3"
     HitAnims(0)="HitF"
     HitAnims(1)="HitF2"
     HitAnims(2)="HitF3"
     MoanVolume=1.500000
     BileFrequency=0.500000
     KFHitFront="HitReactionF"
     KFHitBack="HitReactionB"
     KFHitLeft="HitReactionL"
     KFHitRight="HitReactionR"
     RagMaxSpinAmount=100.000000
     StunTime=1.000000
     StunsRemaining=-1
     BleedOutDuration=5.000000
     ZapDuration=4.000000
     ZappedSpeedMod=0.500000
     ZapThreshold=0.250000
     ZappedDamageMod=2.000000
     ZapResistanceScale=2.000000
     bHarpoonToHeadStuns=True
     bHarpoonToBodyStuns=True
     DamageToMonsterScale=3.000000
     HumanBileAggroChance=0.750000
     MaxSpineVariation=1000
     MaxContortionPercentage=0.250000
     MinTimeBetweenPainAnims=0.500000
     playedHit=True
     FeedThreshold=0.100000
     CorpseLifeSpan=120.000000
     ZombieDamType(0)=Class'KFMod.ZombieMeleeDamage'
     ZombieDamType(1)=Class'KFMod.ZombieMeleeDamage'
     ZombieDamType(2)=Class'KFMod.ZombieMeleeDamage'
     HeadLessDeathSound=SoundGroup'KF_EnemyGlobalSnd.Zomb_HeadlessDie'
     DecapitationSound=SoundGroup'KF_EnemyGlobalSnd.Generic_Decap'
     BurnEffect=Class'KFMod.KFMonsterFlame'
     AltBurnEffect=Class'KFMod.KFAltMonsterFlame'
     CrispUpThreshhold=5
     PuntAnim="PoundPunt"
     BloodStreakInterval=0.250000
     MonsterHeadGiblet=Class'KFMod.ClotGibHead'
     MonsterThighGiblet=Class'KFMod.ClotGibThigh'
     MonsterArmGiblet=Class'KFMod.ClotGibArm'
     MonsterLegGiblet=Class'KFMod.ClotGibLeg'
     MonsterTorsoGiblet=Class'KFMod.ClotGibTorso'
     MonsterLowerTorsoGiblet=Class'KFMod.ClotGibLowerTorso'
     Intelligence=BRAINS_Human
     ExtCollAttachBoneName="Bip01"
     LeftShoulderBone="lshoulder"
     RightShoulderBone="rshoulder"
     LeftThighBone="lthigh"
     RightThighBone="rthigh"
     LeftFArmBone="lfarm"
     RightFArmBone="rfarm"
     LeftFootBone="lfoot"
     RightFootBone="rfoot"
     LeftHandBone="lefthand"
     RightHandBone="righthand"
     NeckBone="CHR_Neck"
     SeveredArmAttachScale=1.000000
     SeveredLegAttachScale=1.000000
     SeveredHeadAttachScale=1.000000
     NeckSpurtEmitterClass=Class'KFMod.DismembermentJetHead'
     NeckSpurtNoGibEmitterClass=Class'KFMod.DismembermentJetDecapitate'
     LimbSpurtEmitterClass=Class'KFMod.DismembermentJetLimb'
     SeveredArmAttachClass=Class'ROEffects.SeveredArmAttachment'
     SeveredLegAttachClass=Class'ROEffects.SeveredLegAttachment'
     SeveredHeadAttachClass=Class'ROEffects.SeveredHeadAttachment'
     ProjectileBloodSplatClass=Class'ROEffects.ProjectileBloodSplat'
     ObliteratedEffectClass=Class'ROEffects.PlayerObliteratedEmitter'
     HeadlessWalkAnims(0)="WalkF_Headless"
     HeadlessWalkAnims(1)="WalkB_Headless"
     HeadlessWalkAnims(2)="WalkL_Headless"
     HeadlessWalkAnims(3)="WalkR_Headless"
     BurningWalkFAnims(0)="WalkF_Fire"
     BurningWalkFAnims(1)="WalkF_Fire"
     BurningWalkFAnims(2)="WalkF_Fire"
     BurningWalkAnims(0)="WalkB_Fire"
     BurningWalkAnims(1)="WalkL_Fire"
     BurningWalkAnims(2)="WalkR_Fire"
     PoundRageBumpDamScale=1.000000
     HiddenGroundSpeed=300.000000
     OnlineHeadshotScale=1.000000
     HeadHealth=25.000000
     MotionDetectorThreat=1.000000
     DeathAnim(0)=
     DeathAnim(1)=
     DeathAnim(2)=
     DeathAnim(3)=
     GibGroupClass=Class'KFMod.KFNoGibGroup'
     bCanDodge=False
     GruntVolume=0.500000
     FootstepVolume=1.000000
     SoundGroupClass=Class'KFMod.KFMaleZombieSounds'
     IdleHeavyAnim="Idle_LargeZombie"
     IdleRifleAnim="Idle_LargeZombie"
     FireHeavyRapidAnim="MeleeAttack"
     FireHeavyBurstAnim="MeleeAttack"
     FireRifleRapidAnim="MeleeAttack"
     FireRifleBurstAnim="MeleeAttack"
     FireRootBone="CHR_Spine1"
     DeResMat0=Texture'KFCharacters.KFDeRez'
     DeResMat1=Texture'KFCharacters.KFDeRez'
     DeResLiftVel=(Points=(,(InVal=0.000000,OutVal=0.000000),(InVal=0.000000,OutVal=0.000000)))
     DeResLiftSoftness=(Points=((OutVal=0.000000),(InVal=0.000000,OutVal=0.000000),(InVal=0.000000,OutVal=0.000000)))
     DeResLateralFriction=0.000000
     RagdollLifeSpan=30.000000
     RagDeathVel=100.000000
     RagShootStrength=200.000000
     RagSpinScale=7.500000
     RagDeathUpKick=0.000000
     RagImpactSounds(0)=SoundGroup'KF_EnemyGlobalSnd.Zomb_BodyImpact'
     RagImpactSoundInterval=0.250000
     RequiredEquipment(0)="none"
     RequiredEquipment(1)="none"
     bCanSwim=False
     bCanStrafe=False
     bSameZoneHearing=True
     bAdjacentZoneHearing=True
     bMuffledHearing=False
     bAroundCornerHearing=True
     bCanUse=False
     HearingThreshold=20000.000000
     Alertness=1.000000
     SightRadius=20000.000000
     PeripheralVision=360.000000
     SkillModifier=5.000000
     MeleeRange=50.000000
     JumpZ=320.000000
     WalkingPct=1.000000
     CrouchedPct=1.000000
     MaxFallSpeed=2500.000000
     HeadRadius=7.000000
     HeadHeight=2.000000
     HeadScale=1.100000
     ControllerClass=Class'KFMod.KFMonsterController'
     TurnLeftAnim="TurnLeft"
     TurnRightAnim="TurnRight"
     IdleCrouchAnim="Idle_LargeZombie"
     IdleWeaponAnim="Idle_LargeZombie"
     IdleRestAnim="Idle_LargeZombie"
     RootBone="CHR_Pelvis"
     HeadBone="head"
     SpineBone1="CHR_Spine2"
     SpineBone2="CHR_Spine3"
     bDramaticLighting=False
     AmbientGlow=0
     SoundVolume=50
     SoundRadius=80.000000
     TransientSoundVolume=1.000000
     CollisionRadius=26.000000
     bBlockKarma=True
     Mass=100.000000
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
     KParams=KarmaParamsSkel'KFMod.KFMonster.PawnKParams'

}
