class KFAmmoPickup extends Ammo;

var() Material KFPickupImage;
var bool bSleeping;
var bool bShowPickup;
var Controller OtherPlayer;

event PostBeginPlay()
{
	// Add to KFGameType.AmmoPickups array
	if ( KFGameType(Level.Game) != none )
	{
		KFGameType(Level.Game).AmmoPickups[KFGameType(Level.Game).AmmoPickups.Length] = self;
		GotoState('Sleeping', 'Begin');
	}
}

state Pickup
{
	// When touched by an actor.
	function Touch(Actor Other)
	{
		local Inventory CurInv;
		local bool bPickedUp;
		local int AmmoPickupAmount;

		if ( Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none &&
			 FastTrace(Other.Location, Location) )
		{
			for ( CurInv = Other.Inventory; CurInv != none; CurInv = CurInv.Inventory )
			{
				if ( KFAmmunition(CurInv) != none && KFAmmunition(CurInv).bAcceptsAmmoPickups )
				{
					if ( KFAmmunition(CurInv).AmmoPickupAmount > 1 )
					{
						if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
						{
							if ( KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill != none )
							{
								AmmoPickupAmount = float(KFAmmunition(CurInv).AmmoPickupAmount) * KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoPickupMod(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo), KFAmmunition(CurInv));
							}
							else
							{
								AmmoPickupAmount = KFAmmunition(CurInv).AmmoPickupAmount;
							}

							KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount);
							bPickedUp = true;
						}
					}
					else if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
					{
						bPickedUp = true;

						if ( FRand() <= (1.0 / Level.Game.GameDifficulty) )
						{
							KFAmmunition(CurInv).AmmoAmount++;
						}
					}
				}
			}

			if ( bPickedUp )
			{
				AnnouncePickup(Pawn(Other));
				GotoState('Sleeping', 'Begin');

				if ( KFGameType(Level.Game) != none )
				{
					KFGameType(Level.Game).AmmoPickedUp(self);
				}
			}
		}
	}
}

auto state Sleeping
{
	ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return (bPredictRespawns && LatentFloat < MaxWait);
	}

	function StartSleeping() {}

	function BeginState()
	{
		local int i;

		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
		bSleeping = true;
		SetCollision(false, false);

		for ( i = 0; i < 4; i++ )
		{
			TeamOwner[i] = None;
		}
	}

	function EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = false;
		bSleeping = false;
		SetCollision(default.bCollideActors, default.bBlockActors);
	}

Begin:
	bSleeping = true;
	Sleep(1000000.0); // Sleep for 11.5 days(never wake up)

DelayedSpawn:
	bSleeping = false;
	Sleep(RespawnTime/GetNumPlayers()); // Delay before respawning
	goto('Respawn');

TryToRespawnAgain:
	Sleep(1.0);

Respawn:
	bShowPickup = true;
	for ( OtherPlayer = Level.ControllerList; OtherPlayer != none; OtherPlayer=OtherPlayer.NextController )
	{
		if ( PlayerController(OtherPlayer) != none && OtherPlayer.Pawn != none )
		{
	 		if ( FastTrace(self.Location, OtherPlayer.Pawn.Location) )
	 		{
	 			bShowPickup = false;
	 			break;
			}
		}
	}

	if ( bShowPickup )
	{
		RespawnEffect();
		Sleep(RespawnEffectTime);

		if ( PickUpBase != none )
		{
			PickUpBase.TurnOn();
		}

		GotoState('Pickup');
	}

	Goto('TryToRespawnAgain');
}

// Returns the number of players
function float GetNumPlayers()
{
	local int NumPlayers;
	local Controller C;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0 )
		{
			NumPlayers++;
		}
	}

	// Always return at least 1
	if( NumPlayers < 1 )
	{
		NumPlayers = 1;
	}

	return NumPlayers;
}

function float BotDesireability(Pawn Bot)
{
	local Actor InvIt;
	local KFWeapon Weap;

	// Only make this desirable if bot can use it
	for ( InvIt = Bot; InvIt != none; InvIt = InvIt.Inventory )
	{
		Weap = KFWeapon(InvIt);

		if ( Weap != none && (Weap.AmmoClass[0] == self.class || Weap.AmmoClass[1] == self.class) )
		{
			return super.BotDesireability(Bot);
		}
	}

	return 0;
}

function Reset()
{
	GotoState('Sleeping', 'Begin');
}

event Landed(Vector HitNormal)
{
}

defaultproperties
{
     InventoryType=Class'KFMod.BullpupAmmo'
     bOnlyReplicateHidden=False
     PickupMessage="Found Some Ammo!"
     PickupSound=Sound'KF_InventorySnd.Ammo_GenericPickup'
     PickupForce="AssaultAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'kf_generic_sm.pickups.Metal_Ammo_Box'
     bDynamicLight=True
     Physics=PHYS_Falling
     PrePivot=(Y=21.000000,Z=12.000000)
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     TransientSoundVolume=100.000000
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
