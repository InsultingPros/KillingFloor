class KFBrowser_RulesList extends Browser_RulesList;

var localized string LateJoinersString;

function string LocalizeRules( string code )
{
    switch( caps(code) )
    {
    case "TRUE":                return TrueString;
    case "FALSE":               return FalseString;
    case "SERVERMODE":          return ServerModeString;
    case "DEDICATED":           return DedicatedString;
    case "NON-DEDICATED":       return NonDedicatedString;
    case "ADMINNAME":           return AdminNameString;
    case "ADMINEMAIL":          return AdminEmailString;
    case "PASSWORD":            return PasswordString;
    case "GAMESTATS":           return GameStatsString;
    case "GAMESPEED":           return GameSpeedString;
    case "MUTATOR":             return MutatorString;
    case "BALANCETEAMS":        return BalanceTeamsString;
    case "PLAYERSBALANCETEAMS": return PlayersBalanceTeamsString;
    case "FRIENDLYFIRE":        return FriendlyFireString;
    case "GOALSCORE":           return GoalScoreString;
    case "TIMELIMIT":           return TimeLimitString;
    case "MINPLAYERS":          return MinPlayersString;
    case "bNoLateJoiners":       return LateJoinersString;
   // case "TRANSLOCATOR":        return TranslocatorString;
    //case "WEAPONSTAY":          return WeaponStayString;
    }
    return code;
}

defaultproperties
{
     LateJoinersString="No Late Joiners"
}
