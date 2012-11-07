//=============================================================================
// RODestroyableSMDestroyedMsg
//=============================================================================
// This is a localized message class used to send critical messages
// when a DestroyableStaticMesh is destroyed. Messages can go to
// the team of whoever destroyed it, the enemy team, both teams or only to the
// player who did the destruction.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class RODestroyableSMDestroyedMsg extends ROCriticalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if (RODestroyableStaticMeshBase(OptionalObject) == none)
	{
	    warn("RODestroyableSMDestroyedMsg message received with no associated RODestroyableStaticMeshBase!");
	    return("");
	}
	else
	{
	    return RODestroyableStaticMeshBase(OptionalObject).OnDestroyCriticalMessage;
	}
}

defaultproperties
{
     iconID=3
}
