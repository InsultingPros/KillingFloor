//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFSquad extends InvasionSquad;

// Let's put some hacks in here to account for how Bots judge Specimen threat priorities.

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue;

	if ( KFMonster(NewThreat) != none )
		ThreatValue += 0.25;
	if (KFMonster(NewThreat).bCloaked)
		ThreatValue += 10;
	if (KFMonster(NewThreat).bDecapitated)
		ThreatValue -= 0.10;
	if( VSize(B.Pawn.Location-NewThreat.Location)<400 ) // Consider close range zombies as much bigger threat.
		ThreatValue += 15;
	Return Super.AssessThreat(B,NewThreat,bThreatVisible);
}

// gibber - the squadAI version is a monster. Lets lighten it for KF
function bool CheckSquadObjectives(Bot B)
{
	B.Skill = 9; // Best skill.

	// might have gotten out of vehicle and been killed
	if ( B.Pawn == None )
		return true;

	if( !bFreelance && Team!=None && Team.AI!=None )
		Team.AI.PutOnFreelance(B);
	if ( B.Enemy != None )
	{
		if ( B.LostContact(5) )
			B.LoseEnemy();
		if ( B.Enemy != None )
		{
			if ( B.EnemyVisible() || (Level.TimeSeconds - B.LastSeenTime < 3) )
			{
				B.FightEnemy(false, 0);
				return true;
			}
		}
	}

	return false;
}

function bool SetEnemy( Bot B, Pawn NewEnemy )
{
	local Bot M;
	local bool bResult;

	if ( (NewEnemy == B.Enemy) || !ValidEnemy(NewEnemy) )
		return false;

	AddEnemy(NewEnemy);

	// reassess squad member enemies
	if ( MustKeepEnemy(NewEnemy) )
	{
		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		{
			if ( (M != B) && (M.Enemy != NewEnemy) )
				FindNewEnemyFor(M,(M.Enemy !=None) && M.EnemyVisible());
		}
	}

	bResult = CheckSwapEnemy(B, NewEnemy);
	if ( bResult && (B.Enemy == NewEnemy) )
		B.AcquireTime = Level.TimeSeconds;
	return bResult;
}

function bool CheckSwapEnemy(Bot B, Pawn NewEnemy)
{
	local bool bSeeOld, bSeeNew;
	local float OldThreat,NewThreat;

	bSeeOld = B.EnemyVisible();

	if ( B.Pawn == None )
		return true;

	if(B.Enemy == NewEnemy)
		return false;

	if ( B.Enemy != None )
	{
		if ( (B.Enemy.Health < 0) || (B.Enemy.Controller == None) )
		{
			B.Enemy = None;
			//BestEnemy = None;
			//OldThreat = 0;
		}
		else
		{
			if ( ModifyThreat(0,B.Enemy,bSeeOld,B) > 5 )
				return false;
			OldThreat = AssessThreat(B,B.Enemy,bSeeOld);
		}
	}

	bSeeNew = B.LineOfSightTo(NewEnemy);

	NewThreat = AssessThreat(B,NewEnemy,bSeeNew);

	if ( NewThreat > OldThreat )
	{
		B.Enemy = NewEnemy;
		B.EnemyChanged(bSeeNew);
		return true;
	}
	return false;
}

defaultproperties
{
}
