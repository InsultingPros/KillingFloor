//=============================================================================
// KrissMMedicGun
//=============================================================================
// A modified Kriss SuperV SMG and Medic Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KrissMMedicGun extends MP7MMedicGun;

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
     HealBoostAmount=40
     HealAmmoCharge=700
     AmmoRegenRate=0.200000
     MagCapacity=25
     ReloadRate=3.330000
     WeaponReloadAnim="Reload_Kriss"
     SleeveNum=1
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_KRISS'
     bIsTier3Weapon=True
     MeshRef="KF_Wep_Kriss.Kriss_Trip"
     SkinRefs(0)="Kf_Weapons9_Trip_T.Weapons.Medic_Kriss_cmb"
     SelectSoundRef="KF_KrissSND.KF_WEP_KRISS_Handling_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.KRISS_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.KRISS"
     FireModeClass(0)=Class'KFMod.KrissMFire'
     FireModeClass(1)=Class'KFMod.KrissMAltFire'
     Description="The 'Zekk has a very high rate of fire and is equipped with the attachment for the Horzine medical darts. "
     Priority=120
     GroupOffset=17
     PickupClass=Class'KFMod.KrissMPickup'
     AttachmentClass=Class'KFMod.KrissMAttachment'
     ItemName="Schneidzekk Medic Gun"
}
