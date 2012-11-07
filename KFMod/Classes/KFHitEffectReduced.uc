class KFHitEffectReduced extends KFHitEffect;

simulated function SpawnEffects()
{
	local Material SurfaceMat;
	local int HitSurface;
	local Vector HitLocation, HitNormal,TDir;
	local rotator EffectDir;
	local Actor Other;

	if( Instigator==None )
		Return;
	TDir = Normal(Location-Instigator.Location);
	Other = Instigator.Trace(HitLocation, HitNormal, Location+TDir*32, Location-TDir*16,true,,SurfaceMat);

	if( Other==none || BlockingVolume(Other)!=None )
		return;

	EffectDir = rotator(HitNormal);

	if(Vehicle(Other) != None && Other.SurfaceType == 0)
		HitSurface = 3;
	else if(Other != None && Other!=Level && Other.SurfaceType != 0)
		HitSurface = Other.SurfaceType;
	else if(SurfaceMat != None)
		HitSurface = SurfaceMat.SurfaceType;
	else return;

	if( Other.IsA('KFMonster') || Other.IsA('ExtendedZCollision') )
		HitSurface = 6;

	if(fRand() >= 0.65)
	{
            if(PhysicsVolume.bWaterVolume)
    			Spawn(class'WaterSplashEmitter');
      	else Spawn(HitEffectClasses[HitSurface],,,, EffectDir);
		if(Other != None && Other.bWorldGeometry && DecalClasses[HitSurface] != None)
    			Spawn(DecalClasses[HitSurface]);
	}
}

defaultproperties
{
}
