class Objective_Whisp extends RedWhisp;

var transient  vector DestLoc;


function PostBeginPlay()
{
	super(xEmitter).PostBeginPlay();
    InitWhisp();
}

function InitWhisp()
{
	local int i,start;
	local PlayerController C;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;


	C = PlayerController(Owner);
	if ( C.Pawn == None )
		return;
	SetLocation(C.Pawn.Location);

	WayPoints[0] = C.Pawn.Location + 200 * vector(C.Rotation);
	HitActor = Trace(HitLocation, HitNormal,WayPoints[0], C.Pawn.Location,false);
	if ( HitActor != None )
		WayPoints[0] = HitLocation;
	NumPoints++;

	if ( (C.RouteCache[i] != None) && C.RouteCache[1] != none && C.ActorReachable(C.RouteCache[1]) )
		start = 1;
	for ( i=start; i<start+10; i++ )
	{
		if ( C.RouteCache[i] == None )
			break;
		else
		{
			WayPoints[NumPoints] = C.RouteCache[i].Location;
			NumPoints++;
		}
	}

	if( NumPoints < start+10 )
	{
	     WayPoints[NumPoints] = DestLoc;
		 NumPoints++;
	}

	Velocity = 500 * Normal(WayPoints[0] - Location) + C.Pawn.Velocity;
}

defaultproperties
{
}
