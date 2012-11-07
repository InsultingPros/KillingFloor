//===================================================================
// ROPawnSoundNotify
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Custom sound notify for playing anim notified sounds from pawns
//===================================================================

class ROPawnSoundNotify extends CustomSoundNotify;

event Notify( Actor Owner )
{
	if ( Owner.Level.NetMode != NM_DedicatedServer && Pawn(Owner) != none  && !Pawn(Owner).IsFirstPerson())
	{
	  	Owner.PlaySound(Sound,,Volume,false,Radius,,bAttenuate);
	}
}

defaultproperties
{
     bAttenuate=True
}
