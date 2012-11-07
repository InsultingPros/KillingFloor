class KFHitEffect extends Actor;

#exec OBJ LOAD FILE=KFMaterials.utx
#exec OBJ LOAD FILE=VMParticleTextures.utx
#exec OBJ LOAD FILE=VehicleFX.utx
#exec OBJ LOAD FILE=XGameShadersB.utx
#exec OBJ LOAD FILE=EmitterTextures.utx

var() class <KFHitEmitter> HitEffectClasses[11]; //Effects indexed by surface type.
var() class <KFBulletDecal> DecalClasses[11];

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'KFMaterials.pock0_t');
	L.AddPrecacheMaterial(Texture'KFMaterials.pock2_t');
	L.AddPrecacheMaterial(Texture'KFMaterials.pock4_t');
	L.AddPrecacheMaterial(Texture'KFMaterials.GlassMark1');
	L.AddPrecacheMaterial(Texture'KFMaterials.GlassMark2');
	L.AddPrecacheMaterial(Texture'KFMaterials.GlassMark3');
	L.AddPrecacheMaterial(Texture'KFMaterials.MetalMark1');
	L.AddPrecacheMaterial(Texture'KFMaterials.MetalMark2');
	L.AddPrecacheMaterial(Texture'KFMaterials.MetalMark3');
	L.AddPrecacheMaterial(Texture'KFMaterials.SnowMark1');
	L.AddPrecacheMaterial(Texture'KFMaterials.SnowMark2');
	L.AddPrecacheMaterial(Texture'KFMaterials.SnowMark3');
	L.AddPrecacheMaterial(Texture'KFMaterials.WoodMark1');
	L.AddPrecacheMaterial(Texture'KFMaterials.WoodMark2');
	L.AddPrecacheMaterial(Texture'KFMaterials.WoodMark3');

	L.AddPrecacheMaterial(Texture'KFMaterials.GlassChips');
	L.AddPrecacheMaterial(Texture'KFMaterials.WoodChips');
	L.AddPrecacheMaterial(Texture'KFMaterials.PlantBits');
	//L.AddPrecacheMaterial(Texture'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
	//L.AddPrecacheMaterial(Texture'VMParticleTextures.DirtKICKGROUP.snowKICKTEX');
	//L.AddPrecacheMaterial(Texture'VehicleFX.Particles.DustyCloud2');
	//L.AddPrecacheMaterial(Texture'XGameShadersB.Blood.BloodJetc');
	//L.AddPrecacheMaterial(Texture'AW-2004Particles.Energy.SparkHead');
	//L.AddPrecacheMaterial(Texture'XEffects.EmitSmoke_t');
	//L.AddPrecacheMaterial(Texture'EmitterTextures.MultiFrame.rockchunks02');
	//L.AddPrecacheMaterial(Texture'EmitterTextures.MultiFrame.MistTexture');
}

simulated function PostNetBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		SpawnEffects();
}

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

	if( Other.IsA('KFMonster') || Other.IsA('ExtendedZCollision') )
		HitSurface = 6;

	if(PhysicsVolume.bWaterVolume)
		Spawn(class'WaterSplashEmitter');
	else
		Spawn(HitEffectClasses[HitSurface],,,, EffectDir);

	// Don't need to try and spawn decalclasses if we have no decalclasses to spawn
	if(DecalClasses[HitSurface] != None)
		Spawn(DecalClasses[HitSurface]);
}

defaultproperties
{
     HitEffectClasses(0)=Class'KFMod.DirtHitEmitter'
     HitEffectClasses(1)=Class'KFMod.RockHitEmitter'
     HitEffectClasses(2)=Class'KFMod.DirtHitEmitter'
     HitEffectClasses(3)=Class'KFMod.MetalHitEmitter'
     HitEffectClasses(4)=Class'KFMod.WoodHitEmitter'
     HitEffectClasses(5)=Class'KFMod.PlantHitEmitter'
     HitEffectClasses(6)=Class'KFMod.FleshHitEmitter'
     HitEffectClasses(7)=Class'KFMod.SnowHitEmitter'
     HitEffectClasses(8)=Class'KFMod.SnowHitEmitter'
     HitEffectClasses(9)=Class'KFMod.WaterHitEmitter'
     HitEffectClasses(10)=Class'KFMod.GlassHitEmitter'
     DecalClasses(0)=Class'KFMod.DefaultBulletDecal'
     DecalClasses(1)=Class'KFMod.DefaultBulletDecal'
     DecalClasses(2)=Class'KFMod.SnowBulletDecal'
     DecalClasses(3)=Class'KFMod.MetalBulletDecal'
     DecalClasses(4)=Class'KFMod.WoodBulletDecal'
     DecalClasses(6)=Class'KFMod.WoodBulletDecal'
     DecalClasses(7)=Class'KFMod.GlassBulletDecal'
     DecalClasses(8)=Class'KFMod.SnowBulletDecal'
     DecalClasses(10)=Class'KFMod.GlassBulletDecal'
     DrawType=DT_None
     bNetTemporary=True
     bReplicateInstigator=True
     LifeSpan=1.000000
}
