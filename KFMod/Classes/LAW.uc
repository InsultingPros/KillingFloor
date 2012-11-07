class LAW extends KFWeaponShotgun;

// Killing Floor's Light Anti Tank Weapon.
// This is probably about as badass as things get....

simulated event WeaponTick(float dt)
{
	if(AmmoAmount(0) == 0)
		MagAmmoRemaining = 0;
	super.Weapontick(dt);
}

/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
    if( Level.TimeSeconds < FireMode[0].NextFireTime )
    {
        return;
    }

    super.ZoomIn(bAnimateTransition);

    if( bAnimateTransition )
    {
        if( bZoomOutInterrupted )
        {
            PlayAnim('Raise',1.0,0.1);
        }
        else
        {
            PlayAnim('Raise',1.0,0.1);
        }
    }
}


/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
    super.ZoomOut(false);

    if( bAnimateTransition )
    {
        TweenAnim(IdleAnim,FastZoomOutTime);
    }
}

defaultproperties
{
     MagCapacity=1
     ReloadRate=3.000000
     WeaponReloadAnim="Reload_LAW"
     MinimumFireRange=300
     Weight=13.000000
     bHasAimingMode=True
     IdleAimAnim="AimIdle"
     StandardDisplayFOV=75.000000
     SleeveNum=3
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Law'
     bIsTier3Weapon=True
     MeshRef="KF_Weapons_Trip.LAW_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.Supers.law_cmb"
     SkinRefs(1)="KF_Weapons_Trip_T.Supers.law_reddot_shdr"
     SkinRefs(2)="KF_Weapons_Trip_T.Supers.rocket_cmb"
     SelectSoundRef="KF_LAWSnd.LAW_Select"
     HudImageRef="KillingFloorHUD.WeaponSelect.LAW_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.LAW"
     PlayerIronSightFOV=90.000000
     ZoomTime=0.260000
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'KFMod.LAWFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToRocketLauncher"
     AIRating=1.500000
     CurrentRating=1.500000
     bSniping=False
     Description="The Light Anti Tank Weapon is, as its name suggests, a military grade heavy weapons platform designed to disable or outright destroy armored vehicles."
     EffectOffset=(X=50.000000,Y=1.000000,Z=10.000000)
     DisplayFOV=75.000000
     Priority=195
     HudColor=(G=0)
     InventoryGroup=4
     GroupOffset=9
     PickupClass=Class'KFMod.LAWPickup'
     PlayerViewOffset=(X=30.000000,Y=30.000000)
     BobDamping=7.000000
     AttachmentClass=Class'KFMod.LAWAttachment'
     IconCoords=(X1=429,Y1=212,X2=508,Y2=251)
     ItemName="L.A.W"
     AmbientGlow=2
}
