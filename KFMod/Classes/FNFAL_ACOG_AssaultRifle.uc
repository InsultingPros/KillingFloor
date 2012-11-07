//=============================================================================
// FNFAL_ACOG_AssaultRifle
//=============================================================================
// FN FAL Assault Rifle with Acog scope Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class FNFAL_ACOG_AssaultRifle extends KFWeapon
	config(user);


replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeFireMode;
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
}

// Toggle semi/auto fire
simulated function DoToggle ()
{
	local PlayerController Player;

	Player = Level.GetLocalPlayerController();
	if ( Player!=None )
	{
		//PlayOwnedSound(sound'Inf_Weapons_Foley.stg44_firemodeswitch01',SLOT_None,2.0,,,,false);
		FireMode[0].bWaitForRelease = !FireMode[0].bWaitForRelease;
		if ( FireMode[0].bWaitForRelease )
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',0);
		else Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',1);
	}
	Super.DoToggle();

	ServerChangeFireMode(FireMode[0].bWaitForRelease);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease)
{
    FireMode[0].bWaitForRelease = bNewWaitForRelease;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

exec function SwitchModes()
{
	DoToggle();
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return AIRating;
}

function byte BestMode()
{
	return 0;
}

simulated function SetZoomBlendColor(Canvas c)
{
	local Byte    val;
	local Color   clr;
	local Color   fog;

	clr.R = 255;
	clr.G = 255;
	clr.B = 255;
	clr.A = 255;

	if( Instigator.Region.Zone.bDistanceFog )
	{
		fog = Instigator.Region.Zone.DistanceFogColor;
		val = 0;
		val = Max( val, fog.R);
		val = Max( val, fog.G);
		val = Max( val, fog.B);
		if( val > 128 )
		{
			val -= 128;
			clr.R -= val;
			clr.G -= val;
			clr.B -= val;
		}
	}
	c.DrawColor = clr;
}

simulated function bool StartFire(int Mode)
{
	if( KFHighROFFire(FireMode[Mode]) == none || FireMode[Mode].bWaitForRelease )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	   return false;

	if( AmmoAmount(0) <= 0 )
	{
    	return false;
    }

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

	if(!FireMode[0].IsInState('FireLoop'))
	{
        GetAnimParams(0, anim, frame, rate);

        if (ClientState == WS_ReadyToFire)
        {
             if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
            {
                PlayIdle();
            }
        }
	}
}

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
		// Switch looping fire anims if we switched to/from zoomed
		else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Iron_Loop')
		{
            LoopAnim('Fire_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
		}
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
		// Switch looping fire anims if we switched to/from zoomed
		else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Loop' )
		{
            LoopAnim('Fire_Iron_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
		}
	}
}

defaultproperties
{
     MagCapacity=20
     ReloadRate=3.600000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Fal_Acog"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=55.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_FNFAL'
     bIsTier3Weapon=True
     MeshRef="KF_Wep_Fal_Acog.FAL_ACOG"
     SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.FAL_cmb"
     SkinRefs(1)="KF_Weapons5_Scopes_Trip_T.FNFAL.AcogShader"
     SelectSoundRef="KF_FNFALSnd.FNFAL_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.FNFAL_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.FNFAL"
     PlayerIronSightFOV=55.000000
     ZoomedDisplayFOV=15.000000
     FireModeClass(0)=Class'KFMod.FNFALFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="Classic NATO battle rifle. Has a high rate of fire and decent accuracy, with good power."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=55.000000
     Priority=180
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=4
     GroupOffset=12
     PickupClass=Class'KFMod.FNFAL_ACOG_Pickup'
     PlayerViewOffset=(X=3.000000,Y=15.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.FNFAL_ACOG_Attachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="FNFAL ACOG"
     TransientSoundVolume=1.250000
}
