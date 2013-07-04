/*
	--------------------------------------------------------------
	 KF_StoryNPC_Static
	--------------------------------------------------------------

	StaticMesh NPC that can take damage.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryNPC_Static extends KF_StoryNPC;

var             bool                bCheckPointed;

var             float               SavedHealth;


simulated function PostBeginPlay()
{
    Super.PostbeginPlay();

    if(!bUseHitPoints)
    {
        Hitpoints.length = 0;
    }
}

function ResurrectNPC(){}


function SaveHealthState()
{
    bCheckPointed = true;
    SavedHealth = Health;
}


function Reset()
{
    Super.Reset();
    if(bCheckPointed)
    {
        Health      = SavedHealth;
    }
}

event EncroachedBy( actor Other ){}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Controller PC;

	SpawnGibs(rotation, 1);


    /* Necessary because this pawn never dies .. we dont want AI Controllers getting stuck in infinite loops trying to attack it */
	for ( PC=Level.ControllerList; PC!=None; PC=PC.NextController )
	{
         if(PC.Enemy == self)
         {
            PC.Enemy = none;
         }
	}

    if(bIndestructible)
    {
        return;
    }

    BaseAIThreatRating = -1.f;
}

// Don't spawn any inventory for a static NPC
function AddDefaultInventory(){}

defaultproperties
{
     bIndestructible=True
     bUseDefaultPhysics=True
     bUseHitPoints=False
     bCanBeHealed=False
     bPlayerShadows=False
     bCanJump=False
     bCanPickupInventory=False
     ControllerClass=Class'Engine.AIController'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Waterworks_SM.pipe01_03'
     bActorShadows=False
     NetUpdateFrequency=5.000000
     bShadowCast=True
     bStaticLighting=True
     bMovable=False
     bUseCylinderCollision=False
     bPathColliding=True
}
