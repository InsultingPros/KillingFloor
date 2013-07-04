/*
	--------------------------------------------------------------
	Msg_CheckPoint
	--------------------------------------------------------------

	Notification that a checkpoint was reached

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Msg_CheckPoint extends LocalMessage;

var 	string	CheckPointStrings[2];


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string 	FinalString;
	local KF_StoryCheckPointVolume	CheckPoint;

	CheckPoint = KF_StoryCheckPointVolume(OptionalObject);

	switch(Switch)
	{
		case 0 :  FinalString = RelatedPRI_1.PlayerName@default.CheckPointStrings[0]@CheckPoint.CheckPointName ; 	break;
		case 1 :  FinalString = default.CheckPointStrings[1]@CheckPoint.CheckPointName ;	break;
	}

	return FinalString;
}

defaultproperties
{
     CheckPointStrings(0)="reached"
     CheckPointStrings(1)="Your team will respawn at .."
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=5
     DrawColor=(G=150,R=25)
     PosY=0.500000
     FontSize=2
}
