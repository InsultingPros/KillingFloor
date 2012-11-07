//=============================================================================
// MedicGun Pickup.  Meant for weapons which can both shoot healing syringes and be dropped
//=============================================================================
class MedicGunPickup extends KFWeaponPickup;

var int HealAmmoCharge;

function InitDroppedPickupFor(Inventory Inv)
{
     super.InitDroppedPickupFor(Inv);
     HealAmmoCharge = KFMedicGun(Inv).HealAmmoCharge;
}

auto state pickup
{
	function BeginState()
	{
		UntriggerEvent(Event, self, None);
		if ( bDropped )
		{
			AddToNavigation();
			SetTimer(20, false);
		}
	}

	// When touched by an actor.  Let's mod this to account for Weights. (Player can't pickup items)
	// IF he's exceeding his max carry weight.
	function Touch(Actor Other)
	{
		local Inventory Copy;

		if ( KFHumanPawn(Other) != none && !CheckCanCarry(KFHumanPawn(Other)) )
		{
			return;
		}

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			SetRespawn();

			if ( Copy != None )
			{
				Copy.PickupFunction(Pawn(Other));
			}

			if ( MySpawner != none && KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponPickedUp(MySpawner);
			}

			if ( KFWeapon(Copy) != none )
			{
				KFWeapon(Copy).SellValue = SellValue;
				KFWeapon(Copy).bPreviouslyDropped = bDropped;
                KFMedicGun(Copy).HealAmmoCharge = HealAmmoCharge;

				if ( !bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
					 Pawn(Other).Controller != none && Pawn(Other).Controller != DroppedBy )
				{
					KFWeapon(Copy).Tier3WeaponGiver = DroppedBy;
				}
			}
		}
	}
}

state FallingPickup
{
	// When touched by an actor.  Let's mod this to account for Weights. (Player can't pickup items)
	// IF he's exceeding his max carry weight.
	function Touch(Actor Other)
	{
		local Inventory Copy;

		if ( KFHumanPawn(Other) != none && !CheckCanCarry(KFHumanPawn(Other)) )
		{
			return;
		}

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			SetRespawn();

			if ( Copy != None )
			{
				Copy.PickupFunction(Pawn(Other));
			}

			if ( MySpawner != none && KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponPickedUp(MySpawner);
			}

			if ( KFWeapon(Copy) != none )
			{
				KFWeapon(Copy).SellValue = SellValue;
				KFWeapon(Copy).bPreviouslyDropped = bDropped || DroppedBy != none;
                KFMedicGun(Copy).HealAmmoCharge = HealAmmoCharge;

				if ( !bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
					 Pawn(Other).Controller != none && Pawn(Other).Controller != DroppedBy )
				{
					KFWeapon(Copy).Tier3WeaponGiver = DroppedBy;
				}
			}
		}
	}
}

state FadeOut
{
	function Touch( actor Other )
	{
		local Inventory Copy;

		if ( KFHumanPawn(Other) != none && !CheckCanCarry(KFHumanPawn(Other)) )
		{
			return;
		}

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			SetRespawn();

			if ( Copy != None )
			{
				Copy.PickupFunction(Pawn(Other));
			}

			if ( MySpawner != none && KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponPickedUp(MySpawner);
			}

			if ( KFWeapon(Copy) != none )
			{
				KFWeapon(Copy).SellValue = SellValue;
				KFWeapon(Copy).bPreviouslyDropped = bDropped || DroppedBy != none;
                KFMedicGun(Copy).HealAmmoCharge = HealAmmoCharge;

				if ( !bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
					 Pawn(Other).Controller != none && Pawn(Other).Controller != DroppedBy )
				{
					KFWeapon(Copy).Tier3WeaponGiver = DroppedBy;
				}
			}
		}
	}
}

defaultproperties
{
}
