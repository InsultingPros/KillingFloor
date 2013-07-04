//=============================================================================
// SPGrenadeLauncher
//=============================================================================
// Steam Punk bomb thrower class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPGrenadeLauncher extends M79GrenadeLauncher;

defaultproperties
{
     SleeveNum=0
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_Grenade'
     MeshRef="KF_IJC_Summer_Weps1.Grenade"
     SkinRefs(1)="KF_IJC_Summer_Weapons.Grenade.Grenade_cmb"
     SelectSoundRef="KF_SP_OrcaSnd.KFO_Orca_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.Grenade_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.Grenade"
     AppID=210943
     FireModeClass(0)=Class'KFMod.SPGrenadeFire'
     Description="The Orca Bomb Propeller tosses little delayed explosive bombs. Good for those bank shots!"
     Priority=164
     GroupOffset=17
     PickupClass=Class'KFMod.SPGrenadePickup'
     PlayerViewOffset=(Y=22.000000,Z=-7.000000)
     AttachmentClass=Class'KFMod.SPGrenadeAttachment'
     ItemName="The Orca Bomb Propeller"
}
