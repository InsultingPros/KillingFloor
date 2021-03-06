class ACTION_DropInventory extends ScriptedAction;

var() class<Inventory> InventoryType;
var() name InvTag;
var() bool bSpawnPickup;
var() bool bAlwaysDropFromInstigator;  // Should we always drop the pickup from the guy who instigates this action, or do we not care?

/* C.GetInstigator() is unreliable in this case, because a different player than the one who's inventory Item we
need to remove could be instigating the trigger*/

function Pawn GetInvHolder( ScriptedController OwningController, out Inventory ItemToRemove)
{
    local Controller C;

    if(bAlwaysDropFromInstigator && OwningController.GetInstigator() != none)
    {
        ItemToRemove = OwningController.GetInstigator().FindInventoryType(InventoryType);

        if(ItemToRemove != none &&
        (InvTag == '' || ItemToRemove.Tag == InvTag))
        {
            return OwningController.GetInstigator();
        }
    }
    else
    {
        for ( C=OwningController.Level.ControllerList; C!=None; C=C.NextController )
        {
            if(C.Pawn != none && C.Pawn.bCanPickupInventory)
            {
                ItemToRemove = C.Pawn.FindInventoryType(InventoryType) ;

                if(ItemToRemove != none &&
                (InvTag == '' || ItemToRemove.Tag == InvTag))
                {
                    return C.Pawn;
                }
            }
        }
    }

    return none;
}

function bool InitActionFor(ScriptedController C)
{
    local Inventory DelInv;
    local Pawn P;
    local PlayerController PC, OPC;
    local class<Pickup> PickupClass;
    local bool bSwitchWeapons;
    local Controller CLC;

    P = GetInvHolder(C,DelInv);
    if( P == none || DelInv == none)
    {
        return false;
    }

    bSwitchWeapons = (DelInv == P.Weapon);

    if( bSpawnPickup )
    {
        DelInv.Velocity = Vector( P.Rotation ) * 250.f ;
        DelInv.DropFrom( P.Location );
    }
    else
    {
	    if ( KFHumanPawn_Story( P ) != none)
		{
			KFHumanPawn_Story( P ).SetHasStoryItem( false );
		}

        if(KF_StoryInventoryItem(DelInv) != none)
        {
            KF_StoryInventoryItem(DelInv).UpdateHeldMaterial(P,none);
        }

        DelInv.DetachFromPawn(P);
        P.DeleteInventory( DelInv );
        DelInv.Destroy();
    }

    // JDR: TODO - re-add DeleteAmmo to Weapon and KFWeapon
    //if( Weapon(DelInv) != none )
    //{
    //    Weapon( DelInv ).DeleteAmmo();
    //}

    OPC = PlayerController(P.Controller);
    if( OPC != none && bSwitchWeapons )
    {
        OPC.ClientSwitchToBestWeapon();
    }

    PickupClass = InventoryType.default.PickupClass;
    if( PickupClass != none )
    {
        for( CLC = P.Level.ControllerList; CLC != None; CLC = CLC.NextController )
    	{
            PC = PlayerController(CLC);
            if(PC != none)
            {
                // JDR: there is no unified way to retrieve a "dropped" message currently,
                // so this only displays the correct message for the gold bar for now,
                // which is all we're using this for, for now...
                PC.ReceiveLocalizedMessage(PickupClass.default.MessageClass,3,OPC.PlayerReplicationInfo);
            }
    	}
    }

	return false;
}

defaultproperties
{
     ActionString="Delete Inventory"
}
