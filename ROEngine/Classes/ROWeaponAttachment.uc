//=============================================================================
// ROWeaponAttachment
//=============================================================================
// Base class for Red Orchestra weapon attachments
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson & Jay Nakai
//=============================================================================

// Fixme - vehicle hit effects don't have proper rotation offline

//#exec LOAD OBJ FILE=Weapons3rd_anm.ukx

class ROWeaponAttachment extends WeaponAttachment
	native;

//=============================================================================
// Variables
//=============================================================================

// Sound
var config float WeaponAmbientScale; // How much to scale the ambient fire sound volume for this weapon

var 	class<Emitter>     		mMuzFlashClass;
var 	Emitter            		mMuzFlash3rd;
var		bool					bAltFireFlash;		// when true, alt fire triggers muzzle flash(MG-34)

// Attachment Bones
var 	name					MuzzleBoneName;
var		name					ShellEjectionBoneName;

// barrel steam emitter
var()	class<Emitter>			ROMGSteamEmitterClass;
var   	Emitter					ROMGSteamEmitter;


var()	class<ROShellEject>		ROShellCaseClass;
var		ROShellEject			ROShellCase;
var()	vector					mShellEmitterOffset;
var		bool					bAnimNotifiedShellEjects;	// This class only does anim notified shell ejection

var()	class<Emitter>			ROSmokeClass;
var		Emitter					ROSmoke;

var		bool					bUpdated;
var		bool					bOutOfAmmo;

// bayonet handling
var		bool					bBayonetAttached;
var		bool					bOldBayonetAttached;

// barrel steam handling - INACTIVE
var 		bool					bBarrelSteamActive;
var 		bool					bOldBarrelSteamActive;

var()		bool					bLoopReloadAnim;

// think about using later
//var		bool			bUseFireAnimsForAltFire;

// Player Animations
var()	name					PA_MovementAnims[8];
var()	name					PA_CrouchAnims[8];
var()	name					PA_SwimAnims[4];
var()	name					PA_ProneAnims[8];
var()	name					PA_ProneIronAnims[8];
var()	name					PA_WalkAnims[8];
var()	name					PA_WalkIronAnims[8];
var()	name					PA_SprintAnims[8];
var()	name					PA_SprintCrouchAnims[8];
var()	name					PA_LimpAnims[8];
var()	name					PA_LimpIronAnims[8];
var()	name					PA_MoveHoldBayo[8];
var()	name					PA_MoveHoldBash[8];
var()	name					PA_WalkHoldBayo[8];
var()	name					PA_WalkHoldBash[8];
var()	name					PA_CrouchHoldBayo[8];
var()	name					PA_CrouchHoldBash[8];
var()	name					PA_SprintHoldBayo[8];
var()	name					PA_SprintHoldBash[8];
var()	name					PA_SprintCrouchHoldBayo[8];
var()	name					PA_SprintCrouchHoldBash[8];

// Explosives anims
var()	name					PA_MoveHoldExplosive[8];
var()	name					PA_WalkHoldExplosive[8];
var()	name					PA_CrouchHoldExplosive[8];
var()	name					PA_SprintHoldExplosive[8];
var()	name					PA_SprintCrouchHoldExplosive[8];
var()	name					PA_ProneHoldExplosive[8];

var()	name					PA_IdleExplosiveHold;
var()	name					PA_IdleCrouchExplosiveHold;
var()	name					PA_IdleProneExplosiveHold;


var()	name					PA_TurnRightAnim;
var()	name					PA_TurnLeftAnim;
var()	name					PA_TurnIronRightAnim;
var()	name					PA_TurnIronLeftAnim;
var()	name					PA_CrouchTurnIronRightAnim;
var()	name					PA_CrouchTurnIronLeftAnim;

var()	name					PA_ProneTurnRightAnim;
var()	name					PA_ProneTurnLeftAnim;
var()	name					PA_StandToProneAnim;
var()	name					PA_CrouchToProneAnim;
var()	name					PA_ProneToStandAnim;
var()	name					PA_ProneToCrouchAnim;
var() 	name					PA_DiveToProneStartAnim;
var() 	name					PA_DiveToProneEndAnim;

var()	name					PA_CrouchTurnRightAnim;
var()	name					PA_CrouchTurnLeftAnim;
var()	name					PA_CrouchIdleRestAnim;

var()	name					PA_IdleCrouchAnim;
var()	name					PA_IdleRestAnim;
var()	name					PA_IdleWeaponAnim;
var()	name					PA_IdleIronRestAnim;
var()	name					PA_IdleIronWeaponAnim;
var()	name					PA_IdleCrouchIronWeaponAnim;
var()	name					PA_IdleProneAnim;
var()	name					PA_IdleDeployedAnim;
var()	name					PA_IdleDeployedProneAnim;

// Melee anims
var()	name					PA_IdleBayoHold;
var()	name					PA_IdleCrouchBayoHold;
var()	name					PA_IdleProneBayoHold;
var()	name					PA_IdleBashHold;
var()	name					PA_IdleCrouchBashHold;
var()	name					PA_IdleProneBashHold;

// MG specific anims
var()	name					PA_IdleDeployedCrouchAnim;

var()	name					PA_ReloadAnim;
var()	name					PA_ProneReloadAnim;
var()	name					PA_ReloadEmptyAnim;
var()	name					PA_ProneReloadEmptyAnim;
var()	name					PA_PreReloadAnim;
var()	name					PA_PronePreReloadAnim;
var()	name					PA_PostReloadAnim;
var()	name					PA_PronePostReloadAnim;
var()	name					PA_ProneIdleRestAnim;

var()	name					PA_BayonetAttachAnim;
var()	name					PA_ProneBayonetAttachAnim;

var()	name					PA_BayonetDetachAnim;
var()	name					PA_ProneBayonetDetachAnim;

var()	name					PA_StandWeaponDeployAnim;
var()	name					PA_ProneWeaponDeployAnim;

var()	name					PA_StandWeaponUnDeployAnim;
var()	name					PA_ProneWeaponUnDeployAnim;

var()	name					PA_StandBoltActionAnim;
var()	name					PA_StandIronBoltActionAnim;
var()	name					PA_CrouchBoltActionAnim;
var()	name					PA_CrouchIronBoltActionAnim;
var()	name					PA_ProneBoltActionAnim;

var()	name					PA_Fire;
var()	name					PA_IronFire;
var()	name					PA_CrouchFire;
var()	name					PA_CrouchIronFire;
var()	name					PA_ProneFire;
var()	name					PA_DeployedFire;
var()	name					PA_CrouchDeployedFire;
var()	name					PA_ProneDeployedFire;

// Moving fire anims
var()	name					PA_MoveStandFire[8];
var()	name					PA_MoveCrouchFire[8];
var()	name					PA_MoveWalkFire[8];
var()	name					PA_MoveStandIronFire[8];

var()	name					PA_AltFire;
var()	name					PA_CrouchAltFire;
var()	name					PA_ProneAltFire;
var()	name					PA_DeployedAltFire;
var()	name					PA_CrouchDeployedAltFire;
var()	name					PA_ProneDeployedAltFire;

var()	name					PA_BayonetAltFire;
var()	name					PA_CrouchBayonetAltFire;
var()	name					PA_ProneBayonetAltFire;

var()	name					PA_FireLastShot;
var()	name					PA_IronFireLastShot;
var()	name					PA_CrouchFireLastShot;
var()	name					PA_ProneFireLastShot;

var() 	name					PA_HitFAnim;
var() 	name					PA_HitBAnim;
var() 	name					PA_HitLAnim;
var() 	name					PA_HitRAnim;
var() 	name					PA_HitLLegAnim;
var() 	name					PA_HitRLegAnim;
var() 	name					PA_CrouchHitUpAnim;
var() 	name					PA_CrouchHitDownAnim;
var() 	name					PA_ProneHitAnim;

var() 	name					PA_AirStillAnim;
var() 	name					PA_AirAnims[4];
var() 	name					PA_TakeoffStillAnim;
var() 	name					PA_TakeoffAnims[4];
var() 	name					PA_LandAnims[4];
var() 	name					PA_DodgeAnims[4];

// Weapon Animations
var()	name					WA_Idle;
var()	name					WA_IdleEmpty;
var()	name					WA_Fire;
var()	name					WA_Reload;
var()	name					WA_ReloadEmpty;
var()	name					WA_ProneReload;
var()	name					WA_ProneReloadEmpty;
var()	name					WA_PreReload;
var()	name					WA_PostReload;

var()	name					WA_BayonetIdle;
var()	name					WA_BayonetIdleEmpty;
var()	name					WA_BayonetFire;
var()	name					WA_BayonetReload;
var()	name					WA_BayonetReloadEmpty;
var()	name					WA_BayonetProneReload;
var()	name					WA_BayonetProneReloadEmpty;
var()	name					WA_BayonetPreReload;
var()	name					WA_BayonetPostReload;

var()	name					WA_BayonetAttach;
var()	name					WA_BayonetDetach;
var()	name					WA_BayonetAttachProne;
var()	name					WA_BayonetDetachProne;

var()	name					WA_WeaponDeploy;
var()	name					WA_WeaponUnDeploy;

var()	name					WA_WorkBolt;
var()	name					WA_BayonetWorkBolt;

// Bullet hit effect variables
var 		byte 				OldSpawnHitCount;		// Saved hit effect spawn count

// for use with menus
var         Material	        menuImage;
var         localized string    menuDescription;

var			Vector				mVehHitNormal;

//=============================
// XWeaponAttachment Variables
//=============================
// player animation specification
var() bool bHeavy;
var() bool bRapidFire;
var() bool bAltRapidFire;
var vector mHitNormal;
var actor mHitActor;
var Weapon LitWeapon;

//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bOutOfAmmo, bBayonetAttached, bBarrelSteamActive;
}


//=============================
// XWeaponAttachment functions
//=============================

simulated function GetHitInfo()
{
	local vector HitLocation, Offset;

	// if standalone, already have valid HitActor and HitNormal
	if ( Level.NetMode == NM_Standalone )
		return;
	Offset = 20 * Normal(Instigator.Location - mHitLocation);
	mHitActor = Trace(HitLocation,mHitNormal,mHitLocation-Offset,mHitLocation+Offset, false);
    NetUpdateTime = Level.TimeSeconds - 1;
}

simulated function Hide(bool NewbHidden)
{
	bHidden = NewbHidden;
}

simulated function Vector GetTipLocation()
{
    local Coords C;
    C = GetBoneCoords('tip');
    return C.Origin;
}

simulated function WeaponLight()
{
    if ( (FlashCount > 0) && !Level.bDropDetail && (Instigator != None)
		&& ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
		if ( Instigator.IsFirstPerson() )
		{
			LitWeapon = Instigator.Weapon;
			LitWeapon.bDynamicLight = true;
		}
		else
			bDynamicLight = true;
        SetTimer(0.15, false);
    }
    else
		Timer();
}

function InitFor(Inventory I)
{
	Super.InitFor(I);

	if ( ROPawn(I.Instigator) == None )
		return;

	if ( ROPawn(I.Instigator).bClearWeaponOffsets )
		SetRelativeLocation(vect(0,0,0));
}

simulated function Timer()
{
	if ( LitWeapon != None )
	{
		LitWeapon.bDynamicLight = false;
		LitWeapon = None;
	}
    bDynamicLight = false;
}

//=============================================================================
// Functions
//=============================================================================

simulated function PostBeginPlay()
{
	if (Role == ROLE_Authority)
	{
		bOldBayonetAttached = bBayonetAttached;
		bOldBarrelSteamActive = bBarrelSteamActive;
		bUpdated = true;
	}

	if (mMuzFlashClass != None)
	{
		mMuzFlash3rd = Spawn(mMuzFlashClass);
		AttachToBone(mMuzFlash3rd, MuzzleBoneName);
	}

	if( ROMGSteamEmitterClass != none )
	{
		ROMGSteamEmitter = Spawn(ROMGSteamEmitterClass);
		AttachToBone(ROMGSteamEmitter, 'steam');
	}

	/*if( ROSmokeClass != none )
	{
		ROSmoke = Spawn(ROSmokeClass, Instigator);
		AttachToBone(ROSmoke, MuzzleBoneName);
	}*/

	//SetTimer(0.1, true);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

    if ( Instigator != None && ROPawn(Instigator) != None )
    {
        ROPawn(Instigator).SetWeaponAttachment(self);
    }

	bOldBayonetAttached = bBayonetAttached;
	bOldBarrelSteamActive = bBarrelSteamActive;
	bUpdated = true;
}

simulated function Tick(float DeltaTime)
// MergeTODO: Refactor, this is terribly innefficient
//simulated function PostNetReceive()
{
	if (!bUpdated)
		return;

	if( bOldBarrelSteamActive != bBarrelSteamActive )
	{
		ThirdPersonBarrelSteam();
		bOldBarrelSteamActive = bBarrelSteamActive;
	}
}

simulated function StartMuzzleSmoke()
{
// UT2k4 Merge - I think I commented this out in the merge - Ramm

	//local coords muzzleloc;
	//muzzleloc = Instigator.Weapon.GetBoneCoords('tip');

	//ROSmoke = Spawn(ROSmokeClass, self,,muzzleloc.origin);
	//AttachToBone(ROSmoke, MuzzleBoneName);
}

simulated function Destroyed()
{
	if( Role < ROLE_Authority)
	{
		if ( Instigator != None && ROPawn(Instigator) != None )
	    {
	        // Check to make sure this weapon isn't still the
	        // current weapon attachment (fixes problems when
	        // packets arrive out of order.
			ROPawn(Instigator).CheckWeaponAttachment(self);
	    }
	}

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.Destroy();

    if( ROSmoke != none )
		ROSmoke.Destroy();

	if( ROMGSteamEmitter != none )
		ROMGSteamEmitter.Destroy();

	Super.Destroyed();
}

simulated function SpawnShells(float amountPerSec)
{
  	local 	coords 		ejectorloc;
  	local 	rotator 	ejectorrot;
  	local 	vector		spawnlocation;

    if( (Instigator != none) && !Instigator.IsFirstPerson()
		&& ROShellCaseClass != none )
    {
  		ejectorloc = GetBoneCoords(ShellEjectionBoneName);
  		ejectorrot = GetBoneRotation(ShellEjectionBoneName);

		// for some reason, the bone origin to too far forward
		spawnlocation = ejectorloc.Origin;

		ejectorrot.Pitch += rand(1700);
  		ejectorrot.Yaw += rand(1700);
  		ejectorrot.Roll += rand(700);

		Spawn(ROShellCaseClass,Instigator,,spawnlocation,ejectorrot);
	}
}

simulated function ThirdPersonGrenadeBack()
{
	if (Level.NetMode == NM_DedicatedServer || ROPawn(Instigator) == None)
		return;

	ROPawn(Instigator).PlayGrenadeBack();
}

// how are we supposed to show hit FX on vehicles if we don't trace actors? - Ramm
simulated function Actor GetVehicleHitInfo()
{
	local vector HitLocation, Offset;
	local Actor MyVehicle;

	// if standalone, already have valid HitActor and HitNormal
	if ( Level.NetMode == NM_Standalone )
		return none;
	Offset = 20 * Normal(Instigator.Location - mHitLocation);
	MyVehicle = Trace(HitLocation,mVehHitNormal,mHitLocation-Offset,mHitLocation+Offset, true);

	if( ROVehicle(MyVehicle) == none )
	{
		return ROVehicleWeapon(MyVehicle);
	}

	return ROVehicle(MyVehicle);
}

simulated event ThirdPersonEffects()
{
	local PlayerController PC;
	local ROVehicleHitEffect VehEffect;

	if (Level.NetMode == NM_DedicatedServer || ROPawn(Instigator) == None )
		return;

	// new Trace FX - Ramm
	if (FiringMode == 0)
	{
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
			PC = Level.GetLocalPlayerController();
			if ( ((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000) )
			{
				if( mHitActor != none && (Vehicle(mHitActor) != none || ROVehicleWeapon(mHitActor) != none) )
				{
					if (Level.NetMode != NM_DedicatedServer)
					{
						VehEffect = Spawn(class'ROVehicleHitEffect',,, mHitLocation, rotator(-mVehHitNormal));
//						VehEffect.InitHitEffects(mHitLocation,mVehHitNormal);
			 		}
				}
				else if( mHitActor == none && GetVehicleHitInfo() != none)
				{
					GetVehicleHitInfo(); // Isn't this redundant? - Possibly remove
					if (Level.NetMode != NM_DedicatedServer)
					{
						VehEffect = Spawn(class'ROVehicleHitEffect',,, mHitLocation, rotator(-mVehHitNormal));
//						VehEffect.InitHitEffects(mHitLocation,mVehHitNormal);
			 		}
				}
				else
				{
					Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
					CheckForSplash();
				}
			}
		}
	}


	if (FlashCount > 0 && ((FiringMode == 0) || bAltFireFlash) )
	{
		if( (Level.TimeSeconds - LastRenderTime > 0.2) && (PlayerController(Instigator.Controller) == None))
			return;

		WeaponLight();

		if (mMuzFlash3rd != None)
			mMuzFlash3rd.Trigger(self, None);

		if( !bAnimNotifiedShellEjects )
			SpawnShells(1.0);

		/*if( ROSmoke != none )
		{
			log("spawning a smoke particle");
			ROSmoke.SpawnParticle(2);
		}*/
	}

	if (FlashCount == 0)
	{
		ROPawn(Instigator).StopFiring();
		AnimEnd(0);
	}
	else if (FiringMode == 0)
		ROPawn(Instigator).StartFiring(false, bRapidFire);
	else
		ROPawn(Instigator).StartFiring(true, bAltRapidFire);
}

// This is replaced by calls in the new ROWeapon directly to the pawn

//simulated function ThirdPersonReload()
//{
//	if (Level.NetMode == NM_DedicatedServer || ROPawn(Instigator) == None)
//		return;
//
//	if (bPlayReload)
//		ROPawn(Instigator).StartReloading(/*bOutOfAmmo, bLoopReloadAnim*/);
//	else
//		ROPawn(Instigator).StopReloading();
//}

simulated function ThirdPersonBarrelSteam()
{
	if( ROMGSteamEmitter == none )
		return;

    ROMGSteamEmitter.Trigger(self, Instigator);
}

simulated function AnimEnd(int Channel)
{
	// Don't play the idle animation if we're rapid fire looping
	if( FlashCount > 0 && ((FiringMode == 0 && bRapidFire) || (FiringMode == 1 && bAltRapidFire)) )
	{
		return;
	}

    PlayIdle();
}

simulated function PlayIdle()
{
	if (bBayonetAttached)
	{
		if (bOutOfAmmo && WA_BayonetIdleEmpty != '')
			LoopAnim(WA_BayonetIdleEmpty);
		else if (WA_BayonetIdle != '')
			LoopAnim(WA_BayonetIdle);
	}
	else
	{
		if (bOutOfAmmo && HasAnim(WA_IdleEmpty))
			LoopAnim(WA_IdleEmpty);
		else
			LoopAnim(WA_Idle);
	}
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation = HitLocation;
	mHitActor = HitActor;
	mHitNormal = HitNormal;
	mVehHitNormal = HitNormal;
}

defaultproperties
{
     WeaponAmbientScale=5.000000
     MuzzleBoneName="tip"
     ShellEjectionBoneName="weapon_eject"
     PA_MovementAnims(0)="runF_Kar"
     PA_MovementAnims(1)="runB_Kar"
     PA_MovementAnims(2)="runL_Kar"
     PA_MovementAnims(3)="runR_Kar"
     PA_CrouchAnims(0)="CrouchF_Kar"
     PA_CrouchAnims(1)="CrouchB_Kar"
     PA_CrouchAnims(2)="CrouchL_Kar"
     PA_CrouchAnims(3)="CrouchR_kar"
     PA_ProneAnims(0)="prone_crawlF_kar"
     PA_ProneAnims(1)="prone_crawlB_kar"
     PA_ProneAnims(2)="prone_crawlL_kar"
     PA_ProneAnims(3)="prone_crawlR_kar"
     PA_ProneAnims(4)="prone_crawlFL_kar"
     PA_ProneAnims(5)="prone_crawlFR_kar"
     PA_ProneAnims(6)="prone_crawlBL_kar"
     PA_ProneAnims(7)="prone_crawlBR_kar"
     PA_ProneIronAnims(0)="prone_slowcrawlF_kar"
     PA_ProneIronAnims(1)="prone_slowcrawlB_kar"
     PA_ProneIronAnims(2)="prone_slowcrawlL_kar"
     PA_ProneIronAnims(3)="prone_slowcrawlR_kar"
     PA_ProneIronAnims(4)="prone_slowcrawlL_kar"
     PA_ProneIronAnims(5)="prone_slowcrawlR_kar"
     PA_ProneIronAnims(6)="prone_slowcrawlB_kar"
     PA_ProneIronAnims(7)="prone_slowcrawlB_kar"
     PA_WalkAnims(0)="WalkF_Kar"
     PA_WalkAnims(1)="WalkB_Kar"
     PA_WalkAnims(2)="walkL_Kar"
     PA_WalkAnims(3)="WalkR_Kar"
     PA_WalkIronAnims(0)="WalkF_iron_Kar"
     PA_WalkIronAnims(1)="WalkB_iron_Kar"
     PA_WalkIronAnims(2)="walkL_iron_Kar"
     PA_WalkIronAnims(3)="walkR_iron_kar"
     PA_SprintAnims(0)="SprintF_Kar"
     PA_SprintAnims(1)="SprintF_Kar"
     PA_SprintAnims(2)="SprintF_Kar"
     PA_SprintAnims(3)="SprintF_Kar"
     PA_LimpAnims(0)="stand_limpFhip_kar"
     PA_LimpAnims(1)="stand_limpBhip_kar"
     PA_LimpAnims(2)="stand_limpLhip_kar"
     PA_LimpAnims(3)="stand_limpRhip_kar"
     PA_LimpAnims(4)="stand_limpFLhip_kar"
     PA_LimpAnims(5)="stand_limpFRhip_kar"
     PA_LimpAnims(6)="stand_limpBLhip_kar"
     PA_LimpAnims(7)="stand_limpBRhip_kar"
     PA_LimpIronAnims(0)="stand_limpFiron_kar"
     PA_LimpIronAnims(1)="stand_limpBiron_kar"
     PA_LimpIronAnims(2)="stand_limpLiron_kar"
     PA_LimpIronAnims(3)="stand_limpRiron_kar"
     PA_LimpIronAnims(4)="stand_limpFLiron_kar"
     PA_LimpIronAnims(5)="stand_limpFRiron_kar"
     PA_LimpIronAnims(6)="stand_limpBLiron_kar"
     PA_LimpIronAnims(7)="stand_limpBRiron_kar"
     PA_MoveHoldBayo(0)="stand_jogFhold_bayo"
     PA_MoveHoldBayo(1)="stand_jogBhold_bayo"
     PA_MoveHoldBayo(2)="stand_jogLhold_bayo"
     PA_MoveHoldBayo(3)="stand_jogRhold_bayo"
     PA_MoveHoldBayo(4)="stand_jogfLhold_bayo"
     PA_MoveHoldBayo(5)="stand_jogFRhold_bayo"
     PA_MoveHoldBayo(6)="stand_jogBLhold_bayo"
     PA_MoveHoldBayo(7)="stand_jogBRhold_bayo"
     PA_MoveHoldBash(0)="stand_jogFholdbash_kar"
     PA_MoveHoldBash(1)="stand_jogBholdbash_kar"
     PA_MoveHoldBash(2)="stand_jogLholdbash_kar"
     PA_MoveHoldBash(3)="stand_jogRholdbash_kar"
     PA_MoveHoldBash(4)="stand_jogfLholdbash_kar"
     PA_MoveHoldBash(5)="stand_jogFRholdbash_kar"
     PA_MoveHoldBash(6)="stand_jogBLholdbash_kar"
     PA_MoveHoldBash(7)="stand_jogBRholdbash_kar"
     PA_WalkHoldBayo(0)="stand_walkFhold_bayo"
     PA_WalkHoldBayo(1)="stand_walkBhold_bayo"
     PA_WalkHoldBayo(2)="stand_walkLhold_bayo"
     PA_WalkHoldBayo(3)="stand_walkRhold_bayo"
     PA_WalkHoldBayo(4)="stand_walkfLhold_bayo"
     PA_WalkHoldBayo(5)="stand_walkFRhold_bayo"
     PA_WalkHoldBayo(6)="stand_walkBLhold_bayo"
     PA_WalkHoldBayo(7)="stand_walkBRhold_bayo"
     PA_WalkHoldBash(0)="stand_walkFholdbash_kar"
     PA_WalkHoldBash(1)="stand_walkBholdbash_kar"
     PA_WalkHoldBash(2)="stand_walkLholdbash_kar"
     PA_WalkHoldBash(3)="stand_walkRholdbash_kar"
     PA_WalkHoldBash(4)="stand_walkfLholdbash_kar"
     PA_WalkHoldBash(5)="stand_walkFRholdbash_kar"
     PA_WalkHoldBash(6)="stand_walkBLholdbash_kar"
     PA_WalkHoldBash(7)="stand_walkBRholdbash_kar"
     PA_CrouchHoldBayo(0)="crouch_walkFhold_bayo"
     PA_CrouchHoldBayo(1)="crouch_walkBhold_bayo"
     PA_CrouchHoldBayo(2)="crouch_walkLhold_bayo"
     PA_CrouchHoldBayo(3)="crouch_walkRhold_bayo"
     PA_CrouchHoldBayo(4)="crouch_walkfLhold_bayo"
     PA_CrouchHoldBayo(5)="crouch_walkFRhold_bayo"
     PA_CrouchHoldBayo(6)="crouch_walkBLhold_bayo"
     PA_CrouchHoldBayo(7)="crouch_walkBRhold_bayo"
     PA_CrouchHoldBash(0)="crouch_walkFholdbash_kar"
     PA_CrouchHoldBash(1)="crouch_walkBholdbash_kar"
     PA_CrouchHoldBash(2)="crouch_walkLholdbash_kar"
     PA_CrouchHoldBash(3)="crouch_walkRholdbash_kar"
     PA_CrouchHoldBash(4)="crouch_walkfLholdbash_kar"
     PA_CrouchHoldBash(5)="crouch_walkFRholdbash_kar"
     PA_CrouchHoldBash(6)="crouch_walkBLholdbash_kar"
     PA_CrouchHoldBash(7)="crouch_walkBRholdbash_kar"
     PA_SprintHoldBayo(0)="stand_sprintFhold_bayo"
     PA_SprintHoldBayo(1)="stand_sprintBhold_bayo"
     PA_SprintHoldBayo(2)="stand_sprintLhold_bayo"
     PA_SprintHoldBayo(3)="stand_sprintRhold_bayo"
     PA_SprintHoldBayo(4)="stand_sprintfLhold_bayo"
     PA_SprintHoldBayo(5)="stand_sprintFRhold_bayo"
     PA_SprintHoldBayo(6)="stand_sprintBLhold_bayo"
     PA_SprintHoldBayo(7)="stand_sprintBRhold_bayo"
     PA_SprintHoldBash(0)="stand_sprintFholdbash_kar"
     PA_SprintHoldBash(1)="stand_sprintBholdbash_kar"
     PA_SprintHoldBash(2)="stand_sprintLholdbash_kar"
     PA_SprintHoldBash(3)="stand_sprintRholdbash_kar"
     PA_SprintHoldBash(4)="stand_sprintfLholdbash_kar"
     PA_SprintHoldBash(5)="stand_sprintFRholdbash_kar"
     PA_SprintHoldBash(6)="stand_sprintBLholdbash_kar"
     PA_SprintHoldBash(7)="stand_sprintBRholdbash_kar"
     PA_SprintCrouchHoldBayo(0)="crouch_sprintFhold_bayo"
     PA_SprintCrouchHoldBayo(1)="crouch_sprintBhold_bayo"
     PA_SprintCrouchHoldBayo(2)="crouch_sprintLhold_bayo"
     PA_SprintCrouchHoldBayo(3)="crouch_sprintRhold_bayo"
     PA_SprintCrouchHoldBayo(4)="crouch_sprintfLhold_bayo"
     PA_SprintCrouchHoldBayo(5)="crouch_sprintFRhold_bayo"
     PA_SprintCrouchHoldBayo(6)="crouch_sprintBLhold_bayo"
     PA_SprintCrouchHoldBayo(7)="crouch_sprintBRhold_bayo"
     PA_SprintCrouchHoldBash(0)="crouch_sprintFholdbash_kar"
     PA_SprintCrouchHoldBash(1)="crouch_sprintBholdbash_kar"
     PA_SprintCrouchHoldBash(2)="crouch_sprintLholdbash_kar"
     PA_SprintCrouchHoldBash(3)="crouch_sprintRholdbash_kar"
     PA_SprintCrouchHoldBash(4)="crouch_sprintfLholdbash_kar"
     PA_SprintCrouchHoldBash(5)="crouch_sprintFRholdbash_kar"
     PA_SprintCrouchHoldBash(6)="crouch_sprintBLholdbash_kar"
     PA_SprintCrouchHoldBash(7)="crouch_sprintBRholdbash_kar"
     PA_TurnRightAnim="TurnR_kar"
     PA_TurnLeftAnim="TurnL_kar"
     PA_TurnIronRightAnim="TurnR_iron_kar"
     PA_TurnIronLeftAnim="TurnL_iron_kar"
     PA_CrouchTurnIronRightAnim="crouch_turnRiron_kar"
     PA_CrouchTurnIronLeftAnim="crouch_turnRiron_kar"
     PA_ProneTurnRightAnim="prone_turnR_kar"
     PA_ProneTurnLeftAnim="prone_turnL_kar"
     PA_StandToProneAnim="stand_prone_Kar"
     PA_CrouchToProneAnim="crouch_prone_Kar"
     PA_ProneToStandAnim="prone_stand_Kar"
     PA_ProneToCrouchAnim="prone_crouch_Kar"
     PA_CrouchTurnRightAnim="Crouch_turnR_kar"
     PA_CrouchTurnLeftAnim="Crouch_turnL_kar"
     PA_IdleCrouchAnim="Ch_Kar"
     PA_IdleRestAnim="idle_kar"
     PA_IdleWeaponAnim="idle_kar"
     PA_IdleIronRestAnim="idle_iron_kar"
     PA_IdleIronWeaponAnim="idle_iron_kar"
     PA_IdleProneAnim="prone_idle_Kar"
     PA_IdleBayoHold="stand_idlehold_bayo"
     PA_IdleCrouchBayoHold="crouch_idlehold_bayo"
     PA_IdleProneBayoHold="prone_idlehold_bayo"
     PA_IdleBashHold="stand_idleholdbash_kar"
     PA_IdleCrouchBashHold="crouch_idleholdbash_kar"
     PA_IdleProneBashHold="prone_idlehold_bayo"
     PA_ReloadAnim="reload_kar"
     PA_ProneReloadAnim="prone_reload_kar"
     PA_StandBoltActionAnim="stand_bolthip_kar"
     PA_StandIronBoltActionAnim="stand_boltiron_kar"
     PA_CrouchBoltActionAnim="crouch_bolt_kar"
     PA_CrouchIronBoltActionAnim="crouch_boltiron_kar"
     PA_ProneBoltActionAnim="prone_bolt_kar"
     PA_Fire="bolt_kar"
     PA_IronFire="bolt_iron_kar"
     PA_CrouchFire="crouch_aimed_kar"
     PA_CrouchIronFire="crouch_shootiron_kar"
     PA_ProneFire="prone_bolt_kar"
     PA_FireLastShot="aimed_kar"
     PA_IronFireLastShot="iron_aimed_kar"
     PA_CrouchFireLastShot="crouch_aimed_kar"
     PA_ProneFireLastShot="prone_aimed_kar"
     PA_HitFAnim="hitF_rifle"
     PA_HitBAnim="hitB_rifle"
     PA_HitLAnim="hitL_rifle"
     PA_HitRAnim="hitR_rifle"
     PA_HitLLegAnim="hitL_leg_rifle"
     PA_HitRLegAnim="hitR_leg_rifle"
     PA_CrouchHitUpAnim="ch_lowerhit_kar"
     PA_CrouchHitDownAnim="ch_upperhit_kar"
     PA_ProneHitAnim="prone_hit_kar"
     PA_AirStillAnim="jump_mid_kar"
     PA_AirAnims(0)="jumpF_mid_kar"
     PA_AirAnims(1)="jumpB_mid_kar"
     PA_AirAnims(2)="jumpL_mid_kar"
     PA_AirAnims(3)="jumpR_mid_kar"
     PA_TakeoffStillAnim="jump_takeoff_kar"
     PA_TakeoffAnims(0)="jumpF_takeoff_kar"
     PA_TakeoffAnims(1)="jumpB_takeoff_kar"
     PA_TakeoffAnims(2)="jumpL_takeoff_kar"
     PA_TakeoffAnims(3)="jumpR_takeoff_kar"
     PA_LandAnims(0)="jumpF_land_kar"
     PA_LandAnims(1)="jumpB_land_kar"
     PA_LandAnims(2)="jumpL_land_kar"
     PA_LandAnims(3)="jumpR_land_kar"
     PA_DodgeAnims(0)="jumpF_mid_kar"
     PA_DodgeAnims(1)="jumpB_mid_kar"
     PA_DodgeAnims(2)="jumpL_mid_kar"
     PA_DodgeAnims(3)="jumpR_mid_kar"
     MenuDescription="Description unavailable."
     bRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     LightPeriod=3
     bUseCollisionStaticMesh=True
}
