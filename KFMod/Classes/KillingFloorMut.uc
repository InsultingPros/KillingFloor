class KillingFloorMut extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( Controller(Other)!=None )
		Controller(Other).PlayerReplicationInfoClass = Class'KFPlayerReplicationInfo';
	return true;
}

defaultproperties
{
     GroupName="KF"
}
