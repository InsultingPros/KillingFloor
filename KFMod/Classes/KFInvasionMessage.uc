class KFInvasionMessage extends InvasionMessage
	abstract;

var localized string SameTeamKill, KilledByMonster;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if( RelatedPRI_1 == none )
		return "";
	else if( RelatedPRI_2 != none && RelatedPRI_2 != RelatedPRI_1 )
	{
		if ( RelatedPRI_2.Team != RelatedPRI_1.Team )
		{
			return RelatedPRI_1.PlayerName@default.KilledByMonster@RelatedPRI_2.PlayerName;
		}

		return RelatedPRI_1.PlayerName@Default.SameTeamKill@RelatedPRI_2.PlayerName;
	}
	else if( Class<Monster>(OptionalObject) != none )
		return RelatedPRI_1.PlayerName@Default.KilledByMonster@GetNameOf(Class<Monster>(OptionalObject));
	Return RelatedPRI_1.PlayerName@Default.OutMessage;
}

static function string GetNameOf( Class<Monster> OClass )
{
	local string S;

	S = OClass.Default.MenuName;
	if( S=="" )
		S = string(OClass.Name);
	if( OClass.Default.bBoss )
		Return "the"@S;
	else if( ShouldUseAn(S) )
		Return "an"@S;
	else Return "a"@S;
}
static function bool ShouldUseAn( string S )
{
	S = Left(S,1);
	Return (S~="a" || S~="e" || S~="i" || S~="o" || S~="u");
}

defaultproperties
{
     SameTeamKill="was team-killed by"
     KilledByMonster="was killed by"
     OutMessage="has died."
     DrawColor=(B=75,G=75,R=255,A=230)
     FontSize=0
}
