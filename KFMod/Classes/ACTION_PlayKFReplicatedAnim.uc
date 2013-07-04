/*
	--------------------------------------------------------------
	 ACTION_PlayKFReplicatedAnim
	--------------------------------------------------------------

	Fully Replicated Version of ACTION_PlayAnim for use with KFPawns

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ACTION_PlayKFReplicatedAnim extends ACTION_PlayAnim;

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
    local KFPawn KFP;

    KFP = KFPawn(C.Pawn);
    if(KFP == none)
    {
        log("Warning - Cannot use KFReplicatedAnim Actions with actors that are not children of KFPawn");
        return false;
    }

	if ( BaseAnim == '' )
		return false;

	C.bControlAnimations = true;
    KFP.SetScriptedAnimData(BaseAnim,BlendInTime,BlendOutTime,AnimRate,AnimIterations,bLoopAnim,StartFrame);

	return false;
}

defaultproperties
{
}
