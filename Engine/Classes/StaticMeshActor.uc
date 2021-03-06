//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	placeable;

var() bool bExactProjectileCollision;		// nonzero extent projectiles should shrink to zero when hitting this actor

/* This interface was added for the roulette minigame in the summer sideshow map.
Implemented in KF_Roulette_Bet_Zone */
function OnActorLanded(Actor FallingActor){}

defaultproperties
{
     bExactProjectileCollision=True
     DrawType=DT_StaticMesh
     bUseDynamicLights=True
     bStatic=True
     bWorldGeometry=True
     bShadowCast=True
     bStaticLighting=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
     bEdShouldSnap=True
}
