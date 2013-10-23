class KF_Slot_CashPickup extends CashPickup;

simulated function PostBeginPlay()
{
    Super.PostbeginPlay();
    Velocity = Normal(vector(Rotation)) * 250.f + VRand()*50.f  ;
}

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	GotoState('FallingPickup');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
    bDropped = true;
    LifeSpan = 5;
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
}

function GiveCashTo( Pawn Other )
{
	// You all love the mental-mad typecasting XD
	if( !bDroppedCash )
	{
	}
	else if ( Other.PlayerReplicationInfo != none && DroppedBy.PlayerReplicationInfo != none &&
			  ((DroppedBy.PlayerReplicationInfo.Score + float(CashAmount)) / Other.PlayerReplicationInfo.Score) >= 0.50 &&
			  PlayerController(DroppedBy) != none && KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements) != none )
	{
		if ( Other.PlayerReplicationInfo != DroppedBy.PlayerReplicationInfo )
		{
			KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements).AddDonatedCash(CashAmount);
		}
	}

	if( Other.Controller!=None && Other.Controller.PlayerReplicationInfo!=none )
	{
		Other.Controller.PlayerReplicationInfo.Score += CashAmount;
	}
	AnnouncePickup(Other);
	SetRespawn();
}

defaultproperties
{
     CashAmount=100
     RespawnTime=0.000000
     bOnlyDirtyReplication=False
     bFixedRotationDir=False
}
