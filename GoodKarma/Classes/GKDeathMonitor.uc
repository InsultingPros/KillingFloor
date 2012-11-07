//GKDeathMonitor as part of the GoodKarma package
//Build 4 Beta 4.5 Release
//By: Jonathan Zepp

class GKDeathMonitor extends Actor
	placeable;

var() name GoodKarmaActorTag ;
var() byte mode ;                                //1 for triggers all the time when dead, 0 for triggers once when it first dies

var Actor deathMonitor, temp ;
var class<Actor> GKActor ;
var class<damageType> killDamType ;
var bool wasDead ;

function tick(float DeltaTime)
{
    if(deathMonitor != none)
    {
        if((NetKActor(deathMonitor)).bDead)
        {
            if(mode == 0 && !wasDead)
                TriggerEvent(Event, none, none) ;
            else if(mode ==1)
                TriggerEvent(Event, none, none) ;
            wasDead = true ;
        }
        else
            wasDead = false ;
    }
}

function PostBeginPlay()
{
        forEach AllActors(GKActor, temp, GoodKarmaActorTag)
            deathMonitor = temp ;
}

defaultproperties
{
     GKActor=Class'GoodKarma.NetKActor'
     bHidden=True
     Texture=Texture'GKTextures.ActorSprites.GKDeathMonitor'
     DrawScale=1.500000
}
