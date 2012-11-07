class NoKarmaMut extends Mutator;

simulated function PostBeginPlay()
{
	local KActor K;

	ForEach DynamicActors(Class'KActor',K)
	{
		K.Destroy();
		if( K==None )
			Continue;
		K.SetPhysics(PHYS_None);
		K.SetCollision(False);
		K.bHidden = True;
		K.bScriptInitialized = true;
		K.Disable('Tick');
		K.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
     GroupName="KF-NoKarma"
     FriendlyName="No Karma Decorations"
     Description="Remove all those buggy karma decorations from the maps."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
