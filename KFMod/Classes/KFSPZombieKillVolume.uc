// Kill all zombies within this volume (clean up map mid-game).
class KFSPZombieKillVolume extends Volume;

function Trigger( actor Other, pawn EventInstigator )
{
	local KFMonster K;

	ForEach TouchingActors(Class'KFMonster',K)
		K.Destroy();
}

defaultproperties
{
}
