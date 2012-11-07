//
//=============================================================================
class BullpupBurstFire extends BullpupFire;

var() int BurstLength; //How many bullets to fire in one burst
var() float BurstRate; //Time between shots (should be smaller than FireRate).
var bool bBursting;
var int RoundsToFire;

event ModeDoFire()
{
	if(bBursting && RoundsToFire > 0)
		RoundsToFire--;

	//If not already firing, start a burst.
	if(!bBursting && AllowFire())
	{
		bBursting = true;
		RoundsToFire = BurstLength;
		SetTimer(BurstRate, true);
	}
	if(RoundsToFire < 1)
	{
		SetTimer(0, false);
		RoundsToFire = 0;
		bBursting = false;
		return;
	}
	Super.ModeDoFire();
}


simulated function Timer()
{
	if(bBursting)
		ModeDoFire();
	else SetTimer(0,false);
}

defaultproperties
{
     BurstLength=4
     BurstRate=0.100000
     Momentum=10000.000000
     FireEndAnim=
     FireRate=0.500000
     ShakeRotMag=(X=20.000000,Y=150.000000,Z=20.000000)
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     BotRefireRate=1.000000
     aimerror=50.000000
}
