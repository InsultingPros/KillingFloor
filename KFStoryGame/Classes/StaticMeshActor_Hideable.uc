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

var () bool      bNoCollisionWhileHidden;

simulated function PostBeginPlay()
{
    bInitialhidden = bHidden;
}


simulated function Trigger( actor Other, pawn EventInstigator )
{
    bHidden = !bHidden;
    if(bNoCollisionWhileHidden)
    {
        if(bHidden)
        {
            SetCollision(false,false);
            bBlockZeroExtentTraces = false;
            bBlockNonZeroExtentTraces = false;
        }
        else
        {
            SetCollision(default.bCollideActors,default.bBlockActors);
            bBlockZeroExtentTraces = default.bBlockZeroExtentTraces;
            bBlockNonZeroExtentTraces = default.bBlockNonZeroExtentTraces;
        }
    }
}

simulated function Reset()
{
    bHidden = bInitialhidden;
}

defaultproperties
{
     bNoCollisionWhileHidden=True
     bStatic=False
     bNoDelete=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
