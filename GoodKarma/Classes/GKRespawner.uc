//GKRespawner as part of the GoodKarma package
//Build 3 Beta 4.5 Release
//By: Jonathan Zepp

class GKRespawner extends Actor
	placeable;

var() name respawnTag ;

var Actor respawnTarget ;
var class<Actor> GKActor ;

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    forEach AllActors(GKActor, respawnTarget, respawnTag)
        (NetKActor(respawnTarget)).respawn() ;
}

defaultproperties
{
     respawnTag="'"
     GKActor=Class'GoodKarma.NetKActor'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKRespawner'
     DrawScale=1.500000
}
