//===================================================================
// ROSquadAI
//
// Copyright (C) 2005 John "Ramm-Jaeger"  Gibson
//
// Custom squad base AI for Red Orchestra
//===================================================================
class ROSquadAI extends SquadAI;

var bool bTankSquad;

// Don't let the bots hop out while we the bot driver is waiting for more crew members
function bool NeverBail(Pawn P)
{
	if( ROWheeledVehicle(P) != none && ROWheeledVehicle(P).bDisableThrottle || (VehicleWeaponPawn(P) != none &&
		ROWheeledVehicle(VehicleWeaponPawn(P).GetVehicleBase()) != none &&  ROWheeledVehicle(VehicleWeaponPawn(P).GetVehicleBase()).bDisableThrottle ))
		return true;

	return ( (Vehicle(P) != None) && Vehicle(P).bKeyVehicle );
}

//return a value indicating how useful this vehicle is to the bot
function float VehicleDesireability(Vehicle V, Bot B)
{
	local float result;

	if ( !V.bCanCarryFlag && (B.PlayerReplicationInfo.HasFlag != None) )
		return 0;
//	if ((CurrentOrders == 'Defend') != V.bDefensive)
//		return 0;
	if (V.Health < V.HealthMax * 0.125 && B.Enemy != None && B.EnemyVisible())
		return 0;
	result = V.BotDesireability(Self, Team.TeamIndex, SquadObjective);
	if ( V.SpokenFor(B) )
		return result * V.NewReservationCostMultiplier(B.Pawn);
	return result;
}

function bool ShouldWaitForCrew(Bot B)
{
	local Bot M;

	for (M=SquadMembers;M!=None;M=M.NextSquadMember)
	{
		if (M != B && Vehicle(M.RouteGoal) != None && VehicleWeaponPawn(M.Pawn) == None && B.Pawn == Vehicle(M.RouteGoal).GetVehicleBase())
		{
			//log("vehicle match");
			if (VSize(B.Pawn.Location - M.Pawn.Location) <= MaxVehicleDist(M.Pawn))
			{
			//	log("dist match");
				return true;
			}
		}
	}
	return false;
}

function bool AssignSquadResponsibility(Bot B)
{
	// set new defense script
	if ( (GetOrders() == 'Defend') && !B.Pawn.bStationary )
		SetDefenseScriptFor(B);
	else if ( (B.GoalScript != None) && (HoldSpot(B.GoalScript) == None) )
		B.FreeScript();

	AssignCombo(B);

	if ( bAddTransientCosts )
		AddTransientCosts(B,1);

	// check for crew wanting a ride
	if (ROWheeledVehicle(B.Pawn) != None && ShouldWaitForCrew(B))
	{
		B.GoToState('WaitForCrew');
		return true;
	}

	// check for major game objective responsibility
	if ( CheckSquadObjectives(B) )
		return true;

	if ( B.Enemy == None && !B.Pawn.bStationary )
	{
		// suggest inventory hunt
		// FIXME - don't load up on unnecessary ammo in DM
		if ( B.FindInventoryGoal(0) )
		{
			B.SetAttractionState();
			return true;
		}

		// roam around level?
		if ( ((B == SquadLeader) && bRoamingSquad) || (GetOrders() == 'Freelance') )
			return B.FindRoamDest();
	}
	return false;
}

function float BotSuitability(Bot B)
{
	if ( class<ROPawn>(B.PawnClass) == None )
		return 0;

	if ( GetOrders() == 'Defend' )
		return (1.0 - class<ROPawn>(B.PawnClass).Default.AttackSuitability);
	return class<ROPawn>(B.PawnClass).Default.AttackSuitability;
}

// Overriden to support our objective system
function actor FormationCenter()
{
	if ( (SquadObjective != None) && (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) )
		return SquadObjective;
	return SquadLeader.Pawn;
}

/* GetFacingRotation()
return the direction the squad is moving towards its objective
// Overriden to support our objective system
*/
function rotator GetFacingRotation()
{
	local rotator Rot;
	// FIXME - use path to objective, rather than just direction

	if ( SquadObjective == None )
		Rot = SquadLeader.Rotation;
	else if ( (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) )
		Rot.Yaw = Rand(65536);
	else if ( SquadLeader.Pawn != None )
		Rot = rotator(SquadObjective.Location - SquadLeader.Pawn.Location);
	else
		Rot.Yaw = Rand(65536);

	Rot.Pitch = 0;
	Rot.Roll = 0;
	return Rot;
}

// Overriden to support our objective system
function SetObjective(GameObjective O, bool bForceUpdate)
{
	local bot M;

	//Log(SquadLeader.PlayerReplicationInfo.PlayerName$" SET OBJECTIVE"@O@"Forced update"@bForceUpdate);
	if ( SquadObjective == O )
	{
		if ( SquadObjective == None )
			return;

		if( (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) &&
			(SquadObjective.DefenseSquad == None) )
		{
			 SquadObjective.DefenseSquad = self;
		}

		if ( !bForceUpdate )
			return;
	}
	else
	{
		if( (SquadObjective != None) && (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) &&
			(SquadObjective.DefenseSquad == self))
		{
			 SquadObjective.DefenseSquad = None;
		}


		NetUpdateTime = Level.Timeseconds - 1;
		SquadObjective = O;
		if ( SquadObjective != None )
		{
			if( (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) &&
				(SquadObjective.DefenseSquad == None) )
			{
				 SquadObjective.DefenseSquad = self;
			}

			SetAlternatePath(true);
		}
	}
	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( M.Pawn != None )
			Retask(M);
}


// Added this code to fix an endless loop. Later try and find out why the endless loop
// got created in the first place.
function SetFreelanceScriptFor(Bot B)
{
	local UnrealScriptedSequence S;
	local int i;
	local		array<UnrealScriptedSequence>			Sequences;

	// possibly stay with same defense point if right on it
	if ( (B.GoalScript != None)	&& !B.GoalScript.bRoamingScript
		&& (B.GoalScript.bDontChangeScripts || ((FRand() < 0.8)	&& B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget()))) )
		return;

	if ( B.GoalScript != None )
	{
		B.GoalScript.bAvoid = true;
		B.FreeScript();
	}
	// find a freelance script
	if ( FreelanceScripts == None )
		ForEach AllActors(class'UnrealScriptedSequence',S)
			if ( S.bFreelance && S.bFirstScript )
			{
				FreelanceScripts = S;
				break;
			}

	if( FreelanceScripts != none )
	{
		foreach AllActors(class'UnrealScriptedSequence',S,FreelanceScripts.Tag)
		{
			Sequences[Sequences.Length] = S;
		}
	}

	// replaced the original epic code because it gets caught in an endless loop
	// for some reason
	for ( i=0; i<Sequences.Length ; i++ )
	{
		if ( Sequences[i].HigherPriorityThan(B.GoalScript, B) )
			B.GoalScript = Sequences[i];
	}

	if ( B.GoalScript != None )
		B.GoalScript.CurrentUser = B;
}


//don't actually merge squads, because they could be two defending squads from different teams going to same neutral powernode
function MergeWith(SquadAI S)
{
	if ( SquadObjective != S.SquadObjective )
	{
		SquadObjective = S.SquadObjective;
		NetUpdateTime = Level.Timeseconds - 1;
	}
}

// Overriden so defending bots will attack recapturable objectives
function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
	else if ( SquadObjective != none && (ROObjective(SquadObjective).bActive) && (ROObjective(SquadObjective).ObjState == Team.TeamIndex) )
			NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
	{
		NetUpdateTime = Level.Timeseconds - 1;
		CurrentOrders = NewOrders;
	}
	return CurrentOrders;
}


// Overriden to handle ROObjectives. Overrides SquadAI::TellBotToFollow()
function bool TellBotToFollow(Bot B, Controller C)
{
	local Pawn Leader;
	local GameObjective O, Best;
	local float NewDist, BestDist;

	if ( (C == None) || C.bDeleteMe )
	{
		PickNewLeader();
		C = SquadLeader;
	}

	if ( B == C )
		return false;

	B.GoalString = "Follow Leader";
	Leader = C.Pawn;
	if ( Leader == None )
		return false;

	if ( CloseToLeader(B.Pawn) )
	{
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
		  	B.SendMessage(SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
		}
		if ( B.Enemy == None )
		{
			// look for destroyable objective
			for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
			{
				if ( !O.bDisabled && (DestroyableObjective(O) != None)
					&& ((Best == None) || (ROObjective(O).IsHigherPriority(Best, Team.TeamIndex))/*(Best.DefensePriority < O.DefensePriority)*/) )
				{
					NewDist = VSize(B.Pawn.Location - O.Location);
					if ( ((Best == None) || (NewDist < BestDist)) && B.LineOfSightTo(O) )
					{
						Best = O;
						BestDist = NewDist;
					}
				}
			}
			if ( Best != None )
			{
				if (Best.DefenderTeamIndex != Team.TeamIndex)
				{
					if (Best.TellBotHowToDisable(B))
						return true;
				}
				else if (BestDist < 1600 && DestroyableObjective(Best).TellBotHowToHeal(B))
				return true;
			}

			if ( B.FindInventoryGoal(0.0004) )
			{
				B.SetAttractionState();
				return true;
			}
			B.WanderOrCamp(true);
			return true;
		}
		else if ( (B.Pawn.Weapon != None) && B.Pawn.Weapon.FocusOnLeader(false) )
		{
			B.FightEnemy(false,0);
			return true;
		}
		return false;
	}
	else if ( B.SetRouteToGoal(Leader) )
		return true;
	else
	{
		B.GoalString = "Can't reach leader";
		return False;
	}
}

function bool FindNewEnemyFor(Bot B, bool bSeeEnemy)
{
	local int i;
	local Pawn BestEnemy, OldEnemy;
	local bool bSeeNew;
	local float BestThreat,NewThreat;

	if ( B.Pawn == None )
		return true;
	if ( (B.Enemy != None) && MustKeepEnemy(B.Enemy) && B.EnemyVisible() )
		return false;

	BestEnemy = B.Enemy;
	OldEnemy = B.Enemy;
	if ( BestEnemy != None )
	{
		if ( (BestEnemy.Health < 0) || (BestEnemy.Controller == None) )
		{
			B.Enemy = None;
			BestEnemy = None;
		}
		else
		{
			BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
			if ( BestThreat > 2 )
				return false;
		}
	}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		if ( (Enemies[i] != None) && (Enemies[i].Health > 0) && (Enemies[i].Controller != None) )
		{
			if ( BestEnemy == None )
			{
				BestEnemy = Enemies[i];
				bSeeEnemy = B.CanSee(Enemies[i]);
				BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
			}
			else if ( Enemies[i] != BestEnemy )
			{
				if ( VSize(Enemies[i].Location - B.Pawn.Location) < 1500 )
					bSeeNew = B.LineOfSightTo(Enemies[i]);
				else
					bSeeNew = B.CanSee(Enemies[i]);	// only if looking at him
				NewThreat = AssessThreat(B,Enemies[i],bSeeNew);
				if ( NewThreat > BestThreat )
				{
					BestEnemy = Enemies[i];
					BestThreat = NewThreat;
					bSeeEnemy = bSeeNew;
				}
			}
		}
		else
			Enemies[i] = None;
	}
	// minimum threat level to aquire a target, pulled out of my ass
	if (BestThreat < 0)
		return False;
	B.Enemy = BestEnemy;
	if ( (B.Enemy != OldEnemy) && (B.Enemy != None) )
	{
		B.EnemyChanged(bSeeEnemy);
		return true;
	}
	return false;
}

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue, NewStrength, Dist;

	NewStrength = B.RelativeStrength(NewThreat);
	ThreatValue = FClamp(NewStrength, 0, 1);
	Dist = VSize(NewThreat.Location - B.Pawn.Location);
	if ( Dist < 2000 )
	{
		ThreatValue += 0.2;
		if ( Dist < 1500 )
			ThreatValue += 0.2;
		if ( Dist < 1000 )
			ThreatValue += 0.2;
		if ( Dist < 500 )
			ThreatValue += 0.2;
	}

	if ( bThreatVisible )
		ThreatValue += 0.5;
	if ( (NewThreat != B.Enemy) && (B.Enemy != None) )
	{
		// moved this to ModifyThreat
//		if ( !bThreatVisible )
//			ThreatValue -= 2;
/*else */if (bThreatVisible && Level.TimeSeconds - B.LastSeenTime > 2 )
			ThreatValue += 1;
		if ( Dist > 0.7 * VSize(B.Enemy.Location - B.Pawn.Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( B.IsHunting() && (NewStrength < 0.2)
			&& (Level.TimeSeconds - FMax(B.LastSeenTime,B.AcquireTime) < 2.5) )
			ThreatValue -= 0.3;
	}

	ThreatValue = ModifyThreat(ThreatValue,NewThreat,bThreatVisible,B);
	if ( NewThreat.IsHumanControlled() )
			ThreatValue += 0.25;

//	log(B.GetHumanReadableName()$" assess threat "$ThreatValue$" for "$NewThreat.GetHumanReadableName());
	return ThreatValue;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	if (bThreatVisible)
		return B.Pawn.ModifyThreat(current,NewThreat);
	return current - 2;
}

function bool CheckVehicle(Bot B)
{
	local Actor BestPath, BestEntry;
	local Vehicle SquadVehicle, V, MainVehicle;
	local float NewDist, BestDist, NewRating, BestRating, BaseRadius;
	local Bot S;
	local PlayerController PC;
	local bool bSkip;

	if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.RouteGoal) != None) && (NavigationPoint(B.Movetarget) != None) )
	{
		if ( VSize(B.Pawn.Location - B.RouteGoal.Location) < B.Pawn.CollisionRadius + Vehicle(B.RouteGoal).EntryRadius * 1.5 )
			B.MoveTarget = B.RouteGoal;
	}
	if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.MoveTarget) != None) )
	{
		if ( Vehicle(B.MoveTarget).PlayerStartTime > Level.TimeSeconds )
		{
			PC = Level.GetLocalPlayerController();
			bSkip = ( (PC != None) && (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && (Vehicle(PC.Pawn) == None) );
		}
		if ( !bSkip )
			V = Vehicle(B.MoveTarget).FindEntryVehicle(B.Pawn);
		if ( V != None )
		{
			//consider healing vehicle before getting in
			if ( !V.bKeyVehicle && (V.Health < V.HealthMax) && (B.Enemy == None || !B.EnemyVisible()) && B.CanAttack(V) )
			{
				//get in and out to steal vehicle for team so bot can heal it
				if (V.GetTeamNum() != Team.TeamIndex)
				{
					V.UsedBy(B.Pawn);
					V.KDriverLeave(false);
				}

				if (V.TeamLink(Team.TeamIndex))
				{
					if (B.Pawn.Weapon != None && B.Pawn.Weapon.CanHeal(V))
					{
						B.GoalString = "Heal "$V;
						B.DoRangedAttackOn(V.GetAimTarget());
						return true;
					}
					else
					{
						B.SwitchToBestWeapon();
						if (B.Pawn.PendingWeapon != None && B.Pawn.PendingWeapon.CanHeal(V))
						{
							B.GoalString = "Heal "$V;
							B.DoRangedAttackOn(V.GetAimTarget());
							return true;
						}
					}
				}
			}
			if ( V.GetVehicleBase() != None )
				BaseRadius = V.GetVehicleBase().CollisionRadius;
			else
				BaseRadius = V.CollisionRadius;
			if ( VSize(B.Pawn.Location - V.Location) < B.Pawn.CollisionRadius + BaseRadius + V.EntryRadius )
			{
				V.UsedBy(B.Pawn);
				if ( Vehicle(B.Pawn) != None )
					BotEnteredVehicle(B);
				return false;
			}
		}
	}
	if ( B.LastSearchTime == Level.TimeSeconds )
		return false;

	if ( Vehicle(B.Pawn) != None )
	{
		if ( !NeverBail(B.Pawn) )
		{
			if ( Vehicle(B.Pawn).StuckCount > 3 )
			{
				// vehicle is stuck
				Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 20;
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
			else if ( (B.Pawn.Health < B.Pawn.HealthMax*0.125) && !B.Pawn.bStationary && (B.Skill + B.Tactics > 4 + 7 * FRand()) )
			{
				//about to blow up, bail
				Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 10;
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
		}

		V = B.Pawn.GetVehicleBase();
		if ( (V != None) && !V.bKeyVehicle && B.GetStateName() != 'RangedAttack')
		{
			// if in passenger seat of a multi-person vehicle, get out if no driver
			if ( V.Driver == None && (SquadLeader == B || SquadLeader.RouteGoal == None
			     || (SquadLeader.RouteGoal != V && !SquadLeader.RouteGoal.IsJoinedTo(V))) )
			{
				Vehicle(B.Pawn).KDriverLeave(false);
				return false;
			}
		}

		if (!B.Pawn.bStationary && PriorityObjective(B) == 0)
			return CheckSpecialVehicleObjectives(B);

		return false;
	}
	if (SpecialVehicleObjective(B.RouteGoal) != None && CheckSpecialVehicleObjectives(B))
		return true;

	if ( (Vehicle(SquadLeader.Pawn) != None) && (VSize(SquadLeader.Pawn.Location - B.Pawn.Location) < 4000) )
	{
		SquadVehicle = Vehicle(SquadLeader.Pawn).OpenPositionFor(B.Pawn);
		if ( SquadVehicle != None )
			MainVehicle = Vehicle(SquadLeader.Pawn);
	}
	else if ( PlayerController(SquadLeader) != None )
		return false;

	BestDist = MaxVehicleDist(B.Pawn);
	if ( SquadVehicle == None )
	{
		for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
			if ( (Vehicle(S.Pawn) != None) && (VSize(S.Pawn.Location - B.Pawn.Location) < BestDist) )
			{
				SquadVehicle = Vehicle(S.Pawn).OpenPositionFor(B.Pawn);
				if ( SquadVehicle != None )
					break;
			}
	}

	if ( (SquadVehicle == None) && (Vehicle(SquadLeader.RouteGoal) != None) && !Vehicle(SquadLeader.RouteGoal).Occupied()
	     && Vehicle(SquadLeader.Routegoal).IndependentVehicle() && VSize(SquadLeader.RouteGoal.Location - B.Pawn.Location) < BestDist )
		SquadVehicle = Vehicle(SquadLeader.RouteGoal).OpenPositionFor(B.Pawn);

	if ( (SquadVehicle == None) && (Vehicle(B.RouteGoal) != None) && !Vehicle(B.RouteGoal).Occupied() && Vehicle(B.RouteGoal).IndependentVehicle()
		&& !Vehicle(B.RouteGoal).ChangedReservation(B.Pawn) )
		SquadVehicle = vehicle(B.RouteGoal);

	if ( (SquadVehicle != None) && (SquadVehicle.PlayerStartTime > Level.TimeSeconds) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC != None) && (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && (Vehicle(PC.Pawn) == None) )
			SquadVehicle = None;
	}

	if ( SquadVehicle == None )
	{
		// look for nearby vehicle
		GetOrders();
		for ( V=Level.Game.VehicleList; V!=None; V=V.NextVehicle )
		{
			NewDist = VSize(B.Pawn.Location - V.Location);
			if (NewDist < BestDist)
			{
				NewRating = VehicleDesireability(V, B);
				if (NewRating > 0)
				{
					NewRating += BestDist / NewDist * 0.01;
					if ( NewRating > BestRating && ( V.bTeamLocked || V.StronglyRecommended(Self, Team.TeamIndex, SquadObjective)
									 || V.FastTrace(V.Location, B.Pawn.Location + B.Pawn.CollisionHeight * vect(0,0,1)) ) )
					{
						SquadVehicle = V;
						BestRating = NewRating;
					}
				}
			}
		}
	}

	if ( SquadVehicle == None )
		return false;

	BestEntry = SquadVehicle.GetMoveTargetFor(B.Pawn);

	if ( B.Pawn.ReachedDestination(BestEntry) )
	{
		SquadVehicle.UsedBy(B.Pawn);
		return False;
	}

	if ( B.ActorReachable(BestEntry) )
	{
		B.RouteGoal = SquadVehicle;
		B.MoveTarget = BestEntry;
		SquadVehicle.SetReservation(B);
		B.GoalString = "Go to vehicle 1 "$BestEntry;
		B.SetAttractionState();
		return true;
	}

	BestPath = B.FindPathToward(BestEntry,B.Pawn.bCanPickupInventory && (Vehicle(B.Pawn) == None));
	if ( BestPath != None )
	{
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestPath;
		B.GoalString = "Go to vehicle 2 "$BestPath;
		B.SetAttractionState();
		return true;
	}

	if ( (VSize(BestEntry.Location - B.Pawn.Location) < 1200)
		&& B.LineOfSightTo(BestEntry) )
	{
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestEntry;
		B.GoalString = "Go to vehicle 3 "$BestEntry;
		B.SetAttractionState();
		return true;
	}
	return false;
}

function byte PriorityObjective(Bot B)
{
	return 2;
}

function bool WaitAtThisPosition(Pawn P)
{
	return false;
}

defaultproperties
{
     MaxSquadSize=3
     bRoamingSquad=False
}
