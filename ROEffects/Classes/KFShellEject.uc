class KFShellEject extends Emitter;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
}

defaultproperties
{
     bNoDelete=False
     bUnlit=False
     bHardAttach=True
}
