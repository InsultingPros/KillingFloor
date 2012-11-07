//====================================================================
//  First Aid Kit//
//====================================================================

class FirstAidKit extends MiniHealthPack;

var() localized string  Message;

var     byte    EquipmentCategoryID;
var 	int 	ItemCost;

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
        if(P!=none)
        {
          PC = PlayerController(P.Controller);


          if ( ValidTouch(Other) && (P.Health < P.HealthMax)&&
            KFHumanPawn(P).HealthToGive == 0 )
          {
            // Make sure he's wounded, and not already being affected by a kit.

            if ( P.GiveHealth(HealingAmount, GetHealMax(P)) || (bSuperHeal && !Level.Game.bTeamGame) )
            {
                AnnouncePickup(P);
                SetRespawn();
            }
          }
          else
            if (P.Health >= P.HealthMax && PlayerController(P.Controller)!=none)
              PlayerController(P.Controller).ClientMessage("You are already at full health.", 'KFCriticalEvent');
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
     EquipmentCategoryID=4
     ItemCost=150
     HealingAmount=50
     bSuperHeal=False
     bOnlyReplicateHidden=False
     RespawnTime=60.000000
     PickupMessage="You used a First Aid Kit"
     PickupSound=Sound'KF_InventorySnd.Medkit_Pickup'
     StaticMesh=StaticMesh'KillingFloorStatics.FirstAidKit'
     Physics=PHYS_Falling
     DrawScale=1.000000
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     ScaleGlow=0.000000
     CollisionRadius=28.000000
     CollisionHeight=20.000000
     RotationRate=(Yaw=0)
}
