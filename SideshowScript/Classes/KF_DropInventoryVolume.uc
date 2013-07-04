/*
	--------------------------------------------------------------
	KF_DropInventoryVolume
	--------------------------------------------------------------

    This volume forces pawns which touch it to drop any items they may
    be carrying of the specified type.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_DropInventoryVolume extends Volume;

/* The type of item that gets dropped */
var ()  class<Inventory>  DropInventoryType;

/* Attempt to throw the inventory item toward this actor */
var ()  Actor             DropTargetLoc;

/* Amount of offset to apply to drop target loc */
var ()  float             DropTargetOffset;

var array<Pickup>         RepositionedPickups;


simulated event Touch( Actor Other )
{
    local Pawn TouchPawn;
    local Inventory Inv;
    local vector TargetVelocity;
    local vector DropFromLoc;
	local Vector X,Y,Z;
	local Pickup P;
	local vector RandOffset;

    /* Cause pawns to toss their pickups */

    TouchPawn = Pawn(Other);
    if(TouchPawn != none)
    {
	   TouchPawn.GetAxes(Rotation,X,Y,Z);

        for( Inv=TouchPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
        {
            if(Inv.IsThrowable() && ClassIsChildOf(Inv.Class,DropinventoryType))
            {
                TargetVelocity = Vector(TouchPawn.Rotation)* 250.f;
                DropFromLoc = TouchPawn.Location + 0.8 * TouchPawn.CollisionRadius * X - 0.5 * TouchPawn.CollisionRadius * Y ;
                Inv.Velocity = TargetVelocity ;
                Inv.DropFrom(DropFromLoc);
            }
        }
    }

    /* Reposition tossed pickups */

    P = Pickup(Other);
    if(P != none && P.InventoryType == DropInventoryType && !AlreadyRepositioned(P))
    {
        if(DropTargetLoc != none &&
        !DropTargetLoc.bBlockActors &&
        DropTargetLoc.Location != vect(0,0,0))
        {
            RepositionedPickups[RepositionedPickups.length] = P;

            RandOffset.X = FRand() * DropTargetOffset;
            RandOffset.Y = FRand() * DropTargetOffset;

            P.SetLocation(DropTargetLoc.Location + Vect(0,0,1)*P.CollisionHeight + RandOffset) ;
        }
    }
}

function bool AlreadyRepositioned(Pickup P)
{
    local int i;

    for( i = 0 ; i < RepositionedPickups.length ; i ++)
    {
        if(RepositionedPickups[i] != none &&
        RepositionedPickups[i] == P)
        {
            return true;
        }
    }

    return false;
}

defaultproperties
{
     DropTargetOffset=64.000000
}
