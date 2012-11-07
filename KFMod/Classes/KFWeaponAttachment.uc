// Tracer Fire

class KFWeaponAttachment extends BaseKFWeaponAttachment;

var class<Emitter>      mMuzFlashClass;
var Emitter             mMuzFlash3rd;

var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var() float             mTracerPullback;
var() float             mTracerMinDistance;
var() float             mTracerSpeed;
var byte                OldSpawnHitCount;// Saved hit effect spawn count

var class<xEmitter>     mShellCaseEmitterClass;
var xEmitter            mShellCaseEmitter;
var() vector            mShellEmitterOffset;
var()   name            ShellEjectBoneName;

var vector  mOldHitLocation;

var Pawn LastInstig;

var vector OlComprVect;

var     bool    bDoFiringEffects;   // Whether or not to do tracers, muzzle flashes, shell ejects, etc

// Anims to use when using this weapon attachment
// From Pawn
var name MovementAnims[8];		// Forward, Back, Left, Right, Forward-Left, Forward-Right, Back-Left, Back-Right
var name TurnLeftAnim;
var name TurnRightAnim;			// turning anims when standing in place (scaled by turn speed)
var name SwimAnims[4];      // 0=forward, 1=backwards, 2=left, 3=right
var name CrouchAnims[8];	// Forward, Back, Left, Right, Forward-Left, Forward-Right, Back-Left, Back-Right
var name WalkAnims[8];
var name AirAnims[4];
var name TakeoffAnims[4];
var name LandAnims[4];
var name DoubleJumpAnims[4];
var name DodgeAnims[4];
var name AirStillAnim;
var name TakeoffStillAnim;
var name CrouchTurnRightAnim;
var name CrouchTurnLeftAnim;
var name IdleCrouchAnim;
var name IdleSwimAnim;
var name IdleWeaponAnim;    // WeaponAttachment code will set this one
var name IdleRestAnim;
var name IdleChatAnim;

// From XPawn
var name WallDodgeAnims[4];
var name IdleHeavyAnim;
var name IdleRifleAnim;
var name FireAnims[4];
var name FireAltAnims[4];
var name FireCrouchAnims[4];
var name FireCrouchAltAnims[4];

// New
var name HitAnims[4];

var name PostFireBlendStandAnim;
var name PostFireBlendCrouchAnim;

var string MeshRef;
var string AmbientSoundRef;

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
	UpdateDefaultMesh(Mesh(DynamicLoadObject(default.MeshRef, class'Mesh', true)));

	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	if ( Spawned != none )
	{
		Spawned.LinkMesh(default.Mesh);
		Spawned.AmbientSound = default.AmbientSound;
	}
}

static function bool UnloadAssets()
{
	UpdateDefaultMesh(none);

	default.AmbientSound = none;

	return true;
}

simulated function PostNetReceive()
{
	if( Instigator!=LastInstig )
	{
		LastInstig = Instigator;
		if( KFPawn(Instigator)!=None )
		{
			KFPawn(Instigator).SetWeaponAttachment(self);
		}
	}
}

simulated function PostNetBeginPlay()
{
	if ( mesh == none )
	{
		PreloadAssets(self);
	}

	Super.PostNetBeginPlay();

	LastInstig = Instigator;
	mHitLocation = vect(0,0,0);
	bNetNotify = True;
}

simulated function UpdateTacBeam( float Dist );
simulated function TacBeamGone();

simulated function SpawnTracer()
{
	local vector SpawnLoc, SpawnDir, SpawnVel;
	local float hitDist;

    if( !bDoFiringEffects )
    {
        return;
    }

	if (mTracer == None)
		mTracer = Spawn(mTracerClass);

	if( mTracer != None )
	{
		SpawnLoc = GetTracerStart();
		mTracer.SetLocation(SpawnLoc);

		hitDist = VSize(mHitLocation - SpawnLoc) - mTracerPullback;

		SpawnDir = Normal(mHitLocation - SpawnLoc);

		if(hitDist > mTracerMinDistance)
		{
			SpawnVel = SpawnDir * mTracerSpeed;
			mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}
	}
}

simulated function Destroyed()
{
	if (mTracer != None)
		mTracer.Destroy();

	if (mMuzFlash3rd != None)
		mMuzFlash3rd.Destroy();

	if (mShellCaseEmitter != None)
		mShellCaseEmitter.Destroy();

	Super.Destroyed();
}

simulated function vector GetTracerStart()
{
	local Pawn p;

	p = Pawn(Owner);

	if ( (p != None) && p.IsFirstPerson() && p.Weapon != None )
		return p.Weapon.GetEffectStart();

	if( Instigator!=None && (Level.TimeSeconds-LastRenderTime)>2 )
		Return Instigator.Location;
	// 3rd person
	if ( mMuzFlash3rd != None )
		return mMuzFlash3rd.Location;
	else return Location;
}

function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation = HitLocation;
	mHitActor = HitActor;
	mHitNormal = HitNormal;
	NetUpdateTime = Level.TimeSeconds - 1;
}

simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
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
				if( mHitActor!=None )
					Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
				CheckForSplash();
				SpawnTracer();
			}
		}
	}

  	if ( FlashCount>0 )
	{
		if( KFPawn(Instigator)!=None )
		{
			if (FiringMode == 0)
			{
				KFPawn(Instigator).StartFiringX(false,bRapidFire);
			}
			else
            {
                KFPawn(Instigator).StartFiringX(true,bRapidFire);
            }
		}

		if( bDoFiringEffects )
		{
    		PC = Level.GetLocalPlayerController();

    		if ( (Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC) )
    			return;

    		WeaponLight();

    		DoFlashEmitter();

    		if ( (mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
    		{
    			mShellCaseEmitter = Spawn(mShellCaseEmitterClass);
    			if ( mShellCaseEmitter != None )
    			    AttachToBone(mShellCaseEmitter, ShellEjectBoneName);
    		}
    		if (mShellCaseEmitter != None)
    			mShellCaseEmitter.mStartParticles++;
		}
	}
	else
	{
		GotoState('');
		if( KFPawn(Instigator)!=None )
			KFPawn(Instigator).StopFiring();
	}
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

simulated function DoFlashEmitter()
{
    if (mMuzFlash3rd == None)
    {
        mMuzFlash3rd = Spawn(mMuzFlashClass);
        AttachToBone(mMuzFlash3rd, 'tip');
    }
    if(mMuzFlash3rd != None)
        mMuzFlash3rd.SpawnParticle(1);
}

defaultproperties
{
     mTracerPullback=50.000000
     mTracerSpeed=7500.000000
     ShellEjectBoneName="ShellPort"
     bDoFiringEffects=True
     MovementAnims(0)="JogF_Bullpup"
     MovementAnims(1)="JogB_Bullpup"
     MovementAnims(2)="JogL_Bullpup"
     MovementAnims(3)="JogR_Bullpup"
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     CrouchAnims(0)="CHwalkF_BullPup"
     CrouchAnims(1)="CHwalkB_BullPup"
     CrouchAnims(2)="CHwalkL_BullPup"
     CrouchAnims(3)="CHwalkR_BullPup"
     WalkAnims(0)="WalkF_Single9mm"
     WalkAnims(1)="WalkB_Single9mm"
     WalkAnims(2)="WalkL_Single9mm"
     WalkAnims(3)="WalkR_Single9mm"
     AirAnims(0)="JumpF_Mid"
     AirAnims(1)="JumpF_Mid"
     AirAnims(2)="JumpL_Mid"
     AirAnims(3)="JumpR_Mid"
     TakeoffAnims(0)="JumpF_Takeoff"
     TakeoffAnims(1)="JumpF_Takeoff"
     TakeoffAnims(2)="JumpL_Takeoff"
     TakeoffAnims(3)="JumpR_Takeoff"
     LandAnims(0)="JumpF_Land"
     LandAnims(1)="JumpF_Land"
     LandAnims(2)="JumpL_Land"
     LandAnims(3)="JumpR_Land"
     DoubleJumpAnims(0)="DoubleJumpF"
     DoubleJumpAnims(1)="DoubleJumpB"
     DoubleJumpAnims(2)="DoubleJumpL"
     DoubleJumpAnims(3)="DoubleJumpR"
     DodgeAnims(0)="JumpF_Takeoff"
     DodgeAnims(1)="JumpF_Takeoff"
     DodgeAnims(2)="JumpL_Takeoff"
     DodgeAnims(3)="JumpR_Takeoff"
     AirStillAnim="JumpF_Mid"
     TakeoffStillAnim="JumpF_Takeoff"
     CrouchTurnRightAnim="CH_TurnR"
     CrouchTurnLeftAnim="CH_TurnL"
     IdleCrouchAnim="CHIdle_BullPup"
     IdleSwimAnim="Swim_Tread"
     IdleWeaponAnim="Idle_Bullpup"
     IdleRestAnim="Idle_Bullpup"
     IdleChatAnim="Idle_Bullpup"
     WallDodgeAnims(0)="WallDodgeF"
     WallDodgeAnims(1)="WallDodgeB"
     WallDodgeAnims(2)="WallDodgeL"
     WallDodgeAnims(3)="WallDodgeR"
     IdleHeavyAnim="Idle_Bullpup"
     IdleRifleAnim="Idle_Bullpup"
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
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=10.000000
     LightPeriod=3
     DrawScale=1.000000
}
