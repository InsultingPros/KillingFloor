//=============================================================================
// DECO_SpaceFighter
//=============================================================================

class KFDeco extends Decoration;

//#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx

function Landed(vector HitNormal);
function HitWall (vector HitNormal, actor Wall);
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, class<DamageType> damageType, optional int HitIndex);
singular function PhysicsVolumeChange( PhysicsVolume NewVolume );
function Trigger( actor Other, pawn EventInstigator );
singular function BaseChange();
function Bump( actor Other );


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'22Patch.ClotGibHead'
     RemoteRole=ROLE_None
     DrawScale=3.000000
     AmbientGlow=48
     bMovable=False
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
     bEdShouldSnap=True
}
