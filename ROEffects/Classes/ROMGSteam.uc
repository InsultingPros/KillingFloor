//------------------------------------------------------------------------------
// Author: Byron Wright
// Description: Steam Emitter for over heating machine gun
// $Id: ROMGSteam.uc,v 1.5 2004/05/09 02:24:28 antarian Exp $:
//------------------------------------------------------------------------------
class ROMGSteam extends Emitter;

var		bool		bActive;

simulated function Trigger( Actor Other, Pawn EventInstigator )
{
	if( bActive )
	{
   		StopSteam();
   		bActive = false;
   	}
   	else
   	{
   		StartSteam();
   		bActive = true;
   	}
}

function StopSteam()
{
    Emitters[0].ParticlesPerSecond = 0;
    Emitters[0].InitialParticlesPerSecond = 0;
    Emitters[0].RespawnDeadParticles=false;
}

function StartSteam()
{
    Emitters[0].ParticlesPerSecond = 3.000000;
    Emitters[0].InitialParticlesPerSecond=3.000000;
    Emitters[0].AllParticlesDead = false;
    Emitters[0].RespawnDeadParticles=false;
}

// Reset is already handled in ROEmitter
/*simulated function Reset()
{
}*/

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         FadeOutStartTime=1.000000
         FadeInEndTime=0.200000
         MaxParticles=64
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=15.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=5.000000,Max=10.000000),Z=(Min=5.000000,Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ROMGSteam.SpriteEmitter0'

     bNoDelete=False
     Tag="mgSteam"
     bHardAttach=True
}
