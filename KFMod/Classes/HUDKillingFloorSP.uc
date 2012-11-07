class HUDKillingFloorSP extends HUDKillingFloor;

simulated function DrawKFHUDTextElements(Canvas Canvas )
{
	if( KFSPObjectiveBoard(ScoreBoard)!=None )
		KFSPObjectiveBoard(ScoreBoard).RenderObjectivedBoard(Canvas);
}

defaultproperties
{
     YouveWonTheMatch="Mission Complete."
     YouveLostTheMatch="Mission Failed."
}
