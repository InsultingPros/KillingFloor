//=============================================================================
// Syringe Inventory class
//=============================================================================
class Syringe extends KFMeleeGun;

var () float AmmoRegenRate;
var () int HealBoostAmount;
Const MaxAmmoCount=500;
var float RegenTimer;
var localized   string  SuccessfulHealMessage;

replication
{
	reliable if( Role < ROLE_Authority )
		ServerAttemptHeal;

	reliable if( Role == ROLE_Authority )
		ClientSuccessfulHeal;

}

simulated function PostBeginPlay()
{
	// Weapon will handle FireMode instantiation
	Super.PostBeginPlay();

	if( Role == ROLE_Authority )
	{
	   if( Level.Game.NumPlayers == 1 )
	   {
            HealBoostAmount = 50;
	   }
	   else
	   {
	       HealBoostAmount = default.HealBoostAmount;
	   }
	}
}

// Try to heal a player on the server
function ServerAttemptHeal()
{
    SyringeFire(FireMode[0]).AttemptHeal();
}

// The server lets the client know they successfully healed someone
simulated function ClientSuccessfulHeal(String HealedName)
{
    SyringeFire(FireMode[0]).SuccessfulHeal();
    if( PlayerController(Instigator.Controller) != none )
    {
        PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage@HealedName, 'CriticalEvent');
    }
}

simulated function MaxOutAmmo()
{
	AmmoCharge[0] = MaxAmmoCount;
}
simulated function SuperMaxOutAmmo()
{
	AmmoCharge[0] = 999;
}
simulated function int MaxAmmo(int mode)
{
	Return MaxAmmoCount;
}
simulated function FillToInitialAmmo()
{
	AmmoCharge[0] = MaxAmmoCount;
}
simulated function int AmmoAmount(int mode)
{
	Return AmmoCharge[0];
}
simulated function bool AmmoMaxed(int mode)
{
	Return AmmoCharge[0]>=MaxAmmoCount;
}
simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
	MaxAmmoPrimary = MaxAmmoCount;
	CurAmmoPrimary = AmmoCharge[0];
}
simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
	Return float(AmmoCharge[0])/float(MaxAmmoCount);
}
simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	if( Load>AmmoCharge[0] )
		Return False;
	AmmoCharge[0]-=Load;
	Return True;
}
function bool AddAmmo(int AmmoToAdd, int Mode)
{
	if( AmmoCharge[0]<MaxAmmoCount )
	{
		AmmoCharge[0]+=AmmoToAdd;
		if( AmmoCharge[0]>MaxAmmoCount )
			AmmoCharge[0] = MaxAmmoCount;
	}
	Return False;
}
simulated function bool HasAmmo()
{
	Return (AmmoCharge[0]>0);
}
simulated function CheckOutOfAmmo()
{
	if( AmmoCharge[0]<=0 )
		OutOfAmmo();
}

simulated function float RateSelf()
{
	return -100;
}

simulated function Tick(float dt)
{
	if ( Level.NetMode!=NM_Client && AmmoCharge[0]<MaxAmmoCount && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + AmmoRegenRate;

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			AmmoCharge[0] += 10 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetSyringeChargeRate(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
		}
		else
		{
			AmmoCharge[0] += 10;
		}

		if ( AmmoCharge[0] > MaxAmmoCount )
		{
			AmmoCharge[0] = MaxAmmoCount;
		}
	}
}
simulated function Timer()
{
	Super.Timer();
	if( KFPawn(Instigator)!=None && KFPawn(Instigator).bIsQuickHealing>0 && ClientState==WS_ReadyToFire )
	{
		if( KFPawn(Instigator).bIsQuickHealing==1 )
		{
			if( !HackClientStartFire() )
			{
				if( Instigator.Health>=Instigator.HealthMax || ChargeBar()<0.75 )
					KFPawn(Instigator).bIsQuickHealing = 2; // Was healed by someone else or some other error occurred.
				SetTimer(0.2,False);
				return;
			}
			KFPawn(Instigator).bIsQuickHealing = 2;
			SetTimer(FireMode[1].FireRate+0.5,False);
		}
		else
		{
			Instigator.SwitchToLastWeapon();
			KFPawn(Instigator).bIsQuickHealing = 0;
		}
	}
	else if( ClientState==WS_Hidden && KFPawn(Instigator)!=None )
		KFPawn(Instigator).bIsQuickHealing = 0; // Weapon was changed, ensure to reset this.
}
simulated function bool HackClientStartFire()
{
	if( StartFire(1) )
	{
		if( Role<ROLE_Authority )
			ServerStartFire(1);
		FireMode[1].ModeDoFire(); // Force to start animating.
		return true;
	}
	return false;
}
simulated function float ChargeBar()
{
	return FClamp(float(AmmoCharge[0])/float(MaxAmmoCount),0,1);
}

simulated function HealthBoost(); //OBSOLOTE!

defaultproperties
{
     AmmoRegenRate=0.300000
     HealBoostAmount=20
     SuccessfulHealMessage="You healed "
     weaponRange=90.000000
     HudImage=Texture'KillingFloorHUD.WeaponSelect.syring_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.Syringe'
     Weight=0.000000
     bKFNeverThrow=True
     bAmmoHUDAsBar=True
     bConsumesPhysicalAmmo=False
     StandardDisplayFOV=85.000000
     FireModeClass(0)=Class'KFMod.SyringeFire'
     FireModeClass(1)=Class'KFMod.SyringeAltFire'
     AIRating=-2.000000
     bMeleeWeapon=False
     bShowChargingBar=True
     AmmoCharge(0)=500
     DisplayFOV=85.000000
     Priority=6
     InventoryGroup=5
     GroupOffset=2
     PickupClass=Class'KFMod.SyringePickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.SyringeAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Med-Syringe"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Syringe_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.equipment.medInjector_cmb'
     AmbientGlow=2
}
