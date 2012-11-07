//=============================================================================
// ROAmmoPickup
//=============================================================================
// Base class for all Red Orchestra weapon ammunition pickups
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROAmmoPickup extends Ammo
	abstract;
	// TODO: Probably want to add notplaceable here when we are done debugging

var 	class<LocalMessage> TouchMessageClass;  // Message class for picking up this pickup
var() 	localized string 	TouchMessage; 		// Human readable description when touched up.
var 	float 				LastNotifyTime; 	// Last time someone selected this pickup
var() 	float 				DropLifeTime;		// How long the pickup will hang around for after being dropped
var		bool				bAmmoPickupIsWeapon;// This ammo pickup give the weapon if the user doesnt have it. used for things like nades and panzerfausts

// Testing, don't want bots to stand around and stare at pickups - Ramm
// TODO: Implement this properly. Bots should try and pickup ammo if they are low or out
function float BotDesireability(Pawn Bot)
{
	local Inventory inv;
	local Weapon W;
	local float Desire;
	local Ammunition M;

	// Ramm - Test
	return 0;

	if ( Bot.Controller.bHuntPlayer )
		return 0;
	for ( Inv=Bot.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		W = Weapon(Inv);
		if ( W != None )
		{
			Desire = W.DesireAmmo(InventoryType, false);
			if ( Desire != 0 )
				return Desire * MaxDesireability;
		}
	}
	M = Ammunition(Bot.FindInventoryType(InventoryType));
	if ( (M != None) && (M.AmmoAmount >= M.MaxAmmo) )
		return -1;
	return 0.25 * MaxDesireability;
}

// Let the player know they can pick this up
simulated event NotifySelected( Pawn user )
{
	if( user.IsHumanControlled() && (( Level.TimeSeconds - LastNotifyTime ) >= TouchMessageClass.default.LifeTime))
	{
		PlayerController(User.Controller).ReceiveLocalizedMessage(TouchMessageClass,1,,,self.class);

        LastNotifyTime = Level.TimeSeconds;
	}
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	switch(Switch)
	{
		case 0:
			return Default.PickupMessage;

		case 1:
			return default.TouchMessage;
	}
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
    LifeSpan = DropLifeTime + rand(10);
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
}

state FallingPickup
{
	ignores Touch;


	function CheckTouching()
	{
	}

	function Timer()
	{
		GotoState('FadeOut');
	}

	function BeginState()
	{
	    SetTimer(8, false);
	}
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
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None))
			return false;

 		if( ROPawn(Other) != none && ROPawn(Other).AutoTraceActor != none && ROPawn(Other).AutoTraceActor == self )
		{
			// do nothing
		}
		// make sure not touching through wall
		else if ( !FastTrace(Other.Location, Location) )
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
	}

	function CheckTouching()
	{
	}

	function UsedBy( Pawn user )
	{
    	local Inventory Copy;

		if( user == none )
			return;

		// valid touch will pickup the object
		if( ValidTouch( user ) )
		{
			Copy = SpawnCopy(user);
			AnnouncePickup(user);
            if ( Copy != None )
				Copy.PickupFunction(user);
			Destroy();
		}
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
		    SetTimer(DropLifeTime, false);
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

// Overrides the UT fadeout since we don't want our pickups to spin and disappear
state FadeOut
{
	function Tick(float DeltaTime)
	{
		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
	}

	// Overriden so this item won't get picked up automatically if it is touching someone when it fades out
	function Touch( actor Other ){}
	function CheckTouching(){}

	function BeginState()
	{
		LifeSpan = 1.0;
	}

	function EndState()
	{
		LifeSpan = 0.0;
		SetDrawScale(Default.DrawScale);
	}
}

//====================================================================
// Reset(UT) - Destroy any remaining pickups when the round restarts
//====================================================================
function Reset()
{
	Destroy();
}

defaultproperties
{
     TouchMessageClass=Class'ROEngine.ROTouchMessagePlus'
     DropLifeTime=45.000000
     bCanAutoTraceSelect=True
     bAutoTraceNotify=True
}
