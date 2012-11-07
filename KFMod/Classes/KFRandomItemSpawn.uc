// Spawn Random items / weapons in to keep the envirments searchable and dynamic :)
// Modded from WildcardBase to allow for all pickup classtypes, not just tournament ones.
class KFRandomItemSpawn extends KFRandomSpawn;

simulated function PostBeginPlay()
{
	local int i;

	if ( Level.NetMode != NM_Client )
	{
		NumClasses = 0;

		if ( bForceDefault )
		{
			for ( i = 0; i < ArrayCount(PickupClasses); ++i)
			{
				PickupClasses[i] = default.PickupClasses[i];
				PickupWeight[i] = default.PickupWeight[i];
			}
		}

		for ( i = 0; i < ArrayCount(PickupClasses) && PickupClasses[NumClasses] != none; ++i )
		{
			NumClasses++;

			if ( PickupWeight[i]==0 )
				PickupWeight[i]=1;

			WeightTotal+=PickupWeight[i];
		}

		CurrentClass = GetWeightedRandClass();
		PowerUp = PickupClasses[CurrentClass];
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		for ( i=0; i< NumClasses; i++ )
		{
			PickupClasses[i].static.StaticPrecache(Level);
		}
	}

	// Add to KFGameType.WeaponPickups array
	if ( KFGameType(Level.Game) != none )
	{
		KFGameType(Level.Game).WeaponPickups[KFGameType(Level.Game).WeaponPickups.Length] = self;
		DisableMe();
	}

	SetLocation(Location - vect(0,0,1)); // adjust because reduced drawscale
}

function SpawnPickup()
{
	super.SpawnPickup();

	if ( KFWeaponPickup(myPickup) != none )
	{
		KFWeaponPickup(myPickup).MySpawner = self;
	}
}

function NotifyNewWave(int CurrentWave, int FinalWave)
{
}

function EnableMe()
{
	bIsEnabledNow = True;
	SetTimer(0.1, false);
}

function EnableMeDelayed(float Delay)
{
	bIsEnabledNow = True;
	SetTimer(Delay, false);
}

defaultproperties
{
     PickupClasses(0)=Class'KFMod.DualiesPickup'
     PickupClasses(1)=Class'KFMod.ShotgunPickup'
     PickupClasses(2)=Class'KFMod.BullpupPickup'
     PickupClasses(3)=Class'KFMod.DeaglePickup'
     PickupClasses(4)=Class'KFMod.WinchesterPickup'
     PickupClasses(5)=Class'KFMod.AxePickup'
     PickupClasses(6)=Class'KFMod.MachetePickup'
     PickupClasses(7)=Class'KFMod.Vest'
     PickupWeight(0)=3
     PickupWeight(1)=1
     PickupWeight(2)=3
     PickupWeight(3)=3
     PickupWeight(4)=2
     PickupWeight(5)=1
     PickupWeight(6)=1
     PickupWeight(7)=2
     Texture=Texture'PatchTex.Common.WeaponSpawnIcon'
}
