/*
	--------------------------------------------------------------
	KFAmmoPickup_Story
	--------------------------------------------------------------

	AmmoPickup actors tailored to Story missions. Refills specific
	types of weapons.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KFAmmoPickup_Story  extends	KFAmmoPickup;

state Pickup
{
	// When touched by an actor.
	function Touch(Actor Other)
	{
		Super(Ammo).Touch(Other);
	}
}

defaultproperties
{
}
