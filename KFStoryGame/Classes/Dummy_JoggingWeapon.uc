/*
    Dummy_JoggingWeapon

	--------------------------------------------------------------

	This is basically just a dummy inventory class that KF pawns
	can hold when they are supposed to not be holding any weapon.
	It's necessary since there isn't any real support in the KF Pawn
    Animation / Weapon attachment code for that.

	While carrying this weapon your dude looks like he is Jogging with
	his arms at his sides.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class Dummy_JoggingWeapon extends KFWeapon
HideDropdown;


simulated function String GetHumanReadableName()
{
    return "";
}

defaultproperties
{
     Weight=0.000000
     bKFNeverThrow=True
     FireModeClass(0)=Class'KFMod.NoFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     InventoryGroup=0
     AttachmentClass=Class'KFStoryGame.Dummy_JoggingAttachment'
}
