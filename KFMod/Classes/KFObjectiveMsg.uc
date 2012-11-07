class KFObjectiveMsg extends CriticalEventPlus
	abstract;

static function string GetString(
	 optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if( KFSPLevelinfo(OptionalObject)==None || Switch<0 || KFSPLevelinfo(OptionalObject).MissionObjectives.Length<=Switch )
		Return "";
	Return KFSPLevelinfo(OptionalObject).MissionObjectives[Switch];
}

defaultproperties
{
     DrawColor=(G=100,R=255)
     StackMode=SM_Down
     PosY=0.800000
     FontSize=2
}
