class ACTION_AddInventory extends ScriptedAction;

var() name InvTag;
var() class<Inventory> InventoryType;

function bool InitActionFor(ScriptedController C)
{
    local Inventory NewInv;
    local Pawn P;
    local class<Pickup> PickupClass;
    local PlayerController PC;

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

	PickupClass = InventoryType.default.PickupClass;
	PC = PlayerController(P.Controller);

	if( PickupClass != none && PC != none )
	{
	    PC.ReceiveLocalizedMessage(PickupClass.default.MessageClass,1,PC.PlayerReplicationInfo,,PickupClass);
	    P.PlaySound( PickupClass.default.PickupSound, SLOT_Interact );
	}

	return false;
}

defaultproperties
{
     ActionString="Add Inventory"
}
