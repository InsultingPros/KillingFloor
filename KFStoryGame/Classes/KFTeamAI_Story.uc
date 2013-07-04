//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFTeamAI_Story extends KFTeamAI;

/* Hack for story NPCs -  check their team Index number instead of the TeamInfo object ..
(They dont actually get put on teams with human players) */

function bool FriendlyToward(Pawn Other)
{
    if(KF_StoryNPC(Other) != none)
    {
        return KF_StoryNPC(Other).TeamIndex == Team.TeamIndex ;
    }

	return Super.OnThisTeam(Other);
}

defaultproperties
{
}
