class KFGameMessages extends GameMessage;

var(Message) localized string NoLateJoiners;


// Messages common to GameInfo derivatives.
//
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

            return RelatedPRI_1.playername@Default.NewTeamMessage@TeamInfo(OptionalObject).GetHumanReadableName()$Default.NewTeamMessageTrailer;
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
    case 12:
        return Default.CantBeSpectator;
        break;
    case 13:
        return Default.CantBePlayer;
        break;
    case 14:
        return RelatedPRI_1.PlayerName@Default.BecameSpectator;
        break;
    case 15:
        return Default.KickWarning;
        break;
    case 16:
        return Default.NoLateJoiners;
        break;
    case 17:
            if (RelatedPRI_1 == None)
                return Default.NewSpecMessage;

            return RelatedPRI_1.playername$Default.SpecEnteredMessage;
            break;
    }
    return "";
}

defaultproperties
{
     NoLateJoiners="This server does not accept late joiners."
}
