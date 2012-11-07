// Flying Crossbow Arrow graphic


#exec OBJ LOAD FILE=KillingFloorWeapons.utx

class XbowTracer extends NewTracer;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         UseDirectionAs=PTDU_Right
         RespawnDeadParticles=False
         UseSizeScale=True
         UseAbsoluteTimeForSizeScale=True
         UseRegularSizeScale=False
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         ExtentMultiplier=(X=0.200000)
         ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=100
         SizeScale(1)=(RelativeTime=0.030000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=10.000000,Max=10.000000))
         ScaleSizeByVelocityMultiplier=(X=0.002000)
         Texture=Texture'KillingFloorWeapons.Xbow.XbowBoltGraphic'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=10000.000000,Max=10000.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.XbowTracer.SpriteEmitter13'

}
