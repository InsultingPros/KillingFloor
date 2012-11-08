//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UnWeldFire extends WeldFire;

function bool AllowFire()
{
	local KFDoorMover WeldTarget;

	WeldTarget = GetDoor();

	// Can't use welder, if no door.
	if(WeldTarget == none)
		return false;

	// Cannot unweld a door that's already unwelded
	if(WeldTarget.WeldStrength <= 0)
		return false;

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire ;
}

defaultproperties
{
     MeleeDamage=15
     hitDamageClass=Class'KFMod.DamTypeUnWeld'
     AmmoPerFire=15
}
