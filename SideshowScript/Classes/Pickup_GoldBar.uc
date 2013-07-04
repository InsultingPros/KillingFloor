/*
	--------------------------------------------------------------
	Pickup_GoldBar
	--------------------------------------------------------------

    Pickup Class for the gold bar inventory item in the summer
    sideshow map.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Pickup_GoldBar extends KF_StoryInventoryPickup;

auto state Pickup
{
	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
        if(IsTouchingDropVolume())
        {
            return false;
        }

        return Super.ValidTouch(Other);
	}
}

function bool IsTouchingDropVolume()
{
    local Volume V;

    /* Haxxor to the Maxxor */
    Foreach TouchingActors(class 'Volume', V)
    {
        if(V.IsA('KF_DropInventoryVolume'))
        {
            return true;    // no picking me back up if I'm placed in this volume!
        }
    }

    return false;
}

state FallingPickup
{
    event Landed(Vector HitNormal)
    {
        Super.Landed(HitNormal);

        if(IsTouchingDropVolume())
        {
            BroadCastPickupEvent(Instigator,3);
        }
    }
}


function InitDroppedPickupFor(Inventory Inv)
{
    Super.InitDroppedPickupFor(Inv);
    bAlwaysRelevant = true;
}

defaultproperties
{
     MaxHeldCopies=1
     CarriedMaterial=Texture'Pier_T.Icons.Goldbar_Icon_64'
     MovementSpeedModifier=0.650000
     AIThreatModifier=1.500000
     InventoryType=Class'SideShowScript.Inv_GoldBar'
     LightType=LT_Steady
     LightHue=45
     LightSaturation=150
     LightBrightness=200.000000
     LightRadius=3.000000
     StaticMesh=StaticMesh'Pier_SM.Env_Pier_Gold_Bars'
     bUseDynamicLights=True
     CollisionRadius=40.000000
     MessageClass=Class'SideShowScript.Msg_GoldBarNotification'
}
