//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieClot_HALLOWEEN extends ZombieClot;

var Shader ClotSkins[5];

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

  	Skins[0] = ClotSkins[Rand(5)];
}

simulated function SpawnSeveredGiblet( class<SeveredAppendage> GibClass, Vector Location, Rotator Rotation, float GibPerterbation, rotator SpawnRotation )
{
	local SeveredAppendage Giblet;
	local Vector Direction, Dummy;

	if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
		return;

	Instigator = self;
	Giblet = Spawn( GibClass,,, Location, SpawnRotation );
	if( Giblet == None )
		return;
	Giblet.SpawnTrail();

	GibPerterbation *= 32768.0;
	Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
	Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

	GetAxes( Rotation, Dummy, Dummy, Direction );

	Giblet.Velocity = Velocity + Normal(Direction) * (Giblet.MaxSpeed + (Giblet.MaxSpeed/2) * FRand());

	// Give a little upward motion to the decapitated head
	if( class<SeveredHead>(GibClass) != none )
	{
		Giblet.Skins[0] = Texture'kf_fx_trip_t.Gore.KF_Gore_Limbs_diff';
		Giblet.Skins[1] = Skins[0];
		Giblet.Velocity.Z += 50;
	}

}

simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
    // temporary fix for halloween zed to suppress the blood overlay so we can have great variation
    if(mat != Material'Effects_Tex.PlayerDeathOverlay')
	{
        Super.SetOverlayMaterial(mat,time,bOverride);
    }
}

defaultproperties
{
     ClotSkins(0)=Shader'KF_Specimens_Trip_HALLOWEEN_T.clot.Clot_RedneckZombie_Blood01_Shdr'
     ClotSkins(1)=Shader'KF_Specimens_Trip_HALLOWEEN_T.clot.Clot_RedneckZombie_Blood02_Shdr'
     ClotSkins(2)=Shader'KF_Specimens_Trip_HALLOWEEN_T.clot.Clot_RedneckZombie_Blood03_Shdr'
     ClotSkins(3)=Shader'KF_Specimens_Trip_HALLOWEEN_T.clot.Clot_RedneckZombie_Blood04_Shdr'
     ClotSkins(4)=Shader'KF_Specimens_Trip_HALLOWEEN_T.clot.Clot_RedneckZombie_Blood05_Shdr'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmClot_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegClot_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadClot_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.clot.Clot_Challenge'
     MenuName="HALLOWEEN Clot"
     AmbientSound=Sound'KF_BaseClot_HALLOWEEN.Clot_Idle1Loop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.CLOT_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.clot.clot_RedneckZombie_CMB'
     SoundVolume=100
}
