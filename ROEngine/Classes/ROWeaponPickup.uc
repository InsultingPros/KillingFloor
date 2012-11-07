//=============================================================================
// ROWeaponPickup
//=============================================================================
// Base class for all Red Orchestra weapon pickups
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ROWeaponPickup extends WeaponPickup
	abstract
	notplaceable;

var 	class<LocalMessage> TouchMessageClass;  // Message class for picking up this pickup
var() 	localized string 	TouchMessage; 		// Human readable description when touched up.
var 	float 				LastNotifyTime; 	// Last time someone selected this pickup
var() 	float 				DropLifeTime;		// How long the pickup will hang around for after being dropped
var		bool				bHasBayonetMounted; // This pickup has a mounted bayonet

// Overriden to spawn from the pawn, so that the weapon has an instigator from the start
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = Other.spawn(InventoryType,Other,,,rot(0,0,0));

	Copy.GiveTo( Other, self );

	return Copy;
}

// Testing, don't want bots to stand around and stare at pickups - Ramm
// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
// TODO: This needs to be properly implemented. Essentially, bots should only pick up a new weapon in RO
// If they are out of ammo or thier weapon is shot out of hand
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local class<Pickup> AmmoPickupClass;
	local float desire;

	// Testing - Ramm
	return 0;

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType));
	if ( AlreadyHas != None )
	{
		if ( Bot.Controller.bHuntPlayer )
			return 0;

		// can't pick it up if weapon stay is on
		if ( !AllowRepeatPickup() )
			return 0;
		if ( (RespawnTime < 10)
			&& ( bHidden || AlreadyHas.AmmoMaxed(0)) )
			return 0;

		if ( AlreadyHas.AmmoMaxed(0) )
			return 0.25 * desire;

		// bot wants this weapon for the ammo it holds
		if( AlreadyHas.AmmoAmount(0) > 0 )
		{
			AmmoPickupClass = AlreadyHas.AmmoPickupClass(0);

			if ( AmmoPickupClass == None )
				return 0.05;
			else
				return FMax( 0.25 * desire,
						AmmoPickupClass.Default.MaxDesireability
						* FMin(1, 0.15 * AlreadyHas.MaxAmmo(0)/AlreadyHas.AmmoAmount(0)) );
		}
		else
			return 0.05;
	}
	if ( Bot.Controller.bHuntPlayer && (MaxDesireability * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
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
    local Weapon W;
    W = Weapon(Inv);
    if (W != None)
    {
        AmmoAmount[0] = W.AmmoAmount(0);
        AmmoAmount[1] = W.AmmoAmount(1);
        bHasBayonetMounted = W.bBayonetMounted;
    }

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
