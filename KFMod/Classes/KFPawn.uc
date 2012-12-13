//=============================================================================
// KFPawn
//=============================================================================
class KFPawn extends xPawn
      dependsOn(xPawnGibGroup);

#exec OBJ LOAD FILE=Inf_Weapons.uax
#exec OBJ LOAD FILE=Inf_Player.uax

// From XPawn
var(Gib) class<xPawnGibGroup> GibGroupClass;
var(Gib) int GibCountCalf;
var(Gib) int GibCountForearm;
var(Gib) int GibCountHead;
var(Gib) int GibCountTorso;
var(Gib) int GibCountUpperArm;

var string KFBSkin;
var string KFFSkin;
var mesh  KFSMesh;

var float healthToGive, lastHealTime;

var bool bResetingAnimAct;
var float NextBileTime, BileFrequency, AnimActResetTime;
var int BileCount;
var Pawn BileInstigator;

var name ClientIdleWeaponAnim;

var bool bThrowingNade; // ARE WE ALREADY THROWING ONE?

var Inventory SecondaryItem;

// Player Health Bar textures
var Texture TeamBeaconTexture, NoEntryTexture;
var Material TeamBeaconBorderMaterial;

var class<DamageType> LastHitDamType; // records the last kind of damge you took (for siren hack)

var (Global) Mesh SafeMesh;

// Fire Related

var int BurnDown ; // Number of times our zombie must suffer Fire Damage.
var bool bAshen; // is our Zed crispy yet?
var class<Emitter> BurnEffect;  // The appearance of the flames we are attaching to our Zed.
var int LastBurnDamage; // Record the last amount of Fire damage the pawn suffered.
var Emitter ItBUURRNNNS;

var bool bBurnified;
var bool bBurnApplied;

var pawn LastDamagedBy,BurnInstigator;

var() globalconfig bool bDetailedShadows,bRealDeathType,bRealtimeShadows;

var KFLevelRules LevRls;
var PlayerReplicationInfo OwnerPRI;

var byte bIsQuickHealing;

/* Feet adjusters ================*/
var bool bHasFootAdjust;
var globalconfig bool bDoAdjustFeet;
var float MaxZHeight,MinZHeight,OldAdjust[2];
var KFPawnFootAdjuster Adjuster;
var Class<SPECIES_KFMaleHuman> FeetAdjSpec;

// Animations
const NUM_FIRE_ANIMS = 4;
var name FireAnims[NUM_FIRE_ANIMS];
var name FireAltAnims[NUM_FIRE_ANIMS];
var name FireCrouchAnims[NUM_FIRE_ANIMS];
var name FireCrouchAltAnims[NUM_FIRE_ANIMS];
var name HitAnims[4];
var name PostFireBlendStandAnim;
var name PostFireBlendCrouchAnim;


// Footstepping
var(Sounds)		float 			FootStepSoundRadius;	// The radius that footstep sounds can be heard
var(Sounds)		float			QuietFootStepVolume;	// The amount to scale footstepsounds when the player is walking slowly
var(Sounds)     sound           SoundFootsteps[20];     // Indexed by ESurfaceTypes (sorry about the literal).
var(Bob)        float           BobSpeedModifier;       // A general scalar for walkbob/footstep sound speed
var(Bob)        float           BobScaleModifier;       // A general scalar for walkbob intensity

var             bool            bMovementDisabled;      // The player can't move right now
var             float           StopDisabledTime;       // When the player can move again;

// Gore
var	        SeveredAppendageAttachment 	SeveredLeftArm;         // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredRightArm;        // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredLeftLeg;         // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredRightLeg;        // The meaty attachments that get attached when body parts are blown off
var	        SeveredAppendageAttachment 	SeveredHead;            // The meaty attachments that get attached when body parts are blown off
var(Gore)   float                       SeveredArmAttachScale;  // The drawscale of the arm gore attachement
var(Gore)   float                       SeveredLegAttachScale;  // The drawscale of the leg gore attachement
var(Gore)   float                       SeveredHeadAttachScale; // The drawscale of the head gore attachement

var	class<DismembermentJetHead>         NeckSpurtEmitterClass;  // class of the chopped off head neck emitter
var	class<DismembermentJetLimb>         LimbSpurtEmitterClass;  // class of the chopped off head neck emitter

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
var(Sounds) sound               DecapitationSound;      //The sound of this players head exploding

var	float	LastDropCashMessageTime;
var	float	DropCashMessageDelay;

var bool    bDestroyAfterRagDollTick;   // Wait until the ragdoll tick has happened and then destroy. Prevents crashes where we try and destroy the actor right after initializing ragdoll
var bool    bProcessedRagTickDestroy;   // Already called destroy for a bDestroyAfterRagDollTick setting

// Collision
var		KFBulletWhipAttachment  AuxCollisionCylinder;   // Additional collision cylinder for detecting bullets passing by
var 				bool 		SavedAuxCollision;     	// Saved aux collision cylinder status

var         float               NadeThrowTimeout;       // Little hack to timeout the grenade throwing flag on the client in case it gets stuck. At some point we should try and track down what is actually causing it to get stuck, this is just a quick fix - Ramm

var     Emitter    AttachedEmitter;

// Hit detection debugging - Only use when debugging
/*var vector DrawLocation;
var rotator DrawRotation;
var int DrawIndex;
var vector HitStart;
var vector HitEnd;
var byte HitPointDebugByte;
var byte OldHitPointDebugByte;*/

replication
{
	reliable if(Role == ROLE_Authority)
		bBurnified,QuickHeal,ClientCurrentWeaponSold,ClientForceChangeWeapon;

	reliable if(Role < ROLE_Authority)
		ServerBuyWeapon,ServerSellWeapon,ServerBuyKevlar,ServerBuyFirstAid,ServerBuyAmmo,ServerSellAmmo;

	reliable if(Role < ROLE_Authority)
		SecondaryItem,TossCash;

	reliable if ( bNetDirty && (Role == Role_Authority) && bNetOwner )
		bMovementDisabled;

    // Hit detection debugging - Only use when debugging
    /*reliable if (Role == ROLE_Authority)
		DrawLocation,DrawRotation,DrawIndex,HitPointDebugByte,HitStart,HitEnd;*/
}

simulated function PostBeginPlay()
{
	Super(UnrealPawn).PostBeginPlay();
	AssignInitialPose();

	if( bActorShadows && bPlayerShadows && (Level.NetMode!=NM_DedicatedServer) )
	{
		if( bDetailedShadows )
			PlayerShadow = Spawn(class'KFShadowProject',Self,'',Location);
		else PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.InitShadow();
	}

    // Only need this on the server
	if( Role == Role_Authority/*IsLocallyControlled() || Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer*/ )
	{
    	if (  AuxCollisionCylinder == none )
    	{
    		AuxCollisionCylinder = Spawn(class 'KFBulletWhipAttachment',self);
    		//AttachToBone(AuxCollisionCylinder, 'CHR_Pelvis');

      		///AuxCollisionCylinder = Spawn(class 'ExtendedZCollision',self);
    		//MyExtCollision.SetCollisionSize(ColRadius,ColHeight);

        	AuxCollisionCylinder.bHardAttach = true;
        	//AttachPos = Location + (ColOffset >> Rotation);
        	AuxCollisionCylinder.SetLocation( Location );
        	AuxCollisionCylinder.SetPhysics( PHYS_None );
        	AuxCollisionCylinder.SetBase( self );

    	}
    	SavedAuxCollision = AuxCollisionCylinder.bCollideActors;
	}
}

// Setters for extra collision cylinders
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

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
	if ( C.PlayerReplicationInfo != None )
		OwnerPRI = C.PlayerReplicationInfo;
}

simulated Function PostNetBeginPlay()
{
	EnableChannelNotify(1,1);
	EnableChannelNotify(2,1);
	super.PostNetBeginPlay();
}

simulated function string GetDefaultCharacter()
{
	return "Corporal_Lewis";
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
    local class<Emitter> AttachedEmitterClass;
    local vector AttachOffset;

	if( rec.Species==None || Class<SPECIES_KFMaleHuman>(rec.Species)==None )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
	Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if ( Species!=None && !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		Species = rec.Species;
		RagdollOverride = rec.Ragdoll;
		if ( !Species.static.Setup(self,rec) )
			return;
	}

	if( rec.AttachedEmitter != "" && AttachedEmitter == none && Level.NetMode != NM_DedicatedServer)
	{
        AttachedEmitterClass = class<Emitter>(DynamicLoadObject(rec.AttachedEmitter,class'Class'));
        AttachedEmitter = Spawn(AttachedEmitterClass, self);
        if( AttachToBone(AttachedEmitter, rec.BoneName ) )
        {
            AttachOffset.X = rec.XOffset;
            AttachOffset.Y = rec.YOffset;
            AttachOffset.Z = rec.ZOffset;
            AttachedEmitter.SetRelativeLocation( AttachOffset );//vect(rec.XOffset, rec.YOffset, rec.ZOffset) );
        }
	}

    if( Class<SPECIES_KFMaleHuman>(Species) != none )
    {
        DetachedArmClass = Class<SPECIES_KFMaleHuman>(Species).default.DetachedArmClass;
        DetachedLegClass = Class<SPECIES_KFMaleHuman>(Species).default.DetachedLegClass;
    }

	ResetPhysicsBasedAnim();
//	bHasFootAdjust = False;
//	FeetAdjSpec = Class<SPECIES_KFMaleHuman>(rec.Species);
//	if( !bDoAdjustFeet || FeetAdjSpec==None || Level.NetMode==NM_DedicatedServer )
//		return;
//	if( Adjuster!=None )
//		Adjuster.Destroy();
//	Adjuster = Spawn(Class'KFPawnFootAdjuster',,,vect(0,0,0),rot(0,0,0));
//	Adjuster.AdjustingPawn = Self;
//	Adjuster.SpecType = FeetAdjSpec;
//	Adjuster.LinkMesh(Mesh);
}

// Clean up weapon inventory before level change since certain weapons
// (sniper scopes with 3d scopes) won't get properly garbage collected
// otherwise. This lead to the webadmin and memory leak issues - Ramm
simulated function PreTravelCleanUp()
{
	local Inventory Inv;
	local KFWeapon invWeapon;
	local int count;

	count=0;

	// consider doing a check on count to make sure it doesn't get too high
	// and force Unreal to crash with a run away loop
	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		invWeapon = KFWeapon(Inv);
		if ( invWeapon != None )
		{
			invWeapon.PreTravelCleanUp();
		}

		count++;

		if( count > 500 )
			break;
	}
}

//returns how exposed this player is to another actor
function float GetExposureTo(vector TestLocation)
{
	local float PercentExposed;

	if( FastTrace(GetBoneCoords(HeadBone).Origin,TestLocation))
	{
        PercentExposed += 0.5;
	}

	if( FastTrace(GetBoneCoords(RootBone).Origin,TestLocation))
	{
        PercentExposed += 0.5;
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

		if( bDetailedShadows )
			PlayerShadow = Spawn(class'KFShadowProject',Self,'',Location);
		else PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.InitShadow();
    }
    else if (PlayerShadow != none && Level.NetMode != NM_DedicatedServer)
    {
        PlayerShadow.Destroy();
        PlayerShadow = none;
    }
}

simulated function DoDerezEffect();

simulated event PostNetReceive()
{
	if ( PlayerReplicationInfo != None )
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

// Don't let this pawn move for a certain amount of time
function DisableMovement(float DisableDuration)
{
    StopDisabledTime = Level.TimeSeconds + DisableDuration;
    bMovementDisabled = true;
}

// Modify the velocity of the pawn
simulated event ModifyVelocity(float DeltaTime, vector OldVelocity)
{
    if( Role == ROLE_Authority )
    {
        if( bMovementDisabled )
        {
            if( Level.TimeSeconds > StopDisabledTime )
            {
                bMovementDisabled = false;
            }
        }
    }

    if( bMovementDisabled && Physics == PHYS_Walking )
    {
        Velocity.X = 0;
        Velocity.Y = 0;
        Velocity.Z = 0;
    }

    if ( KFGameReplicationInfo(Level.GRI).BaseDifficulty >= 5 && bMovementDisabled && Velocity.Z > 0 )
    {
    	Velocity.Z = 0;
    }
}

function TakeFallingDamage()
{
	local float Shake, EffectiveSpeed;
	local float UsedMaxFallSpeed;

    UsedMaxFallSpeed = MaxFallSpeed;

    // Higher max fall speed in low grav so that weapons that push you around
    // don't cause you to die
    if( Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
    {
        UsedMaxFallSpeed *= 2.0;
    }

	if (Velocity.Z < -0.5 * UsedMaxFallSpeed)
	{
		if ( Role == ROLE_Authority )
		{
		    MakeNoise(1.0);
		    if (Velocity.Z < -1 * UsedMaxFallSpeed)
		    {
				EffectiveSpeed = Velocity.Z;
				if ( TouchingWaterVolume() )
					EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
				if ( EffectiveSpeed < -1 * UsedMaxFallSpeed )
					TakeDamage(-100 * (EffectiveSpeed + UsedMaxFallSpeed)/UsedMaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
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

exec function TestEye()
{
    local Vector X,Y,Z;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;


    ClearStayingDebugLines();
    DrawDebugSphere( EyePosition() + Location, 12, 12, 0, 255, 0);

    GetAxes( Controller.rotation, X, Y, Z );

    DrawStayingDebugLine((EyePosition() + Location), (EyePosition() + Location)+500* X, 0,0,255);
    DrawStayingDebugLine((EyePosition() + Location), (EyePosition() + Location)+200* Y, 0,255,0);
    Spawn(class 'ROEngine.RODebugTracer',self,,(EyePosition() + Location),Rotation);
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
}



simulated function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r )
{
	local float DismemberProbability;
    local int RandBone;
    local bool bDidSever;

	//log("DamageFX bonename = "$boneName$" "$Level.TimeSeconds$" Damage "$Damage);

	if ( FRand() > 0.3f || Damage > 30 || Health <= 0 )
	{
		HitFX[HitFxTicker].damtype = DamageType;

		if( Health <= 0 )
		{
			switch( boneName )
			{
				case 'neck':
					boneName = HeadBone;
					break;

				case 'lfoot':
				case 'lleg':
					boneName = 'lthigh';
					break;

				case 'rfoot':
				case 'rleg':
					boneName = 'rthigh';
					break;

				case 'righthand':
				case 'rshoulder':
				case 'rarm':
					boneName = 'rfarm';
					break;

				case 'lefthand':
				case 'lshoulder':
				case 'larm':
					boneName = 'lfarm';
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
						boneName = HeadBone;
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
				DoDamageFX(HeadBone,1000,DamageType,r);
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


//Stops the green shit when a player dies.
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local float frame, rate;
	local name seq;
	local LavaDeath LD;
	local MiscEmmiter BE;

	if( Adjuster!=None )
		Adjuster.Destroy();
	bHasFootAdjust = False;
	AmbientSound = None;
	bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	//bFrozenBody = true;

	SafeMesh = Mesh;

	if (CurrentCombo != None)
		CurrentCombo.Destroy();

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

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
					PlaySound( sound'Inf_Weapons.F1.f1_explode01', SLOT_None, 1.5*TransientSoundVolume ); // KFTODO: Replace this sound
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
	//LifeSpan = RagdollLifeSpan;

	GotoState('Dying');
	if ( BE != None )
		return;

	PlayDyingAnimation(DamageType, HitLoc);
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
		if( pc != none && pc.ViewTarget == self )
			PlayersRagdoll = true;

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.
		if( Level.PhysicsDetailLevel!=PDL_High && !PlayersRagdoll && (Level.TimeSeconds-LastRenderTime)>3 )
		{
			GoTo'NonRagdoll';
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

			if( DamageType != None )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(GetTearOffMomemtum());
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;

			// We scale the hit location out sideways a bit, to get more spin around Z.
			hitLocRel.X *= RagSpinScale;
			hitLocRel.Y *= RagSpinScale;

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(GetTearOffMomemtum()) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);

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

			// If this damage type causes convulsions, turn them on here.
			if(DamageType != None && DamageType.default.bCauseConvulsions)
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

NonRagdoll:
	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
	BaseEyeHeight = Default.BaseEyeHeight;
	SetTwistLook(0, 0);
	SetInvisibility(0.0);
	PlayDirectionalDeath(HitLoc);
	SetPhysics(PHYS_Falling);
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

		PlaySound(RagImpactSounds[0], SLOT_None, RagHitVolume);
		RagLastSoundTime = Level.TimeSeconds;
	}
}
//jag

simulated function bool ForceDefaultCharacter()
{
	return false;
}

simulated function ProcessHitFX()
{
	local Coords boneCoords;
	local class<xEmitter> HitEffects[4];
	local int i,j;
	local float GibPerterbation;

	if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh) )
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

        if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized )
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
			HitFX[SimHitFxTicker].bSever = false;

        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;
			bFlaming = HitFX[SimHitFxTicker].DamType.Default.bFlaming;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'obliterate':
                    break;

                case 'lthigh':
                	if( !bLeftLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bLeftLegGibbed=true;
                    }
                    break;

                case 'rthigh':
                	if( !bRightLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bRightLegGibbed=true;
                    }
                    break;

                case 'lfarm':
                	if( !bLeftArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bLeftArmGibbed=true;
                    }
                    break;

                case 'rfarm':
                	if( !bRightArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
	                    bRightArmGibbed=true;
                    }
                    break;

                case 'head':
                  	SpawnGiblet( GetGibClass(EGT_Head), boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    break;
            }

            if (LastHitDamType == class 'SirenScreamDamage')
                HideBone(HeadBone);
            else if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone )
                HideBone(HitFX[SimHitFxTicker].bone);
		}
	}
}

simulated function SpawnSeveredGiblet( class<SeveredAppendage> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
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
    //Giblet.LifeSpan = self.RagdollLifeSpan;
}

function class<Gib> GetGibClass(xPawnGibGroup.EGibType gibType)
{
    return GibGroupClass.static.GetGibClass(gibType);
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;
	local coords boneCoords;

    if( boneName == 'lthigh' )
    {
		boneScaleSlot = 0;
		if( SeveredLeftLeg == none )
		{
			SeveredLeftLeg = Spawn(SeveredLegAttachClass,self);
			SeveredLeftLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'lleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'lleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredLeftLeg, 'lleg');
		}
	}
	else if ( boneName == 'rthigh' )
	{
		boneScaleSlot = 1;
		if( SeveredRightLeg == none )
		{
			SeveredRightLeg = Spawn(SeveredLegAttachClass,self);
			SeveredRightLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'rleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightLeg, 'rleg');
		}
	}
	else if( boneName == 'rfarm' )
	{
		boneScaleSlot = 2;
		if( SeveredRightArm == none )
		{
			SeveredRightArm = Spawn(SeveredArmAttachClass,self);
			SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'rarm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightArm, 'rarm');
		}
	}
	else if ( boneName == 'lfarm' )
	{
		boneScaleSlot = 3;
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
		boneScaleSlot = 4;
		if( SeveredHead == none )
		{
			SeveredHead = Spawn(SeveredHeadAttachClass,self);
			SeveredHead.SetDrawScale(SeveredHeadAttachScale);
			boneCoords = GetBoneCoords( 'neck' );
			AttachEmitterEffect( NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredHead, 'neck');
		}
	}
	else if ( boneName == 'spine' )
		boneScaleSlot = 5;

    SetBoneScale(BoneScaleSlot, 0.0, BoneName);
}

function PlayDyingSound()
{
	if( Level.NetMode!=NM_Client )
	{
    	if ( bGibbed )
    	{
    		PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.0,true,525);
    		return;
    	}

        if ( HeadVolume.bWaterVolume )
        {
            PlaySound(GetSound(EST_Drown), SLOT_Pain,2.5*TransientSoundVolume,true,500);
            return;
        }

    	PlaySound(SoundGroupClass.static.GetDeathSound(), SLOT_Pain,2.5*TransientSoundVolume, true,500);
	}
}

// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	PlayDyingSound();

    if ( class'GameInfo'.static.UseLowGore() )
		return;

	if ( ItBUURRNNNS != none )
	{
		ItBUURRNNNS.Emitters[0].SkeletalMeshActor = none;
		ItBUURRNNNS.Destroy();
	}

	if( ObliteratedEffectClass != none )
		Spawn( ObliteratedEffectClass,,, Location, HitRotation );

    super.SpawnGibs(HitRotation,ChunkPerterbation);

    if ( FRand() < 0.1 )
	{
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
	}
	else if ( FRand() < 0.25 )
	{
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
		if ( FRand() < 0.5 )
		{
			SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
		}
	}
	else if ( FRand() < 0.35 )
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation );
	else if ( FRand() < 0.5 )
	{
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation );
	}
}

simulated function StartDeRes()
{
	if( Level.NetMode == NM_DedicatedServer )
		return;

	AmbientGlow=0;
	MaxLights=5;

	// DeResFX = Spawn(class'DeResPart', self, , Location);
	//Skins[0] = DeResMat0;
	//Skins[1] = DeResMat1;

	if( Physics == PHYS_KarmaRagdoll )
	{
		// Remove flames
		RemoveFlamingEffects();
		// Turn off any overlays
		SetOverlayMaterial(None, 0.0f, true);
	}
}

// Remove Shield Sounds , Randomize for Human Pain sound.

function int ShieldAbsorb(int dam)
{
	local float Interval, damage, Remaining;
	//local int PainSound;

	damage = dam;

	if ( ShieldStrength == 0 )
		return damage;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		damage *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetBodyArmorDamageModifier(KFPlayerReplicationInfo(PlayerReplicationInfo));
	}

      // Super.ShieldAbsorb(dam);
	//SetOverlayMaterial( ShieldHitMat, ShieldHitMatTime, false );

	// Randomize Painsounds on Armor hit
//	PainSound = rand(6);
//	if (PainSound == 0)
//		PlaySound(sound'KFPlayerSound.hpain3', SLOT_Pain,2*TransientSoundVolume,,400);
//	else if (PainSound == 1)
//		PlaySound(sound'KFPlayerSound.hpain2', SLOT_Pain,2*TransientSoundVolume,,400);
//	else if (PainSound == 2)
//		PlaySound(sound'KFPlayerSound.hpain1', SLOT_Pain,2*TransientSoundVolume,,400);
//	else if (PainSound == 3)
//		PlaySound(sound'KFPlayerSound.hpain3', SLOT_Pain,2*TransientSoundVolume,,400);
//	else if (PainSound == 4)
//		PlaySound(sound'KFPlayerSound.hpain2', SLOT_Pain,2*TransientSoundVolume,,400);
//	else if (PainSound == 5)
//		PlaySound(sound'KFPlayerSound.hpain1', SLOT_Pain,2*TransientSoundVolume,,400);

	if ( ShieldStrength > SmallShieldStrength )
	{
		Interval = ShieldStrength - SmallShieldStrength;
		if ( Interval >= 0.75 * damage )
		{
			ShieldStrength -= 0.75 * damage;
			if ( ShieldStrength < SmallShieldStrength )
				SmallShieldStrength = ShieldStrength;
			return (0.25 * Damage);
		}
		else
		{
			ShieldStrength = SmallShieldStrength;
			damage -= Interval;
			Remaining = 0.33 * Interval;
			if ( Remaining <= damage )
				return damage;
			damage -= Remaining;
		}
	}

	if ( ShieldStrength >= 0.5 * damage )
	{
		ShieldStrength -= damage ;
		SmallShieldStrength = ShieldStrength;
		return Remaining + (0.25 * damage);   // 0.5
	}
	else
	{
		damage -= ShieldStrength;
		ShieldStrength = 0;
		SmallShieldStrength = 0;
	}

	return damage + Remaining;
}

// Play the pawn firing animations
simulated function StartFiringX(bool bAltFire, bool bRapid)
{
    local name FireAnim;
    local int AnimIndex;

    if ( HasUDamage() && (Level.TimeSeconds - LastUDamageSoundTime > 0.25) )
    {
        LastUDamageSoundTime = Level.TimeSeconds;
        PlaySound(UDamageSound, SLOT_None, 1.5*TransientSoundVolume,,700);
    }

    if (Physics == PHYS_Swimming)
        return;

    AnimIndex = Rand(4);

    if (bAltFire)
    {
        if( bIsCrouched )
        {
            FireAnim = FireCrouchAltAnims[AnimIndex];
        }
        else
        {
            FireAnim = FireAltAnims[AnimIndex];
        }
    }
    else
    {
        if( bIsCrouched )
        {
            FireAnim = FireCrouchAnims[AnimIndex];
        }
        else
        {
            FireAnim = FireAnims[AnimIndex];
        }
    }

    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

    if (bRapid)
    {
        if (FireState != FS_Looping)
        {
            LoopAnim(FireAnim,, 0.0, 1);
            FireState = FS_Looping;
        }
    }
    else
    {
        PlayAnim(FireAnim,, 0.0, 1);
        FireState = FS_PlayOnce;
    }

    IdleTime = Level.TimeSeconds;
}

simulated function StopFiring()
{
    if (FireState == FS_Looping)
        FireState = FS_PlayOnce;
    IdleTime = Level.TimeSeconds;
}

simulated function AnimEnd(int Channel)
{
    if (Channel == 1)
    {
        if (FireState == FS_Ready)
        {
            AnimBlendToAlpha(1, 0.0, 0.12);
            FireState = FS_None;
        }
        else if (FireState == FS_PlayOnce)
        {
            if( bIsCrouched )
            {
                PlayAnim(PostFireBlendCrouchAnim,, 0.1, 1);
            }
            else
            {
                PlayAnim(PostFireBlendStandAnim,, 0.1, 1);
            }

            FireState = FS_Ready;
            IdleTime = Level.TimeSeconds;
        }
        else
            AnimBlendToAlpha(1, 0.0, 0.12);
    }
    else if ( bKeepTaunting && (Channel == 0) )
		PlayVictoryAnimation();
}


function RemoveInventorySP( class<inventory> ItemClass )
{
    // If this item is in our inventory chain, unlink it.
    local actor Link;
    local int Count;
    local inventory Item ;

    Item = spawn(ItemClass) ;

    if ( ItemClass == Weapon.class )
        Weapon = None;
    if ( ItemClass == SelectedItem.class )
        SelectedItem = None;
    for( Link = Self; Link!=None; Link=Link.Inventory )
    {
        if( Link.Inventory.class == ItemClass )
        {
            Link.Inventory = Item.Inventory;
            Item.Inventory = None;
            Link.NetUpdateTime = Level.TimeSeconds - 1;
            Item.NetUpdateTime = Level.TimeSeconds - 1;
            break;
        }
        if ( Level.NetMode == NM_Client )
        {
        Count++;
        if ( Count > 1000 )
            break;
    }
    }
    Item.SetOwner(None);
}

// another one cut-n-pasted to remove must-have-ammo fetish
exec function SwitchToLastWeapon()
{
	if ( (Weapon != None) && (Weapon.OldWeapon != None) ) // && Weapon.OldWeapon.HasAmmo() )
	{
		PendingWeapon = Weapon.OldWeapon;
		Weapon.PutDown();
	}
}

// TODO: GetWeapon

simulated function AddHealth()
{
    local int tempHeal ;
    if((level.TimeSeconds - lastHealTime) >= 0.1)
    {
        if(Health < HealthMax)
        {
            tempHeal = int(10 * (level.TimeSeconds - lastHealTime)) ;
            if(tempHeal>0)
              lastHealTime = level.TimeSeconds ;

            Health = Min(Health+tempHeal, HealthMax);
            HealthToGive -= tempHeal ;
        }
        else
        {
            lastHealTime = level.timeSeconds ;
            // if we are all healed, there's gonna be no more healing
            HealthToGive = 0 ;
        }
    }
}

function bool GiveHealth(int HealAmount, int HealMax)
{
    // Taking this out for now because it nerfs the high level medic perks - Ramm
//	if(healAmount >= 50)
//		healAmount = 50;

    // If someone gets healed while burning, reduce the burn length/damage
    if( BurnDown > 0 )
    {
        if( BurnDown > 1 )
        {
            BurnDown *= 0.5;
        }

        LastBurnDamage *= 0.5;
    }

    // Don't let them heal more than the max health
	if( (healAmount + HealthToGive + Health) > HealthMax)
	{
		healAmount = HealthMax - (Health + HealthToGive);

		if( healAmount == 0 )
		{
            return false;
		}
	}

	if( Health<HealMax )
	{
		HealthToGive+=HealAmount;
		lastHealTime = level.timeSeconds;
		return true;
	}
	Return False;
}

function ThrowGrenade()
{
    local inventory inv;
    local Frag aFrag;

    for ( inv = inventory; inv != none; inv = inv.Inventory )
    {
        aFrag = Frag(inv);

        if ( aFrag != none && aFrag.HasAmmo() && !bThrowingNade )
        {
            if ( KFWeapon(Weapon) == none || Weapon.GetFireMode(0).NextFireTime - Level.TimeSeconds > 0.1 ||
                 (KFWeapon(Weapon).bIsReloading && !KFWeapon(Weapon).InterruptReload()) )
            {
                return;
            }

            //TODO: cache this without setting SecItem yet
            //SecondaryItem = aFrag;
            KFWeapon(Weapon).ClientGrenadeState = GN_TempDown;
            Weapon.PutDown();
            break;
            //aFrag.StartThrow();
        }
    }
}

function WeaponDown()
{
    local inventory inv;
    local Frag aFrag;

    for(inv=inventory; inv!=none; inv=inv.Inventory)
    {
        aFrag=Frag(inv);

        if(aFrag!=none && aFrag.HasAmmo() )
        {
            SecondaryItem = aFrag;
            aFrag.StartThrow();
        }
    }
}

simulated function HandleNadeThrowAnim()
{
    if( Weapon != none )
    {
        if( AK47AssaultRifle(Weapon) != none )
        {
            SetAnimAction('Frag_AK47');
        }
        else if( Bullpup(Weapon) != none )
        {
            SetAnimAction('Frag_Bullpup');
        }
        else if( Crossbow(Weapon) != none )
        {
            SetAnimAction('Frag_Crossbow');
        }
        else if( Deagle(Weapon) != none || Magnum44Pistol(Weapon) != none || MK23Pistol(Weapon) != none)
        {
            SetAnimAction('Frag_Single9mm');
        }
        else if( KFWeapon(Weapon) != none && KFWeapon(Weapon).bDualWeapon )
        {
            SetAnimAction('Frag_Dual9mm');
        }
        else if( FlameThrower(Weapon) != none )
        {
            SetAnimAction('Frag_Flamethrower');
        }
        else if( Axe(Weapon) != none || DwarfAxe(Weapon) != none )
        {
            SetAnimAction('Frag_Axe');
        }
        else if( Chainsaw(Weapon) != none )
        {
            SetAnimAction('Frag_Chainsaw');
        }
        else if( Katana(Weapon) != none || ClaymoreSword(Weapon) != none )
        {
            SetAnimAction('Frag_Katana');
        }
        else if( Knife(Weapon) != none )
        {
            SetAnimAction('Frag_Knife');
        }
        else if( Machete(Weapon) != none )
        {
            SetAnimAction('Frag_Knife');
        }
        else if( Syringe(Weapon) != none )
        {
            SetAnimAction('Frag_Syringe');
        }
        else if( Welder(Weapon) != none )
        {
            SetAnimAction('Frag_Syringe');
        }
        else if( BoomStick(Weapon) != none )
        {
            SetAnimAction('Frag_HuntingShotgun');
        }
        else if( LAW(Weapon) != none )
        {
            SetAnimAction('Frag_LAW');
        }
        else if( Shotgun(Weapon) != none || BenelliShotgun(Weapon) != none || Trenchgun(Weapon) != none)
        {
            SetAnimAction('Frag_Shotgun');
        }
        else if( Winchester(Weapon) != none )
        {
            SetAnimAction('Frag_Winchester');
        }
        else if( Single(Weapon) != none )
        {
            SetAnimAction('Frag_Single9mm');
        }
        else if( M14EBRBattleRifle(Weapon) != none )
        {
            SetAnimAction('Frag_M14');
        }
        else if( SCARMK17AssaultRifle(Weapon) != none )
        {
            SetAnimAction('Frag_SCAR');
        }
        else if( AA12AutoShotgun(Weapon) != none || FNFAL_ACOG_AssaultRifle(Weapon) != none )
        {
            SetAnimAction('Frag_AA12');
        }
        else if( MP5MMedicGun(Weapon) != none || KSGShotgun(Weapon) != none )
        {
            SetAnimAction('Frag_MP5');
        }
        else if( MP7MMedicGun(Weapon) != none )
        {
            SetAnimAction('Frag_MP7');
        }
        else if( M7A3MMedicGun(Weapon) != none || KrissMMedicGun(Weapon) != none )
        {
            SetAnimAction('Frag_Kriss');
        }
        else if( PipeBombExplosive(Weapon) != none )
        {
            SetAnimAction('Frag_PipeBomb');
        }
        else if( M79GrenadeLauncher(Weapon) != none )
        {
            SetAnimAction('Frag_M79');
        }
        else if( M32GrenadeLauncher(Weapon) != none )
        {
            SetAnimAction('Frag_M32_MGL');
        }
        else if( M4203AssaultRifle(Weapon) != none || M99SniperRifle(Weapon) != none )
        {
            SetAnimAction('Frag_M4203');
        }
        else if( M4AssaultRifle(Weapon) != none || MKb42AssaultRifle(Weapon) != none)
        {
            SetAnimAction('Frag_M4');
        }
        else if( HuskGun(Weapon) != none )
        {
            SetAnimAction('Frag_HuskGun');
        }
        else if( ZEDGun(Weapon) != none )
        {
            SetAnimAction('Frag_Zed');
        }
        else if( NailGun(Weapon) != none )
        {
            SetAnimAction('Frag_Bullpup');
        }
        else if( ThompsonSMG(Weapon) != none )
        {
            SetAnimAction('Frag_Thompson');
        }
        else if( Scythe(Weapon) != none )
        {
            SetAnimAction('Frag_Scythe');
        }
        else if( Crossbuzzsaw(Weapon) != none )
        {
            SetAnimAction('Frag_Cheetah');
        }
        else if( FlareRevolver(Weapon) != none )
        {
            SetAnimAction('Frag_Single9mm');
        }
    }
    else
    {
        SetAnimAction('Frag_Knife');
    }
}


simulated function ThrowGrenadeFinished()
{
  SecondaryItem = none;
  KFWeapon(Weapon).ClientGrenadeState = GN_BringUp;
  Weapon.BringUp();
  bThrowingNade = false;
}

simulated function SetNadeTimeOut(float NewTimeOut)
{
    NadeThrowTimeout = NewTimeOut;
}

/* Feet height adjusting functions ======================================================*/
simulated function SetFootHeight( float HeightMulti, byte iNum )
{
//	local rotator R;
//
//	OldAdjust[iNum] = (HeightMulti-OldAdjust[iNum])*0.5+OldAdjust[iNum];
//	if( Abs(OldAdjust[iNum]-HeightMulti)<0.1 )
//		OldAdjust[iNum] = HeightMulti;
//	HeightMulti = OldAdjust[iNum];
//	HeightMulti = 1.f-HeightMulti; // Invert this value.
//	switch( FeetAdjSpec.Default.TorseRotType )
//	{
//	case BRot_Yaw:
//		R.Yaw = FeetAdjSpec.Default.MaxTorsoTurn*HeightMulti;
//		break;
//	case BRot_Roll:
//		R.Roll = FeetAdjSpec.Default.MaxTorsoTurn*HeightMulti;
//		break;
//	default:
//		R.Pitch = FeetAdjSpec.Default.MaxTorsoTurn*HeightMulti;
//	}
//	SetBoneRotation(FeetAdjSpec.Default.TorsoBones[iNum],R);
//	R = rot(0,0,0);
//	switch( FeetAdjSpec.Default.KneeRotType )
//	{
//	case BRot_Yaw:
//		R.Yaw = FeetAdjSpec.Default.MaxKneeTurn*HeightMulti;
//		break;
//	case BRot_Roll:
//		R.Roll = FeetAdjSpec.Default.MaxKneeTurn*HeightMulti;
//		break;
//	default:
//		R.Pitch = FeetAdjSpec.Default.MaxKneeTurn*HeightMulti;
//	}
//	SetBoneRotation(FeetAdjSpec.Default.KneeBones[iNum],R);
}
simulated function UpdateFeetCoords()
{
//	local Coords C;
//	local byte i;
//	local vector X,Y,Z,HL,Pos;
//
//	GetAxes(Rotation,X,Y,Z);
//	Pos = Location+PrePivot;
//	for( i=0; i<2; i++ )
//	{
//		C = GetBoneCoords(FeetAdjSpec.Default.FeetBones[i]);
//		C.Origin = (C.Origin-Pos)<<Rotation;
//		C.Origin = X*C.Origin.X+Y*C.Origin.Y+Pos-Z*MinZHeight*DrawScale;
//		C.XAxis = C.Origin-Z*MaxZHeight*DrawScale;
//		if( Trace(HL,C.YAxis,C.XAxis,C.Origin,true)==None )
//			SetFootHeight(1,i);
//		else SetFootHeight(FClamp(VSize(HL-C.Origin)/DrawScale/MaxZHeight,0.f,1.f),i);
//	}
}
/* End of feet height adjusting functions ======================================================*/

simulated function Tick(float DeltaTime)
{
//	local float DMult;

    if( Role < ROLE_Authority && bThrowingNade )
    {
        if( NadeThrowTimeout > 0 )
    {
        NadeThrowTimeout -= DeltaTime;
        }
// This is a hack to clear this flag on the client after a bit of time. This fixes a bug where you could get stuck unable to use weapons
        if( NadeThrowTimeout <= 0 )
        {
            NadeThrowTimeout = 0;
            ThrowGrenadeFinished();
        }
    }

	// IN other words - we're moving, we've got a piece, but we're not firing or reloading, or jumping / falling Faust:Perhaps we need that later: VSize(Acceleration) != 0 &&
	if (level.NetMode != NM_DEDICATEDSERVER)
	{
		if(bBurnified && !bBurnApplied)
		{
			if ( !bGibbed )
			{
				StartBurnFX();
			}
		}
		else if(!bBurnified && bBurnApplied)
			StopBurnFX();
	}

       // CheckFlashLightAnims();

	if( bResetingAnimAct && (AnimActResetTime<Level.TimeSeconds) ) // Reset replication.
	{
		bResetingAnimAct = False;
		AnimAction = '';
	}
	if(healthToGive > 0 && health > 0)  //
		AddHealth() ;
	else if(healthToGive < 0)
		healthToGive = 0 ;

	if(BileCount>0 && NextBileTime<level.TimeSeconds)
	{
		--BileCount;
		NextBileTime+=BileFrequency;
		TakeBileDamage();
	}
//	if( bHasFootAdjust && (Level.TimeSeconds-LastRenderTime)<1 )
//	{
//		UpdateFeetCoords();
//		if( Level.NetMode!=NM_ListenServer )
//		{
//			if( Physics!=PHYS_Walking )
//				DMult = 1;
//			else DMult = OldAdjust[0]+OldAdjust[1];
//			if( DMult<1.65 && PrePivot.Z<0 )
//			{
//				PrePivot.Z+=DeltaTime*60f;
//				SetDrawScale(DrawScale);
//			}
//			else if( DMult>1.85 && PrePivot.Z>-35 )
//			{
//				PrePivot.Z-=DeltaTime*60f;
//				SetDrawScale(DrawScale);
//			}
//		}
//	}

//  KFTODO: Maybe take this out because we're using notifies for footsteps in third person now
//	if( Level.Netmode != NM_DedicatedServer )
//	{
//		// do footsteps for nonlocal pawns and bots
//		if( !IsLocallyControlled() || (Level.Netmode == NM_Standalone && !IsHumanControlled()))
//		{
//			CheckFootSteps(DeltaTime);
//		}
//	}

	if( Physics == PHYS_KarmaRagdoll && bDestroyAfterRagDollTick &&
        !bProcessedRagTickDestroy && GetRagDollFrames() > 0 )
	{
        bProcessedRagTickDestroy = true;
        Destroy();
	}

	Super.Tick(deltaTime);
}

// Blend the upper body back to full body animation.
// Called by the native code when AnimBlendTime counts down to zero
simulated event AnimBlendTimer()
{
	AnimBlendToAlpha(1, 0.0, 0.12);
	// Force a new idle anim to play, since we likely just switched weapons
	bIsIdle=false;
	IdleTime = Level.TimeSeconds;
}

simulated event SetAnimAction(name NewAction)
{
    local float UsedBlendOutTime;

	if( NewAction=='' )
		Return;
	if (!bWaitForAnim)
	{
		AnimAction = NewAction;

		if ( AnimAction == 'Weapon_Switch' )
		{
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
            // Set the timer to blend out the upper body animation
            if( HasAnim( AnimAction ) )
            {
                UsedBlendOutTime = GetAnimDuration(NewAction, 1.0);
            }
            else
            {
                UsedBlendOutTime = 0.2;
            }
            AnimBlendTime = UsedBlendOutTime + 0.1;
		}
		else if ( AnimAction == IdleWeaponAnim )
		{
            PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
		}
		else if ( AnimAction == 'Reload' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'AxeAttack' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'ChainSawAttack' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'DeagleHold' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			LoopAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'DualiesHold' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			LoopAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'Frag_AK47' || AnimAction == 'Frag_Bullpup'
            || AnimAction == 'Frag_Crossbow' || AnimAction == 'Frag_Single9mm'
            || AnimAction == 'Frag_Dual9mm' || AnimAction == 'Frag_Flamethrower'
            || AnimAction == 'Frag_Axe' || AnimAction == 'Frag_Chainsaw'
            || AnimAction == 'Frag_Katana' || AnimAction == 'Frag_Knife'
            || AnimAction == 'Frag_Syringe' || AnimAction == 'Frag_HuntingShotgun'
            || AnimAction == 'Frag_LAW' || AnimAction == 'Frag_Shotgun'
            || AnimAction == 'Frag_M14' || AnimAction == 'Frag_SCAR'
            || AnimAction == 'Frag_AA12' || AnimAction == 'Frag_MP7'
            || AnimAction == 'Frag_PipeBomb' || AnimAction == 'Frag_M79'
            || AnimAction == 'Frag_M32_MGL' || AnimAction == 'Frag_M4'
            || AnimAction == 'Frag_M4203' || AnimAction == 'Frag_MP5'
            || AnimAction == 'Frag_HuskGun' || AnimAction == 'Frag_Kriss'
            || AnimAction == 'Frag_Thompson' || AnimAction == 'Frag_scythe'
            || AnimAction == 'Frag_Cheetah' || AnimAction == 'Frag_Zed')
		{
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
			bThrowingNade = true;
		}
		else if ( AnimAction == 'ShotgunFire' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
		}
		else if ( AnimAction == 'DeagleBlast' )
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.0, 1);
		} // Reloads
		else if ( AnimAction == 'Reload1' || AnimAction == 'Reload_BullPup'
            || AnimAction == 'Reload_Single9mm' || AnimAction == 'Reload_Winchester'
            || AnimAction == 'Reload_Crossbow' || AnimAction == 'Reload_Dual9mm'
            || AnimAction == 'Reload_Flamethrower' || AnimAction == 'Reload_HuntingShotgun'
            || AnimAction == 'Reload_LAW' || AnimAction == 'Reload_Shotgun'
            || AnimAction == 'Reload_Winchester' || AnimAction == 'Reload_AK47'
            || AnimAction == 'Reload_M14' || AnimAction == 'Reload_SCAR'
            || AnimAction == 'Reload_MP7' || AnimAction == 'Reload_AA12'
            || AnimAction == 'Reload_Secondary_M4203' || AnimAction == 'Reload_Fal_Acog'
            || AnimAction == 'Reload_Fal_Acog' || AnimAction == 'Reload_M7A3'
            || AnimAction == 'Reload_KSG' || AnimAction == 'Reload_Flare'
            || AnimAction == 'Reload_DualFlare' || AnimAction == 'Reload_Cheetah'
            || AnimAction == 'Reload_Thompson' || AnimAction == 'Reload_Kriss'
            || AnimAction == 'Reload_Zed')
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.1, 1);
			FireState = FS_Ready;
		}
		else if ( ((Physics == PHYS_None)|| ((Level.Game != None) && Level.Game.IsInState('MatchOver'))) && (DrivenVehicle == None) )
		{
			PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
		}
		else if ( (DrivenVehicle != None) || (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
		{
			if ( CheckTauntValid(AnimAction) )
			{
				if (FireState == FS_None || FireState == FS_Ready)
				{
					AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
					PlayAnim(NewAction,, 0.1, 1);
					FireState = FS_Ready;
				}
			}
			else if ( HasAnim(AnimAction) && PlayAnim(AnimAction) )
			{
				if ( Physics != PHYS_None )
					bWaitForAnim = true;
			}
			else AnimAction = NewAction;
		}
		else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(AnimAction,,0.1,1);
		}
		else if (FireState == FS_None || FireState == FS_Ready)
		{
			AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
			PlayAnim(NewAction,, 0.1, 1);
			FireState = FS_Ready;
		}
	}
	if( Level.NetMode!=NM_Client )
	{
		// Reset to fix replication.
		bResetingAnimAct = True;
		AnimActResetTime = Level.TimeSeconds+0.45;
	}
}

simulated function StartBurnFX()
{
    if( bDeleteMe )
    {
        return;
    }

	if( ItBUURRNNNS==None )
	{
		ItBUURRNNNS = Spawn(BurnEffect);
		ItBUURRNNNS.SetBase(Self);
		ItBUURRNNNS.Emitters[0].SkeletalMeshActor = self;
		ItBUURRNNNS.Emitters[0].UseSkeletalLocationAs = PTSU_SpawnOffset;
	}
	bBurnApplied = True;
}

simulated function StopBurnFX()
{
	RemoveFlamingEffects();
	if( ItBUURRNNNS!=None )
		ItBUURRNNNS.Kill();
	bBurnApplied = False;
}

// Process a precision hit
function ProcessLocationalDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, array<int> PointsHit )
{
	local int actualDamage, originalDamage, cumulativeDamage, totalDamage, i;
	local int HighestDamagePoint, HighestDamageAmount;
	local bool bHeadShot;
	// Hit detection debugging
//    local coords CO;
//	local vector HeadLoc;
//	local bool bFirstHit;

    originalDamage = damage;

	// If someone else has killed this player , return
	if( bDeleteMe || PointsHit.Length < 1 || Health <= 0 )
		return;

    // Don't process locational damage if we're not going to damage a friendly anyway
	if( TeamGame(Level.Game)!=None && TeamGame(Level.Game).FriendlyFireScale==0 && instigatedBy!=None && instigatedBy!=Self
	 && instigatedBy.GetTeamNum()==GetTeamNum() )
    {
        Return;
    }

	for(i=0; i<PointsHit.Length; i++)
	{
		// If someone else has killed this player , return
		if( bDeleteMe || Health <= 0 )
			return;

		actualDamage = originalDamage;

		actualDamage *= Hitpoints[PointsHit[i]].DamageMultiplier;
		totalDamage += actualDamage;
		actualDamage = Level.Game.ReduceDamage(actualDamage, self, instigatedBy, HitLocation, Momentum, DamageType);
		cumulativeDamage += actualDamage;

		if( actualDamage > HighestDamageAmount )
		{
			HighestDamageAmount = actualDamage;
			HighestDamagePoint = PointsHit[i];
		}

        // Store if one of the shots was a headshot
        if( Hitpoints[PointsHit[i]].HitPointType == PHP_Head && class<KFWeaponDamageType>(damageType)!=none &&
            class<KFWeaponDamageType>(damageType).default.bCheckForHeadShots)
        {
            bHeadShot = true;
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

		// Lets exit out if one of the shots killed the player
		if ( cumulativeDamage >=  Health )
		{
		    // Play a sound when someone gets a headshot - KFTODO: Replace this with a better bullet hitting a helmet sound
		    if( bHeadShot )
		    {
                PlaySound(sound'ProjectileSounds.impact_metal09', SLOT_None,2.0,true,500);
            }
            TakeDamage(totalDamage, instigatedBy, hitlocation, momentum, damageType, HighestDamagePoint);
		}
	}

	if( totalDamage > 0 )
	{
		// If someone else has killed this player , return
		if( bDeleteMe || Health <= 0 )
			return;

	    // Play a sound when someone gets a headshot
	    if( bHeadShot )
	    {
            // Play a sound when someone gets a headshot - KFTODO: Replace this with a better bullet hitting a helmet sound
            PlaySound(sound'ProjectileSounds.impact_metal09', SLOT_None,2.0,true,500);
        }

		TakeDamage(totalDamage, instigatedBy, hitlocation, momentum, damageType, HighestDamagePoint);
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

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIdx )
{
    local KFPlayerReplicationInfo KFPRI;

	LastHitDamType = damageType;
	LastDamagedBy = instigatedBy;

	super.TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);

	healthtoGive-=5;

    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

    // Just return if this wouldn't even damage us. Prevents us from catching on fire for high level perks that dont take fire damage
    if( KFPRI != none &&  KFPRI.ClientVeteranSkill != none )
    {
	   if( KFPRI.ClientVeteranSkill.Static.ReduceDamage(KFPRI, self, KFMonster(instigatedBy), Damage, DamageType) <= 0 )
	   {
	       return;
	   }
    }

	if ( class<DamTypeBurned>(damageType) != none || class<DamTypeFlamethrower>(damageType) != none)
	{
		if( TeamGame(Level.Game)!=None && TeamGame(Level.Game).FriendlyFireScale==0 && instigatedBy!=None && instigatedBy!=Self
		 && instigatedBy.GetTeamNum()==GetTeamNum()  )
        {
            Return;
        }

        // Do burn damage if the damage was significant enough
        if( Damage > 2 )
        {
            // If we are already burning, and this damage is more than our current burn amount, add more burn time
            if( BurnDown > 0 && Damage > LastBurnDamage )
            {
                BurnDown = 5;
                BurnInstigator = instigatedBy;
            }

            LastBurnDamage = Damage;

            if (BurnDown <= 0 )
            {
                bBurnified = true;
                BurnDown = 5;
                BurnInstigator = instigatedBy;
                SetTimer(1.5,true);
            }
        }
	}

	if(class<DamTypeVomit>(DamageType)!=none)
	{
		BileCount=7;
		BileInstigator = instigatedBy;
		if(NextBileTime< Level.TimeSeconds )
			NextBileTime = Level.TimeSeconds+BileFrequency;

		if ( Level.Game != none && Level.Game.GameDifficulty >= 4.0 && KFPlayerController(Controller) != none &&
			 !KFPlayerController(Controller).bVomittedOn)
		{
			KFPlayerController(Controller).bVomittedOn = true;
			KFPlayerController(Controller).VomittedOnTime = Level.TimeSeconds;

			if ( Controller.TimerRate == 0.0 )
			{
				Controller.SetTimer(10.0, false);
			}
		}
	}
}

function TakeBileDamage()
{
	Super.TakeDamage(2+Rand(3), BileInstigator, Location, vect(0,0,0), class'DamTypeVomit');
	healthtoGive-=5;
}

function bool AddShieldStrength(int ShieldAmount)
{
	if(ShieldStrength >= 100)
		return false;

	ShieldStrength+=ShieldAmount;
	if(ShieldStrength > 100)
		ShieldStrength = 100;
	return true ;
}

function TakeFireDamage(int Damage, pawn BInstigator)
{
	if( Damage > 0 )
    {
        TakeDamage(Damage, BInstigator, Location, vect(0,0,0), class'DamTypeBurned');

    	if (BurnDown > 0)
    	{
    		BurnDown --; // Decrement the number of FireDamage calls left before our Zombie is extinguished :)
    	}
    	if(BurnDown==0)
    	{
            bBurnified = false;
    	}
	}
	else
	{
        BurnDown = 0;
        bBurnified = false;
	}
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HI )
{
    local Vector HitNormal;
    local Vector HitRay;
    local Name HitBone;
    local float HitBoneDist;
    local PlayerController PC;
    local bool bShowEffects, bRecentHit;
	local ProjectileBloodSplat BloodHit;
	local rotator SplatRot;

	bRecentHit = Level.TimeSeconds - LastPainTime < 0.2;

    // Take you out of ironsights when taking momentum from damage
    if( VSize(Momentum) > 0 && KFWeapon(Weapon) != none )
    {
        KFWeapon(Weapon).bForceLeaveIronsights = true;
    }

    if ( Damage <= 0 )
        return;

	// Call the modified version of the original Pawn playhit
	OldPlayHit(Damage,InstigatedBy,HitLocation,DamageType,Momentum);

    PC = PlayerController(Controller);
    bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 2.5)
					|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None))
					|| (PC != None) );
    if ( !bShowEffects )
        return;

	if ( BurnDown > 0 && !bBurnified )
		bBurnified = true;

    HitRay = vect(0,0,0);
    if( InstigatedBy != None )
        HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));

    if( DamageType.default.bLocationalHit )
	{
        CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );
	}
    else
    {
        HitLocation = Location;
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
		if ( !class'GameInfo'.static.NoBlood() )
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

    // hack for siren
    if ( (DamageType.name == 'SirenScreamDamage') && (Health < 0) )
    {
        if( (InstigatedBy != None) && (VSize(InstigatedBy.Location - Location) < 200) )
        {
            DoDamageFX( 'obliterate', 5000 * Damage, DamageType, Rotator(HitNormal) );
        }
        else
        {
            DoDamageFX( HeadBone, 5000 * Damage, DamageType, Rotator(HitNormal) );
            PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
        }
    }
    else
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

				spawn(DesiredEmitter,,,HitLocation+HitNormal + (-HitNormal * CollisionRadius), Rotator(HitNormal));
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

simulated function AttachEffect( class<xEmitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
{
    local Actor a;
    local int i;

    if( bSkeletized || (BoneName == 'None') )
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

    if (a == none)
     return;

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

simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );
    if( Giblet == None )
        return;

	Giblet.bFlaming = bFlaming;
	Giblet.SpawnTrail();

    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (250 + 260 * FRand());
    Giblet.LifeSpan = Giblet.LifeSpan + 2 * FRand() - 1;
}

State Dying
{
	simulated function AnimEnd( int Channel );

	simulated function bool SpecialCalcView( out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local Coords Co;
		local vector HL,HN;

		ViewActor = Self;
		Co = GetBoneCoords('CHR_Head');
		CameraLocation = Co.Origin+Co.XAxis*8;
		// Make sure camera dosent show through world geometry.
		if( Trace(HL,HN,CameraLocation+vect(0,0,25),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		if( Trace(HL,HN,CameraLocation-vect(0,0,25),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		if( Trace(HL,HN,CameraLocation+vect(25,0,0),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		if( Trace(HL,HN,CameraLocation-vect(25,0,0),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		if( Trace(HL,HN,CameraLocation+vect(0,25,0),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		if( Trace(HL,HN,CameraLocation-vect(0,25,0),CameraLocation,False)!=None )
			CameraLocation+=HN*25;
		GetAxes(GetBoneRotation('CHR_Head'),Co.XAxis,Co.YAxis,Co.ZAxis);
		CameraRotation = OrthoRotation(-Co.YAxis,Co.ZAxis,Co.XAxis); // Turns the camera by 90 degrees.
		Return True;
	}
	event FellOutOfWorld(eKillZType KillType)
	{
		local LavaDeath LD;

		// If we fall past a lava killz while dead- burn off skin.
		if( KillType == KILLZ_Lava )
		{
			if ( !bSkeletized )
			{
				if ( SkeletonMesh != None )
				{
					LinkMesh(SkeletonMesh, true);
					Skins.Length = 0;
				}
				bSkeletized = true;

				LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
				if ( LD != None )
					LD.SetBase(self);
				// This should destroy itself once its finished.
				PlaySound( sound'Inf_Weapons.F1.f1_explode01', SLOT_None, 1.5*TransientSoundVolume ); // KFTODO: Replace this sound
			}
			return;
		}
		Super.FellOutOfWorld(KillType);
	}

	simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HI )
	{
		local emitter BloodHit;

		Health -= Damage;

		if (Health <= -200)
		{
			// Gibbed
			BloodHit = Spawn(class'KFMod.FeedingSpray',InstigatedBy,,Location,Rotation);

			// KFTODO: Replace this spawn giblet with
//            SpawnGiblet(class 'ClotGibHead',HitLocation, self.Rotation, 0.06 ) ;
//
//			SpawnGiblet(class 'ClotGibTorso',HitLocation, self.Rotation, 0.06) ;
//			SpawnGiblet(class 'ClotGibLowerTorso',HitLocation, self.Rotation, 0.06 ) ;
//
//			SpawnGiblet(class 'ClotGibArm',HitLocation, self.Rotation, 0.06 ) ;
//			SpawnGiblet(class 'ClotGibArm',HitLocation, self.Rotation, 0.06 ) ;
//
//			SpawnGiblet(class 'ClotGibThigh',HitLocation, self.Rotation, 0.06 ) ;
//			SpawnGiblet(class 'ClotGibThigh',HitLocation, self.Rotation, 0.06 ) ;
//
//			SpawnGiblet(class 'ClotGibLeg',HitLocation, self.Rotation, 0.06 ) ;
//			SpawnGiblet(class 'ClotGibLeg',HitLocation, self.Rotation, 0.06 ) ;

        	if( Physics == PHYS_KarmaRagdoll )
        	{
                bDestroyAfterRagDollTick = true;
        	}
        	else
        	{
                Destroy();
        	}
		}
	}

	simulated function BeginState()
	{
		local int i;

		bSpecialCalcView = Class'KFPawn'.Default.bRealDeathType;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else Controller.Destroy();
		}
		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();
		AmbientSound = None;
		if( Level.NetMode==NM_DedicatedServer )
			SetTimer(1,False);
		SetTimer(5,False);
	}

	simulated function Timer()
	{
        if( Level.NetMode==NM_DedicatedServer )
		{
			Destroy();
			Return;
		}
		if( Physics!=PHYS_None )
		{
			if( VSize(Velocity)>10 )
			{
				SetTimer(1,False);
				Return;
			}
			SetPhysics(PHYS_None);
			SetTimer(30,False);
			if(PlayerShadow != None)
				PlayerShadow.bShadowActive = false;
		}
		else if( (Level.TimeSeconds-LastRenderTime)>40 || Level.bDropDetail )
			Destroy();
		else SetTimer(5,False);
	}

	// We shorten the lifetime when the guys comes to rest.
	// Alex: No , you dont.
	event KVelDropBelow()
	{
	}
}

simulated event Destroyed()
{
	if ( ItBUURRNNNS != none )
	{
		ItBUURRNNNS.Emitters[0].SkeletalMeshActor = none;
		ItBUURRNNNS.Destroy();
	}

	if( Adjuster!=None )
		Adjuster.Destroy();

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

	if ( AuxCollisionCylinder != none )
	{
	    AuxCollisionCylinder.Destroy();
	}

	if ( AttachedEmitter != none )
	{
	    AttachedEmitter.Destroy();
	}

	Super.Destroyed();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Vector            TossVel;
	local Trigger           T;
	local NavigationPoint   N;
	local PlayerDeathMark D;
	local Projectile PP;
	local FakePlayerPawn FP;

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

	// Hack fix for team-killing.
	if( KFPlayerReplicationInfo(PlayerReplicationInfo)!=None )
	{
		FP = KFPlayerReplicationInfo(PlayerReplicationInfo).GetBlamePawn();
		if( FP!=None )
		{
			ForEach DynamicActors(Class'Projectile',PP)
			{
				if( PP.Instigator==Self )
					PP.Instigator = FP;
			}
		}
	}

	D = Spawn(Class'PlayerDeathMark');
	if( D!=None )
		D.Velocity = Velocity;

	Health = Min(0, Health);

	if ( Weapon != None && (DrivenVehicle == None || DrivenVehicle.bAllowWeaponToss) )
	{
		if ( Controller != None )
			Controller.LastPawnWeapon = Weapon.Class;
		Weapon.HolderDied();
		TossVel = Vector(GetViewRotation());
		TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
		TossWeapon(TossVel);
	}
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
	else Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	DrivenVehicle = None;

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else TriggerEvent(Event, self, None);

	// make sure to untrigger any triggers requiring player touch
	if ( IsPlayerPawn() || WasPlayerPawn() )
	{
		PhysicsVolume.PlayerPawnDiedInVolume(self);
		ForEach TouchingActors(class'Trigger',T)
			T.PlayerToucherDied(self);

		// event for HoldObjectives
		ForEach TouchingActors(class'NavigationPoint', N)
			if ( N.bReceivePlayerToucherDiedNotify )
				N.PlayerToucherDied( Self );
	}
	// remove powerup effects, etc.
	RemovePowerups();

	Velocity.Z *= 1.3;

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	NetUpdateFrequency = Default.NetUpdateFrequency;
	PlayDying(DamageType, HitLocation);
	if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
		ClientDying(DamageType, HitLocation);
}

simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation )
{
  /*
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
        */
}


// toss some of your cash away. (to help a cash-strapped ally or perhaps just to party like its 1994)
exec function TossCash( int Amount )
{
	local Vector X,Y,Z;
	local CashPickup CashPickup ;
	local Vector TossVel;

	if( Amount<=0 )
		Amount = 50;
	Controller.PlayerReplicationInfo.Score = int(Controller.PlayerReplicationInfo.Score); // To fix issue with throwing 0 pounds.
	if( Controller.PlayerReplicationInfo.Score<=0 || Amount<=0 )
		return;
	Amount = Min(Amount,int(Controller.PlayerReplicationInfo.Score));

	GetAxes(Rotation,X,Y,Z);

	TossVel = Vector(GetViewRotation());
	TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

	CashPickup = Spawn(class'CashPickup',,, Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);

	if(CashPickup != none)
	{
		CashPickup.CashAmount = Amount;
		CashPickup.bDroppedCash = true;
		CashPickup.RespawnTime = 0;   // Dropped cash doesnt respawn. For obvious reasons.
		CashPickup.Velocity = TossVel;
		CashPickup.DroppedBy = Controller;
		CashPickup.InitDroppedPickupFor(None);
		Controller.PlayerReplicationInfo.Score -= Amount;

		if ( Level.Game.NumPlayers > 1 && Level.TimeSeconds - LastDropCashMessageTime > DropCashMessageDelay )
		{
			PlayerController(Controller).Speech('AUTO', 4, "");
		}
	}
}

// Used to attach an emitter instead of an xemitter
simulated function AttachEmitterEffect( class<Emitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
{
    local Actor a;
    local int i;

    if( bSkeletized || (BoneName == 'None') )
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

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for( i=0; i<Attached.length; i++ )
    {
        if( Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }

         if( Attached[i].IsA('KFMonsterFlame'))
        {
          Attached[i].LifeSpan = 0.1;
        }
    }
}

simulated function class<KFVeterancyTypes> GetVeteran()
{
	if( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill;
	}

	return class'KFVeterancyTypes'; // The base neutral class.
}

function bool CanCarry( float Weight )
{
	Return True;
}

// Validate that client is not hacking.
function bool CanBuyNow()
{
	local ShopVolume Sh;

	if( KFGameType(Level.Game)==None || KFGameType(Level.Game).bWaveInProgress || PlayerReplicationInfo==None )
		return False;
	foreach TouchingActors(Class'ShopVolume',Sh)
		Return True;
	Return False;
}

function bool ItemIsBuyable( Class<Pickup> IC )
{
	local int i;

	if( LevRls==None )
	{
		ForEach DynamicActors(Class'KFLevelRules',LevRls)
			Break;
		if( LevRls==None )
			Return False;
	}

	For( i=0; i<25; i++ )
	{
		if( LevRls.ItemForSale[i]==IC )
			Return True;
	}

	Return False;
}

simulated function ClientCurrentWeaponSold()
{
	local Inventory I;
	local int Count;

	for ( I = Inventory; I != none && Count < 50; I = I.Inventory)
	{
		if ( I != Weapon && I != PendingWeapon && Weapon(I) != none )
		{
			PendingWeapon = Weapon(I);
			break;
		}

		Count++;
	}

	ChangedWeapon();
}

simulated function ClientForceChangeWeapon(Inventory NewWeapon)
{
	PendingWeapon = Weapon(NewWeapon);
	ChangedWeapon();
}

function ServerBuyWeapon( Class<Weapon> WClass )
{
	local Inventory I, J;
	local float Price;
	local bool bIsDualWeapon, bHasDual9mms, bHasDualHCs, bHasDualRevolvers;
	local bool bIgnoreDualWeaponWeight;
	local bool isLocked;

	if ( !CanBuyNow() || Class<KFWeapon>(WClass) == none || Class<KFWeaponPickup>(WClass.Default.PickupClass) == none )
	{
		return;
	}

    if ( Class<KFWeapon>(WClass).Default.AppID > 0 && Class<KFWeapon>(WClass).Default.UnlockedByAchievement != -1 )
    {

		if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
            (!KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).PlayerOwnsWeaponDLC(Class<KFWeapon>(WClass).Default.AppID) &&
             KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).Achievements[Class<KFWeapon>(WClass).Default.UnlockedByAchievement].bCompleted != 1 ))
		{
		    return;
        }

    }
	else if ( Class<KFWeapon>(WClass).Default.AppID > 0 )
	{
		if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
			!KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).PlayerOwnsWeaponDLC(Class<KFWeapon>(WClass).Default.AppID))
		{
			return;
		}
	}
	else if ( Class<KFWeapon>(WClass).Default.UnlockedByAchievement != -1  )
	{
	    if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
             KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).Achievements[Class<KFWeapon>(WClass).Default.UnlockedByAchievement].bCompleted != 1 )
		{
		    return;
        }
	}

	Price = class<KFWeaponPickup>(WClass.Default.PickupClass).Default.Cost;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
	}

	for ( I=Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==WClass )
		{
			Return; // Already has weapon.
		}

		if ( I.Class == class'Dualies' )
		{
			bHasDual9mms = true;
		}
		else if ( I.Class == class'DualDeagle' )
		{
			bHasDualHCs = true;
		}
		else if ( I.Class == class'Dual44Magnum' )
		{
			bHasDualRevolvers = true;
		}
	}

	if ( WClass == class'DualDeagle' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'Deagle' )
			{
				Price = Price / 2;
				// Due to the way the old KF Mod weapon weights were set up, the
				// dual deagles never added any additional weight above the
				// weight of a single deagle. Additionally, the single 9mm
				// had zero weight, so its total weight was equal to 2 9mms.
				// All other dual weild weapons don't need to do this
				bIgnoreDualWeaponWeight = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualHCs = true;
	}

	if ( WClass == class'Dual44Magnum' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'Magnum44Pistol' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualRevolvers = true;
	}

	if ( WClass == class'DualMK23Pistol' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'MK23Pistol' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
	}

	if ( WClass == class'DualFlareRevolver' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'FlareRevolver' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
	}

	bIsDualWeapon = bIsDualWeapon || WClass == class'Dualies';

    if ( !bIgnoreDualWeaponWeight && !CanCarry(Class<KFWeapon>(WClass).Default.Weight) )
	{
		Return;
	}

    if ( PlayerReplicationInfo.Score < Price )
	{
		Return; // Not enough CASH.
	}

	I = Spawn(WClass);

	if ( I != none )
	{
		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponSpawned(I);
		}

		KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
		KFWeapon(I).FillToInitialAmmo();
		KFWeapon(I).SellValue = Price * 0.75;
		I.GiveTo(self);
		PlayerReplicationInfo.Score -= Price;

		if ( bIsDualWeapon )
		{
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).OnDualsAddedToInventory(bHasDual9mms, bHasDualHCs, bHasDualRevolvers);
		}

        ClientForceChangeWeapon(I);
    }

	SetTraderUpdate();
}

function ServerSellWeapon( Class<Weapon> WClass )
{
	local Inventory I;
	local Single NewSingle;
	local Deagle NewDeagle;
	local Magnum44Pistol New44Magnum;
	local MK23Pistol NewMK23;
	local FlareRevolver NewFlare;
	local float Price;

	if ( !CanBuyNow() || Class<KFWeapon>(WClass) == none || Class<KFWeaponPickup>(WClass.Default.PickupClass) == none )
	{
		SetTraderUpdate();
		Return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I.Class == WClass )
		{
			if ( KFWeapon(I) != none && KFWeapon(I).SellValue != -1 )
			{
				Price = KFWeapon(I).SellValue;
			}
			else
			{
				Price = int(class<KFWeaponPickup>(WClass.default.PickupClass).default.Cost * 0.75);

				if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
				}
			}

			if ( Dualies(I) != none && DualDeagle(I) == none && Dual44Magnum(I) == none
                && DualMK23Pistol(I) == none && DualFlareRevolver(I) == none )
			{
				NewSingle = Spawn(class'Single');
				NewSingle.GiveTo(self);
			}

			if ( DualDeagle(I) != none )
			{
				NewDeagle = Spawn(class'Deagle');
				NewDeagle.GiveTo(self);
				Price = Price / 2;
			}

			if ( Dual44Magnum(I) != none )
			{
				New44Magnum = Spawn(class'Magnum44Pistol');
				New44Magnum.GiveTo(self);
				Price = Price / 2;
			}

			if ( DualMK23Pistol(I) != none )
			{
				NewMK23 = Spawn(class'MK23Pistol');
				NewMK23.GiveTo(self);
				Price = Price / 2;
			}

			if ( DualFlareRevolver(I) != none )
			{
				NewFlare = Spawn(class'FlareRevolver');
				NewFlare.GiveTo(self);
				Price = Price / 2;
			}

			if ( I == Weapon || I == PendingWeapon )
			{
				ClientCurrentWeaponSold();
			}

			PlayerReplicationInfo.Score += Price;

			I.Destroyed();
			I.Destroy();

			SetTraderUpdate();

			if ( KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponDestroyed(WClass);
			}

			return;
		}
	}
}

function ServerBuyKevlar()
{
	local float Cost;
	local int UnitsAffordable;

	Cost = class'Vest'.default.ItemCost * ((100.0 - ShieldStrength) / 100.0);

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
	{
		Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
	}

	if ( !CanBuyNow() || ShieldStrength==100 )
	{
		SetTraderUpdate();
		Return;
	}

	if ( PlayerReplicationInfo.Score >= Cost )
	{
		PlayerReplicationInfo.Score -= Cost;
		ShieldStrength = 100;
	}
	else if ( ShieldStrength > 0 )
	{
		Cost = class'Vest'.default.ItemCost;
		if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
		{
			Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
		}

		Cost /= 100.0;

		UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);

		PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);

		ShieldStrength += UnitsAffordable;
	}

	SetTraderUpdate();
}

function ServerBuyFirstAid()
{
	local int Cost;

	Cost = class'FirstAidKit'.default.ItemCost;

	if( !CanBuyNow() || Health==100 )
	{
		SetTraderUpdate();
		Return;
	}

	if( PlayerReplicationInfo.Score < Cost )
	{
		SetTraderUpdate();
		Return;
	}

	PlayerReplicationInfo.Score -= Cost;
	GiveHealth(100, 100);

	SetTraderUpdate();
}

function ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip )
{
	local Inventory I;
	local float Price;
	local Ammunition AM;
	local KFWeapon KW;
	local int c;
	local float UsedMagCapacity;

	if ( !CanBuyNow() || AClass == None )
	{
		SetTraderUpdate();
		return;
	}

	for ( I=Inventory; I != none; I=I.Inventory )
	{
		if ( I.Class == AClass )
		{
			AM = Ammunition(I);
		}
		else if ( KW == None && KFWeapon(I) != None && (Weapon(I).AmmoClass[0] == AClass || Weapon(I).AmmoClass[1] == AClass) )
		{
			KW = KFWeapon(I);
		}
	}

	if ( KW == none || AM == none )
	{
		SetTraderUpdate();
		return;
	}

	AM.MaxAmmo = AM.default.MaxAmmo;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		AM.MaxAmmo = int(float(AM.MaxAmmo) * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AClass));
	}

	if ( AM.AmmoAmount >= AM.MaxAmmo )
	{
		SetTraderUpdate();
		return;
	}

	Price = class<KFWeaponPickup>(KW.PickupClass).default.AmmoCost * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), KW.PickupClass); // Clip price.

	if ( KW.bHasSecondaryAmmo && AClass == KW.FireModeClass[1].default.AmmoClass )
	{
		UsedMagCapacity = 1; // Secondary Mags always have a Mag Capacity of 1? KW.default.SecondaryMagCapacity;
	}
	else
	{
		UsedMagCapacity = KW.default.MagCapacity;
	}

    if( KW.PickupClass == class'HuskGunPickup' )
    {
        UsedMagCapacity = class<HuskGunPickup>(KW.PickupClass).default.BuyClipSize;
    }

	if ( bOnlyClip )
	{
		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			if( KW.PickupClass == class'HuskGunPickup' )
            {
                c = UsedMagCapacity * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AM.Class);
            }
            else
            {
                c = UsedMagCapacity * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMagCapacityMod(KFPlayerReplicationInfo(PlayerReplicationInfo), KW);
            }
		}
		else
		{
			c = UsedMagCapacity;
		}
	}
	else
	{
		c = (AM.MaxAmmo-AM.AmmoAmount);
	}

    Price = int(float(c) / UsedMagCapacity * Price);

	if ( PlayerReplicationInfo.Score < Price ) // Not enough CASH (so buy the amount you CAN buy).
	{
		c *= (PlayerReplicationInfo.Score/Price);

		if ( c == 0 )
		{
			SetTraderUpdate();
			return; // Couldn't even afford 1 bullet.
		}

		AM.AddAmmo(c);
		PlayerReplicationInfo.Score = Max(PlayerReplicationInfo.Score - (float(c) / UsedMagCapacity * Price), 0);

		SetTraderUpdate();

		return;
	}

	PlayerReplicationInfo.Score = int(PlayerReplicationInfo.Score-Price);
	AM.AddAmmo(c);

	SetTraderUpdate();
}

function ServerSellAmmo( Class<Ammunition> AClass )
{
	local Inventory I;
	local float Price;
	local Ammunition AM;
	local KFWeapon KW;
	local int c;

	if( !CanBuyNow() || AClass==None )
		Return;
	For( I=Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==AClass )
			AM = Ammunition(I);
		else if( KW==None && KFWeapon(I)!=None && (Weapon(I).AmmoClass[0]==AClass || Weapon(I).AmmoClass[1]==AClass) )
			KW = KFWeapon(I);
	}
	if( (AM==None && KW==None) || AM.AmmoAmount==AM.MaxAmmo )
		Return;
	Price = Class<KFWeaponPickup>(KW.PickupClass).Default.AmmoCost; // Clip price.
	c = KW.Default.MagCapacity;
	if( c>AM.AmmoAmount )
		c = AM.AmmoAmount;
	Price = float(c)/float(KW.Default.MagCapacity)*Price*0.75;
	PlayerReplicationInfo.Score+=Price;
	AM.AmmoAmount-=c;

	SetTraderUpdate();
}

simulated function SetTraderUpdate()
{
	if ( KFPlayerController(Controller) != none )
	{
		KFPlayerController(Controller).DoTraderUpdate();
	}
}

// Allow players spawn on top of each other.
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;

	if ( (Vehicle(Other) != None) && (Weapon != None) && Weapon.IsA('Translauncher') )
		return true;

	return false;
}
event EncroachedBy( actor Other )
{
	if ( Pawn(Other)!=None && Vehicle(Other)==None && KFPawn(Other)==None )
		gibbedBy(Other);
}

function name GetWeaponBoneFor(Inventory I)
{
     return 'WeaponR_Bone';
}

function name GetOffhandBoneFor(Inventory I)
{
     return 'WeaponL_Bone';
}


simulated function SetWeaponAttachment(WeaponAttachment NewAtt)
{
	local KFWeaponAttachment KFWeapAttach;
    local DualiesAttachment DualiesAttach;
    local int i;

	WeaponAttachment = NewAtt;
	KFWeapAttach =  KFWeaponAttachment(WeaponAttachment);
	DualiesAttach = DualiesAttachment(WeaponAttachment);

	// For remote clients set the brother class for dualies
    if( Level.NetMode == NM_Client && DualiesAttach != none )
	{
        for( i = 0; i < Attached.Length; i++ )
        {
            if( Attached[i] == None )
                continue;

            if( DualiesAttachment(Attached[i]) != none && DualiesAttach != Attached[i] )
            {
                DualiesAttach.brother = DualiesAttachment(Attached[i]);
                DualiesAttachment(Attached[i]).brother = DualiesAttach;
                break;
            }
        }
	}

    if( KFWeapAttach != none )
    {
        MovementAnims[0]= KFWeapAttach.MovementAnims[0];
        MovementAnims[1]= KFWeapAttach.MovementAnims[1];
        MovementAnims[2]= KFWeapAttach.MovementAnims[2];
        MovementAnims[3]= KFWeapAttach.MovementAnims[3];
        TurnLeftAnim = KFWeapAttach.TurnLeftAnim;
        TurnRightAnim = KFWeapAttach.TurnRightAnim;
        SwimAnims[0]= KFWeapAttach.SwimAnims[0];
        SwimAnims[1]= KFWeapAttach.SwimAnims[1];
        SwimAnims[2]= KFWeapAttach.SwimAnims[2];
        SwimAnims[3]= KFWeapAttach.SwimAnims[3];
        CrouchAnims[0]= KFWeapAttach.CrouchAnims[0];
        CrouchAnims[1]= KFWeapAttach.CrouchAnims[1];
        CrouchAnims[2]= KFWeapAttach.CrouchAnims[2];
        CrouchAnims[3]= KFWeapAttach.CrouchAnims[3];
        WalkAnims[0]= KFWeapAttach.WalkAnims[0];
        WalkAnims[1]= KFWeapAttach.WalkAnims[1];
        WalkAnims[2]= KFWeapAttach.WalkAnims[2];
        WalkAnims[3]= KFWeapAttach.WalkAnims[3];
        AirAnims[0]= KFWeapAttach.AirAnims[0];
        AirAnims[1]= KFWeapAttach.AirAnims[1];
        AirAnims[2]= KFWeapAttach.AirAnims[2];
        AirAnims[3]= KFWeapAttach.AirAnims[3];
        TakeoffAnims[0]= KFWeapAttach.TakeoffAnims[0];
        TakeoffAnims[1]= KFWeapAttach.TakeoffAnims[1];
        TakeoffAnims[2]= KFWeapAttach.TakeoffAnims[2];
        TakeoffAnims[3]= KFWeapAttach.TakeoffAnims[3];
        LandAnims[0]= KFWeapAttach.LandAnims[0];
        LandAnims[1]= KFWeapAttach.LandAnims[1];
        LandAnims[2]= KFWeapAttach.LandAnims[2];
        LandAnims[3]= KFWeapAttach.LandAnims[3];
        DoubleJumpAnims[0]= KFWeapAttach.DoubleJumpAnims[0];
        DoubleJumpAnims[1]= KFWeapAttach.DoubleJumpAnims[1];
        DoubleJumpAnims[2]= KFWeapAttach.DoubleJumpAnims[2];
        DoubleJumpAnims[3]= KFWeapAttach.DoubleJumpAnims[3];
        DodgeAnims[0]= KFWeapAttach.DodgeAnims[0];
        DodgeAnims[1]= KFWeapAttach.DodgeAnims[1];
        DodgeAnims[2]= KFWeapAttach.DodgeAnims[2];
        DodgeAnims[3]= KFWeapAttach.DodgeAnims[3];
        AirStillAnim = KFWeapAttach.AirStillAnim;
        TakeoffStillAnim = KFWeapAttach.TakeoffStillAnim;
        CrouchTurnRightAnim = KFWeapAttach.CrouchTurnRightAnim;
        CrouchTurnLeftAnim = KFWeapAttach.CrouchTurnLeftAnim;
        IdleCrouchAnim = KFWeapAttach.IdleCrouchAnim;
        IdleSwimAnim = KFWeapAttach.IdleSwimAnim;
        IdleWeaponAnim = KFWeapAttach.IdleWeaponAnim;
        IdleRestAnim = KFWeapAttach.IdleRestAnim;
        IdleChatAnim = KFWeapAttach.IdleChatAnim;
        FireAnims[0]=KFWeapAttach.FireAnims[0];
        FireAnims[1]=KFWeapAttach.FireAnims[1];
        FireAnims[2]=KFWeapAttach.FireAnims[2];
        FireAnims[3]=KFWeapAttach.FireAnims[3];
        FireAltAnims[0]=KFWeapAttach.FireAltAnims[0];
        FireAltAnims[1]=KFWeapAttach.FireAltAnims[1];
        FireAltAnims[2]=KFWeapAttach.FireAltAnims[2];
        FireAltAnims[3]=KFWeapAttach.FireAltAnims[3];
        FireCrouchAnims[0]=KFWeapAttach.FireCrouchAnims[0];
        FireCrouchAnims[1]=KFWeapAttach.FireCrouchAnims[1];
        FireCrouchAnims[2]=KFWeapAttach.FireCrouchAnims[2];
        FireCrouchAnims[3]=KFWeapAttach.FireCrouchAnims[3];
        FireCrouchAltAnims[0]=KFWeapAttach.FireCrouchAltAnims[0];
        FireCrouchAltAnims[1]=KFWeapAttach.FireCrouchAltAnims[1];
        FireCrouchAltAnims[2]=KFWeapAttach.FireCrouchAltAnims[2];
        FireCrouchAltAnims[3]=KFWeapAttach.FireCrouchAltAnims[3];
        HitAnims[0]=KFWeapAttach.HitAnims[0];
        HitAnims[1]=KFWeapAttach.HitAnims[1];
        HitAnims[2]=KFWeapAttach.HitAnims[2];
        HitAnims[3]=KFWeapAttach.HitAnims[3];
        PostFireBlendStandAnim = KFWeapAttach.PostFireBlendStandAnim;
        PostFireBlendCrouchAnim = KFWeapAttach.PostFireBlendCrouchAnim;
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

	if ( DrivenVehicle != None )
		return;

    GetAxes(Rotation, X,Y,Z);
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

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim(HitAnims[0],, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim(HitAnims[1],, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim(HitAnims[3],, 0.1);
    }
    else
    {
        PlayAnim(HitAnims[2],, 0.1);
    }
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
			PlaySound(sound'Inf_Player.FootStepWaterDeep', SLOT_Interact, FootstepVolume * 2,, FootStepSoundRadius);

			// Play a water ring effect as you walk through the water
 			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.NetMode != NM_DedicatedServer)
				&& !Touching[i].TraceThisActor(HitLocation, HitNormal,Location - CollisionHeight*vect(0,0,1.1), Location) )
			{
					Spawn(class'WaterRingEmitter',,,HitLocation,rot(16384,0,0));
			}

			return;
		}

	// Lets still play the sounds when walking slow, just play them quieter
    if ( bIsCrouched || bIsWalking )
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
	PlaySound(SoundFootsteps[SurfaceTypeID], SLOT_Interact, (FootstepVolume * FootVolumeMod),,(FootStepSoundRadius * FootVolumeMod));
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

		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
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

function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D;
	local float OldBobTime;
	local int m,n;
	local float UsedBobScaleModifier;

	OldBobTime = BobTime;

	Bob = FClamp(Bob, -0.01, 0.01);
    UsedBobScaleModifier = BobScaleModifier;

	// Modify the amount of bob based on the movement state
    if( bIsCrouched )
	{
		UsedBobScaleModifier = 2.5;
	}

	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);

        Speed2D *= BobSpeedModifier;

		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);

		WalkBob = Y * (Bob * UsedBobScaleModifier) * Speed2D * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( Speed2D > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * (Bob * UsedBobScaleModifier) * Speed2D * sin(16 * BobTime);
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

	if ( (m != n) )
		FootStepping(0);
}

function Sound GetSound(xPawnSoundGroup.ESoundType soundType)
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

/* Quickly select syring, alt fire once, select old weapon again */
simulated exec function QuickHeal()
{
	local Syringe S;
	local Inventory I;
	local byte C;

	if ( Health>=HealthMax )
		return;
	for( I=Inventory; (I!=None && C++<250); I=I.Inventory )
	{
		S = Syringe(I);
		if( S!=None )
			break;
	}
	if ( S == none )
		return;

	if ( S.ChargeBar() < 0.95 )
	{
		if ( PlayerController(Controller) != none && HUDKillingFloor(PlayerController(Controller).myHud) != none )
		{
			HUDKillingFloor(PlayerController(Controller).myHud).ShowQuickSyringe();
		}

		return; // No can heal.
	}

	bIsQuickHealing = 1;
	if ( Weapon==None )
	{
		PendingWeapon = S;
		ChangedWeapon();
	}
	else if ( Weapon!=S )
	{
		PendingWeapon = S;
		Weapon.PutDown();
	}
	else // Syringe already selected, just start healing.
	{
		bIsQuickHealing = 0;
		S.HackClientStartFire();
	}
}

simulated exec function ToggleFlashlight()
{
	local KFWeapon KFWeap;

	if ( Controller == none )
	{
		return;
	}

	if ( KFWeapon(Weapon) != none && KFWeapon(Weapon).bTorchEnabled )
	{
		Weapon.ClientStartFire(1);
	}
	else
	{
		KFWeap = KFWeapon(FindInventoryType(class'Shotgun'));
		if ( KFWeap == none )
		{
			KFWeap = KFWeapon(FindInventoryType(class'BenelliShotgun'));
    		if ( KFWeap == none )
    		{
    			KFWeap = KFWeapon(FindInventoryType(class'Dualies'));
    			if ( KFWeap == none || DualDeagle(KFWeap) != none || Dual44Magnum(KFWeap) != none
                    || DualMK23Pistol(KFWeap) != none || DualFlareRevolver(KFWeap) != none )
    			{
    				KFWeap = KFWeapon(FindInventoryType(class'Single'));
    			}
			}
		}

		if ( KFWeap != none )
		{
			KFWeap.bPendingFlashlight = true;

			PendingWeapon = KFWeap;

			if ( Weapon != none )
			{
				Weapon.PutDown();
			}
			else
			{
				ChangedWeapon();
			}
		}
	}
}

function GiveWeapon(string aClassName )
{
	local class<Weapon> WeaponClass;
	local Inventory I;
	local Weapon NewWeapon;
	local bool bHasDual9mms, bHasDualHCs, bHasDualRevolvers;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if( I.Class == WeaponClass )
		{
			Return; // Already has weapon.
		}

		if ( I.Class == class'Dualies' )
		{
			bHasDual9mms = true;
		}
		else if ( I.Class == class'DualDeagle' )
		{
			bHasDualHCs = true;
		}
		else if ( I.Class == class'Dual44Magnum' )
		{
			bHasDualRevolvers = true;
		}
	}

	newWeapon = Spawn(WeaponClass);
	if ( newWeapon != none )
	{
		newWeapon.GiveTo(self);

		if ( WeaponClass == class'Dualies' || WeaponClass == class'DualDeagle' || WeaponClass == class'Dual44Magnum' )
		{
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).OnDualsAddedToInventory(bHasDual9mms, bHasDualHCs, bHasDualRevolvers);
		}

		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponSpawned(newWeapon);
		}
	}
}

function bool DoJump( bool bUpdating )
{
    if ( Super.DoJump(bUpdating) )
    {
        // Take you out of ironsights if you jump on a non-lowgrav map
        if( KFWeapon(Weapon) != none && PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            KFWeapon(Weapon).ForceZoomOutTime = Level.TimeSeconds + 0.01;
        }
        return true;
    }
    return false;
}

defaultproperties
{
     GibGroupClass=Class'KFMod.KFHumanGibGroup'
     BileFrequency=0.500000
     BurnEffect=Class'KFMod.KFMonsterFlame'
     bDetailedShadows=True
     bRealDeathType=True
     bDoAdjustFeet=True
     FireAnims(0)="Fire_Bullpup"
     FireAnims(1)="Fire_Bullpup"
     FireAnims(2)="Fire_Bullpup"
     FireAnims(3)="Fire_Bullpup"
     FireAltAnims(0)="Fire_Bullpup"
     FireAltAnims(1)="Fire_Bullpup"
     FireAltAnims(2)="Fire_Bullpup"
     FireAltAnims(3)="Fire_Bullpup"
     FireCrouchAnims(0)="CHFire_BullPup"
     FireCrouchAnims(1)="CHFire_BullPup"
     FireCrouchAnims(2)="CHFire_BullPup"
     FireCrouchAnims(3)="CHFire_BullPup"
     FireCrouchAltAnims(0)="CHFire_BullPup"
     FireCrouchAltAnims(1)="CHFire_BullPup"
     FireCrouchAltAnims(2)="CHFire_BullPup"
     FireCrouchAltAnims(3)="CHFire_BullPup"
     HitAnims(0)="HitF_Bullpup"
     HitAnims(1)="HitB_Bullpup"
     HitAnims(2)="HitL_Bullpup"
     HitAnims(3)="HitR_Bullpup"
     PostFireBlendStandAnim="Blend_Bullpup"
     PostFireBlendCrouchAnim="CHBlend_Bullpup"
     FootStepSoundRadius=125.000000
     QuietFootStepVolume=0.400000
     SoundFootsteps(0)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(1)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDirt'
     SoundFootsteps(2)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDirt'
     SoundFootsteps(3)=SoundGroup'KF_PlayerGlobalSnd.Player_StepMetal'
     SoundFootsteps(4)=SoundGroup'KF_PlayerGlobalSnd.Player_StepWood'
     SoundFootsteps(5)=SoundGroup'KF_PlayerGlobalSnd.Player_StepGrass'
     SoundFootsteps(6)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDirt'
     SoundFootsteps(7)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(8)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(9)=SoundGroup'KF_PlayerGlobalSnd.Player_StepWater'
     SoundFootsteps(10)=SoundGroup'KF_PlayerGlobalSnd.Player_StepBrGlass'
     SoundFootsteps(11)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(12)=SoundGroup'KF_PlayerGlobalSnd.Player_StepConc'
     SoundFootsteps(13)=SoundGroup'KF_PlayerGlobalSnd.Player_StepWood'
     SoundFootsteps(14)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(15)=SoundGroup'KF_PlayerGlobalSnd.Player_StepMetal'
     SoundFootsteps(16)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(17)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(18)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     SoundFootsteps(19)=SoundGroup'KF_PlayerGlobalSnd.Player_StepDefault'
     BobSpeedModifier=0.900000
     BobScaleModifier=1.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.100000
     SeveredHeadAttachScale=1.100000
     NeckSpurtEmitterClass=Class'KFMod.DismembermentJetHead'
     LimbSpurtEmitterClass=Class'KFMod.DismembermentJetLimb'
     SeveredArmAttachClass=Class'ROEffects.SeveredArmAttachment'
     SeveredLegAttachClass=Class'ROEffects.SeveredLegAttachment'
     SeveredHeadAttachClass=Class'ROEffects.SeveredHeadAttachment'
     ProjectileBloodSplatClass=Class'ROEffects.ProjectileBloodSplat'
     DetachedArmClass=Class'KFMod.SeveredArmSoldier'
     DetachedLegClass=Class'KFMod.SeveredLegSoldier'
     ObliteratedEffectClass=Class'ROEffects.PlayerObliteratedEmitter'
     DecapitationSound=SoundGroup'KF_EnemyGlobalSnd.Generic_Decap'
     DropCashMessageDelay=10.000000
     ShieldStrengthMax=100.000000
     Species=Class'KFMod.SPECIES_KFMaleHuman'
     GruntVolume=0.500000
     FootstepVolume=0.450000
     SoundGroupClass=Class'KFMod.KFMaleSoundGroup'
     IdleHeavyAnim="Idle_Bullpup"
     IdleRifleAnim="Idle_Bullpup"
     FireRootBone="CHR_Spine1"
     DeResTime=0.000000
     DeResMat0=Texture'KFCharacters.KFDeRez'
     DeResMat1=Texture'KFCharacters.KFDeRez'
     DeResLiftVel=(Points=(,(InVal=0.000000,OutVal=0.000000),(InVal=0.000000,OutVal=0.000000)))
     DeResLiftSoftness=(Points=((OutVal=0.000000),(InVal=0.000000,OutVal=0.000000),(InVal=0.000000,OutVal=0.000000)))
     DeResLateralFriction=0.000000
     RagdollLifeSpan=9999.000000
     RagDeathVel=75.000000
     RagShootStrength=6000.000000
     RagDeathUpKick=100.000000
     RagImpactSounds(0)=SoundGroup'KF_PlayerGlobalSnd.Player_BodyImpact'
     RequiredEquipment(0)="none"
     RequiredEquipment(1)="none"
     bScriptPostRender=True
     MeleeRange=80.000000
     GroundSpeed=240.000000
     WaterSpeed=180.000000
     AirSpeed=240.000000
     JumpZ=300.000000
     BaseEyeHeight=44.000000
     EyeHeight=44.000000
     CrouchRadius=20.000000
     MovementAnims(0)="JogF_Bullpup"
     MovementAnims(1)="JogB_Bullpup"
     MovementAnims(2)="JogL_Bullpup"
     MovementAnims(3)="JogR_Bullpup"
     DodgeSpeedFactor=1.000000
     DodgeSpeedZ=0.000000
     SwimAnims(0)="WalkF"
     SwimAnims(1)="WalkB"
     SwimAnims(2)="WalkL"
     SwimAnims(3)="WalkR"
     CrouchAnims(0)="CHwalkF_BullPup"
     CrouchAnims(1)="CHwalkB_BullPup"
     CrouchAnims(2)="CHwalkL_BullPup"
     CrouchAnims(3)="CHwalkR_BullPup"
     WalkAnims(0)="WalkF_Bullpup"
     WalkAnims(1)="WalkB_Bullpup"
     WalkAnims(2)="WalkL_Bullpup"
     WalkAnims(3)="WalkR_Bullpup"
     AirAnims(1)="JumpF_Mid"
     TakeoffAnims(1)="JumpF_Takeoff"
     LandAnims(1)="JumpF_Land"
     DodgeAnims(0)="JumpF_Takeoff"
     DodgeAnims(1)="JumpF_Takeoff"
     DodgeAnims(2)="JumpL_Takeoff"
     DodgeAnims(3)="JumpR_Takeoff"
     AirStillAnim="JumpF_Mid"
     TakeoffStillAnim="JumpF_Takeoff"
     CrouchTurnRightAnim="CH_TurnR"
     CrouchTurnLeftAnim="CH_TurnL"
     IdleCrouchAnim="CHIdle_BullPup"
     IdleWeaponAnim="Idle_Bullpup"
     IdleRestAnim="Idle_Rifle"
     RootBone="CHR_Pelvis"
     HeadBone="CHR_Head"
     SpineBone1="CHR_Spine2"
     SpineBone2="CHR_Spine3"
     HitPoints(0)=(PointRadius=40.000000,PointHeight=60.000000,PointScale=1.000000,PointBone="CHR_Pelvis",PointOffset=(Y=-10.000000))
     HitPoints(1)=(PointRadius=6.500000,PointHeight=8.000000,PointScale=1.000000,PointBone="CHR_Head",PointOffset=(X=2.000000,Y=-2.000000),DamageMultiplier=5.000000,HitPointType=PHP_Head)
     HitPoints(2)=(PointRadius=13.000000,PointHeight=15.000000,PointScale=1.000000,PointBone="CHR_Spine3",PointOffset=(Y=-5.000000),DamageMultiplier=1.000000,HitPointType=PHP_Torso)
     HitPoints(3)=(PointRadius=12.000000,PointHeight=11.000000,PointScale=1.000000,PointBone="CHR_Spine1",PointOffset=(X=-3.000000,Y=-3.000000),DamageMultiplier=1.000000,HitPointType=PHP_Torso)
     HitPoints(4)=(PointRadius=7.000000,PointHeight=12.000000,PointScale=1.000000,PointBone="CHR_LThigh",PointOffset=(X=18.000000,Y=1.000000),DamageMultiplier=0.500000,HitPointType=PHP_Leg)
     HitPoints(5)=(PointRadius=7.000000,PointHeight=12.000000,PointScale=1.000000,PointBone="CHR_RThigh",PointOffset=(X=18.000000,Y=1.000000),DamageMultiplier=0.500000,HitPointType=PHP_Leg)
     HitPoints(6)=(PointRadius=5.000000,PointHeight=11.000000,PointScale=1.000000,PointBone="CHR_LArmUpper",PointOffset=(X=8.000000,Z=1.000000),DamageMultiplier=0.300000,HitPointType=PHP_Arm)
     HitPoints(7)=(PointRadius=5.000000,PointHeight=11.000000,PointScale=1.000000,PointBone="CHR_RArmUpper",PointOffset=(X=8.000000,Z=1.000000),DamageMultiplier=0.300000,HitPointType=PHP_Arm)
     HitPoints(8)=(PointRadius=6.000000,PointHeight=18.000000,PointScale=1.000000,PointBone="CHR_LCalf",PointOffset=(X=15.000000),DamageMultiplier=0.400000,HitPointType=PHP_Leg)
     HitPoints(9)=(PointRadius=6.000000,PointHeight=18.000000,PointScale=1.000000,PointBone="CHR_RCalf",PointOffset=(X=15.000000),DamageMultiplier=0.400000,HitPointType=PHP_Leg)
     HitPoints(10)=(PointRadius=4.000000,PointHeight=10.000000,PointScale=1.000000,PointBone="CHR_LArmForeArm",PointOffset=(X=6.000000),DamageMultiplier=0.200000,HitPointType=PHP_Arm)
     HitPoints(11)=(PointRadius=4.000000,PointHeight=10.000000,PointScale=1.000000,PointBone="CHR_RArmForeArm",PointOffset=(X=6.000000),DamageMultiplier=0.200000,HitPointType=PHP_Arm)
     HitPoints(12)=(PointRadius=4.000000,PointHeight=4.000000,PointScale=1.000000,PointBone="CHR_LArmPalm",PointOffset=(X=5.000000,Y=2.000000),DamageMultiplier=0.100000,HitPointType=PHP_Hand)
     HitPoints(13)=(PointRadius=4.000000,PointHeight=4.000000,PointScale=1.000000,PointBone="CHR_RArmPalm",PointOffset=(X=5.000000,Y=2.000000),DamageMultiplier=0.100000,HitPointType=PHP_Hand)
     HitPoints(14)=(PointRadius=4.000000,PointHeight=8.000000,PointScale=1.000000,PointBone="CHR_LToe1",DamageMultiplier=0.100000,HitPointType=PHP_Foot)
     HitPoints(15)=(PointRadius=4.000000,PointHeight=8.000000,PointScale=1.000000,PointBone="CHR_RToe1",DamageMultiplier=0.100000,HitPointType=PHP_Foot)
     PrePivot=(Z=0.000000)
     AmbientGlow=0
     bClientAnim=True
     bForceSkelUpdate=True
     CollisionRadius=20.000000
     CollisionHeight=40.000000
     bBlockKarma=True
     bBlockHitPointTraces=False
     Mass=400.000000
}
