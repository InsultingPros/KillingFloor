//GK_AS_RoundReset as part of the GoodKarma package
//Build 1 Beta 4.5 Release
//By: Jonathan Zepp

class GK_AS_RoundReset extends Actor
	placeable;

var Actor respawnTarget ;
var class<Actor> GKActor ;

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    forEach AllActors(GKActor, respawnTarget)
        (NetKActor(respawnTarget)).respawn() ;
}

defaultproperties
{
     GKActor=Class'GoodKarma.NetKActor'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKASRespawner'
     DrawScale=1.500000
}
