//=============================================================================
// Frag Grenade Inventory class
//=============================================================================
class Frag extends KFWeapon;

var() name TossAnim;
var() float TossTime;
var() float TossSpawnTime;

var bool bTossActive;
var bool bTossSpawned;

var(Sounds) sound   ThrowSound;
var float   NadeThrowTimeout;   // Fallback countdown so that player couldn't get stuck unable to fire regardless of if the server drops some packets
var float   NadeThrowTime;      // Last time a nade was thrown

replication
{
	reliable if(Role < ROLE_Authority)
		ServerThrow, ServerStartThrow;
}

simulated event StartThrow()
{
    if( Role < ROLE_Authority )
    {
        if(TossTime>TossSpawnTime)
    	{
            KFPawn(Instigator).SetNadeTimeOut(TossSpawnTime + (TossTime-TossSpawnTime));
    	}
    	else
    	{
            KFPawn(Instigator).SetNadeTimeOut(TossSpawnTime);
        }
    }

	ServerStartThrow();
    PlayAnim(TossAnim, 1.0, 0.0); // FireAnimRate, TweenTime);
	PlaySound(FireMode[0].FireSound,SLOT_Interact,2.0);
	bTossActive = true;
	bTossSpawned = false;
	SetTimer(TossSpawnTime, false);
}

simulated function Timer()
{
	if(bTossActive)
	{
		if(!bTossSpawned)
		{
            ServerThrow();
			bTossSpawned=true;
			if(TossTime>TossSpawnTime)
				SetTimer(TossTime-TossSpawnTime, false);
			else Timer();
		}
		else
		{
			bTossActive = false;
			KFPawn(Instigator).ThrowGrenadeFinished();
		}
	}
	else super.Timer();
}

function ServerThrow()
{
    ConsumeAmmo(0, 1);
	FireMode[0].DoFireEffect();
	PlaySound(ThrowSound,SLOT_Interact,2.0);
}

function ServerStartThrow()
{
    if( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
    {
        bTossActive = true;
    }

    NadeThrowTime = Level.TimeSeconds;

	// Set the timeout to the same length as the timer run throughs on the client
    if(TossTime>TossSpawnTime)
	{
        NadeThrowTimeout = TossSpawnTime + (TossTime-TossSpawnTime);
	}
	else
	{
        NadeThrowTimeout = TossSpawnTime;
    }

    if( KFPawn(Instigator) != none )
    {
        KFPawn(Instigator).HandleNadeThrowAnim();
    }
}

// Have to use Tick here because we need this to run on the server
function Tick( float DeltaTime )
{
    super.Tick(DeltaTime);

    if( bTossActive && Role == ROLE_Authority && !Instigator.IsLocallyControlled())
    {
        // if its been too long since a nade was thrown, just timeout and
        // clear this flag on the pawn. Need this since most of the nade
        // throwing code doesn't run on the server!!! - Ramm
        if( (Level.TimeSeconds - NadeThrowTime) > NadeThrowTimeout )
        {
            KFPawn(Instigator).bThrowingNade = false;
            bTossActive = false;
        }
    }
}

function float GetAIRating()
{
	local Bot B;


	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

// don't select this weapon, it's not used that way any more
simulated function float RateSelf()
{
	return -100;
}

// Never select this directly
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( Inventory == None )
		return CurrentChoice;
	else
		return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}
simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( Inventory == None )
		return CurrentChoice;
	else
		return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}
simulated function Weapon WeaponChange( byte F, bool bSilent )
{
	if ( Inventory == None )
		return None;
	else return Inventory.WeaponChange(F,bSilent);
}

defaultproperties
{
     TossAnim="Toss"
     TossTime=0.366000
     TossSpawnTime=0.200000
     ThrowSound=SoundGroup'KF_GrenadeSnd.Nade_Throw'
     MagCapacity=1
     ReloadRate=1.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     Weight=1.000000
     bKFNeverThrow=True
     StandardDisplayFOV=70.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Grenade'
     FireModeClass(0)=Class'KFMod.FragFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=-5.000000
     CurrentRating=-5.000000
     Description="the frag grenade releases a dense cloud of shrapnel in a large area of effect around its detonation zone. Use with caution. "
     DisplayFOV=70.000000
     Priority=40
     InventoryGroup=0
     PickupClass=Class'KFMod.FragPickup'
     BobDamping=10.000000
     AttachmentClass=Class'KFMod.FragAttachment'
     IconCoords=(X1=458,Y1=82,X2=491,Y2=133)
     ItemName="Frag Grenade"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Frag_Trip'
     Skins(0)=Shader'KillingFloorWeapons.Frag_Grenade.FragShader'
     AmbientGlow=2
     TransientSoundVolume=1.000000
     TransientSoundRadius=700.000000
}
