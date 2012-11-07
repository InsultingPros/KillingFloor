class KFKeyInventory extends Inventory;
  
var KFKeyPickup MyPickup;

function UnLock();

function Destroyed()
{
	if( MyPickup!=None )
		MyPickup.GotoState('Pickup');
	Super.Destroyed();
}

defaultproperties
{
}
