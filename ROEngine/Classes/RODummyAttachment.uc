//=============================================================================
// RODummyAttachment
//=============================================================================
// Player attachments that serve no function other than visual
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class RODummyAttachment extends Actor
	abstract;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	local Pawn P;

	P = Pawn(Owner);

	if (P == None)
		Destroy();

	P.AttachToBone(self, AttachmentBone);
}

//-----------------------------------------------------------------------------
// StaticPrecache
//-----------------------------------------------------------------------------

static function StaticPrecache(LevelInfo L)
{
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_Mesh
     bOnlyDrawIfAttached=True
     RemoteRole=ROLE_None
     bUseLightingFromBase=True
}
