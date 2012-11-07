//=============================================================================
// AnimNotify_ShellEject
//=============================================================================
// Anim notify to do shell ejection for weapons with delayed shell ejects
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class AnimNotify_ShellEject extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	if(Owner.IsA('ROWeapon'))
	{
		ROWeapon(Owner).AnimNotifiedShellEject();
	}
	else if (Owner.IsA('ROWeaponAttachment'))
	{
		ROWeaponAttachment(Owner).SpawnShells(1);
	}
}

defaultproperties
{
}
