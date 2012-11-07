//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROTestCriticalMessage extends ROCriticalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    //log("Getting string for switch of " $ switch);
    switch (switch)
    {
        case 0:
            return "Short msg.";
        case 1:
        	return "Test Critical Message!";
        case 2:
        	return "Extra long critical message: the quick brown fox jumps over the lazy dog.";
        default:
            return "Yet another critical message test (this one longer)";
    }
}

defaultproperties
{
     iconID=4
}
