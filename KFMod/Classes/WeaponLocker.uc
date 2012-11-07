class WeaponLocker extends Actor
	placeable;

var() float TriggerRadius, TriggerHeight;
var bool bActive, bOpen;
var int OpenRefs;

simulated event PreBeginPlay()
{
	local ShopVolume Shop;

	super.PreBeginPlay();

	foreach VisibleCollidingActors(class'ShopVolume', Shop, 1000)
	{
		Shop.MyTrader = self;
	}
}

simulated event PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Idle');
}

function SetOpen(bool bToOpen)
{
	switch(bToOpen)
	{
	case false:
		OpenRefs--;
		if(bOpen && OpenRefs == 0)
		{
			if( Level.NetMode!=NM_DedicatedServer )
				LoopAnim('Idle');
			bOpen=false;
		}
		break;
	case true:
		OpenRefs++;
		if(!bOpen)
		{
			NetUpdateTime = Level.TimeSeconds - 1;
			bClientTrigger = !bClientTrigger;
			if( Level.NetMode!=NM_DedicatedServer )
				ClientTrigger();
			bOpen=true;
		}
		break;
	}
}
simulated function AnimEnd( int Channel )
{
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Idle');
}
simulated event ClientTrigger()
{
	//PlayAnim('Gesture');
}

defaultproperties
{
     TriggerRadius=150.000000
     TriggerHeight=100.000000
     bActive=True
     DrawType=DT_Mesh
     bAlwaysRelevant=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.200000
     Mesh=SkeletalMesh'KF_Soldier_Trip.ShopKeeper_Trip'
     CollisionRadius=15.000000
     CollisionHeight=50.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
}
