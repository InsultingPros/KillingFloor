class BullpupSuperAmmoPickup extends KFAmmoPickup;

simulated Function PostNetBeginPlay()
{
	SetTimer(0.3, False);
}

simulated Function Timer()
{
	Destroy();
}

auto state Pickup
{
	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		local Inventory Copy;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			SetRespawn();
			if ( Copy != None )
				Copy.PickupFunction(Pawn(Other));
		}
		else destroy();
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
			Touch(P);
	}

	function Timer()
	{
		if ( bDropped )
			GotoState('FadeOut');
	}

	function BeginState()
	{
		UntriggerEvent(Event, self, None);
		if ( bDropped )
		{
			AddToNavigation();
			SetTimer(8, false);
		}
	}

	function EndState()
	{
		if ( bDropped )
			RemoveFromNavigation();
	}

Begin:
	CheckTouching();
}


State Sleeping
{
ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return ( bPredictRespawns && (LatentFloat < MaxWait) );
	}

	function StartSleeping() {}

	function BeginState()
	{
		Destroy();
	}

	function EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = false;
	}

DelayedSpawn:
	if ( Level.NetMode == NM_Standalone )
		Sleep(FMin(30, Level.Game.GameDifficulty * 8));
	else Sleep(30);
	Goto('Respawn');
Begin:
	Sleep( GetReSpawnTime() - RespawnEffectTime );
Respawn:
	for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
	{
		if (OtherPlayer.pawn != none)
		{
			if(!FastTrace(self.Location,OtherPlayer.Pawn.Location))
			{
				RespawnEffect();
				Sleep(RespawnEffectTime);
				if (PickUpBase != None)
					PickUpBase.TurnOn();
				GotoState('Pickup');
			}
			else Sleep(rand(5) + 5);   // Crafty randomization...you'll never know when the next respawn attempt will be !  (5-10 seconds)
			Goto('Respawn');
		}
	}
}

defaultproperties
{
     AmmoAmount=500
     PickupMessage=
     StaticMesh=StaticMesh'KillingFloorStatics.L85Ammo'
}
