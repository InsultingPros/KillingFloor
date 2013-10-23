//=============================================================================
// L85 Inventory class
//=============================================================================
class Bullpup extends KFWeapon
	config(user);

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
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

simulated function AddReloadedAmmo()
{
	super.AddReloadedAmmo();

	ResetReloadAchievement();
}

function ResetReloadAchievement()
{
	local PlayerController PC;
	local KFSteamStatsAndAchievements KFSteamStats;

	PC = PlayerController( Instigator.Controller );

	if ( PC != none )
	{
		KFSteamStats = KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements);

		if ( KFSteamStats != none )
		{
         	KFSteamStats.OnReloadSPTorBullpup();
		}
	}
}

defaultproperties
{
     MagCapacity=40
     ReloadRate=1.966667
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_BullPup"
     HudImage=Texture'KillingFloorHUD.WeaponSelect.bullpup_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.Bullpup'
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Bullpup'
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'KFMod.BullpupFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_BullpupSnd.Bullpup_Select'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="A military grade automatic rifle. Can be fired in semi-auto or full auto firemodes and comes equipped with a scope for increased accuracy."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=70
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=3
     GroupOffset=1
     PickupClass=Class'KFMod.BullpupPickup'
     PlayerViewOffset=(X=20.000000,Y=21.500000,Z=-9.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.BullpupAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Bullpup"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Bullpup_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.Rifles.bullpup_cmb'
     Skins(1)=Shader'KF_Weapons_Trip_T.Rifles.reflex_sight_A_unlit'
     TransientSoundVolume=1.250000
}
