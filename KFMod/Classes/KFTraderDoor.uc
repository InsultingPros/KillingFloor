// This door opens and closes ONLY by way of a specific call in the gametype.
class KFTraderDoor extends Mover;

// Toggle when triggered.
state() TriggerToggle
{
	function bool SelfTriggered()
	{
		return false;
	}
	function Reset()
	{
		super.Reset();

		if ( bOpening || bDelaying )
		{
			// Reset instantly
			SetResetStatus( true );
			GotoState( 'TriggerToggle', 'Close' );
		}
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( KeyNum==0 || KeyNum<PrevKeyNum )
			GotoState( 'TriggerToggle', 'Open' );
		else
		{
			GotoState( 'TriggerToggle', 'Close' );
		}
	}
Open:
	bClosed = false;
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	SetResetStatus( false );
}

defaultproperties
{
     MoverEncroachType=ME_IgnoreWhenEncroach
     InitialState="TriggerToggle"
}
