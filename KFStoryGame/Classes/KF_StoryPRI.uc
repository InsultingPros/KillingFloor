/*
	--------------------------------------------------------------
	KF_StoryPRI
	--------------------------------------------------------------

    Custom Player ReplicationInfo class for Objective Mode

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_StoryPRI extends KFPlayerReplicationInfo;

/* Struct that contains information for rendering a hovering icon
overtop of a player which is not relevant to clients */

struct SPlayerIconData
{
    var Material    IconMat;          // Icon to render over top of the pawn's head.
    var Vector      CurrentPawnLoc;   // current location of the player pawn.
    var Vector      LastPawnLoc;
};

var private vector InterpolatedPawnLoc;

var private SPlayerIconData FloatingIconData;

/* Reference to the pawn this PRI belongs to */
var private KFHumanPawn_Story            OwnerPawn;

var float LastIconUpdateTime;

replication
{
    unreliable if(Role == Role_Authority && bNetDirty)
        FloatingIconData,OwnerPawn;

}

function SetReplicatedPawnLoc(vector NewLoc)
{
    if(Level.TimeSeconds - LastIconUpdateTime > NetUpdateFrequency)
    {
        LastIconUpdateTime = Level.TimeSeconds;
        FloatingIconData.LastPawnLoc = FloatingIconData.CurrentPawnLoc;
    }

    if(NewLoc != FloatingIconData.CurrentPawnLoc)
    {
        FloatingIconData.CurrentPawnLoc = NewLoc;
    }
}

function SetOwnerPawn(KFHumanPawn_Story NewOwnerPawn)
{
    OwnerPawn = NewOwnerPawn;
}

function SetFloatingIconMat(material NewMat)
{
    FloatingIconData.IconMat = NewMat;
}

/* Returns the current position of the pawn this PRI belongs to (or as close as we can get) */
simulated function Vector GetCurrentPawnLoc()
{
    return FloatingIconData.CurrentPawnLoc;
}

simulated function Vector GetlastPawnLoc()
{
    return FloatingIconData.LastPawnLoc;
}


simulated function Vector GetInterpolatedPawnLoc()
{
    return InterpolatedPawnLoc;
}

/* Set on the client only */
simulated function SetInterpolatedPawnLoc(vector NewValue)
{
    InterpolatedPawnLoc = NewValue;
}


/* Returns the Icon to render overtop of our pawn's head (if one is set) */
simulated function Material GetFloatingIconMat()
{
    return FloatingIconData.IconMat;
}

simulated function KFHumanPawn_Story GetOwnerPawn()
{
    return OwnerPawn;
}

defaultproperties
{
}
