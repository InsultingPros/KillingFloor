// Allow only some specific zombies use this path.
class ZombiePathNode extends PathNode;

var() array< Class<KFMonster> > AllowedZombies,DisallowedZombies;

event int SpecialCost(Pawn Seeker, ReachSpec Path)
{
	local int l,i;

	if( Class<KFMonster>(Seeker.Class)==None )
		return 0;
	l = DisallowedZombies.Length;
	for( i=0; i<l; i++ )
		if( ClassIsChildOf(Seeker.Class,DisallowedZombies[i]) )
			return 9999999;
	l = AllowedZombies.Length;
	if( l==0 )
		return 0;
	for( i=0; i<l; i++ )
		if( ClassIsChildOf(Seeker.Class,AllowedZombies[i]) )
			return 0;
	return 9999999;
}

defaultproperties
{
     bSpecialForced=True
     Texture=Texture'Engine.S_Alarm'
}
