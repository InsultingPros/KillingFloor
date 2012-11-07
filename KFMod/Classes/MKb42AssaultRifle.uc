//=============================================================================
// MKb42 Inventory class
//=============================================================================
class MKb42AssaultRifle extends KFWeapon
	config(user);

//#exec OBJ LOAD FILE=KillingFloorWeapons.utx
//#exec OBJ LOAD FILE=KillingFloorHUD.utx
//#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax

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

exec function ReloadMeNow()
{
	local PlayerController PC;
	PC = Level.GetLocalPlayerController();
    super.ReloadMeNow();
    KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).ResetMKB42Kill();
}

defaultproperties
{
     MagCapacity=30
     ReloadRate=3.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_M4"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MKB42'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_MKB42.MKB42"
     SkinRefs(0)="KF_Weapons8_Trip_T.Weapons.MKB42_cmb"
     SelectSoundRef="KF_AK47Snd.AK47_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.MKB42_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MKB42"
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=35.000000
     FireModeClass(0)=Class'KFMod.MKb42Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="German WWII prototype assault rifle. Used by heroes from the Battle of Stalingrad to the present day!"
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=115
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=3
     GroupOffset=13
     PickupClass=Class'KFMod.MKb42Pickup'
     PlayerViewOffset=(X=20.000000,Y=18.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.MKb42Attachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="MKb42"
     TransientSoundVolume=1.250000
}
