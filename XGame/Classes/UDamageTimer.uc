class UDamageTimer extends Info;

// ifndef _RO_
//#exec OBJ LOAD FILE=PickupSounds.uax

var int SoundCount;

function Timer()
{
	if ( Pawn(Owner) == None )
	{
		Destroy();
		return;
	}
	if ( SoundCount < 4 )
	{
		SoundCount++;
		// ifndef _RO_
        //Pawn(Owner).PlaySound(Sound'PickupSounds.UDamagePickUp', SLOT_None, 1.5*Pawn(Owner).TransientSoundVolume,,1000,1.0);
		SetTimer(0.75,false);
		return;
	}
	Pawn(Owner).DisableUDamage();
	Destroy();
}

defaultproperties
{
}
