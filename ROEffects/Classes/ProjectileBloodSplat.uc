//=============================================================================
// Wall projecting blood hit
//=============================================================================
class ProjectileBloodSplat extends Actor;

var Class<Actor>    BloodDecalClass;
var texture Splats[6];

simulated function PostNetBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		WallSplat();
	else
		LifeSpan = 0.2;
}

simulated function WallSplat()
{
	local vector WallHit, WallNormal;
	local Actor WallActor;

	if ( Level.bDropDetail || (BloodDecalClass == None) )
		return;

	WallActor = Trace(WallHit, WallNormal, Location + 350 * vector(Rotation), Location, false);
	if ( WallActor != None )
		spawn(BloodDecalClass,,,WallHit + 20 * (WallNormal + VRand()), rotator(-WallNormal));
}

static function PrecacheContent(LevelInfo Level)
{
	local int i;

	if ( Default.BloodDecalClass != None )
	{
		for ( i=0; i<6; i++ )
			Level.AddPrecacheMaterial(Default.splats[i]);
	}
}

defaultproperties
{
     BloodDecalClass=Class'ROEffects.ROBloodSplatter'
     Splats(0)=Texture'Effects_Tex.GoreDecals.Splatter_001'
     Splats(1)=Texture'Effects_Tex.GoreDecals.Splatter_002'
     Splats(2)=Texture'Effects_Tex.GoreDecals.Splatter_003'
     Splats(3)=Texture'Effects_Tex.GoreDecals.Splatter_004'
     Splats(4)=Texture'Effects_Tex.GoreDecals.Splatter_005'
     Splats(5)=Texture'Effects_Tex.GoreDecals.Splatter_006'
     LightEffect=LE_QuadraticNonIncidence
     DrawType=DT_Particle
     bAcceptsProjectors=False
     bNetTemporary=True
     bOnlyRelevantToOwner=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.500000
     bUnlit=True
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bNotOnDedServer=True
     bDirectional=True
}
