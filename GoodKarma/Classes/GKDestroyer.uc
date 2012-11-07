//GKDestroyer as part of the GoodKarma package
//Build 1 Beta 4.5 Release
//By: Jonathan Zepp

class GKDestroyer extends Actor
	placeable;

var() name destroyTag ;
var() bool bInstaKill ;
var() int damage ;

var Actor destroyTarget ;
var class<Actor> GKActor ;
var class<damageType> killDamType ;

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    if(!bInstaKill)
    {
        forEach AllActors(GKActor, destroyTarget, destroyTag)
            (NetKActor(destroyTarget)).takeDamage(damage, none, destroyTarget.location, vect(0,0,0), killDamType) ;
    }
    else
    {
        forEach AllActors(GKActor, destroyTarget, destroyTag)
            (NetKActor(destroyTarget)).die() ;
    }
}

defaultproperties
{
     DestroyTag="'"
     Damage=30
     GKActor=Class'GoodKarma.NetKActor'
     killDamType=Class'GoodKarma.DamTypeKick'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKDestroyer'
     DrawScale=1.500000
}
