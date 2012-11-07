//=================================================
//  BEResettableCounter - Slinky - 4/28/05
//=================================================
//  Just like Counter, but resets itself when
// untriggered.
//=================================================
//  Black Ether Studios, 2005.
//=================================================
class BEResettableCounter extends Counter;

var () int CountDownInterval; // time between each decrement of the counter when it is in state_TimedCountDown
var () string TimeUpMessage;
var bool bCounting;  // True when counter is counting down. False when it has been halted, via another trigger call.

event Untrigger( Actor Other, Pawn EventInstigator )
{
	Reset();
}

// Counter was triggered.
// Other trigger turns this on.
function Trigger( actor Other, pawn EventInstigator )
{
	local string S;
	local string Num;

	if( NumToCount > 0 )
	{
		if( --NumToCount == 0 )
		{
			// Trigger all matching actors.
			if( bShowMessage && (CompleteMessage != ""))
				Level.Game.Broadcast(Self,CompleteMessage,'CriticalEvent');
			TriggerEvent(Event,Other,EventInstigator);
		}
		else if( bShowMessage && CountMessage != "" )
		{
			// Still counting down.
			switch( NumToCount )
			{
				case 1:  Num="one"; break;
				case 2:  Num="two"; break;
				case 3:  Num="three"; break;
				case 4:  Num="four"; break;
				case 5:  Num="five"; break;
				case 6:  Num="six"; break;
				default: Num=string(NumToCount); break;
			}
			S = CountMessage;
			ReplaceText(S,"%i",Num);
			Level.Game.Broadcast(Self,S,'CriticalEvent');
		}
	}
}

function Timer()
{
	if (!bCounting)
		return;

	NumToCount --;

	// Counter made it to zero.  we failed.
	if(NumToCount <= 0)
	{
		if( TimeUpMessage!="" )
			Level.Game.Broadcast(Self,TimeUpMessage,'CriticalEvent');
		TriggerEvent(Event,self,Instigator);
		SetTimer(0,false);
		bCounting = false;
	}
	else Level.Game.Broadcast(Self,"00:"$NumToCount,'CriticalEvent');
}

// Other trigger turns this on.
state() TimedCountDown
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Instigator = EventInstigator;

		// If we ARE counting down, start the timer. Otherwise, we've been asked to halt. Let the timer know, so it can
		// stop itself in the next iteration.
		if (!bCounting)
		{
			SetTimer(CountDownInterval,true);
			bCounting = true;
		}
		else if(bCounting)
		{
			bCounting = false;
			SetTimer(0,false);
		} 
	}
}

defaultproperties
{
     CountDownInterval=1
     TimeUpMessage="TIME UP"
}
