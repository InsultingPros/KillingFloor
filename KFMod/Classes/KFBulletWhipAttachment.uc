//=============================================================================
// KFBulletWhipAttachment
//=============================================================================
// An additional collision cylinder for detecting precision hit traces or
// projectiles as well as detecting bullets passing by which allows for the
// creation of bullet whip sound effects.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive
// Author - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFBulletWhipAttachment extends ROBulletWhipAttachment;

defaultproperties
{
     RemoteRole=ROLE_None
     CollisionRadius=60.000000
     CollisionHeight=80.000000
}
