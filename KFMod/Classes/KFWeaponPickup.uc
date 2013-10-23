class KFWeaponPickup extends WeaponPickup
	placeable;

// Begin code from UTWeaponPickup
var(WeaponPickup) vector StandUp;	// rotation change used by WeaponLocker
var(WeaponPickup) float LockerOffset;
// End code from UTWeaponPickup

var () float Weight; // How much does this weapon weight?

// SHOPPING STUFF
var int Cost;
var int AmmoCost;
var int BuyClipSize;
var int PowerValue;
var int SpeedValue;
var int RangeValue;
var string Description;
var localized string ItemName;
var localized string ItemShortName;
var string AmmoItemName;
var mesh showMesh;
var staticMesh AmmoMesh;
var () bool bNoRespawn;
var () bool bOnePickupOnly; // for static level pickups intended to be used only once.

// These are only set for Pickups that are the Secondary Ammo Pickup(such as M4203Pickup)
var	localized string		SecondaryAmmoShortName;
var	class<KFWeaponPickup>	PrimaryWeaponPickup;

var int MagAmmoRemaining; // Store the number of rounds in the clip when guns get ditched
var float LastCantCarryTime;

var byte	CorrespondingPerkIndex; // Used for the trader menu

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var globalconfig bool bBlobShadow;

var     byte    EquipmentCategoryID;

var () bool bNoShadows; // check if you dont want pickup to have projector shadows.

// Keep up with the Random Item Spawner that spawned us(if any)
var	KFRandomItemSpawn	MySpawner;

var int SellValue; // Stores the value for weapons that were purchased, then dropped, to keep people from cheating the system

// Achievement Helpers
var	PlayerController	DroppedBy;
var	bool				bPreviouslyDropped;

// potential variants (gold, camo, etc.)
var array< class<Pickup> > VariantClasses;

simulated function PostNetBeginPlay()
{
	// decide which type of shadow to spawn
	if (!bNoShadows)
	{
		PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.LightDistance = 320;
		PlayerShadow.MaxTraceDistance = 350;
		PlayerShadow.InitShadow();
		PlayerShadow.bShadowActive = true;
	}
}


// cut n pasted to remove uneeded stuff and generally tweak+modify
function float BotDesireability( pawn Bot )
{
	local Weapon AlreadyHas;
	local float desire;

	// Check weight, and make too-heavy items completely unwantable
	// TODO: Check if there's something worth ditching
	if(KFHumanPawn(Bot)!=none)
	{
		if(KFHumanPawn(Bot).CurrentWeight+self.Weight > KFHumanPawn(Bot).MaxCarryWeight )
			return -10;
	}

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType));
	if ( AlreadyHas != None )
		return -10;

	if ( Bot.Controller.bHuntPlayer && (MaxDesireability * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;
	return desire;
}

function RespawnEffect()
{

}

function InitDroppedPickupFor(Inventory Inv)
{
	local KFWeapon W;
	local Inventory InvIt;
	local byte bSaveAmmo[2];
	local int m;

	W = KFWeapon(Inv);

	if (W != None)
	{
		//Check if any other weapon is using the same ammo
		for(InvIt = W.Owner.Inventory; InvIt!=none; InvIt=InvIt.Inventory)
		{
			if(Weapon(InvIt)!=none && InvIt!=W)
			{
				for(m=0; m < 2; m++)
				{
					if(Weapon(InvIt).AmmoClass[m] == W.AmmoClass[m])
						bSaveAmmo[m] = 1;
				}
			}
		}
		if(bSaveAmmo[0]==0)
		{
			MagAmmoRemaining = W.MagAmmoRemaining;
			AmmoAmount[0] = W.AmmoAmount(0);
		}
		if(bSaveAmmo[1]==0)
			AmmoAmount[1] = W.AmmoAmount(1);

		SellValue = W.SellValue;
	}
	SetPhysics(PHYS_Falling);
	GotoState('FallingPickup');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
	bDropped = true;
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
	bNoRespawn = true;

	if ( KFWeapon(Inventory) != none )
	{
		if ( KFWeapon(Inventory).bIsTier2Weapon )
		{
			if ( !KFWeapon(Inventory).bPreviouslyDropped && PlayerController(Pawn(Inventory.Owner).Controller) != none )
			{
				KFWeapon(Inventory).bPreviouslyDropped = true;
				KFSteamStatsAndAchievements(PlayerController(Pawn(Inventory.Owner).Controller).SteamStatsAndAchievements).AddDroppedTier2Weapon();
			}
		}
		else
		{
			bPreviouslyDropped = KFWeapon(Inventory).bPreviouslyDropped;
			DroppedBy = PlayerController(Pawn(W.Owner).Controller);
		}
	}
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
		local int i;

		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
		for ( i=0; i<4; i++ )
			TeamOwner[i] = None;
	}
	function EndState()
	{
		if (bNoRespawn)
			return;
		else
		{
			NetUpdateTime = Level.TimeSeconds - 1;
			bHidden = false;
		}
	}
	function bool PlayerSeezMe()
	{
		local Controller C;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 && C.bIsPlayer && C.LineOfSightTo(Self) )
				Return True;
		}
		return False;
	}

DelayedSpawn:
	if ( Level.NetMode == NM_Standalone )
		Sleep(FMin(30, Level.Game.GameDifficulty * 8));
	else Sleep(30);
	Goto('Respawn');
Begin:
	Sleep( GetReSpawnTime() - RespawnEffectTime );
Respawn:
	While( PlayerSeezMe() )
		Sleep(5+FRand()*5);   // Crafty randomization...you'll never know when the next respawn attempt will be !  (5-10 seconds)
	RespawnEffect();
	Sleep(RespawnEffectTime);
	if (PickUpBase != None)
		PickUpBase.TurnOn();
	GotoState('Pickup');
}

simulated event ClientTrigger()
{
	bHidden = true;
}

function bool CheckCanCarry(KFHumanPawn Hm)
{
	local Inventory CurInv;
	local bool bHasHandCannon;

	for ( CurInv = Hm.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
  		if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).class == class'KFMod.Deagle' )
        {
			bHasHandCannon = true;
        }
    }

	if ( !Hm.CanCarry(Class<KFWeapon>(InventoryType).Default.Weight) && Class<KFWeapon>(InventoryType) != class'KFMod.Deagle')
	{
		if ( LastCantCarryTime < Level.TimeSeconds && PlayerController(Hm.Controller) != none )
		{
			LastCantCarryTime = Level.TimeSeconds + 0.5;
			PlayerController(Hm.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
		}

		return false;
	}

	if ( Class<KFWeapon>(InventoryType) == class'KFMod.Deagle' )
	{
		if ( !bHasHandCannon && !Hm.CanCarry(Class<KFWeapon>(InventoryType).Default.Weight) )
		{
			LastCantCarryTime = Level.TimeSeconds + 0.5;
			PlayerController(Hm.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);

			return false;
		}
	}

	return true;
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

				if ( !bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
					 Pawn(Other).Controller != none && Pawn(Other).Controller != DroppedBy )
				{
					KFWeapon(Copy).Tier3WeaponGiver = DroppedBy;
				}
			}
		}
	}

	function Timer()
	{
	}

	function BeginState()
	{
	}
}

state FadeOut
{
	function Tick(float DeltaTime)
	{
	}

	function BeginState()
	{
	}

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

				if ( !bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
					 Pawn(Other).Controller != none && Pawn(Other).Controller != DroppedBy )
				{
					KFWeapon(Copy).Tier3WeaponGiver = DroppedBy;
				}
			}
		}
	}
}

function Destroyed()
{
	if ( bDropped && class<Weapon>(Inventory.Class) != none )
	{
		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponDestroyed(class<Weapon>(Inventory.Class));
		}
	}

	super.Destroyed();
}

defaultproperties
{
     LockerOffset=35.000000
     Weight=10.000000
     cost=2000
     AmmoCost=20
     Description="I AM A DEFAULT DESCRIPTION! KILL ME NOW!"
     ItemName="DULL ITEMNAME!!!! KILL KILL KILL!!!!"
     AmmoItemName="SHOOT THE DEVS! LAZY SODS DESERVE TO DIE!!!!!"
     bNoShadows=True
     SellValue=-1
     bWeaponStay=False
     MaxDesireability=0.780000
     bOnlyReplicateHidden=False
     bAmbientGlow=False
     RespawnTime=100.000000
     PickupSound=Sound'KF_BullpupSnd.Bullpup_Pickup'
     DrawType=DT_StaticMesh
     Physics=PHYS_Falling
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     TransientSoundVolume=100.000000
     CollisionRadius=20.000000
     CollisionHeight=15.000000
     bFixedRotationDir=False
     RotationRate=(Yaw=0)
     DesiredRotation=(Yaw=0)
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
