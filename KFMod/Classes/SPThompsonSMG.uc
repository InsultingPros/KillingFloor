//=============================================================================
// SPThompsonSMG
//=============================================================================
// A Steampunk Thompson Sub Machine Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonSMG extends ThompsonSMG
	config(user);

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
     ReloadRate=3.800000
     WeaponReloadAnim="Reload_IJC_spThompson_Drum"
     SleeveNum=0
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SteamPunk_Tommygun'
     MeshRef="KF_IJC_Summer_Weps1.Steampunk_Thompson"
     SkinRefs(1)="KF_IJC_Summer_Weapons.Steampunk_Thompson.Steampunk_Thompson_cmb"
     SelectSoundRef="KF_SP_ThompsonSnd.KFO_SP_Thompson_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Selected"
     AppID=210943
     FireModeClass(0)=Class'KFMod.SPThompsonFire'
     Description="Thy weapon is before you. May it's drum beat a sound of terrible fear into your enemies."
     Priority=123
     GroupOffset=19
     PickupClass=Class'KFMod.SPThompsonPickup'
     AttachmentClass=Class'KFMod.SPThompsonAttachment'
     ItemName="Dr. T's Lead Delivery System"
}
