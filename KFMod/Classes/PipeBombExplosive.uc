//=============================================================================
// Pipe bomb proximity charge Inventory class
//=============================================================================
class PipeBombExplosive extends KFWeapon;

var bool bBeingDestroyed; // We've thrown the last bomb and this explosive is about to be destroyed

var texture ArmedSkin1;
var texture ArmedSkin2;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	default.ArmedSkin1 = texture(DynamicLoadObject("KF_Weapons2_Trip_T.Special.Pipebomb_RLight_shdr", class'texture', true));
	default.ArmedSkin2 = texture(DynamicLoadObject("KF_Weapons2_Trip_T.Special.Pipebomb_GLight_OFF", class'texture', true));

	super.PreloadAssets(Inv, bSkipRefCount);
}

static function bool UnloadAssets()
{
	if ( super.UnloadAssets() )
	{
		default.ArmedSkin1 = none;
		default.ArmedSkin2 = none;
		return true;
	}

	return false;
}

// overriden to not try and play a reload animation
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
}

// overriden to not try and play a reload animation
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
}

// overriden to not try and play a reload animation
simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

	if( bHasAimingMode && Instigator != none && Instigator.IsLocallyControlled() )
	{
		if ( bAimingRifle && Instigator!=None && Instigator.Physics==PHYS_Falling )
		{
			IronSightZoomOut();
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
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        if (anim == FireMode[0].FireAnim && ammoAmount(0) > 0 )
        {
            PlayAnim(SelectAnim, SelectAnimRate, 0.1);
        }
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}

simulated function ArmDevice()
{
    Skins[1] = ArmedSkin1;
    Skins[2] = ArmedSkin2;
}

simulated function UnArmDevice()
{
    Skins[1] = default.Skins[1];
    Skins[2] = default.Skins[2];
}

// Kludge to prevent destroyed weapons destroying the ammo if other guns
// are still using the same ammo
simulated function Destroyed()
{
    if( Role < ROLE_Authority )
    {
        // Hack to switch to another weapon on the client when we throw the last pipe bomb out
        if( Instigator != none && Instigator.Controller != none )
        {
            bBeingDestroyed = true;
            Instigator.SwitchToLastWeapon();
        }
    }

    super.Destroyed();
}

simulated function bool PutDown()
{
    // Hack to switch to another weapon on the client when we throw the last pipe bomb out
    if( bBeingDestroyed )
    {
        Instigator.ChangedWeapon();
        return true;
    }
    else
    {
        return super.PutDown();
    }
}

// need to figure out modified rating based on enemy/tactical situation
simulated function float RateSelf()
{
    if( bBeingDestroyed )
        CurrentRating = -2;
    else if( ammoAmount(0) <= 1 )
        CurrentRating = -2;
    else if ( !HasAmmo() )
        CurrentRating = -2;
	else if ( Instigator.Controller == None )
		return 0;
	else
		CurrentRating = Instigator.Controller.RateWeapon(self);
	return CurrentRating;
}

defaultproperties
{
     MagCapacity=1
     Weight=1.000000
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=3
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Pipe_Bomb'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons2_Trip.PipeBomb_Trip"
     SkinRefs(0)="KF_Weapons2_Trip_T.Special.pipebomb_cmb"
     SkinRefs(1)="KF_Weapons2_Trip_T.Special.Pipebomb_RLight_OFF"
     SkinRefs(2)="KF_Weapons2_Trip_T.Special.Pipebomb_GLight_shdr"
     SelectSoundRef="KF_AA12Snd.AA12_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Pipe_Bomb_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Pipe_Bomb"
     FireModeClass(0)=Class'KFMod.PipeBombFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     bCanThrow=False
     Description="An improvised proximity explosive. Blows up when enemies get close."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=65.000000
     Priority=1
     InventoryGroup=4
     GroupOffset=11
     PickupClass=Class'KFMod.PipeBombPickup'
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.PipeBombAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="PipeBomb"
     TransientSoundVolume=1.250000
}
