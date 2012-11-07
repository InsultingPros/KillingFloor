// A special type of volume which functions like a blocking volume, but blocks ONLY humans from entering

class KFZombieZoneVolume extends BlockingVolume;

function Trigger( actor Other, pawn EventInstigator )
{
	SetCollision(!bCollideActors);
}

defaultproperties
{
     bClassBlocker=True
     BlockedClasses(0)=Class'KFMod.KFHumanPawn'
     bStatic=False
}
