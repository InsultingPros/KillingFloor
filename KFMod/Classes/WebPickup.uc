class WebPickup extends Pickup
	notplaceable;

var() int WhichOne;

function Touch(Actor Other)
{
	if ( WhichOne < 100000 && KFPawn(Other) != none )
	{
		//KFPawn(Other).ClientDoIt(WhichOne);
	}
}

auto state Pickup
{
	function Touch(Actor Other)
	{
		if ( WhichOne < 100000 && KFPawn(Other) != none )
		{
			//KFPawn(Other).ClientDoIt(WhichOne);
		}
	}
}

event UsedBy(Pawn User)
{
	if ( KFPawn(User) != none )
	{
		//KFPawn(User).ClientDoIt(WhichOne);
	}
}

defaultproperties
{
     InventoryType=Class'UnrealGame.KeyInventory'
     RespawnTime=9999.000000
     PickupMessage="You picked up a Key."
     DrawType=DT_StaticMesh
     Physics=PHYS_Falling
     DrawScale=0.100000
     CollisionRadius=20.000000
     CollisionHeight=5.000000
}
