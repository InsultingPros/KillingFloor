class MutMachinePistols extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	// here, in mutator subclass, change InventoryClassName if desired.  For example:
	if ( WeaponPickup(Other) != None )
	{
		if ( string(Other.Class) ~= "KFMod.SinglePickup" )
		{
			ReplaceWith( Other, "MachinePistolPickup" );
			return false;
		}
	}
	return true;
}

defaultproperties
{
     FriendlyName="Machine Pistols"
     Description="All the semi-auto 9mms in Killing Floor are replaced with fully automatic counterparts. "
}
