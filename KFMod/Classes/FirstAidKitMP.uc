//====================================================================
//  First Aid Kit Multiplay Version
//====================================================================

class FirstAidKitMP extends MiniHealthPack;

var() localized string  Message;

static function string GetLocalString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    return Default.PickupMessage;
}


//function ResetInjuries()
//{

//Other.GroundSpeed = 210;
//}

function RespawnEffect()
{
// Get rid of the Yellow puff. It's not welcome here.
}

auto state Pickup
{
    function Touch( actor Other )
    {
        local Pawn P;
        local PlayerController PC;

        P = Pawn(Other);
        PC = PlayerController(P.Controller);

           if (Pawn(Other).Health > (Pawn(Other).HealthMax * 0.75 ))
            {
                if ( P != None )
                {
                Message="Your Health must be below 75% to pick this up";
                PC.ClientMessage(Message, 'KFCriticalEvent');
                }
            }


        if ( ValidTouch(Other) && Pawn(Other).Health <= (Pawn(Other).HealthMax * 0.75 ) )
        {

            if ( P.GiveHealth(HealingAmount, GetHealMax(P)) || (bSuperHeal && !Level.Game.bTeamGame) )
            {
                AnnouncePickup(P);
                SetRespawn();
            }
        }
    }
}


function AnnouncePickup( Pawn Receiver )
{
    Receiver.HandlePickup(self);
    PlaySound( PickupSound,SLOT_Interact,2*100,,100 );
}

defaultproperties
{
     HealingAmount=50
     bSuperHeal=False
     RespawnTime=300.000000
     PickupMessage="You used a First Aid Kit"
     PickupSound=Sound'KF_InventorySnd.Medkit_Pickup'
     StaticMesh=StaticMesh'KillingFloorStatics.FirstAidKit'
     DrawScale=1.000000
     AmbientGlow=40
     ScaleGlow=0.000000
     CollisionRadius=35.000000
     CollisionHeight=20.000000
     RotationRate=(Yaw=0)
}
