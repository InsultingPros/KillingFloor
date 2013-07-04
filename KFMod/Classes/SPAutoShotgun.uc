//=============================================================================
// SPAutoShotgun
//=============================================================================
// Steam Punk Fully Automatic Shotgun class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPAutoShotgun extends AA12AutoShotgun;

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    super(KFWeapon).AltFire(F);
}

// Toggle semi/auto fire
simulated function DoToggle (){}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease){}

exec function SwitchModes(){}


simulated function WeaponTick(float dt)
{
    local float SecondaryCharge;
    local rotator DialRot;

    super.WeaponTick(dt);

	if ( Level.NetMode!=NM_DedicatedServer )
	{
        if( FireMode[1].NextFireTime >= Level.TimeSeconds )
        {
            log("Remaining = "$(FireMode[1].NextFireTime - Level.TimeSeconds)$" FireMode[1].FireRate = "$FireMode[1].FireRate$" Scale = "$((FireMode[1].NextFireTime - Level.TimeSeconds)/FireMode[1].FireRate));
            SecondaryCharge = 1.0 - ((FireMode[1].NextFireTime - Level.TimeSeconds)/FireMode[1].FireRate);
        }
        else
        {
            SecondaryCharge = 1.0;
        }

        if( SecondaryCharge > 0.1 && FireMode[0].NextFireTime >= Level.TimeSeconds )
        {
            //log("Remaining = "$(FireMode[1].NextFireTime - Level.TimeSeconds)$" FireMode[1].FireRate = "$FireMode[1].FireRate$" Scale = "$((FireMode[1].NextFireTime - Level.TimeSeconds)/FireMode[1].FireRate));
            SecondaryCharge -= 0.1 * ((FireMode[0].NextFireTime - Level.TimeSeconds)/FireMode[0].FireRate);
        }

        DialRot.roll = 26500 - ( 53000 * SecondaryCharge );
        SetBoneRotation('Dail2',DialRot,1.0);
    }
}

defaultproperties
{
     MagCapacity=10
     ReloadRate=3.300000
     WeaponReloadAnim="Reload_IJC_spJackHammer"
     SleeveNum=0
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_Jackhammer'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Summer_Weps1.Jackhammer"
     SkinRefs(1)="KF_IJC_Summer_Weapons.Jackhammer.jackhammer_cmb"
     SelectSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.Jackhammer_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.Jackhammer"
     AppID=210943
     FireModeClass(0)=Class'KFMod.SPShotgunFire'
     FireModeClass(1)=Class'KFMod.SPShotgunAltFire'
     Description="A device for throwing lead and getting sodding enemies out of your face."
     Priority=167
     GroupOffset=15
     PickupClass=Class'KFMod.SPShotgunPickup'
     PlayerViewOffset=(X=20.000000,Y=23.000000)
     AttachmentClass=Class'KFMod.SPShotgunAttachment'
     ItemName="Multichamber ZED Thrower"
}
