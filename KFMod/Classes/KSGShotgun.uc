//=============================================================================
// KSGShotgun
//=============================================================================
// KSG Prototype/Modified Shotgun Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class KSGShotgun extends KFWeapon;

// Whether or not to use the wide spread setting
var bool bWideSpread;

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
		bWideSpread = !bWideSpread;
		if (bWideSpread )
		{
            Player.ReceiveLocalizedMessage(class'KFMod.KSGSwitchMessage',0);
    	}
		else
        {
            Player.ReceiveLocalizedMessage(class'KFMod.KSGSwitchMessage',1);
        }
	}

	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);

	ServerChangeFireMode(bWideSpread);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewbWideSpread)
{
    bWideSpread = bNewbWideSpread;
}

exec function SwitchModes()
{
	DoToggle();
}

simulated function bool CanZoomNow()
{
	return (!FireMode[0].bIsFiring);
}

defaultproperties
{
     ForceZoomOutOnFireTime=0.010000
     MagCapacity=12
     ReloadRate=3.160000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_KSG"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_KSG'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_KSG_Shotgun.KSG_Shotgun"
     SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.KSG_SHDR"
     SelectSoundRef="KF_KSGSnd.KSG_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.KSG_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.KSG"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'KFMod.KSGFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="An advanced Horzine prototype tactical shotgun. Features a large capacity ammo magazine and selectable tight/wide spread fire modes."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=65.000000
     Priority=100
     InventoryGroup=3
     GroupOffset=12
     PickupClass=Class'KFMod.KSGPickup'
     PlayerViewOffset=(X=15.000000,Y=20.000000,Z=-7.000000)
     BobDamping=4.500000
     AttachmentClass=Class'KFMod.KSGAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="HSG-1 Shotgun"
     TransientSoundVolume=1.250000
}
