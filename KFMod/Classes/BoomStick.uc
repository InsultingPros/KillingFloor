//=============================================================================
// BoomStick Inventory class
//=============================================================================
class BoomStick extends KFWeaponShotgun;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

var     bool        bWaitingToLoadShotty;
var     float       CurrentReloadCountDown;
var()   float       ReloadCountDown;
var     int         SingleShotCount;
var     float       SingleShotReplicateCountdown;

replication
{
    reliable if(Role == ROLE_Authority)
		ClientSetSingleShotCount;
}

simulated function WeaponTick(float dt)
{
    super.WeaponTick(dt);

    if( Role == ROLE_Authority )
    {
        if( bWaitingToLoadShotty )
        {
            CurrentReloadCountDown -= dt;

            if( CurrentReloadCountDown <= 0 )
            {
                if( AmmoAmount(0) > 0 )
                {
                    MagAmmoRemaining = Min(AmmoAmount(0), 2);
                    SingleShotCount = MagAmmoRemaining;
                    ClientSetSingleShotCount(SingleShotCount);
                    NetUpdateTime = Level.TimeSeconds - 1;
    				bWaitingToLoadShotty = false;
                }
            }
        }

        if( SingleShotReplicateCountdown > 0 )
        {
            SingleShotReplicateCountdown -= dt;

            if( SingleShotReplicateCountdown <= 0 )
            {
                ClientSetSingleShotCount(SingleShotCount);
            }
        }
    }
}

// When someone holding an empty gun picks up ammo, make sure and tell the
// weapon that is has some shots it can take
function AmmoPickedUp()
{
    if( SingleShotCount == 0 )
    {
        MagAmmoRemaining = Min(AmmoAmount(0), 2);
        SingleShotCount = MagAmmoRemaining;
        ClientSetSingleShotCount(SingleShotCount);
        NetUpdateTime = Level.TimeSeconds - 1;
    }
}

simulated function SetPendingReload()
{
    bWaitingToLoadShotty = true;
    CurrentReloadCountDown = ReloadCountDown;
}

// Replicate the SingleShotCount on a slight delay. This prevents
// it from replicating from the server before the client does
// its shooting animation/sound effects which would prevent
// those from playing
function SetSingleShotReplication()
{
    SingleShotReplicateCountdown=0.05;
}

simulated function ClientSetSingleShotCount(float NewSingleShotCount)
{
    SingleShotCount = NewSingleShotCount;
}

// Overriden to support the special single firing or dual firing of the shotty
simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	if( super(Weapon).ConsumeAmmo(0, Load, bAmountNeededIsMax) )
	{
        MagAmmoRemaining -= Load;

        NetUpdateTime = Level.TimeSeconds - 1;
        return true;
	}
	return false;
}

//// client only ////
// Overriden to force a single shot if we only have 1 in the pipe
simulated event ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if( Mode == 1 && MagAmmoRemaining == 1 )
        {
            Mode = 0;
        }

        if (StartFire(Mode))
        {
            ServerStartFire(Mode);
        }
    }
    else
    {
        if( Mode == 1 && MagAmmoRemaining == 1 )
        {
            Mode = 0;
        }

        StartFire(Mode);
    }
}

// Overriden to allow switching between single/dual firing mode on the fly
simulated event ClientStopFire(int Mode)
{
    if( Mode == 0 && Instigator != none && Instigator.Controller != none )
    {
        if( Instigator.Controller.bAltFire == 1 )
            return;
    }

    if (Role < ROLE_Authority)
    {
        StopFire(Mode);
    }

    ServerStopFire(Mode);
}

simulated function bool StartFire(int Mode)
{
	if ( super.StartFire(Mode) )
	{
        if ( Instigator != none && PlayerController(Instigator.Controller) != none &&
			 KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnShotHuntingShotgun();
		}

		return true;
	}

	return false;
}

simulated function int AmmoAmount(int mode)
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			return AmmoCharge[0];
		return AmmoCharge[mode];
	}
	if ( Ammo[0] != None )
		return Ammo[0].AmmoAmount;

	return 0;
}

function bool AllowReload()
{
	if ( MagAmmoRemaining == 1 )
	{
		return false;
	}

	return super.AllowReload();
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    super.GiveAmmo(m,WP,bJustSpawned);

    // Update the singleshotcount if we pick this weapon up
    if( WP != none )
    {
        if( m == 0 && AmmoAmount(0) < 2 )
        {
            SingleShotCount = AmmoAmount(0);
            ClientSetSingleShotCount(SingleShotCount);
        }
        else if( BoomStickPickup(WP) != none )
        {
            SingleShotCount = BoomStickPickup(WP).SingleShotCount;
            ClientSetSingleShotCount(SingleShotCount);
        }
    }
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
	super.GiveTo( Other, Pickup );

	if( MagAmmoRemaining == 0 && AmmoAmount(0) > 0 )
	{
	    MagAmmoRemaining = Min(AmmoAmount(0), 2);
        SingleShotCount = MagAmmoRemaining;
        ClientSetSingleShotCount(SingleShotCount);
        NetUpdateTime = Level.TimeSeconds - 1;
		bWaitingToLoadShotty = false;
	}
}

defaultproperties
{
     ReloadCountDown=2.500000
     SingleShotCount=2
     ForceZoomOutOnFireTime=0.010000
     ForceZoomOutOnAltFireTime=0.010000
     MagCapacity=2
     ReloadRate=0.010000
     ReloadAnim="Reload"
     ReloadAnimRate=0.900000
     WeaponReloadAnim="Reload_HuntingShotgun"
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=55.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Hunting_Shotgun'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons_Trip.BoomStick_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.Shotguns.boomstick_cmb"
     SelectSoundRef="KF_DoubleSGSnd.2Barrel_Select"
     HudImageRef="KillingFloorHUD.WeaponSelect.BoomStic_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.BoomStick"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'KFMod.BoomStickAltFire'
     FireModeClass(1)=Class'KFMod.BoomStickFire'
     PutDownAnim="PutDown"
     AIRating=0.900000
     CurrentRating=0.900000
     bSniping=False
     Description="A double barreled shotgun used by big game hunters. It fires two slugs simultaneously and can bring down even the largest targets, quickly."
     DisplayFOV=55.000000
     Priority=160
     InventoryGroup=4
     GroupOffset=2
     PickupClass=Class'KFMod.BoomStickPickup'
     PlayerViewOffset=(X=8.000000,Y=14.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.BoomStickAttachment'
     ItemName="Hunting Shotgun"
     bUseDynamicLights=True
     TransientSoundVolume=1.000000
}
