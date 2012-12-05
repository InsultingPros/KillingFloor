//=============================================================================
// ROBroadcastHandler
//=============================================================================
// Handles live and dead players
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROBroadcastHandler extends BroadcastHandler;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// AllowsBroadcast
//-----------------------------------------------------------------------------

function bool AllowsBroadcast(actor broadcaster, int Len)
{
	if (Len == 0)
		return false;

	return Super.AllowsBroadcast(broadcaster, Len);
}

/*
 Broadcast a localized message to all players.
 Most messages deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event AllowBroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local Controller C;
	local PlayerController P;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		P = PlayerController(C);

		// Only broadcast rally point messages to your same team, and only to other players
		if((class<RORallyMsg>(Message) != none) && switch == 1 )
		{
			if ( P != None && Controller(Sender) != none && P != Sender && P.PlayerReplicationInfo.Team == Controller(Sender).PlayerReplicationInfo.Team )
				BroadcastLocalized(Sender, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}

		// Send correct last-objective message depending on who's winning and on the reciever's team
		else if (class<ROLastObjectiveMsg>(Message) != none && P != None && P.PlayerReplicationInfo != none
            && P.PlayerReplicationInfo.Team != none)
		{
		    // If P.PRI.Team == switch, then that team is about to win. Broadcast an about-to-win
		    // msg to that team. Else broadast an about-to-lost msg.
		    if (P.PlayerReplicationInfo.Team.TeamIndex == switch)
		        BroadcastLocalized(Sender, P, Message, 0 + switch * 2, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		    else
		        BroadcastLocalized(Sender, P, Message, 1 + switch * 2, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}

		// Only send demo charge placed msg to teammates
		else if (class<RODemolitionChargePlacedMsg>(Message) != none && P != None && P.PlayerReplicationInfo != none
            && P.PlayerReplicationInfo.Team != none)
		{
		    if (P.PlayerReplicationInfo.Team.TeamIndex == switch)
		        BroadcastLocalized(Sender, P, Message, switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}

		// If this message is a static mesh destroyed msg, figure who it should go to
		else if (class<RODestroyableSMDestroyedMsg>(Message) != none && ROPlayer(P) != none && P.PlayerReplicationInfo != none && P.PlayerReplicationInfo.Team != none)
		{
	        switch (switch)
	        {
	            case 0:   // send to nobody? wtf this should never be called
	                break;

	            case 1:   // send to everyone
	                BroadcastLocalized(Sender, P, Message, switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
                    break;

                case 2:   // send to teammates only
                    if (RelatedPRI_1 != none && RelatedPRI_1.Team != none &&
                        P.PlayerReplicationInfo.Team.TeamIndex == RelatedPRI_1.Team.TeamIndex)
                    {
                        BroadcastLocalized(Sender, P, Message, switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
                    }
                    break;

                case 3:   // send to enemies only (not sure when this would be useful)
                    if (RelatedPRI_1 != none && RelatedPRI_1.Team != none &&
                        P.PlayerReplicationInfo.Team.TeamIndex != RelatedPRI_1.Team.TeamIndex)
                    {
                        BroadcastLocalized(Sender, P, Message, switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
                    }
                    break;

                case 4:   // send to instigator only
                    if (RelatedPRI_1 == P.PlayerReplicationInfo)
                        BroadcastLocalized(Sender, P, Message, switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
                    break;

                default:
                    warn("Unknown broadcast type found for message class RODemolitionChargePlacedMsg: " $ switch);
	        }
		}
        else if ( P != None )
		{
			BroadcastLocalized(Sender, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
	}
}

//-----------------------------------------------------------------------------
// Broadcast
//-----------------------------------------------------------------------------

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;
	local PlayerReplicationInfo PRI;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	if ( Pawn(Sender) != None )
		PRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		PRI = Controller(Sender).PlayerReplicationInfo;

	if (bPartitionSpectators && PlayerController(Sender) != None && Type == 'Say' && (PlayerController(Sender).IsDead() || PlayerController(Sender).IsSpectating()))
	{
		Type = 'SayDead';

		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			P = PlayerController(C);

			if ((P != None) && (P.IsDead() || P.IsSpectating()))
				BroadcastText(PRI, P, Msg, Type);
		}
	}
	else
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			P = PlayerController(C);

			if (P != None)
				BroadcastText(PRI, P, Msg, Type);
		}
	}
}

//-----------------------------------------------------------------------------
// BroadcastTeam
//-----------------------------------------------------------------------------

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	if( bPartitionSpectators && PlayerController(Sender) != None && (Type == 'TeamSay') && (PlayerController(Sender).IsDead()
		|| Sender.PlayerReplicationInfo.bOnlySpectator || PlayerController(Sender).IsSpectating()) )
	{
		Type = 'TeamSayDead';

		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			P = PlayerController(C);

			if ((P != None) && P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team
				&& (P.IsDead() || P.IsSpectating()))
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
	else
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			P = PlayerController(C);

			if (P != None && P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bPartitionSpectators=True
}
