/*
	--------------------------------------------------------------
	StaticMeshActor_Hideable
	--------------------------------------------------------------

    StaticMeshActor which can be toggled on / off

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class StaticMeshActor_Hideable extends StaticMeshActor;

var bool         bInitialHidden;

simulated function PostBeginPlay()
{
    bInitialhidden = bHidden;
}


simulated function Trigger( actor Other, pawn EventInstigator )
{
    bHidden = !bHidden;
}

simulated function Reset()
{
    bHidden = bInitialhidden;
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
