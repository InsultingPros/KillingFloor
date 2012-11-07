class ChargeUp3rdHusk extends ROMuzzleFlash3rd;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.550000,Color=(G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=12.000000
         Texture=Texture'kf_fx_trip_t.Misc.healingFXflare'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ChargeUp3rdHusk.SpriteEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter0
         LowFrequencyNoiseRange=(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-16.000000,Max=16.000000))
         LowFrequencyPoints=4
         HighFrequencyNoiseRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
         HighFrequencyPoints=8
         LFScaleFactors(0)=(FrequencyScale=(Z=100.000000),RelativeLength=1.000000)
         HFScaleFactors(0)=(FrequencyScale=(X=50.000000,Y=50.000000,Z=50.000000))
         UseBranching=True
         BranchProbability=(Min=1.000000,Max=1.000000)
         BranchSpawnAmountRange=(Min=5.000000,Max=5.000000)
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=72,G=132,R=255,A=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(X=(Min=-18.000000,Max=18.000000),Y=(Min=-18.000000,Max=18.000000),Z=(Min=-18.000000,Max=18.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1.000000,Max=1.000000)
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         InitialParticlesPerSecond=90.000000
         Texture=Texture'kf_fx_trip_t.Misc.healingFX'
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRadialRange=(Min=10.000000,Max=10.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=BeamEmitter'ROEffects.ChargeUp3rdHusk.BeamEmitter0'

}
