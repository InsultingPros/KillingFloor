class KFMaleSoundGroup extends xPawnSoundGroup;

var() sound         BreathingSound;
var() Sound         LandSounds[20]; // Indexed by ESurfaceTypes (sorry about the literal).
var() Sound         JumpSounds[20]; // Indexed by ESurfaceTypes (sorry about the literal).

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


static function Sound GetNearDeathSound()
{
	return default.BreathingSound;
}

defaultproperties
{
     BreathingSound=Sound'KFPlayerSound.Malebreath'
     LandSounds(0)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDefault'
     LandSounds(1)=SoundGroup'KF_PlayerGlobalSnd.Player_LandConc'
     LandSounds(2)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(3)=SoundGroup'KF_PlayerGlobalSnd.Player_LandMetal'
     LandSounds(4)=SoundGroup'KF_PlayerGlobalSnd.Player_LandWood'
     LandSounds(5)=SoundGroup'KF_PlayerGlobalSnd.Player_LandGrass'
     LandSounds(6)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDefault'
     LandSounds(7)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(8)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(9)=SoundGroup'KF_PlayerGlobalSnd.Player_LandWater'
     LandSounds(10)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(11)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(12)=SoundGroup'KF_PlayerGlobalSnd.Player_LandConc'
     LandSounds(13)=SoundGroup'KF_PlayerGlobalSnd.Player_LandWood'
     LandSounds(14)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     LandSounds(15)=SoundGroup'KF_PlayerGlobalSnd.Player_LandMetal'
     LandSounds(16)=SoundGroup'KF_PlayerGlobalSnd.Player_LandConc'
     LandSounds(17)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDefault'
     LandSounds(18)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDefault'
     LandSounds(19)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDefault'
     JumpSounds(0)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(1)=SoundGroup'Inf_Player.footsteps.JumpAsphalt'
     JumpSounds(2)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(3)=SoundGroup'Inf_Player.footsteps.JumpMetal'
     JumpSounds(4)=SoundGroup'Inf_Player.footsteps.JumpWood'
     JumpSounds(5)=SoundGroup'Inf_Player.footsteps.JumpGrass'
     JumpSounds(6)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(7)=SoundGroup'Inf_Player.footsteps.JumpSnowRough'
     JumpSounds(8)=SoundGroup'Inf_Player.footsteps.JumpSnowHard'
     JumpSounds(9)=SoundGroup'Inf_Player.footsteps.JumpWaterShallow'
     JumpSounds(10)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(11)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(12)=SoundGroup'Inf_Player.footsteps.JumpAsphalt'
     JumpSounds(13)=SoundGroup'Inf_Player.footsteps.JumpWood'
     JumpSounds(14)=SoundGroup'Inf_Player.footsteps.JumpMud'
     JumpSounds(15)=SoundGroup'Inf_Player.footsteps.JumpMetal'
     JumpSounds(16)=SoundGroup'Inf_Player.footsteps.JumpAsphalt'
     JumpSounds(17)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(18)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     JumpSounds(19)=SoundGroup'Inf_Player.footsteps.JumpDirt'
     Sounds(0)=SoundGroup'KF_PlayerGlobalSnd.Player_LandDirt'
     DeathSounds(0)=SoundGroup'Inf_Player.playerdeath.Generic'
     DeathSounds(1)=SoundGroup'Inf_Player.playerdeath.Headshot'
     DeathSounds(2)=SoundGroup'Inf_Player.playerdeath.UpperBodyShot'
     DeathSounds(3)=SoundGroup'Inf_Player.playerdeath.LowerBodyShot'
     DeathSounds(4)=SoundGroup'Inf_Player.playerdeath.LimbShot'
     PainSounds(0)=SoundGroup'Inf_Player.playerhurt.Wounding'
     PainSounds(1)=SoundGroup'Inf_Player.playerhurt.Wounding'
     PainSounds(2)=SoundGroup'Inf_Player.playerhurt.Wounding'
     PainSounds(3)=SoundGroup'Inf_Player.playerhurt.Wounding'
     PainSounds(4)=SoundGroup'Inf_Player.playerhurt.Wounding'
     PainSounds(5)=SoundGroup'Inf_Player.playerhurt.Wounding'
}
