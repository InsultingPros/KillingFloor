// ====================================================================
//  Class:  RODamage.ROBot
//  Parent: XGame.xBot
//
//  <Enter a description here>
// ====================================================================
// $id:$
//------------------------------------------------------------------------------

class ROBot extends xBot;

var	int			DesiredRole;	// Role the bot wants to be
var	int			CurrentRole;	// Role the bot is currently
var	int			PrimaryWeapon;		// Stores the weapon selections
var	int			SecondaryWeapon;
var	int			GrenadeWeapon;
var float 		LastFriendlyFireYellTime;
var float		NearMult, FarMult;		// multipliers for startle collision distances
var ROVehicle AvoidVehicle;			// vehicle we are currently avoiding
var actor       DodgeActor;       	    // Actor bot is presently trying to avoid colliding with
var actor       LastDodgeActor;         // Recent DodgeActor we temporarily don't care about
var float       LastDodgeTime;          // Last time you routed around somebody
var float 		RepeatDodgeFrequency;	// how much time must pass before you can dodge the same person again
var float		CachedMoveTimer;		// hack to save move timer

// Bot support - helps allow telling bots to attack/defend specific objectives
const attackID = 0;				// The messageID for the attack command in the voice pack
const defendID = 1;             // The messageID for the defend command in the voice pack

function NotifyIneffectiveAttack(optional Pawn Other)
{
}

// Using VehicleCharging As a base for this code
state TacticalVehicleMove extends MoveToGoalWithEnemy
{
	ignores SeePlayer, HearNoise;

	function Timer()
	{
		Target = Enemy;
		TimedFireWeaponAtEnemy();
		CheckVehicleRoute();
	}

	function FindDestination()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Cross;

		if ( MoveTarget == None )
		{
			Destination = Pawn.Location;
			return;
		}
		Destination = Pawn.Location + 5000 * Normal(Pawn.Location - MoveTarget.Location);
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);

		if ( HitActor == None )
			return;

		Cross = Normal((Destination - Pawn.Location) cross vect(0,0,1));
		Destination = Destination + 1000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination - 2000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination + 1000 * Cross - 3000 * Normal(Pawn.Location - MoveTarget.Location);
	}

	function EnemyNotVisible()
	{
		WhatToDoNext(15);
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
	if ( Pawn.Physics == PHYS_Flying )
	{
		if ( VSize(Enemy.Location - Pawn.Location) < 1200 )
		{
			FindDestination();
			MoveTo(Destination, None, false);
			if ( Enemy == None )
				WhatToDoNext(91);
		}
		MoveTarget = Enemy;
	}
	else if ( Squad.SquadObjective != none )
	{
      if ( !( VSize(Squad.SquadObjective.location - Pawn.Location) < 6000  && FindBestPathToward(Enemy, false,true) )
      ||  !FindBestPathToward(Squad.SquadObjective, false,true) )
   	{
		if (Pawn.HasWeapon())
			GotoState('RangedAttack');
		else
			WanderOrCamp(true);
	}
   }
Moving:
	FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN TacticalVehicleMove!");
}

// Overriding some Bot movement states to cause the bots to sprint. This is a bit of a
// hack right now.

// Stop sprinting when we are doing a tactical move
state TacticalMove
{
ignores /*SeePlayer,*/ HearNoise;

	function BeginState()
	{
		Super.BeginState();
		ROPawn(Pawn).SetSprinting(False);
	}

}

// Sprint when we are moving to a goal
state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) || !SameTeamAs(P.Controller) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		SetCombatTimer();
		ROPawn(Pawn).SetSprinting(True);
		enable('NotifyBump');
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);

		if( !Pawn.bWantsToCrouch )
			ROPawn(Pawn).SetSprinting(True);
	}
}

// Sprint when we are moving to a goal
state Roaming
{
	ignores EnemyNotVisible;

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function Timer()
	{
		super.Timer();
		if( Vehicle(Pawn) != none )
			CheckVehicleRoute();
	}

	function BeginState()
	{
		super.BeginState();
		SetTimer(0.05, true);
		if(ROPawn(Pawn) != none)
		ROPawn(Pawn).SetSprinting(True);
	}

Begin:
	SwitchToBestWeapon();
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Squad.PriorityObjective(self) == 0) && (Vehicle(Pawn) == None) )
	{
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,5);
		if ( (Pickup(MoveTarget) != None) && !Pickup(MoveTarget).ReadyToPickup(0) )
		{
			CampTime = MoveTarget.LatentFloat;
			GoalString = "Short wait for inventory "$MoveTarget;
			GotoState('RestFormation','ShortWait');
		}
	}
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	WhatToDoNext(12);
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

// Sprint when we are moving to a goal
state Fallback
{
	function bool FireWeaponAt(Actor A)
	{
		if ( (A == Enemy) && (Pawn.Weapon != None) && (Pawn.Weapon.AIRating < 0.5)
			&& (Level.TimeSeconds - Pawn.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
			&& (Squad.PriorityObjective(self) == 0)
			&& (InventorySpot(Routegoal) != None) )
		{
			// don't fire if still spawn protected, and no good weapon
			return false;
		}
		return Global.FireWeaponAt(A);
	}

	function Timer()
	{
		super.Timer();
		if( Vehicle(Pawn) != None )
			CheckVehicleRoute();
	}


   function NotifyIneffectiveAttack(optional Pawn Other)
   {
	  if(ROVehicle(Pawn) != none)
		 WhatToDoNext(54);
   }

	function bool IsRetreating()
	{
		return ( (Pawn.Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
	}

	event bool NotifyBump(actor Other)
	{
		local Pawn P;
		local Vehicle V;

		if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
		{
			if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = Vehicle(RouteGoal).FindEntryVehicle(Pawn);
				if ( V != None )
				{
					V.UsedBy(Pawn);
					if (Vehicle(Pawn) != None)
					{
						Squad.BotEnteredVehicle(self);
						WhatToDoNext(54);
					}
				}
				return true;
			}
		}

		Disable('NotifyBump');
		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy && Pawn.HasWeapon() )
			{
				TimedFireWeaponAtEnemy();
				DoRangedAttackOn(Enemy);
			}
			return false;
		}

		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;
		if ( !SameTeamAs(P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache[1] != None) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
			MoveTarget = RouteCache[1];
		}
		Squad.SetEnemy(self,P);
		if ( Enemy == Other )
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}
		if ( CheckPathToGoalAround(P) )
			return false;

		AdjustAround(P);
		return false;
	}

   function ReceiveProjectileWarning(Projectile proj)
   {
	  super.ReceiveProjectileWarning(proj);

	  if(Vehicle(Pawn) != none)
		 WhatToDoNext(54);
   }

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function EnemyNotVisible()
	{
		if ( Squad.FindNewEnemyFor(self,false) || (Enemy == None) )
			WhatToDoNext(13);
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		bEnemyAcquired = false;
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
		//	disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

	function BeginState()
	{
		SetTimer(0.05, true);
		super.BeginState();
	}

Begin:
	WaitForLanding();
	if( ROPawn(Pawn) != none )
		ROPawn(Pawn).SetSprinting(True);

Moving:
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Vehicle(Pawn) == None) )
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	if( ROPawn(Pawn) != none )
	    ROPawn(Pawn).SetSprinting(True);
	WhatToDoNext(14);
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

// Added code to get bots using ironsights in a rudimentary fashion
state RangedAttack
{
ignores HearNoise, Bump;

   function NotifyIneffectiveAttack(optional Pawn Other)
   {
	  if(VehicleWeaponPawn(Pawn) != none && VehicleWeaponPawn(Pawn).VehicleBase != none && VehicleWeaponPawn(Pawn).VehicleBase.Controller != none)
	  {
		 ROBot(VehicleWeaponPawn(Pawn).VehicleBase.Controller).NotifyIneffectiveAttack(Other);
		 return;
	  }

//      if(ROPawn(Other) == none)
//      {
		 Target = Enemy;
		 GoalString = "Position Myself";
		 GotoState('TacticalVehicleMove');
//      }
   }

	function BeginState()
	{
	   local byte i;
	   local ROVehicle V;
	   local Pawn P;

		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		if ( (Pawn.Physics != PHYS_Flying) || (Pawn.MinFlySpeed == 0) )
		Pawn.Acceleration = vect(0,0,0); //stop

		if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
			Target = Focus;
		else if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");

		if ( ROVehicle(Pawn) != None )
		{
			Vehicle(Pawn).Steering = 0;
			Vehicle(Pawn).Throttle = 0;
			Vehicle(Pawn).Rise = 0;

		 V = ROVehicle(Pawn);
		 P = V.Driver;
	  }
	  else if(ROVehicleWeaponPawn(Pawn) != none)
	  {
		 V = ROVehicleWeaponPawn(Pawn).VehicleBase;
		 P = ROVehicleWeaponPawn(Pawn).Driver;
	  }

	  if(V != none)
	  {
		   for(i=0; i < V.WeaponPawns.Length; i++)
		   {
		      if(V.WeaponPawns[i] == none)
		          break;
		      if(ROVehicleWeaponPawn(V.WeaponPawns[i]).Driver == none)
		      {
			   if(V.WeaponPawns[i].isA('ROTankCannonPawn'))
			   {
				  V.KDriverLeave(true);
				  V.WeaponPawns[i].KDriverEnter(P);
				  break;
			   }

               if(ROPawn(Enemy) != none && V.bIsApc && ROVehicleWeaponPawn(V.WeaponPawns[i]).bIsMountedTankMG)
               {
                  V.KDriverLeave(true);
                  V.WeaponPawns[i].KDriverEnter(P);
                  break;
			}
		   }
		}
		}
		// Cause bots to use thier ironsights when they do this
		if( Pawn.Weapon != none &&  ROProjectileWeapon(Pawn.Weapon) != none )
		{
			ROProjectileWeapon(Pawn.Weapon).ZoomIn(false);
		}
	}

   function EndState()
   {
	   local VehicleWeaponPawn V;
	   local Pawn P;

	   V = VehicleWeaponPawn(Pawn);

	  if(V != none)
	  {
		 P = V.Driver;
		 if( V.VehicleBase.Driver == none)
		 {
			V.KDriverLeave(true);
			V.VehicleBase.KDriverEnter(P);
		 }
	  }
   }

Begin:
	bHasFired = false;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		SwitchToBestWeapon();
	GoalString = GoalString@"Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Target == None )
		WhatToDoNext(335);

	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
   }
	bHasFired = true;
	if ( Target == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Target);
	Sleep(0.1);
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Target == None) || ((Target != Enemy) && (GameObjective(Target) == None) && (Enemy != None) && EnemyVisible()) )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

//-----------------------------------------------------------------------------
// Empty
//-----------------------------------------------------------------------------

function bool CanComboMoving() {return false;}
function bool CanCombo() {return false;}
function bool AutoTaunt() {return false;}
function bool CanImpactJump() {return false;}
function bool CanUseTranslocator() {return false;}
function ImpactJump() {}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	if ( ROPawn(aPawn) != None )
		ROPawn(aPawn).Setup(PawnSetupRecord);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	local vector myLoc;
	// limit frequency of same message
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( Level.Game.bGameEnded || Level.Game.bWaitingToStartMatch )
		return;

	OldMessageID = MessageID;
	OldMessageType = MessageType;

	if (Pawn == none)
		myLoc = location;
	else
		myLoc = Pawn.location;
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType, Pawn, myLoc);

}

// Recieve a command from a player. Overriden to allow specific attack/defend commands for objectives
function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender)
{
	if ( !Level.Game.bTeamGame || (Sender.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
		return;

	// Vehicle bot commands. This is hacked in for now. Its a good start to see how you can control bots
	// in vehicles though
	if ( messagetype == 'VEH_ORDERS' )
	{
			switch (MessageID)	// First 3 bits define double click move
			{
				case 10:
					GetOutOfVehicle();
					break;
				case 2:
					messagetype = 'ORDER';
					MessageID = 2;
					break;
				//default:
				case 1:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 3:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 4:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 5:
					messagetype = 'ORDER';
					MessageID = 4;
					break;

				//TODO: Add support for 'goto' command?
			}
	}
	else if ( messagetype == 'VEH_ALERTS' )
	{
	   if (MessageID == 8)
	   {
	       GetOutOfVehicle();
	   }
	}



	if ( messagetype == 'ORDER' )
		SetOrders(OrderNames[messageID], Sender);
	else if ( messagetype == 'ATTACK' )
		SetOrders(OrderNames[attackID], Sender);
	else if ( messagetype == 'DEFEND' )
		SetOrders(OrderNames[defendID], Sender);
}

// Subclassed to allow for setting the correct team or role specific model in ROTeamgame - Ramm
function ChangeCharacter(string newCharacter, optional string inClass)
{
	if( inClass != "")
	{
		SetPawnClass(inClass, newCharacter);
	}
	else
	{
		SetPawnClass(string(PawnClass), newCharacter);
	}

	UpdateURL("Character", newCharacter, true);
	//SaveConfig();
}

// Overriden to allow for setting the correct RO-specific pawn class
function SetPawnClass(string inClass, string inCharacter)
{
	local class<ROPawn> pClass;

	pClass = class<ROPawn>(DynamicLoadObject(inClass, class'Class'));
	if (pClass != None)
		PawnClass = pClass;

	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(PawnSetupRecord.DefaultName);
}

//-----------------------------------------------------------------------------
// GetRoleInfo - Returns the current RORoleInfo
//-----------------------------------------------------------------------------

function RORoleInfo GetRoleInfo()
{
	return ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;
}

//-----------------------------------------------------------------------------
// GetPrimaryWeapon
//-----------------------------------------------------------------------------

function string GetPrimaryWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || PrimaryWeapon < 0)
		return "";

	return string(RI.PrimaryWeapons[PrimaryWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetPrimaryAmmo
//-----------------------------------------------------------------------------

function int GetPrimaryAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || PrimaryWeapon < 0)
		return -1;

	return RI.PrimaryWeapons[PrimaryWeapon].Amount;
}

//-----------------------------------------------------------------------------
// GetSecondaryWeapon
//-----------------------------------------------------------------------------

function string GetSecondaryWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || SecondaryWeapon < 0)
		return "";

	return string(RI.SecondaryWeapons[SecondaryWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetSecondaryAmmo
//-----------------------------------------------------------------------------

function int GetSecondaryAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || SecondaryWeapon < 0)
		return -1;

	return RI.SecondaryWeapons[SecondaryWeapon].Amount;
}

//-----------------------------------------------------------------------------
// GetGrenadeWeapon
//-----------------------------------------------------------------------------

function string GetGrenadeWeapon()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || GrenadeWeapon < 0)
		return "";

	return string(RI.Grenades[GrenadeWeapon].Item);
}

//-----------------------------------------------------------------------------
// GetGrenadeAmmo
//-----------------------------------------------------------------------------

function int GetGrenadeAmmo()
{
	local RORoleInfo RI;

	RI = GetRoleInfo();

	if (RI == None || GrenadeWeapon < 0)
		return -1;

	return RI.Grenades[GrenadeWeapon].Amount;
}

// Overriden to support our respawn system
state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
TryAgain:
	if ( UnrealMPGameInfo(Level.Game) == None )
		destroy();
}

// Overriden to support getting rid of the pawn when a bot is destroyed, otherwise
// You are left with a skin ninja pawn that just stands there
simulated event Destroyed()
{
	local Vehicle DrivenVehicle;
	local Pawn Driver;

	if ( Pawn != None )
	{
		// If its a vehicle, just destroy the driver, otherwise do the normal.
		DrivenVehicle = Vehicle(Pawn);
		if( DrivenVehicle != None )
		{
			Driver = DrivenVehicle.Driver;
			DrivenVehicle.KDriverLeave(true); // Force the driver out of the car
			if ( Driver != None )
			{
				Driver.Health = 0;
				Driver.Died( self, class'Suicided', Driver.Location );
			}
		}
		else
		{
			Pawn.Health = 0;
			Pawn.Died( self, class'Suicided', Pawn.Location );
		}
	}

	super.Destroyed();
}

/* MayDodgeToMoveTarget()
called when starting MoveToGoal(), based on DodgeToGoalPct
Know have CurrentPath, with end lower than start
*/
// Overriden because we dont subclass UnrealPawn
event MayDodgeToMoveTarget()
{
	return;
}

// Overriden because we dont subclass UnrealPawn so we need to remove double click stuff
function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent, Start;
	local actor HitActor;
	local bool bSuccess, bDuckLeft, bWallHit, bChangeStrafe;
	local float MinDist,Dist;

	if ( Vehicle(Pawn) != None )
		return Pawn.Dodge(DCLICK_None);
	if ( Pawn.bStationary )
		return false;
	if ( Stopped() && (Pawn.MaxRotation == 0) )
		GotoState('TacticalMove');
	else if ( FRand() < 0.6 )
		bChangeStrafe = IsStrafing();


	if ( (Skill < 3) || Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Falling)
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;
	if ( Pawn.bIsCrouched || Pawn.bWantsToCrouch || (Pawn.Physics != PHYS_Walking) )
		return false;

	duckDir.Z = 0;
	duckDir *= 335;
	bDuckLeft = bReversed;
	Extent = Pawn.GetCollisionExtent();
	Start = Pawn.Location + vect(0,0,25);
	HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);

	MinDist = 150;
	Dist = VSize(HitLocation - Pawn.Location);
	if ( (HitActor == None) || ( Dist > 150) )
	{
		if ( HitActor == None )
			HitLocation = Start + duckDir;

		HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
		bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
	}
	else
	{
		bWallHit = Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 5);
		MinDist = 30 + MinDist - Dist;
	}

	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > MinDist) );
		if ( bSuccess )
		{
			if ( HitActor == None )
				HitLocation = Start + duckDir;

			HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
			bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
		}
	}
	if ( !bSuccess )
	{
		if ( bChangeStrafe )
			ChangeStrafe();
		return false;
	}

	if ( Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 3 + 3*FRand()) )
		bNotifyFallingHitWall = true;

	bInDodgeMove = true;
	DodgeLandZ = Pawn.Location.Z;
	return true;
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype, optional Pawn soundSender, optional vector senderLocation)
{
	local Controller P;
	local ROPlayer ROP;

	if ( (Recipient == None) && !AllowVoiceMessage(MessageType) )
		return;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
	    ROP = ROPlayer(P);
		if ( ROP != None )
		{
			if ((ROP.PlayerReplicationInfo == Sender) ||
				(ROP.PlayerReplicationInfo == Recipient &&
				 (Level.Game.BroadcastHandler == None ||
				  Level.Game.BroadcastHandler.AcceptBroadcastSpeech(ROP, Sender)))
				)
				ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype, messageID, soundSender, senderLocation);
			else if ( (Recipient == None) || (Level.NetMode == NM_Standalone) )
			{
				//if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame || (Sender.Team == P.PlayerReplicationInfo.Team) )
					if ( Level.Game.BroadcastHandler == None || Level.Game.BroadcastHandler.AcceptBroadcastSpeech(ROP, Sender) )
						ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype, messageID, soundSender, senderLocation);
			}
		}
		else if ( (messagetype == 'ORDER') && ((Recipient == None) || (Recipient == P.PlayerReplicationInfo)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}

function AvoidThisVehicle(ROVehicle Feared)
{
	if ( Vehicle(Pawn) != None )
		return;
	GoalString = "VEHICLE AVOID!";
	AvoidVehicle = Feared;
	GotoState('VehicleAvoid');
}

// State for being startled by something, the bot attempts to move away from it
state VehicleAvoid
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function AvoidThisVehicle(ROVehicle Feared)
	{
		GoalString = "AVOID VEHICLE!";
		// Switch to the new guy if he is closer
		if (VSizeSquared(Pawn.Location - Feared.Location) < VSizeSquared(Pawn.Location - AvoidVehicle.Location))
		{
			AvoidVehicle = Feared;
			BeginState();
		}
	}

	function BeginState()
	{
		SetTimer(0.4,true);
	}

	event Timer()
	{
		local vector dir, side;
		local float dist;

		if (Vehicle(Pawn) != None || AvoidVehicle == None || AvoidVehicle.Velocity dot (Pawn.Location - AvoidVehicle.Location) < 0)
		{
			WhatToDoNext(11);
			return;
		}
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = False;
		dir = Pawn.Location - AvoidVehicle.Location;
		dist = VSize(dir);
		if (dist <= AvoidVehicle.CollisionRadius*NearMult)
			HitTheDirt();
		else if (dist < AvoidVehicle.CollisionRadius*FarMult)
		{
			side = dir cross vect(0,0,1);
			// pick the shortest direction to move to
			if (side dot AvoidVehicle.Velocity > 0)
				Destination = Pawn.Location + (-Normal(side) * (AvoidVehicle.CollisionRadius*FarMult));
			else
				Destination = Pawn.Location + (Normal(side) * AvoidVehicle.CollisionRadius*FarMult);

			GoalString = "AVOID VEHICLE!   Moving my arse..";
		}
	}

	function HitTheDirt()
	{
		local vector dir, side;

		GoalString = "AVOID VEHICLE!   Jumping!!!";
		dir = Pawn.Location - AvoidVehicle.Location;
		side = dir cross vect(0,0,1);
		Pawn.Velocity = Pawn.AccelRate * Normal(side);
		// jump the other way if its shorter
		if (side dot AvoidVehicle.Velocity > 0)
			Pawn.Velocity = -Pawn.Velocity;
		Pawn.Velocity.Z = Pawn.JumpZ;
		bPlannedJump=True;
		Pawn.SetPhysics(PHYS_Falling);
		// yell at the jerk if he's "friendly"
		if (Level.TimeSeconds > LastFriendlyFireYellTime+2 && AvoidVehicle != None && GetTeamNum() == AvoidVehicle.GetTeamNum())
		{
			LastFriendlyFireYellTime = Level.TimeSeconds;
			YellAt(AvoidVehicle);
		}
	}

	function EndState()
	{
		bTimerLoop = False;
		AvoidVehicle=None;
		Focus=None;
	}

Begin:
	WaitForLanding();
	MoveTo(Destination,AvoidVehicle,False);
	if (AvoidVehicle == None || VSize(Pawn.Location - AvoidVehicle.Location) > AvoidVehicle.CollisionRadius*FarMult || AvoidVehicle.Velocity dot (Pawn.Location - AvoidVehicle.Location) < 0)
	{
		WhatToDoNext(11);
		warn("!! " @ Pawn.GetHumanReadableName() @ " STUCK IN AVOID VEHICLE !!");
		GoalString = "!! STUCK IN AVOID VEHICLE !!";
	}
	Sleep(0.2);
	GoTo('Begin');

}

function CheckVehicleRoute()
{
	local actor HitActor;
	local VehicleAvoidArea VA;
	local vector HitLocation, HitNormal, Dir;
	local float dist;

	if( Vehicle(Pawn) != none)
	{
		Dir = vector(Pawn.Rotation);
	//	DrawDebugLine( Pawn.Location, Pawn.Location + Dir*1500.0f, 0, 0, 255 );
   	    HitActor = Trace(HitLocation, HitNormal, Pawn.Location + Dir*1500.0f, Pawn.Location, true);

        if ( HitActor != None && HitActor.bWorldGeometry && VSize(HitLocation - Pawn.Location) < 200)
        {
                GotoState('VehicleReroute','Backup');
                return;
        }
		if ( Vehicle(HitActor) != None /*&& VSizeSquared(Pawn.Velocity - HitActor.Velocity) > 0*/
				&& (HitActor != LastDodgeActor || (Level.TimeSeconds - LastDodgeTime) > RepeatDodgeFrequency))
   	    {
				DodgeActor = HitActor;
				dist = VSize(DodgeActor.Location - Pawn.Location);
				Goalstring = "Avoiding vehicle.";
				if (dist > Pawn.CollisionRadius * NearMult)
					GotoState('VehicleReroute');
				else
					GotoState('VehicleReroute','Backup');
		}
		else
		{
			foreach Pawn.TouchingActors(class'VehicleAvoidArea', VA)
			{
				 if( VA.Vehicle != LastDodgeActor || (Level.TimeSeconds - LastDodgeTime) > RepeatDodgeFrequency )
				 {
					Dir = VA.Vehicle.Location - Pawn.Location;
					dist = VSize(Dir);
					//  in front of me
					if(  vector(Pawn.Rotation) dot Normal(dir) > 0.7)
					{
						GoalString = "Avoiding vehicle.";
						// were moving
						if (VSizeSquared(Pawn.Velocity) > 4 )
						{
							if ( VSizeSquared(VA.Vehicle.Velocity) < 100		// other isnt moving
							 || ( Dir dot VA.Vehicle.Velocity < 0	// moving in same direction
							&& VSizeSquared(Pawn.Velocity - VA.Vehicle.Velocity) > 400) // moving faster than other
										)
							{
								DodgeActor = VA.Vehicle;
								GotoState('VehicleReroute');
							}
						}
						// were not moving
						else
						{
							DodgeActor = VA.Vehicle;
							// not stuck on other
							if (dist > Pawn.CollisionRadius * NearMult)
							{
								GotoState('VehicleReroute');
							}
							// backup
							else
								GotoState('VehicleReroute','Backup');
						}
						break;
					}
				 }
			}
		}
	}
}

// State for bot vehicle drivers to avoid other pawns
state VehicleReroute
{
	ignores EnemyNotVisible,SeePlayer,HearNoise,CheckVehicleRoute;

	function vector Reroute()
	{
		local vector dir, side, newdest, newdir, HitLocation;
		local float dist;

		dir = DodgeActor.Location - Pawn.Location;
		dist = VSize(dir);
		// Too close/stuck on another vehicle - back up first.
		if( dist < 200.0f ) {
		    return BackItUp();
		}
		side = normal(dir cross vect(0,0,1));

		if (VSizeSquared(DodgeActor.Velocity) > 4)
			if ( side dot DodgeActor.Velocity > 0 )
				side = -side;
		else if ((vect(0,1,0) >> Pawn.Rotation) dot dir > 0)
				side = -side;

		// DodgeActor not moving, route around as such
		if(dist > 2500)
			newdir = dir + side*DodgeActor.CollisionRadius;
	    else if(dist > 1000)
	    	newdir = dir*0.75f + side*DodgeActor.CollisionRadius*NearMult;
	    else
	    	newdir = dir*0.25f + side*DodgeActor.CollisionRadius*FarMult;
		newdest = Pawn.Location + newdir;

	   // collision detect
	   HitLocation = newdest;
	   if(RerouteCollisionDetect(HitLocation))
	   {
			newdir = HitLocation - Pawn.Location;
			newdest = Pawn.Location + 0.75*newdir;
	   }

	   LastDodgeActor = DodgeActor;
	   LastDodgeTime = Level.TimeSeconds;
	   DodgeActor = none;
	   GoalString = "Rerouting around other vehicle.";
	   return newdest;
	}

	// Collision detection for rerouting.
	// True if pawn is going to hit World Geometry, false if not
	function bool RerouteCollisionDetect(out vector dest) {
		local actor HitActor;
		local vector HitLocation, HitNormal;

		HitActor = Trace(HitLocation, HitNormal, dest, Pawn.Location, false);
		if( HitActor != None && HitActor.bWorldGeometry)
		{
			dest = HitLocation;
			return True;
		}
		return False;
	}

	function vector BackItUp()
	{
		LastDodgeActor = DodgeActor;
		LastDodgeTime = Level.TimeSeconds;
		DodgeActor = none;

		return Pawn.Location +  (-250*vector(Pawn.Rotation));
	}

Begin:

	Destination = Reroute();
	//log("Successfully rerouted vehicle."@GetHumanReadableName());
	if( RerouteCollisionDetect(Destination))
	{
        Destination = Pawn.Location + Destination;
		if( vsize(Pawn.Location - Destination) < 250.0f )
		{
	    	//log(Pawn.GetHumanReadableName()$" too close to levelinfo, need to back up a bit.");
			MoveTo(BackItUp());
		}
		MoveTo(RouteCache[0].Location);
	}
	else
		MoveTo(Destination);

	LastDodgeActor = none;
	WhatToDoNext(51);
	GoTo('Stuck');

Backup:
	MoveTo(BackItUp());
	WhatToDoNext(50);

Stuck:
	if ( bSoaking )
		SoakStop("STUCK IN VEHICLE AVOID!!");
	GoalString = "STUCK IN VEHICLE AVOID!!";

}

state WaitForCrew
{
	function BeginState()
	{
		ROWheeledVehicle(Pawn).bDisableThrottle = True;
		CachedMoveTimer = MoveTimer;
	}
Begin:
	Sleep(0.2);
	if (ROWheeledVehicle(Pawn).CheckForCrew() || !ROSquadAI(Squad).ShouldWaitForCrew(self))
	{
		ROWheeledVehicle(Pawn).bDisableThrottle = False;
		MoveTimer = CachedMoveTimer;
		// go back to the function that got us here..
		WhatToDoNext(53);
	}
	GoTo('Begin');
}

function VehicleFightEnemy(bool bCanCharge, float EnemyStrength)
{
	if ( Pawn.bStationary || Vehicle(Pawn).bKeyVehicle )
	{
		if ( !EnemyVisible() )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
			DoRangedAttackOn(Enemy);
		return;
	}
	if ( !bFrustrated && Pawn.HasWeapon() && Pawn.TooCloseToAttack(Enemy) )
	{
		GoalString = "Retreat";
		if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
			SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
		DoRetreat();
		return;
	}
	if ( ((Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime)) || Vehicle(Pawn).bKeyVehicle )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( Pawn.HasWeapon() && EnemyVisible() )
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp(true);
		return;
	}
	if ( !EnemyVisible() )
	{
		if ( Squad.MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		GoalString = "Enemy not visible";
		if ( !bCanCharge || (Squad.IsDefending(self) && LostContact(4)) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else if ( ((Aggression < 1) && !LostContact(3+2*FRand()) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	BlockedPath = None;
	Target = Enemy;
	if ( Pawn.bCanFly && !Enemy.bCanFly && (FRand() < 0.17 * (skill + Tactics - 1)) )
	{
		GoalString = "Do tactical move";
		DoTacticalMove();
		return;
	}

//	if ( Pawn.RecommendLongRangedAttack() )
//	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
//	}
//
//	GoalString = "Charge";
//   AssignSquadResponsibility();
}
function SetAttractionState()
{
   local int i;

	if ( Enemy != None )
	{
	   if(ROVehicle(Pawn) != none)
	   {
		   for(i=0; i < ROVehicle(Pawn).WeaponPawns.Length; i++)
		   {
		      if(ROVehicle(Pawn).WeaponPawns[i] == none)
		          break;
		      if(ROVehicleWeaponPawn(ROVehicle(Pawn).WeaponPawns[i]).Driver == none)
		      {
			   if(ROVehicle(Pawn).WeaponPawns[i].isA('ROTankCannonPawn'))
			   {
				  ChooseAttackMode();
				  return;
			   }
			}
		 }
	   }
		GotoState('FallBack');
	}
	else
		GotoState('Roaming');
}

defaultproperties
{
     DesiredRole=-1
     CurrentRole=-1
     PrimaryWeapon=-1
     SecondaryWeapon=-1
     GrenadeWeapon=-1
     NearMult=1.500000
     FarMult=3.000000
     RepeatDodgeFrequency=3.000000
     OrderNames(0)="Attack"
     OrderNames(1)="Defend"
     OrderNames(2)="HOLD"
     OrderNames(5)="Defend"
     OrderNames(6)="Attack"
     OrderNames(7)="HOLD"
     PlayerReplicationInfoClass=Class'ROEngine.ROPlayerReplicationInfo'
     PawnClass=Class'ROEngine.ROPawn'
}
