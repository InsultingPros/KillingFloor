//=============================================================================
// AvoidMarker_MedicNade
// AvoidMarkerthat the medic grenade creates, overridden to not affect the 
// ringmaster
//=============================================================================
class AvoidMarker_MedicNade extends AvoidMarker
	placeable;

function bool RelevantTo(Pawn P)
{
	local bool bRelevant;
	
	bRelevant = Super.RelevantTo(P);
	
	if( bRelevant && P.GetTeamNum() > 0 )
	{
		bRelevant = false;
	}
	
	return bRelevant;
}

defaultproperties
{
}
