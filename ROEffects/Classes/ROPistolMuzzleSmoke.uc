//=====================================================
// ROPistolMuzzleSmoke
// started by Antarian 9/10/03
//
// Copyright (C) 2003 Jeffrey Nakai
//
// class to make a small muzzle smoke effect for RO pistols
//=====================================================

class ROPistolMuzzleSmoke extends ROMuzzleSmoke;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=25.000000)
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
         Opacity=0.250000
         FadeOutStartTime=0.500000
         MaxParticles=64
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.080000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=5.000000,Max=8.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ROPistolMuzzleSmoke.SpriteEmitter0'

}
