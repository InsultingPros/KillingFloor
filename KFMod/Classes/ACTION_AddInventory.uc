class ACTION_AddInventory extends ScriptedAction;

var() name InvTag;
var() class<Inventory> InventoryType;

function bool InitActionFor(ScriptedController C)
{
    local Inventory NewInv;
    local Pawn P;
    local class<Pickup> PickupClass;
    local PlayerController PC, OPC;
    local Controller CLC;

    if( InventoryType == none )
    {
        return false;
    }

    P = C.GetInstigator();
    if( P == none || P.FindInventoryType(InventoryType) != none )
    {
        return true; // stop right there!
    }

	NewInv = C.Spawn(InventoryType,P,InvTag,P.Location);
	if( NewInv == none )
	{
	    return false;
	}

	NewInv.GiveTo( P );

	OPC = PlayerController( P.Controller );

	PickupClass = InventoryType.default.PickupClass;
	if( PickupClass != none )
	{
	    P.PlaySound( PickupClass.default.PickupSound, SLOT_Interact );
    	for( CLC = P.Level.ControllerList; CLC != None; CLC = CLC.NextController )
    	{
            PC = PlayerController(CLC);
            if(PC != none)
            {
                PC.ReceiveLocalizedMessage(PickupClass.default.MessageClass,1,OPC.PlayerReplicationInfo);
            }
    	}
    }

	return false;
}

defaultproperties
{
     ActionString="Add Inventory"
}
