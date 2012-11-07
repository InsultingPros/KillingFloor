//=============================================================================
// ROPawnSoundGroup
//=============================================================================
// Player sounds. Some functionality copied from xPawnSoundGroup
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROPawnSoundGroup extends Object
    abstract;

var() array<Sound>  Sounds;
var() sound         HeadShotDeathSoundGroup;
var() sound         UpperBodyShotDeathSoundGroup;
var() sound         LowerBodyShotDeathSoundGroup;
var() sound         LimbShotDeathSoundGroup;
var() sound         GenericDeathSoundGroup;
var() sound         FallingPainSoundGroup;
var() sound         WoundingPainSoundGroup;

var() Sound         LandSounds[20]; // Indexed by ESurfaceTypes (sorry about the literal).
var() Sound         JumpSounds[20]; // Indexed by ESurfaceTypes (sorry about the literal).

Enum ESoundType
{
    EST_Land,
    EST_CorpseLanded,
    EST_HitUnderWater,
    EST_Jump,
    EST_LandGrunt,
    EST_Gasp,
    EST_Drown,
    EST_BreatheAgain,
	EST_TiredJump,
    EST_Dodge,
    EST_DoubleJump,
    EST_DiveLand
};

static function Sound GetHitSound(optional class<DamageType> DamageType)
{
    //If they are taking damage because they fell, return a falling pain sound
    if ( DamageType.Name == 'Fell' )
        return default.FallingPainSoundGroup;

    //Otherwise, return a wounding pain sound
    return default.WoundingPainSoundGroup;
}

static function Sound GetDeathSound(optional int HitIndex)
{
    //Check for a Head shot
    if( HitIndex == 1 )
        return default.HeadShotDeathSoundGroup;
    //Check for Upper Torso shot
    else if( HitIndex == 2 )
        return default.UpperBodyShotDeathSoundGroup;
    //Check for Lower Torso shot
    else if( HitIndex == 3 )
        return default.LowerBodyShotDeathSoundGroup;
    //Check for Arm/Hand and Leg/Foot shot
    else if( HitIndex >= 4 && HitIndex <= 15 )
        return default.LimbShotDeathSoundGroup;

    //Hit somewhere without a group, return a generic sound
    return default.GenericDeathSoundGroup;
}

static function Sound GetSound(ESoundType SoundType, optional int SurfaceID)
{
    if( SoundType == EST_Land )
	{
		return default.LandSounds[SurfaceID];
	}
	else if( SoundType == EST_Jump )
	{
	  	return default.JumpSounds[SurfaceID];
	}
	else
	{
        return default.Sounds[int(SoundType)];
    }
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
}
