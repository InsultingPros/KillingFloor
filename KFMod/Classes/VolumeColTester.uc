Class VolumeColTester extends Info
	Transient
	NotPlaceable;

function bool IsInVolume( Volume V )
{
	local Volume Vo;

	foreach TouchingActors(Class'Volume',Vo)
		if( Vo==V )
			return true;
	return false;
}
function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;

	return false;
}

defaultproperties
{
     CollisionRadius=26.000000
     CollisionHeight=44.000000
     bCollideActors=True
     bCollideWorld=True
}
