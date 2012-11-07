class NoTraderMut extends Mutator;

function PreBeginPlay()
{
	local ShopVolume S;

	foreach AllActors(Class'ShopVolume',S)
		S.bAlwaysClosed = true;
	Destroy();
}

defaultproperties
{
     GroupName="KF-NoTraderz"
     FriendlyName="No Trader"
     Description="Trader doors stay shut the entire game."
}
