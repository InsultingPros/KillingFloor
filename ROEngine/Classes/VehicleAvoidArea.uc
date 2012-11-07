//-----------------------------------------------------------
//
//-----------------------------------------------------------
Class VehicleAvoidArea extends AvoidMarker;

var ROVehicle Vehicle;		// vehicle this market is attached to -- should be the same as base and owner

state BigMeanAndScary
{
Begin:
	StartleBots();
	Sleep(1.0);
	GoTo('Begin');
}

function InitFor(ROVehicle V)
{
	if (V != None)
	{
		Vehicle = V;
		SetCollisionSize(Vehicle.CollisionRadius *3, Vehicle.CollisionHeight + CollisionHeight);
		SetBase(Vehicle);
		GoToState('BigMeanAndScary');
	}
}

function Touch( actor Other )
{
	if ( (Pawn(Other) != None) && RelevantTo(Pawn(Other)) )
	{
//		Pawn(Other).Controller.FearThisSpot(Self);
		ROBot(Pawn(Other).Controller).AvoidThisVehicle(Vehicle);
	}
}

function bool RelevantTo(Pawn P)
{
	return ( Vehicle != None && Vehicle.Driver != None && VSizeSquared(Vehicle.Velocity) >= 400 && Super.RelevantTo(P)
	 && Vehicle.Velocity dot (P.Location - Vehicle.Location) > 0
	 &&	(Vehicle(P.Controller.RouteGoal) == None || Vehicle(P.Controller.RouteGoal).GetVehicleBase() != Vehicle)  );
}

function StartleBots()
{
	local ROPawn P;

	if (Vehicle != None)
		ForEach CollidingActors(class'ROPawn', P, CollisionRadius)
			if ( RelevantTo(P) )
			{
//				P.Controller.FearThisSpot(Self);
				ROBot(P.Controller).AvoidThisVehicle(Vehicle);
			}
}

defaultproperties
{
     CollisionRadius=1000.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bBlockHitPointTraces=False
}
