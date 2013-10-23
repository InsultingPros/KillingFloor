//=============================================================================
// SealSquealHarpoonBomber
//=============================================================================
// Weapon class for the seal squeal harpoon bomb launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SealSquealHarpoonBomber extends KFWeapon;

//=============================================================================
// Functions
//=============================================================================

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

defaultproperties
{
     MagCapacity=3
     ReloadRate=4.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_IJC_SealSqueal"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SealSqueal'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Halloween_Weps_2.SealSqueal"
     SkinRefs(0)="KF_IJC_Halloween_Weapons2.SealSqueal.SealSqueal_cmb"
     SelectSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Foley_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.SealSqueal_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SealSqueal"
     AppID=258751
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=60.000000
     FireModeClass(0)=Class'KFMod.SealSquealFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="Shoot the zeds with this harpoon gun and watch them squeal.. and then explode!"
     DisplayFOV=70.000000
     Priority=171
     InventoryGroup=4
     GroupOffset=22
     PickupClass=Class'KFMod.SealSquealPickup'
     PlayerViewOffset=(X=15.000000,Y=20.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.SealSquealAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="SealSqueal Harpoon Bomber"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
