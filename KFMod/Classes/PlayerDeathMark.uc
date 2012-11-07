Class PlayerDeathMark extends Info;

function PostBeginPlay()
{
	local KFGameType K;
	local int i;

	K = KFGameType(Level.Game);
	if( K==None )
	{
		Destroy();
		Return;
	}
	i = K.DeathMarkers.Length;
	K.DeathMarkers.Length = i+1;
	K.DeathMarkers[i] = Self;
}
function Destroyed()
{
	local KFGameType K;
	local int i;

	K = KFGameType(Level.Game);
	if( K==None )
		Return;
	for( i=0; i<K.DeathMarkers.Length; i++ )
	{
		if( K.DeathMarkers[i]==None || K.DeathMarkers[i]==Self )
		{
			K.DeathMarkers.Remove(i,1);
			i--;
		}
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     LifeSpan=14.000000
     bCollideWhenPlacing=True
     CollisionRadius=26.000000
     CollisionHeight=40.000000
     bCollideActors=True
     bCollideWorld=True
}
