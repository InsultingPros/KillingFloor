class ProjectilePickupMessage extends LocalMessage;

var() localized string PickupMessages[2];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if ( (Switch >= 0) && (Switch <= 1) )
		return Default.PickupMessages[Switch];
}

defaultproperties
{
     PickupMessages(0)="You picked up a crossbow arrow."
     PickupMessages(1)="You picked up a saw blade."
     bIsUnique=True
     bFadeMessage=True
     PosY=0.900000
}
