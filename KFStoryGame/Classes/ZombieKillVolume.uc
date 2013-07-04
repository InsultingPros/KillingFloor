/*
	--------------------------------------------------------------
	ZombieKillVolume
	--------------------------------------------------------------

	Kills zombies that come in contact with it.  Simple as that.

	Used for protecting player spawn areas in maps that have
	constantly spawning enemies.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ZombieKillVolume extends PhysicsVolume
hidecategories(PhysicsVolume);

simulated event PawnEnteredVolume(Pawn Other)
{
	if(Role == Role_Authority &&
	ClassIsChildOf(Other.class,class 'KFMonster' ))
	{
		Other.Died(Other.Controller, class' Suicided' , Other.Location);
	}
}

defaultproperties
{
}
