class KSGSwitchMessage extends CriticalEventPlus;

var() localized string SwitchMessage[10];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if ( (Switch >= 0) && (Switch <= 9) )
		return Default.SwitchMessage[Switch];
}

defaultproperties
{
     SwitchMessage(0)="Set to Wide-Spread."
     SwitchMessage(1)="Set to Tight-Spread."
     DrawColor=(B=0,G=0,R=220)
     FontSize=-2
}
