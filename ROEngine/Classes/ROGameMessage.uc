//=============================================================================
// ROGameMessage
//=============================================================================
// Changed message around a little
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROGameMessage extends GameMessage;

//=============================================================================
// Variables
//=============================================================================

var(Message) localized string NewTeamMessageRussian;
var(Message) localized string NewTeamMessageGerman;

var(Message) localized string FFKillMessage;
var(Message) localized string FFViolationMessage;
var(Message) localized string FFViolationMessageTrailer;
var(Message) localized string FFDamageMessage;
var(Message) localized string RoleChangeMsg;
var(Message) localized string MaxRoleMsg;
var(Message) localized string TypeForgiveMessage;
var(Message) localized string HasForgivenMessage;
var(Message) localized string YouHaveLoggedInAsAdminMsg;
var(Message) localized string YouHaveLoggedOutOfAdminMsg;


//=============================================================================
// Functions
//=============================================================================

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch (Switch)
    {
        case 0:
            return Default.OverTimeMessage;
            break;
        case 1:
            if (RelatedPRI_1 == None)
                return Default.NewPlayerMessage;

            return RelatedPRI_1.playername$Default.EnteredMessage;
            break;
        case 2:
            if (RelatedPRI_1 == None)
                return "";

            return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.PlayerName;
            break;
        case 3:
            if (RelatedPRI_1 == None)
                return "";
            if (OptionalObject == None)
                return "";

            return RelatedPRI_1.playername@Default.NewTeamMessageRussian;
            break;
        case 4:
            if (RelatedPRI_1 == None)
                return "";

            return RelatedPRI_1.playername$Default.LeftMessage;
            break;
        case 5:
            return Default.SwitchLevelMessage;
            break;
        case 6:
            return Default.FailedTeamMessage;
            break;
        case 7:
            return Default.MaxedOutMessage;
            break;
        case 8:
            return Default.NoNameChange;
            break;
        case 9:
            return RelatedPRI_1.playername@Default.VoteStarted;
            break;
        case 10:
            return Default.VotePassed;
            break;
        case 11:
			return Default.MustHaveStats;
			break;
    	// German team join message HACK - butto 7/17/03
    	case 12:
    		if (RelatedPRI_1 == None)
                return "";
            if (OptionalObject == None)
                return "";

            return RelatedPRI_1.playername@Default.NewTeamMessageGerman;
            break;
    	// FF kill message
    	case 13:
    		if (RelatedPRI_1 == None)
    			return "";

    		return RelatedPRI_1.PlayerName@Default.FFKillMessage;
    		break;
    	// FF boot message
    	case 14:
    		if (RelatedPRI_1 == None)
    			return "";

    		return Default.FFViolationMessage@RelatedPRI_1.PlayerName@Default.FFViolationMessageTrailer;
    		break;
    	// FF damage message
    	case 15:
    		return Default.FFDamageMessage;
    		break;
    	// Role change message
    	case 16:
    		if (RORoleInfo(OptionalObject) == None)
    			return "";

    		if( class'ROPlayer'.default.bUseNativeRoleNames )
    		{
            	return default.RoleChangeMsg $ RORoleInfo(OptionalObject).default.Article $ RORoleInfo(OptionalObject).default.AltName;
            }
            else
            {
            	return default.RoleChangeMsg $ RORoleInfo(OptionalObject).default.Article $ RORoleInfo(OptionalObject).default.MyName;
            }

    		break;
    	// Unable to change role message
    	case 17:
    		if (OptionalObject == None)
    			return "";

    		if( class'ROPlayer'.default.bUseNativeRoleNames )
    		{
            	return default.MaxRoleMsg $ RORoleInfo(OptionalObject).default.AltName;
            }
            else
            {
            	return default.MaxRoleMsg $ RORoleInfo(OptionalObject).default.MyName;
            }
    		break;
    	// To forgive type "np" or "forgive" message
    	case 18:
    		if (RelatedPRI_1 == None)
            	return "Someone" @ default.TypeForgiveMessage;
            else
            	return RelatedPRI_1.PlayerName @ default.TypeForgiveMessage;
    		break;
    	// Has forgiven message
    	case 19:
    		if (RelatedPRI_1 == None || RelatedPRI_2 == None)
    			return "";

           	return RelatedPRI_2.PlayerName @ default.HasForgivenMessage @ RelatedPRI_1.PlayerName;
    		break;
    	// You have logged in as an admin message(used for AdminLoginSilent)
    	case 20:
    	    return default.YouHaveLoggedInAsAdminMsg;
    	    break;
    	// You have logged out of admin message(used for AdminLoginSilent)
    	case 21:
    	    return default.YouHaveLoggedOutOfAdminMsg;
    	    break;
    }
    return "";
}

defaultproperties
{
     NewTeamMessageRussian="has joined the Allied forces."
     NewTeamMessageGerman="has joined the Axis forces."
     FFKillMessage="killed a friendly soldier."
     FFViolationMessage="Removing"
     FFViolationMessageTrailer="due to a friendly fire violation."
     FFDamageMessage="You injured a friendly soldier."
     RoleChangeMsg="You will attempt to respawn as "
     MaxRoleMsg="Unable to change to "
     TypeForgiveMessage="has team killed you, type "np" or "forgive" to forgive them."
     HasForgivenMessage="has forgiven"
     YouHaveLoggedInAsAdminMsg="You have logged in as an administrator."
     YouHaveLoggedOutOfAdminMsg="You have given up your adminstrative abilities."
     LeftMessage=" left the battlefield."
     EnteredMessage=" entered the battlefield."
     OvertimeMessage=
     NewTeamMessage=
     NewPlayerMessage="A new soldier entered the battlefield."
     Lifetime=8
}
