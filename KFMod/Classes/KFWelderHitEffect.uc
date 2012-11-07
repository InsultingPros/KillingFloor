class KFWelderHitEffect extends KFHitEffect;

simulated function SpawnEffects()
{
	local Vector HitLocation, HitNormal,TDir;
	local Actor Other;

	if( Instigator==None )
	{
		Spawn(HitEffectClasses[0],,,,RotRand(True));
		Return;
	}
	TDir = Normal(Location-Instigator.Location);
	Other = Instigator.Trace(HitLocation, HitNormal, Location+TDir*32, Location-TDir*10,true);

	if( Other==none )
	{
		Spawn(HitEffectClasses[0],,,,RotRand(True));
		return;
	}
	Spawn(HitEffectClasses[0],,,HitLocation+HitNormal*4, rotator(HitNormal));
}

defaultproperties
{
     HitEffectClasses(0)=Class'KFMod.WelderHitEmitter'
     RemoteRole=ROLE_SimulatedProxy
}
