//GKShover as part of the GoodKarma package
//Build 1 Beta 4.5 Release
//By: Jonathan Zepp

class GKShover extends Actor
	placeable;

var() name shoveTag ;
var() class<damageType> shoveDamType ;

var Actor shoveTarget ;
var class<Actor> GKActor ;

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    forEach AllActors(GKActor, shoveTarget, shoveTag)
        (NetKActor(shoveTarget)).takeDamage(0, none, shoveTarget.location, vector(rotation), shoveDamType) ;
}

defaultproperties
{
     shoveTag="'"
     shoveDamType=Class'GoodKarma.DamTypeKick'
     GKActor=Class'GoodKarma.NetKActor'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKPusher'
     DrawScale=1.500000
     bDirectional=True
}
