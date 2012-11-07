// Changed base class, since this is 99,99 % same as TurretController, why not use it then?
class AutoGunAI extends TurretController;

function bool IsTargetRelevant( Pawn Target )
{
	if ( (Target != None) && (Target.Controller != None) && !Target.IsA('KFHumanPawn')
		 && (Target.Health > 0) && VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25 )
		return true;
	return false;
}
function bool IsTurretFiring()
{
	return Pawn.IsFiring();
}

auto state Searching
{
	event SeeMonster( Pawn Seen )
	{
		if ( IsTargetRelevant( Seen ) )
		{
			Enemy = Seen;
			GotoState('Engaged');
		}   
	}
}

defaultproperties
{
}
