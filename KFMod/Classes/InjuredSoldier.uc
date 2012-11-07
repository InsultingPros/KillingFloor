// Gavin, Injured soldier in KFS-01
class InjuredSoldier extends Decoration;

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Idle');
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'KFMapObjects.SoldierInjured'
}
