//=============================================================================
// MP5MMedicGun
//=============================================================================
// A modified MP5 SMG and Medic Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MMedicGun extends MP7MMedicGun;

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
     HealBoostAmount=30
     HealAmmoCharge=650
     AmmoRegenRate=0.200000
     MagCapacity=32
     ReloadRate=3.800000
     WeaponReloadAnim="Reload_MP5"
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Mp5Medic'
     MeshRef="KF_Wep_MP5.MP5_Trip"
     SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.MP5_cmb"
     SelectSoundRef="KF_MP5Snd.WEP_MP5_Foley_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Mp5Medic_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Mp5Medic"
     FireModeClass(0)=Class'KFMod.MP5MFire'
     FireModeClass(1)=Class'KFMod.MP5MAltFire'
     Description="MP5 sub machine gun. Modified to fire healing darts. Better damage and healing than MP7M with a larger mag."
     Priority=80
     GroupOffset=4
     PickupClass=Class'KFMod.MP5MPickup'
     AttachmentClass=Class'KFMod.MP5MAttachment'
     ItemName="MP5M Medic Gun"
}
