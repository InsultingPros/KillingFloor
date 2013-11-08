class KFWeapon extends BaseKFWeapon
	abstract;

#exec OBJ LOAD FILE=KF_9MMSnd.uax

var()   vector FirstPersonFlashlightOffset;


var config enum KFScopeDetailSettings
{
	KF_ModelScope,
	KF_TextureScope,
	KF_ModelScopeHigh,
	KF_None
} 	KFScopeDetail;   								// Which detail setting for the scope

var			bool 			bHasScope; 				// true for any sniper weapons, aka they'll have scopes
var(Zooming)    float       ZoomedDisplayFOVHigh;       // What is the DisplayFOV when zoomed in on high scope detail setting
var     float               ForceZoomOutTime;       // When set the weapon will zoom out at this time
var         bool            bForceLeaveIronsights;  // Force the weapon out of ironsights on the next tick
var(Zooming) float          ForceZoomOutOnFireTime; // How long to wait after firing to force zoom out. If zero don't force zoom out on fire
var(Zooming) float          ForceZoomOutOnAltFireTime; // How long to wait after alt firing to force zoom out. If zero don't force zoom out on alt fire

var()       int         	MagCapacity;      // How Much ammo this weapon can hold in its magazine
var() 		float 			ReloadRate;
var 		float			ReloadTimer;
var         int         	MagAmmoRemaining;// How many bullets are left in the weapon's magazine
var 		bool			bSpeedMeUp;

var         bool            bHasSecondaryAmmo;				// This weapon has secondary ammo that we need to show on the hud
var         bool            bReduceMagAmmoOnSecondaryFire;	// Some weapons (like the M4 with M203 launcher) don't want to have primary ammo decrement when secondary fire occurs, so set this to false in that case

var() sound  ToggleSound;
var() 		name 			ReloadAnim;
var() 		float 			ReloadAnimRate;
var() 		bool 			bHoldToReload;

var     	bool    		bDoSingleReload;        // The reload key has been released, but no rounds were added yet
var     	int     		NumLoadedThisReload;    // Tracks number or rounds reloaded this reload cycle

var 		name 			FlashBoneName;
var 		name 			WeaponReloadAnim;

var() 		int 			MinimumFireRange; 		// Minimum distance to fire ...for avoiding LAW / Flamethrower casualties specifically.

var() 		name 			ModeSwitchAnim;

var() 		material 		HudImage; 				// What to display on the HUD, when this weapon isn't selected.
var() 		material 		SelectedHudImage; 		// What to display on the HUD, when this weapon is selected.

var 		bool 			bSteadyAim;  			// If Flicked,  this weapon's accuracy is not affected by Movement.

//var() float HealRate;
//var transient float HealAccum;

var bool bIsReloading, bReloadEffectDone;

var() 		float 			Weight; 				// how much does it weigh

var 		bool 			bKFNeverThrow;

var 		bool 			bAmmoHUDAsBar;

var 		bool 			bUseCombos; 			// Disable combos for the time being...Too iffy

var 		bool 			bNoHit; 				// Hack for Syringe / Welder.

var() 		bool 			bTorchEnabled; 			// just a hook for the pawn, and his light.  Dualies and Single have this set to true. the other weapons dont.

var         bool            bDualWeapon;            // This weapon is a weapon where we are holding two of the same type of gun

var 		int 			StoppingPower; 			// How much each fire of the gun slows you down. Always in negative numbers.

// Iron sights aimin
var				bool   		bAimingRifle;       	// If the weapon is in ironsights
var(Zooming)    bool    	bHasAimingMode;   		// Whether or not this weapon can go into iron sights
var()			name   		IdleAimAnim;        	// Idle anim when aiming
var(Zooming)    sound   	AimInSound;         	// sound to play when going into aiming mode
var(Zooming)    sound   	AimOutSound;        	// sound to play when going into aiming mode

var()		class<InventoryAttachment>	TacShineClass;
var 		Actor 						TacShine;

var 		Effect_TacLightProjector 	FlashLight;

var float NextAmmoCheckTime,LastAmmoResult,LastHasGunMsgTime;

// Keep track of what this weapon is doing on the client while we are throwing a grenade
var() 		enum 			EClientGrenadeState
{
	GN_None,
	GN_TempDown,
	GN_BringUp,
} ClientGrenadeState; // this will always be none on the server

// Used for putting down/bringing up the weapon when throwing a grenade
var 		float 			QuickPutDownTime;
var 		float 			QuickBringUpTime;

var 		bool 			bConsumesPhysicalAmmo;

var 		bool 			bShowPullOutHint;

var			float       	StandardDisplayFOV;   	// Stores the original nonadjusted display FOV (because we need to change the default, and want to know what the original default was)

var bool bPendingFlashlight;

var         int             NumClicks;                  // How many times the player has dry fired thier weapon
var         bool            bModeZeroCanDryFire;        // FireMode zero can dry fire/cause a reload

// Added so we can do team specific sleeves, and later role specific - Ramm
var()		byte			SleeveNum; 					// Which skin is the sleeve?
var			texture			TraderInfoTexture;			// Image for the trader menu

var         Vector          EndBeamEffect;              // Used by weapons with laser sites to designate the end of the laser beam

var			int				SellValue;

// Achievement Helpers
var	bool				bPreviouslyDropped;
var	bool				bIsTier2Weapon;
var	bool				bIsTier3Weapon;
var	PlayerController	Tier3WeaponGiver;

// Dynamic Loading
var		string			MeshRef;
var		array<string>	SkinRefs;
var		string			SelectSoundRef;
var		string			HudImageRef;
var		string			SelectedHudImageRef;
var		int				ReferenceCount;

// Weapon DLC
var	int	AppID;
var int UnlockedByAchievement;

replication
{
	reliable if(Role == ROLE_Authority)
		MagAmmoRemaining, bForceLeaveIronsights;

	reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		MagCapacity, SellValue;

	// TODO - which of these ACTUALLY need sending?
	reliable if(Role < ROLE_Authority)
		ReloadMeNow, ServerSetAiming, ServerSpawnLight, ServerRequestAutoReload,
		ServerInterruptReload;

	reliable if(Role == ROLE_Authority)
		ClientReload, ClientFinishReloading, ClientReloadEffects, FlashLight,
		ClientInterruptReload, ClientForceKFAmmoUpdate;

	reliable if(Role < ROLE_Authority)
		ServerChangeFireMode;
}

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	local int i;

	if ( !bSkipRefCount )
	{
		default.ReferenceCount++;
	}

	UpdateDefaultMesh(SkeletalMesh(DynamicLoadObject(default.MeshRef, class'SkeletalMesh')));
	default.HudImage = texture(DynamicLoadObject(default.HudImageRef, class'texture'));
	default.SelectedHudImage = texture(DynamicLoadObject(default.SelectedHudImageRef, class'texture'));
	default.SelectSound = sound(DynamicLoadObject(default.SelectSoundRef, class'sound'));

	for ( i = 0; i < default.SkinRefs.Length; i++ )
	{
		default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));
	}

	if ( KFWeapon(Inv) != none )
	{
		Inv.LinkMesh(default.Mesh);
		KFWeapon(Inv).HudImage = default.HudImage;
		KFWeapon(Inv).SelectedHudImage = default.SelectedHudImage;
		KFWeapon(Inv).SelectSound = default.SelectSound;

		for ( i = 0; i < default.SkinRefs.Length; i++ )
		{
			Inv.Skins[i] = default.Skins[i];
		}
	}
}

static function bool UnloadAssets()
{
	local int i;

	default.ReferenceCount--;
	log("UnloadAssets RefCount after: " @ default.ReferenceCount);

	UpdateDefaultMesh(none);
	default.HudImage = none;
	default.SelectedHudImage = none;

	for ( i = 0; i < default.SkinRefs.Length; i++ )
	{
		default.Skins[i] = none;
	}

	return default.ReferenceCount == 0;
}

simulated function PreTravelCleanUp(){}
simulated function AdjustIngameScope(){}
simulated function bool ShouldDrawPortal(){return false;}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( FlashLight != none )
		FlashLight.DisplayDebug(Canvas, YL, YPos);

	super.DisplayDebug(Canvas, YL, YPos);
}

simulated function PostBeginPlay()
{
	if ( default.mesh == none )
	{
		PreloadAssets(self, true);
	}

	// Weapon will handle FireMode instantiation
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	if( !bHasScope )
	{
		KFScopeDetail = KF_None;
	}

	InitFOV();
}

// Set up the widescreen FOV values for this weapon
simulated final function InitFOV()
{
	local KFPlayerController KFPC;
	local float ResX, ResY;
	local float AspectRatio;

	KFPC = KFPlayerController(Level.GetLocalPlayerController());

	if( KFPC == none )
	{
		return;
	}

	ResX = float(GUIController(KFPC.Player.GUIController).ResX);
	ResY = float(GUIController(KFPC.Player.GUIController).ResY);
	AspectRatio = ResX / ResY;

	if ( KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
	{
			PlayerIronSightFOV = CalcFOVForAspectRatio(default.PlayerIronSightFOV);
			ZoomedDisplayFOV = CalcFOVForAspectRatio(default.ZoomedDisplayFOV);
			ZoomedDisplayFOVHigh = CalcFOVForAspectRatio(default.ZoomedDisplayFOVHigh);
			DisplayFOV = CalcFOVForAspectRatio(StandardDisplayFOV);
			default.DisplayFOV = DisplayFOV;
			AdjustIngameScope();
	}
	else
	{
			PlayerIronSightFOV = default.PlayerIronSightFOV;
			ZoomedDisplayFOV = default.ZoomedDisplayFOV;
			ZoomedDisplayFOVHigh = default.ZoomedDisplayFOVHigh;
			DisplayFOV = StandardDisplayFOV;
			default.DisplayFOV = DisplayFOV;
			AdjustIngameScope();
	}
}

// For a given 4/3 based FOV, give the proper FOV for the current
// aspect ratio
simulated final function float CalcFOVForAspectRatio(float OriginalFOV)
{
	local float ResX, ResY;
	local float AspectRatio;
	local float OriginalAspectRatio;
	local float NewFOV;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Level.GetLocalPlayerController());

	if( KFPC != none && KFPC.bUseTrueWideScreenFOV )
	{
		ResX = float(GUIController(KFPC.Player.GUIController).ResX);
		ResY = float(GUIController(KFPC.Player.GUIController).ResY);
		AspectRatio = ResX / ResY;

		OriginalAspectRatio = 4/3;

		NewFOV = (ATan((Tan((OriginalFOV*Pi)/360.0)*(AspectRatio/OriginalAspectRatio)),1)*360.0)/Pi;

		return NewFOV;

	}

	return OriginalFOV;
}

// The empty sound if your out of ammo
simulated function Fire(float F)
{
	if( bModeZeroCanDryFire && MagAmmoRemaining < 1 && !bIsReloading &&
		 FireMode[0].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		ServerRequestAutoReload();

		PlayOwnedSound(FireMode[0].NoAmmoSound,SLOT_None,2.0,,,,false);
	}

	super.Fire(F);
}

// request an auto reload on the server - happens when the player dry fires
function ServerRequestAutoReload()
{
	if( /*NumClicks > 0 &&*/ AllowReload() )
	{
		ReloadMeNow();
		return;
	}
	NumClicks++;
}

simulated exec function ToggleIronSights()
{
	if( bHasAimingMode )
	{
		if( bAimingRifle )
		{
			PerformZoom(false);
		}
		else
		{
            if( Owner != none && Owner.Physics == PHYS_Falling &&
                Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
            {
                return;
            }

	   		InterruptReload();

			if( bIsReloading || !CanZoomNow() )
				return;

			PerformZoom(True);
		}
	}
}

simulated exec function IronSightZoomIn()
{
	if( bHasAimingMode )
	{
        if( Owner != none && Owner.Physics == PHYS_Falling &&
            Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            return;
        }

   		InterruptReload();

		if( bIsReloading || !CanZoomNow() )
			return;

		PerformZoom(True);
	}
}

simulated exec function IronSightZoomOut()
{
	if( bHasAimingMode )
	{
		if( bAimingRifle )
			PerformZoom(false);

		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
}

/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
	if ( ClientState != WS_PutDown && ClientState != WS_BringUp )
	{
		super.ZoomIn(bAnimateTransition);

		bAimingRifle = True;

		if( KFHumanPawn(Instigator)!=None )
			KFHumanPawn(Instigator).SetAiming(True);

		if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
		{
			if( AimInSound != none )
			{
	            PlayOwnedSound(AimInSound, SLOT_Misc,,,,, false);
	        }

			KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,ZoomTime);
		}
	}
}

/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
	super.ZoomOut(bAnimateTransition);

	bAimingRifle = False;

	if( KFHumanPawn(Instigator)!=None )
		KFHumanPawn(Instigator).SetAiming(False);

	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
	{
		if( AimOutSound != none )
		{
            PlayOwnedSound(AimOutSound, SLOT_Misc,,,,, false);
        }
		KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,ZoomTime);
	}
}

/**
 * Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
 */
simulated event OnZoomInFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the iron idle anim when we're finished zooming in
		if (anim == IdleAnim)
		{
		   PlayIdle();
		}
	}
}

/**
 * Called by the native code when the interpolation of the first person weapon from the zoomed position finishes
 */
simulated event OnZoomOutFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the regular idle anim when we're finished zooming out
		if (anim == IdleAimAnim)
		{
		   PlayIdle();
		}
	}
}

simulated function PlayIdle()
{
	if( bAimingRifle )
	{
		LoopAnim(IdleAimAnim, IdleAnimRate, 0.2);
	}
	else
	{
		LoopAnim(IdleAnim, IdleAnimRate, 0.2);
	}
}

simulated function vector GetEffectStart()
{
	local Vector FlashLoc;

	// jjs - this function should actually never be called in third person views
	// any effect that needs a 3rdp weapon offset should figure it out itself

	// 1st person
	if (Instigator.IsFirstPerson())
	{
		if ( WeaponCentered() )
			return CenteredEffectStart();

		FlashLoc = GetBoneCoords(default.FlashBoneName).Origin;

		return FlashLoc;
	}
	// 3rd person
	else
	{
		return (Instigator.Location +
			Instigator.EyeHeight*Vect(0,0,0.5) +
			Vector(Instigator.Rotation) * 40.0);
	}
}

function bool HandlePickupQuery( pickup Item )
{
    if( KFPlayerController(Instigator.Controller).IsInInventory(Item.Class, false, true) )
	{
		if( LastHasGunMsgTime<Level.TimeSeconds && PlayerController(Instigator.Controller)!=none )
		{
			LastHasGunMsgTime = Level.TimeSeconds+0.5;
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages',1);
		}
		return true;
	}
	return Super.HandlePickupQuery(Item);
}

function LightFire()  //simulated
{
	ServerSpawnLight();
}

function ServerSpawnLight()
{
	if (!FireMode[0].bIsFiring && !bIsReloading)
	  {
		if( FlashLight==None && KFHumanPawn(Owner).TorchBatteryLife >= 1 && pawn(Owner).Health > 0 )
		{
			FlashLight=spawn(class'Effect_TacLightProjector',Instigator);
			PlaySound(sound'KF_9MMSnd.NineMM_AltFire1',SLOT_Misc,100);
			PlayAnim(ModeSwitchAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
			FlashLight.bHasLight=!FlashLight.bHasLight;
		}
		else if( FlashLight!=None )
		{
			FlashLight.bHasLight=!FlashLight.bHasLight;
			PlayAnim(ModeSwitchAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
			//PlaySound(sound'KF_9MMSnd.NineMM_AltFire2 ',SLOT_Misc,100);
		}
	}
}

// Overridden to take out some UT stuff
simulated event RenderOverlays( Canvas Canvas )
{
	local int m;

	if (Instigator == None)
		return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}

exec function ReloadMeNow()
{
	local float ReloadMulti;

	if(!AllowReload())
		return;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}

	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	ReloadRate = Default.ReloadRate / ReloadMulti;

	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}

	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);

	// Reload message commented out for now - Ramm
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		 Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ClientReload()
{
	local float ReloadMulti;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}

	bIsReloading = true;
	PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
}

simulated function ClientReloadEffects(){}

//// client & server ////
// Overriden to support interrupting reloads
simulated function bool StartFire(int Mode)
{
	local bool RetVal;

	RetVal = super.StartFire(Mode);

	if( RetVal )
	{
        if( Mode == 0 && ForceZoomOutOnFireTime > 0 )
        {
            ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnFireTime;
        }
        else if( Mode == 1 && ForceZoomOutOnAltFireTime > 0 )
        {
            ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnAltFireTime;
        }

		NumClicks=0;

		InterruptReload();
	}

	return RetVal;
}

// Interrupt the reload for single bullet insert weapons
simulated function bool InterruptReload()
{
	if( bHoldToReload && bIsReloading )
	{
		ServerInterruptReload();

		if ( Level.NetMode != NM_StandAlone && (Level.NetMode != NM_ListenServer || !Instigator.IsLocallyControlled()) )
		{
			ClientInterruptReload();
		}

		return true;
	}

	return false;
}

simulated function ServerInterruptReload()
{
	bDoSingleReload = false;
	bIsReloading = false;
	bReloadEffectDone = false;
	PlayIdle();
}

// Server forces the reload to be cancelled
simulated function ClientInterruptReload()
{
	bIsReloading = false;
	PlayIdle();
}

//We shouldn't allow finishreloading to finish reloading unless
//the weapon works like that.
simulated function ActuallyFinishReloading()
{
   bDoSingleReload=false;
   ClientFinishReloading();
   bIsReloading = false;
   bReloadEffectDone = false;
}

simulated function ClientFinishReloading()
{
	bIsReloading = false;
	PlayIdle();

	if(Instigator.PendingWeapon != none && Instigator.PendingWeapon != self)
		Instigator.Controller.ClientSwitchToBestWeapon();
}

function ServerSetAiming(bool IsAiming)
{
	if( KFHumanPawn(Instigator)!=None )
		KFHumanPawn(Instigator).SetAiming(IsAiming);
	bAimingRifle = IsAiming;
}

simulated function bool AllowReload()
{
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(KFInvasionBot(Instigator.Controller) != none && !bIsReloading &&
		MagAmmoRemaining < MagCapacity && AmmoAmount(0) > MagAmmoRemaining)
		return true;

	if(KFFriendlyAI(Instigator.Controller) != none && !bIsReloading &&
		MagAmmoRemaining < MagCapacity && AmmoAmount(0) > MagAmmoRemaining)
		return true;


	if(FireMode[0].IsFiring() || FireMode[1].IsFiring() ||
		   bIsReloading || MagAmmoRemaining >= MagCapacity ||
		   ClientState == WS_BringUp ||
		   AmmoAmount(0) <= MagAmmoRemaining ||
				   (FireMode[0].NextFireTime - Level.TimeSeconds) > 0.1 )
		return false;
	return true;
}

simulated function PostNetReceive()
{
	//This function changes the weapon in netplay if it has no ammo
	//we WANT to be able to select guns without ammo. Therefore this
	//function has to be overridden do it does.....nothing.

}

function ServerStopFire(byte Mode)
{
  //TODO: This works, but could be better timing wise
  //      Still, at least the DBShottie/XBow don't have wierd
  //      negative clip sizes now

  super.ServerStopFire(Mode);

  if(MagCapacity==1)
	MagAmmoRemaining=1;

}

// TODO: Play spot the difference
// cut n pasted to change putdown behaviours
simulated function Timer()
{
	local int Mode;
	local float OldDownDelay;

	OldDownDelay = DownDelay;
	DownDelay = 0;

	if ( ClientState == WS_BringUp )
	{
		for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
	       FireMode[Mode].InitEffects();

		PlayIdle();
		ClientState = WS_ReadyToFire;

		if ( bPendingFlashlight && bTorchEnabled )
		{
			if ( Level.NetMode != NM_Client )
			{
				LightFire();
			}
			else
			{
				ClientStartFire(1);
			}

			bPendingFlashlight = false;
		}
	}
	else if ( ClientState == WS_PutDown )
	{
		if ( OldDownDelay > 0 )
		{
			if ( HasAnim(PutDownAnim) )
				PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);

			SetTimer(PutDownTime, false);
			return;
		}

		if ( Instigator.PendingWeapon == None )
		{
			if( ClientGrenadeState == GN_TempDown )
			{
				if(KFPawn(Instigator)!=none)
				{
					KFPawn(Instigator).WeaponDown();
				}
			}
			else
			{
	 			PlayIdle();
			}

			ClientState = WS_ReadyToFire;
		}
		else
		{
			if( FlashLight!=none )
				Tacshine.Destroy();
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			if ( Instigator.Weapon == self )
			{
				PlayIdle();
				ClientState = WS_ReadyToFire;
			}
			else
			{
				for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
					FireMode[Mode].DestroyEffects();
			}
		}
	}
}

// Kludge to prevent destroyed weapons destroying the ammo if other guns
// are still using the same ammo
simulated function Destroyed()
{
	local byte m;
	local Inventory InvIt;
	local byte bSaveAmmo[NUM_FIRE_MODES]; // byte, because bool arrays aren't allowed :(
	local Actor TempOwner;

	AmbientSound = None;

	if ( FlashLight != none )
		FlashLight.Destroy();

	if ( TacShine != none )
		TacShine.Destroy();

	if ( Owner == none )
	{
		TempOwner = Instigator;
	}
	else
	{
		TempOwner = Owner;
	}

	if ( TempOwner != none)
	{
		for(InvIt = TempOwner.Inventory; InvIt!=none; InvIt=InvIt.Inventory)
		{
			if(Weapon(InvIt)!=none && InvIt!=self)
			{
				for(m=0; m < NUM_FIRE_MODES; m++)
				{
					if( Weapon(InvIt).Ammo[m]==Ammo[m] )
						bSaveAmmo[m] = 1;
				}
			}
		}

		for (m = 0; m < NUM_FIRE_MODES; m++)
		{
			if ( FireMode[m] != None )
				FireMode[m].DestroyEffects();
			if( Ammo[m] != none && bSaveAmmo[m]==0 )
			{
				Ammo[m].Destroy();
				Ammo[m] = None;
			}
		}

		if ( Pawn(TempOwner) != none )
		{
			Pawn(TempOwner).DeleteInventory(self);
		}
	}

	if ( ThirdPersonActor != None )
		ThirdPersonActor.Destroy();
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	//allow selection of empty guns, so that we can select them
	//in order to chuck them away

	if ( (CurrentChoice == None) )
	{
		if ( CurrentWeapon != self )
			CurrentChoice = self;
	}
	else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
	{
		if ( (GroupOffset < CurrentWeapon.GroupOffset) && ((CurrentChoice.InventoryGroup != InventoryGroup)
		 || (GroupOffset > CurrentChoice.GroupOffset)) )
			CurrentChoice = self;
	}
	else if ( InventoryGroup == CurrentChoice.InventoryGroup )
	{
		if ( GroupOffset > CurrentChoice.GroupOffset )
			CurrentChoice = self;
	}
	else if ( InventoryGroup > CurrentChoice.InventoryGroup )
	{
		if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
		 || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
		 || ( (CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup) && (CurrentChoice.GroupOffset>CurrentWeapon.GroupOffset) ) )
			CurrentChoice = self;
	}
	else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup || ( (CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup) && (CurrentChoice.GroupOffset>CurrentWeapon.GroupOffset) ))
	 && (InventoryGroup < CurrentWeapon.InventoryGroup) )
		CurrentChoice = self;

	if ( Inventory == None )
		return CurrentChoice;
	else return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( (CurrentChoice == None) )
	{
		if ( CurrentWeapon != self )
			CurrentChoice = self;
	}
	else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
	{
		if ( (GroupOffset > CurrentWeapon.GroupOffset)
		 && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset < CurrentChoice.GroupOffset)) )
			CurrentChoice = self;
	}
	else if ( InventoryGroup == CurrentChoice.InventoryGroup )
	{
		if ( GroupOffset < CurrentChoice.GroupOffset )
			CurrentChoice = self;
	}
	else if ( InventoryGroup < CurrentChoice.InventoryGroup )
	{
		if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
		 || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
		 || ( (CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup) && (CurrentChoice.GroupOffset<CurrentWeapon.GroupOffset) ) )
			CurrentChoice = self;
	}
	else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup || (CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup) && (CurrentChoice.GroupOffset<CurrentWeapon.GroupOffset))
	 && (InventoryGroup > CurrentWeapon.InventoryGroup) )
		CurrentChoice = self;
	if ( Inventory == None )
		return CurrentChoice;
	else return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}
simulated function Weapon WeaponChange( byte F, bool bSilent )
{
	if ( InventoryGroup == F )
		return self;
	else if ( Inventory == None )
		return None;
	else return Inventory.WeaponChange(F,bSilent);
}

simulated function bool PutDown()
{
	local int Mode;

	InterruptReload();

	if ( bIsReloading )
		return false;

	if( bAimingRifle )
	{
		ZoomOut(False);
	}

	// From Weapon.uc
	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
		if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
		    	// if _RO_
				if( FireMode[Mode] == none )
					continue;
				// End _RO_

				if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
					return false;
				if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
					DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
			}
		}

		if (Instigator.IsLocallyControlled())
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
		    	// if _RO_
				if( FireMode[Mode] == none )
					continue;
				// End _RO_

				if ( FireMode[Mode].bIsFiring )
					ClientStopFire(Mode);
			}

            if (  DownDelay <= 0  || KFPawn(Instigator).bIsQuickHealing > 0)
            {
				if ( ClientState == WS_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
					TweenAnim(SelectAnim,PutDownTime);
				else if ( HasAnim(PutDownAnim) )
				{
					if( ClientGrenadeState == GN_TempDown || KFPawn(Instigator).bIsQuickHealing > 0)
                    {
                       PlayAnim(PutDownAnim, PutDownAnimRate * (PutDownTime/QuickPutDownTime), 0.0);
                	}
                	else
                	{
                	   PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
                	}

				}
			}
        }
		ClientState = WS_PutDown;
		if ( Level.GRI.bFastWeaponSwitching )
			DownDelay = 0;
		if ( DownDelay > 0 )
		{
			SetTimer(DownDelay, false);
		}
		else
		{
			if( ClientGrenadeState == GN_TempDown )
			{
			   SetTimer(QuickPutDownTime, false);
			}
			else
			{
			   SetTimer(PutDownTime, false);
			}
		}
	}
	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		// if _RO_
		if( FireMode[Mode] == none )
			continue;
		// End _RO_

		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
	}
	Instigator.AmbientSound = None;
	OldWeapon = None;
	return true; // return false if preventing weapon switch
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	local int Mode;
	local KFPlayerController Player;

	HandleSleeveSwapping();

	// Hint check
	Player = KFPlayerController(Instigator.Controller);

	if ( Player != none && ClientGrenadeState != GN_BringUp )
	{
		if ( class == class'Single' )
		{
			Player.CheckForHint(10);
		}
		else if ( class == class'Dualies' )
		{
			Player.CheckForHint(11);
		}
		else if ( class == class'Deagle' )
		{
			Player.CheckForHint(12);
		}
		else if ( class == class'Bullpup' )
		{
			Player.CheckForHint(13);
		}
		else if ( class == class'Shotgun' )
		{
			Player.CheckForHint(14);
		}
		else if ( class == class'Winchester' )
	   	{
			Player.CheckForHint(15);
		}
		else if ( class == class'Crossbow' )
	   	{
			Player.CheckForHint(16);
		}
		else if ( class == class'BoomStick' )
	   	{
			Player.CheckForHint(17);
			Player.WeaponPulloutRemark(21);
		}
		else if ( class == class'FlameThrower' )
	   	{
			Player.CheckForHint(18);
		}
		else if ( class == class'LAW' )
	   	{
			Player.CheckForHint(19);
			Player.WeaponPulloutRemark(23);
		}
		else if ( class == class'Knife' && bShowPullOutHint )
		{
			Player.CheckForHint(20);
		}
		else if ( class == class'Machete' )
		{
			Player.CheckForHint(21);
		}
		else if ( class == class'Axe' )
		{
			Player.CheckForHint(22);
			Player.WeaponPulloutRemark(24);
		}
		else if ( class == class'DualDeagle' || class == class'GoldenDualDeagle' )
		{
			Player.WeaponPulloutRemark(22);
		}

		bShowPullOutHint = true;
	}

	if ( KFHumanPawn(Instigator) != none )
		KFHumanPawn(Instigator).SetAiming(false);

	bAimingRifle = false;
	bIsReloading = false;
	IdleAnim = default.IdleAnim;
	//Super.BringUp(PrevWeapon);

	// From Weapon.uc
    if ( ClientState == WS_Hidden || ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
	{
		PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
		ClientPlayForceFeedback(SelectForce);  // jdf

		if ( Instigator.IsLocallyControlled() )
		{
			if ( (Mesh!=None) && HasAnim(SelectAnim) )
			{
                if( ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
				{
					PlayAnim(SelectAnim, SelectAnimRate * (BringUpTime/QuickBringUpTime), 0.0);
				}
				else
				{
					PlayAnim(SelectAnim, SelectAnimRate, 0.0);
				}
			}
		}

		ClientState = WS_BringUp;
        if( ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
		{
			ClientGrenadeState = GN_None;
			SetTimer(QuickBringUpTime, false);
		}
		else
		{
			SetTimer(BringUpTime, false);
		}
	}

	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		FireMode[Mode].bIsFiring = false;
		FireMode[Mode].HoldTime = 0.0;
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
		FireMode[Mode].bInstantStop = false;
	}

	if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
		OldWeapon = PrevWeapon;
	else
		OldWeapon = None;
}

//------------------------------------------------------------------------------
// HandleSleeveSwapping() - This function will handle sleeve swapping for
//	weapons depending on which player the person who picked the weapon up is.
//------------------------------------------------------------------------------
simulated function HandleSleeveSwapping()
{
	local XPawn XP;

	local Material SleeveTexture;

	// don't bother with AI players
	if( !Instigator.IsHumanControlled() || !Instigator.IsLocallyControlled() )
		return;

	XP = XPawn(Instigator);

	if( XP == none )
	{
		return;
	}

	SleeveTexture = Class<KFSpeciesType>(XP.Species).static.GetSleeveTexture();

	if( SleeveTexture != none )
		Skins[SleeveNum] = SleeveTexture;
}

simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	local Inventory Inv;
	local bool bOutOfAmmo;
	local KFWeapon KFWeap;

	if ( Super.ConsumeAmmo(Mode, Load, bAmountNeededIsMax) )
	{
		if ( Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire) )
			MagAmmoRemaining--;

		NetUpdateTime = Level.TimeSeconds - 1;

		if ( FireMode[Mode].AmmoPerFire > 0 && InventoryGroup > 0 && !bMeleeWeapon && bConsumesPhysicalAmmo &&
			 (Ammo[0] == none || FireMode[0] == none || FireMode[0].AmmoPerFire <= 0 || Ammo[0].AmmoAmount < FireMode[0].AmmoPerFire) &&
			 (Ammo[1] == none || FireMode[1] == none || FireMode[1].AmmoPerFire <= 0 || Ammo[1].AmmoAmount < FireMode[1].AmmoPerFire) )
		{
			bOutOfAmmo = true;

			for ( Inv = Instigator.Inventory; Inv != none; Inv = Inv.Inventory )
			{
				KFWeap = KFWeapon(Inv);

				if ( Inv.InventoryGroup > 0 && KFWeap != none && !KFWeap.bMeleeWeapon && KFWeap.bConsumesPhysicalAmmo &&
					 ((KFWeap.Ammo[0] != none && KFWeap.FireMode[0] != none && KFWeap.FireMode[0].AmmoPerFire > 0 &&KFWeap.Ammo[0].AmmoAmount >= KFWeap.FireMode[0].AmmoPerFire) ||
					 (KFWeap.Ammo[1] != none && KFWeap.FireMode[1] != none && KFWeap.FireMode[1].AmmoPerFire > 0 && KFWeap.Ammo[1].AmmoAmount >= KFWeap.FireMode[1].AmmoPerFire)) )
				{
					bOutOfAmmo = false;
					break;
				}
			}

			if ( bOutOfAmmo )
			{
				PlayerController(Instigator.Controller).Speech('AUTO', 3, "");
			}
		}

		return true;
	}
	return false;
}

//TODO - this should, in theory, let us buy/carry more ammo.
//       is this intended, or should this side-effect be squashed?
function ClipUpgrade()
{
	MagCapacity += (0.25 * default.MagCapacity);
}

function OwnerEvent(name EventName)
{
	if( EventName=='ChangedWeapon' )
	{
		if( TacShine!=None )
			TacShine.Destroy();
		if( FlashLight!=None && FlashLight.bHasLight )
			ServerSpawnLight();
	}
	Super.OwnerEvent(EventName);
}

simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

	if( bHasAimingMode )
	{
        if( bForceLeaveIronsights )
        {
        	if( bAimingRifle )
        	{
                ZoomOut(true);

            	if( Role < ROLE_Authority)
        			ServerZoomOut(false);
            }

            bForceLeaveIronsights = false;
        }

        if( ForceZoomOutTime > 0 )
        {
            if( bAimingRifle )
            {
        	    if( Level.TimeSeconds - ForceZoomOutTime > 0 )
        	    {
                    ForceZoomOutTime = 0;

                	ZoomOut(true);

                	if( Role < ROLE_Authority)
            			ServerZoomOut(false);
        		}
    		}
    		else
    		{
                ForceZoomOutTime = 0;
    		}
    	}
	}

	 if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

	// Turn it off on death  / battery expenditure
	if (FlashLight != none)
	{
		// Keep the 1Pweapon client beam up to date.
		AdjustLightGraphic();
		if (FlashLight.bHasLight)
		{
			if (Instigator.Health <= 0 || KFHumanPawn(Instigator).TorchBatteryLife <= 0 || Instigator.PendingWeapon != none )
			{
				//Log("Killing Light...you're out of batteries, or switched / dropped weapons");
				KFHumanPawn(Instigator).bTorchOn = false;
				ServerSpawnLight();
			}
		}
	}

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if(MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
				}
				else
				{
					ReloadMulti = 1.0;
				}

				AddReloadedAmmo();

				if( bHoldToReload )
                {
                    NumLoadedThisReload++;
                }

				if(MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;
				if(MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if( Level.NetMode!=NM_Client )
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}

// Add the ammo for this reload
function AddReloadedAmmo()
{
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(AmmoAmount(0) >= MagCapacity)
			MagAmmoRemaining = MagCapacity;
		else
			MagAmmoRemaining = AmmoAmount(0) ;

	// Don't do this on a "Hold to reload" weapon, as it can update too quick actually and cause issues maybe - Ramm
	if( !bHoldToReload )
	{
		ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
	}

	if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
	{
		KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnWeaponReloaded();
	}
}

simulated function ClientForceKFAmmoUpdate(int NewMagAmmoRemaining, int TotalAmmoRemaining)
{
	//log(self$" ClientForceKFAmmoUpdate NewMagAmmoRemaining "$NewMagAmmoRemaining$" TotalAmmoRemaining "$TotalAmmoRemaining);
	ClientForceAmmoUpdate(0, TotalAmmoRemaining);
}

simulated function DoToggle ()
{
	local PlayerController Player;

	if( IsFiring() )
	{
	   return;
	}

	Player = Level.GetLocalPlayerController();
	if ( Player!=None )
	{
		//PlayOwnedSound(sound'Inf_Weapons_Foley.stg44_firemodeswitch01',SLOT_None,2.0,,,,false);
		FireMode[0].bWaitForRelease = !FireMode[0].bWaitForRelease;
		if ( FireMode[0].bWaitForRelease )
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',0);
		else Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',1);
	}

	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);

	ServerChangeFireMode(FireMode[0].bWaitForRelease);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease)
{
    FireMode[0].bWaitForRelease = bNewWaitForRelease;
}

// TODO - Decode the purpose of this mangled mess
simulated function float ChargeBar()
{
	Return 0;
}

function byte BestMode()
{
	return 0;
}

// complete cut n' paste job needed, so that it can be modified
// to stop this function giving ammo to empty guns that have been
// thrown out
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	local bool bJustSpawnedAmmo;
	local int addAmount, InitialAmount;
	local KFPawn KFP;
    local KFPlayerReplicationInfo KFPRI;

    KFP = KFPawn(Instigator);
    if( KFP != none )
    {
        KFPRI = KFPlayerReplicationInfo(KFP.PlayerReplicationInfo);
    }

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
	{
		Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
		bJustSpawnedAmmo = false;

		if ( bNoAmmoInstances )
		{
			if ( (FireMode[m].AmmoClass == None) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )
				return;

			InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;

			if(WP!=none && WP.bThrown==true)
				InitialAmount = WP.AmmoAmount[m];
			else
			{
				// Other change - if not thrown, give the gun a full clip
				MagAmmoRemaining = MagCapacity;
			}

			if ( Ammo[m] != None )
			{
				addamount = InitialAmount + Ammo[m].AmmoAmount;
				Ammo[m].Destroy();
			}
			else
				addAmount = InitialAmount;

			AddAmmo(addAmount,m);
		}
		else
		{
			if ( (Ammo[m] == None) && (FireMode[m].AmmoClass != None) )
			{
				Ammo[m] = Spawn(FireMode[m].AmmoClass, Instigator);
				Instigator.AddInventory(Ammo[m]);
				bJustSpawnedAmmo = true;
			}
			else if ( (m == 0) || (FireMode[m].AmmoClass != FireMode[0].AmmoClass) )
				bJustSpawnedAmmo = ( bJustSpawned || ((WP != None) && !WP.bWeaponStay) );

	  	      // and here is the modification for instanced ammo actors

			if(WP!=none && WP.bThrown==true)
			{
				addAmount = WP.AmmoAmount[m];
			}
			else if ( bJustSpawnedAmmo )
			{
				if (default.MagCapacity == 0)
					addAmount = 0;  // prevent division by zero.
				else
					addAmount = Ammo[m].InitialAmount * (float(MagCapacity) / float(default.MagCapacity));
			}

			// Don't double add ammo if primary and secondary fire modes share the same ammo class
            if ( WP != none && m > 0 && (FireMode[m].AmmoClass == FireMode[0].AmmoClass) )
			{
				return;
			}

            // AddAmmo caps at MaxAmmo, but veterancy might allow for more than max,
            // so take that into account
			if( KFPRI != none && KFPRI.ClientVeteranSkill != none )
            {
                Ammo[m].MaxAmmo = float(Ammo[m].MaxAmmo) * KFPRI.ClientVeteranSkill.Static.AddExtraAmmoFor(KFPRI, Ammo[m].Class);
        	}

			Ammo[m].AddAmmo(addAmount);
			Ammo[m].GotoState('');
		}
	}
}

//this is a terribly ugly hack allowing us to silently add weapons
//in the case of buy menu consumables

//This does NOT work online and has been replaced.

function SilentGiveTo(Pawn Other, optional Pickup Pickup)
{
	local int m;
	local weapon w;
	local bool bJustSpawned;

	Instigator = Other;
	W = Weapon(Instigator.FindInventoryType(class));
	if ( W == None || W.Class != Class ) // added class check because somebody made FindInventoryType() return subclasses for some reason
	{
		bJustSpawned = true;
		GiveTo(Other);
		W = self;
	}
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if ( FireMode[m] != None )
		{
			FireMode[m].Instigator = Instigator;
			W.GiveAmmo(m,WeaponPickup(Pickup),bJustSpawned);
		}
	}


	if ( !bJustSpawned )
	{
		for (m = 0; m < NUM_FIRE_MODES; m++)
			Ammo[m] = None;
		Destroy();
	}
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
	UpdateMagCapacity(Other.PlayerReplicationInfo);

	if ( KFWeaponPickup(Pickup)!=None && Pickup.bDropped )
	{
		MagAmmoRemaining = Clamp(KFWeaponPickup(Pickup).MagAmmoRemaining, 0, MagCapacity);
	}
	else
		MagAmmoRemaining = MagCapacity;

	Super.GiveTo(Other,Pickup);
}

// Modded to allow for throwing even when out of ammo.  (also added : You cannot throw while reloading)
simulated function bool CanThrow()
{
	local int Mode;

	if(bKFNeverThrow)
	  return false;

	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
			return false;
		if ( FireMode[Mode].NextFireTime > Level.TimeSeconds)
			return false;
	}
	return (bCanThrow && !bIsReloading && (ClientState == WS_ReadyToFire || (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)));
}

simulated function ClientWeaponThrown()
{
	local int m;
	local Inventory InvIt;
   	local byte bSaveAmmo[NUM_FIRE_MODES];

	AmbientSound = None;
	Instigator.AmbientSound = None;

	if( Level.NetMode != NM_Client )
		return;

	for ( InvIt = Instigator.Inventory; InvIt != none; InvIt = InvIt.Inventory )
	{
		if ( Weapon(InvIt) != none && InvIt != self)
		{
			for ( m = 0; m < NUM_FIRE_MODES; m++ )
			{
				if ( Weapon(InvIt).Ammo[m] == Ammo[m] )
				{
					bSaveAmmo[m] = 1;
				}
			}
		}
	}

	Instigator.DeleteInventory(self);
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (Ammo[m] != none && bSaveAmmo[m] == 0 )
			Instigator.DeleteInventory(Ammo[m]);
	}
}

function DropFrom(vector StartLocation)
{
	local int m;
	local Pickup Pickup;
	local vector Direction;

	if (!bCanThrow)
		return;

	ClientWeaponThrown();

	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m].bIsFiring)
			StopFire(m);
	}

	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);
		Direction = vector(Instigator.Rotation);
	}
	else if ( Owner != none )
	{
		Direction = vector(Owner.Rotation);
	}

	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity + (Direction * 100);
		if (Instigator.Health > 0)
			WeaponPickup(Pickup).bThrown = true;
	}

	Destroyed();

	Destroy();
}

// Only fill to initial the FIRST time we come across this weapon.
simulated function FillToInitialAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
		if ( (AmmoClass[1] != None) && (AmmoClass[0] != AmmoClass[1]) )
			AmmoCharge[1] = Max(AmmoCharge[1], AmmoClass[1].Default.InitialAmount);
		return;
	}

	if ( Ammo[0] != None )
        Ammo[0].AmmoAmount = /*Max(*/Ammo[0].AmmoAmount;//,Ammo[0].InitialAmount * (float(MagCapacity) / float(default.MagCapacity)));
	if ( Ammo[1] != None )
        Ammo[1].AmmoAmount = Max(Ammo[1].AmmoAmount,Ammo[1].InitialAmount * (float(MagCapacity) / float(default.MagCapacity)));
}

// Change the Accuracy based on player movement
simulated function AccuracyUpdate(float Velocity)
{
 if (Owner != none)
 {
   if (KFFire(FireMode[0])!= none)
	KFFire(FireMode[0]).AccuracyUpdate(Velocity);
   else
   if  (KFShotgunFire(FireMode[0]) !=none)
	KFShotgunFire(FireMode[0]).AccuracyUpdate(Velocity);
 }
}

function AdjustLightGraphic()
{
	if ( TacShine==none )
	{
		TacShine = Spawn(TacShineClass,,,,);
		AttachToBone(TacShine,'LightBone');
	}
	if( FlashLight!=none )
		Tacshine.bHidden = !FlashLight.bHasLight;
}

simulated function PlayAnimZoom( bool bZoomNow ); // Called from KFZoom whenever start or end the zooming.
simulated function bool CanZoomNow()
{
	return true;
}

simulated function float GetAmmoMulti()
{
	if ( NextAmmoCheckTime > Level.TimeSeconds )
	{
		return LastAmmoResult;
	}

	NextAmmoCheckTime = Level.TimeSeconds + 1;

	if ( FireMode[0] != none && FireMode[0].AmmoClass != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none &&
		 KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		LastAmmoResult = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), FireMode[0].AmmoClass);
	}
	else
	{
		LastAmmoResult = 1;
	}

	return LastAmmoResult;
}

simulated function int MaxAmmo(int mode)
{
	if ( AmmoClass[mode] != None )
		return AmmoClass[mode].Default.MaxAmmo*GetAmmoMulti();
	return 0;
}

simulated function bool AmmoMaxed(int mode)
{
	if ( AmmoClass[mode] == None )
		return false;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;
		return AmmoCharge[mode] >= MaxAmmo(mode);
	}
	if ( Ammo[mode] == None )
		return false;
	return (Ammo[mode].AmmoAmount >= MaxAmmo(mode));
}

simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[Mode] == None )
			return 0;
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;

		return float(AmmoCharge[Mode])/float(MaxAmmo(Mode));
	}
	if (Ammo[Mode] == None)
		return 0.0;
	else return float(Ammo[Mode].AmmoAmount) / float(Ammo[Mode].MaxAmmo)*GetAmmoMulti();
}

// Avoid potential suicides...
function bool CanAttack(Actor Other)
{
	local float Dist, CheckDist;
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor HitActor;
	local int m;
	local bool bInstantHit;

	if ( (Instigator == None) || (Instigator.Controller == None) )
		return false;

	// check that target is within range
	Dist = VSize(Instigator.Location - Other.Location);
	if ( (Dist > FireMode[0].MaxRange()) && (Dist > FireMode[1].MaxRange())  ||
	Dist < MinimumFireRange)
		return false;

	// check that can see target
	if ( !Instigator.Controller.LineOfSightTo(Other) )
		return false;

	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if ( FireMode[m].bInstantHit )
			bInstantHit = true;
		else
		{
			CheckDist = FMax(CheckDist, 0.5 * FireMode[m].ProjectileClass.Default.Speed);
			CheckDist = FMax(CheckDist, 300);
			CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
		}
	}
	// check that would hit target, and not a friendly
	GetAxes(Instigator.Controller.Rotation, X,Y,Z);
	projStart = GetFireStart(X,Y,Z);
	if ( bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);
	else
	{
		// for non-instant hit, only check partial path (since others may move out of the way)
		HitActor = Trace(HitLocation, HitNormal,
				projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location),
				projStart, true);
	}

	if ( (HitActor == None) || (HitActor == Other) )
		return true;
	if ( Pawn(HitActor) == None )
		return !HitActor.BlocksShotAt(Other);
	if ( (Pawn(HitActor).Controller == None) || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller) )
		return true;

	return false;
}

simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
	if ( Instigator == None || Instigator.Controller == None )
	{
		return;
	}

	if ( AmmoClass[0] == None )
	{
		return;
	}

	if ( bNoAmmoInstances )
	{
		MaxAmmoPrimary = MaxAmmo(0);
		CurAmmoPrimary = AmmoCharge[0];

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			MaxAmmoPrimary *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), AmmoClass[0]);
			MaxAmmoPrimary = int(MaxAmmoPrimary);
		}

		return;
	}

	if ( Ammo[0] == None )
	{
		return;
	}

	MaxAmmoPrimary = Ammo[0].default.MaxAmmo;
	CurAmmoPrimary = Ammo[0].AmmoAmount;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		MaxAmmoPrimary *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Ammo[0].class);
		MaxAmmoPrimary = int(MaxAmmoPrimary);
	}
}

simulated function GetSecondaryAmmoCount(out float MaxAmmoSecondary, out float CurAmmoSecondary)
{
	if ( Instigator == none || Instigator.Controller == none || !bHasSecondaryAmmo || AmmoClass[1] == none )
	{
		MaxAmmoSecondary = 0;
		CurAmmoSecondary = 0;
		return;
	}

	if ( bNoAmmoInstances )
	{
		MaxAmmoSecondary = MaxAmmo(1);
		CurAmmoSecondary = AmmoCharge[1];

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			MaxAmmoSecondary *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), AmmoClass[1]);
			MaxAmmoSecondary = int(MaxAmmoSecondary);
		}

		return;
	}

	if ( Ammo[1] == None )
	{
		return;
	}

	MaxAmmoSecondary = Ammo[1].default.MaxAmmo;
	CurAmmoSecondary = Ammo[1].AmmoAmount;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		MaxAmmoSecondary *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Ammo[1].class);
		MaxAmmoSecondary = int(MaxAmmoSecondary);
	}
}

simulated function UpdateMagCapacity(PlayerReplicationInfo PRI)
{
	if ( KFPlayerReplicationInfo(PRI) != none && KFPlayerReplicationInfo(PRI).ClientVeteranSkill != none )
	{
		MagCapacity = default.MagCapacity * KFPlayerReplicationInfo(PRI).ClientVeteranSkill.Static.GetMagCapacityMod(KFPlayerReplicationInfo(PRI), self);
	}
	else
	{
		MagCapacity = default.MagCapacity;
	}
}

defaultproperties
{
     bReduceMagAmmoOnSecondaryFire=True
     FlashBoneName="tip"
     WeaponReloadAnim="Reload1"
     ModeSwitchAnim="'"
     bReloadEffectDone=True
     Weight=10.000000
     StoppingPower=-1000
     TacShineClass=Class'KFMod.TacLightShineAttachment'
     QuickPutDownTime=0.150000
     QuickBringUpTime=0.150000
     bConsumesPhysicalAmmo=True
     StandardDisplayFOV=90.000000
     SleeveNum=1
     SellValue=-1
     UnlockedByAchievement=-1
     bSniping=True
     bNoAmmoInstances=False
     Description="This is a very generic weapon."
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=10.000000
     LightPeriod=3
     AmbientGlow=0
     TransientSoundVolume=100.000000
}
