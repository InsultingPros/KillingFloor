//=============================================================================
//=============================================================================
class KFNoteMsg extends LocalMessage;

static function string GetRelatedString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	return "";
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	return "";
}

static function string AssembleString(
    HUD myHUD,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional String MessageString
    )
{
	return "";
}

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if( KFPlayerController(P)!=None )
	{
		if( Switch==0 )
		{
			if( KFPlayerController(P).ActiveNote!=OptionalObject )
				KFPlayerController(P).ActiveNote = KFSPNoteMessage(OptionalObject);
			else KFPlayerController(P).ActiveNote = None;
		}
		else KFPlayerController(P).ActiveNote = None;
	}
}

defaultproperties
{
     bIsConsoleMessage=False
     Lifetime=0
}
