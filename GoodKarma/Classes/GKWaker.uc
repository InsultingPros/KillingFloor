//GKWaker as part of the GoodKarma package
//Build 1 Beta 4.5 Release
//By: Jonathan Zepp

class GKWaker extends Actor
	placeable;

var() name wakeTag ;

var Actor wakeTarget ;
var class<Actor> GKActor ;

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    forEach AllActors(GKActor, wakeTarget, wakeTag)
        (NetKActor(wakeTarget)).KWake() ;
}

defaultproperties
{
     wakeTag="'"
     GKActor=Class'GoodKarma.NetKActor'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKWaker'
     DrawScale=1.500000
}
