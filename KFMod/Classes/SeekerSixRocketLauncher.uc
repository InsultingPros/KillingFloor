//=============================================================================
// SeekerSixRocketLauncher
//=============================================================================
// Weapon class for the SeekerSix mini rocket launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SeekerSixRocketLauncher extends KFWeapon;

var() Material Counter0;
var() Material Counter1;
var() Material Counter2;
var() Material Counter3;
var() Material Counter4;
var() Material Counter5;
var() Material Counter6;

// Site reticles
var() Material SiteReticle;
var() Material SiteReticleLocked;
// References to site reticles
var	string	SiteReticleRef;
var	string	SiteReticleLockedRef;

var Pawn SeekTarget;
var float LockTime, UnLockTime, SeekCheckTime;
var bool bLockedOn, bBreakLock, bOldLockedOn;
var bool bTightSpread;
var(Seeking) float SeekCheckFreq, SeekRange;
var(Seeking) float LockRequiredTime, UnLockRequiredTime;
var(Seeking) float LockAim;

var     sound   LockOnSound;      // Locked on sound
var     sound   LockLostSound;    // Lost lock on sound
var     string  LockOnSoundRef;
var     string  LockLostSoundRef;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        bLockedOn;
}

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	default.Counter0 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter0_Shader", class'Material', true));
	default.Counter1 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter1_Shader", class'Material', true));
	default.Counter2 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter2_Shader", class'Material', true));
	default.Counter3 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter3_Shader", class'Material', true));
	default.Counter4 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter4_Shader", class'Material', true));
	default.Counter5 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter5_Shader", class'Material', true));
	default.Counter6 = Material(DynamicLoadObject("KF_IJC_Halloween_Weapons2.SeekerSix_Counter.Counter6_Shader", class'Material', true));

	default.SiteReticle = Material(DynamicLoadObject(default.SiteReticleRef, class'Material', true));
	default.SiteReticleLocked = Material(DynamicLoadObject(default.SiteReticleLockedRef, class'Material', true));

	if ( default.LockOnSoundRef != "" )
	{
		default.LockOnSound = sound(DynamicLoadObject(default.LockOnSoundRef, class'Sound', true));
	}

	if ( default.LockLostSoundRef != "" )
	{
		default.LockLostSound = sound(DynamicLoadObject(default.LockLostSoundRef, class'Sound', true));
	}

	if ( SeekerSixRocketLauncher(Inv) != none )
	{
		SeekerSixRocketLauncher(Inv).Counter0 = default.Counter0;
		SeekerSixRocketLauncher(Inv).Counter1 = default.Counter1;
		SeekerSixRocketLauncher(Inv).Counter2 = default.Counter2;
		SeekerSixRocketLauncher(Inv).Counter3 = default.Counter3;
		SeekerSixRocketLauncher(Inv).Counter4 = default.Counter4;
		SeekerSixRocketLauncher(Inv).Counter5 = default.Counter5;
		SeekerSixRocketLauncher(Inv).Counter6 = default.Counter6;

	    SeekerSixRocketLauncher(Inv).SiteReticle = default.SiteReticle;
        SeekerSixRocketLauncher(Inv).SiteReticleLocked = default.SiteReticleLocked;

        SeekerSixRocketLauncher(Inv).LockOnSound = default.LockOnSound;
        SeekerSixRocketLauncher(Inv).LockLostSound = default.LockLostSound;
	}

	super.PreloadAssets(Inv, bSkipRefCount);
}

static function bool UnloadAssets()
{
	if ( super.UnloadAssets() )
	{
    	default.Counter0 = none;
    	default.Counter1 = none;
    	default.Counter2 = none;
    	default.Counter3 = none;
    	default.Counter4 = none;
    	default.Counter5 = none;
    	default.Counter6 = none;


		default.LockOnSound = none;
		default.LockLostSound = none;
		default.SiteReticle = none;
		default.SiteReticleLocked = none;

		return true;
	}

	return false;
}

simulated function WeaponTick(float dt)
{
    super.WeaponTick(dt);

	if ( Level.NetMode!=NM_DedicatedServer)
	{
        if ((MagAmmoRemaining ) == 1)
        Skins[2] = Counter1;
        if ((MagAmmoRemaining ) == 2)
        Skins[2] = Counter2;
        if ((MagAmmoRemaining ) == 3)
        Skins[2] = Counter3;
        if ((MagAmmoRemaining ) == 4)
        Skins[2] = Counter4;
        if ((MagAmmoRemaining ) == 5)
        Skins[2] = Counter5;
        if ((MagAmmoRemaining ) == 6)
        Skins[2] = Counter6;
        if ((MagAmmoRemaining ) == 0)
        Skins[2] = Counter0;

        // Swap the site reticle if you are locked on
        if( bOldLockedOn != bLockedOn )
        {
            bOldLockedOn = bLockedOn;
            if( bLockedOn )
            {
                Skins[1] = SiteReticleLocked;
            }
            else
            {
                Skins[1] = SiteReticle;
            }
        }
 	}
}

// Handle locking on
function Tick(float dt)
{
    local Pawn Other;
    local Vector StartTrace;
    local Rotator Aim;
    local float BestDist, BestAim;

    if (Instigator == None || Instigator.Weapon != self)
        return;

	if ( Role < ROLE_Authority )
		return;

    if ( !Instigator.IsHumanControlled() )
        return;

    if (Level.TimeSeconds > SeekCheckTime)
    {
//        if( !bAimingRifle )
//        {
//            return;
//        }

        if( MagAmmoRemaining < 1 || bIsReloading )
        {
            bLockedOn = false;
            SeekTarget = None;
            return;
        }

        if (bBreakLock)
        {
            bBreakLock = false;
            bLockedOn = false;
            SeekTarget = None;
        }

        StartTrace = Instigator.Location + Instigator.EyePosition();
        Aim = Instigator.GetViewRotation();

        BestAim = LockAim;
        Other = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, SeekRange);

        if ( CanLockOnTo(Other) )
        {
            if (Other == SeekTarget)
            {
                LockTime += SeekCheckFreq;
                if (!bLockedOn && LockTime >= LockRequiredTime)
                {
                    bLockedOn = true;
                    PlaySound(LockOnSound,SLOT_None,2.0);
                 }
            }
            else
            {
                SeekTarget = Other;
                LockTime = 0.0;
            }
            UnLockTime = 0.0;
        }
        else
        {
            if (SeekTarget != None)
            {
                UnLockTime += SeekCheckFreq;
                if (UnLockTime >= UnLockRequiredTime)
                {
                    SeekTarget = None;
                    if (bLockedOn)
                    {
                        bLockedOn = false;
                        PlaySound(LockLostSound,SLOT_None,2.0);
                    }
                }
            }
            else
                 bLockedOn = false;
         }

        SeekCheckTime = Level.TimeSeconds + SeekCheckFreq;
    }
}

// See if this weapon can lock on to the actor
function bool CanLockOnTo(Actor Other)
{
    local Pawn P;

    P = Pawn(Other);

    if (P == None || P == Instigator || !P.bProjTarget)
        return false;

    if (!Level.Game.bTeamGame)
        return true;

	if ( (Instigator.Controller != None) && Instigator.Controller.SameTeamAs(P.Controller) )
		return false;

    return ( (P.PlayerReplicationInfo == None) || (P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team) );
}

//=============================================================================
// Functions
//=============================================================================

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local SeekerSixRocketProjectile Rocket;
    local SeekerSixSeekingRocketProjectile SeekingRocket;

    bBreakLock = true;

    if (bLockedOn && SeekTarget != None)
    {
        SeekingRocket = Spawn(class'SeekerSixSeekingRocketProjectile',,, Start, Dir);
        SeekingRocket.Seeking = SeekTarget;
        return SeekingRocket;
    }
    else
    {
        Rocket = Spawn(class'SeekerSixRocketProjectile',,, Start, Dir);
        return Rocket;
    }
}

// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( MagAmmoRemaining < 1 && !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		ServerRequestAutoReload();

		PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
	}

	super.AltFire(F);
}

simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	local Inventory Inv;
	local bool bOutOfAmmo;
	local KFWeapon KFWeap;

	if ( Super(Weapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax) )
	{
		if ( Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire) )
			MagAmmoRemaining -= Load;

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

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: long ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function AddReloadedAmmo()
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
}

defaultproperties
{
     SiteReticleRef="KF_IJC_Halloween_Weapons2.SeekerSix.Seeker_Sight_Shader"
     SiteReticleLockedRef="KF_IJC_Halloween_Weapons2.SeekerSix.Seeker_Sight_Lock_Shader"
     SeekCheckFreq=0.250000
     SeekRange=25000.000000
     LockRequiredTime=0.750000
     UnLockRequiredTime=0.500000
     LockAim=0.950000
     LockOnSoundRef="KF_FY_SeekerSixSND.WEP_Seeker_LockOn_M"
     LockLostSoundRef="KF_FY_SeekerSixSND.WEP_Seeker_LockOnLost_M"
     MagCapacity=6
     ReloadRate=3.130000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_IJC_SeekerSix"
     Weight=7.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=3
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SeekerSix'
     bIsTier3Weapon=True
     MeshRef="KF_IJC_Halloween_Weps_2.SeekerSix"
     SkinRefs(0)="KF_IJC_Halloween_Weapons2.SeekerSix.Seeker_Six_cmb"
     SkinRefs(1)="KF_IJC_Halloween_Weapons2.SeekerSix.Seeker_Sight_Shader"
     SelectSoundRef="KF_FY_SeekerSixSND.WEP_SeekerSix_Foley_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.SeekerSix_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SeekerSix"
     AppID=258751
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=60.000000
     FireModeClass(0)=Class'KFMod.SeekerSixFire'
     FireModeClass(1)=Class'KFMod.SeekerSixMultiFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="An advanced Horzine mini missile launcher. Fire one, or all six, lock on and let 'em rip!"
     DisplayFOV=65.000000
     Priority=182
     InventoryGroup=4
     GroupOffset=16
     PickupClass=Class'KFMod.SeekerSixPickup'
     PlayerViewOffset=(X=35.000000,Y=20.000000,Z=-5.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.SeekerSixAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="SeekerSix Rocket Launcher"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
