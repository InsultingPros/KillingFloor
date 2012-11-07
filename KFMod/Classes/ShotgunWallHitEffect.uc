//=============================================================================
// xHeavyWallHitEffect.
//=============================================================================
class ShotgunWallHitEffect extends Effects;

var sound ImpactSounds[6];
var vector FireStart;

replication
{
	reliable if ( Role == ROLE_Authority )
		FireStart;
}

simulated function SpawnEffects()
{
	local rotator ReverseRot;
	local PlayerController PC;
	local vector Dir, LinePos, LineDir;
	local bool bViewed;

	PlaySound(ImpactSounds[Rand(6)],, 2.5*TransientSoundVolume,,200);

	PC = Level.GetLocalPlayerController();
	if ( (PC != None) && (PC.ViewTarget != None) && (VSize(PC.Viewtarget.Location - Location) < 3000*PC.FOVBias) )
	{
            Spawn(class'BulletDecal');
            Spawn(class'ROBulletHitEffect',,,,ReverseRot);
		bViewed = true;
	}

	if ( !PhysicsVolume.bWaterVolume )
	{
		ReverseRot = rotator(-1 * vector(Rotation));
		if ( bViewed )
			Spawn(class'ROBulletHitEffect',,,,ReverseRot);
		//Spawn(class'WallSparks',,,,ReverseRot) KFTODO: Maybe replace?
	}

	if ( FireStart != vect(0,0,0) )
	{
		// see if local player controller near bullet, but missed
		if ( (PC != None) && (PC.Pawn != None) )
		{
			Dir = Normal(Location - FireStart);
			LinePos = (FireStart + (Dir dot (PC.Pawn.Location - FireStart)) * Dir);
			LineDir = PC.Pawn.Location - LinePos;
			if ( VSize(LineDir) < 150 )
			{
				SetLocation(LinePos);
                PlaySound(sound'ProjectileSounds.Bullets.Impact_Dirt',,,,80);
 			}
		}
	}
}

simulated function PostNetBeginPlay()
{
	if ( Role == ROLE_Authority )
	{
		if ( Instigator != None )
			MakeNoise(0.5);
	}
	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEffects();

	Super.PostNetBeginPlay();
}

defaultproperties
{
     ImpactSounds(0)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     ImpactSounds(1)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     ImpactSounds(2)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     ImpactSounds(3)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     ImpactSounds(4)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     ImpactSounds(5)=SoundGroup'Inf_Weapons.shells.ShellRifleDirt'
     DrawType=DT_None
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.200000
}
