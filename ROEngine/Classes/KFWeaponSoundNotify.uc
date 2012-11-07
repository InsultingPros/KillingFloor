//===================================================================
// KFWeaponSoundNotify
// Copyright (C) 2009 John "Ramm-Jaeger"  Gibson
//
// Custom sound notify for playing anim notified sounds for weapons
//===================================================================

class KFWeaponSoundNotify extends CustomSoundNotify;

simulated event Notify( Actor Owner )
{
	if ( Owner.Level.NetMode != NM_DedicatedServer && Weapon(Owner) != none  && Weapon(Owner).Instigator != none )
	{
	  	Weapon(Owner).Instigator.PlaySound(Sound,,Volume,false,Radius,,bAttenuate);
	}
}

defaultproperties
{
}
