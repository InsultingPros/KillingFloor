//=============================================================================
// KFPawn - Assault
//=============================================================================
class KFHumanPawn extends KFPawn;

//#exec OBJ LOAD FILE=KFCharacters.utx
//#exec OBJ LOAD FILE=KFSoldiers.ukx
var float DrugBonusMovement;
var bool bOnDrugs;
var Emitter Blood;
var Sound BreathingSound;
//var int BreathingTime;
var Sound MiscSound; //So I can get the damn thing to shutup if the players dead.

//var UnderWaterBlur myHitBlur;
var bool bUsingHitBlur;
var float StopBlurTime;
var         float               BlurFadeOutTime;            // Tracks how long we've spend fading out the blur
var(Blur)   float               StartingBlurFadeOutTime;    // How long to spend fading out the blur
var(Blur)   float               NewSchoolHitBlurIntensity;  // How intense to make the new school hit blur when you are hit
var config  bool                bUseBlurEffect;   			// Whether or not the blur effect should be used
var         float               CurrentBlurIntensity;       // The Currently used blur intensity

// Jarring
var()     float           JarrMoveMag;                 // Magnitude to move the player
var()     float           JarrMoveRate;                // Rate at which the player oscillates
var()     float           JarrMoveDuration;            // scalar duration of the movement
var()     float           JarrRotateMag;               // Magnitude the player 'rolls'
var()     float           JarrRotateRate;              // Rate at which the player oscillates/rolls around
var()     float           JarrRotateDuration;          // scalar duration of the roll

var int SpeedAdjustment; // Give our brave melee players a little bit more under the hood.
var float BaseMeleeIncrease;

var     int         InventorySpeedModifier;         // Modifer to the player's speed based on the weapon they are carrying
var()   float       HealthSpeedModifier;            // The maximum percentage of the default movement speed to reduce speed based on how low the player's health is
var()   float       WeightSpeedModifier;            // The maximum percentage of the default movement speed to reduce speed based on how much weight the player is carrying

var int ScoreCounter; // Once it hits two, reset 3 second score in GRI

var bool bAimingRifle;


var CameraEffect CameraEffectFound;

var () float MaxCarryWeight;

var float CurrentWeight;
var bool bMeBeDoomed;
var int AlphaAmount ; // Amount of Alpha for Cash bonus HUD.

var() Material InjuredOverlay,CriticalOverlay;

var KFPlayerController KFPC;

var () int TorchBatteryLife;
var bool bTorchOn;  // HUD var only.
var int TempScore; // temporary score.

var float LastDyingMessageTime;
var float DyingMessageDelay;

replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
		bAimingRifle;

	reliable if ( bNetDirty && (Role == Role_Authority) && bNetOwner )
		CurrentWeight,MaxCarryWeight,AlphaAmount,bTorchOn,TorchBatteryLife,bOnDrugs,
        InventorySpeedModifier;

	reliable if(RemoteRole == ROLE_AutonomousProxy)
		DoHitCamEffects, StopHitCamEffects;

	reliable if(Role < ROLE_Authority)
		SetAiming;
}

function VeterancyChanged()
{
	local Inventory I;
	local KFPlayerReplicationInfo KFPRI;
	local int MaxAmmo;

	MaxCarryWeight = Default.MaxCarryWeight;

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
	{
		MaxCarryWeight += KFPRI.ClientVeteranSkill.Static.AddCarryMaxWeight(KFPRI);
	}

	if ( CurrentWeight > MaxCarryWeight ) // Now carrying too much, drop something.
	{
		for ( I = Inventory; I != none; I = I.Inventory )
		{
			if ( KFWeapon(I) != none && !KFWeapon(I).bKFNeverThrow )
			{
				I.Velocity = Velocity;
				I.DropFrom(Location + VRand() * 10);
				if ( CurrentWeight <= MaxCarryWeight )
				{
					break; // Drop weapons until player is capable of carrying them all.
				}
			}
		}
	}

	// Make sure nothing is over the Max Ammo amount when changing Veterancy
	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( Ammunition(I) != none )
		{
			MaxAmmo = Ammunition(I).default.MaxAmmo;

			if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
			{
				MaxAmmo = float(MaxAmmo) * KFPRI.ClientVeteranSkill.static.AddExtraAmmoFor(KFPRI, Ammunition(I).Class);
			}

			if ( Ammunition(I).AmmoAmount > MaxAmmo )
			{
				Ammunition(I).AmmoAmount = MaxAmmo;
			}
		}
	}
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	SetTimer(1.5,true);
}


// Just changed to pendingWeapon
simulated function ChangedWeapon()
{
    super.ChangedWeapon();

	// Experience Level relate stuff .
	if ( Weapon != none && KFWeapon(Weapon).bSpeedMeUp )
	{
		// Adjust Melee weapon speed bonuses depending on perk.
		BaseMeleeIncrease = default.BaseMeleeIncrease;

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			BaseMeleeIncrease += KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.Static.GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo));
		}

        InventorySpeedModifier = ((default.GroundSpeed * BaseMeleeIncrease) - (KFWeapon(Weapon).Weight * 2));
	}
	else if ( Weapon == none || !KFWeapon(Weapon).bSpeedMeUp )
	{
		InventorySpeedModifier = 0;
	}
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
    super.ServerChangedWeapon(OldWeapon,NewWeapon);

	// Experience Level relate stuff .
	if( Weapon!= none && KFWeapon(Weapon).bSpeedMeUp )
	{
		// Adjust Melee weapon speed bonuses depending on perk.
		BaseMeleeIncrease = default.BaseMeleeIncrease;

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			BaseMeleeIncrease += KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.Static.GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo));
		}

        InventorySpeedModifier = ((default.GroundSpeed * BaseMeleeIncrease) - (KFWeapon(Weapon).Weight * 2));
	}
	else if (Weapon == none || !KfWeapon(Weapon).bSpeedMeUp)
	{
		InventorySpeedModifier = 0;
	}
}

simulated event ModifyVelocity(float DeltaTime, vector OldVelocity)
{
    local float WeightMod, HealthMod;
    local float EncumbrancePercentage;

    super.ModifyVelocity(DeltaTime, OldVelocity);

	if (Controller != none)
	{
        // Calculate encumbrance, but cap it to the maxcarryweight so when we use dev weapon cheats we don't move mega slow
        EncumbrancePercentage = (FMin(CurrentWeight, MaxCarryWeight)/MaxCarryWeight);
        // Calculate the weight modifier to speed
        WeightMod = (1.0 - (EncumbrancePercentage * WeightSpeedModifier));
        // Calculate the health modifier to speed
        HealthMod = ((Health/HealthMax) * HealthSpeedModifier) + (1.0 - HealthSpeedModifier);

        // Apply all the modifiers
        GroundSpeed = default.GroundSpeed * HealthMod;
        GroundSpeed *= WeightMod;
        GroundSpeed += InventorySpeedModifier;

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			GroundSpeed *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo), KFGameReplicationInfo(Level.GRI));
		}
	}
}

Simulated function tick(float DeltaTime)
{
    local float BlurAmount;

	super.Tick(deltaTime);

	if (KFPC != none)
	{
		if (KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ThreeSecondScore > 0 && AlphaAmount > 0)
			AlphaAmount -=2;

		if (AlphaAmount <= 0)
		{
			KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ThreeSecondScore = 0;
			ScoreCounter = 0;
		}
	}

	if( IsLocallyControlled() )
	{
        if( !bUsingHitBlur && BlurFadeOutTime > 0 )
        {
            BlurFadeOutTime	-= deltaTime;
            BlurAmount = BlurFadeOutTime/StartingBlurFadeOutTime * CurrentBlurIntensity;

            if( BlurFadeOutTime <= 0 )
            {
                BlurFadeOutTime = 0;
                StopHitCamEffects();
            }
            else
            {
        		if( bUseBlurEffect )
        		{
                    if( KFPC == none || !KFPC.PostFX_IsReady()  )
            		{

                        if( CameraEffectFound != none )
                        {
                            UnderWaterBlur(CameraEffectFound).BlurAlpha = Lerp( BlurAmount, 255, UnderWaterBlur(CameraEffectFound).default.BlurAlpha );
                        }
            		}
            		else
            		{
                        KFPC.SetBlur(BlurAmount);
            		}
        		}
    		}
		}
    }
}


function SetAiming(bool IsAiming)
{
	bAimingRifle = IsAiming;
}

simulated event HandleWhizSound()
{
	local float Intensity;

 	// Don't play whizz sounds for bots, or from other players
	if ( IsHumanControlled() && IsLocallyControlled() )
	{
        Spawn(class'ROBulletWhiz',,, mWhizSoundLocation);

        //log("DistSquared of whiz is "$VSizeSquared(GetBoneCoords(HeadBone).Origin - mWhizSoundLocation));

        Intensity = 1.0 - ((FMin(VSizeSquared(GetBoneCoords(HeadBone).Origin - mWhizSoundLocation),3600.0))/3600.0);  // 3600 = (60*60) = Radius of bullet whiz cylinder squared

        //log("Intensity of whiz is "$Intensity);

        AddBlur(0.15, Intensity/2);
	}
}

simulated function AddBlur(Float BlurDuration, float Intensity)
{
    if( KFPC == none )
    {
        return;
    }
	if(!bUsingHitBlur)
	{
		// If we can't handle the post processing shaders, just do an old style motion blur effect
		if( bUseBlurEffect )
		{
			StartingBlurFadeOutTime = BlurDuration;
			BlurFadeOutTime = StartingBlurFadeOutTime;

			if( CurrentBlurIntensity < Intensity )
			{
				CurrentBlurIntensity = Intensity;
			}

			if( !KFPC.PostFX_IsReady() )
			{
    				if ( CameraEffectFound == none )
    				{
					FindCameraEffect(class 'KFmod.UnderWaterBlur');
				}

				UnderWaterBlur(CameraEffectFound).BlurAlpha = UnderWaterBlur(CameraEffectFound).default.BlurAlpha;
			}
			else
			{
				KFPC.SetBlur(CurrentBlurIntensity);
			}
		}
	}
}

function Timer()
{
	//local Actor WallActor;
	//local KFBloodSplatter Streak;
	//local vector WallHit, WallNormal;

	if (BurnDown > 0)
	{
		LastBurnDamage *= 0.5;
        TakeFireDamage(LastBurnDamage, BurnInstigator);
	}
	else
	{
		RemoveFlamingEffects();
		StopBurnFX();
	}

	// Flashlight Drain
	if ( KFWeapon(Weapon)!=none && KFWeapon(Weapon).FlashLight!=none )
 	{
		// Increment / Decrement battery life
		if (KFWeapon(Weapon).FlashLight.bHasLight && TorchBatteryLife > 0)
			TorchBatteryLife -= 10;
		else if (!KFWeapon(Weapon).FlashLight.bHasLight && TorchBatteryLife < default.TorchBatteryLife)
		{
			TorchBatteryLife += 20;
			if ( TorchBatteryLife > default.TorchBatteryLife )
			{
				TorchBatteryLife = default.TorchBatteryLife;
			}
		}
	}
	else if( TorchBatteryLife<default.TorchBatteryLife )
	{
		TorchBatteryLife += 20;
		if ( TorchBatteryLife > default.TorchBatteryLife )
		{
			TorchBatteryLife = default.TorchBatteryLife;
		}
	}

	if (Controller != none)
	{
		if(KFPC != none )
		{
			bOnDrugs = false;
			// Update for the scoreboards.
			if (Health <= 0)
			{
				PlaySound(MiscSound,SLOT_Talk);
				return;
			}
			if ( Health < HealthMax * 0.25 )
			{
				PlaySound(BreathingSound, SLOT_Talk, ((50-Health)/5)*TransientSoundVolume,,TransientSoundRadius,, false);
				// Commenting this streak code out because it doesn't work and spams the log - Ramm
                //WallActor = Trace(WallHit, WallNormal, Location - 50 * Velocity, Location, false);
				//Streak= spawn(class 'KFMod.KFBloodSplatter',,,vect(0,0,0), Rotation);
				//if (Streak != none)
				//	Streak.SetRotation(Rotator(Velocity));
			}

			// Accuracy vs. Movement tweakage!  - Alex
			if (KFWeapon(Weapon) != none)
				KFWeapon(Weapon).AccuracyUpdate(vsize(Velocity));
		}
	}

	// TODO: WTF? central here
	// Instantly set the animation to arms at sides Idle if we've got no weapon (rather than Pointing an invisible gun!)
	if (Weapon != none)
	{
		if (WeaponAttachment(Weapon.ThirdPersonActor) == none && VSize(Velocity) <= 0)
			IdleWeaponAnim = IdleRestAnim;
	}
	else if (Weapon == none)
		IdleWeaponAnim = IdleRestAnim;


}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( Controller!=None && Controller.bGodMode )
		return;

	if ( KFMonster(InstigatedBy) != none )
	{
		KFMonster(InstigatedBy).bDamagedAPlayer = true;
	}

	// Don't allow momentum from a player shooting a player
	if( InstigatedBy != none && KFHumanPawn(InstigatedBy) != none )
	{
		Momentum = vect(0,0,0);
	}

	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);

	//Bloody Overlays
	if ((Health-Damage) <= 0.5*HealthMax)
		SetOverlayMaterial(InjuredOverlay,0, true);

	if ( Role == ROLE_Authority && Level.Game.NumPlayers > 1 && Health < 0.25 * HealthMax && Level.TimeSeconds - LastDyingMessageTime > DyingMessageDelay )
	{
		// Tell everyone we're dying
		PlayerController(Instigator.Controller).Speech('AUTO', 6, "");

		LastDyingMessageTime = Level.TimeSeconds;
	}

	if( Controller==none || PlayerController(Controller)==None )
		return;
}

function TakeBileDamage()
{
	local vector BileVect;

	super.TakeBileDamage();

	//TODO: move this sanity check to DoHitCamEffect?
	if(Controller == none || PlayerController(Controller) == None)
		return;

	if(Controller.bGodMode)
		return;

	BileVect.X=frand();
	BileVect.Y=frand();
	BileVect.Z=frand();
	DoHitCamEffects( BileVect, 0.35 );
}

// Overridden to support view shake changes
function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local vector direction;
    local rotator InvRotation;
    local float jarscale;

    super.PlayTakeHit( HitLocation, Damage, DamageType );

    // for standalone and client
    // Cooney
    if ( Level.NetMode != NM_DedicatedServer )
    {
        // Get the approximate direction
        // that the hit went into the body
        direction = Location - HitLocation;
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

        jarscale = 0.1f + (Damage/10.0f);
        if ( jarscale > 1.0f )
        {
            jarscale = 1.0f;
        }

        DoHitCamEffects(direction,jarscale);
    }
}

simulated function DoHitCamEffects(vector HitDirection, float JarrScale )
{
    local vector localShakeMoveMag;
    local vector localShakeMoveRate;
    local vector localShakeRotateMag;
    local vector localShakeRotateRate;

    if( KFPC == none )
    {
        return;
    }

    if( bUseBlurEffect )
	{
		if( !KFPC.PostFX_IsReady() )
		{
            CurrentBlurIntensity = 1.0;
		}
		else
		{
            CurrentBlurIntensity = NewSchoolHitBlurIntensity;
		}

		AddBlur(2.0,CurrentBlurIntensity);
	}

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

    KFPC.ShakeView(localShakeRotateMag*JarrScale,
              localShakeRotateRate*(2.0f-JarrScale),
              JarrRotateDuration,
              localShakeMoveMag*JarrScale,
              localShakeMoveRate*(2.0f-JarrScale),
              JarrMoveDuration);
}

simulated function StopHitCamEffects()
{
    CurrentBlurIntensity=0.0;

	if( CameraEffectFound != none )
	{
        RemoveCameraEffect(CameraEffectFound);
    }

    if( KFPC != none )
    {
		KFPC.StopViewShaking();
		KFPC.SetBlur(0);
    }
}

simulated function died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	StopHitCamEffects();
	super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
	StopHitCamEffects();
	Super.Destroyed();
}


simulated function CameraEffect FindCameraEffect(class<CameraEffect> CameraEffectClass)
{
	local PlayerController PlayerControllerLocal;
	local int i;

	PlayerControllerLocal = Level.GetLocalPlayerController();
	if ( PlayerControllerLocal != None )
	{
		for (i = 0; i < PlayerControllerLocal.CameraEffects.Length; i++)
			if ( PlayerControllerLocal.CameraEffects[i].Class == CameraEffectClass )
			{
				CameraEffectFound = PlayerControllerLocal.CameraEffects[i];
				break;
			}
		if ( CameraEffectFound == None )
			CameraEffectFound = CameraEffect(Level.ObjectPool.AllocateObject(CameraEffectClass));
		if ( CameraEffectFound != None )
			PlayerControllerLocal.AddCameraEffect(CameraEffectFound);
	}
	return CameraEffectFound;
}


//=============================================================================
// RemoveCameraEffect
//
// Removes one reference to the CameraEffect from the CameraEffects array. If
// there are any more references to the same CameraEffect object, they remain
// there. The CameraEffect will be put back in the ObjectPool if no other
// references to it are left in the CameraEffects array.
//=============================================================================

simulated function RemoveCameraEffect(CameraEffect CameraEffect)
{
  local PlayerController PlayerControllerLocal;
  local int i;

  PlayerControllerLocal = Level.GetLocalPlayerController();
  if ( PlayerControllerLocal != None ) {
    PlayerControllerLocal.RemoveCameraEffect(CameraEffect);
    for (i = 0; i < PlayerControllerLocal.CameraEffects.Length; i++)
      if ( PlayerControllerLocal.CameraEffects[i] == CameraEffect ) {
        log(CameraEffect@"still in CameraEffects array");
        return;
      }
    log("Freeing"@CameraEffect);
    Level.ObjectPool.FreeObject(CameraEffect);
    CameraEffectFound = none;
  }
}




simulated function PrevWeapon()
{
    if ( Level.Pauser != None )
        return;

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
    {
        PendingWeapon = Inventory.PrevWeapon(None, Weapon);
    }

    if ( PendingWeapon != None )
        Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
simulated function NextWeapon()
{
    if ( Level.Pauser != None )
        return;

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
    if ( PendingWeapon != None && Weapon != none )
        Weapon.PutDown();
}

//This is a terribly ugly hack which allows us to silently give
//weapons to pawns in the case of buy menu consumables
function SilentGiveWeapon(string aClassName )
{
	local class<Weapon> WeaponClass;
	local Weapon NewWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if( FindInventoryType(WeaponClass) != None )
		return;
	newWeapon = Spawn(WeaponClass);

	if( newWeapon != None && KFWeapon(newWeapon) != None)
		KFWeapon(newWeapon).SilentGiveTo(self);
	else if(newWeapon != none)
	    newWeapon.GiveTo(self);
}

function bool AddInventory( inventory NewItem )
{
	if( !super.AddInventory(NewItem) )
		return false;

    if( KFWeapon(NewItem) != none )
	{
		CurrentWeight += KFWeapon(NewItem).Weight;
	}
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	local Inventory I;
	local bool bFoundItem;

	if ( Role != ROLE_Authority )
	{
		return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I == Item )
		{
			bFoundItem = true;
		}
	}

	if ( bFoundItem )
	{
        if ( KFWeapon(Item) != none )
		{
			CurrentWeight -= KFWeapon(Item).Weight;
		}
	}

	super.DeleteInventory(Item);
}

function Drugs()
{

 // Still not sure what to do with this.
 // It's some sort of drug heightened adrenal state where the player can run faster etc...
 // Amusingly, it's incremental. So each "hit" (call of this function :P) will send you into
 // a further....enhanced state for the duration of the drug's life (30 seconds max).

 // call it like so :
 //   bOnDrugs = true;
 //   Drugs();

 if(bOnDrugs)
 {
// Log("You're on Some Drugs");
   DrugBonusMovement = 150;
   Groundspeed +=DrugBonusMovement;

   PlaySound(BreathingSound, SLOT_Talk, TransientSoundVolume,,TransientSoundRadius,, false);
   Weapon.StartBerserk();

   KFPC.ShakeView(vect(30,-30,30),vect(200,-300,200),30,vect(-30,30,30),vect(300,-200,200),30);

 }

}

function AddDefaultInventory()
{
	local int i;

    // Add this code in if you want to force bots to spawn without a weapon
    /*if( !IsHumanControlled() )
    {
        return;
    }*/

	if ( KFSPGameType(Level.Game) != none )
	{
		Level.Game.AddGameSpecificInventory(self);

		if ( Inventory != none )
			Inventory.OwnerEvent('LoadOut');

		return;
	}

	if ( IsLocallyControlled() )
	{
		for ( i = 0; i < 16; i++ )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddDefaultInventory(KFPlayerReplicationInfo(PlayerReplicationInfo), self);
		}

		for ( i = 0; i < 16; i++ )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

		Level.Game.AddGameSpecificInventory(self);
	}
	else
	{
		Level.Game.AddGameSpecificInventory(self);

		for ( i = 15; i >= 0; i-- )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddDefaultInventory(KFPlayerReplicationInfo(PlayerReplicationInfo), self);
		}

		for ( i = 15; i >= 0; i-- )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);
	}

	// HACK FIXME
	if ( Inventory != None )
		Inventory.OwnerEvent('LoadOut');

	Controller.ClientSwitchToBestWeapon();
}

function CreateInventoryVeterancy(string InventoryClassName, float SellValueScale)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != none )
		{
			Inv.GiveTo(self);
			if ( Inv != none )
				Inv.PickupFunction(self);

			if ( KFWeapon(Inv) != none )
			{
				KFWeapon(Inv).SellValue = float(class<KFWeaponPickup>(InventoryClass.default.PickupClass).default.Cost) * SellValueScale * 0.75;
			}

			if ( KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponSpawned(Inv);
			}
		}
	}
}

function bool CanCarry( float Weight )
{
	return ((CurrentWeight+Weight)<=MaxCarryWeight);
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	Return False;
}

function bool ShowStalkers()
{
	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.Static.ShowStalkers(KFPlayerReplicationInfo(PlayerReplicationInfo));
	}

	return false;
}

function float GetStalkerViewDistanceMulti()
{
	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.Static.GetStalkerViewDistanceMulti(KFPlayerReplicationInfo(PlayerReplicationInfo));
	}

	return 0.0;
}

/* ============ AI -  Monster threat assessment functionality ==============================
Clamped from -1 to 100, where 100 is the most threatening ==================================
===========================================================================================*/

function  float AssessThreatTo(KFMonsterController  Monster)
{
   local float ValMax;

   if(Monster == none || Monster.Pawn == none)
   {
       return -1.f;
   }

    ValMax = Square(100.f);
    return (ValMax -(VSizeSquared(Monster.Pawn.Location - Location)/ ValMax))/100.f ;
}

defaultproperties
{
     BreathingSound=Sound'KFPlayerSound.Malebreath'
     StartingBlurFadeOutTime=0.500000
     NewSchoolHitBlurIntensity=0.800000
     JarrMoveMag=50.000000
     JarrMoveRate=200.000000
     JarrMoveDuration=3.000000
     JarrRotateMag=1000.000000
     JarrRotateRate=10000.000000
     JarrRotateDuration=4.000000
     BaseMeleeIncrease=0.200000
     HealthSpeedModifier=0.300000
     WeightSpeedModifier=0.130000
     MaxCarryWeight=15.000000
     InjuredOverlay=Shader'KFCharacters.BloodiedShader'
     CriticalOverlay=Shader'KFCharacters.BloodiedShader'
     TorchBatteryLife=500
     DyingMessageDelay=10.000000
     bCanDodgeDoubleJump=False
     MultiJumpRemaining=0
     MaxMultiJump=0
     RequiredEquipment(0)="KFMod.Knife"
     RequiredEquipment(1)="KFMod.Single"
     RequiredEquipment(2)="KFMod.Frag"
     RequiredEquipment(3)="KFMod.Syringe"
     RequiredEquipment(4)="KFMod.Welder"
     bCanDoubleJump=False
     bCanWallDodge=False
     GroundSpeed=200.000000
     WaterSpeed=200.000000
     AirSpeed=230.000000
     AccelRate=1000.000000
     JumpZ=325.000000
     AirControl=0.150000
     MaxFallSpeed=600.000000
     CrouchHeight=34.000000
     HeadRadius=7.000000
     HeadHeight=2.000000
     ControllerClass=Class'KFMod.KFInvasionBot'
     CrouchTurnRightAnim="CrouchR"
     CrouchTurnLeftAnim="CrouchL"
     bDramaticLighting=False
     Mesh=SkeletalMesh'KF_Soldier_Trip.British_Soldier1'
     Skins(0)=Combiner'KF_Soldier_Trip_T.Uniforms.brit_soldier_I_cmb'
     CollisionHeight=50.000000
}
