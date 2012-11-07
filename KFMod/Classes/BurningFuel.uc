// Shoot it, and it spawns damaging flames that last for a duration.
// :Alex
class BurningFuel extends Actor
	Placeable;

var () int BurnThreshold;  // Minimum damage before it ignites?
var bool bBurning,bDoneBurning,bClientBurning; // is this fuel burning?
var FuelFlame Flames; // our flames!
var() float BurnDuration;

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		bBurning;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( Damage>=BurnThreshold && !bBurning && !bDoneBurning )
	{
		SetTimer(BurnDuration,False);
		bBurning = true;
		Flames = Spawn(class 'KFMod.FuelFlame',,,location,rotation);
		Flames.Parent = self;

		if( Level.NetMode!=NM_DedicatedServer )
			Spawn(class 'Old2k4.LavaDeath',,,location,rotation);
	}
}


simulated function Tick( float DeltaTime)
{
	if( Level.NetMode==NM_DedicatedServer )
	{
		Disable('Tick');
		Return;
	}
	If( bBurning && DrawScale>0.1 )
		SetDrawScale(DrawScale - 0.1*DeltaTime);
}

function Timer()
{
	bBurning = false;
	bDoneBurning = True;
	if( Flames!=None )
		Flames.Destroy();
}

simulated function PostNetReceive()
{
	if( bClientBurning!=bBurning )
	{
		bClientBurning = bBurning;
		if( bBurning )
		{
			Flames = Spawn(class 'KFMod.FuelFlame',,,location,rotation);
			Flames.Parent = self;
			Spawn(class 'Old2k4.LavaDeath',,,location,rotation);
		}
		else if( Flames!=None )
			Flames.Destroy();
	}
}

defaultproperties
{
     BurnDuration=10.000000
     DrawType=DT_StaticMesh
     bAcceptsProjectors=False
     RemoteRole=ROLE_SimulatedProxy
     bStaticLighting=True
     bCollideActors=True
     bNetNotify=True
}
