//===================================================================
// ROTeamAI
//
// Copyright (C) 2005 John "Ramm-Jaeger"  Gibson
//
// Custom Team AI for Red Orchestra
//===================================================================
class ROTeamAI extends TeamAI;

//Jonathan@psyonix.com
//This is called when the map is loaded and should setup all the info the team
//should know about the objectives.
function SetObjectiveLists()
{
	local ROObjective O;

	foreach AllActors(class'ROObjective',O)
	{
		if ( O.bFirstObjective )
			Objectives = O;
	}
}

/*
SetBotOrders - based on RosterEntry recommendations
Just calls the Super for now. Add code here if we want to change the way
attack/defend/freelance squads are set up - Ramm
*/
function SetBotOrders(Bot NewBot, RosterEntry R)
{
	if ( Objectives == None )
		SetObjectiveLists();

	// pick orders
	if ( Team.Size == 0 )
		OrderOffset = 0;

   DefendHere(NewBot, GetLeastDefendedObjective());
}

function bool DefendHere(Bot B, GameObjective O)
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
	{
	   if(S.SquadObjective == O && (S.Size < S.MaxSquadSize))
	   {
		   S.AddBot(B);
		   return true;
	   }
   }

   if (O.DefenderTeamIndex == Team.TeamIndex)
	  O.DefenseSquad = AddSquadWithLeader(B, O);
   else
	  AddSquadWithLeader(B, O);
   return true;
}

function bool PutOnDefense(Bot B)
{
	local GameObjective O;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		//we need this because in RO, unlike other gametypes, two defending squads (possibly from different teams!)
		//could be headed to the same objective
		if ( O.DefenseSquad == None || O.DefenseSquad.Team != Team )
		{
			O.DefenseSquad = AddSquadWithLeader(B, O);
// MergeTODO: Investigate this
			//ONSSquadAI(O.DefenseSquad).bDefendingSquad = true;
		}
		else
			O.DefenseSquad.AddBot(B);
		return true;
	}
	return false;
}

// Modified so when the round resets bots will get objectives again
function FindNewObjectives(GameObjective DisabledObjective)
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
	{
		if ( S.SquadObjective == DisabledObjective || S.SquadObjective == none )
		{
			FindNewObjectiveFor(S,true);
		}
	}
}

// This will force all squads on this team to switch to this objective.
function SetAllSquadObjectivesTo(int NewObjective)
{
	local GameObjective O;
	local SquadAI S;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if( ROObjective(O).ObjNum == NewObjective)
		{
			for ( S=Squads; S!=None; S=S.NextSquad )
			{
				S.SetObjective(O, true);
			}
		}
	}
}

function SetSquadObjectivesTo(int NewObjective, PlayerReplicationInfo SquadLeader)
{
	local GameObjective O;
	local SquadAI S;

	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if (ROObjective(O).ObjNum == NewObjective)
		{
			for (S=Squads; S!=None; S=S.NextSquad)
			{
				if (S.LeaderPRI == SquadLeader)
					S.SetObjective(O, true);
			}
		}
	}
}

// Tell the bots what the highest priority objective for them to attack is
// Overriden to support the ROObjective structure
function GameObjective GetPriorityAttackObjectiveFor(SquadAI AttackSquad)
{
//	local GameObjective O;
//	local ROObjective ROObj;

//	if ( (PickedObjective != None) && (!PickedObjective.bActive || Team.TeamIndex == ROObjective(PickedObjective).ObjState))
//		PickedObjective = None;

//	for ( O=Objectives; O!=None; O=O.NextObjective )
//	{
//		ROObj = ROObjective(O);
//
//		if ( (ROObj != None) && ROObj.bActive && Team.TeamIndex != ROObj.ObjState &&
//			( (PickedObjective == none) || (ROObj.IsHigherPriority(PickedObjective, Team.TeamIndex))) )
//		{
//			PickedObjective = O;
//		}
//	}
	//jonathan@psyonix There's No deference betwen attack and defense objectives in RO
//	if (PickedObjective == none)
//	   PickedObjective = GetLeastDefendedObjective();

   //log("Objective:"$PickedObjective);
	return GetLeastDefendedObjective();
}

// Tell the bots which objective is the least defended (highest priority) so they
// will go and defend it
function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;
	local ROObjective ROObj;
	local int NumBestSquads, NumCurSquads;	local SquadAI S;

	NumBestSquads = 10000;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		ROObj = ROObjective(O);

		if ( (ROObj != None) && ROObj.bActive )
		{
         NumCurSquads = 0;
	      for ( S=Squads; S!=None; S=S.NextSquad )
	      {
	         if(S.SquadObjective == O)
               NumCurSquads += S.Size;
	      }

	      if(NumCurSquads<NumBestSquads)
	      {
	         Best = O;
	         NumBestSquads = NumCurSquads;
         }
	   }
	}

	return Best;
}
//TODO:: Jonathan Remove this when I'm sure we have everything from it
//		ROObj = ROObjective(O);
//
//		if ( (ROObj != None) && ROObj.bActive && Team.TeamIndex == ROObj.ObjState &&
//			( (Best == none) ||  (ROObj.IsHigherPriority(Best, Team.TeamIndex))) )
//		{
//			Best = O;
//		}

// Tell the bots which objective is the most defended (lowest priority)
function GameObjective GetMostDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( !O.bDisabled && O.bActive && (Team.TeamIndex == ROObjective(O).ObjState)
			&& ((Best == None) || (ROObjective(O).IsHigherPriority(Best, Team.TeamIndex))
				|| ((ROObjective(O).IsEqualPriority(Best,Team.TeamIndex)) && (Best.GetNumDefenders() < O.GetNumDefenders()))) )
			Best = O;
	}
	return Best;
}

// Returns true if this team has nothing to defend. Not used right now
function bool NothingToDefend()
{
	local ROObjective ROObj;
	local GameObjective O;

	for ( O=Team.AI.Objectives; O!=None; O=O.NextObjective )
	{
		ROObj = ROObjective(O);
		if ( (ROObj != None) && ROObj.bActive && Team.TeamIndex == ROObj.ObjState)
		{
			return false;
		}
	}
	return true;
}

defaultproperties
{
     SquadType=Class'ROEngine.ROSquadAI'
}
