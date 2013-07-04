// A special type of volume which functions like a blocking volume, but blocks ONLY humans from entering

class BlockingVolume_Toggleable extends BlockingVolume;

function Reset()
{
	SetCollision(default.bCollideActors);
}

simulated	function Trigger( actor Other, pawn EventInstigator )
{
	SetCollision(!bCollideActors);
}

defaultproperties
{
     bClassBlocker=True
     BlockedClasses(0)=Class'KFMod.KFHumanPawn'
     bStatic=False
}
