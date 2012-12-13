class ChargeUp3rdZEDGun extends ROMuzzleFlash3rd;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.550000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=7.000000,Max=7.000000))
         InitialParticlesPerSecond=12.000000
         Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_B'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ChargeUp3rdZEDGun.SpriteEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter0
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=4
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         HighFrequencyPoints=2
         LFScaleFactors(0)=(FrequencyScale=(Z=100.000000),RelativeLength=1.000000)
         HFScaleFactors(0)=(FrequencyScale=(X=50.000000,Y=50.000000,Z=50.000000))
         UseBranching=True
         BranchProbability=(Min=1.000000,Max=1.000000)
         BranchSpawnAmountRange=(Min=5.000000,Max=5.000000)
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=255,G=255,R=128,A=255))
         ColorScale(1)=(RelativeTime=0.503571,Color=(B=255,G=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,A=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(X=(Min=-18.000000,Max=18.000000),Y=(Min=-18.000000,Max=18.000000),Z=(Min=-18.000000,Max=18.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1.000000,Max=1.000000)
         StartLocationPolarRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-32.000000,Max=32.000000))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         InitialParticlesPerSecond=90.000000
         Texture=Texture'kf_fx_trip_t.Misc.healingFX'
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRadialRange=(Min=50.000000,Max=50.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=BeamEmitter'ROEffects.ChargeUp3rdZEDGun.BeamEmitter0'

}
